import 'package:buzzing/common/localization/default_localizations.dart';
import 'package:flutter/material.dart';

class BuzzingLocalizationsDelegate
    extends LocalizationsDelegate<BuzzingLocalizations> {
  BuzzingLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // TODO: implement isSupported
    return true;
  }

  @override
  Future<BuzzingLocalizations> load(Locale locale) {
    return new SynchronousFuture<BuzzingLocalizations>(
        new BuzzingLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<BuzzingLocalizations> old) {
    return false;
  }

  static LocalizationsDelegate<BuzzingLocalizations> delegate =
      new BuzzingLocalizationsDelegate();
}
