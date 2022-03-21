class ReplayTimeInfo {
  int scheduleTime;
  int timeDuration;
  int framesCount;
  int beginTimestamp;

  ReplayTimeInfo({
    this.scheduleTime = 0,
    this.timeDuration = 0,
    this.framesCount = 0,
    this.beginTimestamp = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      "scheduleTime": scheduleTime,
      "timeDuration": timeDuration,
      "framesCount": framesCount,
      "beginTimestamp": beginTimestamp
    };
  }

  // TODO json no filed
  ReplayTimeInfo.fromJson(Map<String, dynamic> json)
      : scheduleTime = json["scheduleTime"],
        timeDuration = json["timeDuration"],
        framesCount = json["framesCount"],
        beginTimestamp = json["beginTimestamp"];
}

/// 白板回放的查看模式。
class PlayerObserverMode {
  /// （默认）跟随模式。
  /// 在跟随模式下，用户观看白板回放时的视角跟随规则如下：
  /// - 如果录制的实时房间中有主播，则跟随主播的视角。
  /// - 如果录制的实时房间中没有主播，即跟随用户 ID 最小的具有读写权限用户（即房间内的第一个互动模式的用户）的视角。
  /// - 如果录制的实时房间中既没有主播，也没有读写权限的用户，则以白板初始化时的视角（中心点在世界坐标系的原点，缩放比例为 1.0）观看回放。
  ///
  /// @note
  /// 在跟随模式下，如果用户通过触屏手势调整了视角，则会自动切换到自由模式。
  static const directory = "directory";

  /// 自由模式。
  ///
  /// 在自由模式下，用户观看回放时可以自由调整视角。
  static const freedom = "freedom";
}
