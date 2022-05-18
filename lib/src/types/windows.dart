enum WindowPrefersColorScheme {
  /// Always use the light mode regardless of system preference.
  light,
  /// Always use the dark mode (if available) regardless of system preference.
  dark,
  /// Use either the light or dark theme detected by webview
  auto,
}

extension WindowPrefersColorSchemeExtensions on WindowPrefersColorScheme {
  String serialize() {
    switch (this) {
      case WindowPrefersColorScheme.light:
        return "light";
      case WindowPrefersColorScheme.dark:
        return "dark";
      case WindowPrefersColorScheme.auto:
        return "auto";
    }
  }
}

class WindowParams {
  WindowParams({
    this.containerSizeRatio = 9 / 16,
    this.chessboard = true,
    this.collectorStyles,
    this.prefersColorScheme,
    this.overwriteStyles = "",
    this.debug = false,
  });

  /// 各个端本地显示多窗口内容时，高与宽比例，默认为 9:16
  double containerSizeRatio;

  /// 多窗口区域（主窗口）以外的空间显示 PS 棋盘背景，默认 true
  bool chessboard;

  /// 驼峰形式的 CSS，透传给多窗口时，最小化 div 的 css
  Map<String, String>? collectorStyles;

  /// 窗口样式覆盖
  String? overwriteStyles;

  /// 是否在网页控制台打印日志
  bool debug;

  /// 窗口配色模式
  WindowPrefersColorScheme? prefersColorScheme;

  Map<String, dynamic> toJson() {
    return {
      "containerSizeRatio": containerSizeRatio,
      "chessboard": chessboard,
      "collectorStyles": collectorStyles,
      "overwriteStyles": overwriteStyles,
      "debug": debug,
      "prefersColorScheme": prefersColorScheme?.serialize()
    }..removeWhere((key, value) => value == null);
  }
}
