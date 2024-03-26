import 'dart:async';
import 'dart:io';

import 'dart:typed_data';

import 'model.dart';


class Server {

  Server({required this.onError, required this.onData});

  final Uint8ListCallback onData;
  final DynamicCallback onError;
  ServerSocket? server;
  bool running = false;
  List<Socket> sockets = [];

  start() async {
    runZoned(() async {
      server = await ServerSocket.bind('0.0.0.0', 4040);
      this.running = true;
      server?.listen(onRequest);
      this.onData(Uint8List.fromList('Server listening on port 4040'.codeUnits));
    }, onError: (e) {
      this.onError(e);
    });
  }

  stop() async {
    await this.server?.close();
    this.server = null;
    this.running = false;
  }

  broadCast(String message) {
    this.onData(Uint8List.fromList('Broadcasting : $message'.codeUnits));
    for (Socket socket in sockets) {
      socket.write( message + '\n' );
    }
  }


  onRequest(Socket socket) {
    if (!sockets.contains(socket)) {
      sockets.add(socket);
    }
    socket.listen((Uint8List data) {
      this.onData(data);
    });
  }
}