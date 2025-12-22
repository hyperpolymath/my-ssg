// SPDX-License-Identifier: AGPL-3.0-or-later
// SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
// NoteG Language Server Protocol Implementation

import {
  createConnection,
  TextDocuments,
  ProposedFeatures,
  InitializeParams,
  InitializeResult,
  TextDocumentSyncKind,
  CompletionItem,
  CompletionItemKind,
  DiagnosticSeverity,
  Diagnostic,
  TextDocumentPositionParams,
  Hover,
  MarkupKind,
  DefinitionParams,
  Location,
  DocumentFormattingParams,
  TextEdit,
  Range,
  Position,
} from "vscode-languageserver/node";

import { TextDocument } from "vscode-languageserver-textdocument";

// ============================================================================
// Server Setup
// ============================================================================

const connection = createConnection(ProposedFeatures.all);
const documents: TextDocuments<TextDocument> = new TextDocuments(TextDocument);

// ============================================================================
// Capabilities
// ============================================================================

connection.onInitialize((params: InitializeParams): InitializeResult => {
  return {
    capabilities: {
      textDocumentSync: TextDocumentSyncKind.Incremental,
      completionProvider: {
        resolveProvider: true,
        triggerCharacters: [".", "|"],
      },
      hoverProvider: true,
      definitionProvider: true,
      documentFormattingProvider: true,
      diagnosticProvider: {
        interFileDependencies: false,
        workspaceDiagnostics: false,
      },
    },
    serverInfo: {
      name: "NoteG Language Server",
      version: "0.1.0",
    },
  };
});

// ============================================================================
// Keywords and Built-ins
// ============================================================================

const keywords = [
  "let",
  "const",
  "fn",
  "if",
  "then",
  "else",
  "match",
  "with",
  "type",
  "module",
  "import",
  "export",
  "true",
  "false",
  "null",
];

const builtins = [
  { name: "print", signature: "(value: any) -> null", doc: "Print a value to stdout" },
  { name: "len", signature: "(value: string | array) -> number", doc: "Get the length of a string or array" },
  { name: "str", signature: "(value: any) -> string", doc: "Convert a value to a string" },
  { name: "num", signature: "(value: string) -> number", doc: "Parse a string as a number" },
  { name: "type", signature: "(value: any) -> string", doc: "Get the type of a value" },
];

// ============================================================================
// Completion
// ============================================================================

connection.onCompletion((params: TextDocumentPositionParams): CompletionItem[] => {
  const items: CompletionItem[] = [];

  // Add keywords
  for (const keyword of keywords) {
    items.push({
      label: keyword,
      kind: CompletionItemKind.Keyword,
      detail: `Keyword: ${keyword}`,
    });
  }

  // Add built-in functions
  for (const builtin of builtins) {
    items.push({
      label: builtin.name,
      kind: CompletionItemKind.Function,
      detail: builtin.signature,
      documentation: builtin.doc,
    });
  }

  // Add snippets
  items.push({
    label: "fn",
    kind: CompletionItemKind.Snippet,
    insertText: "fn ${1:name}(${2:params}) {\n\t$0\n}",
    insertTextFormat: 2, // Snippet
    detail: "Function definition",
  });

  items.push({
    label: "let",
    kind: CompletionItemKind.Snippet,
    insertText: "let ${1:name} = ${0}",
    insertTextFormat: 2,
    detail: "Variable declaration",
  });

  items.push({
    label: "if",
    kind: CompletionItemKind.Snippet,
    insertText: "if ${1:condition} then\n\t${2:body}\nelse\n\t${0}",
    insertTextFormat: 2,
    detail: "Conditional expression",
  });

  return items;
});

connection.onCompletionResolve((item: CompletionItem): CompletionItem => {
  return item;
});

// ============================================================================
// Hover
// ============================================================================

connection.onHover((params: TextDocumentPositionParams): Hover | null => {
  const document = documents.get(params.textDocument.uri);
  if (!document) return null;

  const text = document.getText();
  const offset = document.offsetAt(params.position);

  // Simple word extraction
  const wordStart = findWordStart(text, offset);
  const wordEnd = findWordEnd(text, offset);
  const word = text.substring(wordStart, wordEnd);

  // Check if it's a keyword
  if (keywords.includes(word)) {
    return {
      contents: {
        kind: MarkupKind.Markdown,
        value: `**Keyword:** \`${word}\``,
      },
    };
  }

  // Check if it's a built-in
  const builtin = builtins.find((b) => b.name === word);
  if (builtin) {
    return {
      contents: {
        kind: MarkupKind.Markdown,
        value: `**${builtin.name}**\n\n\`${builtin.signature}\`\n\n${builtin.doc}`,
      },
    };
  }

  return null;
});

function findWordStart(text: string, offset: number): number {
  let start = offset;
  while (start > 0 && /\w/.test(text[start - 1])) {
    start--;
  }
  return start;
}

function findWordEnd(text: string, offset: number): number {
  let end = offset;
  while (end < text.length && /\w/.test(text[end])) {
    end++;
  }
  return end;
}

// ============================================================================
// Diagnostics
// ============================================================================

documents.onDidChangeContent((change) => {
  validateDocument(change.document);
});

async function validateDocument(document: TextDocument): Promise<void> {
  const diagnostics: Diagnostic[] = [];
  const text = document.getText();
  const lines = text.split("\n");

  // Simple validation rules
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    // Check for unclosed braces in templates
    const templateStarts = (line.match(/\{\{/g) || []).length;
    const templateEnds = (line.match(/\}\}/g) || []).length;
    if (templateStarts !== templateEnds) {
      diagnostics.push({
        severity: DiagnosticSeverity.Error,
        range: {
          start: { line: i, character: 0 },
          end: { line: i, character: line.length },
        },
        message: "Unclosed template expression",
        source: "noteg",
      });
    }

    // Check for trailing whitespace (warning)
    if (/\s+$/.test(line)) {
      diagnostics.push({
        severity: DiagnosticSeverity.Warning,
        range: {
          start: { line: i, character: line.search(/\s+$/) },
          end: { line: i, character: line.length },
        },
        message: "Trailing whitespace",
        source: "noteg",
      });
    }

    // Check for TODO/FIXME comments
    const todoMatch = line.match(/\/\/\s*(TODO|FIXME|XXX):/i);
    if (todoMatch) {
      diagnostics.push({
        severity: DiagnosticSeverity.Information,
        range: {
          start: { line: i, character: todoMatch.index || 0 },
          end: { line: i, character: line.length },
        },
        message: `${todoMatch[1].toUpperCase()} found`,
        source: "noteg",
      });
    }
  }

  connection.sendDiagnostics({ uri: document.uri, diagnostics });
}

// ============================================================================
// Formatting
// ============================================================================

connection.onDocumentFormatting((params: DocumentFormattingParams): TextEdit[] => {
  const document = documents.get(params.textDocument.uri);
  if (!document) return [];

  const text = document.getText();
  const formatted = formatNotegCode(text, params.options);

  return [
    TextEdit.replace(
      Range.create(Position.create(0, 0), document.positionAt(text.length)),
      formatted
    ),
  ];
});

function formatNotegCode(
  text: string,
  options: { tabSize: number; insertSpaces: boolean }
): string {
  const indent = options.insertSpaces ? " ".repeat(options.tabSize) : "\t";
  const lines = text.split("\n");
  let indentLevel = 0;
  const result: string[] = [];

  for (const rawLine of lines) {
    const line = rawLine.trim();

    // Decrease indent before closing braces
    if (line.startsWith("}") || line.startsWith("]") || line.startsWith(")")) {
      indentLevel = Math.max(0, indentLevel - 1);
    }

    // Add indented line
    if (line) {
      result.push(indent.repeat(indentLevel) + line);
    } else {
      result.push("");
    }

    // Increase indent after opening braces
    if (line.endsWith("{") || line.endsWith("[") || line.endsWith("(")) {
      indentLevel++;
    }
  }

  return result.join("\n");
}

// ============================================================================
// Start Server
// ============================================================================

documents.listen(connection);
connection.listen();

console.log("NoteG Language Server started");
