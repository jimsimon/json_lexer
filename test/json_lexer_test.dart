// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library json_lexer.test;

import 'package:test/test.dart';

import 'package:json_lexer/json_lexer.dart';

void main() {
  test("can handle ints", () {
    JsonLexer lexer = new JsonLexer("2");
    Token token = lexer.tokens.removeFirst();
    expect(token.valueType, ValueType.NUMBER);
    expect(token.value, "2");
  });

  test("can handle doubles", () {
    JsonLexer lexer = new JsonLexer("2.1");
    Token token = lexer.tokens.removeFirst();
    expect(token.valueType, ValueType.NUMBER);
    expect(token.value, "2.1");
  });

  test("can handle Strings", () {
    JsonLexer lexer = new JsonLexer('"hello"');
    Token token = lexer.tokens.removeFirst();
    expect(token.valueType, ValueType.STRING);
    expect(token.value, "hello");
  });

  test("can handle bools", () {
    JsonLexer lexer = new JsonLexer('true');
    Token token = lexer.tokens.removeFirst();
    expect(token.valueType, ValueType.BOOL);
    expect(token.value, "true");

    lexer = new JsonLexer('false');
    token = lexer.tokens.removeFirst();
    expect(token.valueType, ValueType.BOOL);
    expect(token.value, "false");
  });

  test("can handle objects", () {
    JsonLexer lexer = new JsonLexer('{}');
    Token token = lexer.tokens.removeFirst();
    expect(token.valueType, ValueType.BEGIN_OBJECT);
    expect(token.value, "{");

    token = lexer.tokens.removeFirst();
    expect(token.valueType, ValueType.END_OBJECT);
    expect(token.value, "}");
  });

  test("can handle arrays", () {
    JsonLexer lexer = new JsonLexer('[]');
    Token token = lexer.tokens.removeFirst();
    expect(token.valueType, ValueType.BEGIN_ARRAY);
    expect(token.value, "[");

    token = lexer.tokens.removeFirst();
    expect(token.valueType, ValueType.END_ARRAY);
    expect(token.value, "]");
  });

  test("can handle null", () {
    JsonLexer lexer = new JsonLexer('null');
    Token token = lexer.tokens.removeFirst();
    expect(token.valueType, ValueType.NULL);
    expect(token.value, "null");
  });

  test("can handle commas", () {
    JsonLexer lexer = new JsonLexer(',');
    Token token = lexer.tokens.removeFirst();
    expect(token.valueType, ValueType.VALUE_SEPARATOR);
    expect(token.value, ",");
  });

  test("can handle colons", () {
    JsonLexer lexer = new JsonLexer(':');
    Token token = lexer.tokens.removeFirst();
    expect(token.valueType, ValueType.NAME_SEPARATOR);
    expect(token.value, ":");
  });

  test("throws error for bad input", () {
    expect(() => new JsonLexer('bad'), throwsA(new isInstanceOf<LexerException>()));
  });

  test("can handle input with multiple tokens", () {
    JsonLexer lexer = new JsonLexer('{}');
    Token token = lexer.tokens.removeFirst();
    expect(token.valueType, ValueType.BEGIN_OBJECT);
    expect(token.value, "{");

    token = lexer.tokens.removeFirst();
    expect(token.valueType, ValueType.END_OBJECT);
    expect(token.value, "}");
  });

  test("can handle input with multiple tokens", () {
    JsonLexer lexer = new JsonLexer('{"test": 123}');
    Token token = lexer.tokens.removeFirst();
    expect(token.valueType, ValueType.BEGIN_OBJECT);
    expect(token.value, "{");

    token = lexer.tokens.removeFirst();
    expect(token.valueType, ValueType.STRING);
    expect(token.value, "test");

    token = lexer.tokens.removeFirst();
    expect(token.valueType, ValueType.NAME_SEPARATOR);
    expect(token.value, ":");

    token = lexer.tokens.removeFirst();
    expect(token.valueType, ValueType.NUMBER);
    expect(token.value, "123");

    token = lexer.tokens.removeFirst();
    expect(token.valueType, ValueType.END_OBJECT);
    expect(token.value, "}");
  });

  test("can handle escaped quotation marks", () {
    JsonLexer lexer = new JsonLexer(r'"\""');
    expect(lexer.tokens.first.value, '"');
  });

  test("can handle escaped reverse solidus", () {
    JsonLexer lexer = new JsonLexer(r'"\\"');
    expect(lexer.tokens.first.value, r'\');

  });

  test("can handle escaped solidus", () {
    JsonLexer lexer = new JsonLexer(r'"\/"');
    expect(lexer.tokens.first.value, '/');
  });

  test("can handle escaped backspace", () {
    JsonLexer lexer = new JsonLexer(r'"\b"');
    expect(lexer.tokens.first.value, '\b');
  });

  test("can handle escaped formfeed", () {
    JsonLexer lexer = new JsonLexer(r'"\f"');
    expect(lexer.tokens.first.value, '\f');
  });

  test("can handle escaped newline", () {
    JsonLexer lexer = new JsonLexer(r'"\n"');
    expect(lexer.tokens.first.value, '\n');
  });

  test("can handle escaped carriage return", () {
    JsonLexer lexer = new JsonLexer(r'"\r"');
    expect(lexer.tokens.first.value, '\r');
  });

  test("can handle escaped horizontal tab", () {
    JsonLexer lexer = new JsonLexer(r'"\t"');
    expect(lexer.tokens.first.value, '\t');
  });

  test("can handle escaped unicode sequences", () {
    JsonLexer lexer = new JsonLexer(r'"\u0030"]');
    expect(lexer.tokens.first.value, '0');
  });

  test("can handle a string with multiple escape characters", () {
    JsonLexer lexer = new JsonLexer(r'"\"foo\" is not \"bar\". specials: \b\r\n\f\t\\/"');
    expect(lexer.tokens.first.value, "\"foo\" is not \"bar\". specials: \b\r\n\f\t\\/");
  });
}
