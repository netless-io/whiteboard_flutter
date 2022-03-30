import 'package:flutter_test/flutter_test.dart';
import 'package:whiteboard_sdk_flutter/src/bridge.dart';
import 'package:whiteboard_sdk_flutter/src/types/types.dart';

void main() {
  group('CallInfo Serialize', () {
    test('call info with no args', () {
      var callInfo = CallInfo(1, "foo.bar", []);
      var expectResult = '{"method":"foo.bar","callbackId":1,"data":"[]"}';

      expect(callInfo.toString(), expectResult);
    });

    test('call info with complex args', () {
      var windowAppParams = WindowAppParams(
        kind: "EmbeddedPage",
        options: {
          "scenePath": "/embedPage",
          "title": "A Embed Page",
        },
        attributes: {"src": "https://www.baidu.com"},
      );
      var callInfo = CallInfo(1, "room.addApp", [
        windowAppParams.kind,
        windowAppParams.options,
        windowAppParams.attributes
      ]);
      var expectResult =
          '{"method":"room.addApp","callbackId":1,"data":"[\\"EmbeddedPage\\",{\\"scenePath\\":\\"/embedPage\\",\\"title\\":\\"A Embed Page\\"},{\\"src\\":\\"https://www.baidu.com\\"}]"}';
      expect(callInfo.toString(), expectResult);
    });
  });
}
