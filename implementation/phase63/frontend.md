# Phase63 ready frontend state

Status: implementation candidate; no compiler target or speed result yet.

The existing Phase61 private carrier skips freshening the authenticated Base
prefix, but rebuilds parser name and constructor indexes for each source,
rebuilds the name index for module freshness, and scans the full Base term tree
and declaration events again during final graph validation. Phase62 attributes
160.83 ms to source completion and 62.64 ms to final prefix-aware graph tracing;
these are enclosing costs, not a prediction of removable time.

The candidate prepares an immutable `FReadyPrefixState` from the exact cached
Base definitions. Preparation checks the existing error and freshness rules and
retains the top-level event count, latest-event name index, and first-depth-first
constructor index. The private host binds this state to the exact compiler,
Base/source bytes and source interval. It is intended to share definition/term
objects with the checked world through the separately owned DAG transport;
ordinary JSON would duplicate the indexed definitions and is not the design.

A second `FPrefixGraph` constructor carries those indexes through actual source
completion. The old constructor, public seed paths and raw graph APIs keep their
full validation behavior. The ready constructor can only be selected from an
eligible leading global Base injection plus admitted prepared state. Each module
still uses the ordinary contextual parser, fill logic, qualification, paths and
error rendering; only its initial parser scope and freshness lookup reuse the
indexes. After completion, only newly appended definitions extend the indexes.
Name insertion uses latest-event semantics; constructor insertion retains the
first depth-first occurrence, including nested constructor lists.

Final tracing checks the actual suffix against the saved Base name index and
freshens that suffix from the separately authenticated freshening counter. It
still preserves the full loaded graph, source origins, imports and first error
selection. An invalid or nonleading state falls back to the original path.

## Required controls

- Compare complete loaded traces and checked outcomes with the old path on Base
  alone, Numeric, MapSet, imports, aliases, laws/fills and duplicate declarations.
- Leading global seed admission succeeds; changed path/text, prior events,
  nonempty namespace and invalid prepared state retain the fallback.
- Reused parser names equal `index_build(reverse(prior))` including law/fill
  events; constructor lookups retain the first depth-first occurrence when names
  repeat. Check nested constructors and namespace qualification.
- Malformed later fragments preserve diagnostic ordering and source locations;
  whole-graph validation remains available for public raw callers.
- Frozen prepared state remains unchanged across multiple source completions and
  multiple requests. Output modules and typed compiler behavior must match.
- Counter/trace evidence must show Base error traversal and parser-index rebuilds
  disappear on the selected private path; clean short timings decide retention.

Source/data work is CPU0 only. Root owns every guarded Node/compiler/test target.

## Implemented candidate and controller

`src/load/prefix.bend` adds the immutable state, the second carrier constructor,
its admitted seed entry, and incremental index maintenance. `load/modules.bend`
and `load/graph.bend` add private indexed completion helpers. Existing raw paths
and the `FPrefixLoad` checker handoff are unchanged. The ready graph still retains
the full book on errors: validating only the suffix must not make fallback
freshening or origin refinement lose the prefix.

The [controller](../../selfhost/tools/performance/phase63/frontend-controls.mjs)
accepts `CHECKED_ATTEMPT SOURCE [SOURCE...] NEW_PHASE63_OUT`. It verifies the
frozen checked attempt and compares all contextual completions, whole graph
traces, diagnostics and logical index contents between old and ready paths.
Alongside supplied real programs it covers 14 maintained frontend fixtures,
eight producer admission/fallback cases, two synthetic constructor/namespace
precedence cases and four forged public-seed controls. Prepared objects are
deep-frozen and their complete serialized identity is checked afterward.

A same-count reordered prefix presented directly to the private ready entry is
not independently authenticated by its count. Exact prepared-state/Base coupling
is deliberately a private host admission obligation, as with the checked-world
snapshot. The public-seed controls assert that adding prepared metadata to raw
caller objects does not select private carrier APIs. Separate host controls must
cover identity and cache replacement. No target was executed by this source
owner; root owns candidate checks, controller execution and measurement.
