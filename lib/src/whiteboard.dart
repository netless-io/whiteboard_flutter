import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:whiteboard_sdk_flutter/src/bridge_webview.dart';

import 'bridge.dart';
import 'bridge_inapp_webview.dart';
import 'types/types.dart';

class WhiteboardView extends StatelessWidget {
  final WhiteOptions options;
  final SdkCreatedCallback onSdkCreated;
  final SdkOnLoggerCallback? onLogger;
  final bool useBasicWebView;

  static GlobalKey<DsBridgeInAppWebViewState> inAppWebView =
      GlobalKey<DsBridgeInAppWebViewState>();
  static GlobalKey<DsBridgeWebViewState> webView =
      GlobalKey<DsBridgeWebViewState>();

  WhiteboardView({
    Key? key,
    required this.options,
    required this.onSdkCreated,
    this.onLogger,
    this.useBasicWebView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (useBasicWebView) {
      return DsBridgeWebView(
        key: webView,
        url: "about:blank",
        onDSBridgeCreated: onDSBridgeCreated,
      );
    } else {
      return DsBridgeInAppWebView(
        key: inAppWebView,
        url: "about:blank",
        onDSBridgeCreated: onDSBridgeCreated,
      );
    }
  }

  void onDSBridgeCreated(DsBridge dsBridge) {
    dsBridge.addJavascriptObject(this.createSDKInterface());
    onSdkCreated(WhiteSdk(options: options, dsBridge: dsBridge));
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
    onLogger?.call(value);
  }
}

class WhiteSdk {
  static const String tag = "WhiteSdk";

  final DsBridge dsBridge;
  final WhiteOptions options;

  Future<WhiteReplay> joinReplay({
    required ReplayOptions options,
    PlayerStateChangedCallback? onPlayerStateChanged,
    PlayerPhaseChangedCallback? onPlayerPhaseChanged,
    FirstFrameLoadedCallback? onLoadFirstFrame,
    ScheduleTimeChangedCallback? onScheduleTimeChanged,
    PlaybackErrorCallback? onPlaybackError,
  }) {
    var completer = Completer<WhiteReplay>();
    dsBridge.callHandler("sdk.replayRoom", [options.toJson()], ([value]) {
      var replayRoom = WhiteReplay(
        dsBridge: dsBridge,
        params: options,
        onPlayerPhaseChanged: onPlayerPhaseChanged,
        onPlayerStateChanged: onPlayerStateChanged,
        onLoadFirstFrame: onLoadFirstFrame,
        onScheduleTimeChanged: onScheduleTimeChanged,
        onPlaybackError: onPlaybackError,
      );
      try {
        replayRoom.initTimeInfoWithReplayRoom(jsonDecode(value));
        completer.complete(replayRoom);
      } catch (e) {
        completer.completeError(e);
      }
    });
    return completer.future;
  }

  WhiteSdk({required this.options, required this.dsBridge}) {
    dsBridge.callHandler("sdk.newWhiteSdk", [options.toJson()], null);
    setBackgroundColor(options.backgroundColor);
  }

  Future<WhiteRoom> joinRoom({
    required RoomOptions options,
    RoomStateChangedCallback? onRoomStateChanged,
    RoomPhaseChangedCallback? onRoomPhaseChanged,
    RoomDisconnectedCallback? onRoomDisconnected,
    RoomKickedCallback? onRoomKicked,
    UndoStepsUpdatedCallback? onCanUndoStepsUpdate,
    RedoStepsUpdatedCallback? onCanRedoStepsUpdate,
    RoomErrorCallback? onRoomError,
  }) {
    var completer = Completer<WhiteRoom>();
    dsBridge.callHandler("sdk.joinRoom", [options.toJson()], ([value]) {
      var room = WhiteRoom(
        dsBridge: dsBridge,
        options: options,
        onRoomStateChanged: onRoomStateChanged,
        onRoomPhaseChanged: onRoomPhaseChanged,
        onRoomDisconnected: onRoomDisconnected,
        onRoomKicked: onRoomKicked,
        onCanUndoStepsUpdate: onCanUndoStepsUpdate,
        onCanRedoStepsUpdate: onCanRedoStepsUpdate,
        onRoomError: onRoomError,
      );
      try {
        room._initRoomState(jsonDecode(value));
        completer.complete(room);
      } catch (e) {
        completer.completeError(e);
      }
    });
    return completer.future;
  }

  setBackgroundColor(Color? color) {
    if (color == null) {
      return;
    }
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

class WhiteDisplayer {
  String tag = "WhiteDisplayer";

  final DsBridge dsBridge;

  WhiteDisplayer(this.dsBridge);

  scalePptToFit(String mode) {
    dsBridge.callHandler("displayer.scalePptToFit", [mode]);
  }

  scaleIframeToFit() {
    dsBridge.callHandler("displayer.scaleIframeToFit");
  }

  postIframeMessage(dynamic object) {
    dsBridge.callHandler("displayer.postMessage", [jsonEncode(object)]);
  }

  moveCamera(CameraConfig config) {
    dsBridge.callHandler("displayer.moveCamera", [config.toJson()]);
  }

  moveCameraToContainer(RectangleConfig config) {
    dsBridge.callHandler("displayer.moveCameraToContain", [config.toJson()]);
  }

  refreshViewSize() {
    dsBridge.callHandler("displayer.refreshViewSize");
  }

  setBackgroundColor(Color color) {
    dsBridge.callHandler(
      "displayer.setBackgroundColor",
      [color.red, color.green, color.blue, color.alpha],
      null,
    );
  }

  setDisableCameraTransform(bool disable) {
    dsBridge.callHandler("displayer.setDisableCameraTransform", [disable]);
  }

  Future<bool> getDisableCameraTransform() async {
    var value = dsBridge.callHandler(
      "displayer.getDisableCameraTransform",
      [],
      null,
    );
    return value == 'true';
  }

  void setCameraBound(CameraBound cameraBound) {
    dsBridge.callHandler("displayer.setCameraBound", [cameraBound.toJson()]);
  }

  /// 转换白板上点的坐标。
  Future<WhiteBoardPoint> convertToPointInWorld(num x, num y) {
    var completer = Completer<WhiteBoardPoint>();
    dsBridge.callHandler("displayer.convertToPointInWorld", [x, y], ([value]) {
      completer.complete(WhiteBoardPoint.fromJson(jsonDecode(value)));
    });
    return completer.future;
  }

  Future<String> getScenePathType(String path) {
    var completer = Completer<String>();
    dsBridge.callHandler("displayer.scenePathType", [path], ([value]) {
      completer.complete(value);
    });
    return completer.future;
  }

  Future<Map<String, List<Scene>>> getEntireScenes(String path) {
    var completer = Completer<Map<String, List<Scene>>>();

    dsBridge.callHandler("displayer.entireScenes", [path], ([value]) {
      var data = (jsonDecode(value) as Map).map((k, v) {
        var convert = (v as List).map((e) => Scene.fromJson(e)).toList();
        return MapEntry<String, List<Scene>>(k, convert);
      });
      completer.complete(data);
    });
    return completer.future;
  }
}

// Sdk Callback
typedef SdkCreatedCallback = void Function(WhiteSdk whiteSdk);
typedef SdkOnLoggerCallback = void Function(dynamic value);

/// Room Callbacks
typedef RoomStateChangedCallback = void Function(RoomState newState);
typedef RoomPhaseChangedCallback = void Function(String phase);
typedef RoomDisconnectedCallback = void Function(String error);
typedef RoomKickedCallback = void Function(String reason);
typedef UndoStepsUpdatedCallback = void Function(int stepNum);
typedef RedoStepsUpdatedCallback = void Function(int stepNum);
typedef RoomErrorCallback = void Function(String error);

/// Playback Callbacks
typedef PlayerPhaseChangedCallback = void Function(String phase);
typedef PlayerStateChangedCallback = void Function(ReplayState playerState);
typedef FirstFrameLoadedCallback = void Function();
typedef SliceChangedCallback = void Function(String slice);
typedef ScheduleTimeChangedCallback = void Function(int scheduleTime);
typedef PlaybackErrorCallback = void Function(String error);

class WhiteReplay extends WhiteDisplayer {
  String tag = "WhiteReplay";

  final ReplayOptions params;
  final DsBridge dsBridge;

  ReplayTimeInfo replayTimeInfo = ReplayTimeInfo();
  String phase = WhiteBoardPlayerPhase.WaitingFirstFrame;
  int currentTime = 0;

  PlayerPhaseChangedCallback? onPlayerPhaseChanged;
  ScheduleTimeChangedCallback? onScheduleTimeChanged;
  PlayerStateChangedCallback? onPlayerStateChanged;
  FirstFrameLoadedCallback? onLoadFirstFrame;
  PlaybackErrorCallback? onPlaybackError;

  WhiteReplay({
    required this.params,
    required this.dsBridge,
    this.onPlayerPhaseChanged,
    this.onPlayerStateChanged,
    this.onLoadFirstFrame,
    this.onScheduleTimeChanged,
    this.onPlaybackError,
  }) : super(dsBridge) {
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
      "fireCatchErrorWhenAppendFrame",
      this._fireCatchErrorWhenAppendFrame,
    );
    interface.setMethod("onCatchErrorWhenRender", this._onCatchErrorWhenRender);
    interface.setMethod("fireMagixEvent", this._fireMagixEvent);
    interface.setMethod("fireHighFrequencyEvent", this._fireHighFrequencyEvent);
    interface.setMethod("onSliceChanged", this._onSliceChanged);
    return interface;
  }

  _onPhaseChanged(String value) {
    phase = value;
    onPlayerPhaseChanged?.call(value);
  }

  _onPlayerStateChanged(String value) {
    print(value);
    onPlayerStateChanged?.call(ReplayState()..fromJson(jsonDecode(value)));
  }

  _onLoadFirstFrame(value) {
    print(value);
    onPlaybackError?.call(value);
  }

  _onScheduleTimeChanged(value) {
    currentTime = value;
    onScheduleTimeChanged?.call(value);
  }

  _onStoppedWithError(value) {
    print(value);
    onPlaybackError?.call(value);
  }

  _fireCatchErrorWhenAppendFrame(value) {
    print(value);
    onPlaybackError?.call(value);
  }

  _onCatchErrorWhenRender(value) {
    print(value);
    onPlaybackError?.call(value);
  }

  _fireMagixEvent(value) {
    print(value);
  }

  _fireHighFrequencyEvent(value) {
    print(value);
  }

  _onSliceChanged(value) {
    print(value);
  }

  initTimeInfoWithReplayRoom(Map<String, dynamic> json) {
    replayTimeInfo = ReplayTimeInfo.fromJson(json["timeInfo"]);
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
    return double.tryParse(value!) ?? 0;
  }

  FutureOr<String?> get roomUUID {
    return dsBridge.callHandler("player.state.roomUUID");
  }

  FutureOr<String?> getPhase() {
    return dsBridge.callHandler("player.state.phase");
  }

  Future<ReplayState> get playerState async {
    var value = await dsBridge.callHandler("player.state.playerState");
    return ReplayState()..fromJson(jsonDecode(value!));
  }

  Future<bool> get isPlayable async {
    var value = await dsBridge.callHandler("player.state.isPlayable");
    return value == 'true';
  }

  Future<ReplayTimeInfo> get timeInfo async {
    var value = await dsBridge.callHandler("player.state.timeInfo");
    return ReplayTimeInfo.fromJson(jsonDecode(value!));
  }
}

class WhiteRoom extends WhiteDisplayer {
  final RoomOptions options;
  final DsBridge dsBridge;

  String tag = "WhiteRoom";

  // TODO 状态增量同步处理
  RoomState state = RoomState();
  RoomPhase phase = RoomPhase();

  RoomStateChangedCallback? onRoomStateChanged;
  RoomPhaseChangedCallback? onRoomPhaseChanged;
  RoomDisconnectedCallback? onRoomDisconnected;
  RoomKickedCallback? onRoomKicked;
  UndoStepsUpdatedCallback? onCanUndoStepsUpdate;
  RedoStepsUpdatedCallback? onCanRedoStepsUpdate;
  RoomErrorCallback? onRoomError;

  late int observerId;
  int timeDelay = 0;
  bool disconnectedBySelf = false;
  bool writable = false;

  WhiteRoom({
    required this.options,
    required this.dsBridge,
    this.onRoomStateChanged,
    this.onRoomPhaseChanged,
    this.onRoomDisconnected,
    this.onRoomKicked,
    this.onCanUndoStepsUpdate,
    this.onCanRedoStepsUpdate,
    this.onRoomError,
  }) : super(dsBridge) {
    dsBridge.addJavascriptObject(this.createRoomInterface());
  }

  JavaScriptNamespaceInterface createRoomInterface() {
    var interface = JavaScriptNamespaceInterface("room");
    interface.setMethod("firePhaseChanged", this._firePhaseChanged);
    interface.setMethod("fireCanUndoStepsUpdate", this._fireCanUndoStepsUpdate);
    interface.setMethod("fireCanRedoStepsUpdate", this._fireCanRedoStepsUpdate);
    interface.setMethod("fireRoomStateChanged", this._fireRoomStateChanged);
    interface.setMethod(
      "fireDisconnectWithError",
      this._fireDisconnectWithError,
    );
    interface.setMethod("fireKickedWithReason", this._fireKickedWithReason);
    interface.setMethod(
      "fireCatchErrorWhenAppendFrame",
      this._fireCatchErrorWhenAppendFrame,
    );
    interface.setMethod("fireMagixEvent", this._fireMagixEvent);
    interface.setMethod("fireHighFrequencyEvent", this._fireHighFrequencyEvent);
    return interface;
  }

  _firePhaseChanged(String value) {
    phase.value = value;
    onRoomPhaseChanged?.call(value);
  }

  void _fireCanUndoStepsUpdate(value) {
    print(value);
    onCanUndoStepsUpdate?.call(value);
  }

  void _fireCanRedoStepsUpdate(value) {
    print(value);
    onCanRedoStepsUpdate?.call(value);
  }

  void _fireRoomStateChanged(String value) {
    try {
      var data = jsonDecode(value) as Map<String, dynamic>;
      state.fromJson({}
        ..addAll(state.toJson())
        ..addAll(data));
      onRoomStateChanged?.call(state);
    } catch (e) {
      print(e);
    }
  }

  _fireDisconnectWithError(value) {
    print(value);
    onRoomDisconnected?.call(value);
  }

  _fireKickedWithReason(value) {
    print(value);
    onRoomKicked?.call(value);
  }

  _fireCatchErrorWhenAppendFrame(value) {
    print(value);
    onRoomError?.call(value);
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

  _initRoomState(Map<String, dynamic> json) {
    state = RoomState()..fromJson(json["state"]);
  }

  setGlobalState(GlobalState modifyState) {
    dsBridge.callHandler("room.setGlobalState", [modifyState.toJson()]);
  }

  Future<T> getGlobalState<T extends GlobalState>(GlobalStateParser<T> parser) {
    var completer = Completer<T>();
    dsBridge.callHandler("room.getGlobalState", [], ([value]) {
      completer.complete(parser(jsonDecode(value)));
    });
    return completer.future;
  }

  setMemberState(MemberState state) {
    dsBridge.callHandler('room.setMemberState', [state.toJson()]);
  }

  Future<MemberState> getMemberState() {
    var completer = Completer<MemberState>();
    dsBridge.callHandler("room.getMemberState", [], ([value]) {
      completer.complete(MemberState.fromJson(jsonDecode(value)));
    });
    return completer.future;
  }

  Future<List<RoomMember>> getRoomMembers() {
    var completer = Completer<List<RoomMember>>();
    dsBridge.callHandler("room.getRoomMembers", [], ([value]) {
      var members = (json.decode(value) as List)
          .map((jsonMap) => RoomMember.fromJson(jsonMap))
          .toList();
      completer.complete(members);
    });
    return completer.future;
  }

  void setViewMode(ViewMode viewMode) {
    dsBridge.callHandler("room.setViewMode", [viewMode.serialize()]);
  }

  ViewMode viewModeFromJson(String json) {
    ViewMode viewMode;
    switch (json) {
      case "freedom":
        viewMode = ViewMode.Freedom;
        break;
      case "follower":
        viewMode = ViewMode.Follower;
        break;
      case "broadcaster":
        viewMode = ViewMode.Broadcaster;
        break;
      default:
        viewMode = ViewMode.Freedom;
        break;
    }
    return viewMode;
  }

  Future<BroadcastState> getBroadcastState() {
    var completer = Completer<BroadcastState>();
    dsBridge.callHandler('room.getBroadcastState', [], ([value]) {
      var data = BroadcastState.fromJson(jsonDecode(value));
      completer.complete(data);
    });
    return completer.future;
  }

  RoomState getRoomStateNative() {
    return state;
  }

  Future<RoomState> getRoomState() {
    var completer = Completer<RoomState>();
    dsBridge.callHandler("room.state.getRoomState", [], ([value]) {
      var data = RoomState()..fromJson(value);
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

  Future<Map<String, dynamic>> putScenes(
      String dir, List<Scene> scene, int index) {
    var completer = Completer<Map<String, dynamic>>();
    dsBridge.callHandler(
        "room.putScenes", [dir, scene.map((e) => e.toJson()).toList(), index], (
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

  Future<List<Scene>> getScenes() {
    var completer = Completer<List<Scene>>();
    dsBridge.callHandler("room.getSceneState", [], ([value]) {
      var data = (jsonDecode(value) as List)
          .map((itemMap) => Scene.fromJson(itemMap))
          .toList();
      completer.complete(data);
    });
    return completer.future;
  }

  Future<WhiteBoardSceneState> getSceneState() {
    var completer = Completer<WhiteBoardSceneState>();
    dsBridge.callHandler("room.getSceneState", [], ([value]) {
      var data = WhiteBoardSceneState.fromJson(jsonDecode(value));
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
    var uuid = genUuidV4();
    imageInfo.uuid = uuid;
    dsBridge.callHandler("room.insertImage", [imageInfo.toJson()]);
    dsBridge.callHandler("room.completeImageUpload", [uuid, url]);
  }

  String genUuidV4() {
    Random random = new Random();
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
        .runes
        .map((e) {
          var r = random.nextInt(15);
          String c = String.fromCharCode(e);
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
