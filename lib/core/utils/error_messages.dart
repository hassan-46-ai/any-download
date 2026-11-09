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
    return error.message ?? 'Could not save the file.';
  }
  return error.toString().replaceFirst('Exception: ', '');
}
