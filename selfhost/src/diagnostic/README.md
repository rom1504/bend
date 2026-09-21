# Source-aware diagnostic path

The trusted checker still decides acceptance. `check_book` retains its original
string result: an empty string means acceptance. Diagnostic metadata never changes
that decision or relaxes a check.

The kernel's `check` and `infer` wrappers attach context and an ancestor trail only
when a result already contains an error. Fifteen existing failure sites preserve
expected/observed values that were previously discarded. Metadata occupies the
existing failed `KChecked.term` payload; the `KTerm`, `KDef`, `KEnv`, and `KChecked`
type layouts are unchanged.

## APIs

- `check_book_diagnostic(book, origins) -> DResult` preserves the authoritative
  error string and derives a structured explanation on rejection.
- `diagnostic_render(result) -> String` produces the complete `Error:` output.
  Unsupported declaration/TODO paths retain the original legacy output.
- `f_load_origins_for(main, sources, definition) -> FProvenance` loads through the
  actual frontend and returns origins only for the requested definition.
- `diagnostic_result_locate(result, origins) -> DResult` attaches source locations
  without repeating checking.
- `f_load_origins(main, sources)` provides the unfiltered provenance map for tests
  and tools that need it. Filtering avoids tracing every Base declaration.

The driver first executes its existing checker/prefix gate. On rejection it may
request a diagnostic with an empty origin list, read the structured definition
name, collect that definition's origins, attach them, and render. The driver checks
that the rich result's error equals the original rejection. A mismatch or failure
in the optional diagnostic path leaves the original rejection intact.

## Provenance and formatting

Origins contain the actual final core term, module source, UTF-16 start/end offsets,
and a path into the final freshened declaration. Only retained lexer positions
receive origins. Lookup requires the same definition and an exact structural term
match. Distinct matching locations are ambiguous and are not guessed; an exact
ancestor origin may supply a less specific location.

The renderer normalizes displayed terms, reconstructs shadowed binder names,
aligns context columns, preserves adjacent source lines and line-number widths,
and supports message-only errors and notes. It does not substitute fixture text.

Source positions currently survive for Ref/ADT/Ctr nodes. Variable occurrences,
binders, generated nodes, and expanded literals can lose their positions before
this phase. These diagnostics retain their expected/observed/context information
but omit unavailable source excerpts. Parser errors and declaration failures that
still expose only a string retain legacy output. This is not a claim of complete
byte-for-byte diagnostic parity for the entire upstream suite.

## Verification

`tools/verify.mjs` includes the diagnostic and provenance tests. Focused tests use
`BEND_DIAGNOSTIC_API` for an API exporting the diagnostic functions and
`BEND_FRONT_API` for frontend provenance functions:

- `tests/diagnostic.mjs`: 22 renderer, producer, ambiguity, and fallback checks.
- `tests/diagnostic-source.mjs`: eight generated source programs compared directly
  with the pinned upstream checker: six exact complete diagnostics, two exact
  structured diagnostics where source spans are unavailable.
- `tests/frontend/origins.mjs`: imported/beta-substituted references, constructor
  and alias locations, UTF-16 offsets, final-core paths, graph equality, filters.
- `tests/kernel.mjs`: all 43 existing checker/annotation assertions remain valid.

`tools/diagnostic-source.mjs OUTPUT --frontend` assembles a focused diagnostic
compiler. Its guarded instrumentation support also reproduces the earlier isolated
experiment from an uninstrumented kernel. `kernel-instrumentation.patch` records
that source change; production `kernel.bend` already contains it.
