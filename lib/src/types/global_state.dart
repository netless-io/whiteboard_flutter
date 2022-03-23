import 'types.dart';

class DisplayerState {
  GlobalState? globalState;
  WhiteBoardSceneState? sceneState;
  CameraConfig? cameraState;
  List<RoomMember>? roomMembers;

  var globalStateParser;

  void setCustomGlobalStateParser<T>(GlobalStateParser<T> parser) {
    this.globalStateParser = parser;
  }

  parseGlobalState(Map<String, dynamic> state) {
    return globalStateParser != null ? globalStateParser(state) : null;
  }
}

class ReplayState extends DisplayerState {
  String? observerMode;

  void fromJson(Map<String, dynamic> json) {
    observerMode = json["observerMode"];
    roomMembers = (json["roomMembers"] as List)
        .map<RoomMember>((e) => RoomMember.fromJson(e))
        .toList();
    cameraState = CameraConfig.fromJson(json["cameraState"]);
    sceneState = WhiteBoardSceneState.fromJson(json["sceneState"]);
    globalState = parseGlobalState(json['globalState']);
  }

  Map<String, dynamic> toJson() => {
        "observerMode": observerMode,
        "roomMembers": roomMembers?.map((e) => e.toJson()).toList(),
        "cameraState": cameraState?.toJson(),
        "globalState": globalState?.toJson(),
        "sceneState": sceneState?.toJson(),
      }..removeWhere((key, value) => value == null);
}

class RoomState extends DisplayerState {
  MemberState? memberState;
  BroadcastState? broadcastState;
  num? zoomScale;

  void fromJson(Map<String, dynamic> json) {
    memberState = MemberState.fromJson(json["memberState"]);
    broadcastState = BroadcastState.fromJson(json["broadcastState"]);
    zoomScale = json["zoomScale"];
    roomMembers = (json["roomMembers"] as List)
        .map<RoomMember>((jsonMap) => RoomMember.fromJson(jsonMap))
        .toList();
    cameraState = CameraConfig.fromJson(json["cameraState"]);
    sceneState = WhiteBoardSceneState.fromJson(json["sceneState"]);
    globalState = parseGlobalState(json["globalState"] ?? {});
  }

  Map<String, dynamic> toJson() => {
        "memberState": memberState?.toJson(),
        "broadcastState": broadcastState?.toJson(),
        "zoomScale": zoomScale,
        "roomMembers": roomMembers?.map((e) => e.toJson()).toList(),
        "cameraState": cameraState?.toJson(),
        "globalState": globalState?.toJson(),
        "sceneState": sceneState?.toJson(),
      }..removeWhere((key, value) => value == null);
}

typedef GlobalStateParser<T> = T Function(Map<String, dynamic> jsonMap);

abstract class GlobalState {
  Map<String, dynamic> toJson();

  void fromJson(Map<String, dynamic> json);
}
