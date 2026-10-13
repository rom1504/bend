# Phase85: B2 code shape and V8 investigation targets

Read-only investigation, 2026-10-13. No compiler build, target execution, source
optimization, or benchmark was performed in this lane. Existing Phase83 CPU
profiles are reused; V8 behavior below is a hypothesis until the coordinating
trace experiment establishes it.

The useful question is **which repeated Bend operations the generated JavaScript
makes expensive**, not whether a large generated file looks unattractive. B2
already removes almost all B1 trampolines. Its Numeric allocation sample was
100.8 MB against TypeScript's 145.45 MB, yet it remains slower. More closure
removal or lower total allocation is not by itself a parity mechanism.

## Reproducible source and profile audit

The [offline scanner](../../../selfhost/tools/performance/phase85/code-shape.py)
reads the selected image and the eight existing Phase83 B2 profiles. It neither
imports nor executes compiler code. Run from the repository root:

```sh
python3 selfhost/tools/performance/phase85/code-shape.py \
  --out selfhost/build/phase85/code-shape-audit.json
```

The resulting [audit](../../../selfhost/build/phase85/code-shape-audit.json)
binds source, lexical helper, scanner, profile summary and each raw profile by
SHA256. It reports exact function identifiers/lines, selected function hashes,
SCC members, static sites, and per-source named self/inclusive samples. The
scanner excludes runtime/export transport declarations and literal/comment
contents from its token census. Nested arrow bodies remain included in their
outer lexical function; arrows are not separately counted as outer declarations.
A wrapper is classified by its small body containing one SCC call; its dispatcher
is a separate row. Anonymous self samples are separately mapped by lexical source
range, not mistaken for the dynamic caller. This is lexical analysis, not a full
JS AST, CFG, bytecode, or dynamic invocation census.

Inputs:

| Input | SHA256 |
| --- | --- |
| Phase82 B2, `selfhost/build/phase82/compiler04-b2/full/compiler.mjs`, 4,731,079 bytes | `098320e8f3e40894156790d740ad205e386f375195b3c6741d67cca96e94e092` |
| Pinned `bend.ts` | `1d133151652b597a1a035c77c172475e6de096da37f3b9e3adc23c2f75bdfe49` |
| Pinned `comp.ts` | `2b13224ba09a9e39e37cccf06e449c1bdafe5e03a81641654f7d0e455507629c` |
| Pinned `main.ts` | `407c0196a47e464640c6557cb06d230016270a40f28ea4250f00936ab79c2f8e` |

Upstream files are under `selfhost/.bootstrap/upstream-phase66/bend2`, pin
`059266225b77c8ca256ac6b25ee5c21449bab151`. Profile receipts identify Node
`v24.18.0`, `--max-old-space-size=1024`, `--stack-size=4096`. Actual enabled V8
features must come from the local executable's options/version, not current V8
mainline defaults.

## Largest is different from hottest

There are **4,037 generated declarations: 170 SCC dispatchers, 526 SCC entry
wrappers, and 3,341 other bodies**. The selected bodies contain 788,257 lexical
tokens and 664 arrow sites, including nested bodies. These are static sites,
not runtime work. Source bytes include generated provenance comments.

| Generated function | Source line | Source bytes | Lexical tokens | SCC states | Formal parameters | Named self ms across eight profiles |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `f_context_publish$scc` | 14063 | 71,428 | 12,930 | 34 | 10 | 34.2 |
| `norm_cmp_loop$scc` | 2724 | 29,292 | 6,219 | 13 | 10 | 5.0 |
| `f_context_grow$scc` | 12918 | 30,178 | 5,660 | 19 | 7 | 59.0 |
| `f_lex_scanned$scc` | 12251 | 18,790 | 3,694 | 5 | 9 | 190.7 |
| `norm_eval_node$scc` | 2065 | 16,416 | 3,368 | 12 | 9 | 72.1 |
| `index_find$scc` | 1416 | 4,189 | 947 | 3 | 6 | 49.0 |
| `book_final_scan$scc` | 1875 | 2,280 | 468 | 2 | 7 | 109.4 |
| `wnf` | 2060 | 230 | 48 | — | 2 | 240.1 |
| `index_lookup` | 1749 | 358 | 54 | — | 2 | 111.8 |
| `subst` entry wrapper | 1024 | 100 | 16 | — | 4 | 99.4 |
| `subst$scc` body | 937 | 4,659 | 980 | 4 | 5 | 80.2 |

The aggregate sums eight different diagnostic requests; it is useful for ranking
shared hotspots, not as a workload-weighted performance score or removable-time
forecast. A wrapper's self samples cannot establish that its call instruction
alone consumed that time. Inlining, sample attribution and first-execution
compilation require separate investigation. Inclusive stacks overlap. The
largest top-level parser SCC has 97.0 ms inclusive but only 10.5 ms self on
Functions65: optimizing its switch cannot automatically recover its callees.
The large comparison SCC is cold here and is a poor first implementation target.

All module import time is outside the qualified compilation request. Removing
comments or reducing module file bytes is not automatically an improvement to
that metric. Lazy function compilation during a request can still matter and
needs a trace aligned to request boundaries.

## Concrete mechanisms to test

### 1. SCC loop layout merges unrelated argument roles

`selfhost/src/back/js/direct/core.bend:284–315` emits one switch loop per tail
component, with parameter width equal to the largest member. Every member gets
a wrapper with that width. Tail transfers assign the same positional `$a0`,
`$a1`, etc., change `$pc`, and continue. This is a correct stack-safe technique;
its V8 suitability is not yet established for these hot components.

In `lookup$scc`, state 0 receives a declaration list in `$a0` and a name string
in `$a1`; later states use `$a0` for a definition and `$a1` for the remaining
list. In `f_lex_scanned$scc`, `$a0` is a scanner-result object in one state and
a string in other states. These are concrete type-role changes in loop-carried
slots, not merely many source functions sharing a name. Maximum-width wrappers
also carry unused parameters for smaller members.

V8's Maglev description explains that loop merges introduce phis and choose
representations compatible with their inputs. Feedback can specialize property
loads, but heterogeneous loop state can limit useful representation facts. This
makes slot mixing a testable risk, **not proof of a deoptimization or megamorphic
access**. [V8 Maglev design](https://v8.dev/blog/maglev).

Test the five-state lexer, lookup, and normalization components first. Record
real bytecode length/register count, tier entry, OSR, deopt reasons and compiler
cost. If evidence supports it, a generated-image diagnostic can compare
semantically distinct loop slots or structured transitions while preserving
stack safety. Arbitrarily splitting a recursive SCC into normal JS calls can
reintroduce stack overflow and is not an acceptable production optimization.
Any successful result belongs in the general Bend JS emitter, followed by B2
reproduction and broad execution controls—not hand-maintained compiler JS.

### 2. Large SCCs can obstruct inlining without exceeding a size ceiling

The Node v24.18.0 V8 source defines a 60 KiB TurboFan optimized-bytecode ceiling
and separate per-function/cumulative inlining budgets. It also exposes filtered
bytecode printing and optimization, deoptimization, OSR and inlining traces.
These limits concern bytecode, **not generated source bytes or lexical tokens**.
The 71 KB parser source is therefore not evidence that V8 refuses to optimize
it. Verify actual runtime flags before selecting a diagnostic configuration.
[Version-bound V8 flags](https://raw.githubusercontent.com/nodejs/node/v24.18.0/deps/v8/src/flags/flag-definitions.h).

The more immediate risk is the small `wnf`/`subst`/`lookup` entry calling a much
larger SCC that cannot inline at relevant sites. `wnf` constructs a Nil argument
and `atom("Absent")`, then calls the `norm_eval` entry of a 12-state component.
`subst` enters a four-state component shared with rebuilding/span application.
Profile these call chains together. Count essential normalization/substitution
work separately from call/dispatch/allocation overhead; their source-level
algorithms differ from upstream and no JIT flag removes required node visits.

For contrast, pinned upstream `bend.ts` directly switches on term constructors
and uses higher-order term openings (`term_apply`, `term_force`, `term_strip`,
`term_higher`, `term_wnf`). It does not mechanically combine its handwritten
normalizer/checker functions into our positional dispatcher. This is a code-shape
and representation difference, not evidence that native recursion is always
better than loopification.

### 3. String destruction still does character work and creates suffix values

`ne_template_plain` at B2 line 63751 loops by reading `codePointAt(0)`, selecting
a one/two-code-unit character, and slicing the remaining string. `kf_char$scc`
at line 4482 has the same generated string destruction and builds a reversed
string with concatenation. The lexer has related scalar calls and scanner
products. `ne_template_plain` has 103.9 ms named self across the eight profiles;
it is payload safety checking, **not** the canonical runtime-template scan
removed in Phase82.

Pinned upstream `bend.ts:1527–1568` advances a mutable position into a source
string and uses `charCodeAt`, `startsWith` and position increments. It usually
does not create a suffix string for each character. This establishes different
work per character; it does not establish quadratic copying in V8. Sliced-string
representation and flattening must be observed before making that claim.

A promising general test is a cursor-based lowering for admitted linear string
walks, or a Bend scanner source representation that carries original string and
index. Preserve Unicode scalar behavior, astral characters, invalid surrogate
handling, source coordinates and raw APIs. An ASCII-only benchmark or replacement
with JS UTF-16 indexing would not prove equivalence. Begin with CPU/bytecode and
allocation evidence for the actual hot loop before expanding parser scope.

### 4. Immutable lookup and generic term access have real work beyond V8 maps

`index_lookup` calls `dc`, `index_first`, the full name hash and `index_find`.
The latter walks an immutable trie and in some branches reconstructs a matched
KDef or KIndexNode. Upstream `book_nil` at `bend.ts:869` has null-prototype
`tlds`/`ctrs` tables, with direct indexed access at consumers such as
`comp.ts:1171`. This is an algorithm/data-structure difference as well as a JIT
question. Do not attribute all lookup time to hidden classes.

The self-hosted KTerm has three physical constructors, with `tg`, `nm`, `ix`,
`ks`, etc. selecting fields. Upstream instead switches directly on semantic
term tags and accesses variant fields. The generated accessors are short, so
whether they inline and whether repeated loads disappear is the relevant test.
The existence of three constructors does not establish a megamorphic site.
V8 associates property layouts with maps and can specialize stable layouts;
actual feedback is needed to identify problematic sites.
[V8 hidden-class explanation](https://v8.dev/docs/hidden-classes).

If allocation survives around reconstructed matches, consider general
match/rebuild identity elimination with ownership/provenance controls. If hashing
and pointer traversal dominate instead, a measured request-local symbol/storage
change is more relevant than tweaking V8 flags. Both require actual attribution;
previous generic caches and full typed-graph retention are counterexamples to
assuming an added table pays for itself.

## Bounded next diagnostic and acceptance criteria

Use one Numeric, Functions65 and lexer request, serially, with exact output and
request-boundary markers. Keep default clean clocks separate from profiled or
trace-heavy runs. The coordinating lane owns execution and resource guards.

1. Bind `process.versions.v8`, the Node executable and effective options. Capture
   default tier/deopt/OSR events for the selected image and pinned TypeScript.
2. Print bytecode for exact SCC names, not only entry wrappers; include register
   counts and the actual dispatchers' lengths. Shell-quote `$` in function filters.
3. Select one hot loop for inlining/feedback inspection. Start with lexer if
   default traces show problematic tiering or mixed representations; otherwise
   follow measured normalization/lookup costs. Do not dump every TurboFan graph.
4. If needed, compare one controlled tier configuration as a diagnostic—not as
   a new default or a speed claim. A cold/warm difference must distinguish
   changed tiering from changed cached compiler work and Base preparation.
5. Prototype only the dominant demonstrated mechanism. Require equal logical
   work where testing code shape, complete output equality, and improvement on
   at least one additional family before a general backend change.

For scale, in the existing Functions65 profile the three frontend SCCs above
sum to 44.1 ms self of a 675.0 ms request; the selected normalization entry/body
sum to 19.5 ms, and selected lookup/hash entry/body names to 38.5 ms. These are
disjoint named self sums, but still neither complete family attribution nor
entirely removable costs. No single one of these observations yet supports the
24.7% total B2 reduction required for parity. A broader shared lowering issue
could affect several families; a cold large function by itself cannot.

This investigation recommends testing V8 execution before another native-plan
rewrite. It does not recommend repeating Phase84 fusion or binding shortcuts,
Phase78 broad source branch expansion, or native hosting without a separate
feasibility/measurement contract. The compiler remains implemented in Bend.
