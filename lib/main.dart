import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/permissions_screen.dart';
import 'screens/google_fit_screen.dart';
import 'screens/home_screen.dart';
import 'screens/shop_screen.dart';
import 'services/permission_service.dart';
import 'services/esencia_service.dart';
import 'services/orbe_service.dart';
import 'services/collection_service.dart';
import 'services/native_bridge.dart';
import 'services/widget_service.dart';
import 'services/notification_preferences_service.dart';
import 'services/notification_guard_service.dart';
import 'services/tutorial_service.dart';
import 'services/progression_service.dart'; // Added
import 'services/google_fit_service.dart';
// import 'services/active_time_tracker.dart'; // Removed
import 'providers/locale_provider.dart';
import 'data/seeds/initial_data.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'screens/language_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Seed database on first run
  await InitialData.seedDatabase();
  
  runApp(const StillwalksApp());
}

class StillwalksApp extends StatelessWidget {
  const StillwalksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PermissionService()),
        ChangeNotifierProvider(create: (_) => EsenciaService()),
        ChangeNotifierProvider(create: (_) => OrbeService()),
        ChangeNotifierProvider(create: (_) => CollectionService()),
        ChangeNotifierProvider(create: (_) => NotificationPreferencesService()),
        ChangeNotifierProvider(create: (_) => NotificationGuardService()),
        ChangeNotifierProvider(create: (_) => TutorialService()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => GoogleFitService()..initialize()),
        // ChangeNotifierProvider(create: (_) => ActiveTimeTracker()), // Removed
        Provider(create: (_) => NativeBridge()),
        Provider(create: (_) => WidgetService()),
        Provider(create: (_) => ProgressionService()), // Added
      ],
      child: Builder(
        builder: (context) {
          // Setup native bridge callbacks after providers are available
          final nativeBridge = Provider.of<NativeBridge>(context, listen: false);
          final esenciaService = Provider.of<EsenciaService>(context, listen: false);
          final orbeService = Provider.of<OrbeService>(context, listen: false);
          final widgetService = Provider.of<WidgetService>(context, listen: false);
          final collectionService = Provider.of<CollectionService>(context, listen: false);
          final notificationGuard = Provider.of<NotificationGuardService>(context, listen: false);
          final googleFitService = Provider.of<GoogleFitService>(context, listen: false);
          
          // Helper to update widget
          void updateWidget() async {
            final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
            final l10n = await AppLocalizations.delegate.load(localeProvider.locale);
            
            widgetService.updateWidgetData(
              essenceService: esenciaService, 
              orbeService: orbeService,
              collectionService: collectionService,
              nativeBridge: nativeBridge,
              l10n: l10n,
            );
            
            // Sync localization to native
            nativeBridge.syncLocalization(l10n);
          }
          
          // Listen to changes in services to update widget automatically
          esenciaService.addListener(updateWidget);
          orbeService.addListener(updateWidget);
          collectionService.addListener(updateWidget);
          
          // REMOVED: Native Android no longer generates essence
          // All essence generation is now handled by Flutter
          // nativeBridge.onEsenciaGenerated callback removed
          
          nativeBridge.onStepsUpdated = (newSteps, totalSteps) async {
            final result = await orbeService.addStepsToActiveOrbes(newSteps);
            final bonusEssence = result['essenceEarned'] as double;
            final unusedSteps = result['unusedSteps'] as int; // Get unused steps

            if (bonusEssence > 0) {
              await esenciaService.addEsencia(bonusEssence);
              debugPrint('✨ Main: Bonus essence earned from orbs: $bonusEssence');
            }
            
            // Update persistent sync state
            await nativeBridge.setLastSyncedFlutterSteps(totalSteps);

            // Add unused steps to storage (instead of only if activeOrbs == 0)
            if (unusedSteps > 0) {
              await esenciaService.addStoredSteps(unusedSteps);
            }
            
            // Check daily goal
            await notificationGuard.updateDailySteps(newSteps);

            debugPrint('👟 Main: Received $newSteps steps from native (Total: $totalSteps)');
            updateWidget();
          };

          // Validar sincronización inicial de pasos (recuperar pasos perdidos en background)
          // Esto se maneja ahora en _AppInitializerState via _syncNativeSteps
          // pero como _AppInitializerState.initState/didChangeApp works on its own context/services,
          // we might want it there. 
          // Actually, AppInitializer is the HOME widget.
          // The code block lines 118-152 was inside `StillwalksApp.build` -> `MultiProvider` -> `Builder`.
          // This creates a duplicate logic issue if I moved it to `AppInitializer`.
          // BUT `AppInitializer` is stateful and has lifecycle access.
          // The code in `StillwalksApp` `addPostFrameCallback` runs once when the App Widget is built.
          // I should REMOVE it from here and let `AppInitializer` handle it entirely, 
          // OR expose the method.
          
          // Since I added `_syncNativeSteps` to `_AppInitializerState`, I can remove this block 
          // from `StillwalksApp` to avoid duplication/race conditions, 
          // AS LONG AS `AppInitializer` calls it on init.
          // `AppInitializer._initialize` handles service init. I should call `_syncNativeSteps` there too.
          
          // Removing this block to cleanup.
          
          // Setup Google Fit sync if enabled
          void syncGoogleFitSteps() async {
            if (!googleFitService.isEnabled) return;
            
            final googleSteps = await googleFitService.getStepsSinceLastSync();
            if (googleSteps != null && googleSteps > 0) {
              debugPrint('📊 Synced $googleSteps steps from Google Fit');
              //  Process Google Fit steps the same way as hardware sensor steps
              final result = await orbeService.addStepsToActiveOrbes(googleSteps);
              final bonusEssence = result['essenceEarned'] as double;
              final unusedSteps = result['unusedSteps'] as int;
              
              if (bonusEssence > 0) {
                await esenciaService.addEsencia(bonusEssence);
              }
              
              if (unusedSteps > 0) {
                await esenciaService.addStoredSteps(unusedSteps);
              }
              
              updateWidget();
            }
          }
          
          // Sync Google Fit every 5 minutes if enabled
          Future<void> startGoogleFitSync() async {
            while (true) {
              await Future.delayed(const Duration(minutes: 5));
              if (googleFitService.isEnabled) {
                syncGoogleFitSteps(); // No await - function is void
              }
            }
          }
          
          // Start background sync
          startGoogleFitSync();
          
          return Consumer<LocaleProvider>(
            builder: (context, localeProvider, _) {
              return MaterialApp(
                title: 'Stillwalks',
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('es'),
                  Locale('en'),
                ],
                locale: localeProvider.locale,
                theme: ThemeData(
                  brightness: Brightness.dark,
                  primarySwatch: Colors.deepPurple,
                  scaffoldBackgroundColor: Colors.black,
                  useMaterial3: true,
                ),
                home: const AppInitializer(),
                routes: {
                  '/shop': (context) => const ShopScreen(),
                },
                debugShowCheckedModeBanner: false,
              );
            },
          );
        },
      ),
    );
  }
}

/// Widget that initializes all services before showing the app
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> with WidgetsBindingObserver {
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('📱 App lifecycle changed to $state');
    
    // final activeTimeTracker = Provider.of<ActiveTimeTracker>(context, listen: false); // Removed
    final esenciaService = Provider.of<EsenciaService>(context, listen: false);
    final nativeBridge = Provider.of<NativeBridge>(context, listen: false);
    
    if (state == AppLifecycleState.resumed) {
      // App volvió a foreground
      
      // Calcular esencia pendiente (Offline)
      esenciaService.calculateOfflineEssence();
      
      // Sincronizar pasos (Native -> Flutter)
      _syncNativeSteps();
      
      // Start foreground generation
      esenciaService.startGenerationTimer();
      
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App sale de foreground
      
      // Stop foreground generation
      esenciaService.stopGenerationTimer();
      
      // Actualizar widget
      _updateWidget();
    }
  }

  Future<void> _syncNativeSteps() async {
    if (!mounted) return;
    try {
      final nativeBridge = Provider.of<NativeBridge>(context, listen: false);
      final orbeService = Provider.of<OrbeService>(context, listen: false);
      final esenciaService = Provider.of<EsenciaService>(context, listen: false);
      
      final sessionSteps = await nativeBridge.getSteps();
      final lastSynced = await nativeBridge.getLastSyncedFlutterSteps();
      
      if (sessionSteps > lastSynced) {
        final diff = sessionSteps - lastSynced;
        debugPrint('🔄 Main: Syncing $diff missed steps (Native: $sessionSteps, Last: $lastSynced)');
        
        // Add missed steps
        final result = await orbeService.addStepsToActiveOrbes(diff);
        final bonusEssence = result['essenceEarned'] as double;
        final unusedSteps = result['unusedSteps'] as int; 
        
        if (bonusEssence > 0) {
           await esenciaService.addEsencia(bonusEssence);
           debugPrint('✨ Main: Bonus essence earned from missed steps: $bonusEssence');
        }
        
        // Add unused steps to storage
        if (unusedSteps > 0) {
           await esenciaService.addStoredSteps(unusedSteps);
        }
        
        // Update sync state
        await nativeBridge.setLastSyncedFlutterSteps(sessionSteps);
      } else if (sessionSteps < lastSynced) {
         // Restart/Reboot detected?
         debugPrint('⚠️ Main: Native steps ($sessionSteps) < Last Synced ($lastSynced). Resetting sync.');
         await nativeBridge.setLastSyncedFlutterSteps(sessionSteps);
      }
    } catch (e) {
      debugPrint('❌ Error syncing missed steps: $e');
    }
  }

  void _updateWidget() {
    if (!mounted) return;
    try {
      final nativeBridge = Provider.of<NativeBridge>(context, listen: false);
      final esenciaService = Provider.of<EsenciaService>(context, listen: false);
      final orbeService = Provider.of<OrbeService>(context, listen: false);
      final collectionService = Provider.of<CollectionService>(context, listen: false);
      final widgetService = Provider.of<WidgetService>(context, listen: false);
      
      final notificationGuard = Provider.of<NotificationGuardService>(context, listen: false);
      
      notificationGuard.updateAppActive();
      
      final l10n = AppLocalizations.of(context)!;
      
      widgetService.updateWidgetData(
        essenceService: esenciaService, 
        orbeService: orbeService, 
        collectionService: collectionService,
        nativeBridge: nativeBridge,
        l10n: l10n,
      );
      
      nativeBridge.syncLocalization(l10n);
    } catch (e) {
      debugPrint('⚠️ Error updating widget from lifecycle: $e');
    }
  }

  Future<void> _initialize() async {
    try {
      debugPrint('🚀 Initializing Stillwalks...');
      
      final esenciaService = Provider.of<EsenciaService>(context, listen: false);
      final orbeService = Provider.of<OrbeService>(context, listen: false);
      final collectionService = Provider.of<CollectionService>(context, listen: false);
      final permissionService = Provider.of<PermissionService>(context, listen: false);
      final nativeBridge = Provider.of<NativeBridge>(context, listen: false);
      
      // Initialize all services
      await esenciaService.initialize();
      await orbeService.initialize();
      await collectionService.initialize();
      
      // Initialize Tutorial and check integrity
      final tutorialService = Provider.of<TutorialService>(context, listen: false);
      await tutorialService.initialize();
      
      if (!tutorialService.isCompleted) {
        debugPrint('🎓 AppInitializer: Tutorial incomplete (Step: ${tutorialService.currentStep}). Resetting to start.');
        await tutorialService.resetTutorial();
        // Reset Game State to prevent exploits (free orbs/essence)
        await esenciaService.resetProgress();
        await orbeService.resetState();
      }
      
      // Initialize notification preferences
      final notificationPreferences = Provider.of<NotificationPreferencesService>(context, listen: false);
      final notificationGuard = Provider.of<NotificationGuardService>(context, listen: false);
      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
      await notificationPreferences.initialize();
      await notificationGuard.initialize();
      
      // Sync locale with saved language setting
      if (!notificationPreferences.settings.hasLanguageBeenSelected) {
        // Force English by default for the selection screen
        localeProvider.setLocale('en');
      } else {
        localeProvider.setLocale(notificationPreferences.settings.language);
      }
      
      // Wire notification services to services
      notificationPreferences.setNativeBridge(nativeBridge);
      notificationGuard.setPreferences(notificationPreferences);
      notificationGuard.setNativeBridge(nativeBridge);
      notificationGuard.setNativeBridge(nativeBridge);
      orbeService.setNotificationServices(nativeBridge, notificationPreferences, notificationGuard);
      esenciaService.setNotificationServices(nativeBridge, notificationPreferences, notificationGuard);
      esenciaService.setCollectionService(collectionService); // Added
      
      // Wire game mechanics listeners
      orbeService.setEsenciaService(esenciaService);
      orbeService.listenToEssenceService(esenciaService.onEssenceEarned);
      
      // Calculate pending Esencia from offline time
      // final activeTimeTracker = Provider.of<ActiveTimeTracker>(context, listen: false); // Removed
      await esenciaService.calculateOfflineEssence();
      
      // Start foreground generation immediately
      esenciaService.startGenerationTimer();
      
      // Check permissions
      await permissionService.checkPermission();
      
      // Start native tracking if permissions granted
      if (permissionService.hasPermission) {
        try {
          await nativeBridge.startTracking();
          debugPrint('✅ Native tracking started');
        } catch (e) {
          debugPrint('⚠️ Error starting native tracking: $e');
          // Non-fatal, can continue without native tracking
        }
      }

      // Initial Sync of steps
      if (context.mounted) await _syncNativeSteps();
      
      setState(() {
        _isInitialized = true;
      });
      
      debugPrint('✅ Stillwalks initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing app: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Error al inicializar',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _isInitialized = false;
                    });
                    _initialize();
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/creatures/spiristone.png',
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.pets, size: 100, color: Colors.deepPurple),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
              ),
              const SizedBox(height: 16),
              const Text(
                'Inicializando Stillwalks...',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    
    final permissionService = Provider.of<PermissionService>(context);
    final notificationPreferences = Provider.of<NotificationPreferencesService>(context);
    
    // Check if language has been selected first
    if (!notificationPreferences.settings.hasLanguageBeenSelected) {
      return const LanguageSelectionScreen();
    }
    
    // Show permissions screen if not granted
    if (!permissionService.hasPermission) {
      return const PermissionsScreen();
    }

    // Show Google Fit screen if not connected and not skipped
    final googleFitService = Provider.of<GoogleFitService>(context);
    // Note: googleFitService.isEnabled is true if user has connected.
    // hasSeenGoogleFitPrompt tracks if they already made a choice (skip/connect).
    if (!googleFitService.isEnabled && !notificationPreferences.settings.hasSeenGoogleFitPrompt) {
      return const GoogleFitScreen();
    }
    
    // Show home if permissions granted
    return const HomeScreen();
  }
}
