import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:whiteboard_sdk_flutter/whiteboard_sdk_flutter.dart';

import 'white_example_page.dart';

class WindowTestPage extends WhiteExamplePage {
  WindowTestPage({Key? key}) : super('Window');

  @override
  Widget build(BuildContext context) {
    return WindowTestBody();
  }
}

class WindowTestBody extends StatefulWidget {
  @override
  WindowTestBodySate createState() => WindowTestBodySate();
}

class WindowTestBodySate extends State<WindowTestBody> {
  WhiteSdk? whiteSdk;
  WhiteRoom? whiteRoom;

  static const String APP_ID = '283/VGiScM9Wiw2HJg';
  static const String ROOM_UUID = "d4184790ffd511ebb9ebbf7a8f1d77bd";
  static const String ROOM_TOKEN =
      "NETLESSROOM_YWs9eTBJOWsxeC1IVVo4VGh0NyZub25jZT0xNjI5MjU3OTQyNTM2MDAmcm9sZT0wJnNpZz1lZDdjOGJiY2M4YzVjZjQ5NDU5NmIzZGJiYzQzNDczNDJmN2NjYTAxMThlMTMyOWVlZGRmMjljNjE1NzQ5ZWFkJnV1aWQ9ZDQxODQ3OTBmZmQ1MTFlYmI5ZWJiZjdhOGYxZDc3YmQ";
  static const String UNIQUE_CLIENT_ID = "123456";

  RedoStepsUpdatedCallback _onCanRedoStepsUpdate = (stepNum) {
    print('can redo step : $stepNum');
  };

  UndoStepsUpdatedCallback _onCanUndoStepsUpdate = (stepNum) {
    print('can undo step : $stepNum');
  };

  RoomStateChangedCallback _onRoomStateChanged = (newState) {
    print('room state change : ${newState.toJson()}');
  };

  Future<WhiteRoom> _joinRoomAgain() async {
    return await whiteSdk!.joinRoom(
        options: RoomOptions(
            uuid: ROOM_UUID,
            roomToken: ROOM_TOKEN,
            uid: UNIQUE_CLIENT_ID,
            isWritable: true,
            windowParams: WindowParams(
              containerSizeRatio: 1.5,
            )),
        onCanRedoStepsUpdate: _onCanRedoStepsUpdate,
        onCanUndoStepsUpdate: _onCanUndoStepsUpdate,
        onRoomStateChanged: _onRoomStateChanged);
  }

  @override
  void initState() {
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WhiteboardView(
          options: WhiteOptions(
            appIdentifier: APP_ID,
            useMultiViews: true,
            log: true,
          ),
          onSdkCreated: _onSdkCreated,
          useBasicWebView: true,
        ),
        Container(
          child: whiteRoom != null
              ? OperatingView(
                  room: whiteRoom!,
                  onReconnect: _joinRoomAgain,
                )
              : Center(
                  child: CircularProgressIndicator(
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(Colors.blue),
                )),
        )
      ],
    );
  }

  void _onSdkCreated(WhiteSdk sdk) async {
    var room = await sdk.joinRoom(
      options: RoomOptions(
        uuid: ROOM_UUID,
        roomToken: ROOM_TOKEN,
        uid: UNIQUE_CLIENT_ID,
        isWritable: true,
        windowParams: WindowParams(
          containerSizeRatio: 9 / 16,
        ),
      ),
    );
    room.disableSerialization(false);

    setState(() {
      print("whiteboard setState ");
      whiteSdk = sdk;
      whiteRoom = room;
    });
  }
}

class OperatingView extends StatefulWidget {
  final WhiteRoom room;
  final VoidCallback? onReconnect;

  OperatingView({
    Key? key,
    required this.room,
    this.onReconnect,
  }) : super(key: key);

  @override
  State<OperatingView> createState() {
    return OperatingViewState();
  }
}

typedef Handler = void Function();

class OpListItem {
  String text;
  Category category;
  Handler handler;

  OpListItem(this.text, this.category, this.handler);
}

enum Category {
  /// 教具类
  Appliance,

  /// PPT及图片类
  Image,

  /// 状态类
  State,

  /// 交互类
  Interaction,

  /// 其它
  Misc,

  /// 全部
  All,
}

class OperatingViewState extends State<OperatingView> {
  @override
  Widget build(BuildContext context) {
    return _buildOperatingArea();
  }

  Widget _buildOperatingArea() {
    return Container(
      // color: Colors.cyan,
      child: SizedBox(
        width: 200,
        child: ListView.builder(
          itemCount: filterOptList.length,
          scrollDirection: Axis.vertical,
          //列表项构造器
          itemBuilder: (BuildContext context, int index) {
            return _buildOpListItem(context, index);
          },
        ),
      ),
    );
  }

  var allOpList = <OpListItem>[];
  var filterOptList = <OpListItem>[];
  var categories = Category.values;
  var index = 0;
  List<double> ratios = [16 / 9, 1 / 1, 9 / 16];
  List<WindowPrefersColorScheme> colorSchemes = [
    WindowPrefersColorScheme.dark,
    WindowPrefersColorScheme.light,
  ];

  WhiteRoom get room => widget.room;

  OperatingViewState() {
    allOpList = [
      OpListItem("CleanScene", Category.Appliance, () {
        room.cleanScene(true);
      }),
      OpListItem("StaticDoc", Category.Misc, () {
        var testDocJson =
            '[{\"name\":\"1\",\"ppt\":{\"height\":1010.0,\"src\":\"https://convertcdn.netless.link/staticConvert/0764816000c411ecbfbbb9230f6dd80f/1.png\",\"width\":714.0}},{\"name\":\"2\",\"ppt\":{\"height\":1010.0,\"src\":\"https://convertcdn.netless.link/staticConvert/0764816000c411ecbfbbb9230f6dd80f/2.png\",\"width\":714.0}},{\"name\":\"3\",\"ppt\":{\"height\":1010.0,\"src\":\"https://convertcdn.netless.link/staticConvert/0764816000c411ecbfbbb9230f6dd80f/3.png\",\"width\":714.0}},{\"name\":\"4\",\"ppt\":{\"height\":1010.0,\"src\":\"https://convertcdn.netless.link/staticConvert/0764816000c411ecbfbbb9230f6dd80f/4.png\",\"width\":714.0}}]';
        var scenes = (jsonDecode(testDocJson) as List)
            .map((e) => Scene.fromJson(e))
            .toList();
        var appParams =
            WindowAppParams.docsViewerApp("/static", scenes, "test static");
        room.addApp(appParams);
      }),
      OpListItem("DynamicDoc", Category.Misc, () {
        var testSlideJson =
            '[{\"name\":\"1\",\"ppt\":{\"src\":\"pptx://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/1.slide\",\"width\":1280,\"height\":720,\"previewURL\":\"https://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/preview/1.png\"}},{\"name\":\"2\",\"ppt\":{\"src\":\"pptx://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/2.slide\",\"width\":1280,\"height\":720,\"previewURL\":\"https://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/preview/2.png\"}},{\"name\":\"3\",\"ppt\":{\"src\":\"pptx://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/3.slide\",\"width\":1280,\"height\":720,\"previewURL\":\"https://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/preview/3.png\"}},{\"name\":\"4\",\"ppt\":{\"src\":\"pptx://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/4.slide\",\"width\":1280,\"height\":720,\"previewURL\":\"https://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/preview/4.png\"}},{\"name\":\"5\",\"ppt\":{\"src\":\"pptx://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/5.slide\",\"width\":1280,\"height\":720,\"previewURL\":\"https://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/preview/5.png\"}},{\"name\":\"6\",\"ppt\":{\"src\":\"pptx://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/6.slide\",\"width\":1280,\"height\":720,\"previewURL\":\"https://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/preview/6.png\"}},{\"name\":\"7\",\"ppt\":{\"src\":\"pptx://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/7.slide\",\"width\":1280,\"height\":720,\"previewURL\":\"https://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/preview/7.png\"}},{\"name\":\"8\",\"ppt\":{\"src\":\"pptx://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/8.slide\",\"width\":1280,\"height\":720,\"previewURL\":\"https://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/preview/8.png\"}},{\"name\":\"9\",\"ppt\":{\"src\":\"pptx://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/9.slide\",\"width\":1280,\"height\":720,\"previewURL\":\"https://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/preview/9.png\"}},{\"name\":\"10\",\"ppt\":{\"src\":\"pptx://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/10.slide\",\"width\":1280,\"height\":720,\"previewURL\":\"https://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/preview/10.png\"}},{\"name\":\"11\",\"ppt\":{\"src\":\"pptx://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/11.slide\",\"width\":1280,\"height\":720,\"previewURL\":\"https://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/preview/11.png\"}},{\"name\":\"12\",\"ppt\":{\"src\":\"pptx://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/12.slide\",\"width\":1280,\"height\":720,\"previewURL\":\"https://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/preview/12.png\"}},{\"name\":\"13\",\"ppt\":{\"src\":\"pptx://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/13.slide\",\"width\":1280,\"height\":720,\"previewURL\":\"https://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/preview/13.png\"}},{\"name\":\"14\",\"ppt\":{\"src\":\"pptx://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/14.slide\",\"width\":1280,\"height\":720,\"previewURL\":\"https://convertcdn.netless.link/dynamicConvert/369ac28037d011ec99f08bddeae74404/preview/14.png\"}}]';
        var scenes = (jsonDecode(testSlideJson) as List)
            .map((e) => Scene.fromJson(e))
            .toList();
        var appParams = WindowAppParams.docsViewerApp(
          "/dynamic",
          scenes,
          "test dynamic",
        );
        room.addApp(appParams);
      }),
      OpListItem("Video", Category.Misc, () {
        var appParams = WindowAppParams.mediaPlayerApp(
          "https://white-pan.oss-cn-shanghai.aliyuncs.com/101/oceans.mp4",
          "test player",
        );
        room.addApp(appParams);
      }),
      OpListItem("ColorScheme", Category.Misc, () {
        room.setPrefersColorScheme(colorSchemes[index++ % colorSchemes.length]);
      }),
      OpListItem("ContainerSizeRatio", Category.Misc, () {
        room.setContainerSizeRatio(ratios[index++ % ratios.length]);
      }),
      OpListItem("Reconnect", Category.Misc, () async {
        room.disconnect().then((value) {
          Future.delayed(
            Duration(seconds: 2),
            () => widget.onReconnect?.call(),
          );
        }).catchError((o) {
          print("disconnect error");
        });
      }),
    ];
    filterOptList = allOpList;
  }

  Widget _buildOpListItem(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
          child: Text("${filterOptList[index].text}", softWrap: true),
          onPressed: filterOptList[index].handler),
    );
  }

  void showHint(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
