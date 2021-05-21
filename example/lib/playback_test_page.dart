import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:whiteboard_sdk_flutter/whiteboard_sdk_flutter.dart';

class PlaybackTestPage extends StatefulWidget {
  PlaybackTestPage({Key key}) : super(key: key);

  @override
  _PlaybackTestPageSate createState() => _PlaybackTestPageSate();
}

class _PlaybackTestPageSate extends State<PlaybackTestPage> {
  WhiteBoardSDK sdk;
  WhiteBoardPlayer player;

  static const String APP_ID = '283/VGiScM9Wiw2HJg';
  static const String ROOM_UUID = "2e2762f05c5911eb894d4bad573d796b";
  static const String ROOM_TOKEN =
      "NETLESSROOM_YWs9M2R5WmdQcFlLcFlTdlQ1ZjRkOFBiNjNnY1RoZ3BDSDlwQXk3Jm5vbmNlPTE2MTEyODIzNjY1MjUwMCZyb2xlPTAmc2lnPTVhZDY1NDkwNGUyMDE5MjRkNDRiYzBhMDUxYWNkNjc0ZDdkNzY4NGNhNTQzZWQ0YTIyMzA2N2U1MDQ2NmMyNWImdXVpZD0yZTI3NjJmMDVjNTkxMWViODk0ZDRiYWQ1NzNkNzk2Yg";

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WhiteBoardWithInApp(
          appId: APP_ID,
          log: true,
          backgroundColor: Color(0xFFF9F4E7),
          assetFilePath: "assets/whiteboardBridge/index.html",
          onCreated: (_sdk) async {
            var _player = await _sdk.replayRoom(
                ReplayRoomParams(room: ROOM_UUID, roomToken: ROOM_TOKEN),
                onPlayerStateChanged: _onPlayerStateChanged,
                onPlayerPhaseChanged: _onPlayerPhaseChanged,
                onScheduleTimeChanged: _onScheduleTimeChanged);

            setState(() {
              sdk = _sdk;
              player = _player;
            });
          },
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

  void _onPlayerStateChanged(WhiteBoardPlayerState state) {
    print("_onScheduleTimeChanged ${state.toJson()}");
  }

  void _onPlayerPhaseChanged(String phase) {
    print("_onPlayerPhaseChanged $phase");
  }

  var allOpList = <OpListItem>[];

  _PlaybackTestPageSate() {
    allOpList = [
      OpListItem("开始", Category.All, () async {
        player.play();
      }),
      OpListItem("暂停）", Category.All, () {
        player.pause();
      }),
      OpListItem("停止）", Category.All, () {
        player.stop();
      }),
      OpListItem("播放速度设置", Category.All, () {
        player.setPlaybackSpeed(2.0);
        player.playbackSpeed.then((value) => print("playbackSpeed $value"));
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
