import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_whiteboard_sdk/flutter_whiteboard_sdk.dart';

class RoomTestPage extends StatefulWidget {
  RoomTestPage({Key key}) : super(key: key);

  @override
  _RoomTestPageSate createState() => _RoomTestPageSate();
}

class _RoomTestPageSate extends State<RoomTestPage> {
  WhiteBoardSDK sdk;
  WhiteBoardRoom room;

  static const String APP_ID = '283/VGiScM9Wiw2HJg';
  static const String ROOM_UUID = "2e2762f05c5911eb894d4bad573d796b";
  static const String ROOM_TOKEN =
      "NETLESSROOM_YWs9M2R5WmdQcFlLcFlTdlQ1ZjRkOFBiNjNnY1RoZ3BDSDlwQXk3Jm5vbmNlPTE2MTEyODIzNjY1MjUwMCZyb2xlPTAmc2lnPTVhZDY1NDkwNGUyMDE5MjRkNDRiYzBhMDUxYWNkNjc0ZDdkNzY4NGNhNTQzZWQ0YTIyMzA2N2U1MDQ2NmMyNWImdXVpZD0yZTI3NjJmMDVjNTkxMWViODk0ZDRiYWQ1NzNkNzk2Yg";

  OnCanRedoStepsUpdate _onCanRedoStepsUpdate = (stepNum) {
    print('can redo step : $stepNum');
  };

  OnCanUndoStepsUpdate _onCanUndoStepsUpdate = (stepNum) {
    print('can undo step : $stepNum');
  };

  OnRoomStateChanged _onRoomStateChanged = (newState) {
    print('room state change : ${newState.toJson()}');
  };

  Future<WhiteBoardRoom> _joinRoomAgain() async {
    return await sdk.joinRoom(
        params: JoinRoomParams(ROOM_UUID, ROOM_TOKEN),
        onCanRedoStepsUpdate: _onCanRedoStepsUpdate,
        onCanUndoStepsUpdate: _onCanUndoStepsUpdate,
        onRoomStateChanged: _onRoomStateChanged);
  }

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
            var _room = await _sdk.joinRoom(
                params: JoinRoomParams(ROOM_UUID, ROOM_TOKEN),
                onCanRedoStepsUpdate: _onCanRedoStepsUpdate,
                onCanUndoStepsUpdate: _onCanUndoStepsUpdate,
                onRoomStateChanged: _onRoomStateChanged);
            _room.disableSerialization(false);

            setState(() {
              sdk = _sdk;
              room = _room;
            });
          },
        ),
        OperatingView(sdk: sdk, room: room, joinRoomAgain: _joinRoomAgain),
      ],
    );
  }
}

class OperatingView extends StatefulWidget {
  WhiteBoardSDK sdk;
  WhiteBoardRoom room;
  Function joinRoomAgain;

  OperatingView({Key key, this.sdk, this.room, this.joinRoomAgain}) : super(key: key);

  @override
  State<OperatingView> createState() {
    return OperatingViewState();
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

class OperatingViewState extends State<OperatingView> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildOperatingArea(),
      Expanded(
        flex: 1,
        child: Container(),
      ),
      _buildFilterArea(),
      Padding(padding: EdgeInsets.only(top: 16))
    ]);
  }

  Widget _buildOperatingArea() {
    return Container(
      // color: Colors.red,
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ListView.builder(
          itemCount: filterOptList.length,
          scrollDirection: Axis.horizontal,
          //列表项构造器
          itemBuilder: (BuildContext context, int index) {
            return _buildOpListItem(context, index);
          },
        ),
      ),
    );
  }

  Widget _buildFilterArea() {
    return Container(
      // color: Colors.red,
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ListView.builder(
          itemCount: categorys.length,
          scrollDirection: Axis.horizontal,
          //列表项构造器
          itemBuilder: (BuildContext context, int index) {
            return _buildCategoryListItem(context, index);
          },
        ),
      ),
    );
  }

  var allOpList = <OpListItem>[];
  var filterOptList = <OpListItem>[];
  var categorys = Category.values;

  WhiteBoardRoom get room => widget.room;

  OperatingViewState() {
    allOpList = [
      OpListItem("重连", Category.Misc, () async {
        room.disconnect().then((value) {
          Future.delayed(Duration(seconds: 3)).then((value) => widget.joinRoomAgain());
        }).catchError((o) {
          print("disconnect error");
        });
      }),
      OpListItem("清屏（保留PPT）", Category.Misc, () {
        room.cleanScene(true);
      }),
      OpListItem("主播模式", Category.Interaction, () {
        room.setViewMode(WhiteBoardViewMode.Broadcaster);
      }),
      OpListItem("自由模式", Category.Interaction, () {
        room.setViewMode(WhiteBoardViewMode.Freedom);
      }),
      OpListItem("跟随模式", Category.Interaction, () {
        room.setViewMode(WhiteBoardViewMode.Follower);
      }),
      OpListItem("获取视角状态", Category.Interaction, () async {
        var state = await room.getBroadcastState();
        showHint("ViewMode ${state.mode}");
      }),
      OpListItem("移动视角", Category.Interaction, () {
        var config = WhiteBoardCameraConfig(centerX: 100);
        room.moveCamera(config);
      }),
      OpListItem("调整视野", Category.Interaction, () {
        var config = RectangleConfig(1000, 1000, 0, 0);
        room.moveCameraToContainer(config);
      }),
      OpListItem("撤消", Category.Interaction, () {
        room.undo();
      }),
      OpListItem("重做", Category.Interaction, () {
        room.redo();
      }),
      OpListItem("副本", Category.Interaction, () {
        room.duplicate();
      }),
      OpListItem("复制", Category.Interaction, () {
        room.copy();
      }),
      OpListItem("粘贴", Category.Interaction, () {
        room.paste();
      }),
      OpListItem("铺满PPT", Category.Image, () {
        room.scalePptToFit(AnimationMode.Continuous);
      }),
      OpListItem("插入新页面", Category.Image, () async {
        var sceneState = await room.getSceneState();
        var dir = sceneState.scenePath.substring(0, sceneState.scenePath.lastIndexOf('/'));

        room.putScenes(dir, [WhiteBoardScene(name: "page1")], 0);
        room.setScenePath(dir + "/page1");
      }),
      OpListItem("插入新PPT", Category.Image, () async {
        var sceneState = await room.getSceneState();
        var dir = sceneState.scenePath.substring(0, sceneState.scenePath.lastIndexOf('/'));

        var ppt = WhiteBoardPpt(
            src:
                "https://white-pan.oss-cn-shanghai.aliyuncs.com/101/image/alin-rusu-1239275-unsplash_opt.jpg",
            width: 600,
            height: 600);
        room.putScenes(dir, [WhiteBoardScene(name: "page2", ppt: ppt)], 0);
        room.setScenePath(dir + "/page2");
      }),
      OpListItem("插入图片", Category.Image, () {
        var image = ImageInformation(centerX: 0, centerY: 0, width: 100, height: 200);
        room.insertImageByUrl(
            image, "https://white-pan.oss-cn-shanghai.aliyuncs.com/40/image/mask.jpg");
      }),
      OpListItem("获取Scene状态", Category.State, () {
        room.getSceneState().then((value) => print("getSceneState Result ${value.toJson()}"));
      }),
      OpListItem("获取Room连接状态", Category.State, () {
        room.getRoomPhase().then((value) => print("getRoomPhase reuslt ${value}"));
      }),
      OpListItem("获取Room教具状态", Category.State, () async {
        room.getMemberState().then((value) => print("member state ${value.toJson()}"));
      }),
      OpListItem("获取Room状态", Category.State, () {
        room.getRoomState().then((value) => print("room state ${value.toJson()}"));
      }),
      OpListItem("自定义状态", Category.State, () {
        room.setGlobalState(GlobalDataFoo(a: "change_aaa", b: "change_bbb", c: 321));
        room
            .getGlobalState((jsonMap) => GlobalDataFoo()..fromJson(jsonMap))
            .then((value) => print(value.toJson()));
      }),
      OpListItem("房间成员", Category.State, () {
        room
            .getRoomMembers()
            .then((value) => print("RoomMembers: ${value.map((e) => e.toJson()).join(';;;;')}"));
      }),
      OpListItem("只读切换", Category.Interaction, () {
        room.setWritable(!room.getWritable());
      }),
      OpListItem("铅笔工具", Category.Interaction, () {
        var state = WhiteBoardMemberState(currentApplianceName: ApplianceName.pencil);
        room.setMemberState(state);
      }),
      OpListItem("选取工具", Category.Interaction, () {
        var state = WhiteBoardMemberState(currentApplianceName: ApplianceName.selector);
        room.setMemberState(state);
      }),
      OpListItem("删除选中", Category.Interaction, () {
        room.delete();
      }),
      OpListItem("矩形工具", Category.Interaction, () {
        var state = WhiteBoardMemberState(currentApplianceName: ApplianceName.rectangle);
        room.setMemberState(state);
      }),
      OpListItem("移动工具", Category.Interaction, () {
        var state = WhiteBoardMemberState(currentApplianceName: ApplianceName.hand);
        room.setMemberState(state);
      }),
      OpListItem("形状工具", Category.Interaction, () {
        var state = WhiteBoardMemberState(
            currentApplianceName: ApplianceName.shape, shapeType: ShapeType.pentagram);
        room.setMemberState(state);
      }),
      OpListItem("缩放", Category.Interaction, () {}),
    ];
    filterOptList = allOpList;
  }

  int _random() {
    Random random = new Random();
    int randomNumber = random.nextInt(100); // from 0 upto 99 included
    return randomNumber;
  }

  Widget _buildOpListItem(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
          child: Text("${filterOptList[index].text}", softWrap: true),
          onPressed: filterOptList[index].handler),
    );
  }

  Widget _buildCategoryListItem(BuildContext context, int index) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
            child: Text(_getFilterDisplay(categorys[index]), softWrap: true),
            onPressed: () {
              setState(() {
                if (categorys[index] == Category.All)
                  filterOptList = allOpList;
                else
                  filterOptList =
                      allOpList.where((item) => item.category == categorys[index]).toList();
              });
            }));
  }

  void showHint(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String _getFilterDisplay(Category category) {
    switch (category) {
      case Category.All:
        return "全部";
      case Category.Image:
        return "图片及PPT";
      case Category.Interaction:
        return "交互操作";
      case Category.State:
        return "状态信息";
      case Category.Misc:
        return "其它";
      default:
        return "Unknown";
    }
  }
}

class GlobalDataFoo implements WhiteBoardGlobalState {
  String a = "aaaa";
  String b = "bbb";
  int c = 123;

  GlobalDataFoo({this.a, this.b, this.c});

  @override
  void fromJson(Map<String, dynamic> json) {
    a = json["a"];
    b = json["b"];
    c = json["c"];
  }

  @override
  Map<String, dynamic> toJson() => {
        "a": a,
        "b": b,
        "c": c,
      };
}
