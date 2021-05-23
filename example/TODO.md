# 通用问题处理
* enum 类型 json 处理
参考官网例子
```dart
class Color {
  static const red = '#f00';
  static const green = '#0f0';
  static const blue = '#00f';
  static const black = '#000';
  static const white = '#fff';
}
```
* model 类的 json 处理
参考官网例子
```dart
class User {
  final String name;
  final String email;

  User(this.name, this.email);

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        email = json['email'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
      };
}
```
* 模型类可变参数
```dart
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
```
* json to list
```dart
// 使用流式处理
var members = (json.decode(value) as List)
        ?.map<WhiteBoardRoomMember>((jsonMap) => WhiteBoardRoomMember.fromJson(jsonMap))
        ?.toList();
```

## 语法熟悉
* map object .. 语法