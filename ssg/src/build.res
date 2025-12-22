// SPDX-License-Identifier: AGPL-3.0-or-later
// SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
// NoteG SSG - Mill-Based Synthesis Build System

open Types

// ============================================================================
// Configuration Loading
// ============================================================================

let defaultConfig: siteConfig = {
  name: "my-ssg",
  version: "0.1.0",
  site: {
    title: "My Site",
    description: "A site built with NoteG",
    url: "http://localhost:8080",
    language: "en-GB",
    author: None,
  },
  build: {
    contentDir: "content",
    templatesDir: "templates",
    outputDir: "_site",
    clean: true,
  },
  features: {
    enabled: true,
    bsl: false,
    gsl: false,
    asl: false,
    makaton: false,
  },
}

@module("fs") external readFileSync: (string, string) => string = "readFileSync"
@module("fs") external writeFileSync: (string, string) => unit = "writeFileSync"
@module("fs") external existsSync: string => bool = "existsSync"
@module("fs") external mkdirSync: (string, {..}) => unit = "mkdirSync"

let loadConfig = (path: string): generationResult<siteConfig> => {
  if existsSync(path) {
    try {
      let content = readFileSync(path, "utf8")
      // Parse JSON config - simplified for now
      Ok(defaultConfig)
    } catch {
    | _ => Error(IoError(`Failed to read config: ${path}`))
    }
  } else {
    Ok(defaultConfig)
  }
}

// ============================================================================
// Variable Store
// ============================================================================

let createVariableStore = (config: siteConfig, content: contentFile): array<templateVariable> => {
  [
    {name: "site.title", value: config.site.title},
    {name: "site.description", value: config.site.description},
    {name: "site.url", value: config.site.url},
    {name: "page.title", value: content.frontmatter.title},
    {name: "page.content", value: content.body},
  ]
}

let getVariable = (store: array<templateVariable>, name: string): option<string> => {
  store->Array.find(v => v.name == name)->Option.map(v => v.value)
}

// ============================================================================
// Operation Card Execution
// ============================================================================

let executeOperation = (card: operationCard, ctx: templateContext): generationResult<unit> => {
  switch card.kind {
  | LoadContent =>
    Js.log(`Loading content from ${card.inputPath}`)
    Ok()
  | ParseFrontmatter =>
    Js.log(`Parsing frontmatter`)
    Ok()
  | ApplyTemplate =>
    Js.log(`Applying template: ${card.templateName->Option.getOr("default")}`)
    Ok()
  | TransformMarkdown =>
    Js.log(`Transforming Markdown to HTML`)
    Ok()
  | WriteOutput =>
    Js.log(`Writing output to ${card.outputPath}`)
    Ok()
  | CopyAsset =>
    Js.log(`Copying asset to ${card.outputPath}`)
    Ok()
  }
}

let executeSequence = (ops: operationSequence, ctx: templateContext): generationResult<unit> => {
  ops->Array.reduce(Ok(), (acc, card) => {
    switch acc {
    | Error(e) => Error(e)
    | Ok() => executeOperation(card, ctx)
    }
  })
}

// ============================================================================
// Template Engine
// ============================================================================

let applyTemplate = (template: string, variables: array<templateVariable>): string => {
  variables->Array.reduce(template, (acc, v) => {
    acc->String.replaceAll(`{{ ${v.name} }}`, v.value)
       ->String.replaceAll(`{{${v.name}}}`, v.value)
  })
}

// ============================================================================
// Content Processing
// ============================================================================

let parseFrontmatter = (content: string): (frontmatter, string) => {
  // Simple frontmatter parser - looks for --- delimiters
  let defaultFrontmatter = {
    title: "Untitled",
    date: None,
    draft: false,
    tags: [],
    layout: None,
    custom: Js.Dict.empty(),
  }

  if content->String.startsWith("---") {
    let parts = content->String.split("---")
    if parts->Array.length >= 3 {
      // Parse YAML frontmatter (simplified)
      let body = parts->Array.sliceToEnd(~start=2)->Array.join("---")
      (defaultFrontmatter, body->String.trim)
    } else {
      (defaultFrontmatter, content)
    }
  } else {
    (defaultFrontmatter, content)
  }
}

// ============================================================================
// Build Pipeline
// ============================================================================

let createBuildOperations = (content: contentFile): operationSequence => {
  [
    {kind: LoadContent, inputPath: content.path, outputPath: "", templateName: None},
    {kind: ParseFrontmatter, inputPath: "", outputPath: "", templateName: None},
    {kind: TransformMarkdown, inputPath: "", outputPath: "", templateName: None},
    {kind: ApplyTemplate, inputPath: "", outputPath: "", templateName: content.frontmatter.layout},
    {kind: WriteOutput, inputPath: "", outputPath: content.outputPath, templateName: None},
  ]
}

let build = (config: siteConfig): generationResult<buildStats> => {
  let startTime = Js.Date.now()

  Js.log("NoteG SSG Build Starting...")
  Js.log(`Content directory: ${config.build.contentDir}`)
  Js.log(`Output directory: ${config.build.outputDir}`)

  // Create output directory
  if !existsSync(config.build.outputDir) {
    mkdirSync(config.build.outputDir, {"recursive": true})
  }

  // Build stats
  let stats = {
    startTime,
    endTime: Some(Js.Date.now()),
    filesProcessed: 0,
    filesWritten: 0,
    errors: [],
  }

  Js.log("Build complete!")
  Ok(stats)
}

// ============================================================================
// Entry Point
// ============================================================================

let main = () => {
  switch loadConfig("noteg.config.json") {
  | Ok(config) =>
    switch build(config) {
    | Ok(stats) =>
      Js.log(`Processed ${stats.filesProcessed->Int.toString} files`)
      Js.log(`Written ${stats.filesWritten->Int.toString} files`)
    | Error(e) =>
      switch e {
      | ParseError(msg) => Js.log(`Parse error: ${msg}`)
      | TemplateError(msg) => Js.log(`Template error: ${msg}`)
      | IoError(msg) => Js.log(`IO error: ${msg}`)
      | ValidationError(msg) => Js.log(`Validation error: ${msg}`)
      }
    }
  | Error(e) =>
    Js.log("Failed to load configuration")
  }
}
