# Native compilation: request costs and the short loop

This records a source audit and a closed diagnostic measurement of the selected
Phase67 compiler. It uses actual checked/profile7 B1 `c76f1113…` and genuine
B2 `cbffd1f8…`; TypeScript remains pinned to `0592662`. Root alone runs compiler,
Clang and executable targets. All previous raw directories remain immutable.

## What is known before new profiling

The closed Phase67 acquisition recorded the following single-request diagnostics.
They are separate epochs, not a balanced B1/B2/TS compilation comparison. Bend
explicitly prepared Base before each request, which also warmed its API. TS loaded
and checked Base inside the request. Preparation misses and hits must not be
pooled: the first selected Numeric preparation took 3.290 s, while the Array and
Lexer cache reads took about 83 and 81 ms.

| Program family | Selected B1 checked Bend→C | TS load/check + C emission | Selected C bytes | TS C bytes | Selected Clang | TS Clang |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Numeric | 1.722 s | 0.703 s | 1,645,611 | 117,622 | 13.752 s | 0.946 s |
| Array fold | 2.003 s | 0.711 s | 1,676,027 | 118,820 | 14.128 s | 0.905 s |
| Lexer | 2.518 s | 0.885 s | 1,977,087 | 144,943 | 16.789 s | 1.069 s |

Sources are the pinned `native-scalars01`, `native-heldout-scalars01`,
`native-baseline02`, and `native-heldout-baseline02` acquisition reports under
Phase67. The new plan joins each complete-C oracle to its actual emission
receipt, compiler identity, original recipe, wrapper and independent executable
oracle. B2 must independently reproduce the same complete C before inheriting
that finite executable observation.

The roughly fourteenfold C size gap affects both emission and Clang. Therefore
native program optimization and compiler iteration speed are partly the same
problem: fewer unnecessary closure/continuation segments can shrink output and
reduce Clang work. Rebuilding those binaries on every compiler diagnostic would
waste most of the iteration budget. The existing seven-second Bend-only runtime
loop remains the right tool after binaries have been acquired.

## Actual request pipeline

`tools/typed-driver.mjs::inspectWithMemo` performs these operations for native
mode:

1. Read the prepared Base frame; discover files; parse and complete source into
   the private prefix carrier.
2. Check the owned request against the prepared world. The existing result
   already includes specialization and completion/TODO validation.
3. Generate declaration/trust reporting when requested; enforce owned names and
   main/IO restrictions.
4. Determine native annotation stops, find the reachable source definitions,
   annotate them, and merge annotations into the complete type-level context.
5. Validate runtime layouts, discover C foreign paths, and convert the required
   foreign sources.
6. Run `nc_compile`: enforce native policy and binder limits; erase, compact and
   lower reachable definitions; collect constructors/show support; validate the
   native IR; construct tables and render C.
7. Return C. `native-build.mjs` chooses the native target and invokes the toolchain
   only when a caller requests an executable. Execution is another operation.

The measurement must keep imports/API initialization, explicit cache preparation,
the ordinary checked request, Clang process time and executable runtime separate.
The fast loop stops after step 6. It uses `withReport:true`, matching the existing
native acquisition, and includes its reporting cost in the request.

## Source-backed opportunities, not yet measured gains

**Retain the native context's exact binder maximum.**
`nc_annotated_context` already computes `norm_max_book(merged)` and stores it in
`book_cached`. `nc_compile` subsequently runs `norm_max_book` on that cached book
again. That walk enters the sentinel's index and then the original list, revisiting
definition terms. The retained maximum is exact for this producer; the trie adds
no term binder IDs, and its stored definitions come from the merged list.

An arbitrary public cache marker is not an authenticity proof. The isolated
[`cached-bound-v1.patch`](../../selfhost/tools/performance/phase68/compilation/cached-bound-v1.patch)
therefore leaves public `nc_compile` on its full scan. One optional private entry
uses the saved maximum only after the owned host has just called the actual
`nc_annotated_context`. Its guard remains after owned-name, main and foreign-main
rejections, preserving error and demand order. Old images and injected APIs take
the public path. The proposal adds ten Bend and three host lines, no type or
persistent-cache schema, and is unselected/unexecuted. Its value must first be
supported by the profile; adding an export has qualification costs.

Required controls before promotion: exact public behavior with forged-low,
forged-high and absent cache markers; exact boundary IDs 3,999,999,999 and
4,000,000,000; early rejection precedence; actual private activation only on owned
fresh annotation output; public/injected and old-export fallback; and complete C
equality on the three fast families plus ordinary native correctness controls.
The direct private function is a capability consumer, not an arbitrary-input
authentication API.

**Share the original indexed context before annotation.** Native mode currently
bypasses the driver's `book_context_world` path. `reach_book` therefore receives
the plain checked list. `annotate_selected` then builds its own context internally;
the later annotated context builds another index and maximum. This does not mean
annotation itself uses only linear lookup: it already calls `book_context`.
Reuse must preserve raw declaration order, stop selection, layout errors and the
public/injected fallback. Measure these stages before adding another context.

**Reuse erased definitions for reachability and compilation.**
`nc_foreign_paths → nc_live_names → nc_definition` erases reachable bodies.
The immediately following `nc_foreign_scope` independently calls `nc_live_names`,
repeating that erasure. `nc_compile_defs → nc_compile_def → nc_definition` erases
them a third time before compaction/lowering. A request-local native plan could retain erased bodies,
references, foreign paths and fresh-ID dependencies. Its dependencies and error
ordering must be explicit; carrying only a name-indexed body without the context
would be unsafe. The existing `nd_arity` is already a leading-lambda/telescope
query: it does **not** erase whole target definitions and must not be counted as
another erasure pass.

**Lower once where closure and direct entries share work.** `nc_compile_def`
lowers the ordinary closure entry; `nd_extend` also lowers the function's direct
body when it has parameters. General closure/direct ABI improvements may remove
both duplicate work and emitted continuations. This is a larger native backend
change, with stronger potential for program runtime and Clang time than a small
metadata cache. Retain partial application, reference ownership, bang/fork and
error behavior; do not infer a whole-request gain from a syntax count.

**Reuse existing Base annotation products where native policy permits.** The
native driver currently uses ordinary selected annotation. The optional retained
products are produced independently by `ka_def`, but producer selection uses JS
stops. A native consumer can only reuse keys actually present, after native stops
win and the same owned checked-Base identity proof passes. Foreign/native policy,
custom Base refusal and demand order remain mandatory. This is an opportunity to
share an existing mechanism, not permission to enable it without native controls.

**Profile table construction and text passes.** `ne_program` renders segments,
constructs multiple tables, and performs four marker-replacement passes over an
increasing C string. Fork closure uses repeated list membership/closure scans.
These are observable candidate costs; modern JS string representation means a
textual concatenation count alone cannot prove quadratic allocation or time.

## Minimal measurement method

The reviewed source is in
[`selfhost/tools/performance/phase68/compilation`](../../selfhost/tools/performance/phase68/compilation/README.md).
The first frozen plan is `selfhost/build/phase68/native-compilation01/plan.json`
(`2991d80b…cf39f8`). Preparing it only copied and hashed source/data; no compiler
target was run by this lane. It has two explicit preparations, nine clean fresh
requests over Numeric/Array/Lexer and TS/B1/B2, and four optional profile requests.
One sample per cell is a discriminator, not a stable speed score. Three rotations
per case are available for a position-balanced comparison.

All projects and caches are fresh Phase68 copies of the selected immutable host
and native runtime. The actual compiler images retain their original paths and
hashes. Every clean request imports the API afresh, then reads its already prepared
mandatory cache inside the measured request; it does not call `prepareBase` before
that request. TS ordinary `book_load` includes Base loading/checking. This is an
explicit product-workflow comparison, not an assertion of identical internal
caching policies or cold OS page caches.

Diagnostics forward the actual owned API, time only its public host-entry calls,
and collect a V8 profile between request start and return. Internal recursive
calls may bypass public wrappers, so erase/lower/render attribution comes from
the unmodified generated compiler's sampled stacks. The analyzer reports nearest
recognized frozen-source owner, leaf costs and inclusive function unions, retaining
unattributed/host/GC samples. Inclusive rows overlap and cannot be summed.
Diagnostic clocks never enter clean medians.

Root can run only preparation and the clean screen first, then request the four
profiles if useful. Historical single-request durations suggest tens of seconds
for this screen plus explicit preparation, rather than repeated C builds. That is
an estimate until the guarded method runs. Any changed complete C, refusal, cache
mutation, missing expected stage, resource limit or identity drift stops the run
and retains the failure. Clang and independent runtime validation remain required
for an optimization that intentionally changes C; historical byte equality cannot
qualify new output bytes.

## Closed baseline: repeated template construction dominates a useful slice

All fifteen jobs in `native-compilation01` passed, including every complete-C
oracle and both explicit preparations. The data-only summary is
`selfhost/build/phase68/native-compilation01-summary.json`
(`93137689…b0801`). These are one clean observation per case/role, not the broad
compiler score or a position-balanced result:

| Family | TS checked request | B1 checked request | B2 checked request | B2 / TS |
| --- | ---: | ---: | ---: | ---: |
| Numeric | 783 ms | 2,137 ms | 1,921 ms | 2.45× |
| Array | 715 ms | 2,018 ms | 1,845 ms | 2.58× |
| Lexer | 928 ms | 2,569 ms | 2,300 ms | 2.48× |

Imports were separate: B1 61–70 ms, B2 106–117 ms and TS 231–251 ms. Explicit
mandatory Base preparation took 3.228 s for B1 and 3.077 s for B2. These caches
were then read inside each fresh request; preparation did not manufacture native
annotation sidecars. Clang and program execution were not repeated because the
complete C reproduced the previously qualified executable inputs.

In the separate B2 diagnostic requests, `nc_compile` accounts for 61–66% of
request wall time. The strongest source-specific leaf is **`ni_templates`**:
312 ms Numeric, 260 ms Array and 273 ms Lexer. Every template lookup currently
constructs the entire 69-entry linked catalog before selecting one string.
Both emission and membership queries use it. This is repeated compiler work
independent of any particular benchmark name.

[P68-006](../../experiments/phase68/P68-006-demand-templates.md) replaces that
catalog with one lazy selector containing the same 69 literal pairs and an empty
miss path. The isolated patch removes the catalog type and list/search helpers;
it does not introduce a second production table, cache, host algorithm or API
root. Formatting the formerly single-line table increases physical lines by 63
while removing one type and one net definition. Source/data review passed;
runtime controls and full-C equality remain required before selection. The
observed leaf slice supports testing roughly a 10–15% B2 request reduction,
not promising it. The profile also records 355–531 ms of GC, but does not prove
how much of that belongs to template allocation.

The next measured areas are text rendering and the native plan. Native text
helpers own 278–320 ms; `nt_replace_step` alone has 97–122 ms self samples.
`ne_program` has 342–416 ms inclusive samples, overlapping those helpers.
`nc_lower` has 488–530 ms inclusive samples, also overlapping template lookup
and other descendants. These numbers must not be added. Annotation is only
66–91 ms in these profiles, so extending its retained products is less urgent
than removing eager template work. B1's trampoline and anonymous-frame shape
obscures attribution; the B2 self percentages are not B1 measurements.

The profiler retains a small inspector-control tail after the request returns
(about 24 ms here). The analyzer keeps it as host/unknown sampled time rather
than silently treating total profile samples as request wall time.

## Text-splicing follow-up: preserve sequential first-occurrence semantics

The four `ne_fill` calls replace the first occurrence of Tables, Spins, Segments
and Requests, in that order, retaining the marker and appending its generated
payload. Public `nc_compile` accepts an arbitrary runtime string. Markers may be
absent, duplicated or out of order; an earlier inserted payload can itself
contain a later marker. A one-pass replacement of markers in the original
runtime alone would change those cases.

The first experiment should therefore compare complete output on synthetic
runtime strings with every marker order, duplicates, missing markers, and each
later marker inside an earlier payload. Two defensible implementation routes are:

* Preserve the public sequential renderer and give an authenticated canonical
  runtime a specialized splice path, with a proof or explicit fallback for
  marker-bearing generated/foreign fragments. Runtime identity alone does not
  establish the payload condition.
* Represent output as a short sequence of original/generated pieces, apply each
  first-occurrence insertion to that sequence, and concatenate once. Search must
  include inserted pieces and matches crossing piece boundaries. This preserves
  arbitrary input semantics but adds machinery; benchmark its allocation before
  keeping it.

Neither route is implemented or selected here. First reprofile after the much
smaller template change: reduced GC may change the apparent rendering budget.

## Templates05: correctness passes; B1 has no measured gain

The strict Templates05 build passed all 69 catalog entries / 285 distinct names,
including membership and seven substitution vectors. Numeric, Array and Lexer
also reproduce the qualified Prefix04 complete C exactly. The acquisition
request clocks do **not** show a gain: Numeric 2,344→2,436 ms, Array 2,616→2,601 ms,
Lexer 3,309→3,350 ms. These separate single observations are a rejection of any
current speed claim, not a precise regression estimate.

The [generated-source comparison](../../implementation/phase68/evidence/template-lowering-source01.json)
rules out the suggested explanation that old B1 hoisted a shared table: both old
B1 and B2 contain 69 `Con`, 69 `ni_Op` and one `Nil` literal inside the called
function. Neither explicitly shares the table. Actual V8 allocation elimination
would still require runtime evidence.

The control flow does differ. Old B1 lookup takes trampoline/closure steps;
old B2 lookup uses a direct loop. New B1's 10,383-byte selector contains 70 nested
`run_tail` choices. Removing the catalog can therefore trade its cost for
closure/trampoline work and a larger generated function. This is a plausible
explanation, not a proven causal result. B2's existing literal-choice lowering
suggests a cheaper direct chain, which must be checked in the actual new B2.

The minimal Templates05 B2 plan is staged through the existing reviewed
tiny/full/source/direct-comparison sequence. It constructs genuine image
lineage without running the final self-check, fixed-point or JS23 gates; those
remain required for promotion. Native workers can then use the explicit
`--oracle-attempt` method to compare both selected images with Prefix04's
runtime-qualified C, retaining the original oracle producer instead of
rebuilding identical executables.

The actual Templates05 B2 now confirms the expected code shape: its
[`ni_template`](../../implementation/phase68/evidence/template-lowering-source02.json)
has 70 direct literal branches, zero trampoline calls, and no eager catalog.
Its full emission and eight driver comparisons pass. The frozen native request
plan `native-compilation-templates05-01` binds B2 `58d3bbe2…` separately from
Prefix04's qualified C producer. The first clean screen is still pending at
this observation; this code-shape result alone establishes no speed gain.

## Inline09: remaining compilation work

All fifteen actual Inline09 request observations now pass complete C equality.
One clean observation per role gives B1 2,285/2,432/2,988 ms and B2
1,415/1,442/1,954 ms for Numeric/Array/Lexer; the same-plan TypeScript requests
are 707/724/862 ms. The B2 ratios are 2.003×/1.990×/2.265×. This is a screen,
not a balanced final result. Intervening native changes also prevent assigning
the difference from Templates05 to occurrence summaries alone.

The [full-stack census](../../implementation/phase68/evidence/native-request-hotspots09.json)
shows 551 ms B1 Numeric and 152/174/180 ms B2 in occurrence collection including
its index work. The nearest visible native callers include `nc_lower`,
`nc_lower_to`, `nc_live_env` and `nc_share_env`; these are sampled attribution,
not exact invocation counts. Four existing let functions visibly collect the
same body up to three times. [P68-012](../../experiments/phase68/P68-012-local-occurrence-reuse.md)
therefore tries local summary reuse, adding six lines and no new type/function.

Renderer measurements need a narrower interpretation than the total text-module
budget. `nt_lines` inclusive sampled time is only 46 ms B1 Numeric and
26/27/19 ms B2. `nt_replace` is 20 ms B1 and 158/143/177 ms B2. Replacing
`nt_lines` with `String.join(String.lines(s), "\n    ")` is extensionally exact
and seven lines shorter, but both actual compiler images implement String.lines
through non-tail-recursive String.split. It is not a native JavaScript split
operation. This source-only alternative is retained under `renderer-lines`,
but introduces a large-body stack-risk hypothesis for a small speed ceiling.
The occurrence reuse is the stronger shared B1/B2 experiment.
