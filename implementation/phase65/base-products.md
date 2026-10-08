# Phase65: immutable Base backend products

Status: **both discriminators passed; isolated annotation source candidate
reviewed and frozen for integration. No compiler change selected for release.**
The input is installed Phase64 State09, baseline checkout `49431ba`, with genuine
B2 image `b09fe54ad58d105d1c77ccb399f4076660d6109cf2a7f4b21e13933b89c22c2e`.
Closed Phase64 raw evidence remains unchanged. Root owns all target execution.

## Hypothesis and smallest decision

Prepared Base currently saves checking, frontend indexes, original TODO counts
and the exact checked bound. The backend still annotates reachable non-stopped
Base definitions, constructs their local call rows, checks their executable
layout demands and lowers them on every request. The hypothesis is that some
of these products depend solely on the immutable checked Base lookup closure.
If those operations are cheap or products vary by request, do not build another
cache layer. The first candidate is **annotated definitions**, followed by local
call rows. SCC membership, selection and generated text remain request-local.

The [census controller](../../selfhost/tools/performance/phase65/base-products/census.mjs)
appends observers to a copied actual compiler image and clones the small staged
project, so preparing that diagnostic cannot write into the consumed measurement
project. It retains driver-owned API
identity and requires execution of the authenticated ready-world route. It
classifies a definition as Base only when its complete structural digest agrees
with a definition from the actual `prepared.checked` list, or the annotation
just produced from that exact definition. Names alone do not grant ownership.

It records independent root operations: `ka_def`, the top-level
`jd_calls_body` for its `jd_calls_row_arity` owner, the top-level `j_layout_term`
matched by exact term/type identity against the current `j_layout_error` input,
and `jd_doc_definition`. B2's layout SCC bypasses the apparent `j_layout_def`
function; observing that wrapper would silently miss the work. Every selected
source must activate all four operation classes. Nested term calls are not
added again. Local layout products exclude the unchanged incoming worklist tail;
the complete caller still decides ordering, reach and first refusal.

For every actually annotated Base definition, a second computation uses only
the exact forward checked Base context and compares the complete resulting
`KDef`. Across source requests, product digests are also compared for identical
input definitions. Native stops are recorded separately: a stopped definition
is not an annotation-cache hit. Lowering differences are evidence against text
reuse, not a reason to weaken byte equality.

Instrumented times rank work only. Observer branches, explicit trampoline
forcing, hashing, repeated requests and JIT warming change execution. They
cannot establish a clean speedup. Every observed request must equal the full
disabled-observer driver observation and the qualified complete module oracle.
One request per source is observed after its reference request; this is not a
fresh latency benchmark.

## Dependency and admission contract

An eventual producer must be implemented in Bend and bound to the exact API,
Base source identity/range, term/span ABI and prepared-world version. Host code
may serialize its product; it must not synthesize semantic compiler facts.

The product must derive from **checked Base output**, not final raw Base or a
name-only reconstruction. The existing raw-prefix closure check alone is not
a proof for all transformed products. Review the references/ADT lookups in the
actual checked definitions and all recursively reached definitions. Existing
collision, constructor-disjointness, suffix namespace and authenticated-carrier
admission remain prerequisites. Unsupported or mismatched contexts use the
ordinary backend; no capability follows from a public arbitrary book.

`ka_def` creates `KEnv{kw_initial(book),...}`. `kw_initial` has deferred freshness,
and annotation itself reads the book and existing binder IDs; it does not ask
for a new request-level fresh ID. WNF, substitution, telescopes and match-goal
construction still require exact lookup closure. High suffix binder IDs therefore
remain a control, not an established source of annotation dependence. Complete
product equality includes spans, quantities, annotations and binder IDs.

The per-request stop policy must still choose between original and annotated
definitions. Local call rows additionally depend on native admission, numeric
layout policy, exact annotated lookup bodies, live arity, per-body fuel and
unknown-call classification. Their ordered edges/unknown/arity may be reusable;
the caller must recompute whole selected-graph validation, SCCs, component order,
bounce propagation and existing budgets. A cached failure must not move ahead
of an earlier request error or charge a different amount of fuel.

Layout analysis can produce an ordered local demand list, including the refusal
marker. Its global traversal/stops/error precedence remain dynamic. Lowered text
also embeds SCC membership, parameter widths and request policy decisions. It
is excluded from the first implementation even if several samples agree.

Transport can already encode `List<KDef>`, terms and local `JDCall` rows in
frame4. A production product envelope would need explicit producer/version and
optional-root ownership. Missing or invalid optional products must discard only
that acceleration and keep the validated mandatory book; a present corrupt
mandatory frame retains strict refusal. Cache admission must not add a full
per-request product/closure rehash that costs as much as the saved traversal.

## Fast execution and stop conditions

Root first produces a bound input using CPU0 data work:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase65/base-products/prepare-config.py selfhost/build/phase65/baseline-state09/preparation/report.json selfhost/tools/performance/phase65/base-products/census-input01.json numeric-recurrence lexer test-map-set-ops
```

Then, under the existing single CPU3 memory/time guard:

```sh
taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node --stack-size=4096 --max-old-space-size=1024 selfhost/tools/performance/phase65/base-products/census.mjs selfhost/tools/performance/phase65/base-products/census-input01.json selfhost/build/phase65/base-products-census01
```

The initial budget was 30–60 seconds; the completed run took 10.65 seconds. The
controller checks lexical declarations before importing the derivative. Source
inspection has confirmed the needed symbols in the actual B2 image.

If annotations differ, identify the first exact dependent lookup before any
reuse patch. If Base annotation plus local call-body work is below approximately
5% of whole measured request cost, stop this lane unless a larger layout product
has a clean closure proof. If meaningful, prototype one optional Bend-produced
annotation cache and compare its read/decode/admission cost with work removed.
Use a clean three-source screen and a held-out source before broader B2 gates.
No sum of per-operation diagnostic clocks is a projected parity result.

Focused controls must cover actual Base-only versus source contexts; a high
binder floor; source template instances; native/foreign policy activation;
native stops; imported alias and constructor collisions; closed-name hash
collision fallback; invalid optional product version/identity; raw public books;
ordered diagnostics and exact full emitted modules. No production schema or
source patch is selected before the discriminator runs.

## First executed discriminator

Root's [three-source diagnostic](../../selfhost/build/phase65/base-products-census01/report.json)
passed in **10.65 seconds**, including setup and controls. All complete driver
observations and qualified modules match. It captures 463 checked Base
definitions. Used Base annotation products agree exactly with the same definitions
annotated under only the checked Base context: 11 in Lexer, 78 in Map and seven
in Numeric. The Base-only bound is 3,412; request bounds are 3,577, 3,575 and
3,425 respectively. These finite observations support the closure hypothesis;
they do not prove arbitrary prefix or product reuse.

| Source | Base annotation calls / diagnostic ms | Base call-body scans / ms | Base layout roots / ms | Base lowering calls / ms |
|---|---:|---:|---:|---:|
| Lexer | 11 / 0.97 | 3 / 0.11 | 1 / 0.02 | 1 / 0.11 |
| Map | 78 / 116.89 | 65 / 35.01 | 62 / 11.81 | 63 / 73.62 |
| Numeric | 7 / 0.06 | 1 / 0.03 | 0 / 0 | 0 / 0 |

These are instrumented, already-warmed operation clocks. Map's `Map.pop.go`
accounts for 94.29 ms of its annotation sample; compilation/JIT/GC effects can
distort individual events. Do not translate this table directly to clean gains.
It decisively identifies substantial repeated closed-Base work in Map, while
the same proposed cache could easily make Numeric or Lexer slower if eagerly
materialized for every request.

Only **16 products** are repeated across different sources in this first sample:
11 annotations, three call scans (`Word`, `Pair`, `Bool.and`), one layout product
and one lowering product (both `Bool.and`). All agree. The other 62 Map Base
lowerings have no cross-request comparison; zero observed differences does not
establish general text reuse.

The consumed controller is preserved exactly as
[`census-consumed01.mjs`](../../selfhost/tools/performance/phase65/base-products/census-consumed01.mjs),
SHA256 `1bd91176b1688905ecac415250da7fcbdefb1cb7755b3be2e1c16c7ecfb56af9`.
The current controller gained one optional copied-helper provenance check after
the successful report closed: report mtime 01:01:39.540 UTC, edit 01:01:50.404 UTC.
The [explicit method relocation](../../selfhost/tools/performance/phase65/base-products/census-consumed01-relocation.json)
binds the old report to its byte-identical preserved source. No old receipt was
edited or silently repinned. The successor is unconsumed; both methods and the
observer template are now frozen.

## Annotation retention prototype and net-cost test

[`annotation-candidate.bend`](../../selfhost/tools/performance/phase65/base-products/annotation-candidate.bend)
is an isolated Bend-only candidate. Its producer accepts the actual prepared
world, rejects an unready state, and reverses its exact checked list inside Bend.
It requires checked lookup closure plus implicit literal implementation type
names, then stores non-stopped
definitions above a generic body-term work threshold. Its private consumer
checks current stops before lookup and otherwise falls back to ordinary `ka_def`.
The selected world-version-three admission bridge preserves current source/name/constructor/
hash/binder guards. This artifact does not alter the prepared-world shape.

The returned product has a small key list and a cached annotated book. Both can
use existing frame4 root types; a separate optional artifact needs explicit
version/layout and API/Base/source-range binding. A Bend-owned membership query
can request the heavy decode only when selected definitions intersect its keys.
No benchmark names occur in the policy. Host transport must never infer the
semantic permission from the presence of a cached world alone.

Before integration, the frozen
[`artifact-census.mjs`](../../selfhost/tools/performance/phase65/base-products/artifact-census.mjs)
annotated the complete pinned checked Base through the existing Bend API. It
measured actual extra graph records and bytes at generic thresholds
0/32/64/128/256 terms, plus read/hash/validate/materialize cost with the existing
prepared graph already decoded. Exact reconstructed definitions are checked.
Its three same-process decoder samples are a cost discriminator, not a clean
fresh-request performance result. The command takes the same input JSON and a
new Phase65 output directory; root ran it under the standard guard.

The [artifact discriminator](../../selfhost/build/phase65/base-annotation-artifact01/report.json)
passed in **4.12 seconds**. The existing source/prepared graph contains 46,757
nodes and approximately 1.16 MB. Full Base annotation terminated in 178.24 ms
outside the request clock. Of 463 checked definitions, 275 are eligible before
the work threshold.

| Minimum body terms | Product definitions | Extra nodes | Product bytes | Key bytes | Median materialization ms |
|---:|---:|---:|---:|---:|---:|
| 0 | 275 | 48,484 | 1,111,640 | 10,616 | 37.86 |
| 32 | 42 | 27,317 | 627,036 | 1,676 | 5.26 |
| 64 | 12 | 19,006 | 437,464 | 520 | 3.39 |
| 128 | 8 | 17,178 | 395,676 | 368 | 16.31 |
| 256 | 7 | 14,970 | 345,408 | 316 | 3.83 |

Every decoded product equals the original complete definition. The materialization
samples include file reading, one digest, validation and reconstruction relative
to the already decoded prepared graph. They are three same-process samples;
GC and warm-up noise explain the non-monotonic rows. They are not fresh-process
request savings.

The first candidate uses **64 body terms**, counted by Bend without naming any
benchmark or Base function. Its 12 products cover seven Map annotations from
the first census, accounting for 110.61 ms of that diagnostic sample. Numeric
and Lexer have zero hits, so they should not read or decode the heavy product.
The independent fresh B2 stage profile places total annotation at 111.71 ms
for Map, 10.67 ms for Lexer and 2.92 ms for Numeric. This supports trying the
cache but does not justify subtracting the diagnostic times from clean latency.

## Frozen source integration contract

The [source patch](../../selfhost/tools/performance/phase65/base-products/annotation-source-v1.patch)
adds one module, `src/check/base-products.bend`, and its manifest entry. Source
review passed and `git apply --check` passed; checked compilation and runtime
controls remain pending. The patch and its [metadata](../../selfhost/tools/performance/phase65/base-products/annotation-source-v1.json)
are frozen. Selected prepared world v3 is unchanged; the rejected constructor
index experiment is not included.

The four private exports are:

- `base_annotation_prepare(preparedWorld, minimumWork)` returns
  `KBaseAnnotationState{keys,book}` from the producer's actual checked Base.
- `base_annotation_wanted(selected,stops,keys)` decides in Bend whether any
  selected, currently non-stopped definition could use the optional artifact.
- `base_annotation_allowed(load,preparedWorld)` repeats exact current prefix
  admission and excludes hash-collision replay before reuse.
- `annotate_selected_base(context,selected,stops,productsBook)` preserves selected
  order and current stops, using ordinary `ka_def` for missing products.

The host must also require the same owned API, successful world-check route,
request carrier and prepared context that produced the current checked book.
A prepared world merely being present is insufficient: its checker might have
fallen back. The wanted test precedes the expensive admission and artifact
decode. Optional artifacts are separately bound to the exact API, Base source
identity/range, ABI and parent source/prepared frame identities. Missing,
malformed or mismatched optional artifacts use ordinary annotation. They cannot
weaken mandatory-frame validation.

This producer is private and optional for the pinned Base whose full annotation
was observed to terminate. It is not a claim that eager annotation of arbitrary
unselected unsafe prefixes preserves demand. Public arbitrary-book annotation
retains its original behavior. The first clean screen must establish the actual
net gain, including key loading, hit admission, heavy materialization and any
code-size effects; no production speedup is claimed yet.
