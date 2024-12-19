import 'dart:html';

import 'package:buzzing/common/utils/common_utils.dart';
import 'package:buzzing/common/utils/navigator_utils.dart';
import 'package:flutter/material.dart';
import 'package:buzzing/common/localization/buzzing_string_base.dart';
import 'package:buzzing/common/localization/buzzing_string_en.dart';
import 'package:buzzing/common/localization/buzzing_string_zh.dart';

class BuzzingLocalizations {
  final Locale locale;

  BuzzingLocalizations(this.locale);

  static Map<String, BuzzingStringBase> _localizedValues = {
    'en': new BuzzingStringEn(),
    'zh': new BuzzingStringZh(),
  };

  BuzzingStringBase? get currentLocalized {
    if (_localizedValues.containsKey(locale.languageCode)) {
      return _localizedValues[locale.languageCode];
    }
    return _localizedValues["en"];
  }

  static BuzzingLocalizations? of(BuildContext context) {
    return Localizations.of(context, BuzzingLocalizations);
  }

  static BuzzingStringBase? i18n(BuildContext context) {
    return (Localizations.of(context, BuzzingLocalizations) as BuzzingLocalizations)
        .currentLocalized;
  }
}
