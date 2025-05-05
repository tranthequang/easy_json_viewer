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
    "project_info": {
      "project_number": "513938456430",
      "project_id": "dones-f1d83",
      "storage_bucket": "dones-f1d83.appspot.com"
    },
    "client": [
      {
        "client_info": {
          "mobilesdk_app_id": "1:513938456430:android:8d08b7447cf27434838b7f",
          "android_client_info": {"package_name": "com.flutter.base"}
        },
        "oauth_client": [
          {
            "client_id":
                "513938456430-9ff6n5c99ap1rq39sojcd8mbcm1dmcn0.apps.googleusercontent.com",
            "client_type": 3
          }
        ],
        "api_key": [
          {"current_key": "AIzaSyAGpg5NO4AKf4vvrzgbthv9oQOalxmOlgc"}
        ],
        "services": {
          "appinvite_service": {
            "other_platform_oauth_client": [
              {
                "client_id":
                    "513938456430-9ff6n5c99ap1rq39sojcd8mbcm1dmcn0.apps.googleusercontent.com",
                "client_type": 3
              },
              {
                "client_id":
                    "513938456430-ll2al9ak1ojncs5lh27h6k9kfoupr18n.apps.googleusercontent.com",
                "client_type": 2,
                "ios_info": {"bundle_id": "com1.flutter.base"}
              },
              {
                "client_id":
                    "513938456430-ll2al9ak1ojncs5lh27h6k9kfoupr18n.apps.googleusercontent.com",
                "client_type": 2,
                "ios_info": {"bundle_id": "com2.flutter.base"}
              },
              {
                "client_id":
                    "513938456430-ll2al9ak1ojncs5lh27h6k9kfoupr18n.apps.googleusercontent.com",
                "client_type": 2,
                "ios_info": {"bundle_id": "com3.flutter.base"}
              },
              {
                "client_id":
                    "513938456430-ll2al9ak1ojncs5lh27h6k9kfoupr18n.apps.googleusercontent.com",
                "client_type": 2,
                "ios_info": {"bundle_id": "com4.flutter.base"}
              },
              {
                "client_id":
                    "513938456430-ll2al9ak1ojncs5lh27h6k9kfoupr18n.apps.googleusercontent.com",
                "client_type": 2,
                "ios_info": {"bundle_id": "com5.flutter.base"}
              },
              {
                "client_id":
                    "513938456430-ll2al9ak1ojncs5lh27h6k9kfoupr18n.apps.googleusercontent.com",
                "client_type": 2,
                "ios_info": {"bundle_id": "com6.flutter.base"}
              }
            ]
          }
        }
      }
    ],
    "configuration_version": "1"
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
