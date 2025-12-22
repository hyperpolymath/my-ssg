-- SPDX-License-Identifier: AGPL-3.0-or-later
-- SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
--
-- NoteG Engine - Core Ada/SPARK Foundation
-- Provides formally verified static site generation primitives

pragma SPARK_Mode (On);

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Noteg_Engine is

   -- ========================================================================
   -- Type Definitions
   -- ========================================================================

   type Generation_Result is (Success, Parse_Error, Template_Error, IO_Error);

   type Content_Kind is (Markdown, HTML, Plain_Text, NoteG_Source);

   type Variable_Value is record
      Name  : Unbounded_String;
      Value : Unbounded_String;
   end record;

   type Variable_Store is array (Positive range <>) of Variable_Value;

   type Template_Context is record
      Variables : access Variable_Store;
      Base_Path : Unbounded_String;
      Output_Path : Unbounded_String;
   end record;

   -- ========================================================================
   -- Operation Card Types (Mill-Based Synthesis)
   -- ========================================================================

   type Operation_Kind is (
      Load_Content,
      Parse_Frontmatter,
      Apply_Template,
      Transform_Markdown,
      Write_Output,
      Copy_Asset
   );

   type Operation_Card is record
      Kind : Operation_Kind;
      Input_Path : Unbounded_String;
      Output_Path : Unbounded_String;
      Template_Name : Unbounded_String;
   end record;

   type Operation_Sequence is array (Positive range <>) of Operation_Card;

   -- ========================================================================
   -- Core Engine Functions
   -- ========================================================================

   -- Initialize the engine with a configuration
   procedure Initialize (Config_Path : String)
     with Global => null;

   -- Execute a single operation card
   function Execute_Operation (Card : Operation_Card;
                                Ctx  : Template_Context) return Generation_Result
     with Pre => Card.Kind in Operation_Kind;

   -- Execute a sequence of operations (Mill synthesis)
   function Execute_Sequence (Ops : Operation_Sequence;
                               Ctx : Template_Context) return Generation_Result;

   -- ========================================================================
   -- Variable Store Operations
   -- ========================================================================

   -- Get a variable value by name
   function Get_Variable (Store : Variable_Store;
                          Name  : String) return Unbounded_String
     with Post => Get_Variable'Result /= Null_Unbounded_String or else
                  (for all V of Store => To_String (V.Name) /= Name);

   -- Set a variable value
   procedure Set_Variable (Store : in out Variable_Store;
                           Name  : String;
                           Value : String);

   -- ========================================================================
   -- Template Operations
   -- ========================================================================

   -- Apply mustache-style template substitution
   function Apply_Template (Template : String;
                            Ctx      : Template_Context) return Unbounded_String;

   -- Parse operation card from template definition
   function Parse_Operation_Card (Definition : String) return Operation_Card;

   -- ========================================================================
   -- Content Processing
   -- ========================================================================

   -- Parse YAML frontmatter from content
   procedure Parse_Frontmatter (Content    : String;
                                 Frontmatter : out Variable_Store;
                                 Body       : out Unbounded_String);

   -- Transform Markdown to HTML
   function Transform_Markdown (Source : String) return Unbounded_String;

   -- ========================================================================
   -- Verification Support
   -- ========================================================================

   -- Bernoulli verification mode flag
   Verification_Mode : Boolean := False;

   -- Run verification tests
   procedure Run_Verification
     with Pre => Verification_Mode;

end Noteg_Engine;
