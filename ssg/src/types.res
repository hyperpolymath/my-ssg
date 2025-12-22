// SPDX-License-Identifier: AGPL-3.0-or-later
// SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
// NoteG SSG - Type Definitions

// ============================================================================
// Site Configuration Schema
// ============================================================================

type siteMetadata = {
  title: string,
  description: string,
  url: string,
  language: string,
  author: option<string>,
}

type buildConfig = {
  contentDir: string,
  templatesDir: string,
  outputDir: string,
  clean: bool,
}

type accessibilityFeatures = {
  enabled: bool,
  bsl: bool,  // British Sign Language
  gsl: bool,  // German Sign Language
  asl: bool,  // American Sign Language
  makaton: bool,
}

type siteConfig = {
  name: string,
  version: string,
  site: siteMetadata,
  build: buildConfig,
  features: accessibilityFeatures,
}

// ============================================================================
// Content Types
// ============================================================================

type contentKind =
  | Markdown
  | Html
  | PlainText
  | NotegSource

type frontmatter = {
  title: string,
  date: option<string>,
  draft: bool,
  tags: array<string>,
  layout: option<string>,
  custom: Js.Dict.t<string>,
}

type contentFile = {
  path: string,
  kind: contentKind,
  frontmatter: frontmatter,
  body: string,
  outputPath: string,
}

// ============================================================================
// Template Types
// ============================================================================

type templateVariable = {
  name: string,
  value: string,
}

type templateContext = {
  variables: array<templateVariable>,
  content: contentFile,
  site: siteConfig,
}

type template = {
  name: string,
  path: string,
  content: string,
}

// ============================================================================
// Operation Cards (Mill-Based Synthesis)
// ============================================================================

type operationKind =
  | LoadContent
  | ParseFrontmatter
  | ApplyTemplate
  | TransformMarkdown
  | WriteOutput
  | CopyAsset

type operationCard = {
  kind: operationKind,
  inputPath: string,
  outputPath: string,
  templateName: option<string>,
}

type operationSequence = array<operationCard>

// ============================================================================
// Generation Results
// ============================================================================

type generationError =
  | ParseError(string)
  | TemplateError(string)
  | IoError(string)
  | ValidationError(string)

type generationResult<'a> = result<'a, generationError>

// ============================================================================
// Accessibility Metadata
// ============================================================================

type signLanguageMetadata = {
  videoUrl: option<string>,
  transcriptUrl: option<string>,
  interpreter: option<string>,
}

type accessibilityMeta = {
  bsl: option<signLanguageMetadata>,
  gsl: option<signLanguageMetadata>,
  asl: option<signLanguageMetadata>,
  makaton: option<array<string>>,  // Symbol references
  altText: option<string>,
  ariaLabel: option<string>,
}

// ============================================================================
// Build State
// ============================================================================

type buildStats = {
  startTime: float,
  endTime: option<float>,
  filesProcessed: int,
  filesWritten: int,
  errors: array<generationError>,
}

type buildState = {
  config: siteConfig,
  content: array<contentFile>,
  templates: array<template>,
  stats: buildStats,
}
