# Agora Whiteboard SDK

A Flutter Plugin of Agora Whiteboard SDK

## Installation
Add whiteboard_sdk_flutter to your pubspec:

```yaml
dependencies:
  whiteboard_sdk_flutter: ^0.5.4
```

### Android

Configure your app to use the `INTERNET` permission in the manifest file located
in: </br>
`<project root>/android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## Sample Usage

### Live Room
1. Init whiteboard using `WhiteSdkOptions`, `WhiteSdk` can be fetch on `onSdkCreated`
2. call `WhiteSdk.joinRoom` using `RoomOptions` to fetch a `WhiteRoom`
3. `WhiteRoom` is a controller to Live-Whiteboard

```dart
Widget build(BuildContext context) {
    return new WhiteboardView(
        options: WhiteOptions(
            appIdentifier: APP_ID,
            log: true,
        ),
        onSdkCreated: (sdk) async {
            // use sdk to join room
            var room = await sdk.joinRoom(
                options: RoomOptions(
                    uuid: ROOM_UUID,
                    roomToken: ROOM_TOKEN,
                    uid: UNIQUE_CLIENT_ID,
                    isWritable: true,
                ),
            );

            setState(() {
                whiteSdk = sdk;
                whiteRoom = room;
            });
        },
    );
}
```

### Replay
1. Init whiteboard using `WhiteSdkOptions`, `WhiteSdk` can be fetch on `onSdkCreated`
2. call `WhiteSdk.joinReplay` using `ReplayOptions` to fetch `WhiteReplay`
3. `WhiteReplay` is a controller to Record-Whiteboard

```dart
Widget build(BuildContext context) {
    return new WhiteboardView(
        options: WhiteOptions(
            appIdentifier: APP_ID,
            log: true,
            backgroundColor: Color(0xFFF9F4E7),
        ),
        onSdkCreated: (whiteSdk) async {
            // use sdk to join replay
            var replay = await sdk.joinReplay(
              options: ReplayOptions(room: ROOM_UUID, roomToken: ROOM_TOKEN),
              onPlayerStateChanged: _onPlayerStateChanged,
              onPlayerPhaseChanged: _onPlayerPhaseChanged,
              onScheduleTimeChanged: _onScheduleTimeChanged,
            );

            setState(() {
              whiteSdk = sdk;
              whiteReplay = replay;
            });
          },
    );
}
```
### Example
See the `example/` folder for a working example app. </br>

Common apis can be found in the `examples/` </br>

[Room](https://github.com/netless-io/Whiteboard-Flutter/tree/main/example/lib/room_test_page.dart) </br>

[Replay](https://github.com/netless-io/Whiteboard-Flutter/tree/main/example/lib/replay_test_page.dart)


## Contributor
Thanks To [liuhong1happy](https://gitee.com/liuhong1happy/flutter_netless_whiteboard) for the first version of flutter whiteboard.