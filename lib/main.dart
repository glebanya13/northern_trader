import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/providers/theme_provider.dart';
import 'package:northern_trader/common/widgets/error.dart';
import 'package:northern_trader/common/widgets/loader.dart';
import 'package:northern_trader/features/auth/controller/auth_controller.dart';
import 'package:northern_trader/features/auth/screens/login_screen.dart';
import 'package:northern_trader/firebase_options.dart';
import 'package:northern_trader/router.dart';
import 'package:northern_trader/mobile_layout_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    rethrow;
  }
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colors = AppColors(isDark);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Northern Trader',
      themeMode: themeMode,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: colors.backgroundColor,
        appBarTheme: AppBarTheme(
          color: colors.appBarColor,
          iconTheme: IconThemeData(color: colors.textColor),
          titleTextStyle: TextStyle(
            color: colors.textColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: ColorScheme.light(
          primary: colors.accentColor,
          secondary: colors.accentColor,
          surface: colors.cardColor,
          onSurface: colors.textColor,
          onPrimary: blackColor,
        ),
        cardTheme: CardThemeData(
          color: colors.cardColor,
          elevation: 2,
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: colors.inputFieldColor,
          filled: true,
          hintStyle: TextStyle(color: colors.greyColor),
          labelStyle: TextStyle(color: colors.textColor),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: colors.backgroundColor,
        appBarTheme: AppBarTheme(
          color: colors.appBarColor,
          iconTheme: IconThemeData(color: colors.textColor),
          titleTextStyle: TextStyle(
            color: colors.textColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: ColorScheme.dark(
          primary: colors.accentColor,
          secondary: colors.accentColor,
          surface: colors.cardColor,
          onSurface: colors.textColor,
          onPrimary: blackColor,
        ),
        cardTheme: CardThemeData(
          color: colors.cardColor,
          elevation: 2,
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: colors.inputFieldColor,
          filled: true,
          hintStyle: TextStyle(color: colors.greyColor),
          labelStyle: TextStyle(color: colors.textColor),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru', 'RU'),
        Locale('en', 'US'),
      ],
      onGenerateRoute: (settings) => generateRoute(settings),
      home: ref.watch(userDataAuthProvider).when(
            data: (user) {
              if (user == null) {
                return const LoginScreen();
              }
              return const MobileLayoutScreen();
            },
            error: (err, trace) {
              return ErrorScreen(
                error: err.toString(),
              );
            },
            loading: () => const Loader(),
          ),
    );
  }
}

