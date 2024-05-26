import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isolate_examples/app/isolated_json_decoder.dart';
import 'package:isolate_examples/app/json.dart';

class App extends StatelessWidget {
  const App({super.key});

  Future<void> parseWithLongLive() async {
    final start = DateTime.now();
    List data = [];
    for (final j in jsonItems) {
      data.add(await IsolatedJsonDecoder.instance.parseJson(j));
    }
    print(DateTime.now().difference(start));
  }

  Future<void> parseWithCompute() async {
    final start = DateTime.now();
    List data = [];
    for (final j in jsonItems) {
      data.add(await compute(jsonDecode, j));
    }
    print(DateTime.now().difference(start));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                child: Text('Запустить long time isolate'),
                onPressed: parseWithLongLive,
              ),
              ElevatedButton(
                child: Text('Запустить compute'),
                onPressed: parseWithCompute,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
