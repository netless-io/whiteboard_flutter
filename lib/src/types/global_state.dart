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

  ReplayState.fromJson(Map<String, dynamic> json) {
    observerMode = json["observerMode"];
    roomMembers = (json["roomMembers"] as List)
        .map<RoomMember>((e) => RoomMember.fromJson(e))
        .toList();
    cameraState = CameraConfig.fromJson(json["cameraState"]);
    globalState = parseGlobalState(json['globalState']);
    sceneState = WhiteBoardSceneState.fromJson(json["sceneState"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "observerMode": observerMode,
      if (roomMembers != null)
        "roomMembers": roomMembers!.map((e) => e.toJson()).toList(),
      if (cameraState != null) "cameraState": cameraState!.toJson(),
      if (globalState != null) "globalState": globalState!.toJson(),
      if (sceneState != null) "sceneState": sceneState!.toJson(),
    };
  }
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
    globalState = parseGlobalState(json["globalState"] ?? {});
    sceneState = WhiteBoardSceneState.fromJson(json["sceneState"]);
  }

  Map<String, dynamic> toJson() {
    return {
      if (memberState != null) "memberState": memberState!.toJson(),
      if (broadcastState != null) "broadcastState": broadcastState!.toJson(),
      "zoomScale": zoomScale,
      if (roomMembers != null) "roomMembers": roomMembers!.map((e) => e.toJson()).toList(),
      if (cameraState != null) "cameraState": cameraState!.toJson(),
      if (globalState != null) "globalState": globalState!.toJson(),
      if (sceneState != null) "sceneState": sceneState!.toJson(),
    }..removeWhere((key, value) => value == null);
  }
}

typedef T GlobalStateParser<T>(Map<String, dynamic> jsonMap);

abstract class GlobalState {
  Map<String, dynamic> toJson();

  void fromJson(Map<String, dynamic> json);
}
