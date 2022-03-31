import 'appliance.dart';

class MemberState {
  List<int>? strokeColor;
  num? strokeWidth;
  num? textSize;
  String? currentApplianceName;
  String? shapeType;

  MemberState({
    this.currentApplianceName,
    String? shapeType,
    this.strokeColor,
    this.strokeWidth,
    this.textSize,
  }) {
    if (ApplianceName.shape == currentApplianceName) {
      this.shapeType = shapeType ?? ShapeType.triangle;
    }
  }

  MemberState.fromJson(Map<String, dynamic> json) {
    strokeColor = List<int>.from(json["strokeColor"]);
    strokeWidth = json["strokeWidth"];
    textSize = json["textSize"];
    shapeType = json["shapeType"];
    currentApplianceName = json["currentApplianceName"];
  }

  Map<String, dynamic> toJson() {
    return {
      "strokeColor": strokeColor,
      "strokeWidth": strokeWidth,
      "textSize": textSize,
      "shapeType": shapeType,
      "currentApplianceName": currentApplianceName,
    }..removeWhere((key, value) => value == null);
  }
}
