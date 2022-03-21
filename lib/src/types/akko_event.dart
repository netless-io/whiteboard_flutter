import 'dart:convert';

class AkkoEvent {
  String eventName;
  var payload;

  AkkoEvent(this.eventName, this.payload);

  Map<String, dynamic> toJson() {
    return {"eventName": eventName, "payload": jsonEncode(payload)};
  }
}
