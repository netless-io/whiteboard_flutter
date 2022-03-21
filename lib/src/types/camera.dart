import 'types.dart';

enum ViewMode {
  Freedom,
  Follower,
  Broadcaster,
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

class CameraConfig {
  num centerX;
  num centerY;
  num scale;
  String? animationMode;

  CameraConfig({
    this.centerX = 0,
    this.centerY = 0,
    this.scale = 1.0,
    this.animationMode = AnimationMode.Continuous,
  });

  Map<String, dynamic> toJson() {
    return {
      "centerX": centerX,
      "centerY": centerY,
      "scale": scale,
      "animationMode": animationMode
    };
  }

  CameraConfig.fromJson(Map<String, dynamic> json)
      : centerX = json["centerX"],
        centerY = json["centerY"],
        scale = json["scale"],
        animationMode = json["animationMode"];
}

/// 视角边界的缩放模式和缩放比例。
class ContentModeConfig {
  /// 视角边界的缩放比例
  final num scale;

  /// 四周填充的空白空间,单位为像素
  final num space;
  final String mode;

  ContentModeConfig(
      {this.scale = 1, this.space = 0, this.mode = ScaleMode.scale});

  Map<String, dynamic> toJson() {
    return {
      "scale": scale,
      "space": space,
      "mode": mode,
    };
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

  RectangleConfig.fromSize(num width, num height,
      [String animationMode = AnimationMode.Continuous])
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
  final ContentModeConfig? maxContentMode;
  final ContentModeConfig? minContentMode;

  CameraBound({
    this.damping = 0,
    this.centerX = 0,
    this.centerY = 0,
    this.width = 0,
    this.height = 0,
    minScale,
    maxScale,
  })  : this.minContentMode = ContentModeConfig(scale: minScale),
        this.maxContentMode = ContentModeConfig(scale: maxScale);

  CameraBound.withContentModeConfig({
    this.damping = 0,
    this.centerX = 0,
    this.centerY = 0,
    this.width = 0,
    this.height = 0,
    this.minContentMode,
    this.maxContentMode,
  });

  Map<String, dynamic> toJson() {
    return {
      "damping": damping,
      "centerX": centerX,
      "centerY": centerY,
      "width": width,
      "height": height,
      if (maxContentMode != null) "maxContentMode": maxContentMode!.toJson(),
      if (minContentMode != null) "minContentMode": minContentMode!.toJson(),
    };
  }
}

class WhiteBoardPoint {
  num x;
  num y;

  WhiteBoardPoint(this.x, this.y);

  WhiteBoardPoint.fromJson(Map<String, dynamic> jsonMap)
      : x = jsonMap["x"],
        y = jsonMap["y"];
}
