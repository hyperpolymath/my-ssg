// SPDX-License-Identifier: AGPL-3.0-or-later
// SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
// NoteG Language - Parser

open Lexer

// ============================================================================
// AST Types
// ============================================================================

type rec expr =
  | ELiteral(literal)
  | EIdent(string)
  | EBinary(expr, binaryOp, expr)
  | EUnary(unaryOp, expr)
  | ECall(expr, array<expr>)
  | ELambda(array<string>, expr)
  | EIf(expr, expr, option<expr>)
  | EMatch(expr, array<matchArm>)
  | EBlock(array<stmt>)
  | EArray(array<expr>)
  | ERecord(array<(string, expr)>)
  | EAccess(expr, string)
  | EIndex(expr, expr)
  | EPipe(expr, expr)
  | ETemplate(array<templatePart>)

and literal =
  | LString(string)
  | LNumber(float)
  | LBool(bool)
  | LNull

and binaryOp =
  | OpAdd
  | OpSub
  | OpMul
  | OpDiv
  | OpMod
  | OpEq
  | OpNotEq
  | OpLt
  | OpLtEq
  | OpGt
  | OpGtEq
  | OpAnd
  | OpOr

and unaryOp =
  | OpNeg
  | OpNot

and matchArm = {
  pattern: pattern,
  guard: option<expr>,
  body: expr,
}

and pattern =
  | PWildcard
  | PIdent(string)
  | PLiteral(literal)
  | PArray(array<pattern>)
  | PRecord(array<(string, pattern)>)

and templatePart =
  | TpText(string)
  | TpExpr(expr)

and stmt =
  | SLet(string, option<typeAnnotation>, expr)
  | SConst(string, option<typeAnnotation>, expr)
  | SExpr(expr)
  | SType(string, typeAnnotation)
  | SModule(string, array<stmt>)
  | SImport(string, array<string>)
  | SExport(array<string>)

and typeAnnotation =
  | TyIdent(string)
  | TyArray(typeAnnotation)
  | TyFunction(array<typeAnnotation>, typeAnnotation)
  | TyRecord(array<(string, typeAnnotation)>)
  | TyUnion(array<typeAnnotation>)
  | TyOptional(typeAnnotation)

type program = {
  statements: array<stmt>,
}

// ============================================================================
// Parser State
// ============================================================================

type parseError = {
  message: string,
  position: position,
}

type parserState = {
  tokens: array<token>,
  mutable current: int,
  mutable errors: array<parseError>,
}

// ============================================================================
// Parser Helpers
// ============================================================================

let createParser = (tokens: array<token>): parserState => {
  {tokens, current: 0, errors: []}
}

let isAtEnd = (parser: parserState): bool => {
  switch parser.tokens->Array.get(parser.current) {
  | Some({kind: TEOF}) => true
  | None => true
  | _ => false
  }
}

let peek = (parser: parserState): option<token> => {
  parser.tokens->Array.get(parser.current)
}

let previous = (parser: parserState): option<token> => {
  parser.tokens->Array.get(parser.current - 1)
}

let advance = (parser: parserState): option<token> => {
  if !isAtEnd(parser) {
    parser.current = parser.current + 1
  }
  previous(parser)
}

let check = (parser: parserState, kind: tokenKind): bool => {
  switch peek(parser) {
  | Some(token) =>
    switch (token.kind, kind) {
    | (TIdent(_), TIdent(_)) => true
    | (TString(_), TString(_)) => true
    | (TNumber(_), TNumber(_)) => true
    | (TBool(_), TBool(_)) => true
    | (a, b) => a == b
    }
  | None => false
  }
}

let match_ = (parser: parserState, kinds: array<tokenKind>): bool => {
  kinds->Array.some(kind => {
    if check(parser, kind) {
      let _ = advance(parser)
      true
    } else {
      false
    }
  })
}

let consume = (parser: parserState, kind: tokenKind, message: string): option<token> => {
  if check(parser, kind) {
    advance(parser)
  } else {
    let pos = switch peek(parser) {
    | Some(t) => t.start
    | None => {line: 0, column: 0, offset: 0}
    }
    parser.errors = parser.errors->Array.concat([{message, position: pos}])
    None
  }
}

// ============================================================================
// Expression Parsing
// ============================================================================

let rec parseExpression = (parser: parserState): option<expr> => {
  parsePipe(parser)
}

and parsePipe = (parser: parserState): option<expr> => {
  let left = parseOr(parser)

  switch left {
  | Some(l) =>
    if match_(parser, [TPipe]) {
      switch parsePipe(parser) {
      | Some(right) => Some(EPipe(l, right))
      | None => Some(l)
      }
    } else {
      Some(l)
    }
  | None => None
  }
}

and parseOr = (parser: parserState): option<expr> => {
  let left = parseAnd(parser)

  switch left {
  | Some(l) =>
    if match_(parser, [TOr]) {
      switch parseOr(parser) {
      | Some(right) => Some(EBinary(l, OpOr, right))
      | None => Some(l)
      }
    } else {
      Some(l)
    }
  | None => None
  }
}

and parseAnd = (parser: parserState): option<expr> => {
  let left = parseEquality(parser)

  switch left {
  | Some(l) =>
    if match_(parser, [TAnd]) {
      switch parseAnd(parser) {
      | Some(right) => Some(EBinary(l, OpAnd, right))
      | None => Some(l)
      }
    } else {
      Some(l)
    }
  | None => None
  }
}

and parseEquality = (parser: parserState): option<expr> => {
  let left = parseComparison(parser)

  switch left {
  | Some(l) =>
    if match_(parser, [TEqEq]) {
      switch parseEquality(parser) {
      | Some(right) => Some(EBinary(l, OpEq, right))
      | None => Some(l)
      }
    } else if match_(parser, [TNotEq]) {
      switch parseEquality(parser) {
      | Some(right) => Some(EBinary(l, OpNotEq, right))
      | None => Some(l)
      }
    } else {
      Some(l)
    }
  | None => None
  }
}

and parseComparison = (parser: parserState): option<expr> => {
  let left = parseTerm(parser)

  switch left {
  | Some(l) =>
    let op = if match_(parser, [TLt]) {
      Some(OpLt)
    } else if match_(parser, [TLtEq]) {
      Some(OpLtEq)
    } else if match_(parser, [TGt]) {
      Some(OpGt)
    } else if match_(parser, [TGtEq]) {
      Some(OpGtEq)
    } else {
      None
    }

    switch op {
    | Some(operator) =>
      switch parseComparison(parser) {
      | Some(right) => Some(EBinary(l, operator, right))
      | None => Some(l)
      }
    | None => Some(l)
    }
  | None => None
  }
}

and parseTerm = (parser: parserState): option<expr> => {
  let left = parseFactor(parser)

  switch left {
  | Some(l) =>
    if match_(parser, [TPlus]) {
      switch parseTerm(parser) {
      | Some(right) => Some(EBinary(l, OpAdd, right))
      | None => Some(l)
      }
    } else if match_(parser, [TMinus]) {
      switch parseTerm(parser) {
      | Some(right) => Some(EBinary(l, OpSub, right))
      | None => Some(l)
      }
    } else {
      Some(l)
    }
  | None => None
  }
}

and parseFactor = (parser: parserState): option<expr> => {
  let left = parseUnary(parser)

  switch left {
  | Some(l) =>
    if match_(parser, [TStar]) {
      switch parseFactor(parser) {
      | Some(right) => Some(EBinary(l, OpMul, right))
      | None => Some(l)
      }
    } else if match_(parser, [TSlash]) {
      switch parseFactor(parser) {
      | Some(right) => Some(EBinary(l, OpDiv, right))
      | None => Some(l)
      }
    } else if match_(parser, [TPercent]) {
      switch parseFactor(parser) {
      | Some(right) => Some(EBinary(l, OpMod, right))
      | None => Some(l)
      }
    } else {
      Some(l)
    }
  | None => None
  }
}

and parseUnary = (parser: parserState): option<expr> => {
  if match_(parser, [TMinus]) {
    switch parseUnary(parser) {
    | Some(expr) => Some(EUnary(OpNeg, expr))
    | None => None
    }
  } else if match_(parser, [TNot]) {
    switch parseUnary(parser) {
    | Some(expr) => Some(EUnary(OpNot, expr))
    | None => None
    }
  } else {
    parseCall(parser)
  }
}

and parseCall = (parser: parserState): option<expr> => {
  let callee = parsePrimary(parser)

  switch callee {
  | Some(c) =>
    if match_(parser, [TLParen]) {
      let args = ref([])
      if !check(parser, TRParen) {
        switch parseExpression(parser) {
        | Some(arg) => args := args.contents->Array.concat([arg])
        | None => ()
        }
        while match_(parser, [TComma]) {
          switch parseExpression(parser) {
          | Some(arg) => args := args.contents->Array.concat([arg])
          | None => ()
          }
        }
      }
      let _ = consume(parser, TRParen, "Expected ')' after arguments")
      Some(ECall(c, args.contents))
    } else if match_(parser, [TDot]) {
      switch peek(parser) {
      | Some({kind: TIdent(name)}) =>
        let _ = advance(parser)
        Some(EAccess(c, name))
      | _ =>
        parser.errors = parser.errors->Array.concat([{
          message: "Expected property name after '.'",
          position: switch peek(parser) {
          | Some(t) => t.start
          | None => {line: 0, column: 0, offset: 0}
          },
        }])
        Some(c)
      }
    } else {
      Some(c)
    }
  | None => None
  }
}

and parsePrimary = (parser: parserState): option<expr> => {
  switch peek(parser) {
  | Some({kind: TString(s)}) =>
    let _ = advance(parser)
    Some(ELiteral(LString(s)))
  | Some({kind: TNumber(n)}) =>
    let _ = advance(parser)
    Some(ELiteral(LNumber(n)))
  | Some({kind: TBool(b)}) =>
    let _ = advance(parser)
    Some(ELiteral(LBool(b)))
  | Some({kind: TNull}) =>
    let _ = advance(parser)
    Some(ELiteral(LNull))
  | Some({kind: TIdent(name)}) =>
    let _ = advance(parser)
    Some(EIdent(name))
  | Some({kind: TLParen}) =>
    let _ = advance(parser)
    let expr = parseExpression(parser)
    let _ = consume(parser, TRParen, "Expected ')' after expression")
    expr
  | Some({kind: TLBracket}) =>
    let _ = advance(parser)
    let elements = ref([])
    if !check(parser, TRBracket) {
      switch parseExpression(parser) {
      | Some(el) => elements := elements.contents->Array.concat([el])
      | None => ()
      }
      while match_(parser, [TComma]) {
        switch parseExpression(parser) {
        | Some(el) => elements := elements.contents->Array.concat([el])
        | None => ()
        }
      }
    }
    let _ = consume(parser, TRBracket, "Expected ']' after array elements")
    Some(EArray(elements.contents))
  | _ => None
  }
}

// ============================================================================
// Statement Parsing
// ============================================================================

let parseStatement = (parser: parserState): option<stmt> => {
  // Skip newlines
  while match_(parser, [TNewline]) {
    ()
  }

  switch peek(parser) {
  | Some({kind: TLet}) =>
    let _ = advance(parser)
    switch peek(parser) {
    | Some({kind: TIdent(name)}) =>
      let _ = advance(parser)
      let _ = consume(parser, TEq, "Expected '=' after variable name")
      switch parseExpression(parser) {
      | Some(value) => Some(SLet(name, None, value))
      | None => None
      }
    | _ =>
      parser.errors = parser.errors->Array.concat([{
        message: "Expected variable name after 'let'",
        position: switch peek(parser) {
        | Some(t) => t.start
        | None => {line: 0, column: 0, offset: 0}
        },
      }])
      None
    }
  | Some({kind: TConst}) =>
    let _ = advance(parser)
    switch peek(parser) {
    | Some({kind: TIdent(name)}) =>
      let _ = advance(parser)
      let _ = consume(parser, TEq, "Expected '=' after constant name")
      switch parseExpression(parser) {
      | Some(value) => Some(SConst(name, None, value))
      | None => None
      }
    | _ =>
      parser.errors = parser.errors->Array.concat([{
        message: "Expected constant name after 'const'",
        position: switch peek(parser) {
        | Some(t) => t.start
        | None => {line: 0, column: 0, offset: 0}
        },
      }])
      None
    }
  | _ =>
    switch parseExpression(parser) {
    | Some(expr) => Some(SExpr(expr))
    | None => None
    }
  }
}

// ============================================================================
// Program Parsing
// ============================================================================

let parseProgram = (tokens: array<token>): result<program, array<parseError>> => {
  let parser = createParser(tokens)
  let statements = ref([])

  while !isAtEnd(parser) {
    switch parseStatement(parser) {
    | Some(stmt) => statements := statements.contents->Array.concat([stmt])
    | None =>
      // Skip token and try to continue
      let _ = advance(parser)
    }
  }

  if parser.errors->Array.length > 0 {
    Error(parser.errors)
  } else {
    Ok({statements: statements.contents})
  }
}

let parse = (source: string): result<program, array<parseError>> => {
  let tokens = tokenize(source)
  parseProgram(tokens)
}
