import 'package:flutter/material.dart';

import 'replay_test_page.dart';
import 'room_test_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whiteboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'White Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String testPage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: testPage == null
          ? _buildPickView()
          : testPage == "room"
              ? RoomTestPage()
              : ReplayTestPage(),
    );
  }

  Widget _buildPickView() {
    return Column(
      children: [
        Expanded(flex: 1, child: Container()),
        SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              onPressed: _onPressRoom,
              child: Text("Room"),
            )),
        SizedBox(height: 40),
        SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              onPressed: _onPressReplay,
              child: Text("Replay"),
            )),
        Expanded(flex: 1, child: Container()),
      ],
    );
  }

  void _onPressRoom() => setState(() {
        testPage = "room";
      });

  void _onPressReplay() => setState(() {
        testPage = "replay";
      });
}
