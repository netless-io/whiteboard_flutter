import 'package:flutter/foundation.dart';

import 'types.dart';

@immutable
class RoomOptions {
  final String uuid;
  final String roomToken;
  final String uid;

  /// 数据中心。[Region]
  final String region;

  /// 视角边界。
  final CameraBound? cameraBound;

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

  /// 获取自定义用户信息。
  final dynamic userPayload;

  /// 多窗口属性
  final WindowParams? windowParams;

  /// 是否关闭 ``insertText`` 与 ``updateText`` 操作权限
  final bool disableTextOperations;

  /// 实时房间的参数
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
    this.disableTextOperations = false,
    this.userPayload,
    this.windowParams,
  });

  RoomOptions copyWith({
    String? uuid,
    String? roomToken,
    String? uid,
    String? region,
    bool? isWritable,
    CameraBound? cameraBound,
    int? timeout,
    bool? disableEraseImage,
    bool? disableDeviceInputs,
    bool? disableOperations,
    bool? disableCameraTransform,
    bool? disableBezier,
    bool? disableNewPencil,
    bool? disableTextOperations,
    dynamic userPayload,
    WindowParams? windowParams,
  }) {
    return RoomOptions(
      uuid: uuid ?? this.uuid,
      roomToken: roomToken ?? this.roomToken,
      uid: uid ?? this.uid,
      region: region ?? this.region,
      isWritable: isWritable ?? this.isWritable,
      cameraBound: cameraBound ?? this.cameraBound,
      timeout: timeout ?? this.timeout,
      disableEraseImage: disableEraseImage ?? this.disableEraseImage,
      disableDeviceInputs: disableDeviceInputs ?? this.disableDeviceInputs,
      disableOperations: disableOperations ?? this.disableOperations,
      disableCameraTransform:
          disableCameraTransform ?? this.disableCameraTransform,
      disableBezier: disableBezier ?? this.disableBezier,
      disableNewPencil: disableNewPencil ?? this.disableNewPencil,
      disableTextOperations:
          disableTextOperations ?? this.disableTextOperations,
      userPayload: userPayload ?? this.userPayload,
      windowParams: windowParams ?? this.windowParams,
    );
  }

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
      if (userPayload != null) "userPayload": userPayload,
      if (windowParams != null) "windowParams": windowParams,
    }..removeWhere((key, value) => value == null);
  }
}
