# LanguageStyle
## Language
### Operators
#### Question mark
```dart
b ??= value;
```
#### Cascade notation
```dart
var paint = Paint()
  ?..color = Colors.black
  ..strokeCap = StrokeCap.round
  ..strokeWidth = 5.0;
```
#### AVOID using Completer directly.
```dart
/// bad
Future<bool> fileContainsBear(String path) {
  var completer = Completer<bool>();

  File(path).readAsString().then((contents) {
    completer.complete(contents.contains('bear'));
  });

  return completer.future;
}

/// good
Future<bool> fileContainsBear(String path) {
  return File(path).readAsString().then((contents) {
    return contents.contains('bear');
  });
}

Future<bool> fileContainsBear(String path) async {
  var contents = await File(path).readAsString();
  return contents.contains('bear');
}
```
### Function
```dart
void doStuff({
  List<int> list = const [1, 2, 3],
  Map<String, String> gifts = const {
    'first': 'paper',
    'second': 'cotton',
    'third': 'leather'
  },
}) {
  print('list:  $list');
  print('gifts: $gifts');
}
```
### Class
#### Redirecting constructors
```dart
class Point {
  double x, y;

  // The main constructor for this class.
  Point(this.x, this.y);

  // Delegates to the main constructor.
  Point.alongXAxis(double x) : this(x, 0);
}
```
#### Constant constructors
```dart
class ImmutablePoint {
  static const ImmutablePoint origin = ImmutablePoint(0, 0);

  final double x, y;

  const ImmutablePoint(this.x, this.y);
}
```
#### CONSIDER declaring multiple classes in the same library.
It’s perfectly fine for a single library to contain multiple classes, top level variables, and functions if they all logically belong together.

### Comments
行注释使用 //
变量及行数类注释使用 ///

## Project
### enum 类型 json 处理
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
### model 类的 json 处理
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
### 模型类可变参数
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
### json to list
```dart
// 使用流式处理
var members = (json.decode(value) as List)
        ?.map<WhiteBoardRoomMember>((jsonMap) => WhiteBoardRoomMember.fromJson(jsonMap))
        ?.toList();
```
### map object .. 语法