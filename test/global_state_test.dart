// ignore_for_file: inference_failure_on_collection_literal

import 'package:flutter_test/flutter_test.dart';
import 'package:whiteboard_sdk_flutter/src/types/types.dart';

void main() {
  group('Display State', () {
    test('empty room state toJson should be empty map', () {
      RoomState emptyRoomState = RoomState();

      expect(emptyRoomState.toJson(), {});
    });

    test('empty replay state toJson should be empty map', () {
      ReplayState emptyReplayState = ReplayState();

      expect(emptyReplayState.toJson(), {});
    });
  });
}
