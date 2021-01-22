import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_whiteboard_sdk/flutter_whiteboard_sdk.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter WhiteBoard SDK Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  WhiteBoardSDK sdk;
  List<WhiteBoardScene> scenes;

  static const String APP_ID = '283/VGiScM9Wiw2HJg';
  static const String ROOM_UUID = "2e2762f05c5911eb894d4bad573d796b";
  static const String ROOM_TOKEN = "NETLESSROOM_YWs9M2R5WmdQcFlLcFlTdlQ1ZjRkOFBiNjNnY1RoZ3BDSDlwQXk3Jm5vbmNlPTE2MTEyODIzNjY1MjUwMCZyb2xlPTAmc2lnPTVhZDY1NDkwNGUyMDE5MjRkNDRiYzBhMDUxYWNkNjc0ZDdkNzY4NGNhNTQzZWQ0YTIyMzA2N2U1MDQ2NmMyNWImdXVpZD0yZTI3NjJmMDVjNTkxMWViODk0ZDRiYWQ1NzNkNzk2Yg";

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: WhiteBoardWithInApp(
          appId: APP_ID,
          log: true,
          backgroundColor: Color(0xFFF9F4E7),
          assetFilePath: "assets/whiteboardBridge/index.html",
          onCreated: (_sdk) async {
            sdk = _sdk;
            sdk.joinRoom(JoinRoomParams(ROOM_UUID, ROOM_TOKEN));
          },
        ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
