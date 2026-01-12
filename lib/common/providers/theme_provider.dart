import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Провайдер для управления темой приложения
// На вебе всегда темная тема, на мобильных всегда светлая
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(kIsWeb ? ThemeMode.dark : ThemeMode.light);
}

// Провайдер для доступа к теме
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

