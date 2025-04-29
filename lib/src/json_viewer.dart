import 'package:easy_json_viewer/src/json_viewer_controller.dart';
import 'package:flutter/material.dart';
import 'json_node.dart';
import 'json_tree_view.dart';

enum JsonViewerThemeMode { light, dark, auto }

class JsonViewer extends StatelessWidget {
  final dynamic json;
  final JsonViewerController? controller;
  final Widget Function(JsonNode, int)? customNodeBuilder;
  final JsonViewerThemeMode themeMode;
  final Color highlightColor;

  const JsonViewer({
    super.key,
    required this.json,
    this.controller,
    this.customNodeBuilder,
    this.themeMode = JsonViewerThemeMode.auto,
    this.highlightColor = Colors.yellow,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('JSON Viewer')),
      body: JsonTreeViewer(
        json: json,
        themeMode: themeMode,
        customNodeBuilder: customNodeBuilder,
        highlightColor: highlightColor,
      ),
    );
  }
}
