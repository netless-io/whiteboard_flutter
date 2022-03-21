class PptParams {
  /// 更改动态 ppt 请求时的请求协议，可以将 https://www.exmaple.com/1.pptx 更改成 scheme://www.example.com/1.pptx
  String? scheme;

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
