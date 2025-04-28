import 'json_node.dart';

/// Parse a dynamic JSON into a list of JsonNode.
List<JsonNode> parseJson(dynamic json) {
  if (json is Map<String, dynamic>) {
    return json.entries.map((entry) {
      final value = entry.value;
      return JsonNode(
        key: entry.key,
        value: _getNodeValue(value),
        children: _parseChildren(value),
        isExpandable: _isExpandable(value),
      );
    }).toList();
  } else if (json is List) {
    return json.asMap().entries.map((entry) {
      final value = entry.value;
      return JsonNode(
        key: '[${entry.key}]',
        value: _getNodeValue(value),
        children: _parseChildren(value),
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
List<JsonNode> _parseChildren(dynamic value) {
  if (value is Map<String, dynamic>) {
    return parseJson(value);
  } else if (value is List) {
    return parseJson(value);
  } else {
    return [];
  }
}
