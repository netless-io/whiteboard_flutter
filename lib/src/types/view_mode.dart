// ignore_for_file: constant_identifier_names

enum ViewMode {
  Freedom,
  Follower,
  Broadcaster,
}

extension ViewModeExtensions on ViewMode {
  String serialize() {
    switch (this) {
      case ViewMode.Freedom:
        return "Freedom";
      case ViewMode.Follower:
        return "Follower";
      case ViewMode.Broadcaster:
        return "Broadcaster";
    }
  }
}

extension ViewModeStringExtensions on String? {
  ViewMode toViewMode() {
    var viewModelMap = <String?, ViewMode>{
      "freedom": ViewMode.Freedom,
      "follower": ViewMode.Follower,
      "broadcaster": ViewMode.Broadcaster,
    };
    return viewModelMap[this] ?? ViewMode.Freedom;
  }
}
