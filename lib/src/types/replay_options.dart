import 'package:flutter/foundation.dart';

import 'types.dart';

@immutable
class ReplayOptions {
  final String room;
  final String roomToken;
  final String region;
  final String? mediaURL;
  final int beginTimestamp;
  final int? duration;
  final CameraBound? cameraBound;
  final String? slice;

  /// 回调播放进度的频率 默认500ms
  final int step;

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
  });

  Map<String, dynamic> toJson() {
    return {
      "room": room,
      "roomToken": roomToken,
      "region": region,

      /// 此处mediaURL不传入SDK，会有问题
      // "mediaURL": mediaURL,
      "beginTimestamp": beginTimestamp,
      "duration": duration,
      "cameraBound": cameraBound?.toJson(),
      "slice": slice,
    }..removeWhere((key, value) => value == null);
  }
}
