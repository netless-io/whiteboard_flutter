import 'dart:math';

import 'package:flutter/material.dart';
import 'package:whiteboard_sdk_flutter/whiteboard_sdk_flutter.dart';

class RoomTestPage extends StatefulWidget {
  RoomTestPage({Key key}) : super(key: key);

  @override
  _RoomTestPageSate createState() => _RoomTestPageSate();
}

class _RoomTestPageSate extends State<RoomTestPage> {
  WhiteSdk sdk;
  WhiteRoom room;

  static const String APP_ID = '283/VGiScM9Wiw2HJg';
  static const String ROOM_UUID = "d4184790ffd511ebb9ebbf7a8f1d77bd";
  static const String ROOM_TOKEN =
      "NETLESSROOM_YWs9eTBJOWsxeC1IVVo4VGh0NyZub25jZT0xNjI5MjU3OTQyNTM2MDAmcm9sZT0wJnNpZz1lZDdjOGJiY2M4YzVjZjQ5NDU5NmIzZGJiYzQzNDczNDJmN2NjYTAxMThlMTMyOWVlZGRmMjljNjE1NzQ5ZWFkJnV1aWQ9ZDQxODQ3OTBmZmQ1MTFlYmI5ZWJiZjdhOGYxZDc3YmQ";

  OnCanRedoStepsUpdate _onCanRedoStepsUpdate = (stepNum) {
    print('can redo step : $stepNum');
  };

  OnCanUndoStepsUpdate _onCanUndoStepsUpdate = (stepNum) {
    print('can undo step : $stepNum');
  };

  OnRoomStateChanged _onRoomStateChanged = (newState) {
    print('room state change : ${newState.toJson()}');
  };

  Future<WhiteRoom> _joinRoomAgain() async {
    return await sdk.joinRoom(
        options: RoomOptions(
          uuid: ROOM_UUID,
          roomToken: ROOM_TOKEN,
          isWritable: false,
        ),
        onCanRedoStepsUpdate: _onCanRedoStepsUpdate,
        onCanUndoStepsUpdate: _onCanUndoStepsUpdate,
        onRoomStateChanged: _onRoomStateChanged);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WhiteboardView(
          onSdkCreated: (_sdk) async {
            var _room = await _sdk.joinRoom(
                options: RoomOptions(
                  uuid: ROOM_UUID,
                  roomToken: ROOM_TOKEN,
                  isWritable: true,
                ),
                onCanRedoStepsUpdate: _onCanRedoStepsUpdate,
                onCanUndoStepsUpdate: _onCanUndoStepsUpdate,
                onRoomStateChanged: _onRoomStateChanged);
            _room.disableSerialization(false);

            setState(() {
              sdk = _sdk;
              room = _room;
            });
          },
          options: WhiteOptions(
            appIdentifier: APP_ID,
            log: true,
            backgroundColor: Color(0xFFF9F4E7),
          ),
        ),
        OperatingView(sdk: sdk, room: room, joinRoomAgain: _joinRoomAgain),
      ],
    );
  }
}

class OperatingView extends StatefulWidget {
  WhiteSdk sdk;
  WhiteRoom room;
  Function joinRoomAgain;

  OperatingView({Key key, this.sdk, this.room, this.joinRoomAgain})
      : super(key: key);

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
          itemCount: categories.length,
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
  var categories = Category.values;

  WhiteRoom get room => widget.room;

  OperatingViewState() {
    allOpList = [
      OpListItem("重连", Category.Misc, () async {
        room.disconnect().then((value) {
          Future.delayed(Duration(seconds: 3))
              .then((value) => widget.joinRoomAgain());
        }).catchError((o) {
          print("disconnect error");
        });
      }),
      OpListItem("区域设置", Category.Misc, () {
        room.setCameraBound(CameraBound(
            width: 1000, height: 1000, minScale: 0.5, maxScale: 1.5));
        room.cleanScene(true);
      }),
      OpListItem("清屏（保留PPT）", Category.Appliance, () {
        room.cleanScene(true);
      }),
      OpListItem("主播模式", Category.Interaction, () {
        room.setViewMode(ViewMode.Broadcaster);
      }),
      OpListItem("自由模式", Category.Interaction, () {
        room.setViewMode(ViewMode.Freedom);
      }),
      OpListItem("跟随模式", Category.Interaction, () {
        room.setViewMode(ViewMode.Follower);
      }),
      OpListItem("获取视角状态", Category.Interaction, () async {
        var state = await room.getBroadcastState();
        showHint("ViewMode ${state.mode}");
      }),
      OpListItem("移动视角", Category.Interaction, () {
        var config = CameraConfig(centerX: 100);
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
        var dir = sceneState.scenePath
            .substring(0, sceneState.scenePath.lastIndexOf('/'));

        room.putScenes(dir, [Scene(name: "page1")], 0);
        room.setScenePath(dir + "/page1");
      }),
      OpListItem("插入新PPT", Category.Image, () async {
        var sceneState = await room.getSceneState();
        var dir = sceneState.scenePath
            .substring(0, sceneState.scenePath.lastIndexOf('/'));

        var ppt = WhiteBoardPpt(
            src:
                "https://white-pan.oss-cn-shanghai.aliyuncs.com/101/image/alin-rusu-1239275-unsplash_opt.jpg",
            width: 360,
            height: 360);
        room.putScenes(dir, [Scene(name: "page2", ppt: ppt)], 0);
        room.setScenePath(dir + "/page2");
      }),
      OpListItem("插入图片", Category.Image, () {
        var image =
            ImageInformation(centerX: 0, centerY: 0, width: 100, height: 200);
        room.insertImageByUrl(image,
            "https://white-pan.oss-cn-shanghai.aliyuncs.com/40/image/mask.jpg");
      }),
      OpListItem("获取Scene状态", Category.State, () {
        room
            .getSceneState()
            .then((value) => print("getSceneState Result ${value.toJson()}"));
      }),
      OpListItem("获取Room连接状态", Category.State, () {
        room
            .getRoomPhase()
            .then((value) => print("getRoomPhase result $value"));
      }),
      OpListItem("获取Room教具状态", Category.State, () async {
        room
            .getMemberState()
            .then((value) => print("member state ${value.toJson()}"));
      }),
      OpListItem("获取Room状态", Category.State, () {
        room
            .getRoomState()
            .then((value) => print("room state ${value.toJson()}"));
      }),
      OpListItem("自定义状态", Category.State, () {
        room.setGlobalState(
            GlobalDataFoo(a: "change_aaa", b: "change_bbb", c: 321));
        room
            .getGlobalState((jsonMap) => GlobalDataFoo()..fromJson(jsonMap))
            .then((value) => print(value.toJson()));
      }),
      OpListItem("房间成员", Category.State, () {
        room.getRoomMembers().then((value) =>
            print("RoomMembers: ${value.map((e) => e.toJson()).join(';;;;')}"));
      }),
      OpListItem("只读切换", Category.Misc, () {
        room.setWritable(!room.getWritable()).then((writable) => {
              if (writable) {room.disableSerialization(false)}
            });
      }),
      OpListItem("铅笔工具", Category.Appliance, () {
        var state = MemberState(currentApplianceName: ApplianceName.pencil);
        room.setMemberState(state);
      }),
      OpListItem("选取工具", Category.Appliance, () {
        var state = MemberState(currentApplianceName: ApplianceName.selector);
        room.setMemberState(state);
      }),
      OpListItem("删除选中", Category.Appliance, () {
        room.delete();
      }),
      OpListItem("矩形工具", Category.Appliance, () {
        var state = MemberState(currentApplianceName: ApplianceName.rectangle);
        room.setMemberState(state);
      }),
      OpListItem("移动工具", Category.Appliance, () {
        var state = MemberState(currentApplianceName: ApplianceName.hand);
        room.setMemberState(state);
      }),
      OpListItem("文本工具", Category.Appliance, () {
        var state = MemberState(currentApplianceName: ApplianceName.text);
        room.setMemberState(state);
      }),
      OpListItem("形状工具", Category.Appliance, () {
        var state = MemberState(
          currentApplianceName: ApplianceName.shape,
          shapeType: ShapeType.pentagram,
        );
        room.setMemberState(state);
      }),
      OpListItem("缩放", Category.Appliance, () {}),
    ];
    filterOptList =
        allOpList.where((elem) => elem.category == Category.Appliance).toList();
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
            child: Text(_getFilterDisplay(categories[index]), softWrap: true),
            onPressed: () {
              setState(() {
                if (categories[index] == Category.All)
                  filterOptList = allOpList;
                else
                  filterOptList = allOpList
                      .where((item) => item.category == categories[index])
                      .toList();
              });
            }));
  }

  void showHint(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String _getFilterDisplay(Category category) {
    switch (category) {
      case Category.Appliance:
        return "教具";
      case Category.Image:
        return "图片及PPT";
      case Category.Interaction:
        return "交互操作";
      case Category.State:
        return "状态信息";
      case Category.Misc:
        return "其它";
      case Category.All:
        return "全部";
      default:
        return "Unknown";
    }
  }
}

class GlobalDataFoo implements GlobalState {
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
