import 'package:flutter/material.dart';
import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/utils/env/env_config.dart';
import 'package:buzzing/utils/logger_util.dart';

class ConfigWrapper extends StatelessWidget {
  ConfigWrapper({Key? key, this.config, this.child});

  @override
  Widget build(BuildContext context) {
    Config.DEBUG = this.config?.debug;
    L.d("ConfigWrapper build ${Config.DEBUG}");
    return new _InheritedConfig(config: this.config, child: this.child!);
  }

  static EnvConfig? of(BuildContext context) {
    final _InheritedConfig inheritedConfig =
        context.dependOnInheritedWidgetOfExactType<_InheritedConfig>()!;
    return inheritedConfig.config;
  }

  final EnvConfig? config;
  final Widget? child;
}

class _InheritedConfig extends InheritedWidget {
  const _InheritedConfig({required this.config, required super.child});
  final EnvConfig? config;

  @override
  bool updateShouldNotify(_InheritedConfig oldWidget) =>
      config != oldWidget.config;
}
