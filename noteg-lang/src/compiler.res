// SPDX-License-Identifier: AGPL-3.0-or-later
// SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
// NoteG Language - Compiler (to JavaScript)

open Lexer
open Parser

// ============================================================================
// Compiler Configuration
// ============================================================================

type compilerOptions = {
  target: string,         // "es2022" | "deno" | "node"
  minify: bool,
  sourceMap: bool,
  strict: bool,
}

let defaultOptions: compilerOptions = {
  target: "es2022",
  minify: false,
  sourceMap: false,
  strict: true,
}

// ============================================================================
// Code Generation State
// ============================================================================

type codeGenState = {
  mutable indent: int,
  mutable output: string,
  options: compilerOptions,
}

let createState = (options: compilerOptions): codeGenState => {
  {indent: 0, output: "", options}
}

let emit = (state: codeGenState, code: string): unit => {
  state.output = state.output ++ code
}

let emitLine = (state: codeGenState, code: string): unit => {
  let indentation = String.repeat("  ", state.indent)
  state.output = state.output ++ indentation ++ code ++ "\n"
}

let emitNewline = (state: codeGenState): unit => {
  state.output = state.output ++ "\n"
}

let indent = (state: codeGenState): unit => {
  state.indent = state.indent + 1
}

let dedent = (state: codeGenState): unit => {
  state.indent = max(0, state.indent - 1)
}

// ============================================================================
// Expression Compilation
// ============================================================================

let rec compileExpr = (state: codeGenState, expr: expr): string => {
  switch expr {
  | ELiteral(lit) =>
    switch lit {
    | LNull => "null"
    | LBool(b) => b ? "true" : "false"
    | LNumber(n) =>
      if Float.toInt(n)->Int.toFloat == n {
        Float.toInt(n)->Int.toString
      } else {
        Float.toString(n)
      }
    | LString(s) => `"${escapeString(s)}"`
    }

  | EIdent(name) => sanitizeIdent(name)

  | EBinary(left, op, right) =>
    let l = compileExpr(state, left)
    let r = compileExpr(state, right)
    let opStr = switch op {
    | OpAdd => "+"
    | OpSub => "-"
    | OpMul => "*"
    | OpDiv => "/"
    | OpMod => "%"
    | OpEq => "==="
    | OpNotEq => "!=="
    | OpLt => "<"
    | OpLtEq => "<="
    | OpGt => ">"
    | OpGtEq => ">="
    | OpAnd => "&&"
    | OpOr => "||"
    }
    `(${l} ${opStr} ${r})`

  | EUnary(op, operand) =>
    let o = compileExpr(state, operand)
    let opStr = switch op {
    | OpNeg => "-"
    | OpNot => "!"
    }
    `(${opStr}${o})`

  | ECall(callee, args) =>
    let c = compileExpr(state, callee)
    let argsStr = args->Array.map(a => compileExpr(state, a))->Array.join(", ")
    `${c}(${argsStr})`

  | ELambda(params, body) =>
    let paramsStr = params->Array.map(sanitizeIdent)->Array.join(", ")
    let bodyStr = compileExpr(state, body)
    `((${paramsStr}) => ${bodyStr})`

  | EIf(condition, thenBranch, elseBranch) =>
    let cond = compileExpr(state, condition)
    let thenStr = compileExpr(state, thenBranch)
    switch elseBranch {
    | Some(e) =>
      let elseStr = compileExpr(state, e)
      `(${cond} ? ${thenStr} : ${elseStr})`
    | None =>
      `(${cond} ? ${thenStr} : null)`
    }

  | EBlock(stmts) =>
    let body = stmts->Array.map(s => compileStmt(state, s))->Array.join("\n")
    `(() => {\n${body}\n})()`

  | EArray(elements) =>
    let elems = elements->Array.map(e => compileExpr(state, e))->Array.join(", ")
    `[${elems}]`

  | ERecord(fields) =>
    let fieldsStr = fields->Array.map(((name, expr)) => {
      let v = compileExpr(state, expr)
      `${sanitizeIdent(name)}: ${v}`
    })->Array.join(", ")
    `{ ${fieldsStr} }`

  | EAccess(obj, field) =>
    let o = compileExpr(state, obj)
    `${o}.${sanitizeIdent(field)}`

  | EIndex(arr, index) =>
    let a = compileExpr(state, arr)
    let i = compileExpr(state, index)
    `${a}[${i}]`

  | EPipe(left, right) =>
    // Transform pipe to function call
    let l = compileExpr(state, left)
    switch right {
    | ECall(callee, args) =>
      let c = compileExpr(state, callee)
      let argsStr = args->Array.map(a => compileExpr(state, a))->Array.join(", ")
      if args->Array.length > 0 {
        `${c}(${l}, ${argsStr})`
      } else {
        `${c}(${l})`
      }
    | EIdent(name) =>
      `${sanitizeIdent(name)}(${l})`
    | _ =>
      let r = compileExpr(state, right)
      `${r}(${l})`
    }

  | EMatch(_, _) =>
    // Pattern matching compilation - stub
    "/* match expression not yet supported */"

  | ETemplate(parts) =>
    let compiled = parts->Array.map(part => {
      switch part {
      | TpText(s) => escapeString(s)
      | TpExpr(e) => `\${${compileExpr(state, e)}}`
      }
    })->Array.join("")
    "`" ++ compiled ++ "`"
  }
}

and escapeString = (s: string): string => {
  s->String.replaceAll("\\", "\\\\")
   ->String.replaceAll("\"", "\\\"")
   ->String.replaceAll("\n", "\\n")
   ->String.replaceAll("\t", "\\t")
   ->String.replaceAll("\r", "\\r")
}

and sanitizeIdent = (name: string): string => {
  // Reserved words in JavaScript
  let reserved = ["break", "case", "catch", "continue", "debugger", "default",
                  "delete", "do", "else", "finally", "for", "function", "if",
                  "in", "instanceof", "new", "return", "switch", "this", "throw",
                  "try", "typeof", "var", "void", "while", "with", "class",
                  "const", "enum", "export", "extends", "import", "super",
                  "implements", "interface", "let", "package", "private",
                  "protected", "public", "static", "yield", "await", "async"]

  if reserved->Array.includes(name) {
    `_${name}`
  } else {
    name
  }
}

// ============================================================================
// Statement Compilation
// ============================================================================

and compileStmt = (state: codeGenState, stmt: stmt): string => {
  switch stmt {
  | SLet(name, typeAnnotation, value) =>
    let v = compileExpr(state, value)
    let typeComment = switch typeAnnotation {
    | Some(t) => ` /* ${compileType(t)} */`
    | None => ""
    }
    `let ${sanitizeIdent(name)}${typeComment} = ${v};`

  | SConst(name, typeAnnotation, value) =>
    let v = compileExpr(state, value)
    let typeComment = switch typeAnnotation {
    | Some(t) => ` /* ${compileType(t)} */`
    | None => ""
    }
    `const ${sanitizeIdent(name)}${typeComment} = ${v};`

  | SExpr(e) =>
    `${compileExpr(state, e)};`

  | SType(name, annotation) =>
    // Emit as JSDoc typedef
    `/** @typedef {${compileType(annotation)}} ${sanitizeIdent(name)} */`

  | SModule(name, stmts) =>
    let body = stmts->Array.map(s => compileStmt(state, s))->Array.join("\n  ")
    `const ${sanitizeIdent(name)} = (() => {\n  ${body}\n  return {};\n})();`

  | SImport(path, names) =>
    let namesStr = names->Array.map(sanitizeIdent)->Array.join(", ")
    `import { ${namesStr} } from "${path}";`

  | SExport(names) =>
    let namesStr = names->Array.map(sanitizeIdent)->Array.join(", ")
    `export { ${namesStr} };`
  }
}

and compileType = (t: typeAnnotation): string => {
  switch t {
  | TyIdent(name) => name
  | TyArray(inner) => `Array<${compileType(inner)}>`
  | TyFunction(params, ret) =>
    let paramsStr = params->Array.map(compileType)->Array.join(", ")
    `(${paramsStr}) => ${compileType(ret)}`
  | TyRecord(fields) =>
    let fieldsStr = fields->Array.map(((name, t)) => {
      `${name}: ${compileType(t)}`
    })->Array.join(", ")
    `{ ${fieldsStr} }`
  | TyUnion(types) =>
    types->Array.map(compileType)->Array.join(" | ")
  | TyOptional(inner) =>
    `${compileType(inner)} | null`
  }
}

// ============================================================================
// Program Compilation
// ============================================================================

let compileProgram = (program: program, options: compilerOptions): string => {
  let state = createState(options)

  // Emit header
  emitLine(state, "// Generated by NoteG Compiler")
  emitLine(state, "// SPDX-License-Identifier: AGPL-3.0-or-later")
  emitLine(state, `"use strict";`)
  emitNewline(state)

  // Emit runtime helpers if needed
  emitLine(state, "// Runtime helpers")
  emitLine(state, "const __noteg_print = console.log;")
  emitLine(state, "const __noteg_len = (x) => x.length;")
  emitLine(state, "const __noteg_str = String;")
  emitLine(state, "const __noteg_num = Number;")
  emitLine(state, "const __noteg_type = (x) => typeof x;")
  emitNewline(state)

  // Compile statements
  program.statements->Array.forEach(stmt => {
    emitLine(state, compileStmt(state, stmt))
  })

  state.output
}

// ============================================================================
// Entry Point
// ============================================================================

let compile = (source: string, options: option<compilerOptions>): result<string, string> => {
  let opts = options->Option.getOr(defaultOptions)

  switch parse(source) {
  | Ok(program) =>
    Ok(compileProgram(program, opts))
  | Error(errors) =>
    let msg = errors->Array.map(e => e.message)->Array.join("\n")
    Error(`Compilation failed:\n${msg}`)
  }
}

let compileFile = (inputPath: string, outputPath: string): result<unit, string> => {
  try {
    // Note: This would use Deno or Node file APIs
    // For now, this is a placeholder
    Ok()
  } catch {
  | _ => Error("File operation failed")
  }
}
