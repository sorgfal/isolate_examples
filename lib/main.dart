import 'package:flutter/material.dart';
import 'package:isolate_examples/app/app.dart';
import 'package:isolate_examples/app/isolated_json_decoder.dart';

void main() async {
  await IsolatedJsonDecoder.instance.init();
  runApp(const App());
}
