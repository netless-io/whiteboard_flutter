class ImageInformation {
  String? uuid;
  num centerX;
  num centerY;
  num width;
  num height;

  /// 设置锁定图片。
  bool locked;

  ImageInformation({
    this.uuid,
    this.centerX = 0,
    this.centerY = 0,
    this.width = 0,
    this.height = 0,
    this.locked = false,
  });

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
