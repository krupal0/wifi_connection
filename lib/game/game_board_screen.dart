import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wifi_connection/game/number_text_field.dart';

class GameDashboardScreen extends StatefulWidget {
  const GameDashboardScreen({super.key});

  @override
  State<GameDashboardScreen> createState() => _GameDashboardScreenState();
}

class _GameDashboardScreenState extends State<GameDashboardScreen> {
  var lock = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: min(size.width - 100, size.height - 100),
              height: min(size.width - 100, size.height - 100),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, // Spacing between each column
                ),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 25, // Number of items
                itemBuilder: (BuildContext context, int index) {
                  return Center(
                      child: NumberTextField(
                    controller: TextEditingController(),
                        enable: !lock,
                  ));
                },
              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton(onPressed: () {
              setState(() {
                lock  = true;
              });
            }, child: Text('Lock')),
          ],
        ),
      ),
    );
  }
}
