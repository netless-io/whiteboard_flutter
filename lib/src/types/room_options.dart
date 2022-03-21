import 'dart:convert';

import 'types.dart';

class RoomOptions {
  final String uuid;
  final String roomToken;
  final String uid;

  /// 数据中心。
  final String region;

  /// 视角边界。
  CameraBound? cameraBound;

  /// 重连时，最大重连尝试时间，单位：毫秒，默认 45 秒。
  final int timeout;

  /// 是否以互动模式加入白板房间
  final bool isWritable;

  /// 禁止白板工具响应用户输入。
  final bool disableEraseImage;

  /// 禁止白板工具响应用户输入
  final bool disableDeviceInputs;

  /// 禁止白板工具响应用户输入
  final bool disableOperations;

  /// 禁止本地用户操作白板视角
  final bool disableCameraTransform;

  /// 关闭贝塞尔曲线优化。
  final bool disableBezier;

  /// 关闭笔锋效果
  final bool disableNewPencil;

  dynamic userPayload;

  /// 关闭笔锋效果。
  /// 用户配置
  RoomOptions({
    required this.uuid,
    required this.roomToken,
    required this.uid,
    this.region = Region.cn_hz,
    this.isWritable = true,
    this.cameraBound,
    this.timeout = 45000,
    this.disableEraseImage = false,
    this.disableDeviceInputs = false,
    this.disableOperations = false,
    this.disableCameraTransform = false,
    this.disableBezier = false,
    this.disableNewPencil = false,
    this.userPayload,
  });

  Map<String, dynamic> toJson() {
    return {
      "uuid": uuid,
      "roomToken": roomToken,
      "uid": uid,
      "region": region,
      "cameraBound": cameraBound,
      "timeout": timeout,
      "isWritable": isWritable,
      "disableEraseImage": disableEraseImage,
      "disableDeviceInputs": disableDeviceInputs,
      "disableOperations": disableOperations,
      "disableCameraTransform": disableCameraTransform,
      "disableBezier": disableBezier,
      "disableNewPencil": disableNewPencil,
      if (userPayload != null) "userPayload": jsonEncode(userPayload),
    }..removeWhere((key, value) => value == null);
  }
}
