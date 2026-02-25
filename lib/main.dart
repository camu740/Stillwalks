import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/permissions_screen.dart';
import 'screens/google_fit_screen.dart';
import 'screens/home_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/language_selection_screen.dart';

import 'services/permission_service.dart';
import 'services/esencia_service.dart';
import 'services/orbe_service.dart';
import 'services/collection_service.dart';
import 'services/native_bridge.dart';
import 'services/widget_service.dart';
import 'services/notification_preferences_service.dart';
import 'services/notification_guard_service.dart';
import 'services/tutorial_service.dart';
import 'services/progression_service.dart';
import 'services/hatching_service.dart';
import 'services/google_fit_service.dart';
import 'services/audio_service.dart';

import 'providers/locale_provider.dart';
import 'data/seeds/initial_data.dart';
import 'l10n/app_localizations.dart';

void main() async {
  try {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    
    // Database seeding moved to AppInitializer to detect startup errors visually
    // and avoid "Skipped frames" on main thread
    
    runApp(const StillwalksApp());
  } catch (e, stackTrace) {
    debugPrint('CRITICAL ERROR DURING STARTUP: $e');
    debugPrint('Stack trace: $stackTrace');
    FlutterNativeSplash.remove(); // Ensure splash is removed on error
    runApp(ErrorApp(error: e, stackTrace: stackTrace));
  }
}

class ErrorApp extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;

  const ErrorApp({
    super.key,
    required this.error,
    required this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Critical Startup Error',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Please take a screenshot of this screen and send it to the developer.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.5)),
                    ),
                    child: SelectableText(
                      'Error: $error\n\nStack Trace:\n$stackTrace',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
        Provider(create: (_) => NativeBridge()),
        Provider(create: (_) => WidgetService()),
        Provider(create: (_) => ProgressionService()),
        ChangeNotifierProvider(create: (_) => HatchingService()),
        ChangeNotifierProvider(create: (_) => AudioService()),
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
          
          nativeBridge.onStepsUpdated = (newSteps, totalSteps) async {
            final result = await orbeService.addStepsToActiveOrbes(newSteps);
            final bonusEssence = result['essenceEarned'] as double;
            final unusedSteps = result['unusedSteps'] as int;

            if (bonusEssence > 0) {
              await esenciaService.addEsencia(bonusEssence);
              debugPrint('✨ Main: Bonus essence earned from orbs: $bonusEssence');
            }
            
            // Update persistent sync state
            await nativeBridge.setLastSyncedFlutterSteps(totalSteps);

            // Add unused steps to storage
            if (unusedSteps > 0) {
              await esenciaService.addStoredSteps(unusedSteps);
            }
            
            // Check daily goal
            await notificationGuard.updateDailySteps(newSteps);

            debugPrint('👟 Main: Received $newSteps steps from native (Total: $totalSteps)');
            updateWidget();
          };
          
          // Setup Google Fit sync if enabled
          void syncGoogleFitSteps() async {
            if (!googleFitService.isEnabled) return;
            
            final googleSteps = await googleFitService.getStepsSinceLastSync();
            if (googleSteps != null && googleSteps > 0) {
              debugPrint('📊 Synced $googleSteps steps from Google Fit');
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
                syncGoogleFitSteps();
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
    
    final esenciaService = Provider.of<EsenciaService>(context, listen: false);
    
    if (state == AppLifecycleState.resumed) {
      // App volvió a foreground
      _syncNativeSteps();
      esenciaService.startGenerationTimer();
      
      // Resume music
      final audioService = Provider.of<AudioService>(context, listen: false);
      audioService.resume();
      
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App sale de foreground
      esenciaService.stopGenerationTimer();
      _updateWidget();
      
      // Pause music
      final audioService = Provider.of<AudioService>(context, listen: false);
      audioService.pause();
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
        
        final result = await orbeService.addStepsToActiveOrbes(diff);
        final bonusEssence = result['essenceEarned'] as double;
        final unusedSteps = result['unusedSteps'] as int; 
        
        if (bonusEssence > 0) {
           await esenciaService.addEsencia(bonusEssence);
           debugPrint('✨ Main: Bonus essence earned from missed steps: $bonusEssence');
        }
        
        if (unusedSteps > 0) {
           await esenciaService.addStoredSteps(unusedSteps);
        }
        
        await nativeBridge.setLastSyncedFlutterSteps(sessionSteps);
      } else if (sessionSteps < lastSynced) {
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
      
      await InitialData.seedDatabase();

      await esenciaService.initialize();
      await orbeService.initialize();
      await collectionService.initialize();
      
      final tutorialService = Provider.of<TutorialService>(context, listen: false);
      await tutorialService.initialize();
      
      if (!tutorialService.isCompleted) {
        debugPrint('🎓 AppInitializer: Tutorial incomplete (Step: ${tutorialService.currentStep}). Resetting to start.');
        await tutorialService.resetTutorial();
        await esenciaService.resetProgress();
        await orbeService.resetState();
      }
      
      final notificationPreferences = Provider.of<NotificationPreferencesService>(context, listen: false);
      final notificationGuard = Provider.of<NotificationGuardService>(context, listen: false);
      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
      await notificationPreferences.initialize();
      await notificationGuard.initialize();
      
      if (!notificationPreferences.settings.hasLanguageBeenSelected) {
        localeProvider.setLocale('en');
      } else {
        localeProvider.setLocale(notificationPreferences.settings.language);
      }
      
      notificationPreferences.setNativeBridge(nativeBridge);
      notificationGuard.setPreferences(notificationPreferences);
      notificationGuard.setNativeBridge(nativeBridge);
      notificationGuard.setNativeBridge(nativeBridge);
      orbeService.setNotificationServices(nativeBridge, notificationPreferences, notificationGuard);
      esenciaService.setNotificationServices(nativeBridge, notificationPreferences, notificationGuard);
      esenciaService.setCollectionService(collectionService);
      esenciaService.setTutorialService(tutorialService);

      orbeService.setEsenciaService(esenciaService);
      orbeService.listenToEssenceService(esenciaService.onEssenceEarned);
      
      esenciaService.startGenerationTimer();
      
      await permissionService.checkPermission();
      
      if (permissionService.hasPermission) {
        try {
          await nativeBridge.startTracking();
          debugPrint('✅ Native tracking started');
        } catch (e) {
          debugPrint('⚠️ Error starting native tracking: $e');
        }
      }

      if (context.mounted) await _syncNativeSteps();
      
      setState(() {
        _isInitialized = true;
      });
      
      debugPrint('✅ Stillwalks initialized successfully');
      FlutterNativeSplash.remove();
      
      // Start background music with saved volume
      if (context.mounted) {
        final audioService = Provider.of<AudioService>(context, listen: false);
        final savedVolume = notificationPreferences.settings.musicVolume;
        audioService.initialize(volume: savedVolume);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing app: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
      FlutterNativeSplash.remove();
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
        backgroundColor: Colors.black, // Dark theme background
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo de la app
              Image.asset(
                'assets/ui/stillwalks-logo.png',
                width: 140, 
                height: 140,
              ),
              const SizedBox(height: 32),
              // Loading indicator discreto
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    final permissionService = Provider.of<PermissionService>(context);
    final notificationPreferences = Provider.of<NotificationPreferencesService>(context);
    
    if (!notificationPreferences.settings.hasLanguageBeenSelected) {
      return const LanguageSelectionScreen();
    }
    
    if (!permissionService.hasPermission) {
      return const PermissionsScreen();
    }

    final googleFitService = Provider.of<GoogleFitService>(context);

    if (!googleFitService.isEnabled && !notificationPreferences.settings.hasSeenGoogleFitPrompt) {
      return const GoogleFitScreen();
    }
    
    return const HomeScreen();
  }
}
