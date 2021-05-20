import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_whiteboard_sdk/flutter_whiteboard_sdk.dart';

class OperatingView extends StatefulWidget {
  WhiteBoardSDK sdk;
  WhiteBoardRoom room;
  WhiteBoardPlayer player;

  OperatingView({Key key, this.sdk, this.room, this.player}) : super(key: key);

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
          itemCount: categoryList.length,
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
  var categoryList = Category.values;

  WhiteBoardRoom get room => widget.room;

  OperatingViewState() {
    allOpList = [
      OpListItem("重连", Category.Misc, () {
        room.setViewMode(WhiteBoardViewMode.Broadcaster);
      }),
      OpListItem("主播模式", Category.State, () {
        room.setViewMode(WhiteBoardViewMode.Broadcaster);
      }),
      OpListItem("自由模式", Category.State, () {
        room.setViewMode(WhiteBoardViewMode.Freedom);
      }),
      OpListItem("跟随模式", Category.State, () {
        room.setViewMode(WhiteBoardViewMode.Follower);
      }),
      OpListItem("获取视角状态", Category.State, () async {
        var state = await room.getBroadcastState();
        showHint("ViewMode ${state.mode}");
      }),
      OpListItem("铺满PPT", Category.Image, () {
        room.scalePptToFit(AnimationMode.Continuous);
      }),
      OpListItem("移动视角", Category.State, () {
        var config = WhiteBoardCameraConfig(centerX: 100);
        room.moveCamera(config);
      }),
      OpListItem("调整视野", Category.State, () {
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
      OpListItem("清屏（保留PPT）", Category.Interaction, () {
        room.cleanScene(true);
      }),
      OpListItem("插入新页面", Category.Image, () {
        var config = WhiteBoardCameraConfig(centerX: 100);
        room.moveCamera(config);
      }),
      OpListItem("插入新PPT", Category.Image, () {
        var config = WhiteBoardCameraConfig(centerX: 100);
        room.moveCamera(config);
      }),
      OpListItem("插入图片", Category.Image, () {
        var config = WhiteBoardCameraConfig(centerX: 100);
        room.moveCamera(config);
      }),
      OpListItem("获取Scene状态", Category.State, () {
        var config = WhiteBoardCameraConfig(centerX: 100);
        room.moveCamera(config);
      }),
      OpListItem("获取Room连接状态", Category.State, () {
        var config = WhiteBoardCameraConfig(centerX: 100);
        room.moveCamera(config);
      }),
      OpListItem("获取Room教具状态", Category.State, () async {
        room.getMemberState().then((value) => print(value.toJson()));
      }),
      OpListItem("获取Room状态", Category.State, () {}),
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
      OpListItem("缩放", Category.Interaction, () {
        var config = WhiteBoardCameraConfig(centerX: 100);
        room.moveCamera(config);
      }),
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
      child: SizedBox(
          width: 100.0,
          child: ElevatedButton(
              child: Text("${filterOptList[index].text}"),
              onPressed: filterOptList[index].handler)),
    );
  }

  Widget _buildCategoryListItem(BuildContext context, int index) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 100.0,
          child: ElevatedButton(
              child: Text("${categoryList[index].toString().split('.').last}"),
              onPressed: () {
                setState(() {
                  if (categoryList[index] == Category.All)
                    filterOptList = allOpList;
                  else
                    filterOptList =
                        allOpList.where((item) => item.category == categoryList[index]).toList();
                });
              }),
        ));
  }

  void showHint(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
