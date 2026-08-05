import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/router/router.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/theme_provider.dart';
import 'features/profile/providers/profile_providers.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: SmartBankApp(),
    ),
  );
}

class SmartBankApp extends ConsumerWidget {
  const SmartBankApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final profile = ref.watch(profileControllerProvider).value;

    final appTitle = (profile != null && profile.id.isNotEmpty) 
        ? 'SmartBank | ${profile.fullName}' 
        : 'SmartBank AI';

    return MaterialApp.router(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: goRouter,
    );
  }
}
