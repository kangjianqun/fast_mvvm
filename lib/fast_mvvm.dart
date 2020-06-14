import 'dart:async';
import 'package:flutter/services.dart';

export 'src/base.dart';
export 'src/common.dart';
export 'src/widget.dart';

class FastMvvm {
  static const MethodChannel _channel = const MethodChannel('fast_mvvm');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
