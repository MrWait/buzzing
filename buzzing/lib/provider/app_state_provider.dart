import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buzzing/i18n/strings.g.dart';

import '../controller/app_controller.dart';
import '../utils/data_persistence.dart';

@immutable
class AppState {
  final int theme;
  final bool isRunningBackground;
  final int languageIndex;

  const AppState({
    this.theme = 0,
    this.isRunningBackground = false,
    this.languageIndex = 0,
  });

  AppState copyWith({
    int? theme,
    bool? isRunningBackground,
    int? languageIndex,
  }) {
    return AppState(
      theme: theme ?? this.theme,
      isRunningBackground: isRunningBackground ?? this.isRunningBackground,
      languageIndex: languageIndex ?? this.languageIndex,
    );
  }

  Locale? get locale {
    switch (languageIndex) {
      case 1:
        return const Locale('zh', 'CN');
      case 2:
        return const Locale('en', 'US');
      default:
        return WidgetsBinding.instance.platformDispatcher.locale;
    }
  }
}

class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    _init();
    return const AppState(
      languageIndex: 0,
    );
  }

  Future<void> _init() async {
    final index = DataPersistence.getLanguage() ?? 0;
    state = state.copyWith(languageIndex: index);
    switch (index) {
      case 1:
        LocaleSettings.setLocale(AppLocale.zh);
      case 2:
        LocaleSettings.setLocale(AppLocale.en);
      default:
        break;
    }
  }

  void setRunningBackground(bool running) {
    state = state.copyWith(isRunningBackground: running);
  }

  void changeTheme(int theme) {
    state = state.copyWith(theme: theme);
  }

  void changeLanguage(int index) {
    state = state.copyWith(languageIndex: index);
    DataPersistence.putLanguage(index);
    switch (index) {
      case 1:
        LocaleSettings.setLocale(AppLocale.zh);
      case 2:
        LocaleSettings.setLocale(AppLocale.en);
      default:
        LocaleSettings.useDeviceLocale();
    }
  }
}

final appStateProvider = NotifierProvider<AppStateNotifier, AppState>(
  AppStateNotifier.new,
);

final appControllerProvider = Provider<AppController>((ref) {
  final controller = AppController();
  controller.onInit();
  ref.onDispose(() => controller.onClose());
  return controller;
});
