import 'dart:convert';

import 'package:conduit_core/conduit_core.dart';
import 'package:qlutter_backend/qlutter_backend.dart';

class RoomsController extends ResourceController {
  // RoomsController(this.context) : super();

  // final ManagedContext context;
  Future _processConnection(WebSocket socket) async {
    await for (final message in socket) {
      //await the response for more realistic async behaviour
      await Future.delayed(const Duration(milliseconds: 5));
      socket.add('${message.hashCode}');
      if (message == 'stop') {
        break;
      }
    }
    await socket.close(WebSocketStatus.normalClosure, 'stop acknowledged');
    return Future.value();
  }

  @Operation.get()
  Future<Response?> testMethod() {
    final httpRequest = request!.raw;
    WebSocketTransformer.upgrade(httpRequest).then(_processConnection);
    return Future
        .value(); //upgrade the HTTP connection to WebSocket by returning null
  }
}

class ChatController extends ResourceController {
  static final _socket = <String, WebSocket>{};

  void handleEvent(String event, String user) {
    final json = jsonDecode(event);
    final to = json['to'] as String;
    final msg = json['msg'] as String;
    if (_socket.containsKey(to)) {
      _socket[to]!.add(msg);
    }
    if (to == "broadcast") {
      _socket.forEach((key, value) {
        _socket[key]!.add(msg);
      });
    }
    if (msg == 'bye' && _socket.containsKey(user)) {
      _socket[user]!.close(WebSocketStatus.normalClosure, 'farewell $user');
      _socket.remove(user);
    }
  }

  @Operation.get()
  Future<Response?> newChat(@Bind.query('user') String user) async {
    final httpRequest = request!.raw;
    _socket[user] = await WebSocketTransformer.upgrade(httpRequest);
    _socket[user]!.listen((event) => handleEvent(event as String, user));

    return Future
        .value(); //upgrade the HTTP connection to WebSocket by returning null
  }
}
