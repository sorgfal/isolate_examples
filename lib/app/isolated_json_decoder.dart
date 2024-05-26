import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

typedef ParsedJson = Map<String, Object?>;

class IsolatedJsonDecoder extends IsolatedJsonDecoderImplementation {
  static final IsolatedJsonDecoder instance = IsolatedJsonDecoder._internal();

  factory IsolatedJsonDecoder() {
    return instance;
  }

  IsolatedJsonDecoder._internal();

  Future<ParsedJson> parseJson(String json) async {
    return _registerTask(json);
  }

  Future<void> init() async {
    await _maybeInitIsolate();
  }
}

void _jsonDecodeWorker(SendPort port) {
  final ReceivePort taskPort = ReceivePort();

  port.send(taskPort.sendPort);

  taskPort.listen((message) {
    if (message is DecodeJsonTask) {
      final result = jsonDecode(message.text);
      port.send(DecodeJsonResult(result: result, id: message.id));
    }
  });
}

class DecodeJsonTask {
  final String text;
  final int id;

  DecodeJsonTask({required this.text, required this.id});
}

class DecodeJsonResult {
  final ParsedJson result;
  final int id;

  DecodeJsonResult({required this.result, required this.id});
}

class IsolatedJsonDecoderImplementation {
  Map<int, Completer<ParsedJson>> _tasks = {};

  int _counter = 0;

  Future<ParsedJson> _registerTask(String text) async {
    final counter = _counter++;

    _tasks[counter] = Completer<ParsedJson>();

    _taskPort!.send(DecodeJsonTask(id: counter, text: text));

    return _tasks[counter]!.future;
  }

  void _resolveTask(int id, ParsedJson data) {
    _tasks[id]?.complete(data);
    _tasks.remove(id);
  }

  Isolate? _isolate;
  ReceivePort? _controlPort;
  SendPort? _taskPort;

  Future<void> _maybeInitIsolate() async {
    if (_isolate != null) return;

    _controlPort = ReceivePort();
    _isolate = await Isolate.spawn(_jsonDecodeWorker, _controlPort!.sendPort);
    Completer<SendPort> completer = Completer<SendPort>();

    _controlPort!.listen((message) {
      switch (message) {
        case SendPort port:
          completer.complete(port);
        case DecodeJsonResult result:
          _resolveTask(result.id, result.result);
      }
    });
    _taskPort = await completer.future;
  }
}
