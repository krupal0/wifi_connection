import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Socket Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _localIp = '';
  String _message = '';
  final TextEditingController _controller = TextEditingController();
  late ServerSocket _serverSocket;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.wifi) {
        final info = NetworkInfo();
        final wifiIp = await info.getWifiIP();
        print('wifi ip : ${wifiIp}');
        if (wifiIp != null && wifiIp.isNotEmpty) {
          setState(() {
            _localIp = wifiIp;
          });
        } else {
          setState(() {
            _message = 'Error: Unable to get local IP address';
          });
        }
      } else {
        setState(() {
          _message = 'Error: WiFi is not connected';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    }
  }

  void _startServer() async {
    try {
      _serverSocket = await ServerSocket.bind(_localIp, 4000, shared: true);
      _serverSocket.listen((Socket socket) {
        socket.listen(
              (List<int> data) {
            setState(() {
              _message = 'Received from client: ${String.fromCharCodes(data)}';
            });
          },
          onError: (error) {
            print('Socket listen error: $error');
          },
          onDone: () {
            print('Client disconnected');
          },
        );
      });
      setState(() {
        _message = 'Server started';
      });
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    }
  }

  WebSocket? serverSocket;
  Future<void> startServer() async {
    try {
      var server = await HttpServer.bind(InternetAddress.anyIPv4, 4000);
      setState(() {
        _message = 'Server started';
      });

      server.listen((HttpRequest request) async {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          serverSocket =
          await WebSocketTransformer.upgrade(request);
          setState(() {
            _message = 'Client connected';
          });
          serverSocket?.listen((message) {
            setState(() {
              _message = 'Received: $message';
            });
          }, onError: (error) {
            setState(() {
              _message = 'WebSocket error: $error';
            });
          }, onDone: () {
            setState(() {
              _message = 'Client disconnected';
            });
          });
        }
      });
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
      print('Error: $e');
    }
  }

  WebSocket? clientSocket;

  Future<void> listener() async {
    try {
      clientSocket = await WebSocket.connect('ws://localhost:4000');
      setState(() {
        _message = 'Connected to server';
      });

      clientSocket?.listen((message) {
        setState(() {
          _message = 'Received: $message';
        });
        // Handle game updates
      }, onError: (error) {
        setState(() {
          _message = _message = 'WebSocket error: $error';
        });
      }, onDone: () {
        setState(() {
          _message = 'Server disconnected';
        });
      });

      // Send messages to server
      // clientSocket?.add('Hello from client');
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    }
  }

  void _stopServer() {
    _serverSocket?.close();
    setState(() {
      _message = 'Server stopped';
    });
  }

  void _sendMessage() async {
    try {
      serverSocket !=null ?
      serverSocket?.add(_controller.text) :
      clientSocket?.add(_controller.text);
      // var socket = await Socket.connect(_localIp, 4000);
      // socket.write(_controller.text);
      // socket.close();
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Socket Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Local IP: $_localIp'),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: startServer,
              child: Text('Start Server'),
            ),
            ElevatedButton(
              onPressed: listener,
              child: Text('Listen Server'),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: _stopServer,
              child: Text('Stop Server'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Message to send',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _sendMessage,
              child: Text('Send Message'),
            ),
            SizedBox(height: 16.0),
            Text('$_message'),
          ],
        ),
      ),
    );
  }
}
