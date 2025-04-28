/// Represents a node in the JSON tree.
class JsonNode {
  final String key;
  final dynamic value;
  final List<JsonNode> children;
  bool isExpanded;
  final bool isExpandable;
  bool isHighlighted;

  JsonNode({
    required this.key,
    required this.value,
    this.children = const [],
    this.isExpanded = false,
    this.isExpandable = false,
    this.isHighlighted = false,
  });

  factory JsonNode.fromJson(dynamic json, {String key = ''}) {
    if (json is Map) {
      List<JsonNode> children = [];
      json.forEach((key, value) {
        children.add(JsonNode.fromJson(value, key: key));
      });
      return JsonNode(
        key: key,
        value: '',
        children: children,
        isExpanded: true,
      );
    } else if (json is List) {
      List<JsonNode> children = [];
      for (var item in json) {
        children.add(
          JsonNode.fromJson(item, key: json.indexOf(item).toString()),
        );
      }
      return JsonNode(
        key: key,
        value: '',
        children: children,
        isExpanded: true,
      );
    } else if (json is String) {
      return JsonNode(key: key, value: json, isExpanded: false);
    } else if (json is num) {
      return JsonNode(key: key, value: json, isExpanded: false);
    } else if (json is bool) {
      return JsonNode(key: key, value: json, isExpanded: false);
    } else {
      return JsonNode(key: key, value: json, isExpanded: false);
    }
  }
}
