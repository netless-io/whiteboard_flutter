class WindowRegisterAppParams {
  WindowRegisterAppParams({
    this.kind,
    this.javascriptString,
    this.url,
    this.appOptions,
    this.variable,
  });

  WindowRegisterAppParams.localJs({
    required String kind,
    required String javascriptString,
    required String variable,
    Map<String, Object>? appOptions,
  }) : this(
          javascriptString: javascriptString,
          variable: variable,
          kind: kind,
          appOptions: appOptions,
        );

  WindowRegisterAppParams.remoteJs({
    required String url,
    required String kind,
    Map<String, Object>? appOptions,
  }) : this(
          kind: kind,
          url: url,
          appOptions: appOptions,
        );

  /// 用本地 js 代码注册
  String? javascriptString;

  /// 注册的 app 名称
  String? kind;

  /// 用发布包代码注册
  String? url;

  /// 初始化 app 实例时，会被传入的参数。这段配置不会被同步其他端，属于本地设置。常常用来设置 debug 的开关。
  Map<String, Object>? appOptions;

  /// 挂载在 window 上的变量名，挂在后为 window.variable
  String? variable;

  Map<String, dynamic> toJson() {
    return {
      "kind": kind,
      "javascriptString": javascriptString,
      "url": url,
      "appOptions": appOptions,
      "variable": variable,
    }..removeWhere((key, value) => value == null);
  }
}
