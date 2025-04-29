import 'dart:convert';

import 'package:easy_json_viewer/easy_json_viewer.dart';
import 'package:easy_json_viewer/src/json_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JsonTreeViewer extends StatefulWidget {
  final dynamic json; // JSON data (String or Map)
  final String searchKey; // Key to search for
  final JsonViewerController? controller;
  final Widget Function(JsonNode, int)? customNodeBuilder;
  final JsonViewerThemeMode themeMode;
  final Color highlightColor;
  final Color valueTextColor;
  final Color keyTextColor;

  const JsonTreeViewer({
    super.key,
    required this.json,
    this.controller,
    this.searchKey = '',
    this.customNodeBuilder,
    this.themeMode = JsonViewerThemeMode.auto,
    this.highlightColor = Colors.yellow,
    this.valueTextColor = Colors.black,
    this.keyTextColor = Colors.black,
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
    widget.controller?.addListener(_handleController);
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
          searchKey.isNotEmpty &&
          node.children.isEmpty) {
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
      padding: EdgeInsets.only(left: level * 5.0, top: 4.0, bottom: 4.0),
      child: MouseRegion(
        onEnter: (_) {
          if (kIsWeb ||
              [
                TargetPlatform.macOS,
                TargetPlatform.windows,
                TargetPlatform.linux,
              ].contains(defaultTargetPlatform)) {
            setState(() => node.isHovered = true);
          }
        },
        onExit: (_) {
          if (kIsWeb ||
              [
                TargetPlatform.macOS,
                TargetPlatform.windows,
                TargetPlatform.linux,
              ].contains(defaultTargetPlatform)) {
            setState(() => node.isHovered = false);
          }
        },
        child: GestureDetector(
          onTap: () {
            // Mobile: Tap to copy key + value
            if ([
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(defaultTargetPlatform)) {
              final isComplexType =
                  node.rawValue is Map || node.rawValue is List;
              final copiedContent =
                  isComplexType
                      ? const JsonEncoder.withIndent(
                        '  ',
                      ).convert(node.rawValue)
                      : '${node.key}: ${node.value}';
              Clipboard.setData(ClipboardData(text: copiedContent));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Copied: ${copiedContent.length > 100 ? '${copiedContent.substring(0, 100)}...' : copiedContent}',
                  ),
                ),
              );
            }
          },
          child: Column(
            children: [
              _buildRowForNode(node),
              if (node.isExpanded &&
                  node.isExpandable &&
                  node.children.isNotEmpty)
                Column(
                  children:
                      node.children.map((child) {
                        return _buildNode(child, level + 1);
                      }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowForNode(JsonNode node) {
    return Row(
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
            color: widget.keyTextColor,
          ),
        ),

        const SizedBox(width: 2),

        // Separator :
        Text(": "),

        const SizedBox(width: 5),

        // Value + Copy button (if hover)
        Stack(
          children: [
            Text(
              '${node.value}',
              overflow: TextOverflow.visible,
              maxLines: null,
              style: TextStyle(
                color:
                    node.isHighlighted
                        ? widget.highlightColor
                        : widget.valueTextColor,
              ),
            ),
            if ((kIsWeb ||
                    [
                      TargetPlatform.macOS,
                      TargetPlatform.windows,
                      TargetPlatform.linux,
                    ].contains(defaultTargetPlatform)) &&
                node.isHovered)
              Positioned(
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.copy, size: 16),
                  onPressed: () {
                    final isComplexType =
                        node.rawValue is Map || node.rawValue is List;
                    final copiedContent =
                        isComplexType
                            ? const JsonEncoder.withIndent(
                              '  ',
                            ).convert(node.rawValue)
                            : '${node.key}: ${node.value}';
                    Clipboard.setData(ClipboardData(text: copiedContent));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Copied: ${copiedContent.length > 100 ? '${copiedContent.substring(0, 100)}...' : copiedContent}',
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ],
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
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleController);
      widget.controller?.addListener(_handleController);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleController);
    super.dispose();
  }

  void _handleController() {
    if (widget.controller == null) return;

    if (widget.controller!.expandAllRequested) {
      _setExpandCollapseAll(true);
      widget.controller!.reset();
    } else if (widget.controller!.collapseAllRequested) {
      _setExpandCollapseAll(false);
      widget.controller!.reset();
    }
  }

  void _setExpandCollapseAll(bool expand) {
    setState(() {
      _toggleExpandAll(_jsonTree, expand);
    });
  }

  void _toggleExpandAll(List<JsonNode> nodes, bool expand) {
    for (var node in nodes) {
      if (node.isExpandable) {
        node.isExpanded = expand;
        _toggleExpandAll(node.children, expand);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicWidth(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            controller: _scrollController,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _jsonTree.map((node) => _buildNode(node, 0)).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
