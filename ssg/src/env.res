// SPDX-License-Identifier: AGPL-3.0-or-later
// SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
// NoteG SSG - Environment Handling

// ============================================================================
// Environment Types
// ============================================================================

type environment =
  | Development
  | Production
  | Test

type envConfig = {
  environment: environment,
  logLevel: string,
  mcpDebug: bool,
  siteUrl: string,
}

// ============================================================================
// Environment Detection
// ============================================================================

@val @scope("process.env") external nodeEnv: option<string> = "NODE_ENV"
@val @scope("process.env") external logLevel: option<string> = "LOG_LEVEL"
@val @scope("process.env") external mcpDebug: option<string> = "MCP_DEBUG"
@val @scope("process.env") external siteUrl: option<string> = "SITE_URL"

let parseEnvironment = (env: option<string>): environment => {
  switch env {
  | Some("production") => Production
  | Some("test") => Test
  | _ => Development
  }
}

let parseBool = (value: option<string>): bool => {
  switch value {
  | Some("true") | Some("1") | Some("yes") => true
  | _ => false
  }
}

// ============================================================================
// Configuration Loading
// ============================================================================

let loadEnvConfig = (): envConfig => {
  let env = parseEnvironment(nodeEnv)

  {
    environment: env,
    logLevel: logLevel->Option.getOr(
      switch env {
      | Development => "debug"
      | Production => "info"
      | Test => "warn"
      }
    ),
    mcpDebug: parseBool(mcpDebug),
    siteUrl: siteUrl->Option.getOr(
      switch env {
      | Development => "http://localhost:8080"
      | Production => "https://example.com"
      | Test => "http://localhost:3000"
      }
    ),
  }
}

// ============================================================================
// Environment Helpers
// ============================================================================

let isDevelopment = (config: envConfig): bool => {
  config.environment == Development
}

let isProduction = (config: envConfig): bool => {
  config.environment == Production
}

let isTest = (config: envConfig): bool => {
  config.environment == Test
}

let getLogLevel = (config: envConfig): string => {
  config.logLevel
}

// ============================================================================
// Logging
// ============================================================================

type logLevel = Debug | Info | Warn | Error

let logLevelToInt = (level: logLevel): int => {
  switch level {
  | Debug => 0
  | Info => 1
  | Warn => 2
  | Error => 3
  }
}

let stringToLogLevel = (s: string): logLevel => {
  switch s->String.toLowerCase {
  | "debug" => Debug
  | "info" => Info
  | "warn" | "warning" => Warn
  | "error" => Error
  | _ => Info
  }
}

let shouldLog = (config: envConfig, level: logLevel): bool => {
  let configLevel = stringToLogLevel(config.logLevel)
  logLevelToInt(level) >= logLevelToInt(configLevel)
}

let log = (config: envConfig, level: logLevel, message: string): unit => {
  if shouldLog(config, level) {
    let prefix = switch level {
    | Debug => "[DEBUG]"
    | Info => "[INFO]"
    | Warn => "[WARN]"
    | Error => "[ERROR]"
    }
    Js.log(`${prefix} ${message}`)
  }
}
