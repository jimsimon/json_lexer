# json_lexer
A JSON lexer written in Dart.

Features
----------
* Written entirely in Dart
* Works on both the VM and the browser (via dart2js)
* Handles escaped JSON strings

Example Usage
-------------
```dart
import "package:json_lexer/json_lexer.dart";

main() {
    Queue<Token> tokens = new JsonLexer(json).tokens;
    while (tokens.isNotEmpty) {
      Token token = tokens.removeFirst();
      print("Type: ${token.type}");
      print("Value Type: ${token.valueType}");
      print("Value: ${token.value}");
    }
}
```