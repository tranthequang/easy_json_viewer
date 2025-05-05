import 'package:flutter/foundation.dart';

class JsonViewerController extends ChangeNotifier {
  bool _expandAll = false;
  bool _collapseAll = false;
  void Function()? nextResult;
  void Function()? previousResult;

  void goToNext() => nextResult?.call();
  void goToPrevious() => previousResult?.call();

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
