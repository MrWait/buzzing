import 'dart:io';

import 'package:flutter/foundation.dart';

bool get isDesktop =>
    !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

bool get isMobile =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);

bool get isApple => Platform.isMacOS || Platform.isIOS;
