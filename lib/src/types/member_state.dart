import 'types.dart';

class MemberState {
  List<int>? strokeColor;
  num? strokeWidth;
  num? textSize;
  String? currentApplianceName;
  String? shapeType;

  MemberState({
    String? currentApplianceName,
    String? shapeType,
    this.strokeColor,
    this.strokeWidth,
    this.textSize,
  }) {
    this.currentApplianceName = currentApplianceName;
    if (ApplianceName.shape == currentApplianceName) {
      this.shapeType = shapeType != null ? shapeType : ShapeType.triangle;
    }
  }

  MemberState.fromJson(Map<String, dynamic> json) {
    strokeColor = (json["strokeColor"]).map<int>((e) => e as int).toList();
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
