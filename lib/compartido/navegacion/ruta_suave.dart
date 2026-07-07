import 'package:flutter/material.dart';

Route<T> rutaSuave<T>(Widget page) {
  return MaterialPageRoute<T>(builder: (_) => page);
}
