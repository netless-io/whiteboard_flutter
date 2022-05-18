import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'types.dart';

@immutable
class ReplayOptions {
  /// 房间 UUID，即房间唯一标识符，必须和加入互动白板房间实例时设置的房间 UUID 一致
  final String room;

  /// 用于鉴权的 Room Token，必须是使用上面传入的房间 UUID 生成的 Room Token
  final String roomToken;

  /// 实例的数据中心。详见 [Region]
  final String region;

  /// 音频地址，暂不支持视频。
  /// Player 会自动与音视频播放做同步，保证同时播放，当一方缓冲时，会暂停。
  final String? mediaURL;

  /// Unix 时间戳（毫秒），表示回放的起始 UTC 时间。例如，如果要将回放的起始时间设为 2021-03-10 18:03:34 GMT+0800，你需要传入 `1615370614269`
  final int beginTimestamp;

  /// 回放的持续时长，单位为毫秒。
  final int? duration;

  /// 本地用户的视角边界
  final CameraBound? cameraBound;

  final String? slice;

  /// 回调播放进度的频率 默认500ms
  final int step;

  /// 多窗口属性
  final WindowParams? windowParams;

  ReplayOptions({
    required this.room,
    required this.roomToken,
    this.region = Region.cn_hz,
    this.mediaURL,
    this.beginTimestamp = 0,
    this.slice,
    this.duration,
    this.cameraBound,
    this.step = 500,
    this.windowParams,
  });

  ReplayOptions copyWith({
    String? room,
    String? roomToken,
    String? region,
    String? mediaURL,
    int? beginTimestamp,
    String? slice,
    int? duration,
    CameraBound? cameraBound,
    int? step,
    WindowParams? windowParams,
  }) {
    return ReplayOptions(
      room: room ?? this.room,
      roomToken: roomToken ?? this.roomToken,
      region: region ?? this.region,
      mediaURL: mediaURL ?? this.mediaURL,
      beginTimestamp: beginTimestamp ?? this.beginTimestamp,
      slice: slice ?? this.slice,
      duration: duration ?? this.duration,
      cameraBound: cameraBound ?? this.cameraBound,
      step: step ?? this.step,
      windowParams: windowParams ?? this.windowParams,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "room": room,
      "roomToken": roomToken,
      "region": region,
      "mediaURL": mediaURL,
      "beginTimestamp": beginTimestamp,
      "duration": duration,
      "cameraBound": cameraBound?.toJson(),
      "slice": slice,
      if (windowParams != null) "windowParams": jsonEncode(windowParams)
    }..removeWhere((key, value) => value == null);
  }
}
