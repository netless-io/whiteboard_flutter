import 'member_state.dart';

class RoomMember {
  int memberId;
  MemberState memberState;
  String session;
  dynamic payload;

  RoomMember({
    required this.memberId,
    required this.memberState,
    required this.session,
    this.payload,
  });

  Map<String, dynamic> toJson() {
    return {
      "memberId": memberId,
      "memberState": memberState.toJson(),
      "session": session,
      "payload": payload
    };
  }

  RoomMember.fromJson(Map<String, dynamic> json)
      : memberId = json["memberId"],
        memberState = MemberState.fromJson(json["memberState"]),
        session = json["session"],
        payload = json["payload"];
}

class UserPayload {
  String userId;
  String identity;

  UserPayload({
    this.userId = "",
    this.identity = "",
  });

  Map<String, dynamic> toJson() {
    return {"userId": userId, "identity": identity};
  }

  UserPayload.fromJson(Map<String, dynamic> json)
      : userId = json["userId"],
        identity = json["identity"];
}

class RoomPhase {
  /// 连接中。
  static const String connecting = "connecting";

  /// 已连接，
  static const String connected = "connected";

  /// 正在重连。
  static const String reconnecting = "reconnecting";

  /// 正在断开连接。
  static const String disconnecting = "disconnecting";

  /// 已经断开连接。
  static const String disconnected = "disconnected";

  String value = RoomPhase.disconnected;
}
