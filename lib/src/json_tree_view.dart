import 'dart:convert';

import 'package:easy_json_viewer/easy_json_viewer.dart';
import 'package:easy_json_viewer/src/json_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum JsonViewerThemeMode { light, dark, auto }

class JsonTreeViewer extends StatefulWidget {
  final dynamic json; // JSON data (String or Map)
  final String searchKey; // Key to search for
  final JsonViewerController? controller;
  final JsonViewerThemeMode themeMode;
  final Color highlightColor;
  final Color valueTextColor;
  final Color focusColor;
  final Color keyTextColor;
  final bool isSort;
  final Function(int)? onResultSearch;
  final Function(int)? onResultIndex;

  const JsonTreeViewer({
    super.key,
    required this.json,
    this.controller,
    this.searchKey = '',
    this.themeMode = JsonViewerThemeMode.auto,
    this.highlightColor = Colors.yellow,
    this.focusColor = Colors.grey,
    this.valueTextColor = Colors.black,
    this.keyTextColor = Colors.black,
    this.isSort = false,
    this.onResultSearch,
    this.onResultIndex,
  });

  @override
  State<JsonTreeViewer> createState() => _JsonTreeViewerState();
}

class _JsonTreeViewerState extends State<JsonTreeViewer> {
  late List<JsonNode> _jsonTree;

  final List<JsonNode> _searchResults = [];
  int _currentSearchIndex = 0;
  final Map<JsonNode, GlobalKey> _nodeKeys = {};

  @override
  void initState() {
    super.initState();
    _jsonTree = parseJson(widget.json, widget.isSort); // Parse the input JSON
    widget.controller?.addListener(_handleController);
    widget.controller?.nextResult = _handleNext;
    widget.controller?.previousResult = _handlePrevious;
  }

  // Method to search nodes and highlight matching results
  void _searchAndHighlight(String searchKey) {
    _searchResults.clear();
    _searchInNode(_jsonTree, searchKey);
    _currentSearchIndex = 0;
    if (_searchResults.isNotEmpty) {
      _scrollToHighlighted(_searchResults[_currentSearchIndex]);
    }
  }

  // Recursively search for the searchKey and highlight nodes
  void _searchInNode(List<JsonNode> nodes, String searchKey) {
    for (var node in nodes) {
      if ((node.key.contains(searchKey) ||
              (node.value?.toString().contains(searchKey) ?? false)) &&
          searchKey.isNotEmpty &&
          node.children.isEmpty) {
        _searchResults.add(node);
        node.isHighlighted = true; // Mark node as highlighted
      } else {
        node.isHighlighted = false; // Reset highlight
      }

      // Recursively search in children if any
      if (node.children.isNotEmpty) {
        _searchInNode(node.children, searchKey);
      }
      widget.onResultSearch?.call(_searchResults.length);
    }
  }

  void _handleNext() {
    if (_searchResults.isEmpty) return;
    _currentSearchIndex = (_currentSearchIndex + 1) % _searchResults.length;
    _scrollToHighlighted(_searchResults[_currentSearchIndex]);
    widget.onResultIndex?.call(_currentSearchIndex);
  }

  void _handlePrevious() {
    if (_searchResults.isEmpty) return;
    _currentSearchIndex =
        (_currentSearchIndex - 1 + _searchResults.length) %
        _searchResults.length;
    _scrollToHighlighted(_searchResults[_currentSearchIndex]);
    widget.onResultIndex?.call(_currentSearchIndex);
  }

  void _scrollToHighlighted(JsonNode node) {
    if (_searchResults.isEmpty) return;

    final key = _nodeKeys[node];
    if (key == null) return;

    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: Duration(milliseconds: 300),
        alignment: 0.2, // scroll sao cho node nằm gần đầu
        curve: Curves.easeInOut,
      );
    }
    setState(() {});
  }

  // Render each node
  Widget _buildNode(JsonNode node, int level) {
    final key = _nodeKeys.putIfAbsent(node, () => GlobalKey());
    return Padding(
      key: key,
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
            if (node.children.isNotEmpty) {
              setState(() {
                node.isExpanded = !node.isExpanded;
              });
            } else {
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
        Row(
          spacing: 5,
          children: [
            Text(
              '${node.value}',
              overflow: TextOverflow.visible,
              maxLines: null,
              style: TextStyle(
                color: widget.valueTextColor,
                backgroundColor:
                    node.isHighlighted
                        ? _currentSearchIndex == _searchResults.indexOf(node)
                            ? widget.focusColor
                            : widget.highlightColor
                        : Colors.transparent,
              ),
            ),
            if ((kIsWeb ||
                    [
                      TargetPlatform.macOS,
                      TargetPlatform.windows,
                      TargetPlatform.linux,
                    ].contains(defaultTargetPlatform)) &&
                node.isHovered)
              InkWell(
                onTap: () {
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
                child: Icon(Icons.copy, size: 16),
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
    return kIsWeb ||
            [
              TargetPlatform.macOS,
              TargetPlatform.windows,
              TargetPlatform.linux,
            ].contains(defaultTargetPlatform)
        ? _buildContentForWeb()
        : _buildContentForMobile();
  }

  Widget _buildContentForWeb() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _jsonTree.map((node) => _buildNode(node, 0)).toList(),
        ),
      ),
    );
  }

  Widget _buildContentForMobile() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicWidth(
        child: Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
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
