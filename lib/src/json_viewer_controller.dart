import 'package:flutter/foundation.dart';

class JsonViewerController extends ChangeNotifier {
  bool _expandAll = false;
  bool _collapseAll = false;

  /// Request to expand all nodes
  void expandAll() {
    _expandAll = true;
    _collapseAll = false;
    notifyListeners();
  }

  /// Request to collapse all nodes
  void collapseAll() {
    _expandAll = false;
    _collapseAll = true;
    notifyListeners();
  }

  bool get expandAllRequested => _expandAll;
  bool get collapseAllRequested => _collapseAll;

  void reset() {
    _expandAll = false;
    _collapseAll = false;
  }
}
