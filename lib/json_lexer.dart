library json_lexer;

import "dart:collection";
import "dart:convert";

enum ValueType {
  NUMBER,
  BOOL,
  STRING,
  BEGIN_OBJECT,
  END_OBJECT,
  BEGIN_ARRAY,
  END_ARRAY,
  NULL,
  VALUE_SEPARATOR,
  NAME_SEPARATOR
}

enum TokenType {
  VALUE,
  BEGIN_OBJECT,
  END_OBJECT,
  BEGIN_ARRAY,
  END_ARRAY,
  VALUE_SEPARATOR,
  NAME_SEPARATOR,
  EOF
}

RegExp _WHITESPACE = new RegExp(r"^\s$");

const List _numberCharacters = const ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", "e", "E", "."];

const Map<String, ValueType> _valueTypeMap = const {
  "0": ValueType.NUMBER,
  "1": ValueType.NUMBER,
  "2": ValueType.NUMBER,
  "3": ValueType.NUMBER,
  "4": ValueType.NUMBER,
  "5": ValueType.NUMBER,
  "6": ValueType.NUMBER,
  "7": ValueType.NUMBER,
  "8": ValueType.NUMBER,
  "9": ValueType.NUMBER,
  "-": ValueType.NUMBER,
  "t": ValueType.BOOL,
  "f": ValueType.BOOL,
  "{": ValueType.BEGIN_OBJECT,
  "}": ValueType.END_OBJECT,
  "[": ValueType.BEGIN_ARRAY,
  "]": ValueType.END_ARRAY,
  "n": ValueType.NULL,
  ",": ValueType.VALUE_SEPARATOR,
  ":": ValueType.NAME_SEPARATOR,
  '"': ValueType.STRING
};

const Map<String, TokenType> _tokenTypeMap = const {
  "0": TokenType.VALUE,
  "1": TokenType.VALUE,
  "2": TokenType.VALUE,
  "3": TokenType.VALUE,
  "4": TokenType.VALUE,
  "5": TokenType.VALUE,
  "6": TokenType.VALUE,
  "7": TokenType.VALUE,
  "8": TokenType.VALUE,
  "9": TokenType.VALUE,
  "-": TokenType.VALUE,
  "t": TokenType.VALUE,
  "f": TokenType.VALUE,
  "{": TokenType.BEGIN_OBJECT,
  "}": TokenType.END_OBJECT,
  "[": TokenType.BEGIN_ARRAY,
  "]": TokenType.END_ARRAY,
  "n": TokenType.VALUE,
  ",": TokenType.VALUE_SEPARATOR,
  ":": TokenType.NAME_SEPARATOR,
  '"': TokenType.VALUE
};


class Token {
  ValueType valueType;
  String value;
  TokenType type;
}

class LexerException implements Exception {
  String msg;

  LexerException(String this.msg);
  
  String toString() => msg == null ? '' : msg;
}

class JsonLexer {

  int _index = 0;
  String _json;
  Queue<Token> tokens;

  JsonLexer(String this._json) {
    tokens = _convertJsonStringToTokens();
  }

  String _consumeCharacter() {
    String character = _json[_index];
    _index++;
    return character;
  }

  String _consumeCharacters(int count) {
    String fragment = _json.substring(_index, _index + count);
    _index += count;
    return fragment;
  }

  String _peekCharacter() {
    if (_index == _json.length) {
      return null;
    }
    return _json[_index];
  }

  void _consumeWhitespace() {
    while (_WHITESPACE.hasMatch(_peekCharacter())) {
      _consumeCharacter();
    }
  }

  Queue<Token> _convertJsonStringToTokens() {
    Queue<Token> tokens = new Queue();
    while(_index != _json.length) {
      _consumeWhitespace();
      String character = _peekCharacter();

      String value;
      ValueType valueType = _valueTypeMap[character];
      TokenType tokenType = _tokenTypeMap[character];
      switch (valueType) {
        case ValueType.NUMBER:
          value = _parseNumber();
          break;
        case ValueType.BOOL:
          value = _parseBool();
          break;
        case ValueType.NULL:
          value = _parseNull();
          break;
        case ValueType.STRING:
          value = _parseString();
          break;
        case ValueType.BEGIN_OBJECT:
        case ValueType.END_OBJECT:
        case ValueType.BEGIN_ARRAY:
        case ValueType.END_ARRAY:
        case ValueType.NAME_SEPARATOR:
        case ValueType.VALUE_SEPARATOR:
          value = _consumeCharacter();
          break;
        default:
          throw new LexerException("Syntax Error: Unexpected token $character");
      }

      Token token = new Token();
      token.valueType = valueType;
      token.value = value;
      token.type = tokenType;
      tokens.add(token);
    }
    tokens.add(new Token()..type=TokenType.EOF);
    return tokens;
  }

  String _parseNumber() {
    String number = "";

    while(_numberCharacters.contains(_peekCharacter())) {
      number += _consumeCharacter();
    }
    return number;
  }

  String _parseString() {
    _consumeCharacter(); //We don't care about the starting quotation mark
    String string = "";
    String character = _consumeCharacter();
    while (character != '"') {
      if (character == r"\") {
        string += _parseEscapedStringFragment();
      } else {
        string += character;
      }
      if (_index == _json.length) {
        throw new LexerException("Invalid json fragment encountered: $string");
      }
      character = _consumeCharacter();
    }
    return string;
  }

  String _parseEscapedStringFragment() {
    String character = _consumeCharacter();
    switch (character) {
      case '"':
      case r'\':
      case '/':
        return character;
      case 'b':
        return '\b';
      case 'f':
        return '\f';
      case 'n':
        return '\n';
      case 'r':
        return '\r';
      case 't':
        return '\t';
      case 'u':
        int remainingLength = _json.length - _index;
        if (remainingLength >= 4) {
          var hexString = _consumeCharacters(4);
          var hexInt = int.parse(hexString, radix: 16);
          return UTF8.decode([hexInt]);
        }
        throw new LexerException("Invalid json fragment encountered: $_json");
      default:
        throw new LexerException("Syntax Error: Unexpected token $character");
    }
  }

  String _parseBool() {
    String fragment = _consumeCharacters(4);
    if (fragment == "true") {
      return "true";
    } else if (fragment == "fals" && _consumeCharacter() == "e") {
      return "false";
    }
    throw new LexerException("Invalid json fragment encountered: $fragment");
  }

  String _parseNull() {
    String fragment = _consumeCharacters(4);
    if (fragment == "null") {
      return "null";
    }
    throw new LexerException("Invalid json fragment encountered: $fragment");
  }
}