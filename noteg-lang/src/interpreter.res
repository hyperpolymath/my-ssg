// SPDX-License-Identifier: AGPL-3.0-or-later
// SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
// NoteG Language - Interpreter

open Lexer
open Parser

// ============================================================================
// Runtime Values
// ============================================================================

type rec value =
  | VNull
  | VBool(bool)
  | VNumber(float)
  | VString(string)
  | VArray(array<value>)
  | VRecord(Js.Dict.t<value>)
  | VFunction(array<string>, expr, environment)
  | VBuiltin(string, array<value> => value)

and environment = {
  parent: option<environment>,
  bindings: Js.Dict.t<value>,
}

type runtimeError = {
  message: string,
  position: option<position>,
}

// ============================================================================
// Environment Operations
// ============================================================================

let createEnv = (parent: option<environment>): environment => {
  {parent, bindings: Js.Dict.empty()}
}

let rec lookup = (env: environment, name: string): option<value> => {
  switch env.bindings->Js.Dict.get(name) {
  | Some(v) => Some(v)
  | None =>
    switch env.parent {
    | Some(p) => lookup(p, name)
    | None => None
    }
  }
}

let define = (env: environment, name: string, value: value): unit => {
  env.bindings->Js.Dict.set(name, value)
}

// ============================================================================
// Built-in Functions
// ============================================================================

let builtins: Js.Dict.t<array<value> => value> = {
  let dict = Js.Dict.empty()

  dict->Js.Dict.set("print", args => {
    args->Array.forEach(arg => {
      switch arg {
      | VNull => Js.log("null")
      | VBool(b) => Js.log(b)
      | VNumber(n) => Js.log(n)
      | VString(s) => Js.log(s)
      | VArray(arr) => Js.log(arr)
      | VRecord(r) => Js.log(r)
      | VFunction(_, _, _) => Js.log("<function>")
      | VBuiltin(name, _) => Js.log(`<builtin: ${name}>`)
      }
    })
    VNull
  })

  dict->Js.Dict.set("len", args => {
    switch args->Array.get(0) {
    | Some(VString(s)) => VNumber(s->String.length->Int.toFloat)
    | Some(VArray(arr)) => VNumber(arr->Array.length->Int.toFloat)
    | _ => VNull
    }
  })

  dict->Js.Dict.set("str", args => {
    switch args->Array.get(0) {
    | Some(VNull) => VString("null")
    | Some(VBool(b)) => VString(b ? "true" : "false")
    | Some(VNumber(n)) => VString(Float.toString(n))
    | Some(VString(s)) => VString(s)
    | _ => VString("")
    }
  })

  dict->Js.Dict.set("num", args => {
    switch args->Array.get(0) {
    | Some(VString(s)) => VNumber(s->Float.fromString->Option.getOr(0.0))
    | Some(VNumber(n)) => VNumber(n)
    | Some(VBool(true)) => VNumber(1.0)
    | Some(VBool(false)) => VNumber(0.0)
    | _ => VNull
    }
  })

  dict->Js.Dict.set("type", args => {
    switch args->Array.get(0) {
    | Some(VNull) => VString("null")
    | Some(VBool(_)) => VString("bool")
    | Some(VNumber(_)) => VString("number")
    | Some(VString(_)) => VString("string")
    | Some(VArray(_)) => VString("array")
    | Some(VRecord(_)) => VString("record")
    | Some(VFunction(_, _, _)) => VString("function")
    | Some(VBuiltin(_, _)) => VString("builtin")
    | None => VNull
    }
  })

  dict
}

let createGlobalEnv = (): environment => {
  let env = createEnv(None)

  builtins->Js.Dict.entries->Array.forEach(((name, fn)) => {
    define(env, name, VBuiltin(name, fn))
  })

  env
}

// ============================================================================
// Evaluation
// ============================================================================

let rec eval = (expr: expr, env: environment): result<value, runtimeError> => {
  switch expr {
  | ELiteral(lit) =>
    switch lit {
    | LNull => Ok(VNull)
    | LBool(b) => Ok(VBool(b))
    | LNumber(n) => Ok(VNumber(n))
    | LString(s) => Ok(VString(s))
    }

  | EIdent(name) =>
    switch lookup(env, name) {
    | Some(v) => Ok(v)
    | None => Error({message: `Undefined variable: ${name}`, position: None})
    }

  | EBinary(left, op, right) =>
    switch (eval(left, env), eval(right, env)) {
    | (Ok(l), Ok(r)) => evalBinary(l, op, r)
    | (Error(e), _) | (_, Error(e)) => Error(e)
    }

  | EUnary(op, operand) =>
    switch eval(operand, env) {
    | Ok(v) => evalUnary(op, v)
    | Error(e) => Error(e)
    }

  | ECall(callee, args) =>
    switch eval(callee, env) {
    | Ok(VFunction(params, body, closure)) =>
      if params->Array.length != args->Array.length {
        Error({message: "Argument count mismatch", position: None})
      } else {
        let localEnv = createEnv(Some(closure))
        let evalArgs = args->Array.map(arg => eval(arg, env))
        let hasError = evalArgs->Array.some(r =>
          switch r {
          | Error(_) => true
          | Ok(_) => false
          }
        )
        if hasError {
          Error({message: "Error evaluating arguments", position: None})
        } else {
          params->Array.forEachWithIndex((i, param) => {
            switch evalArgs->Array.get(i) {
            | Some(Ok(v)) => define(localEnv, param, v)
            | _ => ()
            }
          })
          eval(body, localEnv)
        }
      }
    | Ok(VBuiltin(_, fn)) =>
      let evalArgs = args->Array.map(arg => eval(arg, env))
      let values = evalArgs->Array.filterMap(r =>
        switch r {
        | Ok(v) => Some(v)
        | Error(_) => None
        }
      )
      Ok(fn(values))
    | Ok(_) => Error({message: "Not callable", position: None})
    | Error(e) => Error(e)
    }

  | ELambda(params, body) =>
    Ok(VFunction(params, body, env))

  | EIf(condition, thenBranch, elseBranch) =>
    switch eval(condition, env) {
    | Ok(VBool(true)) => eval(thenBranch, env)
    | Ok(VBool(false)) =>
      switch elseBranch {
      | Some(e) => eval(e, env)
      | None => Ok(VNull)
      }
    | Ok(_) => Error({message: "Condition must be boolean", position: None})
    | Error(e) => Error(e)
    }

  | EBlock(stmts) =>
    let localEnv = createEnv(Some(env))
    let lastValue = ref(VNull)
    let error = ref(None)

    stmts->Array.forEach(stmt => {
      if error.contents->Option.isNone {
        switch evalStmt(stmt, localEnv) {
        | Ok(v) => lastValue := v
        | Error(e) => error := Some(e)
        }
      }
    })

    switch error.contents {
    | Some(e) => Error(e)
    | None => Ok(lastValue.contents)
    }

  | EArray(elements) =>
    let values = elements->Array.map(e => eval(e, env))
    let results = values->Array.filterMap(r =>
      switch r {
      | Ok(v) => Some(v)
      | Error(_) => None
      }
    )
    if results->Array.length == elements->Array.length {
      Ok(VArray(results))
    } else {
      Error({message: "Error evaluating array elements", position: None})
    }

  | ERecord(fields) =>
    let dict = Js.Dict.empty()
    let error = ref(None)

    fields->Array.forEach(((name, expr)) => {
      if error.contents->Option.isNone {
        switch eval(expr, env) {
        | Ok(v) => dict->Js.Dict.set(name, v)
        | Error(e) => error := Some(e)
        }
      }
    })

    switch error.contents {
    | Some(e) => Error(e)
    | None => Ok(VRecord(dict))
    }

  | EAccess(obj, field) =>
    switch eval(obj, env) {
    | Ok(VRecord(dict)) =>
      switch dict->Js.Dict.get(field) {
      | Some(v) => Ok(v)
      | None => Error({message: `Field not found: ${field}`, position: None})
      }
    | Ok(_) => Error({message: "Cannot access field on non-record", position: None})
    | Error(e) => Error(e)
    }

  | EIndex(arr, index) =>
    switch (eval(arr, env), eval(index, env)) {
    | (Ok(VArray(elements)), Ok(VNumber(i))) =>
      let idx = i->Float.toInt
      switch elements->Array.get(idx) {
      | Some(v) => Ok(v)
      | None => Error({message: "Index out of bounds", position: None})
      }
    | (Ok(VString(s)), Ok(VNumber(i))) =>
      let idx = i->Float.toInt
      if idx >= 0 && idx < s->String.length {
        Ok(VString(s->String.charAt(idx)))
      } else {
        Error({message: "Index out of bounds", position: None})
      }
    | _ => Error({message: "Invalid index operation", position: None})
    }

  | EPipe(left, right) =>
    switch eval(left, env) {
    | Ok(v) =>
      switch right {
      | ECall(callee, args) =>
        eval(ECall(callee, [ELiteral(valueToLiteral(v))]->Array.concat(args)), env)
      | EIdent(name) =>
        switch lookup(env, name) {
        | Some(VFunction(_, _, _) as fn) =>
          eval(ECall(ELiteral(LNull), [ELiteral(valueToLiteral(v))]), env)
        | Some(VBuiltin(_, fn)) =>
          Ok(fn([v]))
        | _ => Error({message: "Pipe target must be a function", position: None})
        }
      | _ => Error({message: "Invalid pipe target", position: None})
      }
    | Error(e) => Error(e)
    }

  | EMatch(_, _) =>
    // Pattern matching not fully implemented
    Error({message: "Pattern matching not yet implemented", position: None})

  | ETemplate(parts) =>
    let result = ref("")
    let error = ref(None)

    parts->Array.forEach(part => {
      if error.contents->Option.isNone {
        switch part {
        | TpText(s) => result := result.contents ++ s
        | TpExpr(e) =>
          switch eval(e, env) {
          | Ok(VString(s)) => result := result.contents ++ s
          | Ok(VNumber(n)) => result := result.contents ++ Float.toString(n)
          | Ok(VBool(b)) => result := result.contents ++ (b ? "true" : "false")
          | Ok(VNull) => result := result.contents ++ "null"
          | Ok(_) => error := Some({message: "Cannot interpolate complex value", position: None})
          | Error(e) => error := Some(e)
          }
        }
      }
    })

    switch error.contents {
    | Some(e) => Error(e)
    | None => Ok(VString(result.contents))
    }
  }
}

and valueToLiteral = (v: value): literal => {
  switch v {
  | VNull => LNull
  | VBool(b) => LBool(b)
  | VNumber(n) => LNumber(n)
  | VString(s) => LString(s)
  | _ => LNull
  }
}

and evalBinary = (left: value, op: binaryOp, right: value): result<value, runtimeError> => {
  switch (left, op, right) {
  | (VNumber(l), OpAdd, VNumber(r)) => Ok(VNumber(l +. r))
  | (VString(l), OpAdd, VString(r)) => Ok(VString(l ++ r))
  | (VNumber(l), OpSub, VNumber(r)) => Ok(VNumber(l -. r))
  | (VNumber(l), OpMul, VNumber(r)) => Ok(VNumber(l *. r))
  | (VNumber(l), OpDiv, VNumber(r)) =>
    if r == 0.0 {
      Error({message: "Division by zero", position: None})
    } else {
      Ok(VNumber(l /. r))
    }
  | (VNumber(l), OpMod, VNumber(r)) => Ok(VNumber(mod_float(l, r)))
  | (VNumber(l), OpLt, VNumber(r)) => Ok(VBool(l < r))
  | (VNumber(l), OpLtEq, VNumber(r)) => Ok(VBool(l <= r))
  | (VNumber(l), OpGt, VNumber(r)) => Ok(VBool(l > r))
  | (VNumber(l), OpGtEq, VNumber(r)) => Ok(VBool(l >= r))
  | (l, OpEq, r) => Ok(VBool(valuesEqual(l, r)))
  | (l, OpNotEq, r) => Ok(VBool(!valuesEqual(l, r)))
  | (VBool(l), OpAnd, VBool(r)) => Ok(VBool(l && r))
  | (VBool(l), OpOr, VBool(r)) => Ok(VBool(l || r))
  | _ => Error({message: "Invalid binary operation", position: None})
  }
}

and valuesEqual = (a: value, b: value): bool => {
  switch (a, b) {
  | (VNull, VNull) => true
  | (VBool(x), VBool(y)) => x == y
  | (VNumber(x), VNumber(y)) => x == y
  | (VString(x), VString(y)) => x == y
  | _ => false
  }
}

and evalUnary = (op: unaryOp, operand: value): result<value, runtimeError> => {
  switch (op, operand) {
  | (OpNeg, VNumber(n)) => Ok(VNumber(-.n))
  | (OpNot, VBool(b)) => Ok(VBool(!b))
  | _ => Error({message: "Invalid unary operation", position: None})
  }
}

and evalStmt = (stmt: stmt, env: environment): result<value, runtimeError> => {
  switch stmt {
  | SLet(name, _, value) =>
    switch eval(value, env) {
    | Ok(v) =>
      define(env, name, v)
      Ok(v)
    | Error(e) => Error(e)
    }

  | SConst(name, _, value) =>
    switch eval(value, env) {
    | Ok(v) =>
      define(env, name, v)
      Ok(v)
    | Error(e) => Error(e)
    }

  | SExpr(e) => eval(e, env)

  | SType(_, _) => Ok(VNull) // Type declarations have no runtime effect

  | SModule(_, stmts) =>
    let moduleEnv = createEnv(Some(env))
    stmts->Array.forEach(s => {
      let _ = evalStmt(s, moduleEnv)
    })
    Ok(VNull)

  | SImport(_, _) => Ok(VNull) // Imports handled elsewhere

  | SExport(_) => Ok(VNull) // Exports handled elsewhere
  }
}

// ============================================================================
// Entry Point
// ============================================================================

let interpret = (source: string): result<value, runtimeError> => {
  switch parse(source) {
  | Ok(program) =>
    let env = createGlobalEnv()
    let lastValue = ref(VNull)
    let error = ref(None)

    program.statements->Array.forEach(stmt => {
      if error.contents->Option.isNone {
        switch evalStmt(stmt, env) {
        | Ok(v) => lastValue := v
        | Error(e) => error := Some(e)
        }
      }
    })

    switch error.contents {
    | Some(e) => Error(e)
    | None => Ok(lastValue.contents)
    }

  | Error(parseErrors) =>
    let msg = parseErrors->Array.map(e => e.message)->Array.join(", ")
    Error({message: `Parse errors: ${msg}`, position: None})
  }
}
