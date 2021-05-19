import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'DsBridge.dart';
import 'DsBridgeInAppWebView.dart';
import 'DsBridgeWebView.dart';

class WhiteBoard extends StatelessWidget {
  final String appId;
  final bool log;
  final Color backgroundColor;
  final String assetFilePath;
  final ValueChanged<WhiteBoardSDK> onCreated;

  static GlobalKey<DsBridgeWebViewState> webview =
      GlobalKey<DsBridgeWebViewState>();

  WhiteBoard(
      {Key key,
      this.assetFilePath,
      this.appId,
      this.onCreated,
      this.backgroundColor = Colors.white,
      this.log = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DsBridgeWebView(
      key: webview,
      url: "",
      onWebViewCreated: (controller) {
        controller.loadAssetHtmlFile(assetFilePath);
      },
      onDSBridgeCreated: (DsBridge dsBridge) {
        onCreated(WhiteBoardSDK(
            config: WhiteBoardSdkConfiguration(
                appIdentifier: appId,
                log: log,
                backgroundColor: backgroundColor),
            dsBridge: dsBridge));
      },
    );
  }
}

class WhiteBoardWithInApp extends StatelessWidget {
  final String appId;
  final bool log;
  final Color backgroundColor;
  final ValueChanged<WhiteBoardSDK> onCreated;

  final String assetFilePath;

  static GlobalKey<DsBridgeInAppWebViewState> webview =
      GlobalKey<DsBridgeInAppWebViewState>();

  WhiteBoardWithInApp(
      {Key key,
      this.assetFilePath,
      this.appId,
      this.onCreated,
      this.backgroundColor = Colors.white,
      this.log = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DsBridgeInAppWebView(
      key: webview,
      url: "",
      onWebViewCreated: (controller) {
        controller.loadFile(assetFilePath: assetFilePath);
      },
      onDSBridgeCreated: (DsBridge dsBridge) {
        onCreated(WhiteBoardSDK(
            config: WhiteBoardSdkConfiguration(
                appIdentifier: appId,
                log: log,
                backgroundColor: backgroundColor),
            dsBridge: dsBridge));
      },
    );
  }
}

class WhiteBoardSDK {
  String tag = "WhiteBoardSDK";
  final DsBridge dsBridge;
  final WhiteBoardSdkConfiguration config;

  WhiteBoardSDK({this.config, this.dsBridge}) {
    dsBridge.callHandler("sdk.newWhiteSdk", [config.toJson()], null);
    if (config.backgroundColor != null) {
      setBackgroundColor(config.backgroundColor);
    }
  }

  Future<WhiteBoardRoom> joinRoom(RoomParams params) {
    var completer = Completer<WhiteBoardRoom>();
    dsBridge.callHandler("sdk.joinRoom", [params.toJson()], ([returnValue]) {
      var room = WhiteBoardRoom(dsBridge: dsBridge, params: params);
      try {
        room.initStateWithJoinRoom(jsonDecode(returnValue));
        completer.complete(room);
      } catch (e) {
        completer.completeError(e);
      }
      return room;
    });
    return completer.future;
  }

  Future<WhiteBoardPlayer> replayRoom(ReplayRoomParams params) {
    var completer = Completer<WhiteBoardPlayer>();
    dsBridge.callHandler("sdk.replayRoom", [params.toJson()], ([returnValue]) {
      var room = WhiteBoardPlayer(dsBridge: dsBridge, params: params);
      try {
        room.initTimeInfoWithReplyRoom(jsonDecode(returnValue));
        completer.complete(room);
      } catch (e) {
        completer.completeError(e);
      }
      return room;
    });
    return completer.future;
  }

  setBackgroundColor(Color color) {
    int r = color.red;
    int g = color.green;
    int b = color.blue;
    double a = color.opacity;
    dsBridge.evaluateJavascript('''
      var div = document.getElementById("whiteboard-container");
      var color = "rgba($r, $g, $b, $a)";
      div.style.background = color;
    ''');
  }
}

class WhiteBoardDisplayer {
  static const kDisplayerNamespace = "displayer.";
  static const kAsyncDisplayerNamespace = "displayerAsync.";

  String tag = "WhiteBoardDisplayer";

  final DsBridge dsBridge;

  WhiteBoardDisplayer(this.dsBridge) {
    dsBridge.addJavascriptObject(this.createSDKInterface());
  }

  JavaScriptNamespaceInterface createSDKInterface() {
    var interface = JavaScriptNamespaceInterface("sdk");
    interface.setMethod("onPPTMediaPlay", this._onPPTMediaPlay);
    interface.setMethod("onPPTMediaPause", this._onPPTMediaPause);
    interface.setMethod('throwError', this._onThrowMessage);
    interface.setMethod('postMessage', this._onPostMessage);
    return interface;
  }

  _onPPTMediaPlay(value) {
    print(value);
  }

  _onPPTMediaPause(value) {
    print(value);
  }

  _onThrowMessage(value) {
    print(value);
  }

  _onPostMessage(value) {
    print(value);
  }

  scalePptToFit(String mode) {
    dsBridge.callHandler("${kDisplayerNamespace}scalePptToFit", [mode], null);
  }

  moveCamera(WhiteBoardCameraConfig config) {
    dsBridge.callHandler(
        "${kDisplayerNamespace}moveCamera", [config.toJson()], null);
  }

  refreshViewSize() {
    dsBridge.callHandler("${kDisplayerNamespace}refreshViewSize", [], null);
  }

  setBackgroundColor(Color color) {
    dsBridge.callHandler("${kDisplayerNamespace}setBackgroundColor",
        [color.red, color.green, color.blue, color.alpha], null);
  }

  setDisableCameraTransform(bool disable) {
    dsBridge.callHandler(
        "${kDisplayerNamespace}setDisableCameraTransform", [disable], null);
  }

  Future<bool> getDisableCameraTransform() async {
    var value = dsBridge.callHandler(
        "${kDisplayerNamespace}getDisableCameraTransform", [], null);
    return value == 'true';
  }
}

class WhiteBoardMemberState {
  List<int> strokeColor;
  int strokeWidth;
  int textSize;
  PencilOptions pencilOptions;
  bool disableBezier;
  String currentApplianceName;

  WhiteBoardMemberState({
    this.currentApplianceName,
    this.strokeColor,
    this.strokeWidth,
    this.textSize,
    this.pencilOptions,
    this.disableBezier,
  });

  void fromJson(Map<String, dynamic> json) {
    strokeColor =
        (json["strokeColor"] as List)?.map<int>((e) => e as int)?.toList();
    strokeWidth = json["strokeWidth"];
    textSize = json["textSize"];
    pencilOptions = PencilOptions()..fromJson(json["pencilOptions"]);
    disableBezier = json["disableBezier"];
    currentApplianceName = json["currentApplianceName"];
  }

  Map<String, dynamic> toJson() {
    return {
      "strokeColor": strokeColor,
      "strokeWidth": strokeWidth,
      "textSize": textSize,
      "pencilOptions": pencilOptions?.toJson(),
      "disableBezier": disableBezier,
      "currentApplianceName": currentApplianceName,
    }..removeWhere((key, value) => value == null);
  }
}

typedef void OnRoomStateChanged(WhiteBoardRoomState newState);
typedef void OnRoomDisconnected(String error);
typedef void OnRoomKicked(String reason);
typedef void OnPlayerPhaseChanged(String phase);
typedef void OnRoomPhaseChanged(String phase);
typedef void OnScheduleTimeChanged(int scheduleTime);

class WhiteBoardPlayer extends WhiteBoardDisplayer {
  final ReplayRoomParams params;
  final DsBridge dsBridge;

  String tag = "WhiteBoardPlayer";

  ReplayTimeInfo replayTimeInfo = ReplayTimeInfo();
  String phase = WhiteBoardPlayerPhase.Buffering;
  int currentTime = 0;

  OnPlayerPhaseChanged onPlayerPhaseChanged;
  OnScheduleTimeChanged onScheduleTimeChanged;

  WhiteBoardPlayer({this.params, this.dsBridge}) : super(dsBridge) {
    dsBridge.addJavascriptObject(this.createPlayerInterface());
  }

  JavaScriptNamespaceInterface createPlayerInterface() {
    var interface = JavaScriptNamespaceInterface("player");
    interface.setMethod("onPhaseChanged", this._onPhaseChanged);
    interface.setMethod("onPlayerStateChanged", this._onPlayerStateChanged);
    interface.setMethod("onLoadFirstFrame", this._onLoadFirstFrame);
    interface.setMethod("onScheduleTimeChanged", this._onScheduleTimeChanged);
    interface.setMethod("onStoppedWithError", this._onStoppedWithError);
    interface.setMethod(
        "fireCatchErrorWhenAppendFrame", this._fireCatchErrorWhenAppendFrame);
    interface.setMethod("onCatchErrorWhenRender", this._onCatchErrorWhenRender);
    return interface;
  }

  _onPhaseChanged(String value) {
    phase = value;
    if (onPlayerPhaseChanged != null) {
      onPlayerPhaseChanged(value);
    }
  }

  _onPlayerStateChanged(String value) {
    print(value);
  }

  _onLoadFirstFrame(value) {
    print(value);
  }

  _onScheduleTimeChanged(value) {
    currentTime = value;
    if (onScheduleTimeChanged != null) {
      onScheduleTimeChanged(value);
    }
  }

  _onStoppedWithError(value) {
    print(value);
  }

  _fireCatchErrorWhenAppendFrame(value) {
    print(value);
  }

  _onCatchErrorWhenRender(value) {
    print(value);
  }

  initTimeInfoWithReplyRoom(Map<String, dynamic> json) {
    replayTimeInfo = ReplayTimeInfo()..fromJson(json["timeInfo"]);
  }

  play() {
    dsBridge.callHandler("player.play", [], null);
  }

  stop() {
    dsBridge.callHandler("player.stop", [], null);
  }

  pause() {
    dsBridge.callHandler("player.pause", [], null);
  }

  seekToScheduleTime(double beginTime) {
    currentTime = beginTime.toInt();
    dsBridge.callHandler("player.seekToScheduleTime", [beginTime], null);
  }

  setObserverMode(String observerMode) {
    dsBridge.callHandler("player.setObserverMode", [observerMode], null);
  }

  setPlaybackSpeed(double rate) {
    dsBridge.callHandler("player.setPlaybackSpeed", [rate], null);
  }

  Future<String> get roomUUID {
    return dsBridge.callHandler("player.state.roomUUID", [], null);
  }

  Future<String> getPhase() {
    return dsBridge.callHandler("player.state.phase", [], null);
  }

  Future<WhiteBoardPlayerState> get playerState async {
    var value =
        await dsBridge.callHandler("player.state.playerState", [], null);
    return WhiteBoardPlayerState()..fromJson(jsonDecode(value));
  }

  Future<bool> get isPlayable async {
    var value = await dsBridge.callHandler("player.state.isPlayable", [], null);
    return value == 'true';
  }

  Future<double> get playbackSpeed async {
    var value =
        await dsBridge.callHandler("player.state.playbackSpeed", [], null);
    return double.tryParse(value);
  }

  Future<ReplayTimeInfo> get timeInfo async {
    var value = await dsBridge.callHandler("player.state.timeInfo", [], null);
    return ReplayTimeInfo()..fromJson(jsonDecode(value));
  }
}

class WhiteBoardPlayerPhase {
  static const WaitingFirstFrame = "waitingFirstFrame";
  static const Playing = "playing";
  static const Pause = "pause";
  static const Stopped = "stop";
  static const Ended = "ended";
  static const Buffering = "buffering";
}

class WhiteBoardRoom extends WhiteBoardDisplayer {
  final JoinRoomParams params;
  final DsBridge dsBridge;

  String tag = "WhiteBoardRoom";

  WhiteBoardRoomState state = WhiteBoardRoomState();
  WhiteBoardRoomPhase phase = WhiteBoardRoomPhase();

  OnRoomStateChanged onRoomStateChanged;
  OnRoomDisconnected onRoomDisconnected;
  OnRoomKicked onRoomKicked;
  OnRoomPhaseChanged onRoomPhaseChanged;

  bool disconnectedBySelf = false;

  WhiteBoardRoom({this.params, this.dsBridge}) : super(dsBridge) {
    dsBridge.addJavascriptObject(this.createRoomInterface());
  }

  JavaScriptNamespaceInterface createRoomInterface() {
    var interface = JavaScriptNamespaceInterface("room");
    interface.setMethod("firePhaseChanged", this._firePhaseChanged);
    interface.setMethod("fireCanUndoStepsUpdate", this._fireCanUndoStepsUpdate);
    interface.setMethod("fireCanRedoStepsUpdate", this._fireCanRedoStepsUpdate);
    interface.setMethod("fireRoomStateChanged", this._fireRoomStateChanged);
    interface.setMethod(
        "fireDisconnectWithError", this._fireDisconnectWithError);
    interface.setMethod("fireKickedWithReason", this._fireKickedWithReason);
    interface.setMethod(
        "fireCatchErrorWhenAppendFrame", this._fireCatchErrorWhenAppendFrame);
    return interface;
  }

  _firePhaseChanged(String value) {
    if (onRoomPhaseChanged != null) {
      onRoomPhaseChanged(value);
    }
  }

  _fireCanUndoStepsUpdate(value) {
    print(value);
  }

  _fireCanRedoStepsUpdate(value) {
    print(value);
  }

  _fireRoomStateChanged(String value) {
    try {
      var data = jsonDecode(value) as Map<String, dynamic>;
      state.fromJson(
          (<String, dynamic>{})..addAll(state?.toJson())..addAll(data));
      if (onRoomStateChanged != null) onRoomStateChanged(state);
    } catch (e) {
      print(e);
    }
  }

  _fireDisconnectWithError(value) {
    if (onRoomDisconnected != null) onRoomDisconnected(value);
  }

  _fireKickedWithReason(value) {
    if (onRoomKicked != null) onRoomKicked(value);
  }

  _fireCatchErrorWhenAppendFrame(value) {
    print(value);
  }

  initStateWithJoinRoom(Map<String, dynamic> json) {
    state = WhiteBoardRoomState()..fromJson(json["state"]);
  }

  setGlobalState(WhiteBoardGlobalState modifyState) {}

  setMemberState(WhiteBoardMemberState modifyState) {
    dsBridge.callHandler('room.setMemberState', [modifyState.toJson()], null);
  }

  void setViewMode(WhiteBoardViewMode viewMode) {
    String viewModeString;
    switch (viewMode) {
      case WhiteBoardViewMode.Freedom:
        viewModeString = "Freedom";
        break;
      case WhiteBoardViewMode.Follower:
        viewModeString = "Follower";
        break;
      case WhiteBoardViewMode.Broadcaster:
        viewModeString = "Broadcaster";
        break;
      default:
        viewModeString = "Freedom";
        break;
    }
    dsBridge.callHandler("room.setViewMode", [viewModeString], null);
  }

  disconnect({Function callback}) {
    disconnectedBySelf = true;
    dsBridge.callHandler("room.disconnect", [], ([value]) => {callback()});
  }

  set disableOperations(bool value) {
    disableCameraTransform = value;
    disableDeviceInputs = value;
  }

  set disableCameraTransform(bool value) {
    dsBridge.callHandler("room.disableCameraTransform", [value], null);
  }

  set disableDeviceInputs(bool value) {
    dsBridge.callHandler("room.disableDeviceInputs", [value], null);
  }

  debugInfo(Function callback) {
    dsBridge.callHandler("room.state.debugInfo", [], ([value]) {
      callback(value);
    });
  }

  pptNextStep() {
    dsBridge.callHandler("ppt.nextStep", [], null);
  }

  pptPreviousStep() {
    dsBridge.callHandler("ppt.previousStep", [], null);
  }

  Future<Map<String, dynamic>> putScenes(
      String dir, List<WhiteBoardScene> scene, int index) {
    var completer = Completer<Map<String, dynamic>>();
    dsBridge.callHandler(
        "room.putScenes", [dir, scene.map((e) => e.toJson()).toList(), index], (
            [value]) {
      completer.complete(jsonDecode(value));
    });
    return completer.future;
  }

  cleanScene(bool retainPPT) {
    dsBridge.callHandler("room.cleanScene", [retainPPT], null);
  }

  Future<Map<String, dynamic>> setScenePath(String path) {
    var completer = Completer<Map<String, dynamic>>();
    dsBridge.callHandler("room.setScenePath", [path], ([value]) {
      completer.complete(jsonDecode(value));
    });
    return completer.future;
  }

  setSceneIndex(int index, [Function callback]) {
    dsBridge.callHandler("room.setSceneIndex", [index], callback);
  }

  setWritable(bool writable, [Function callback]) {
    dsBridge.callHandler("room.setWritable", [writable], callback);
  }

  removeScenes(String dirOrPath) {
    dsBridge.callHandler("room.removeScenes", [dirOrPath], null);
  }

  Future<WhiteBoardSceneState> getSceneState() {
    var completer = Completer<WhiteBoardSceneState>();
    dsBridge.callHandler("room.getSceneState", [], ([value]) {
      var data = WhiteBoardSceneState()..fromJson(jsonDecode(value));
      completer.complete(data);
    });
    return completer.future;
  }
}

class WhiteBoardDisplayerState {
  WhiteBoardGlobalState globalState;
  WhiteBoardSceneState sceneState;
  WhiteBoardCameraConfig cameraState;
  List<WhiteBoardRoomMember> roomMembers;
}

class WhiteBoardPlayerState extends WhiteBoardDisplayerState {
  String observerMode;

  void fromJson(Map<String, dynamic> json) {
    observerMode = json["observerMode"];
    roomMembers = (json["roomMembers"] as List)
        ?.map<WhiteBoardRoomMember>((e) => WhiteBoardRoomMember()..fromJson(e))
        ?.toList();
    cameraState = WhiteBoardCameraConfig()..fromJson(json["cameraState"]);
    globalState = WhiteBoardGlobalState()..fromJson(json["globalState"]);
    sceneState = WhiteBoardSceneState()..fromJson(json["sceneState"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "observerMode": observerMode,
      "roomMembers": roomMembers.map((e) => e.toJson()).toList(),
      "cameraState": cameraState.toJson(),
      "globalState": globalState.toJson(),
      "sceneState": sceneState.toJson(),
    };
  }
}

class WhiteBoardRoomState extends WhiteBoardDisplayerState {
  WhiteBoardMemberState memberState;
  WhiteBoardBroadcastState broadcastState;
  num zoomScale;

  void fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    memberState = WhiteBoardMemberState()..fromJson(json["memberState"]);
    broadcastState = WhiteBoardBroadcastState()
      ..fromJson(json["broadcastState"]);
    zoomScale = json["zoomScale"];
    roomMembers = (json["roomMembers"] as List)
        ?.map<WhiteBoardRoomMember>((e) => WhiteBoardRoomMember()..fromJson(e))
        ?.toList();
    cameraState = WhiteBoardCameraConfig()..fromJson(json["cameraState"]);
    globalState = WhiteBoardGlobalState()..fromJson(json["globalState"]);
    sceneState = WhiteBoardSceneState()..fromJson(json["sceneState"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "memberState": memberState.toJson(),
      "broadcastState": broadcastState.toJson(),
      "zoomScale": zoomScale,
      "roomMembers": roomMembers.map((e) => e.toJson()).toList(),
      "cameraState": cameraState.toJson(),
      "globalState": globalState.toJson(),
      "sceneState": sceneState.toJson(),
    };
  }
}

class WhiteBoardGlobalState {
  int currentSceneIndex;

  WhiteBoardGlobalState({this.currentSceneIndex});

  Map<String, dynamic> toJson() {
    return {
      "currentSceneIndex": currentSceneIndex,
    };
  }

  void fromJson(Map<String, dynamic> json) {
    currentSceneIndex = json["currentSceneIndex"];
  }
}

class WhiteBoardRoomMember {
  int memberId;
  WhiteBoardMemberState memberState;
  String session;
  WhiteBoardUserPayload payload;

  WhiteBoardRoomMember({
    this.memberId,
    this.memberState,
    this.session,
    this.payload,
  });

  Map<String, dynamic> toJson() {
    return {
      "memberId": memberId,
      "memberState": memberState.toJson(),
      "session": session,
      "payload": payload.toJson()
    };
  }

  void fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    memberId = json["memberId"];
    memberState = WhiteBoardMemberState()..fromJson(json["memberState"]);
    session = json["session"];
    payload = WhiteBoardUserPayload()..fromJson(json["payload"]);
  }
}

class WhiteBoardUserPayload {
  String userId;
  String identity;

  WhiteBoardUserPayload({
    this.userId,
    this.identity,
  });

  Map<String, dynamic> toJson() {
    return {"userId": userId, "identity": identity};
  }

  void fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    userId = json["userId"];
    identity = json["identity"];
  }
}

class ApplianceName {
  static const pencil = "pencil";
  static const selector = "selector";
  static const laserPointer = "laserPointer";
  static const rectangle = "rectangle";
  static const ellipse = "ellipse";
  static const eraser = "eraser";
  static const text = "text";
  static const straight = "straight";
  static const arrow = "arrow";
  static const hand = "hand";
}

class PencilOptions {
  bool enableDrawPoint;
  bool disableBezier;
  int sparseHump;
  int sparseWidth;

  PencilOptions({
    this.enableDrawPoint,
    this.disableBezier,
    this.sparseHump,
    this.sparseWidth,
  });

  void fromJson(Map<String, dynamic> json) {
    enableDrawPoint = json["enableDrawPoint"];
    disableBezier = json["disableBezier"];
    sparseHump = json["sparseHump"];
    sparseWidth = json["sparseWidth"];
  }

  Map<String, dynamic> toJson() {
    return {
      "enableDrawPoint": enableDrawPoint,
      "disableBezier": disableBezier,
      "sparseHump": sparseHump,
      "sparseWidth": sparseWidth
    };
  }
}

class WhiteBoardBroadcastState {
  String mode;

  void fromJson(Map<String, dynamic> json) {
    mode = json["mode"];
  }

  Map<String, dynamic> toJson() {
    return {
      "mode": mode,
    };
  }
}

class WhiteBoardSceneState {
  List<WhiteBoardScene> scenes;
  String scenePath;
  int index;

  Map<String, dynamic> toJson() {
    return {
      "index": index,
      "scenePath": scenePath,
      "scenes": scenes?.map<Map<String, dynamic>>((e) => e.toJson())?.toList()
    };
  }

  void fromJson(Map<String, dynamic> json) {
    index = json["index"];
    scenePath = json["scenePath"];
    scenes = (json["scenes"] as List)
        ?.map<WhiteBoardScene>((e) => WhiteBoardScene()..fromJson(e))
        ?.toList();
  }
}

class WhiteBoardRoomPhase {
  static const String connecting = "connecting";
  static const String connected = "connected";
  static const String reconnecting = "reconnecting";
  static const String disconnecting = "disconnecting";
  static const String disconnected = "disconnected";
  String value = WhiteBoardRoomPhase.disconnected;
}

enum WhiteBoardViewMode {
  Freedom,
  Follower,
  Broadcaster,
}

class WhiteBoardScene {
  String name;
  WhiteBoardPpt ppt;
  int componentsCount;

  void fromJson(Map<String, dynamic> json) {
    name = json["name"];
    componentsCount = json["componentsCount"];
    ppt = json["ppt"] != null ? (WhiteBoardPpt()..fromJson(json["ppt"])) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "ppt": ppt.toJson(),
      "componentsCount": componentsCount,
    };
  }
}

class WhiteBoardPpt {
  String src;
  int width;
  int height;
  String previewURL;

  void fromJson(Map<String, dynamic> json) {
    src = json["src"];
    width = json["width"];
    height = json["height"];
    previewURL = json["previewURL"];
  }

  Map<String, dynamic> toJson() {
    return {
      "src": src,
      "width": width,
      "height": height,
      "previewURL": previewURL,
    };
  }
}

class AnimationMode {
  static const Continuous = "continuous";
  static const Immediately = "immediately";
}

class WhiteBoardSdkConfiguration {
  final String appIdentifier;
  final bool log;
  final Color backgroundColor;

  WhiteBoardSdkConfiguration(
      {this.appIdentifier, this.log, this.backgroundColor});

  toJson() {
    return {
      "appIdentifier": appIdentifier,
      "log": log,
    };
  }
}

abstract class RoomParams {
  Map<String, dynamic> toJson();
}

class JoinRoomParams extends RoomParams {
  final String uuid;
  final String roomToken;

  JoinRoomParams(this.uuid, this.roomToken);

  @override
  Map<String, dynamic> toJson() {
    return {
      "uuid": uuid,
      "roomToken": roomToken,
    };
  }
}

class ReplayRoomParams extends RoomParams {
  final String room;
  final String roomToken;
  final String mediaURL;
  final int beginTimestamp;
  final int duration;

  ReplayRoomParams(
      {this.room,
      this.roomToken,
      this.mediaURL,
      this.beginTimestamp,
      this.duration});

  @override
  Map<String, dynamic> toJson() {
    return {
      "room": room,
      "roomToken": roomToken,

      /// 此处mediaURL不传入SDK，会有问题
      // "mediaURL": mediaURL,
      "beginTimestamp": beginTimestamp,
      "duration": duration,
    };
  }
}

class WhiteBoardCameraConfig {
  num centerX;
  num centerY;
  num scale;
  String animationMode;

  WhiteBoardCameraConfig(
      {this.centerX = 0, this.centerY = 0, this.scale, this.animationMode});

  Map<String, dynamic> toJson() {
    return {
      "centerX": centerX,
      "centerY": centerY,
      "scale": scale,
      "animationMode": animationMode
    };
  }

  void fromJson(Map<String, dynamic> json) {
    centerX = json["centerX"];
    centerY = json["centerY"];
    scale = json["scale"];
    animationMode = json["animationMode"];
  }
}

class ReplayTimeInfo {
  int scheduleTime;
  int timeDuration;
  int framesCount;
  int beginTimestamp;

  Map<String, dynamic> toJson() {
    return {
      "scheduleTime": scheduleTime,
      "timeDuration": timeDuration,
      "framesCount": framesCount,
      "beginTimestamp": beginTimestamp
    };
  }

  void fromJson(Map<String, dynamic> json) {
    scheduleTime = json["scheduleTime"];
    timeDuration = json["timeDuration"];
    framesCount = json["framesCount"];
    beginTimestamp = json["beginTimestamp"];
  }
}
