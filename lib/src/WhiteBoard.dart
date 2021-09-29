import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import 'DsBridge.dart';
import 'DsBridgeInAppWebView.dart';

class WhiteBoardWithInApp extends StatelessWidget {
  final ValueChanged<WhiteBoardSDK> onCreated;

  // final String assetFilePath;
  final WhiteBoardSdkConfiguration configuration;

  static GlobalKey<DsBridgeInAppWebViewState> webView = GlobalKey<DsBridgeInAppWebViewState>();

  WhiteBoardWithInApp({
    Key key,
    this.onCreated,
    this.configuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DsBridgeInAppWebView(
      key: webView,
      url: "",
      onWebViewCreated: (controller) {
        controller.loadFile(assetFilePath: "packages/whiteboard_sdk_flutter/assets/whiteboardBridge/index.html");
      },
      onDSBridgeCreated: (DsBridge dsBridge) async {
        dsBridge.addJavascriptObject(this.createSDKInterface());
        onCreated(WhiteBoardSDK(config: configuration, dsBridge: dsBridge));
      },
    );
  }

  JavaScriptNamespaceInterface createSDKInterface() {
    var interface = JavaScriptNamespaceInterface("sdk");
    interface.setMethod("onPPTMediaPlay", this._onPPTMediaPlay);
    interface.setMethod("onPPTMediaPause", this._onPPTMediaPause);
    interface.setMethod('throwError', this._onThrowMessage);
    interface.setMethod('postMessage', this._onPostMessage);
    interface.setMethod('logger', this._onLogger);
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

  _onLogger(value) {
    print(value);
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

  // TODO Bad Smell Code
  Future<WhiteBoardRoom> joinRoom({
    @required RoomParams params,
    OnRoomStateChanged onRoomStateChanged,
    OnRoomPhaseChanged onRoomPhaseChanged,
    OnRoomDisconnected onRoomDisconnected,
    OnRoomKicked onRoomKicked,
    OnCanUndoStepsUpdate onCanUndoStepsUpdate,
    OnCanRedoStepsUpdate onCanRedoStepsUpdate,
    OnRoomError onRoomError,
  }) {
    var completer = Completer<WhiteBoardRoom>();
    dsBridge.callHandler("sdk.joinRoom", [params.toJson()], ([value]) {
      var room = WhiteBoardRoom(
          dsBridge: dsBridge,
          params: params,
          onRoomStateChanged: onRoomStateChanged,
          onRoomPhaseChanged: onRoomPhaseChanged,
          onRoomDisconnected: onRoomDisconnected,
          onRoomKicked: onRoomKicked,
          onCanUndoStepsUpdate: onCanUndoStepsUpdate,
          onCanRedoStepsUpdate: onCanRedoStepsUpdate,
          onRoomError: onRoomError);
      try {
        room._initStateWithJoinRoom(jsonDecode(value));
        completer.complete(room);
      } catch (e) {
        completer.completeError(e);
      }
      return room;
    });
    return completer.future;
  }

  Future<WhiteBoardPlayer> replayRoom(
    ReplayRoomParams params, {
    OnPlayerStateChanged onPlayerStateChanged,
    OnPlayerPhaseChanged onPlayerPhaseChanged,
    OnLoadFirstFrame onLoadFirstFrame,
    OnSliceChanged onSliceChanged,
    OnScheduleTimeChanged onScheduleTimeChanged,
    OnPlaybackError onPlaybackError,
  }) {
    var completer = Completer<WhiteBoardPlayer>();
    dsBridge.callHandler("sdk.replayRoom", [params.toJson()], ([returnValue]) {
      var replayRoom = WhiteBoardPlayer(
        dsBridge: dsBridge,
        params: params,
        onPlayerPhaseChanged: onPlayerPhaseChanged,
        onPlayerStateChanged: onPlayerStateChanged,
        onLoadFirstFrame: onLoadFirstFrame,
        onSliceChanged: onSliceChanged,
        onScheduleTimeChanged: onScheduleTimeChanged,
        onPlaybackError: onPlaybackError,
      );
      try {
        replayRoom.initTimeInfoWithReplayRoom(jsonDecode(returnValue));
        completer.complete(replayRoom);
      } catch (e) {
        completer.completeError(e);
      }
      return replayRoom;
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

  WhiteBoardDisplayer(this.dsBridge);

  scalePptToFit(String mode) {
    dsBridge.callHandler("${kDisplayerNamespace}scalePptToFit", [mode]);
  }

  scaleIframeToFit() {
    dsBridge.callHandler("${kDisplayerNamespace}scaleIframeToFit");
  }

  postIframeMessage(dynamic object) {
    dsBridge.callHandler("${kDisplayerNamespace}postMessage", [jsonEncode(object)]);
  }

  moveCamera(WhiteBoardCameraConfig config) {
    dsBridge.callHandler("${kDisplayerNamespace}moveCamera", [config.toJson()]);
  }

  moveCameraToContainer(RectangleConfig config) {
    dsBridge.callHandler("${kDisplayerNamespace}moveCameraToContain", [config.toJson()]);
  }

  refreshViewSize() {
    dsBridge.callHandler("${kDisplayerNamespace}refreshViewSize");
  }

  setBackgroundColor(Color color) {
    dsBridge.callHandler("${kDisplayerNamespace}setBackgroundColor",
        [color.red, color.green, color.blue, color.alpha], null);
  }

  setDisableCameraTransform(bool disable) {
    dsBridge.callHandler("${kDisplayerNamespace}setDisableCameraTransform", [disable]);
  }

  Future<bool> getDisableCameraTransform() async {
    var value = dsBridge.callHandler("${kDisplayerNamespace}getDisableCameraTransform", [], null);
    return value == 'true';
  }

  void setCameraBound(CameraBound cameraBound) {
    dsBridge.callHandler("${kDisplayerNamespace}setCameraBound", [cameraBound.toJson()]);
  }

  /// 转换白板上点的坐标。
  Future<WhiteBoardPoint> convertToPointInWorld(num x, num y) {
    var completer = Completer<WhiteBoardPoint>();
    dsBridge.callHandler("${kDisplayerNamespace}convertToPointInWorld", [x, y], ([value]) {
      completer.complete(WhiteBoardPoint.fromJson(jsonDecode(value)));
    });
    return completer.future;
  }

  Future<String> getScenePathType(String path) {
    var completer = Completer<String>();
    dsBridge.callHandler("${kDisplayerNamespace}convertToPointInWorld", [path], ([value]) {
      completer.complete(value);
    });
    return completer.future;
  }

  // TODO Test
  Future<Map<String, List<WhiteBoardScene>>> getEntireScenes(String path) {
    var completer = Completer<Map<String, List<WhiteBoardScene>>>();

    dsBridge.callHandler("${kDisplayerNamespace}entireScenes", [path], ([value]) {
      var data = (jsonDecode(value) as Map)?.map((k, v) {
            var convert = (v as List)?.map((e) => WhiteBoardScene()..fromJson(e))?.toList();
            return MapEntry<String, List<WhiteBoardScene>>(k, convert);
          }) ??
          {};
      completer.complete(data);
    });
    return completer.future;
  }
}

class WhiteBoardMemberState {
  List<int> strokeColor;
  num strokeWidth;
  num textSize;
  String currentApplianceName;
  String shapeType;

  WhiteBoardMemberState({
    String currentApplianceName,
    String shapeType,
    List<int> strokeColor,
    num strokeWidth,
    num textSize,
  }) {
    this.strokeColor = strokeColor;
    this.strokeWidth = strokeWidth;
    this.textSize = textSize;
    this.currentApplianceName = currentApplianceName;
    if (ApplianceName.shape == currentApplianceName && shapeType == null) {
      this.shapeType = ShapeType.triangle;
    }
    if (shapeType != null) {
      this.shapeType = shapeType;
      this.currentApplianceName = ApplianceName.shape;
    }
  }

  void fromJson(Map<String, dynamic> json) {
    strokeColor = (json["strokeColor"] as List)?.map<int>((e) => e as int)?.toList();
    strokeWidth = json["strokeWidth"];
    textSize = json["textSize"];
    shapeType = json["shapeType"];
    currentApplianceName = json["currentApplianceName"];
  }

  Map<String, dynamic> toJson() {
    return {
      "strokeColor": strokeColor,
      "strokeWidth": strokeWidth,
      "textSize": textSize,
      "shapeType": shapeType,
      "currentApplianceName": currentApplianceName,
    }..removeWhere((key, value) => value == null);
  }
}

/// Room Callbacks
typedef OnRoomStateChanged = void Function(WhiteBoardRoomState newState);
typedef OnRoomPhaseChanged = void Function(String phase);
typedef OnRoomDisconnected = void Function(String error);
typedef OnRoomKicked = void Function(String reason);
typedef OnCanUndoStepsUpdate = void Function(int stepNum);
typedef OnCanRedoStepsUpdate = void Function(int stepNum);
typedef OnRoomError = void Function(String error);

/// Playback Callbacks
typedef OnPlayerPhaseChanged = void Function(String phase);
typedef OnPlayerStateChanged = void Function(WhiteBoardPlayerState playerState);
typedef OnLoadFirstFrame = void Function();
typedef OnSliceChanged = void Function(String slice);
typedef OnScheduleTimeChanged = void Function(int scheduleTime);
typedef OnPlaybackError = void Function(String error);

class WhiteBoardPlayer extends WhiteBoardDisplayer {
  final ReplayRoomParams params;
  final DsBridge dsBridge;

  String tag = "WhiteBoardPlayer";

  ReplayTimeInfo replayTimeInfo = ReplayTimeInfo();
  String phase = WhiteBoardPlayerPhase.WaitingFirstFrame;
  int currentTime = 0;

  OnPlayerPhaseChanged onPlayerPhaseChanged;
  OnScheduleTimeChanged onScheduleTimeChanged;
  OnPlayerStateChanged onPlayerStateChanged;
  OnLoadFirstFrame onLoadFirstFrame;
  OnSliceChanged onSliceChanged;
  OnPlaybackError onPlaybackError;

  WhiteBoardPlayer(
      {this.params,
      this.dsBridge,
      this.onPlayerPhaseChanged,
      this.onPlayerStateChanged,
      this.onLoadFirstFrame,
      this.onScheduleTimeChanged,
      this.onSliceChanged,
      this.onPlaybackError})
      : super(dsBridge) {
    dsBridge.addJavascriptObject(this.createPlayerInterface());
  }

  JavaScriptNamespaceInterface createPlayerInterface() {
    var interface = JavaScriptNamespaceInterface("player");
    interface.setMethod("onPhaseChanged", this._onPhaseChanged);
    interface.setMethod("onPlayerStateChanged", this._onPlayerStateChanged);
    interface.setMethod("onLoadFirstFrame", this._onLoadFirstFrame);
    interface.setMethod("onScheduleTimeChanged", this._onScheduleTimeChanged);
    interface.setMethod("onStoppedWithError", this._onStoppedWithError);
    interface.setMethod("fireCatchErrorWhenAppendFrame", this._fireCatchErrorWhenAppendFrame);
    interface.setMethod("onCatchErrorWhenRender", this._onCatchErrorWhenRender);
    interface.setMethod("fireMagixEvent", this._fireMagixEvent);
    interface.setMethod("fireHighFrequencyEvent", this._fireHighFrequencyEvent);
    interface.setMethod("onSliceChanged", this._onSliceChanged);
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
    if (onPlayerStateChanged != null) {
      onPlayerStateChanged(WhiteBoardPlayerState()..fromJson(jsonDecode(value)));
    }
  }

  _onLoadFirstFrame(value) {
    print(value);
    if (onPlaybackError != null) {
      onPlaybackError(value);
    }
  }

  _onScheduleTimeChanged(value) {
    currentTime = value;
    if (onScheduleTimeChanged != null) {
      onScheduleTimeChanged(value);
    }
  }

  _onStoppedWithError(value) {
    print(value);
    if (onPlaybackError != null) {
      onPlaybackError(value);
    }
  }

  _fireCatchErrorWhenAppendFrame(value) {
    print(value);
    if (onPlaybackError != null) {
      onPlaybackError(value);
    }
  }

  _onCatchErrorWhenRender(value) {
    print(value);
    if (onPlaybackError != null) {
      onPlaybackError(value);
    }
  }

  _fireMagixEvent(value) {
    print(value);
  }

  _fireHighFrequencyEvent(value) {
    print(value);
  }

  _onSliceChanged(value) {
    print(value);
    if (onSliceChanged != null) {
      onSliceChanged(value);
    }
  }

  initTimeInfoWithReplayRoom(Map<String, dynamic> json) {
    replayTimeInfo = ReplayTimeInfo()..fromJson(json["timeInfo"]);
  }

  play() {
    dsBridge.callHandler("player.play");
  }

  stop() {
    dsBridge.callHandler("player.stop");
  }

  pause() {
    dsBridge.callHandler("player.pause");
  }

  seekToScheduleTime(double beginTime) {
    currentTime = beginTime.toInt();
    dsBridge.callHandler("player.seekToScheduleTime", [beginTime]);
  }

  /// 参数限定 PlayerObserverMode
  setObserverMode(String observerMode) {
    dsBridge.callHandler("player.setObserverMode", [observerMode]);
  }

  setPlaybackSpeed(double rate) {
    dsBridge.callHandler("player.setPlaybackSpeed", [rate]);
  }

  Future<double> get playbackSpeed async {
    var value = await dsBridge.callHandler("player.state.playbackSpeed");
    return double.tryParse(value);
  }

  Future<String> get roomUUID {
    return dsBridge.callHandler("player.state.roomUUID");
  }

  Future<String> getPhase() {
    return dsBridge.callHandler("player.state.phase");
  }

  Future<WhiteBoardPlayerState> get playerState async {
    var value = await dsBridge.callHandler("player.state.playerState");
    return WhiteBoardPlayerState()..fromJson(jsonDecode(value));
  }

  Future<bool> get isPlayable async {
    var value = await dsBridge.callHandler("player.state.isPlayable");
    return value == 'true';
  }

  Future<ReplayTimeInfo> get timeInfo async {
    var value = await dsBridge.callHandler("player.state.timeInfo");
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

  // TODO 状态增量同步处理
  WhiteBoardRoomState state = WhiteBoardRoomState();
  WhiteBoardRoomPhase phase = WhiteBoardRoomPhase();

  OnRoomStateChanged onRoomStateChanged;
  OnRoomPhaseChanged onRoomPhaseChanged;
  OnRoomDisconnected onRoomDisconnected;
  OnRoomKicked onRoomKicked;
  OnCanUndoStepsUpdate onCanUndoStepsUpdate;
  OnCanRedoStepsUpdate onCanRedoStepsUpdate;
  OnRoomError onRoomError;

  int observerId;
  int timeDelay;
  bool disconnectedBySelf = false;
  bool writable = false;

  WhiteBoardRoom(
      {@required this.params,
      @required this.dsBridge,
      this.onRoomStateChanged,
      this.onRoomPhaseChanged,
      this.onRoomDisconnected,
      this.onRoomKicked,
      this.onCanUndoStepsUpdate,
      this.onCanRedoStepsUpdate,
      this.onRoomError})
      : super(dsBridge) {
    dsBridge.addJavascriptObject(this.createRoomInterface());
  }

  JavaScriptNamespaceInterface createRoomInterface() {
    var interface = JavaScriptNamespaceInterface("room");
    interface.setMethod("firePhaseChanged", this._firePhaseChanged);
    interface.setMethod("fireCanUndoStepsUpdate", this._fireCanUndoStepsUpdate);
    interface.setMethod("fireCanRedoStepsUpdate", this._fireCanRedoStepsUpdate);
    interface.setMethod("fireRoomStateChanged", this._fireRoomStateChanged);
    interface.setMethod("fireDisconnectWithError", this._fireDisconnectWithError);
    interface.setMethod("fireKickedWithReason", this._fireKickedWithReason);
    interface.setMethod("fireCatchErrorWhenAppendFrame", this._fireCatchErrorWhenAppendFrame);
    interface.setMethod("fireMagixEvent", this._fireMagixEvent);
    interface.setMethod("fireHighFrequencyEvent", this._fireHighFrequencyEvent);
    return interface;
  }

  _firePhaseChanged(String value) {
    phase.value = value;
    if (onRoomPhaseChanged != null) onRoomPhaseChanged(value);
  }

  _fireCanUndoStepsUpdate(value) {
    print(value);
    if (onCanUndoStepsUpdate != null) onCanUndoStepsUpdate(value);
  }

  _fireCanRedoStepsUpdate(value) {
    print(value);
    if (onCanRedoStepsUpdate != null) onCanRedoStepsUpdate(value);
  }

  _fireRoomStateChanged(String value) {
    try {
      var data = jsonDecode(value) as Map<String, dynamic>;
      state.fromJson((<String, dynamic>{})..addAll(state?.toJson())..addAll(data));
      if (onRoomStateChanged != null) onRoomStateChanged(state);
    } catch (e) {
      print(e);
    }
  }

  _fireDisconnectWithError(value) {
    print(value);
    if (onRoomDisconnected != null) onRoomDisconnected(value);
  }

  _fireKickedWithReason(value) {
    print(value);
    if (onRoomKicked != null) onRoomKicked(value);
  }

  _fireCatchErrorWhenAppendFrame(value) {
    print(value);
    if (onRoomError != null) onRoomError(value);
  }

  // TODO Support Custom Event
  _fireMagixEvent(value) {
    print(value);
  }

  _fireHighFrequencyEvent(value) {
    print(value);
  }

  bool isDisconnectedBySelf() {
    return disconnectedBySelf;
  }

  _initStateWithJoinRoom(Map<String, dynamic> json) {
    state = WhiteBoardRoomState()..fromJson(json["state"]);
  }

  setGlobalState(WhiteBoardGlobalState modifyState) {
    dsBridge.callHandler("room.setGlobalState", [modifyState.toJson()]);
  }

  Future<T> getGlobalState<T extends WhiteBoardGlobalState>(GlobalStateParser<T> parser) {
    var completer = Completer<T>();
    dsBridge.callHandler("room.getGlobalState", [], ([value]) {
      completer.complete(parser(jsonDecode(value)));
    });
    return completer.future;
  }

  setMemberState(WhiteBoardMemberState state) {
    dsBridge.callHandler('room.setMemberState', [state.toJson()]);
  }

  Future<WhiteBoardMemberState> getMemberState() {
    var completer = Completer<WhiteBoardMemberState>();
    dsBridge.callHandler("room.getMemberState", [], ([value]) {
      completer.complete(WhiteBoardMemberState()..fromJson(jsonDecode(value)));
    });
    return completer.future;
  }

  Future<List<WhiteBoardRoomMember>> getRoomMembers() {
    var completer = Completer<List<WhiteBoardRoomMember>>();
    dsBridge.callHandler("room.getRoomMembers", [], ([value]) {
      var members = (json.decode(value) as List)
          ?.map((jsonMap) => WhiteBoardRoomMember.fromJson(jsonMap))
          ?.toList();
      completer.complete(members);
    });
    return completer.future;
  }

  void setViewMode(WhiteBoardViewMode viewMode) {
    dsBridge.callHandler("room.setViewMode", [viewModeToJson(viewMode)]);
  }

  String viewModeToJson(WhiteBoardViewMode viewMode) {
    var viewModeString;
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
    return viewModeString;
  }

  WhiteBoardViewMode viewModeFromJson(String json) {
    WhiteBoardViewMode viewMode;
    switch (json) {
      case "freedom":
        viewMode = WhiteBoardViewMode.Freedom;
        break;
      case "follower":
        viewMode = WhiteBoardViewMode.Follower;
        break;
      case "broadcaster":
        viewMode = WhiteBoardViewMode.Broadcaster;
        break;
      default:
        viewMode = WhiteBoardViewMode.Freedom;
        break;
    }
    return viewMode;
  }

  Future<WhiteBoardBroadcastState> getBroadcastState() {
    var completer = Completer<WhiteBoardBroadcastState>();
    dsBridge.callHandler('room.getBroadcastState', [], ([value]) {
      var data = WhiteBoardBroadcastState.fromJson(jsonDecode(value));
      completer.complete(data);
    });
    return completer.future;
  }

  WhiteBoardRoomState getRoomStateNative() {
    return state;
  }

  Future<WhiteBoardRoomState> getRoomState() {
    var completer = Completer<WhiteBoardRoomState>();
    dsBridge.callHandler("room.state.getRoomState", [], ([value]) {
      var data = WhiteBoardRoomState()..fromJson(value);
      completer.complete(data);
    });
    return completer.future;
  }

  String getRoomPhaseNative() {
    return phase.value;
  }

  Future<String> getRoomPhase() {
    var completer = Completer<String>();
    dsBridge.callHandler("room.getRoomPhase", [], ([value]) {
      completer.complete(value);
    });
    return completer.future;
  }

  Future<bool> disconnect() {
    disconnectedBySelf = true;
    var completer = Completer<bool>();
    dsBridge.callHandler('room.disconnect', [], ([value]) {
      if (value == null) {
        completer.complete(true);
      } else {
        completer.completeError(value);
      }
    });
    return completer.future;
  }

  set disableOperations(bool value) {
    disableCameraTransform = value;
    disableDeviceInputs = value;
  }

  set disableCameraTransform(bool value) {
    dsBridge.callHandler("room.disableCameraTransform", [value]);
  }

  set disableDeviceInputs(bool value) {
    dsBridge.callHandler("room.disableDeviceInputs", [value]);
  }

  void disableEraseImage(bool value) {
    dsBridge.callHandler("room.sync.disableEraseImage", [value]);
  }

  bool getWritable() {
    return writable;
  }

  int getObserverId() {
    return observerId;
  }

  void _setWritable(bool writable) {
    this.writable = writable;
  }

  void _setObserverId(int observerId) {
    this.observerId = observerId;
  }

  Future<bool> setWritable(bool writable) {
    var completer = Completer<bool>();
    dsBridge.callHandler("room.setWritable", [writable], ([value]) {
      bool isWritable = jsonDecode(value)['isWritable'];
      int observerId = jsonDecode(value)['observerId'];

      _setWritable(isWritable);
      _setObserverId(observerId);

      completer.complete(isWritable);
    });
    return completer.future;
  }

  Future<Map<String, dynamic>> debugInfo() {
    var completer = Completer<Map<String, dynamic>>();
    dsBridge.callHandler("room.state.debugInfo", [], ([value]) {
      completer.complete(jsonDecode(value));
    });
    return completer.future;
  }

  pptNextStep() {
    dsBridge.callHandler("ppt.nextStep");
  }

  pptPreviousStep() {
    dsBridge.callHandler("ppt.previousStep");
  }

  Future<Map<String, dynamic>> putScenes(String dir, List<WhiteBoardScene> scene, int index) {
    var completer = Completer<Map<String, dynamic>>();
    dsBridge.callHandler("room.putScenes", [dir, scene.map((e) => e.toJson()).toList(), index], (
        [value]) {
      completer.complete(jsonDecode(value));
    });
    return completer.future;
  }

  /// 切换至指定的场景。
  /// <p>
  /// 方法调用成功后，房间内的所有用户看到的白板都会切换到指定场景。
  /// <p>
  /// 场景切换失败可能有以下原因：
  /// - 路径不合法，请确保场景路径以 "/"，由场景组和场景名构成。
  /// - 场景路径对应的场景不存在。
  /// - 传入的路径是场景组的路径，而不是场景路径。
  ///
  /// @param path    想要切换到的场景的场景路径，请确保场景路径以 "/"，由场景组和场景名构成，例如，`/math/classA`.
  /// @param promise `Promise<Boolean>` 接口，详见 {@link Promise<> Promise<T>}。你可以通过该接口获取 `setScenePath` 的调用结果：
  ///                - 如果方法调用成功，则返回 `true`.
  ///                - 如果方法调用失败，则返回错误信息。
  Future<bool> setScenePath(String path) {
    var completer = Completer<bool>();
    dsBridge.callHandler("room.setScenePath", [path], ([value]) {
      var jsonMap = jsonDecode(value);
      if (jsonMap['__error'] == null)
        completer.complete(true);
      else
        completer.completeError(jsonMap);
    });
    return completer.future;
  }

  /// 切换至当前场景组下的指定场景。
  /// <p>
  /// 方法调用成功后，房间内的所有用户看到的白板都会切换到指定场景。
  /// 指定的场景必须在当前场景组中，否则，方法调用会失败。
  ///
  /// @param index   目标场景在当前场景组下的索引号。
  /// @param promise `Promise<Boolean>` 接口，详见 {@link Promise<> Promise<T>}。你可以通过该接口获取 `setSceneIndex` 的调用结果：
  ///                - 如果方法调用成功，则返回 `true`.
  ///                - 如果方法调用失败，则返回错误信息。
  Future<bool> setSceneIndex(int index) async {
    var completer = Completer<bool>();
    dsBridge.callHandler("room.setSceneIndex", [index], ([value]) {
      var jsonMap = jsonDecode(value);
      if (jsonMap['__error'] == null)
        completer.complete(true);
      else
        completer.completeError(jsonMap);
    });
    return completer.future;
  }

  /// 移动场景。
  /// <p>
  /// 成功移动场景后，场景路径也会改变。
  ///
  /// @param sourcePath      需要移动的场景原路径。必须为场景路径，不能是场景组的路径。
  /// @param targetDirOrPath 目标场景组路径或目标场景路径：
  ///                        - 当 `targetDirOrPath`设置为目标场景组时，表示将指定场景移至其他场景组中，场景路径会发生改变，但是场景名称不变。
  ///                        - 当 `targetDirOrPath`设置为目标场景路径时，表示改变指定场景在当前场景组的位置，场景路径和场景名都会发生改变。
  /// @note - 该方法只能移动场景，不能移动场景组，即 `sourcePath` 只能是场景路径，不能是场景组路径。
  /// - 该方法支持改变指定场景在当前所属场景组下的位置，也支持将指定场景移至其他场景组。
  void moveScene(String sourcePath, String targetDirOrPath) {
    dsBridge.callHandler("room.moveScene", [sourcePath, targetDirOrPath]);
  }

  /// 删除场景或者场景组。
  ///
  /// @param dirOrPath 场景组路径或者场景路径。如果传入的是场景组，则会删除该场景组下的所有场景。
  /// @note - 互动白板实时房间内必须至少有一个场景。当删除所有的场景后，SDK 会自动生成一个路径为 `/init` 初始场景（房间初始化时的默认场景）。
  /// - 如果删除白板当前所在场景，白板会展示被删除场景所在场景组的最后一个场景
  /// - 如果删除的是场景组，则该场景组下的所有场景都会被删除。
  /// - 如果删除的是当前场景所在的场景组 dirA，SDK 会向上递归，寻找与该场景组同级的场景组：
  /// 1. 如果上一级目录中，还有其他场景目录 dirB（可映射文件夹概念），排在被删除的场景目录 dirA 后面，则当前场景会变成
  /// dirB 中的第一个场景（index 为 0）；
  /// 2. 如果上一级目录中，在 dirA 后不存在场景目录，则查看当前目录是否存在场景；
  /// 如果存在，则该场景成为当前目录（index 为 0 的场景目录）。
  /// 3. 如果上一级目录中，dirA 后没有场景目录，当前上一级目录，也不存在任何场景；
  /// 则查看是否 dirA 前面是否存在场景目录 dirC，选择 dir C 中的第一顺位场景
  /// 4. 以上都不满足，则继续向上递归执行该逻辑。
  removeScenes(String dirOrPath) {
    dsBridge.callHandler("room.removeScenes", [dirOrPath]);
  }

  Future<List<WhiteBoardScene>> getScenes() {
    var completer = Completer<List<WhiteBoardScene>>();
    dsBridge.callHandler("room.getSceneState", [], ([value]) {
      var data = (jsonDecode(value) as List)
          ?.map((itemMap) => WhiteBoardScene()..fromJson(itemMap))
          ?.toList();
      completer.complete(data);
    });
    return completer.future;
  }

  Future<WhiteBoardSceneState> getSceneState() {
    var completer = Completer<WhiteBoardSceneState>();
    dsBridge.callHandler("room.getSceneState", [], ([value]) {
      var data = WhiteBoardSceneState()..fromJson(jsonDecode(value));
      completer.complete(data);
    });
    return completer.future;
  }

  cleanScene(bool retainPPT) {
    dsBridge.callHandler("room.cleanScene", [retainPPT]);
  }

  // 绑定uuid 与 url
  void completeImageUpload(String uuid, String url) {
    dsBridge.callHandler("room.completeImageUpload", [uuid, url]);
  }

  /// 插入图片显示区域
  void insertImage(ImageInformation imageInfo) {
    dsBridge.callHandler("room.insertImage", [imageInfo.toJson()]);
  }

  // 有SDK生成uuid并插入图片
  void insertImageByUrl(ImageInformation imageInfo, String url) {
    var uuid = _asUuidV4();
    imageInfo.uuid = uuid;
    dsBridge.callHandler("room.insertImage", [imageInfo.toJson()]);
    dsBridge.callHandler("room.completeImageUpload", [uuid, url]);
  }

  String _asUuidV4() {
    Random random = new Random();
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
        .runes
        .map((e) {
          var r = random.nextInt(15);
          String c = String.fromCharCode(e);
          // return String.fromCharCode(e) == 'x';
          return c == 'x'
              ? r.toRadixString(16)
              : (c == 'y' ? (r & 0x3 | 0x8).toRadixString(16) : c);
        })
        .toList()
        .join();
  }

  /// 开启/禁止本地序列化。
  /// @param disable 是否禁止本地序列化：
  ///                - `true`：（默认）禁止开启本地序列化；
  ///                - `false`： 开启本地序列化，即可以对本地操作进行解析。
  /// 设置 `disableSerialization(true)` 后，以下方法将不生效：
  /// - `redo`
  /// - `undo`
  /// - `duplicate`
  /// - `copy`
  /// - `paste`
  void disableSerialization(bool disable) {
    dsBridge.callHandler('room.sync.disableSerialization', [disable]);
  }

  /// 复制选中内容。
  void copy() {
    dsBridge.callHandler('room.sync.copy');
  }

  /// 粘贴复制的内容。
  void paste() {
    dsBridge.callHandler('room.sync.paste');
  }

  /// 复制并粘贴选中的内容。
  void duplicate() {
    dsBridge.callHandler('room.sync.duplicate');
  }

  /// 撤销上一步操作。
  void undo() {
    dsBridge.callHandler('room.undo');
  }

  /// 重做，即回退撤销操作。
  void redo() {
    dsBridge.callHandler('room.redo');
  }

  /// 删除选中的内容。
  void delete() {
    dsBridge.callHandler("room.sync.delete");
  }

  /// 同步时间戳。
  void syncBlockTimestamp(int utcMs) {
    dsBridge.callHandler("room.sync.syncBlockTimstamp", [utcMs]);
  }

  /// 发送自定义事件。
  void dispatchMagixEvent(AkkoEvent eventEntry) {
    dsBridge.callHandler("room.dispatchMagixEvent", [eventEntry.toJson()]);
  }

  /// 设置远端白板画面同步延时。单位为秒。
  void setTimeDelay(int delaySec) {
    dsBridge.callHandler("room.setTimeDelay", [delaySec * 1000]);
    this.timeDelay = delaySec;
  }

  /// 获取设置得远端白板画面同步延时。单位为秒。
  int getTimeDelay() {
    return this.timeDelay;
  }

  /// 获取当前用户的视野缩放比例。
  Future<num> getZoomScale() {
    var completer = Completer<num>();
    dsBridge.callHandler("room.getZoomScale", [], ([value]) {
      completer.complete(value);
    });
    return completer.future;
  }
}

class WhiteBoardDisplayerState {
  WhiteBoardGlobalState globalState;
  var globalStateParser;
  WhiteBoardSceneState sceneState;
  WhiteBoardCameraConfig cameraState;
  List<WhiteBoardRoomMember> roomMembers;

  void setCustomGlobalStateParser<T>(GlobalStateParser<T> parser) {
    this.globalStateParser = parser;
  }

  parseGlobalState(Map<String, dynamic> state) {
    return globalStateParser != null ? globalStateParser(state) : null;
  }
}

class WhiteBoardPlayerState extends WhiteBoardDisplayerState {
  String observerMode;

  void fromJson(Map<String, dynamic> json) {
    observerMode = json["observerMode"];
    roomMembers = (json["roomMembers"] as List)
        ?.map<WhiteBoardRoomMember>((e) => WhiteBoardRoomMember.fromJson(e))
        ?.toList();
    cameraState = WhiteBoardCameraConfig()..fromJson(json["cameraState"]);
    globalState = parseGlobalState(json['globalState']);
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
    broadcastState = WhiteBoardBroadcastState.fromJson(json["broadcastState"]);
    zoomScale = json["zoomScale"];
    roomMembers = (json["roomMembers"] as List)
        ?.map<WhiteBoardRoomMember>((jsonMap) => WhiteBoardRoomMember.fromJson(jsonMap))
        ?.toList();
    cameraState = WhiteBoardCameraConfig()..fromJson(json["cameraState"]);
    globalState = parseGlobalState(json["globalState"]);
    sceneState = WhiteBoardSceneState()..fromJson(json["sceneState"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "memberState": memberState.toJson(),
      "broadcastState": broadcastState.toJson(),
      "zoomScale": zoomScale,
      "roomMembers": roomMembers.map((e) => e.toJson()).toList(),
      "cameraState": cameraState.toJson(),
      if (globalState != null) "globalState": globalState.toJson(),
      "sceneState": sceneState.toJson(),
    };
  }
}

typedef T GlobalStateParser<T>(Map<String, dynamic> jsonMap);

abstract class WhiteBoardGlobalState {
  Map<String, dynamic> toJson();

  void fromJson(Map<String, dynamic> json);
}

class WhiteBoardRoomMember {
  int memberId;
  WhiteBoardMemberState memberState;
  String session;
  dynamic payload;

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
      "payload": payload
    };
  }

  WhiteBoardRoomMember.fromJson(Map<String, dynamic> json) {
    memberId = json["memberId"];
    memberState = WhiteBoardMemberState()..fromJson(json["memberState"]);
    session = json["session"];
    payload = json["payload"];
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
  /// 铅笔。
  static const pencil = "pencil";

  /// 选择工具。
  static const selector = "selector";

  /// 激光笔。
  static const laserPointer = "laserPointer";

  /// 矩形工具。
  static const rectangle = "rectangle";

  /// 椭圆工具。
  static const ellipse = "ellipse";

  /// 橡皮工具。
  static const eraser = "eraser";

  /// 文本输入框。
  static const text = "text";

  /// 直线工具。
  static const straight = "straight";

  /// 箭头工具。
  static const arrow = "arrow";

  /// 抓手工具。
  static const hand = "hand";

  /// 点击
  static const clicker = "clicker";

  /// 形状
  static const shape = "shape";
}

class WhiteBoardBroadcastState {
  String mode;
  int broadcasterId;
  WhiteBoardRoomMember broadcasterInformation;

  WhiteBoardBroadcastState.fromJson(Map<String, dynamic> json) {
    mode = json["mode"];
    broadcasterId = json["broadcasterId"];
    broadcasterInformation = json["broadcasterInformation"] != null
        ? WhiteBoardRoomMember.fromJson(json["broadcasterInformation"])
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      "mode": mode,
      "broadcasterId": broadcasterId,
      "broadcasterInformation": broadcasterInformation,
    };
  }
}

class ScenePathType {
  static const empty = "none";
  static const page = "page";
  static const dir = "dir";
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
  /// 连接中。
  static const String connecting = "connecting";

  /// 已连接，
  static const String connected = "connected";

  /// 正在重连。
  static const String reconnecting = "reconnecting";

  /// 正在断开连接。
  static const String disconnecting = "disconnecting";

  /// 已经断开连接。
  static const String disconnected = "disconnected";

  String value = WhiteBoardRoomPhase.disconnected;
}

class ShapeType {
  /// 三角形（默认）
  static const String triangle = "triangle";

  /// 菱形
  static const String rhombus = "rhombus";

  /// 五角星
  static const String pentagram = "pentagram";

  /// 说话泡泡
  static const String speechBalloon = "speechBalloon";
}

// TODO 历史遗留问题，正反序列化处理区别
enum WhiteBoardViewMode {
  Freedom,
  Follower,
  Broadcaster,
}

class WhiteBoardScene {
  String name;
  WhiteBoardPpt ppt;

  WhiteBoardScene({this.name, this.ppt});

  void fromJson(Map<String, dynamic> json) {
    name = json["name"];
    ppt = json["ppt"] != null ? (WhiteBoardPpt.fromJson(json["ppt"])) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      if (ppt != null) "ppt": ppt.toJson(),
    };
  }
}

class WhiteBoardPpt {
  String src;
  int width;
  int height;
  String previewURL;

  WhiteBoardPpt({this.src, this.width, this.height, this.previewURL});

  WhiteBoardPpt.fromJson(Map<String, dynamic> json) {
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
    }..removeWhere((key, value) => value == null);
  }
}

class AnimationMode {
  static const Continuous = "continuous";
  static const Immediately = "immediately";
}

class WhiteBoardSdkConfiguration {
  final String appIdentifier;
  final String region;
  final String deviceType;
  final String renderEngine;
  final Color backgroundColor;
  final bool log;
  final bool enableInterrupterAPI;
  final bool preloadDynamicPPT;
  final bool routeBackup;
  final bool userCursor;
  final bool onlyCallbackRemoteStateModify;
  final bool disableDeviceInputs;
  final bool enableIFramePlugin;
  final bool enableRtcIntercept;
  final bool enableImgErrorCallback;

  PptParams pptParams = PptParams();
  Map<String, String> fonts = {};

  WhiteBoardSdkConfiguration({
    this.appIdentifier,
    this.log,
    this.backgroundColor,
    this.region,
    this.deviceType,
    this.renderEngine = RenderEngineType.canvas,
    this.enableInterrupterAPI = false,
    this.preloadDynamicPPT = false,
    this.routeBackup = false,
    this.userCursor = false,
    this.onlyCallbackRemoteStateModify = false,
    this.disableDeviceInputs = false,
    this.enableIFramePlugin = false,
    this.enableRtcIntercept = false,
    this.enableImgErrorCallback = false,
    this.pptParams,
    this.fonts,
  });

  Map<String, dynamic> toJson() {
    return {
      "appIdentifier": appIdentifier,
      "region": region,
      "deviceType": deviceType,
      "renderEngine": renderEngine,
      "enableInterrupterAPI": enableInterrupterAPI,
      "preloadDynamicPPT": preloadDynamicPPT,
      "routeBackup": routeBackup,
      "userCursor": userCursor,
      "onlyCallbackRemoteStateModify": onlyCallbackRemoteStateModify,
      "disableDeviceInputs": disableDeviceInputs,
      "enableIFramePlugin": enableIFramePlugin,
      "enableRtcIntercept": enableRtcIntercept,
      "enableImgErrorCallback": enableImgErrorCallback,
      "pptParams": pptParams,
      "fonts": fonts,
      "log": log,
    }..removeWhere((key, value) => value == null);
  }
}

abstract class RoomParams {
  Map<String, dynamic> toJson();
}

class JoinRoomParams extends RoomParams {
  final String uuid;
  final String roomToken;

  /// 数据中心。
  final String region;

  /// 视角边界。
  final CameraBound cameraBound;

  /// 重连时，最大重连尝试时间，单位：毫秒，默认 45 秒。
  int timeout = 45000;

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

  /// 关闭笔锋效果。
  final bool disableNewPencil;

  /// 用户配置
  dynamic userPayload;

  JoinRoomParams({
    this.uuid,
    this.roomToken,
    this.region,
    this.cameraBound,
    this.timeout,
    this.isWritable = true,
    this.disableEraseImage = false,
    this.disableDeviceInputs = false,
    this.disableOperations = false,
    this.disableCameraTransform = false,
    this.disableBezier = false,
    this.disableNewPencil = false,
    this.userPayload,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "uuid": uuid,
      "roomToken": roomToken,
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
      "userPayload": jsonEncode(userPayload),
    }..removeWhere((key, value) => value == null);
  }
}

class ReplayRoomParams extends RoomParams {
  final String room;
  final String roomToken;
  final String mediaURL;
  final int beginTimestamp;
  final int duration;
  CameraBound cameraBound;
  String region;
  String slice;

  /// 回调播放进度的频率 默认500ms
  int step = 500;

  ReplayRoomParams(
      {this.room,
      this.roomToken,
      this.mediaURL,
      this.beginTimestamp,
      this.duration,
      this.region,
      this.step});

  @override
  Map<String, dynamic> toJson() {
    return {
      "room": room,
      "roomToken": roomToken,

      /// 此处mediaURL不传入SDK，会有问题
      // "mediaURL": mediaURL,
      "beginTimestamp": beginTimestamp,
      "duration": duration,
      if (cameraBound != null) "cameraBound": cameraBound.toJson(),
      "region": region,
      "slice": slice,
    }..removeWhere((key, value) => value == null);
  }
}

class WhiteBoardCameraConfig {
  num centerX;
  num centerY;
  num scale;
  String animationMode;

  WhiteBoardCameraConfig({this.centerX = 0, this.centerY = 0, this.scale, this.animationMode});

  Map<String, dynamic> toJson() {
    return {"centerX": centerX, "centerY": centerY, "scale": scale, "animationMode": animationMode};
  }

  void fromJson(Map<String, dynamic> json) {
    centerX = json["centerX"];
    centerY = json["centerY"];
    scale = json["scale"];
    animationMode = json["animationMode"];
  }
}

class RectangleConfig {
  final num width;
  final num height;
  final num centerX;
  final num centerY;
  final String animationMode;

  RectangleConfig(num width, num height, num centerX, num centerY,
      [String animationMode = AnimationMode.Continuous])
      : width = width,
        height = height,
        centerX = centerX,
        centerY = centerX,
        animationMode = animationMode;

  RectangleConfig.fromSize(num width, num height, [String animationMode = AnimationMode.Continuous])
      : width = width,
        height = height,
        centerX = -width / 2.0,
        centerY = -height / 2.0,
        animationMode = animationMode;

  Map<String, dynamic> toJson() => {
        'width': width,
        'height': height,
        'centerX': centerX,
        'centerY': centerY,
        'animationMode': animationMode,
      };
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

/// 数据中心。
class Region {
  /// 中国杭州。
  static const String cn_hz = 'cn-hz';

  /// 美国硅谷。
  static const String us_sv = 'us-sv';

  /// 新加坡。
  static const String sg = 'sg';

  /// 印度孟买。
  static const String in_mum = 'in-mum';

  /// 英国伦敦。
  static const String gb_lon = 'gb-lon';
}

class CameraBound {
  /// 用户将视角移出视角边界时感受到的阻力
  final num damping;

  /// 视角边界的中心点在世界坐标系（以白板初始化时的中心点为原点的坐标系）中的 X 轴坐标。
  final num centerX;

  /// 视角边界的中心点在世界坐标系（以白板初始化时的中心点为原点的坐标系）中的 Y 轴坐标。
  final num centerY;

  /// 视角边界的宽度。
  final num width;

  /// 视角边界的高度。
  final num height;
  final ContentModeConfig maxContentMode;
  final ContentModeConfig minContentMode;

  CameraBound(
      {this.damping, this.centerX, this.centerY, this.width, this.height, minScale, maxScale})
      : this.minContentMode = ContentModeConfig(scale: minScale),
        this.maxContentMode = ContentModeConfig(scale: maxScale);

  CameraBound.withContentModeConfig(
      {this.damping,
      this.centerX,
      this.centerY,
      this.width,
      this.height,
      this.minContentMode,
      this.maxContentMode});

  Map<String, dynamic> toJson() {
    return {
      "damping": damping,
      "centerX": centerX,
      "centerY": centerY,
      "width": width,
      "height": height,
      "maxContentMode": maxContentMode.toJson(),
      "minContentMode": minContentMode.toJson(),
    };
  }
}

/// 视角边界的缩放模式和缩放比例。
class ContentModeConfig {
  /// 视角边界的缩放比例
  final num scale;

  /// 四周填充的空白空间,单位为像素
  final num space;
  final String mode;

  ContentModeConfig({this.scale = 1, this.space = 0, this.mode = ScaleMode.scale});

  Map<String, dynamic> toJson() {
    return {
      "scale": scale,
      "space": space,
      "mode": mode,
    };
  }
}

class ScaleMode {
  /// （默认）基于设置的 `scale` 缩放视角边界。
  static const scale = 'Scale';

  /// 等比例缩放视角边界，使视角边界的长边正好顶住与其垂直的屏幕的两边，以保证在屏幕上完整展示视角边界。
  static const aspectFit = 'AspectFit';

  /// 等比例缩放视角边界，使视角边界的长边正好顶住与其垂直的屏幕的两边，以保证在屏幕上完整展示视角边界；在此基础上，再将视角边界缩放指定的倍数。
  static const aspectFitScale = 'AspectFitScale';

  /// 等比例缩放视角边界，使视角边界的长边正好顶住与其垂直的屏幕的两边；在此基础上，在视角边界的四周填充指定的空白空间。
  static const aspectFitSpace = 'AspectFitSpace';

  /// 等比例缩放视角边界，使视角边界的短边正好顶住与其垂直的屏幕的两边，以保证视角边界铺满屏幕。
  static const aspectFill = 'AspectFill';

  /// 等比例缩放视角边界，使视角边界的短边正好顶住与其垂直的屏幕的两边，以保证视角边界铺满屏幕；在此基础上再将视角边界缩放指定的倍数。
  static const aspectFillScale = 'AspectFillScale';
}

class AkkoEvent {
  String eventName;
  var payload;

  AkkoEvent(this.eventName, this.payload);

  Map<String, dynamic> toJson() {
    return {"eventName": eventName, "payload": jsonEncode(payload)};
  }
}

class ImageInformation {
  String uuid;
  num centerX;
  num centerY;
  num width;
  num height;

  /// 设置锁定图片。
  bool locked;

  ImageInformation({this.uuid, this.centerX, this.centerY, this.width, this.height, this.locked});

  Map<String, dynamic> toJson() {
    return {
      "uuid": uuid,
      "centerX": centerX,
      "centerY": centerY,
      "width": width,
      "height": height,
      "locked": locked,
    }..removeWhere((key, value) => value == null);
  }
}

class WhiteBoardPoint {
  num x;
  num y;

  WhiteBoardPoint(this.x, this.y);

  WhiteBoardPoint.fromJson(Map<String, dynamic> jsonMap) {
    x = jsonMap["x"];
    y = jsonMap["y"];
  }
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

class RenderEngineType {
  /// SVG 渲染模式。
  static const svg = "svg";

  /// Canvas 渲染模式。
  static const canvas = "canvas";
}

class PptParams {
  /// 更改动态 ppt 请求时的请求协议，可以将 https://www.exmaple.com/1.pptx 更改成 scheme://www.example.com/1.pptx
  String scheme;

  /// 开启/关闭动态 PPT 服务端排版功能
  bool useServerWrap;

  PptParams({this.scheme, this.useServerWrap = true});

  Map<String, dynamic> toJson() {
    return {
      "scheme": scheme,
      "useServerWrap": useServerWrap,
    }..removeWhere((key, value) => value == null);
  }
}

class DeviceType {
  static const desktop = "desktop";
  static const touch = "touch";
}
