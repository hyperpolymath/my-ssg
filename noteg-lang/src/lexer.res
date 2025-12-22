// SPDX-License-Identifier: AGPL-3.0-or-later
// SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
// NoteG Language - Lexer

// ============================================================================
// Token Types
// ============================================================================

type tokenKind =
  // Literals
  | TString(string)
  | TNumber(float)
  | TBool(bool)
  | TNull
  // Identifiers
  | TIdent(string)
  // Keywords
  | TLet
  | TConst
  | TFn
  | TIf
  | TThen
  | TElse
  | TMatch
  | TWith
  | TType
  | TModule
  | TImport
  | TExport
  // Operators
  | TPlus
  | TMinus
  | TStar
  | TSlash
  | TPercent
  | TEq
  | TEqEq
  | TNotEq
  | TLt
  | TLtEq
  | TGt
  | TGtEq
  | TAnd
  | TOr
  | TNot
  | TPipe
  | TArrow
  | TFatArrow
  // Delimiters
  | TLParen
  | TRParen
  | TLBrace
  | TRBrace
  | TLBracket
  | TRBracket
  | TComma
  | TColon
  | TSemicolon
  | TDot
  // Template syntax
  | TTemplateStart  // {{
  | TTemplateEnd    // }}
  // Special
  | TNewline
  | TEOF
  | TError(string)

type position = {
  line: int,
  column: int,
  offset: int,
}

type token = {
  kind: tokenKind,
  lexeme: string,
  start: position,
  end_: position,
}

type lexerState = {
  source: string,
  mutable pos: int,
  mutable line: int,
  mutable column: int,
}

// ============================================================================
// Lexer Implementation
// ============================================================================

let createLexer = (source: string): lexerState => {
  {
    source,
    pos: 0,
    line: 1,
    column: 1,
  }
}

let isAtEnd = (lexer: lexerState): bool => {
  lexer.pos >= lexer.source->String.length
}

let peek = (lexer: lexerState): option<string> => {
  if isAtEnd(lexer) {
    None
  } else {
    Some(lexer.source->String.charAt(lexer.pos))
  }
}

let peekNext = (lexer: lexerState): option<string> => {
  if lexer.pos + 1 >= lexer.source->String.length {
    None
  } else {
    Some(lexer.source->String.charAt(lexer.pos + 1))
  }
}

let advance = (lexer: lexerState): string => {
  let c = lexer.source->String.charAt(lexer.pos)
  lexer.pos = lexer.pos + 1
  if c == "\n" {
    lexer.line = lexer.line + 1
    lexer.column = 1
  } else {
    lexer.column = lexer.column + 1
  }
  c
}

let currentPosition = (lexer: lexerState): position => {
  {line: lexer.line, column: lexer.column, offset: lexer.pos}
}

let isDigit = (c: string): bool => {
  c >= "0" && c <= "9"
}

let isAlpha = (c: string): bool => {
  (c >= "a" && c <= "z") || (c >= "A" && c <= "Z") || c == "_"
}

let isAlphaNumeric = (c: string): bool => {
  isAlpha(c) || isDigit(c)
}

let skipWhitespace = (lexer: lexerState): unit => {
  let rec loop = () => {
    switch peek(lexer) {
    | Some(" ") | Some("\t") | Some("\r") =>
      let _ = advance(lexer)
      loop()
    | Some("/") =>
      switch peekNext(lexer) {
      | Some("/") =>
        // Line comment
        while !isAtEnd(lexer) && peek(lexer) != Some("\n") {
          let _ = advance(lexer)
        }
        loop()
      | _ => ()
      }
    | _ => ()
    }
  }
  loop()
}

let scanString = (lexer: lexerState): token => {
  let start = currentPosition(lexer)
  let _ = advance(lexer) // consume opening quote
  let buffer = ref("")

  while !isAtEnd(lexer) && peek(lexer) != Some("\"") {
    let c = advance(lexer)
    if c == "\\" {
      switch peek(lexer) {
      | Some("n") =>
        let _ = advance(lexer)
        buffer := buffer.contents ++ "\n"
      | Some("t") =>
        let _ = advance(lexer)
        buffer := buffer.contents ++ "\t"
      | Some("\\") =>
        let _ = advance(lexer)
        buffer := buffer.contents ++ "\\"
      | Some("\"") =>
        let _ = advance(lexer)
        buffer := buffer.contents ++ "\""
      | _ => buffer := buffer.contents ++ c
      }
    } else {
      buffer := buffer.contents ++ c
    }
  }

  if isAtEnd(lexer) {
    {kind: TError("Unterminated string"), lexeme: buffer.contents, start, end_: currentPosition(lexer)}
  } else {
    let _ = advance(lexer) // consume closing quote
    {kind: TString(buffer.contents), lexeme: `"${buffer.contents}"`, start, end_: currentPosition(lexer)}
  }
}

let scanNumber = (lexer: lexerState): token => {
  let start = currentPosition(lexer)
  let buffer = ref("")

  while !isAtEnd(lexer) && isDigit(peek(lexer)->Option.getOr("")) {
    buffer := buffer.contents ++ advance(lexer)
  }

  if peek(lexer) == Some(".") && isDigit(peekNext(lexer)->Option.getOr("")) {
    buffer := buffer.contents ++ advance(lexer) // consume .
    while !isAtEnd(lexer) && isDigit(peek(lexer)->Option.getOr("")) {
      buffer := buffer.contents ++ advance(lexer)
    }
  }

  let value = buffer.contents->Float.fromString->Option.getOr(0.0)
  {kind: TNumber(value), lexeme: buffer.contents, start, end_: currentPosition(lexer)}
}

let scanIdentifier = (lexer: lexerState): token => {
  let start = currentPosition(lexer)
  let buffer = ref("")

  while !isAtEnd(lexer) && isAlphaNumeric(peek(lexer)->Option.getOr("")) {
    buffer := buffer.contents ++ advance(lexer)
  }

  let kind = switch buffer.contents {
  | "let" => TLet
  | "const" => TConst
  | "fn" => TFn
  | "if" => TIf
  | "then" => TThen
  | "else" => TElse
  | "match" => TMatch
  | "with" => TWith
  | "type" => TType
  | "module" => TModule
  | "import" => TImport
  | "export" => TExport
  | "true" => TBool(true)
  | "false" => TBool(false)
  | "null" => TNull
  | ident => TIdent(ident)
  }

  {kind, lexeme: buffer.contents, start, end_: currentPosition(lexer)}
}

let scanToken = (lexer: lexerState): token => {
  skipWhitespace(lexer)

  if isAtEnd(lexer) {
    let pos = currentPosition(lexer)
    {kind: TEOF, lexeme: "", start: pos, end_: pos}
  } else {
    let start = currentPosition(lexer)
    let c = advance(lexer)

    switch c {
    | "(" => {kind: TLParen, lexeme: "(", start, end_: currentPosition(lexer)}
    | ")" => {kind: TRParen, lexeme: ")", start, end_: currentPosition(lexer)}
    | "{" =>
      if peek(lexer) == Some("{") {
        let _ = advance(lexer)
        {kind: TTemplateStart, lexeme: "{{", start, end_: currentPosition(lexer)}
      } else {
        {kind: TLBrace, lexeme: "{", start, end_: currentPosition(lexer)}
      }
    | "}" =>
      if peek(lexer) == Some("}") {
        let _ = advance(lexer)
        {kind: TTemplateEnd, lexeme: "}}", start, end_: currentPosition(lexer)}
      } else {
        {kind: TRBrace, lexeme: "}", start, end_: currentPosition(lexer)}
      }
    | "[" => {kind: TLBracket, lexeme: "[", start, end_: currentPosition(lexer)}
    | "]" => {kind: TRBracket, lexeme: "]", start, end_: currentPosition(lexer)}
    | "," => {kind: TComma, lexeme: ",", start, end_: currentPosition(lexer)}
    | ":" => {kind: TColon, lexeme: ":", start, end_: currentPosition(lexer)}
    | ";" => {kind: TSemicolon, lexeme: ";", start, end_: currentPosition(lexer)}
    | "." => {kind: TDot, lexeme: ".", start, end_: currentPosition(lexer)}
    | "+" => {kind: TPlus, lexeme: "+", start, end_: currentPosition(lexer)}
    | "-" =>
      if peek(lexer) == Some(">") {
        let _ = advance(lexer)
        {kind: TArrow, lexeme: "->", start, end_: currentPosition(lexer)}
      } else {
        {kind: TMinus, lexeme: "-", start, end_: currentPosition(lexer)}
      }
    | "*" => {kind: TStar, lexeme: "*", start, end_: currentPosition(lexer)}
    | "/" => {kind: TSlash, lexeme: "/", start, end_: currentPosition(lexer)}
    | "%" => {kind: TPercent, lexeme: "%", start, end_: currentPosition(lexer)}
    | "=" =>
      if peek(lexer) == Some("=") {
        let _ = advance(lexer)
        {kind: TEqEq, lexeme: "==", start, end_: currentPosition(lexer)}
      } else if peek(lexer) == Some(">") {
        let _ = advance(lexer)
        {kind: TFatArrow, lexeme: "=>", start, end_: currentPosition(lexer)}
      } else {
        {kind: TEq, lexeme: "=", start, end_: currentPosition(lexer)}
      }
    | "!" =>
      if peek(lexer) == Some("=") {
        let _ = advance(lexer)
        {kind: TNotEq, lexeme: "!=", start, end_: currentPosition(lexer)}
      } else {
        {kind: TNot, lexeme: "!", start, end_: currentPosition(lexer)}
      }
    | "<" =>
      if peek(lexer) == Some("=") {
        let _ = advance(lexer)
        {kind: TLtEq, lexeme: "<=", start, end_: currentPosition(lexer)}
      } else {
        {kind: TLt, lexeme: "<", start, end_: currentPosition(lexer)}
      }
    | ">" =>
      if peek(lexer) == Some("=") {
        let _ = advance(lexer)
        {kind: TGtEq, lexeme: ">=", start, end_: currentPosition(lexer)}
      } else {
        {kind: TGt, lexeme: ">", start, end_: currentPosition(lexer)}
      }
    | "&" =>
      if peek(lexer) == Some("&") {
        let _ = advance(lexer)
        {kind: TAnd, lexeme: "&&", start, end_: currentPosition(lexer)}
      } else {
        {kind: TError("Unexpected character: &"), lexeme: "&", start, end_: currentPosition(lexer)}
      }
    | "|" =>
      if peek(lexer) == Some("|") {
        let _ = advance(lexer)
        {kind: TOr, lexeme: "||", start, end_: currentPosition(lexer)}
      } else if peek(lexer) == Some(">") {
        let _ = advance(lexer)
        {kind: TPipe, lexeme: "|>", start, end_: currentPosition(lexer)}
      } else {
        {kind: TError("Unexpected character: |"), lexeme: "|", start, end_: currentPosition(lexer)}
      }
    | "\n" => {kind: TNewline, lexeme: "\\n", start, end_: currentPosition(lexer)}
    | "\"" =>
      // Back up one position to include the quote in scanString
      lexer.pos = lexer.pos - 1
      lexer.column = lexer.column - 1
      scanString(lexer)
    | _ =>
      if isDigit(c) {
        lexer.pos = lexer.pos - 1
        lexer.column = lexer.column - 1
        scanNumber(lexer)
      } else if isAlpha(c) {
        lexer.pos = lexer.pos - 1
        lexer.column = lexer.column - 1
        scanIdentifier(lexer)
      } else {
        {kind: TError(`Unexpected character: ${c}`), lexeme: c, start, end_: currentPosition(lexer)}
      }
    }
  }
}

let tokenize = (source: string): array<token> => {
  let lexer = createLexer(source)
  let tokens = ref([])

  let rec loop = () => {
    let token = scanToken(lexer)
    tokens := tokens.contents->Array.concat([token])
    switch token.kind {
    | TEOF => ()
    | _ => loop()
    }
  }

  loop()
  tokens.contents
}
