Releasing
=========

Cutting a Release
-----------------

1. Update `CHANGELOG.md`.
   > Fix:
   > New: new api, feature, etc.
   > Update: bump dependencies
   > Breaking change. change class to enum.
2. Set versions:

    ```
    export RELEASE_VERSION=X.Y.Z
    ```
3. Update versions:
   ```
   sed -i "" -r \
   "s/^(.*const String flutterWhiteSdkVersion = )(.*)(;.*)/\1\"${RELEASE_VERSION}\"\3/" \
   lib/src/types/version.dart
   sed -i "" \
   "s/version: .*/version: $RELEASE_VERSION/g" \
   "pubspec.yaml"
   sed -i "" \
    "s/whiteboard_sdk_flutter: ^.*/whiteboard_sdk_flutter: ^$RELEASE_VERSION/g" \
   README.md README_zh_CN.md
   sed -i "" \
    "s/whiteboard_sdk_flutter: ^.*/whiteboard_sdk_flutter: ^$RELEASE_VERSION/g" \
   "example/pubspec.yaml"
    ```
4. Tag the release and push to GitHub.
   ```
   git commit -am "Prepare for release $RELEASE_VERSION"
   git tag -a $RELEASE_VERSION -m "Version $RELEASE_VERSION"
   git push && git push --tags
   ```

5. Publish pub
   ```
   dart pub publish
   ```