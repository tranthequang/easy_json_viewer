# easy_json_viewer

[![Pub Version](https://img.shields.io/pub/v/easy_json_viewer.svg)](https://pub.dev/packages/easy_json_viewer)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A lightweight and flexible Flutter package to visualize JSON data.  
Supports expand/collapse nodes, customizable node rendering, external search control, theme customization, highlight, smooth animations, and copy functionality.

---

## ✨ Features

- Render JSON from `String`, `Map`, or `List`.
- Expand/Collapse individual nodes and entire tree.
- Smooth expand/collapse animations.
- Customize node widget rendering.
- Highlight search results with customizable highlight colors.
- Dark, Light, and Auto themes support.
- Copy node value (tap on mobile or hover on web/desktop).
- Scroll to the first matched search result.
- Null values are handled and displayed properly.

---

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

## 🛠 Usage

```dart
import 'package:easy_json_viewer/easy_json_viewer.dart';

...

JsonViewer(
  json: yourJsonData, // Can be a JSON String or a Map/List object
  enableSearch: true,
  themeMode: JsonViewerThemeMode.auto, // Options: auto, light, dark
  highlightColor: Colors.yellow,       // Highlight color for search matches
  customNodeBuilder: (node, level) {
    return Text('${node.key}: ${node.value}');
  },
);
```

Where `yourJsonData` can be:
- A raw JSON String
- A parsed `Map<String, dynamic>`
- A `List<dynamic>`

---

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

## 📝 License

This project is licensed under the [MIT License](LICENSE).

---

## ❤️ Contributions

Pull requests are welcome! Feel free to open an issue if you want to suggest improvements or report bugs.

---