# easy_json_viewer

[![Pub Version](https://img.shields.io/pub/v/easy_json_viewer.svg)](https://pub.dev/packages/easy_json_viewer)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A powerful, customizable, and lightweight Flutter widget to visualize and explore complex JSON data structures with support for search, highlight, copy, theming, and external control.


---

## 🚀 Features

✅ Parse and render JSON data (`String`, `Map`, or `List`) into a beautiful expandable/collapsible tree view  
✅ Dark / Light / Auto theme mode  
✅ Highlight search results with customizable highlight color  
✅ Copy key-value on tap (with full JSON copy for lists/maps)  
✅ Expand/Collapse all nodes from outside the widget  
✅ Scroll to highlighted search results (support for next/previous navigation)  
✅ Smart layout and overflow handling for deeply nested structures  
✅ Compatible across mobile, web, desktop (MacOS, Windows, Linux)  
✅ Search bar & controls can be implemented externally for more flexibility  

---

## 📌 Parameters

| Property | Type | Description |
|---------|------|-------------|
| `json` | `dynamic` | Raw JSON `String`, `Map`, or `List` |
| `controller` | `JsonViewerController?` | Controller for controlling expand/collapse/search externally |
| `themeMode` | `JsonViewerThemeMode` | `auto` (default), `dark`, or `light` |
| `highlightColor` | `Color` | Color used to highlight search matches |

## 🚀 Installation

Add the following line to your `pubspec.yaml`:

```yaml
dependencies:
  easy_json_viewer: ^1.0.0
```

Then run:

```bash
flutter pub get
```

---

## 🧭 External Controller API

Use `JsonViewerController` to interact with the viewer from outside:

```dart
final controller = JsonViewerController();

JsonViewer(
  json: myJson,
  controller: controller,
);

// Navigate search results
controller.goToNext();
controller.goToPrevious();

// Expand/collapse all
controller.expandAll();
controller.collapseAll();
```

## 🔍 Search Integration

- Search is handled **externally** (you provide the UI).
- You call `controller.search(String query)` to trigger highlighting and navigation logic.
- The controller maintains the list of matching nodes and exposes navigation.

## 🧱 Example Usage

```dart
final controller = JsonViewerController();

JsonViewer(
  json: jsonData,
  controller: controller,
  themeMode: JsonViewerThemeMode.auto,
  highlightColor: Colors.orangeAccent,
);

// UI Buttons
ElevatedButton(onPressed: controller.goToNext, child: Text("Next"));
ElevatedButton(onPressed: controller.goToPrevious, child: Text("Previous"));
```

## 📁 JSONNode Model

Each parsed JSON value is wrapped into a `JsonNode` with:

- `String key`
- `dynamic value`
- `List<JsonNode> children`
- `bool isExpanded`
- `bool isExpandable`
- `bool isHighlighted`
- `dynamic rawValue` — (original unprocessed value)


## 🎨 Theme Support

You can easily control the theme appearance:

- `JsonViewerThemeMode.auto` (default): Follows system settings.
- `JsonViewerThemeMode.light`: Forces light mode.
- `JsonViewerThemeMode.dark`: Forces dark mode.

---

## 🔍 Search Functionality

You can implement your own search bar and pass the keyword externally to the widget.

Example:

```dart
String searchKeyword = 'address';

JsonViewer(
  json: yourJsonData,
  externalSearchKey: searchKeyword, // <- Search keyword passed here
);
```

- Highlighted nodes will be styled using the `highlightColor`.
- The viewer will scroll automatically to the first match.

---

## 📋 Copy Functionality

- **Mobile**: Tap a node to copy its value to clipboard.
- **Web/Desktop**: Hover over a node to show a "Copy" button.

---

## 📂 Example

You can find a full working example inside the `example/` folder.

Run it with:

```bash
cd example
flutter run
```

---

## 🧠 Design Decisions

- Layout is scrollable both vertically and horizontally to avoid overflow issues
- `GlobalKey` is assigned to each node for precise scrolling using `Scrollable.ensureVisible()`
- `Flexible` and `Wrap` used to prevent layout overflow on long strings
- The viewer widget is fully decoupled — search, control, and theme are customizable outside

## 🛠️ Upcoming Ideas

- Optional internal search bar
- Animation customizations
- Support for collapsed summary values (e.g., arrays with count preview)

## 📝 License

This project is licensed under the [MIT License](LICENSE).

---

## ❤️ Contributions

Pull requests are welcome! Feel free to open an issue if you want to suggest improvements or report bugs.

---