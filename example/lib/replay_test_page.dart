import 'package:flutter/material.dart';
import 'package:whiteboard_sdk_flutter/whiteboard_sdk_flutter.dart';

class ReplayTestPage extends StatefulWidget {
  ReplayTestPage({Key key}) : super(key: key);

  @override
  _ReplayTestPageSate createState() => _ReplayTestPageSate();
}

class _ReplayTestPageSate extends State<ReplayTestPage> {
  WhiteSdk sdk;
  WhiteReplay replay;

  static const String APP_ID = '283/VGiScM9Wiw2HJg';
  static const String ROOM_UUID = "d4184790ffd511ebb9ebbf7a8f1d77bd";
  static const String ROOM_TOKEN =
      "NETLESSROOM_YWs9eTBJOWsxeC1IVVo4VGh0NyZub25jZT0xNjI5MjU3OTQyNTM2MDAmcm9sZT0wJnNpZz1lZDdjOGJiY2M4YzVjZjQ5NDU5NmIzZGJiYzQzNDczNDJmN2NjYTAxMThlMTMyOWVlZGRmMjljNjE1NzQ5ZWFkJnV1aWQ9ZDQxODQ3OTBmZmQ1MTFlYmI5ZWJiZjdhOGYxZDc3YmQ";

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WhiteboardView(
          onSdkCreated: (whiteSdk) async {
            var replay = await whiteSdk.joinReplay(
              options: ReplayOptions(room: ROOM_UUID, roomToken: ROOM_TOKEN),
              onPlayerStateChanged: _onPlayerStateChanged,
              onPlayerPhaseChanged: _onPlayerPhaseChanged,
              onScheduleTimeChanged: _onScheduleTimeChanged,
            );

            setState(() {
              sdk = whiteSdk;
              replay = replay;
            });
          },
          options: WhiteOptions(
            appIdentifier: APP_ID,
            log: true,
            backgroundColor: Color(0xFFF9F4E7),
          ),
        ),
        Column(children: [
          _buildOperatingArea(),
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Padding(padding: EdgeInsets.only(top: 16))
        ]),
      ],
    );
  }

  /// Callback
  void _onScheduleTimeChanged(int scheduleTime) {
    print("_onScheduleTimeChanged $scheduleTime");
  }

  void _onPlayerStateChanged(ReplayState state) {
    print("_onScheduleTimeChanged ${state.toJson()}");
  }

  void _onPlayerPhaseChanged(String phase) {
    print("_onPlayerPhaseChanged $phase");
  }

  var allOpList = <OpListItem>[];

  _ReplayTestPageSate() {
    allOpList = [
      OpListItem("开始", Category.All, () async {
        replay.play();
      }),
      OpListItem("暂停）", Category.All, () {
        replay.pause();
      }),
      OpListItem("停止）", Category.All, () {
        replay.stop();
      }),
      OpListItem("播放速度设置", Category.All, () {
        replay.setPlaybackSpeed(2.0);
        replay.playbackSpeed.then((value) => print("playbackSpeed $value"));
      }),
    ];
  }

  Widget _buildOperatingArea() {
    return Container(
      // color: Colors.red,
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ListView.builder(
          itemCount: allOpList.length,
          scrollDirection: Axis.horizontal,
          //列表项构造器
          itemBuilder: (BuildContext context, int index) {
            return _buildOpListItem(context, index);
          },
        ),
      ),
    );
  }

  Widget _buildOpListItem(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
          child: Text("${allOpList[index].text}", softWrap: true),
          onPressed: allOpList[index].handler),
    );
  }

  void showHint(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

typedef void Handler();

class OpListItem {
  String text;
  Category category;
  Handler handler;

  OpListItem(this.text, this.category, this.handler);
}

enum Category {
  /// 全部
  All,

  /// PPT及图片类
  Image,

  /// 状态类
  State,

  /// 交互类
  Interaction,

  /// 其它
  Misc,
}
