import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:train_easy_design_system/train_easy_design_system.dart';
import 'package:traineasy/firebase_options.dart';
import 'package:traineasy/presentation/home/home_page.dart';
import 'package:traineasy/presentation/auth/widgets/auth_gate.dart';
import 'package:traineasy/core/di/injector.dart';
import 'package:traineasy/core/config/environment_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await EnvironmentConfig.load();
  if (!EnvironmentConfig.isValid && kDebugMode) {
    // Log de diagnóstico para facilitar configuração
    debugPrint('⚠️ .env inválido ou incompleto. Verifique suas variáveis de ambiente.');
    debugPrint('  FIREBASE_PROJECT_ID: ${EnvironmentConfig.projectId.isEmpty ? 'VAZIO' : 'OK'}');
    debugPrint('  FIREBASE_ANDROID_APP_ID: ${EnvironmentConfig.androidAppId.isEmpty ? 'VAZIO' : 'OK'}');
    debugPrint('  FIREBASE_IOS_APP_ID: ${EnvironmentConfig.iosAppId.isEmpty ? 'VAZIO' : 'OK'}');
    debugPrint('  FIREBASE_WEB_APP_ID: ${EnvironmentConfig.webAppId.isEmpty ? 'VAZIO' : 'OK'}');
    debugPrint('  FIREBASE_API_KEY: ${EnvironmentConfig.apiKey.isEmpty ? 'VAZIO' : 'OK'}');
    debugPrint('  FIREBASE_AUTH_DOMAIN: ${EnvironmentConfig.authDomain.isEmpty ? 'VAZIO' : 'OK'}');
    debugPrint('  FIREBASE_DATABASE_URL: ${EnvironmentConfig.databaseUrl.isEmpty ? 'VAZIO' : 'OK'}');
    debugPrint('  FIREBASE_STORAGE_BUCKET: ${EnvironmentConfig.storageBucket.isEmpty ? 'VAZIO' : 'OK'}');
    debugPrint('  FIREBASE_MESSAGING_SENDER_ID: ${EnvironmentConfig.messagingSenderId.isEmpty ? 'VAZIO' : 'OK'}');
    debugPrint('  FIREBASE_MEASUREMENT_ID: ${EnvironmentConfig.measurementId.isEmpty ? 'VAZIO' : 'OK'}');
  }
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Injector.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Train Easy',
      debugShowCheckedModeBanner: false,
      theme: buildTrainEasyTheme(),
      home: _RootSplash(
        nextPage: const AuthGate(
          childWhenAuthed: HomePage(),
        ),
      ),
    );
  }
}

class _RootSplash extends StatefulWidget {
  const _RootSplash({required this.nextPage});
  final Widget nextPage;

  @override
  State<_RootSplash> createState() => _RootSplashState();
}

class _RootSplashState extends State<_RootSplash> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scale = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 2000), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, __, ___) => widget.nextPage,
      transitionDuration: const Duration(milliseconds: 450),
      transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.surface2, AppColors.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: size.width * 0.9,
              height: size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.18),
                    AppColors.accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Opacity(
                    opacity: _fade.value,
                    child: Transform.scale(
                      scale: _scale.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(AppSpacing.s5),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.surface2,
                                borderRadius: BorderRadius.all(Radius.circular(AppRadius.r3)),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(AppSpacing.s5),
                                child: Icon(Icons.fitness_center, size: 56, color: AppColors.accent),
                              ),
                            ),
                          ),
                          SizedBox(height: AppSpacing.s2),
                          Text('Train Easy', style: AppTypography.h1),
                          SizedBox(height: AppSpacing.s2),
                          Text('Seu treino, seu personal, sua evolução', textAlign: TextAlign.center, style: AppTypography.caption),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
