import 'dart:convert';
import 'dart:ui';

import 'types.dart';

class RenderEngineType {
  /// SVG 渲染模式。
  static const svg = "svg";

  /// Canvas 渲染模式。
  static const canvas = "canvas";
}

class DeviceType {
  static const desktop = "desktop";
  static const touch = "touch";
}

class WhiteOptions {
  WhiteOptions({
    required this.appIdentifier,
    this.useMultiViews = false,
    this.log = true,
    this.backgroundColor,
    this.region = Region.cn_hz,
    this.deviceType = DeviceType.touch,
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
    this.disableNewPencilStroke = false,
    this.fonts = const <String, String>{},
    this.nativeTags = const <String, String>{},
    PptParams? pptParams,
  }) : pptParams = pptParams ?? PptParams();

  final String appIdentifier;
  final String region;
  final bool useMultiViews;
  final String deviceType;
  final String renderEngine;
  final Color? backgroundColor;
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
  final bool disableNewPencilStroke;

  final PptParams pptParams;
  final Map<String, String> fonts;
  final Map<String, String> nativeTags;

  WhiteOptions copyWith({
    String? appIdentifier,
    bool? useMultiViews,
    bool? log,
    String? region,
    String? deviceType,
    String? renderEngine,
    Color? backgroundColor,
    bool? enableInterrupterAPI,
    bool? preloadDynamicPPT,
    bool? routeBackup,
    bool? userCursor,
    bool? onlyCallbackRemoteStateModify,
    bool? disableDeviceInputs,
    bool? enableIFramePlugin,
    bool? enableRtcIntercept,
    bool? enableImgErrorCallback,
    PptParams? pptParams,
    Map<String, String>? fonts,
    Map<String, String>? nativeTags,
  }) {
    return WhiteOptions(
      appIdentifier: appIdentifier ?? this.appIdentifier,
      useMultiViews: useMultiViews ?? this.useMultiViews,
      log: log ?? this.log,
      region: region ?? this.region,
      deviceType: deviceType ?? this.deviceType,
      renderEngine: renderEngine ?? this.renderEngine,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      enableInterrupterAPI: enableInterrupterAPI ?? this.enableInterrupterAPI,
      preloadDynamicPPT: preloadDynamicPPT ?? this.preloadDynamicPPT,
      routeBackup: routeBackup ?? this.routeBackup,
      userCursor: userCursor ?? this.userCursor,
      onlyCallbackRemoteStateModify:
          onlyCallbackRemoteStateModify ?? this.onlyCallbackRemoteStateModify,
      disableDeviceInputs: disableDeviceInputs ?? this.disableDeviceInputs,
      enableIFramePlugin: enableIFramePlugin ?? this.enableIFramePlugin,
      enableRtcIntercept: enableRtcIntercept ?? this.enableRtcIntercept,
      enableImgErrorCallback:
          enableImgErrorCallback ?? this.enableImgErrorCallback,
      pptParams: pptParams ?? this.pptParams,
      fonts: fonts ?? this.fonts,
      nativeTags: nativeTags ?? this.nativeTags,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        "appIdentifier": appIdentifier,
        "useMultiViews": useMultiViews,
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
        "__nativeTags": jsonEncode({
          "nativeVersion": flutterWhiteSdkVersion,
          "platform": "flutter",
          ...nativeTags,
        }),
      }..removeWhere((key, value) => value == null);
}
