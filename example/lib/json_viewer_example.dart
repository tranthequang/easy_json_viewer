import 'dart:developer';

import 'package:easy_json_viewer/easy_json_viewer.dart';
import 'package:flutter/material.dart';

class JsonTreeExample extends StatefulWidget {
  const JsonTreeExample({super.key});

  @override
  State<JsonTreeExample> createState() => _JsonTreeExampleState();
}

class _JsonTreeExampleState extends State<JsonTreeExample> {
  final TextEditingController _searchController = TextEditingController();
  final controller = JsonViewerController();
  String _searchKey = '';
  final Map<String, dynamic> sampleJson = {
    "name": "John Doe",
    "age": 30,
    "address": {"street": "123 Main St", "city": "New York"},
    "hobbies": ["reading", "traveling", "coding"],
    "addresses": [
      {"street": "123 Main St", "city": "New York"},
      {"street": "456 Elm St", "city": "Los Angeles"},
    ],
  };

  // Method to update the search key
  void _updateSearchKey(String searchKey) {
    setState(() {
      _searchKey = searchKey;
      if (_searchKey.isNotEmpty) {
        controller.expandAll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON Viewer Example'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 200,
              child: TextField(
                controller: _searchController,
                onChanged: _updateSearchKey,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            spacing: 10,
            children: [
              ElevatedButton(
                onPressed: () {
                  controller.expandAll();
                },
                child: const Text('Expand All'),
              ),
              ElevatedButton(
                onPressed: () {
                  controller.collapseAll();
                },
                child: const Text('Collapse All'),
              ),
              ElevatedButton(
                onPressed: () {
                  controller.goToNext();
                },
                child: const Text('Next Result'),
              ),
            ],
          ),
          Expanded(
            child: JsonTreeViewer(
              json: sampleJson, // Your JSON data (String or Map)
              searchKey: _searchKey, // Key to search for
              controller: controller,
              onResultSearch: (numRessult) {
                log('Found $numRessult results');
              },
            ),
          ),
        ],
      ),
    );
  }
}
