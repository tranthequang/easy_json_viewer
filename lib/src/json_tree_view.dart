import 'dart:developer';

import 'package:easy_json_viewer/easy_json_viewer.dart';
import 'package:easy_json_viewer/src/json_parser.dart';
import 'package:flutter/material.dart';

class JsonTreeViewer extends StatefulWidget {
  final dynamic json; // JSON data (String or Map)
  final String searchKey; // Key to search for
  final Widget Function(JsonNode, int)? customNodeBuilder;
  final JsonViewerThemeMode themeMode;
  final Color highlightColor;
  final Color valueTextColor;

  const JsonTreeViewer({
    super.key,
    required this.json,
    this.searchKey = '',
    this.customNodeBuilder,
    this.themeMode = JsonViewerThemeMode.auto,
    this.highlightColor = Colors.yellow,
    this.valueTextColor = Colors.black,
  });

  @override
  State<JsonTreeViewer> createState() => _JsonTreeViewerState();
}

class _JsonTreeViewerState extends State<JsonTreeViewer> {
  late List<JsonNode> _jsonTree;
  final ScrollController _scrollController =
      ScrollController(); // For scrolling to search result

  @override
  void initState() {
    super.initState();
    _jsonTree = parseJson(widget.json); // Parse the input JSON
    log(_jsonTree.toString());
  }

  // Method to search nodes and highlight matching results
  void _searchAndHighlight(String searchKey) {
    _searchInNode(_jsonTree, searchKey);
  }

  // Recursively search for the searchKey and highlight nodes
  void _searchInNode(List<JsonNode> nodes, String searchKey) {
    for (var node in nodes) {
      if ((node.key.contains(searchKey) ||
              (node.value?.toString().contains(searchKey) ?? false)) &&
          searchKey.isNotEmpty) {
        node.isHighlighted = true; // Mark node as highlighted
      } else {
        node.isHighlighted = false; // Reset highlight
      }

      // Recursively search in children if any
      if (node.children.isNotEmpty) {
        _searchInNode(node.children, searchKey);
      }
    }

    // Scroll to the first highlighted node
    _scrollToFirstHighlightedNode();
  }

  // Scroll to the first highlighted node
  void _scrollToFirstHighlightedNode() {
    for (int i = 0; i < _jsonTree.length; i++) {
      JsonNode node = _jsonTree[i];
      if (node.isHighlighted) {
        // Scroll to the first matching node
        _scrollController.animateTo(
          i * 50.0, // Example offset based on row height (can be adjusted)
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        break;
      }
    }
  }

  // Render each node
  Widget _buildNode(JsonNode node, int level) {
    return Padding(
      padding: EdgeInsets.only(left: level * 16.0, top: 4.0, bottom: 4.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Expand/Collapse Icon
              if (node.isExpandable)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      node.isExpanded = !node.isExpanded;
                    });
                  },
                  child: Icon(
                    node.isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 20,
                  ),
                )
              else
                SizedBox(width: 20),

              // Key
              Text(
                node.key,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      node.isHighlighted ? widget.highlightColor : Colors.black,
                ),
              ),

              const SizedBox(width: 2),

              // Separator :
              Text(": "),

              const SizedBox(width: 5),

              // Value (Flexible to avoid overflow)
              Expanded(
                child: Text(
                  '${node.value}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        node.isHighlighted
                            ? widget.highlightColor
                            : widget.valueTextColor,
                  ),
                  maxLines: 10,
                ),
              ),
            ],
          ),
          if (node.isExpanded && node.isExpandable && node.children.isNotEmpty)
            Column(
              children:
                  node.children.map((child) {
                    return _buildNode(child, level + 1);
                  }).toList(),
            ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(JsonTreeViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchKey != oldWidget.searchKey) {
      _searchAndHighlight(
        widget.searchKey,
      ); // Perform search if searchKey changes
    }
  }

  @override
  Widget build(BuildContext context) {
    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: _jsonTree.map((node) => _buildNode(node, 0)).toList(),
    // );

    return ListView.builder(
      controller: _scrollController, // Assign ScrollController to ListView
      itemCount: _jsonTree.length,
      itemBuilder: (context, index) {
        final node = _jsonTree[index];
        return _buildNode(node, 0);
      },
    );
  }
}
