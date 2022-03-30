import 'dart:convert';

import 'scene.dart';

class WindowAppParams {
  static const String kindDocsViewer = "DocsViewer";
  static const String kindMediaPlayer = "MediaPlayer";

  // for kind of new ppt
  static const String kindSlide = "Slide";

  WindowAppParams({
    required this.kind,
    this.options,
    this.attributes,
  });

  WindowAppParams.docsViewerApp(
    String scenePath,
    List<Scene> scenes,
    String title,
  ) : this(
          kind: kindDocsViewer,
          options: <String, dynamic>{
            "scenePath": scenePath,
            "scenes": scenes,
            "title": title,
          },
        );

  WindowAppParams.slideApp(
    String scenePath,
    List<Scene> scenes,
    String title,
  ) : this(
          kind: kindSlide,
          options: <String, dynamic>{
            "scenePath": scenePath,
            "scenes": scenes,
            "title": title,
          },
        );

  WindowAppParams.mediaPlayerApp(
    String src,
    String title,
  ) : this(
          kind: kindMediaPlayer,
          options: <String, dynamic>{
            "title": title,
          },
          attributes: <String, dynamic>{
            "src": src,
          },
        );

  final String kind;
  final Map<String, dynamic>? options;
  final Map<String, dynamic>? attributes;

  Map<String, dynamic> toJson() {
    return {
      "kind": kind,
      if (options != null) "options": jsonEncode(options),
      if (attributes != null) "attributes": jsonEncode(attributes),
    }..removeWhere((key, value) => value == null);
  }
}
