import 'types.dart';

class ReplayOptions {
  final String room;
  final String roomToken;
  String region;
  final String? mediaURL;
  final int beginTimestamp;
  final int? duration;
  CameraBound? cameraBound;
  String? slice;

  /// 回调播放进度的频率 默认500ms
  int step = 500;

  ReplayOptions({
    required this.room,
    required this.roomToken,
    this.region = Region.cn_hz,
    this.mediaURL,
    this.beginTimestamp = 0,
    this.duration,
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
      if (cameraBound != null) "cameraBound": cameraBound!.toJson(),
      "slice": slice,
    }..removeWhere((key, value) => value == null);
  }
}
