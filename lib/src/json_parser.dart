import 'json_node.dart';

/// Parse a dynamic JSON into a list of JsonNode.
List<JsonNode> parseJson(dynamic json, bool isSort) {
  if (json is Map<String, dynamic>) {
    Map<String, dynamic> sortedJson = json;
    if (isSort) {
      sortedJson = Map.fromEntries(
        json.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      );
    }
    return sortedJson.entries.map((entry) {
      final value = entry.value;
      return JsonNode(
        key: entry.key,
        value: _getNodeValue(value),
        rawValue: value,
        children: _parseChildren(value, isSort),
        isExpandable: _isExpandable(value),
      );
    }).toList();
  } else if (json is List) {
    List<dynamic> sortedJson = json;
    if (isSort) {
      sortedJson = List.from(json)
        ..sort((a, b) => a.toString().compareTo(b.toString()));
    }
    return sortedJson.asMap().entries.map((entry) {
      final value = entry.value;
      return JsonNode(
        key: '[${entry.key}]',
        value: _getNodeValue(value),
        rawValue: value,
        children: _parseChildren(value, isSort),
        isExpandable: _isExpandable(value),
      );
    }).toList();
  } else {
    return [];
  }
}

dynamic _getNodeValue(dynamic value) {
  if (value == null) {
    return "null";
  } else if (value is Map<String, dynamic>) {
    return "{...}";
  } else if (value is List) {
    return "${value.length} items";
  } else {
    return value; // Primitive value: String, int, double, bool
  }
}

/// Determine if a node is expandable.
bool _isExpandable(dynamic value) {
  return value is Map<String, dynamic> || value is List;
}

/// Recursively parse children if needed.
List<JsonNode> _parseChildren(dynamic value, bool isSort) {
  if (value is Map<String, dynamic>) {
    return parseJson(value, isSort);
  } else if (value is List) {
    return parseJson(value, isSort);
  } else {
    return [];
  }
}
