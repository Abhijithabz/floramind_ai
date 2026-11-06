import 'package:flutter/material.dart';

class FloraMindAppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;

  void setThemeMode(ThemeMode themeMode) {
    if (_themeMode == themeMode) {
      return;
    }
    _themeMode = themeMode;
    notifyListeners();
  }

  void setLocale(Locale? locale) {
    if (_locale == locale) {
      return;
    }
    _locale = locale;
    notifyListeners();
  }
}

class FloraMindAppScope extends InheritedNotifier<FloraMindAppState> {
  const FloraMindAppScope({
    super.key,
    required FloraMindAppState state,
    required super.child,
  }) : super(notifier: state);

  static FloraMindAppState of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<FloraMindAppScope>();
    assert(scope != null, 'FloraMindAppScope not found in context.');
    return scope!.notifier!;
  }

  static FloraMindAppState? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FloraMindAppScope>()
        ?.notifier;
  }
}
