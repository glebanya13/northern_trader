import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════
// 🎨 ОСНОВНАЯ ПАЛИТРА - Темная и светлая тема с салатовым акцентом
// ═══════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════
// 🟢 САЛАТОВЫЕ АКЦЕНТЫ - разные для светлой и темной темы
// ═══════════════════════════════════════════════════════════

// Салатовые акценты для темной темы (яркие)
const limeGreen = Color.fromRGBO(190, 255, 100, 1);              // Яркий салатовый для темной темы
const limeGreenDark = Color.fromRGBO(150, 220, 80, 1);           // Темнее для hover (темная тема)
const limeGreenMuted = Color.fromRGBO(170, 235, 90, 1);          // Приглушенный для фона (темная тема)

// Салатовые акценты для светлой темы (более темные и насыщенные для контраста)
const limeGreenLight = Color.fromRGBO(120, 200, 50, 1);         // Более темный салатовый для светлой темы
const limeGreenDarkLight = Color.fromRGBO(100, 170, 40, 1);     // Еще темнее для hover (светлая тема)
const limeGreenMutedLight = Color.fromRGBO(140, 210, 60, 1);    // Приглушенный для фона (светлая тема)

// Дополнительные акценты - одинаковые для обеих тем
const purpleAccent = Color.fromRGBO(160, 100, 255, 1);           // Фиолетовый для дополнительных акцентов
const goldAccent = Color.fromRGBO(255, 215, 0, 1);               // Оставляем золотой
const lightBlue = Color.fromRGBO(100, 200, 255, 1);              // Голубой акцент

// Утилитарные цвета - одинаковые
const blackColor = Color.fromRGBO(12, 12, 12, 1);               // Глубокий черный
const whiteColor = Color.fromRGBO(255, 255, 255, 1);            // Чистый белый для иконок

// ═══════════════════════════════════════════════════════════
// 🌙 ТЕМНАЯ ТЕМА
// ═══════════════════════════════════════════════════════════

// Основные фоновые цвета (темная тема)
const backgroundColorDark = Color.fromRGBO(18, 18, 18, 1);           // Глубокий черный фон
const appBarColorDark = Color.fromRGBO(24, 24, 24, 1);               // Чуть светлее для AppBar
const webAppBarColorDark = Color.fromRGBO(24, 24, 24, 1);

// Текстовые цвета (темная тема)
const textColorDark = Color.fromRGBO(245, 245, 245, 1);              // Почти белый для читаемости
const textColorSecondaryDark = Color.fromRGBO(160, 160, 160, 1);     // Серый для второстепенного текста
const greyColorDark = Color.fromRGBO(130, 130, 130, 1);              // Средний серый

// Карточки и контейнеры (темная тема)
const cardColorDark = Color.fromRGBO(28, 28, 28, 1);                 // Темно-серая карточка
const cardColorLightDark = Color.fromRGBO(35, 35, 35, 1);            // Светлее для вложенных элементов
const cardColorDarker = Color.fromRGBO(22, 22, 22, 1);             // Темнее основного фона

// Специфичные цвета элементов (темная тема)
const searchBarColorDark = cardColorDark;                                 // Темная поисковая строка
const dividerColorDark = Color.fromRGBO(45, 45, 45, 1);             // Серый разделитель
const inputFieldColorDark = cardColorDark;                                // Темное поле ввода
const chatBarMessageDark = cardColorLightDark;                            // Панель сообщений
const mobileChatBoxColorDark = cardColorDark;                             // Контейнер чата

// ═══════════════════════════════════════════════════════════
// ☀️ СВЕТЛАЯ ТЕМА
// ═══════════════════════════════════════════════════════════

// Основные фоновые цвета (светлая тема)
const backgroundColorLight = Color.fromRGBO(250, 250, 250, 1);           // Светло-серый фон
const appBarColorLight = Color.fromRGBO(255, 255, 255, 1);               // Белый AppBar
const webAppBarColorLight = Color.fromRGBO(255, 255, 255, 1);

// Текстовые цвета (светлая тема)
const textColorLight = Color.fromRGBO(18, 18, 18, 1);              // Темный текст для читаемости
const textColorSecondaryLight = Color.fromRGBO(100, 100, 100, 1);     // Серый для второстепенного текста
const greyColorLight = Color.fromRGBO(130, 130, 130, 1);              // Средний серый

// Карточки и контейнеры (светлая тема)
const cardColorLight = Color.fromRGBO(255, 255, 255, 1);                 // Белая карточка
const cardColorLightLight = Color.fromRGBO(248, 248, 248, 1);            // Светло-серая для вложенных элементов
const cardColorDarkerLight = Color.fromRGBO(240, 240, 240, 1);             // Светло-серый для контраста

// Специфичные цвета элементов (светлая тема)
const searchBarColorLight = cardColorLight;                                 // Светлая поисковая строка
const dividerColorLight = Color.fromRGBO(230, 230, 230, 1);             // Светлый разделитель
const inputFieldColorLight = cardColorLight;                                // Светлое поле ввода
const chatBarMessageLight = cardColorLightLight;                            // Панель сообщений
const mobileChatBoxColorLight = cardColorLight;                             // Контейнер чата

// ═══════════════════════════════════════════════════════════
// 🎨 КЛАСС ДЛЯ УПРАВЛЕНИЯ ЦВЕТАМИ В ЗАВИСИМОСТИ ОТ ТЕМЫ
// ═══════════════════════════════════════════════════════════

class AppColors {
  final bool isDark;

  AppColors(this.isDark);

  // Основные фоновые цвета
  Color get backgroundColor => isDark ? backgroundColorDark : backgroundColorLight;
  Color get appBarColor => isDark ? appBarColorDark : appBarColorLight;
  Color get webAppBarColor => isDark ? webAppBarColorDark : webAppBarColorLight;

  // Текстовые цвета
  Color get textColor => isDark ? textColorDark : textColorLight;
  Color get textColorSecondary => isDark ? textColorSecondaryDark : textColorSecondaryLight;
  Color get greyColor => isDark ? greyColorDark : greyColorLight;

  // Карточки и контейнеры (ВСЕГДА темные в обеих темах)
  Color get cardColor => cardColorDark;  // Всегда темный
  Color get cardColorLight => cardColorLightDark;  // Всегда темный светлый оттенок
  Color get cardColorDark => cardColorDarker;  // Всегда самый темный

  // Специфичные цвета элементов
  Color get searchBarColor => isDark ? searchBarColorDark : searchBarColorLight;
  Color get dividerColor => isDark ? dividerColorDark : dividerColorLight;
  Color get inputFieldColor => isDark ? inputFieldColorDark : inputFieldColorLight;
  Color get inputColor => isDark ? inputFieldColorDark : inputFieldColorLight;
  Color get richTextColor => isDark ? textColorDark : textColorLight;
  Color get chatBarMessage => isDark ? chatBarMessageDark : chatBarMessageLight;
  Color get mobileChatBoxColor => isDark ? mobileChatBoxColorDark : mobileChatBoxColorLight;

  // Салатовые акценты (адаптивные к теме)
  Color get accentColor => isDark ? limeGreen : limeGreenLight;  // Основной акцентный цвет
  Color get accentColorDark => isDark ? limeGreenDark : limeGreenDarkLight;  // Темнее для hover
  Color get accentColorMuted => isDark ? limeGreenMuted : limeGreenMutedLight;  // Приглушенный для фона

  // Цвета сообщений
  Color get messageColor => accentColor;  // Салатовый для исходящих сообщений
  Color get senderMessageColor => isDark ? cardColorLightDark : cardColorLightLight;  // Для входящих сообщений
  Color get tabColor => accentColor;  // Салатовые табы

  // Белые карточки (для контраста)
  Color get whiteCardColor => isDark ? Color.fromRGBO(245, 245, 245, 1) : Color.fromRGBO(18, 18, 18, 1);
  Color get whiteCardTextColor => isDark ? Color.fromRGBO(18, 18, 18, 1) : Color.fromRGBO(245, 245, 245, 1);
  Color get whiteCardSecondaryTextColor => isDark ? Color.fromRGBO(80, 80, 80, 1) : Color.fromRGBO(160, 160, 160, 1);
  
  // Цвета текста для карточек (ВСЕГДА светлые, так как карточки всегда темные)
  Color get cardTextColor => textColorDark;  // Всегда светлый текст
  Color get cardTextColorSecondary => textColorSecondaryDark;  // Всегда светлый вторичный текст
  Color get cardGreyColor => greyColorDark;  // Всегда светлый серый
}

// ═══════════════════════════════════════════════════════════
// 🔄 ОБРАТНАЯ СОВМЕСТИМОСТЬ - старые константы для темной темы
// ═══════════════════════════════════════════════════════════

// Основные фоновые цвета
const backgroundColor = backgroundColorDark;
const appBarColor = appBarColorDark;
const webAppBarColor = webAppBarColorDark;

// Текстовые цвета
const textColor = textColorDark;
const textColorSecondary = textColorSecondaryDark;
const greyColor = greyColorDark;

// Карточки и контейнеры (используем алиасы для обратной совместимости)
const cardColor = cardColorDark;
// Примечание: cardColorLight и cardColorDark теперь методы класса AppColors
// Для обратной совместимости используем прямые ссылки на константы темной темы
const cardColorLightCompat = cardColorLightDark;  // Для обратной совместимости
const cardColorDarkCompat = cardColorDarker;  // Для обратной совместимости

// Специфичные цвета элементов
const messageColor = limeGreen;
const senderMessageColor = cardColorLightDark;
const tabColor = limeGreen;
const searchBarColor = searchBarColorDark;
const dividerColor = dividerColorDark;
const inputFieldColor = inputFieldColorDark;
const chatBarMessage = chatBarMessageDark;
const mobileChatBoxColor = mobileChatBoxColorDark;

// Белые карточки (для контраста)
const whiteCardColor = Color.fromRGBO(245, 245, 245, 1);
const whiteCardTextColor = Color.fromRGBO(18, 18, 18, 1);
const whiteCardSecondaryTextColor = Color.fromRGBO(80, 80, 80, 1);

