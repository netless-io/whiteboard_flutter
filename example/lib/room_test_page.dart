import 'dart:math';

import 'package:flutter/material.dart';
import 'package:whiteboard_sdk_flutter/whiteboard_sdk_flutter.dart';

class RoomTestPage extends StatefulWidget {
  RoomTestPage({Key? key}) : super(key: key);

  @override
  _RoomTestPageSate createState() => _RoomTestPageSate();
}

class _RoomTestPageSate extends State<RoomTestPage> {
  WhiteSdk? whiteSdk;
  WhiteRoom? whiteRoom;

  static const String APP_ID = '283/VGiScM9Wiw2HJg';
  static const String ROOM_UUID = "d4184790ffd511ebb9ebbf7a8f1d77bd";
  static const String ROOM_TOKEN =
      "NETLESSROOM_YWs9eTBJOWsxeC1IVVo4VGh0NyZub25jZT0xNjI5MjU3OTQyNTM2MDAmcm9sZT0wJnNpZz1lZDdjOGJiY2M4YzVjZjQ5NDU5NmIzZGJiYzQzNDczNDJmN2NjYTAxMThlMTMyOWVlZGRmMjljNjE1NzQ5ZWFkJnV1aWQ9ZDQxODQ3OTBmZmQ1MTFlYmI5ZWJiZjdhOGYxZDc3YmQ";
  static const String APP_GLOBAL_UID = "123455";

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
    return await whiteSdk!.joinRoom(
        options: RoomOptions(
          uuid: ROOM_UUID,
          roomToken: ROOM_TOKEN,
          uid: APP_GLOBAL_UID,
          isWritable: true,
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
          options: WhiteOptions(
            appIdentifier: APP_ID,
            log: true,
            backgroundColor: Color(0xFFF9F4E7),
          ),
          onSdkCreated: (sdk) async {
            // use sdk to join room
            var room = await sdk.joinRoom(
              options: RoomOptions(
                uuid: ROOM_UUID,
                roomToken: ROOM_TOKEN,
                uid: APP_GLOBAL_UID,
                isWritable: true,
              ),
            );
            room.disableSerialization(false);

            setState(() {
              whiteSdk = sdk;
              whiteRoom = room;
            });
          },
        ),
        if (whiteSdk != null && whiteRoom != null)
          OperatingView(
            sdk: whiteSdk!,
            room: whiteRoom!,
            joinRoomAgain: _joinRoomAgain,
          ),
      ],
    );
  }
}

class OperatingView extends StatefulWidget {
  WhiteSdk sdk;
  WhiteRoom room;
  Function? joinRoomAgain;

  OperatingView(
      {Key? key, required this.sdk, required this.room, this.joinRoomAgain})
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
      OpListItem("Reconnect", Category.Misc, () async {
        room.disconnect().then((value) {
          Future.delayed(Duration(seconds: 2))
              .then((value) => widget.joinRoomAgain?.call());
        }).catchError((o) {
          print("disconnect error");
        });
      }),
      OpListItem("Camera Bound", Category.Misc, () {
        room.setCameraBound(CameraBound(
            width: 1000, height: 1000, minScale: 0.5, maxScale: 1.5));
        room.cleanScene(true);
      }),
      OpListItem("Clean Scene", Category.Appliance, () {
        room.cleanScene(true);
      }),
      OpListItem("Broadcaster Mode", Category.Interaction, () {
        room.setViewMode(ViewMode.Broadcaster);
      }),
      OpListItem("Freedom Mode", Category.Interaction, () {
        room.setViewMode(ViewMode.Freedom);
      }),
      OpListItem("Follower Mode", Category.Interaction, () {
        room.setViewMode(ViewMode.Follower);
      }),
      OpListItem("Fetch ViewMode", Category.Interaction, () async {
        var state = await room.getBroadcastState();
        showHint("ViewMode ${state.mode}");
      }),
      OpListItem("Move Camera", Category.Interaction, () {
        var config = CameraConfig(centerX: 100);
        room.moveCamera(config);
      }),
      OpListItem("Move Camera By Rectangle", Category.Interaction, () {
        var config = RectangleConfig(1000, 1000, 0, 0);
        room.moveCameraToContainer(config);
      }),
      OpListItem("Undo", Category.Interaction, () {
        room.undo();
      }),
      OpListItem("Redo", Category.Interaction, () {
        room.redo();
      }),
      OpListItem("Duplicate", Category.Interaction, () {
        room.duplicate();
      }),
      OpListItem("Copy", Category.Interaction, () {
        room.copy();
      }),
      OpListItem("Paste", Category.Interaction, () {
        room.paste();
      }),
      OpListItem("Fit Ppt", Category.Image, () {
        room.scalePptToFit(AnimationMode.Continuous);
      }),
      OpListItem("Insert Scene", Category.Image, () async {
        var sceneState = await room.getSceneState();
        var dir = sceneState.scenePath
            .substring(0, sceneState.scenePath.lastIndexOf('/'));

        room.putScenes(dir, [Scene(name: "page1")], 0);
        room.setScenePath(dir + "/page1");
      }),
      OpListItem("Insert New Ppt", Category.Image, () async {
        var sceneState = await room.getSceneState();
        var dir = sceneState.scenePath
            .substring(0, sceneState.scenePath.lastIndexOf('/'));

        var ppt = WhiteBoardPpt(
          src:
              "https://white-pan.oss-cn-shanghai.aliyuncs.com/101/image/alin-rusu-1239275-unsplash_opt.jpg",
          width: 360,
          height: 360,
        );
        room.putScenes(dir, [Scene(name: "page2", ppt: ppt)], 0);
        room.setScenePath(dir + "/page2");
      }),
      OpListItem("Insert Image", Category.Image, () {
        var image =
            ImageInformation(centerX: 0, centerY: 0, width: 100, height: 200);
        room.insertImageByUrl(image,
            "https://white-pan.oss-cn-shanghai.aliyuncs.com/40/image/mask.jpg");
      }),
      OpListItem("Get SceneState", Category.State, () {
        room
            .getSceneState()
            .then((value) => print("getSceneState Result ${value.toJson()}"));
      }),
      OpListItem("Get RoomPhase", Category.State, () {
        room
            .getRoomPhase()
            .then((value) => print("getRoomPhase result $value"));
      }),
      OpListItem("Get Room MemberState", Category.State, () async {
        room
            .getMemberState()
            .then((value) => print("member state ${value.toJson()}"));
      }),
      OpListItem("Get RoomState", Category.State, () {
        room
            .getRoomState()
            .then((value) => print("room state ${value.toJson()}"));
      }),
      OpListItem("Use Global State", Category.State, () {
        room.setGlobalState(
            GlobalDataFoo(a: "change_aaa", b: "change_bbb", c: 321));
        room
            .getGlobalState((jsonMap) => GlobalDataFoo()..fromJson(jsonMap))
            .then((value) => print(value.toJson()));
      }),
      OpListItem("Get RoomMembers", Category.State, () {
        room.getRoomMembers().then((value) =>
            print("RoomMembers: ${value.map((e) => e.toJson()).join(';;;;')}"));
      }),
      OpListItem("Change Writable", Category.Misc, () {
        room.setWritable(!room.getWritable()).then((writable) => {
              if (writable) {room.disableSerialization(false)}
            });
      }),
      OpListItem("Pencil", Category.Appliance, () {
        var state = MemberState(currentApplianceName: ApplianceName.pencil);
        room.setMemberState(state);
      }),
      OpListItem("Selector", Category.Appliance, () {
        var state = MemberState(currentApplianceName: ApplianceName.selector);
        room.setMemberState(state);
      }),
      OpListItem("Delete Selected", Category.Appliance, () {
        room.delete();
      }),
      OpListItem("Rectangle", Category.Appliance, () {
        var state = MemberState(currentApplianceName: ApplianceName.rectangle);
        room.setMemberState(state);
      }),
      OpListItem("Hand", Category.Appliance, () {
        var state = MemberState(currentApplianceName: ApplianceName.hand);
        room.setMemberState(state);
      }),
      OpListItem("Text", Category.Appliance, () {
        var state = MemberState(currentApplianceName: ApplianceName.text);
        room.setMemberState(state);
      }),
      OpListItem("Shape", Category.Appliance, () {
        var state = MemberState(
          currentApplianceName: ApplianceName.shape,
          shapeType: ShapeType.pentagram,
        );
        room.setMemberState(state);
      }),
      OpListItem("Scale", Category.Appliance, () {}),
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
        return "Appliance";
      case Category.Image:
        return "Image & Ppt";
      case Category.Interaction:
        return "Interaction";
      case Category.State:
        return "State";
      case Category.Misc:
        return "Misc";
      case Category.All:
        return "All";
      default:
        return "Unknown";
    }
  }
}

class GlobalDataFoo implements GlobalState {
  String? a = "aaaa";
  String? b = "bbb";
  int? c = 123;

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
