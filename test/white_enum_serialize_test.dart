import 'package:flutter_test/flutter_test.dart';
import 'package:whiteboard_sdk_flutter/whiteboard_sdk_flutter.dart';

void main() {
  group('ViewMode', () {
    test('ViewMode.Broadcaster serialize', () {
      expect(ViewMode.Broadcaster.serialize(), "Broadcaster");
    });

    test('ViewMode.Follower serialize', () {
      expect(ViewMode.Follower.serialize(), "Follower");
    });

    test('ViewMode.Freedom serialize', () {
      expect(ViewMode.Freedom.serialize(), "Freedom");
    });

    test('deserialize "null" to ViewMode.Freedom', () {
      expect(null.toViewMode(), ViewMode.Freedom);
    });

    test('deserialize "follower"', () {
      expect("follower".toViewMode(), ViewMode.Follower);
    });

    test('deserialize "broadcaster"', () {
      expect("broadcaster".toViewMode(), ViewMode.Broadcaster);
    });

    test('deserialize "freedom"', () {
      expect("freedom".toViewMode(), ViewMode.Freedom);
    });
  });
}
