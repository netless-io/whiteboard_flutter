import 'room_state.dart';

class BroadcastState {
  late String mode;
  int? broadcasterId;
  RoomMember? broadcasterInformation;

  BroadcastState.fromJson(Map<String, dynamic> json) {
    mode = json["mode"];
    broadcasterId = json["broadcasterId"];
    broadcasterInformation = json["broadcasterInformation"] != null
        ? RoomMember.fromJson(json["broadcasterInformation"])
        : null;
  }

  Map<String, dynamic> toJson() => {
        "mode": mode,
        "broadcasterId": broadcasterId,
        "broadcasterInformation": broadcasterInformation,
      }..removeWhere((key, value) => value == null);
}
