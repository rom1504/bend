# Reusing an exactly freshened loader prefix

This is a source candidate, not a measured saving. The ordinary loader entry
still validates and freshens the whole graph. The observed loader stage
also contains other work; its duration does not measure alpha-renaming alone.

The private source is [loader-prefix01/prefix.bend](../../selfhost/build/phase61/loader-prefix01/prefix.bend).
It adds an optional entry without changing `FGraph`, ordinary `f_graph_trace`,
the checker ABI or the installed driver. Root has included it in the combined
state candidate; integration and execution are root-owned.
The source and [focused controller](../../selfhost/tools/performance/phase61/loader-prefix/controls-v1.mjs)
have independent static approval. [Frozen identities and scope](../../selfhost/build/phase61/loader-prefix01/focused-freeze.json)
remain separate from execution results; no loader control has run at this checkpoint.

## Existing path

`prepareBase` caches the result of `f_load_graph("Base", ...)`, after the ordinary
`check_book` succeeds. That book has already passed `f_fresh_defs(book, 1)`.
`discoverSources` later injects this exact book at Base's normal dependency
position, then calls `f_graph_trace`. The latter still executes
`f_validate_result`, `f_graph_fresh_result` and `f_fresh_result` over the complete
assembled event list. Error books are also freshened before origin refinement.

`f_fresh_book_stack` visits each definition's type, value and constructor children
in order. Its explicit worklist reserves IDs for All, Lam and Let binders, then
rebuilds every visited term and definition. A certificate must retain the actual
returned next counter. The checker's fresh counter, or a guessed maximum ID,
does not substitute for this traversal's state.

## Additive source rule

`f_fresh_prefix_prepare(prefix)` runs the unchanged freshener once. It returns
only `FFreshPrefixState{next,ready}`; ready requires the original prefix to equal
the freshened output exactly. Comparison includes KTerm variant, literal payload,
removed names, binder IDs, quantities, explicit Lambda quantity presence, source
intervals and every KDef field/constructor. No second full book is serialized.

`f_graph_trace_from_prefix(graph,sources,prefix,state)` preserves the ordinary
whole-graph validation and duplicate-name checks. On success, it compares the
leading declaration-event prefix with the prepared book. Only an exact match
uses the saved next counter to freshen the remaining definitions, then appends
them to the original prefix. Errors, failed preparation and prefix mismatches
use ordinary full freshening. Origin refinement, done events and supplied
sources remain unchanged. Prefix and suffix definitions still begin with empty
lexical renaming environments, exactly as in the whole-book walker.

This retains an equality walk over the prefix while removing its repeated
reconstruction. It is a bounded first experiment. Base can be imported after
another dependency, so the name `Base` or a valid cache alone cannot authorize
skipping a nonleading segment. A source law/fill event is retained in chronological
order; this rule does not use a final lookup book or an unordered set of names.

## Driver and cache boundary

The optional entry is private to a driver-prepared capability. Its scalar state
is not a proof supplied by an arbitrary API caller. Cache preparation must call
the actual producer; cache acceptance must bind the complete state payload to
the same checked API, Base bytes, canonical path, source interval and exact book.
Missing or old-schema state takes the original path. The book and state must
remain immutable throughout a request. A `validatedBy` string does not create
this capability. Existing public load/check entry points keep their old behavior.

This field is independent of the checker agent's `checkedPrefixState`: it only
reuses alpha-renaming. It neither skips checking nor certifies a reusable KWorld.
The cache should store one parsed book plus separate compact freshening/checker
state fields, rather than duplicate a many-megabyte book inside each state.

## Required falsifiers

- Compare the entire old/new FLoadTrace on real located Base plus several source
  suffixes, including exact IDs, quantities, origins, error text and done events.
- Cover empty prefix/suffix, nonleading Base, alias imports, law/fill ordering,
  changed prefix span/quantity/variant/definition and failed prepared state.
- Cover All domain/body ordering, nested Lam, parallel Let bindings, constructor
  definition children and a deep/broad term without a new host stack dependency.
- Compare the actual next counter and require a canonical prepared prefix;
  renamed or malformed prefix inputs must fall back instead of skipping work.
- Exercise stale API/Base/path/interval/book/state cache identities in the host
  integration. Keep public raw callers on the unchanged loader entry.
- Compare full compiler outputs and request latency only after exact loader
  equivalence. Equality checking may consume much of the avoided work; no
  percentage saving follows from this source inspection.

Root-supervised focused command, with fresh output under Phase61:

```sh
node selfhost/tools/performance/phase61/loader-prefix/controls-v1.mjs \
  BASELINE_ATTEMPT CANDIDATE_ATTEMPT selfhost/build/phase61/loader-controls01
```

The controller privately copies the real driver/API, captures ordinary completed
graphs for Numeric recurrence, Evening and Lexer, and compares both original
images with the new entry. It also verifies selected/fallback activation and the
actual freshener's input count and starting counter. Twelve structural cases
cover rejection and empty sides; the isolated Let witness has one binding, so it
does not independently establish multi-binding Let order. It never invokes
cache-writing preparation APIs. Cache authentication and full frontend/program
qualification remain separate integration gates.
