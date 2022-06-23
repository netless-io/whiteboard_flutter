// ignore_for_file: inference_failure_on_untyped_parameter

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';

import 'bridge.dart';
import 'bridge_inapp_webview.dart';
import 'bridge_webview.dart';
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
        onDSBridgeCreated: onDSBridgeCreated,
      );
    } else {
      return DsBridgeInAppWebView(
        key: inAppWebView,
        onDSBridgeCreated: onDSBridgeCreated,
      );
    }
  }

  void onDSBridgeCreated(DsBridge dsBridge) {
    dsBridge.addJavascriptObject(createSDKInterface());
    onSdkCreated(WhiteSdk(options: options, dsBridge: dsBridge));
  }

  JavaScriptNamespaceInterface createSDKInterface() {
    var interface = JavaScriptNamespaceInterface("sdk");
    var methods = <String, Function>{
      "onPPTMediaPlay": _onPPTMediaPlay,
      "onPPTMediaPause": _onPPTMediaPause,
      "throwError": _onThrowMessage,
      "postMessage": _onPostMessage,
      "setupFail": _onSetupFail,
      "logger": _onLogger,
    };
    methods.forEach((key, value) => interface.setMethod(key, value));
    return interface;
  }

  void _onSetupFail(value) {
    var whiteException = WhiteException.parseError(value);
    print(whiteException);
  }

  void _onPPTMediaPlay(value) {
    print(value);
  }

  void _onPPTMediaPause(value) {
    print(value);
  }

  void _onThrowMessage(value) {
    print(value);
  }

  void _onPostMessage(value) {
    print(value);
  }

  void _onLogger(value) {
    print(value);
    onLogger?.call(value);
  }
}

class WhiteErrorCode {
  const WhiteErrorCode._(this._type);

  final String _type;

  @override
  String toString() => _type;

  static const WhiteErrorCode invalidAppId = WhiteErrorCode._('invalidAppId');

  static const WhiteErrorCode sdkInitFailed = WhiteErrorCode._('sdkInitFailed');

  static const WhiteErrorCode joinRoomError = WhiteErrorCode._('joinRoomError');

  static const WhiteErrorCode invalidRoomToken =
      WhiteErrorCode._('invalidRoomToken');

  static const WhiteErrorCode unknown = WhiteErrorCode._('unknown');

  static WhiteErrorCode fromMessage(String message) {
    if (message.contains("invalid appIdentifier")) return invalidAppId;
    if (message.contains("sdk init failed")) return sdkInitFailed;
    if (message.contains("akko setup failed")) return joinRoomError;
    if (message.contains("invalid room token")) return invalidRoomToken;
    return unknown;
  }
}

class WhiteException implements Exception {
  WhiteException({
    required this.message,
    this.jsStack,
  }) : code = WhiteErrorCode.fromMessage(message);

  final String message;

  final String? jsStack;

  final WhiteErrorCode code;

  factory WhiteException.parseError(Map<String, dynamic> error) {
    return WhiteException(message: error['message'], jsStack: error['jsStack']);
  }

  static WhiteException? parseValueError(String value) {
    var error = jsonDecode(value);
    if (error.containsKey('__error')) {
      return WhiteException.parseError(error['__error']);
    }
    return null;
  }
}

class WhiteSdk {
  static const String tag = "WhiteSdk";

  final DsBridge dsBridge;
  final WhiteOptions options;

  WhiteSdk({
    required this.options,
    required this.dsBridge,
  }) {
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
    dsBridge.callHandler("sdk.joinRoom", [options.toJson()], ([value]) {
      var error = WhiteException.parseValueError(value);
      if (error == null) {
        room._initRoomState(jsonDecode(value));
        completer.complete(room);
      } else {
        completer.completeError(error);
      }
    });
    return completer.future;
  }

  Future<WhiteReplay> joinReplay({
    required ReplayOptions options,
    PlayerStateChangedCallback? onPlayerStateChanged,
    PlayerPhaseChangedCallback? onPlayerPhaseChanged,
    FirstFrameLoadedCallback? onLoadFirstFrame,
    ScheduleTimeChangedCallback? onScheduleTimeChanged,
    PlaybackErrorCallback? onPlaybackError,
  }) {
    var completer = Completer<WhiteReplay>();
    var replay = WhiteReplay(
      dsBridge: dsBridge,
      params: options,
      onLoadFirstFrame: onLoadFirstFrame,
      onPlayerPhaseChanged: onPlayerPhaseChanged,
      onPlayerStateChanged: onPlayerStateChanged,
      onPlaybackError: onPlaybackError,
      onScheduleTimeChanged: onScheduleTimeChanged,
    );
    dsBridge.callHandler("sdk.replayRoom", [options.toJson()], ([value]) {
      try {
        replay.initTimeInfo(jsonDecode(value));
        completer.complete(replay);
      } catch (e) {
        completer.completeError(e);
      }
    });
    return completer.future;
  }

  String get version => flutterWhiteSdkVersion;

  Future<bool> registerApp(WindowRegisterAppParams params) {
    var completer = Completer<bool>();
    dsBridge.callHandler("sdk.registerApp", [params.toJson()], ([value]) {
      if (value == null) {
        completer.complete(true);
      } else {
        completer.completeError(value);
      }
    });
    return completer.future;
  }

  void setBackgroundColor(Color? color) {
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
  final DsBridge dsBridge;

  WhiteDisplayer(this.dsBridge);

  void scalePptToFit([String mode = AnimationMode.Continuous]) {
    dsBridge.callHandler("displayer.scalePptToFit", [mode]);
  }

  void scaleIframeToFit() {
    dsBridge.callHandler("displayer.scaleIframeToFit");
  }

  void postIframeMessage(dynamic object) {
    dsBridge.callHandler("displayer.postMessage", [object]);
  }

  void moveCamera(CameraConfig config) {
    dsBridge.callHandler("displayer.moveCamera", [config.toJson()]);
  }

  void moveCameraToContainer(RectangleConfig config) {
    dsBridge.callHandler("displayer.moveCameraToContain", [config.toJson()]);
  }

  void refreshViewSize() {
    dsBridge.callHandler("displayer.refreshViewSize");
  }

  void setBackgroundColor(Color color) {
    dsBridge.callHandler(
      "displayer.setBackgroundColor",
      [color.red, color.green, color.blue, color.alpha],
      null,
    );
  }

  void setDisableCameraTransform(bool disable) {
    dsBridge.callHandler("displayer.setDisableCameraTransform", [disable]);
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
        var scenes = (v as List).map((e) => Scene.fromJson(e)).toList();
        return MapEntry<String, List<Scene>>(k, scenes);
      });
      completer.complete(data);
    });
    return completer.future;
  }
}

// Sdk Callback
typedef SdkCreatedCallback = void Function(WhiteSdk whiteSdk);
typedef SdkOnLoggerCallback = void Function(dynamic value);
typedef SdkSetupFailCallback = void Function(WhiteException exception);

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

  ReplayTimeInfo replayTimeInfo = ReplayTimeInfo();
  String phase = WhiteBoardPlayerPhase.WaitingFirstFrame;
  int scheduleTime = 0;
  int timeDuration = 0;
  int beginTimestamp = 0;

  PlayerPhaseChangedCallback? onPlayerPhaseChanged;
  ScheduleTimeChangedCallback? onScheduleTimeChanged;
  PlayerStateChangedCallback? onPlayerStateChanged;
  FirstFrameLoadedCallback? onLoadFirstFrame;
  PlaybackErrorCallback? onPlaybackError;

  WhiteReplay({
    required this.params,
    required DsBridge dsBridge,
    this.onPlayerPhaseChanged,
    this.onPlayerStateChanged,
    this.onLoadFirstFrame,
    this.onScheduleTimeChanged,
    this.onPlaybackError,
  })  : beginTimestamp = params.beginTimestamp,
        timeDuration = params.duration ?? 0,
        super(dsBridge) {
    dsBridge.addJavascriptObject(createPlayerInterface());
  }

  JavaScriptNamespaceInterface createPlayerInterface() {
    var interface = JavaScriptNamespaceInterface("player");
    var methods = <String, Function>{
      "onPhaseChanged": _onPhaseChanged,
      "onPlayerStateChanged": _onPlayerStateChanged,
      "onLoadFirstFrame": _onLoadFirstFrame,
      "onScheduleTimeChanged": _onScheduleTimeChanged,
      "onStoppedWithError": _onStoppedWithError,
      "fireCatchErrorWhenAppendFrame": _fireCatchErrorWhenAppendFrame,
      "onCatchErrorWhenRender": _onCatchErrorWhenRender,
      "fireMagixEvent": _fireMagixEvent,
      "fireHighFrequencyEvent": _fireHighFrequencyEvent,
      "onSliceChanged": _onSliceChanged,
    };
    methods.forEach((key, value) => interface.setMethod(key, value));
    return interface;
  }

  void _onPhaseChanged(String value) {
    phase = value;
    onPlayerPhaseChanged?.call(value);
  }

  void _onPlayerStateChanged(String value) {
    debugPrint("PlayerStateChanged $value");
    onPlayerStateChanged?.call(ReplayState()..fromJson(jsonDecode(value)));
  }

  void _onLoadFirstFrame(value) {
    print(value);
    onPlaybackError?.call(value);
  }

  void _onScheduleTimeChanged(value) {
    scheduleTime = value;
    onScheduleTimeChanged?.call(value);
  }

  void _onStoppedWithError(value) {
    print(value);
    onPlaybackError?.call(value);
  }

  void _fireCatchErrorWhenAppendFrame(value) {
    print(value);
    onPlaybackError?.call(value);
  }

  void _onCatchErrorWhenRender(value) {
    print(value);
    onPlaybackError?.call(value);
  }

  void _fireMagixEvent(value) {
    print(value);
  }

  void _fireHighFrequencyEvent(value) {
    print(value);
  }

  void _onSliceChanged(value) {
    print(value);
  }

  void initTimeInfo(Map<String, dynamic> json) {
    replayTimeInfo = ReplayTimeInfo.fromJson(json["timeInfo"]);
  }

  void play() {
    dsBridge.callHandler("player.play");
  }

  void stop() {
    dsBridge.callHandler("player.stop");
  }

  void pause() {
    dsBridge.callHandler("player.pause");
  }

  void seekToScheduleTime(double beginTime) {
    scheduleTime = beginTime.toInt();
    dsBridge.callHandler("player.seekToScheduleTime", [beginTime]);
  }

  /// 参数限定 PlayerObserverMode
  void setObserverMode(String observerMode) {
    dsBridge.callHandler("player.setObserverMode", [observerMode]);
  }

  void setPlaybackSpeed(double rate) {
    dsBridge.callHandler("player.setPlaybackSpeed", [rate]);
  }

  Future<double> get playbackSpeed {
    var completer = Completer<double>();
    dsBridge.callHandler("player.state.playbackSpeed", [], ([value]) {
      completer.complete(double.tryParse(value!) ?? 0);
    });
    return completer.future;
  }

  FutureOr<String?> get roomUUID {
    return dsBridge.callHandler("player.state.roomUUID");
  }

  Future<String> getPhase() {
    var completer = Completer<String>();
    dsBridge.callHandler("player.state.phase", [], ([value]) {
      try {
        completer.complete(value);
      } catch (e) {
        // ignore
      }
    });
    return completer.future;
  }

  Future<ReplayState> get playerState {
    var completer = Completer<ReplayState>();
    dsBridge.callHandler("player.state.playerState", [], ([value]) {
      var replayState = ReplayState()..fromJson(jsonDecode(value!));
      completer.complete(replayState);
    });
    return completer.future;
  }

  Future<bool> get isPlayable {
    var completer = Completer<bool>();
    dsBridge.callHandler("player.state.isPlayable", [], ([value]) {
      completer.complete(value == 'true');
    });
    return completer.future;
  }

  Future<ReplayTimeInfo> get timeInfo {
    var completer = Completer<ReplayTimeInfo>();
    dsBridge.callHandler("player.state.timeInfo", [], ([_]) {
      var timeInfo = ReplayTimeInfo(
        scheduleTime: scheduleTime,
        timeDuration: timeDuration,
        beginTimestamp: beginTimestamp,
      );
      completer.complete(timeInfo);
    });
    return completer.future;
  }
}

class WhiteRoom extends WhiteDisplayer {
  static const String tag = "WhiteRoom";

  final RoomOptions options;

  // TODO 状态增量同步处理
  RoomState state = RoomState();
  RoomPhase phase = RoomPhase();

  RoomStateChangedCallback? onRoomStateChanged;
  RoomPhaseChangedCallback? onRoomPhaseChanged;
  RoomDisconnectedCallback? onRoomDisconnected;
  UndoStepsUpdatedCallback? onCanUndoStepsUpdate;
  RedoStepsUpdatedCallback? onCanRedoStepsUpdate;
  RoomKickedCallback? onRoomKicked;
  RoomErrorCallback? onRoomError;

  late int observerId;
  int timeDelay = 0;
  bool disconnectedBySelf = false;
  bool writable = false;

  WhiteRoom({
    required this.options,
    required DsBridge dsBridge,
    this.onRoomStateChanged,
    this.onRoomPhaseChanged,
    this.onRoomDisconnected,
    this.onCanUndoStepsUpdate,
    this.onCanRedoStepsUpdate,
    this.onRoomKicked,
    this.onRoomError,
  }) : super(dsBridge) {
    dsBridge.addJavascriptObject(createRoomInterface());
  }

  JavaScriptNamespaceInterface createRoomInterface() {
    var interface = JavaScriptNamespaceInterface("room");
    var methods = <String, Function>{
      "fireRoomStateChanged": _fireRoomStateChanged,
      "firePhaseChanged": _firePhaseChanged,
      "fireDisconnectWithError": _fireDisconnectWithError,
      "fireCanUndoStepsUpdate": _fireCanUndoStepsUpdate,
      "fireCanRedoStepsUpdate": _fireCanRedoStepsUpdate,
      "fireCatchErrorWhenAppendFrame": _fireCatchErrorWhenAppendFrame,
      "fireKickedWithReason": _fireKickedWithReason,
      "fireMagixEvent": _fireMagixEvent,
      "fireHighFrequencyEvent": _fireHighFrequencyEvent,
    };
    methods.forEach((key, value) => interface.setMethod(key, value));
    return interface;
  }

  void _firePhaseChanged(String value) {
    debugPrint("_firePhaseChanged $value");
    phase.value = value;
    onRoomPhaseChanged?.call(value);
  }

  void _fireCanUndoStepsUpdate(value) {
    debugPrint("_fireCanUndoStepsUpdate $value");
    onCanUndoStepsUpdate?.call(value);
  }

  void _fireCanRedoStepsUpdate(value) {
    debugPrint("_fireCanRedoStepsUpdate $value");
    onCanRedoStepsUpdate?.call(value);
  }

  void _fireRoomStateChanged(String value) {
    try {
      var data = jsonDecode(value) as Map<String, dynamic>;

      /// todo update state with update(data)
      state.fromJson({}
        ..addAll(state.toJson())
        ..addAll(data));
      onRoomStateChanged?.call(state);
    } catch (e) {
      print("fireRoomStateChanged error $e");
    }
  }

  void _fireDisconnectWithError(value) {
    print(value);
    onRoomDisconnected?.call(value);
  }

  void _fireKickedWithReason(value) {
    print(value);
    onRoomKicked?.call(value);
  }

  void _fireCatchErrorWhenAppendFrame(value) {
    print(value);
    onRoomError?.call(value);
  }

  void _fireMagixEvent(value) {
    print(value);
  }

  void _fireHighFrequencyEvent(value) {
    print(value);
  }

  bool isDisconnectedBySelf() {
    return disconnectedBySelf;
  }

  void _initRoomState(Map<String, dynamic> json) {
    state = RoomState()..fromJson(json["state"]);
  }

  void setGlobalState(GlobalState modifyState) {
    dsBridge.callHandler("room.setGlobalState", [modifyState.toJson()]);
  }

  Future<T> getGlobalState<T extends GlobalState>(GlobalStateParser<T> parser) {
    var completer = Completer<T>();
    dsBridge.callHandler("room.getGlobalState", [], ([value]) {
      completer.complete(parser(jsonDecode(value)));
    });
    return completer.future;
  }

  void setMemberState(MemberState state) {
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
      var members = (jsonDecode(value) as List)
          .map((jsonMap) => RoomMember.fromJson(jsonMap))
          .toList();
      completer.complete(members);
    });
    return completer.future;
  }

  void setViewMode(ViewMode viewMode) {
    dsBridge.callHandler("room.setViewMode", [viewMode.serialize()]);
  }

  Future<BroadcastState> getBroadcastState() {
    var completer = Completer<BroadcastState>();
    dsBridge.callHandler('room.getBroadcastState', [], ([value]) {
      var data = BroadcastState.fromJson(jsonDecode(value));
      completer.complete(data);
    });
    return completer.future;
  }

  /// 获取本地缓存的房间状态
  RoomState getRoomStateNative() {
    return state;
  }

  /// 异步获取最新房间状态
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

  /// 允许/禁止白板响应用户任何操作。
  /// <p>
  /// 该方法设置是否禁止白板响应用户的操作，包括：
  /// - `CameraTransform`：移动、缩放视角。
  /// - `DeviceInputs`：使用白板工具输入。
  ///
  /// @param value 允许/禁止白板响应用户任何操作。
  ///                          - `true`：不响应用户操作。
  ///                          - `false`：（默认）响应用户操作。
  set disableOperations(bool value) {
    disableCameraTransform = value;
    disableDeviceInputs = value;
  }

  /// 禁止/允许用户调整（移动或缩放）视角。
  ///
  /// @since 2.2.0
  ///
  /// @param value 是否禁止用户调整视角：
  ///                               - `true`：禁止用户调整视角。
  ///                               - `false`：（默认）允许用户调整视角。
  set disableCameraTransform(bool value) {
    dsBridge.callHandler("room.disableCameraTransform", [value]);
  }

  /// 禁止/允许用户操作白板工具。
  ///
  /// @since 2.2.0
  ///
  /// @param value 是否禁止用户操作白板工具：
  ///                          - `true`：禁止用户操作白板工具操作。
  ///                          - `false`：（默认）允许用户操作白板工具输入操作。
  set disableDeviceInputs(bool value) {
    dsBridge.callHandler("room.disableDeviceInputs", [value]);
  }

  /// 禁止/允许窗口操作。
  ///
  /// @since 2.2.0
  ///
  /// @param value 是否禁止窗口操作：
  ///                          - `true`：禁止窗口操作。
  ///                          - `false`：（默认）允许窗口操作。
  set disableWindowOperation(bool value) {
    dsBridge.callHandler("room.disableWindowOperation", [value]);
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
      var error = WhiteException.parseValueError(value);
      if (error == null) {
        bool isWritable = jsonDecode(value)['isWritable'];
        int observerId = jsonDecode(value)['observerId'];

        _setWritable(isWritable);
        _setObserverId(observerId);

        completer.complete(isWritable);
      } else {
        completer.completeError(error);
      }
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

  void pptNextStep() {
    dsBridge.callHandler("ppt.nextStep");
  }

  void pptPreviousStep() {
    dsBridge.callHandler("ppt.previousStep");
  }

  void addPage([Scene? scene, bool after = false]) {
    var params = AddPageParams(scene: scene, after: after);
    dsBridge.callHandler("room.addPage", [params.toJson()]);
  }

  Future<bool> nextPage() {
    var completer = Completer<bool>();
    dsBridge.callHandler("room.nextPage", [], ([value]) {
      completer.complete(value);
    });
    return completer.future;
  }

  Future<bool> prevPage() {
    var completer = Completer<bool>();
    dsBridge.callHandler("room.prevPage", [], ([value]) {
      completer.complete(value);
    });
    return completer.future;
  }

  Future<Map<String, dynamic>> putScenes(
      String dir, List<Scene> scene, int index) {
    var completer = Completer<Map<String, dynamic>>();
    dsBridge.callHandler(
      "room.putScenes",
      [dir, scene.map((e) => e.toJson()).toList(), index],
      ([value]) {
        completer.complete(jsonDecode(value));
      },
    );
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
      var error = WhiteException.parseValueError(value);
      if (error == null) {
        completer.complete(true);
      } else {
        completer.completeError(error);
      }
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
  Future<bool> setSceneIndex(int index) {
    var completer = Completer<bool>();
    dsBridge.callHandler("room.setSceneIndex", [index], ([value]) {
      var error = WhiteException.parseValueError(value);
      if (error == null) {
        completer.complete(true);
      } else {
        completer.completeError(error);
      }
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
  void removeScenes(String dirOrPath) {
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

  void cleanScene(bool retainPPT) {
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
    Random random = Random();
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

  /// 插入文字
  void insertText(int x, int y, String text) {
    dsBridge.callHandler("room.insertText", [x, y, text]);
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
    dsBridge.callHandler("room.sync.syncBlockTimestamp", [utcMs]);
  }

  /// 发送自定义事件。
  void dispatchMagixEvent(AkkoEvent eventEntry) {
    dsBridge.callHandler("room.dispatchMagixEvent", [eventEntry.toJson()]);
  }

  /// 设置远端白板画面同步延时。单位为秒。
  void setTimeDelay(int delaySec) {
    dsBridge.callHandler("room.setTimeDelay", [delaySec * 1000]);
    timeDelay = delaySec;
  }

  /// 获取设置得远端白板画面同步延时。单位为秒。
  int getTimeDelay() {
    return timeDelay;
  }

  /// 获取当前用户的视野缩放比例。
  Future<num> getZoomScale() {
    var completer = Completer<num>();
    dsBridge.callHandler("room.getZoomScale", [], ([value]) {
      completer.complete(value);
    });
    return completer.future;
  }

  /// 添加窗口
  Future<String> addApp(WindowAppParams appParam) {
    var completer = Completer<String>();
    dsBridge.callHandler(
      "room.addApp",
      [appParam.kind, appParam.options, appParam.attributes],
      ([value]) {
        completer.complete(value);
      },
    );
    return completer.future;
  }

  /// 设置多窗口显示比例
  /// [ratio] 高与宽比例
  void setContainerSizeRatio(double ratio) {
    dsBridge.callHandler("room.setContainerSizeRatio", [ratio]);
  }

  /// 设置设置暗色模式
  ///
  /// [colorScheme]
  void setPrefersColorScheme(WindowPrefersColorScheme colorScheme) {
    dsBridge.callHandler(
      "room.setPrefersColorScheme",
      [colorScheme.serialize()],
    );
  }
}
