import 'package:flutter/services.dart';

class SpeechService {
  static const _channel = MethodChannel('id.dailytrack.fresh/speech');

  static Future<bool> isAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAvailable');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<String> startListening() async {
    try {
      final result = await _channel.invokeMethod<String>('startListening');
      return result ?? '';
    } on PlatformException catch (e) {
      if (e.code == 'NOT_AVAILABLE') return '';
      return '';
    } catch (_) {
      return '';
    }
  }
}
