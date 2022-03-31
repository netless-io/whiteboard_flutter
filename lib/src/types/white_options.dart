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

  final PptParams pptParams;
  final Map<String, String> fonts;
  final Map<String, String> nativeTags;

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
