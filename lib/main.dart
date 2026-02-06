import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/permissions_screen.dart';
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
import 'providers/locale_provider.dart';
import 'data/seeds/initial_data.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

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
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        Provider(create: (_) => NativeBridge()),
        Provider(create: (_) => WidgetService()),
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
          
          // Configure callbacks from native Android
          nativeBridge.onEsenciaGenerated = (esencia, hours) async {
            await esenciaService.addEsencia(esencia, fromNative: true);
            debugPrint('🎯 Main: Received $esencia Esencia from native ($hours hours)');
            updateWidget();
          };
          
          nativeBridge.onStepsUpdated = (newSteps, totalSteps) async {
            final result = await orbeService.addStepsToActiveOrbes(newSteps);
            final activeOrbs = result['count'] as int;
            final bonusEssence = result['essenceEarned'] as double;

            if (bonusEssence > 0) {
              await esenciaService.addEsencia(bonusEssence);
              debugPrint('✨ Main: Bonus essence earned from orbs: $bonusEssence');
            }

            if (activeOrbs == 0) {
              await esenciaService.addStoredSteps(newSteps);
            }
            
            // Check daily goal
            await notificationGuard.updateDailySteps(newSteps);

            debugPrint('👟 Main: Received $newSteps steps from native (Total: $totalSteps)');
            updateWidget();
          };
          
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
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      debugPrint('📱 App lifecycle changed to $state. Updating widget...');
      _updateWidget();
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
      
      // Initialize notification preferences
      final notificationPreferences = Provider.of<NotificationPreferencesService>(context, listen: false);
      final notificationGuard = Provider.of<NotificationGuardService>(context, listen: false);
      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
      await notificationPreferences.initialize();
      await notificationGuard.initialize();
      
      // Sync locale with saved language setting
      localeProvider.setLocale(notificationPreferences.settings.language);
      
      // Wire notification services to services
      notificationPreferences.setNativeBridge(nativeBridge);
      notificationGuard.setPreferences(notificationPreferences);
      notificationGuard.setNativeBridge(nativeBridge);
      orbeService.setNotificationServices(nativeBridge, notificationPreferences, notificationGuard);
      esenciaService.setNotificationServices(nativeBridge, notificationPreferences, notificationGuard);
      
      // Wire game mechanics listeners
      orbeService.listenToEssenceService(esenciaService.onEssenceEarned);
      
      // Calculate pending Esencia from offline time
      await esenciaService.calculatePendingEsencia();
      
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
    
    // Show permissions screen if not granted
    if (!permissionService.hasPermission) {
      return const PermissionsScreen();
    }
    
    // Show home if permissions granted
    return const HomeScreen();
  }
}
