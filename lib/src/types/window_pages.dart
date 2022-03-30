import 'dart:convert';

import 'scene.dart';

class AddPageParams {
  AddPageParams({
    this.after = false,
    this.scene,
  });

  bool after;
  Scene? scene;

  Map<String, dynamic> toJson() {
    return {
      "after": after,
      if (scene != null) "scene": jsonEncode(scene),
    }..removeWhere((key, value) => value == null);
  }
}
