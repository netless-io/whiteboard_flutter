class PageState {
  PageState({
    required this.index,
    required this.length,
  });

  final int index;
  final int length;

  PageState.fromJson(Map<String, dynamic> json)
      : this(
          index: json["index"],
          length: json["length"],
        );

  Map<String, dynamic> toJson() {
    return {
      "index": index,
      "length": length,
    };
  }
}
