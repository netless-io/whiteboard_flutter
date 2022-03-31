import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:whiteboard_sdk_flutter/whiteboard_sdk_flutter.dart';

import 'bridge_test.mocks.dart';

class FakeInterface extends JavaScriptNamespaceInterface {
  FakeInterface() : super("fake") {
    setMethod('onNormalCallReturnValue', _onNormalCallReturnValue);
    setMethod('onNormalCallReturnVoid', _onNormalCallReturnVoid);
    setMethod('onFutureCall', _onFutureCall);
  }

  void _onNormalCallReturnVoid(value) {}

  String _onNormalCallReturnValue(value) {
    return "fakeReturn";
  }

  Future<String> _onFutureCall(value) {
    return Future.value("fakeReturn");
  }
}

@GenerateMocks([DsBridge])
void main() {
  group('ParseNamespace', () {
    late MockDsBridge bridge;
    late InnerJavascriptInterface interface;

    setUp(() {
      bridge = MockDsBridge();
      interface = InnerJavascriptInterface(bridge);
    });

    var parseNamespaceTestUnits = <String, List<String>>{
      "_dsb.dsinit": ["_dsb", "dsinit"],
      "_dsb.returnValue": ["_dsb", "returnValue"],
      "sdk.logger": ["sdk", "logger"],
      "room.firePhaseChanged": ["room", "firePhaseChanged"],
      "room.fireCanUndoStepsUpdate": ["room", "fireCanUndoStepsUpdate"],
      "room.fireRoomStateChanged": ["room", "fireRoomStateChanged"],
      "player.onPhaseChanged": ["player", "onPhaseChanged"],
      "player.onPlayerStateChanged": ["player", "onPlayerStateChanged"],
    };

    parseNamespaceTestUnits.forEach((key, value) {
      test('parse namespace with $key', () {
        expect(interface.parseNamespace(key), value);
      });
    });
  });

  group('NamespaceInterfaces', () {
    late MockDsBridge bridge;
    late InnerJavascriptInterface interface;

    setUp(() {
      bridge = MockDsBridge();
      interface = InnerJavascriptInterface(bridge);
    });

    test('initialize as empty', () {
      expect(interface.javaScriptNamespaceInterfaces.isEmpty, true);
    });

    test('add "" as "__dsbridge"', () {
      interface.addNamespaceInterface(JavaScriptNamespaceInterface());

      var collection = interface.javaScriptNamespaceInterfaces;
      expect(collection.containsKey(""), false);
      expect(collection.containsKey("__dsbridge"), true);
    });
  });

  group('Interface Call', () {
    late MockDsBridge bridge;
    late InnerJavascriptInterface interface;

    setUp(() {
      bridge = MockDsBridge();
      DsBridge.isDebug = true;
      interface = InnerJavascriptInterface(bridge);

      var fakeInterface = FakeInterface();
      interface.addNamespaceInterface(fakeInterface);
    });

    test('bridge mock test', () async {
      when(bridge.evaluateJavascript("javascript")).thenReturn("true");
      expect(bridge.evaluateJavascript("javascript"), "true");
    });

    test('call non-existent namespace return -1', () async {
      DsBridge.isDebug = false;

      var expectResult = <String, dynamic>{"code": -1}.toString();
      expect(await interface.call("nonexistence.any", "{}"), expectResult);
    });

    test('call func with return', () async {
      var expectResult = '{"code":0,"data":"fakeReturn"}';

      var actual = await interface.call(
        "fake.onNormalCallReturnValue",
        "{\"data\":{\"param\":\"value\"}}",
      );

      expect(actual, expectResult);
    });

    test('call func no return', () async {
      var expectResult = '{"code":0,"data":null}';

      var actual = await interface.call(
        "fake.onNormalCallReturnVoid",
        "{\"data\":{\"param\":\"value\"}}",
      );

      expect(actual, expectResult);
    });

    test('call future func', () async {
      var expectJs = 'dscb111({"code":0,"data":"fakeReturn"}.data);'
          'delete window.dscb111';

      when(bridge.evaluateJavascript(expectJs)).thenReturn("true");
      // var expectResult = '{"code":0,"data":"fakeReturn"}';
      var expectResult = '{"code":-1}';

      var actual = await interface.call(
        "fake.onFutureCall",
        "{\"data\":{\"param\":\"value\"}, \"_dscbstub\": \"dscb111\"}",
      );
      expect(actual, expectResult);

      verify(bridge.evaluateJavascript(expectJs));
    });
  });
}
