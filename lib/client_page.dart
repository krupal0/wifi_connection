import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:wifi_connection/client_class.dart';

class ClientPage extends StatefulWidget {
  @override
  _ClientPageState createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  late Client client;
  List<String> serverLogs = [];
  TextEditingController controller = TextEditingController();
  bool loading = false;

  initState() {
    super.initState();
    findHotspot();
    client = Client(
      hostname: "192.168.43.1",
      port: 4040,
      onData: this.onData,
      onError: this.onError,
      onDisconnect: ()=>
        setState(() {
          loading = false;
        },),
    );
  }

  Future<void> findHotspot() async {
    final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4, includeLinkLocal: true);
    setState(() {
      serverLogs.add('finding a device');
    });

    try {
      NetworkInterface vpnInterface = interfaces.firstWhere((element) => element.name == "tun0");
      serverLogs.add( vpnInterface.addresses.first.address);
    } on StateError {
      try {
        NetworkInterface interface = interfaces.firstWhere((element) => element.name == "wlan0");
        serverLogs.add( interface.addresses.first.address);
      } catch (ex) {
        try {
          NetworkInterface interface = interfaces.firstWhere((element) => !(element.name == "tun0" || element.name == "wlan0"));
          serverLogs.add( interface.addresses.first.address);
        } catch (ex) {
            serverLogs.add(ex.toString());
        }
      }
    }
    setState(() {

    });
  }

  onData(Uint8List data) {
    DateTime time = DateTime.now();
    serverLogs.add(time.hour.toString() + "h" + time.minute.toString() + " : " + String.fromCharCodes(data));
    setState(() {
     loading = false;
    });
  }

  onError(dynamic error) {
    print(error);
    setState(() {
      loading = false;
    });
  }

  dispose() {
    controller.dispose();
    client.disconnect();
    setState(() {
      loading = false;
    });
    super.dispose();
  }

  confirmReturn() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("ATTENTION"),
          content: Text("Quitter cette page déconnectera le client du serveur de socket"),
          actions: <Widget>[
            ElevatedButton(
              child: Text("Quitter", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),ElevatedButton(
              child: Text("Annuler", style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Server'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: confirmReturn,
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Client",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: client.connected ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                        ),
                        padding: EdgeInsets.all(5),
                        child: Text(
                          client.connected ? 'CONNECTÉ' : 'DÉCONNECTÉ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                    child: Text(!client.connected ? 'Connecter le client' : 'Déconnecter le client'),
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      if (client.connected ) {
                        await client.disconnect();
                        this.serverLogs.clear();
                      } else {
                        await client.connect();
                      }
                    },
                  ),
                  if(loading)
                    const CircularProgressIndicator(),
                  Divider(
                    height: 30,
                    thickness: 1,
                    color: Colors.black12,
                  ),
                  Expanded(
                    flex: 1,
                    child: ListView(
                      children: serverLogs.map((String log) {
                        return Padding(
                          padding: EdgeInsets.only(top: 15),
                          child: Text(log),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.grey,
            height: 80,
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Message à envoyer :',
                        style: TextStyle(
                          fontSize: 8,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: controller,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                MaterialButton(
                  onPressed: () {
                    controller.text = "";
                  },
                  minWidth: 30,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Icon(Icons.clear),
                ),
                SizedBox(width: 15,),
                MaterialButton(
                  onPressed: () {
                    client.write(controller.text);
                    controller.text = "";
                  },
                  minWidth: 30,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Icon(Icons.send),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}