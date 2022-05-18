import 'package:flutter/material.dart';
import 'package:whiteboard_sdk_flutter_example/white_example_page.dart';
import 'package:whiteboard_sdk_flutter_example/window_test_page.dart';

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
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _pushPage(context, allPages[0]),
                  child: Text("Room"),
                )),
            SizedBox(height: 40),
            SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _pushPage(context, allPages[1]),
                  child: Text("Replay"),
                )),
            SizedBox(height: 40),
            SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _pushPage(context, allPages[2]),
                  child: Text("Window"),
                )),
          ],
        ),
      ),
    );
  }

  void _pushPage(BuildContext context, WhiteExamplePage page) {
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => Scaffold(
              appBar: AppBar(title: Text(page.title)),
              body: page,
            )));
  }
}

final List<WhiteExamplePage> allPages = <WhiteExamplePage>[
  RoomTestPage(),
  ReplayTestPage(),
  WindowTestPage(),
];
