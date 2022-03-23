import 'dart:convert';

class AkkoEvent {
  String eventName;
  dynamic payload;

  AkkoEvent(this.eventName, this.payload);

  Map<String, dynamic> toJson() => {
        "eventName": eventName,
        "payload": jsonEncode(payload),
      };
}
