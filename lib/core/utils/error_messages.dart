import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// Turns any thrown object into a short message that is safe to show a user.
String describeError(Object error) {
  if (error is SocketException || error is HttpException) {
    return 'Network error. Please check your internet connection.';
  }
  if (error is TimeoutException) {
    return 'The request timed out. Please try again.';
  }
  if (error is PlatformException) {
    return _describeEngineError(error.message ?? '');
  }
  return error.toString().replaceFirst('Exception: ', '');
}

String _describeEngineError(String raw) {
  final text = raw.toLowerCase();
  if (text.contains('unsupported url')) {
    return "This link isn't supported. Open the video itself and copy its link.";
  }
  if (text.contains('login') ||
      text.contains('sign in') ||
      text.contains('cookies') ||
      text.contains('private') ||
      text.contains('age')) {
    return 'This video is private, age-restricted or needs a login, so it '
        "can't be downloaded.";
  }
  if (text.contains('403') ||
      text.contains('429') ||
      text.contains('unable to extract') ||
      text.contains('sign in to confirm')) {
    return 'The site blocked the request. Tap the update icon on the '
        'Download tab to update the engine, then try again.';
  }
  if (text.contains('unable to download') || text.contains('urlopen')) {
    return 'Network error. Please check your internet connection.';
  }
  if (raw.isEmpty) return 'Something went wrong. Please try again.';
  return raw.length > 220 ? '${raw.substring(0, 220)}…' : raw;
}
