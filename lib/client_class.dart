
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'model.dart';


class Client {
  Client({
    required this.onError,
    required this.onData,
    required this.hostname,
    required this.port,
    required this.onDisconnect
  });

  String hostname;
  int port;
  Uint8ListCallback onData;
  DynamicCallback onError;
  VoidCallback onDisconnect;
  bool connected = false;

  Socket? socket;

  connect() async {
    try {
      socket = await Socket.connect(hostname, 4040);
      socket?.listen(
        onData,
        onError: onError,
        onDone: disconnect,
        cancelOnError: false,
      );
      connected = true;
    } on Exception catch (exception) {
      onData(Uint8List.fromList("Error : $exception".codeUnits));
    }
  }

  write(String message) {
    //Connect standard in to the socket
    socket?.write(message + '\n');
  }

  disconnect() {
    if (socket != null) {
      socket!.destroy();
      connected = false;
      onDisconnect();
    }
  }
}
