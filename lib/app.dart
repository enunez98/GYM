import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'features/auth/login_screen.dart';

class GymApp extends StatelessWidget {
  const GymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GYM Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.energyGreen,
          brightness: Brightness.light,
          primary: AppColors.energyGreen,
          surface: AppColors.pureWhite,
          error: AppColors.red,
        ),
        scaffoldBackgroundColor: AppColors.softWhite,
        canvasColor: AppColors.pureWhite,
        dividerColor: AppColors.lightBorder,
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: AppColors.ink,
          displayColor: AppColors.ink,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.carbonBlack,
          foregroundColor: AppColors.boneWhite,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.pureWhite,
          labelStyle: const TextStyle(color: AppColors.ink),
          hintStyle: TextStyle(color: AppColors.ink.withValues(alpha: .45)),
          prefixIconColor: AppColors.energyGreen,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.lightBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.energyGreen,
              width: 1.5,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.energyGreen,
            foregroundColor: AppColors.carbonBlack,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.pureWhite,
          indicatorColor: AppColors.energyGreen.withValues(alpha: .2),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              color: states.contains(WidgetState.selected)
                  ? AppColors.energyGreen
                  : AppColors.ink.withValues(alpha: .55),
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
