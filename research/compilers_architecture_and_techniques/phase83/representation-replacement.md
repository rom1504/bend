# Phase83: replace native work, rather than retain another graph

Investigation date: 2026-10-13. Source baseline: `8042809`, selected Phase82
compiler04. This is a source and evidence investigation, not an implemented
optimization. No compiler build, target run, or production edit was performed
by this investigation agent. A later section analyzes four new observation-only
requests run serially by the lead agent. It extends [Phase81](../phase81/README.md) and the existing
[Zig survey](../zig.md), with newly inspected primary sources below.

## Finding

The compiler already has a request-local per-function cache. Reintroducing
erased bodies, arity, or compact bodies under an IR name would repeat existing
work. The substantial unimplemented opportunity is to **produce runtime code
and its required semantic facts directly from checked source**, replacing the
annotated graph and its subsequent consumers on the owned native path.

However, the measurements do not establish that this change alone can deliver
parity. Functions65 has only 6.4 ms of annotation in the final diagnostic run.
Its frontend, metadata, reports, and backend planning also need investigation.
Do not authorize a broad IR migration from the old 15–25% estimate alone.

## What the source actually does

Paths below are relative to `selfhost/`. The inspected production files are
unchanged. Function names provide search anchors independent of line movement.

| Boundary | Existing product and repeated interpretation | Consumers and constraints |
|---|---|---|
| `tools/typed-driver.mjs:897–926` | Select reachable definitions; `annotate_selected`; validate layouts; `nr_prepare_annotated`. | Reports/checking already happened. Layout failure must precede foreign loading and native emission. Raw or injected APIs retain their older path. |
| `src/check/annotate.bend:annotate`, `ka_node` | Normalize type heads; infer application types; substitute dependent telescope tails; wrap runtime syntax in `Ann`; store field quantities. | Shared with JS. Annotation establishes lambda quantities and match goals; it is not merely attaching an optional debug type. |
| `src/back/js/validate.bend:jl_checked_error`, `jl_node` | Traverse annotated reachable bodies, inspect intrinsic calls and runtime-relevant fields, detect open array layouts. | Erased arguments and unreachable match alternatives have specific treatment. Constructor/literal shortcuts are significant. |
| `src/back/native/request.bend:nr_prepare_annotated`, `nr_walk`, `nr_visit` | Merge annotated definitions into full context, build an index and exact source bound, erase runtime-reachable bodies, rediscover references, retain erased body and arity. | `NR_Request` holds source, prepared book, names, foreign paths/scope, and bound. This is already a request product. |
| `src/back/native/erase.bend:nc_erase*` | Interpret `Ann` type heads again; reconstruct constructor telescopes; erase arguments/fields/lambdas; compute match field counts/masks and identities. | Quantities, dependent substitution, equality proofs, native constructor identities, and raw behavior must stay exact. |
| `src/back/native/scalar-array.bend:ns_definitions`, `ns_unshared_terms` | Read **annotated source** again for scalar-array permission and type-sensitive sharing checks; query occurrences in erased bodies. | This permission also authorizes root observers. It cannot be replaced by a scalar-width flag without preserving the stronger effect/identity contract. |
| `src/back/native/static.bend:ns_defs`, `ns_def_step` | Read cached erased body, compact literals, construct static-body representation and static image. | `NativeStaticBody` retains its `NativeErasedBody` predecessor. Observers need the original pre-compaction body. |
| `src/back/native/product.bend:nq_signature_user`; `flat.bend:nf_worker_kinds` | Revisit the function telescope separately for live arity/product shapes and scalar parameter kinds. | Product width bounds, normalization fuel, opaque fallbacks, and dependent types are explicit. |
| `src/back/native/flat.bend:nf_plan` | Build signatures; fully lower ordinary and product candidates; admit dependency closure; retry affected ordinary workers. | Rejected candidates may already contain generated C. Phase78 already avoids rebuilding unaffected workers. |
| `src/back/native/book.bend:nc_compile_def`; observer modules | Scheduler/device fallback and observer routes use shared bodies but distinct ownership/demand rules. | A new representation cannot erase those distinctions or simply omit the fallback work. |

`src/back/native/ir.bend` is an existing output representation: `N_Segment`
contains parameters, frame information, C body text, references, and execution
flags. It is **not** an operation-level analysis IR. Converting already-generated
C into a new instruction graph would arrive too late to remove the expensive
semantic walks.

### Existing sharing that must survive

`nc_definition` returns a cached `NativeErasedBody` or `NativeStaticBody`.
`nc_compact_definition` recognizes the latter and skips repeated compaction.
`nd_arity` consumes retained arity. `nc_source_body` deliberately retrieves
the erased predecessor for observers. These are successful design elements;
the replacement should absorb them, not bypass them and add a second cache.

## Why the preceding experiments did not prove this proposal

- [Phase79](../../../experiments/phase79/P79-001-native-library-workers.md)
  moved annotations/bodies/workers into a library artifact. Additional decoding,
  context, and GC work left only 3.49–5.15% request savings; non-IO held-outs did
  not improve. Its artifact grew by 2.94 MB and preparation by 3.3 seconds.
- [Phase80](../../../experiments/phase80/P80-001-checker-types.md) retained
  checker annotations. Local annotation time fell from about85 to26 ms, but
  whole-request gains were 0.6–1.3%; held-outs regressed. Keeping more types is
  not equivalent to removing the annotation/erasure boundary.
- [Phase82](../../../experiments/phase82/P82-002-owned-layout-erasure.md)
  consumed normalized heads and stored quantities in a private eraser. It kept
  the annotated graph and downstream consumers. Its 1.38% B2 gain is evidence
  against another small consumer specialization, not proof that full replacement
  is either valuable or worthless.

The new discriminator must count representations **not constructed**, traversals
**not performed**, and complete request time. A faster isolated helper is
insufficient.

## Primary-source lessons and their limits

### Zig: a function boundary, not one universal representation

The inspected AIR source describes a Sema-produced, codegen-consumed object per
function. It stores instructions separately from variable payloads, and exposes
structured blocks, loops, branches, calls and returns. The practical transfer
is to make semantic lowering produce what native consumers require, with a
clear per-function lifetime. Compact arrays are not a free benefit in a Bend
compiler running as generated JS; that storage choice needs its own test.
[AIR source](https://github.com/ziglang/zig/blob/master/src/Air.zig).

Zig's liveness source performs a loop analysis followed by a backward main
analysis. It records operand deaths, unused results, and branch-specific deaths
using common-case bits plus exceptional storage. This is a useful counterexample
to indiscriminate fusion: some facts require a different traversal order.
For Bend, produce cheap local facts during lowering, then perform a separate
bounded ownership/use analysis only where its consumers need it. A syntactic
occurrence count is not a general substitute for branch-sensitive ownership.
[Liveness source](https://github.com/ziglang/zig/blob/master/src/Air/Liveness.zig).

These two GitHub `master` pages were inspected on the date above; they are not
claimed to be immutable pins. Attempts to retrieve AIR and Liveness at the
older survey's exact commit failed. The earlier survey retains its own pinned
source account; this refresh does not claim a fresh full audit of that version.

### Cranelift: obtain facts while constructing their actual consumer

Cranelift's SSA builder records variable definitions and uses during CFG
construction. Blocks become complete in two distinct senses: instructions are
filled, then predecessor information is sealed. This permits SSA construction
without a subsequent whole-function conversion pass. Its source explicitly
attributes the algorithm to Braun et al. The transferable idea is an explicit
completion boundary: expose a native function product only when its runtime
operands and required facts are complete. Do not reconstruct facts from emitted
strings afterward.
[SSA builder source](https://docs.rs/cranelift-frontend/latest/src/cranelift_frontend/ssa.rs.html).

`FunctionBuilder` uses an allocated function and a reusable temporary context;
finalization resets that context for the next function. Its API recommends
sealing blocks promptly rather than postponing all work. For Bend, a scoped
builder should carry only the current function's unresolved obligations, while
the request retains exact declaration and constructor identities. Reusing Rust
allocation capacity is not directly equivalent to a pure persistent Bend map.
[Builder documentation](https://docs.rs/cranelift-frontend/latest/cranelift_frontend/struct.FunctionBuilder.html).

The original SSA-construction paper gives an especially useful warning. Avoiding
temporary non-SSA instructions reduced constructed instruction volume in its
LLVM comparison, but reported total compiler time remained close. Representation
counts demonstrate work removed; they do not establish a proportional latency
gain. Our whole-request gate must remain decisive.
[Braun et al., CC2013](https://compilers.cs.uni-saarland.de/papers/bbhlmz13cc.pdf).

Cranelift's e-graph RFC separately explains why independent optimization passes
can repeatedly expose work for each other. Our analog is repeated native
interpretation and candidate planning, not a demonstrated need for equality
saturation. Importing an e-graph optimizer would add an unrelated problem before
the current representation cost is measured.
[Cranelift RFC](https://github.com/bytecodealliance/rfcs/blob/main/accepted/cranelift-egraph.md).

## A replacement worth prototyping

Start with a **type-directed native producer**, not a global SSA conversion.
Its initial output can keep the existing erased `KTerm` shape so current
lowerers and exact-C comparison remain available. This is a deforestation
experiment: avoid materializing the intermediate annotated tree, while still
doing the semantic interpretation it represented.

For each selected definition, the producer would return:

1. The runtime body in existing erased syntax, with exact constructor identity,
   match count/mask, and quantities already resolved.
2. Its runtime references, collected as the runtime body is constructed.
3. Layout obligations/refusals and scalar-array permission facts that previously
   depended on `Ann` nodes; typed variable array-freedom information where needed.
4. Function-level live arity, ordinary parameter kinds and optional product
   signature, obtained from a shared traversal of the original telescope.

Only after that replacement proves worthwhile should the body become a new
structured operation datatype. A good next representation would distinguish
runtime values, calls, constructors, matches and structured lets directly. It
should preserve source evaluation/demand order. Binder IDs already identify
binders; adding expression IDs alone does not eliminate a traversal.

The ownership arrangement should be explicit:

- Immutable checked source remains available for diagnostics and type context.
- The native request owns fresh products; no public caller-supplied fact grants
  checked permissions.
- Annotation trees are absent from the successful owned native path.
- Static/literal lowering either consumes the runtime body once or produces a
  bounded alternate view. Observer analysis must run before losing the original
  shape, or receive exactly the sufficient facts it needs; do not silently drop
  its predecessor and hope compact terms suffice.
- Shared JS annotation and raw native entry points retain their existing
  behavior. Their source modules cannot initially be deleted just because the
  owned native path no longer calls them.

### What must disappear to call this a replacement

The owned native path should no longer construct `Ann` wrappers, merge an
annotated duplicate definition book, run `nc_erase` over those wrappers, or
revisit them through `jl_term`, `ns_terms`, and `ns_unshared_terms`. Runtime
reference collection should not immediately rescan the newly built body.
Function kinds and product signatures should not separately reconstruct the
same original telescope. Passing a narrow certificate to each existing consumer
is acceptable; retaining the complete old graph as fallback for every successful
definition defeats this experiment.

This does not imply zero type normalization or substitution. Dependent telescope
tails still require original source arguments even when those arguments erase.
The fused producer must preserve equality-proof handling, lambda quantity
adjustments, match-rest goals, native literal expansion, and specialized source
semantics. Unsupported cases may initially use the old path, but coverage and
fallback costs must be reported rather than averaged away.

## A second, distinct opportunity: generate less discarded candidate code

`nf_candidate` and `nq_candidate_mode` both call `nc_lower_to` and retain full
`NC_Code` before `nf_admit` determines whether their dependencies are admissible.
The ordinary retry then regenerates some workers after product signatures are
withdrawn. This ordering can spend real lowering/text effort on discarded code.
The initial Phase82 evidence did not measure its magnitude separately; the new
Phase83 diagnostic below establishes a substantial case-specific cost.

A useful diagnostic records per candidate: role, body-node count, local refusal,
generated C bytes, segments, dependencies, admitted status, and retry cause.
First partition `nf_plan` into signature extraction, ordinary lowering, product
lowering, admission and retry. Compare the cost of rejected versus retained
workers. Merely counting rejected workers is inadequate: an early refusal may
be almost free.

If rejected generation is substantial, test a shared lowering builder that
emits a compact decision product with explicit refusal/dependency information
before rendering text. Admitted products alone render. This must reuse the
actual lowering rules; a separate approximate eligibility traversal can add work
or duplicate correctness logic. An incremental dependency worklist can replace
repeated `nf_admit_pass` scans if measurements show those scans matter. Preserve
the present cycle exclusion and tail-self-call rules; changing SCC semantics is
a separate runtime optimization.

## Bounds, estimates and next experiment

### Fresh Phase83 worker-fate evidence

The lead agent ran one observation-only B2 derivative on Numeric, Map, small and
functions65. All four retain exact C. Reports are
`selfhost/build/phase83/regions01/runs/clean-region-{case}/report.json`.
Their `diagnostic.workers` records time individual candidate construction;
`diagnostic.plans[0]` records final native-plan readiness. These are instrumented
diagnostics, not clean performance improvements or repeated timing estimates.

| Case | Final workers / ready | Candidate constructions, including retries | Construction time for finally ready names | Construction time for finally unready names | Final body units in unready workers |
|---|---:|---:|---:|---:|---:|
| Numeric |41 /16|44|56.28ms|36.05ms|47,873|
| Map |104 /36|121|38.03ms|379.40ms|717,818|
| Small |2 /2|2|8.62ms|0|0|
| Functions65 |66 /66|66|32.61ms|0|0|

Body units mean JavaScript UTF-16 string length, not allocated bytes. Repeated
construction can produce more text than the final retained candidate array.
Map constructs1,133,898 body units across all121 attempts;1,075,038 belong to
finally unready names. Its final array holds776,678 units, of which717,818 are
unready. Do not confuse these two counts.

Map's unready construction separates into:

- **181.40ms in18 locally failing constructions**, including179.88ms in13
  non-tail-self-call failures. Those13 construct594,758 body units.
- **198.00ms in67 locally successful but ultimately dependency-blocked
  constructions**. Every recorded candidate has zero continuation segments,
  so error-free unready cases fail the dependency admission rather than the
  segment restriction.
- **84.06ms in17 ordinary retries**, included in the figures above. Admission
  itself is only1.97ms; replacing its list fixed point with a worklist is not
  the significant opportunity on this input.

Four definitions dominate: `Map.pop.go`, `Map.seek.go`, `Map.ins.go`, and
`Map.put.go`. Their initial ordinary, product and retried ordinary constructions
total304.11ms across12 attempts. The pinned Base source at
`bend2/base.bend:2614,2656,2701,2854` contains recursion under constructors or as
an argument to rebuilding helpers. Ordinary initial attempts can initially
depend on speculative product signatures; product failures then expose the
ordinary non-tail refusal during retry. Their emitted text is not selected.

The fate claim also requires source inspection. `no_route_pair` admits only its
new observer pair against the old ready set; it does not reconsider the existing
worker list. `no_private_free` forbids collisions with existing worker names.
Scalar redirection is allowed only for an owner already ready. Thus observer
routing cannot re-admit the existing unready workers on this path.
`nf_prototypes`, `nf_bodies`, and `nf_adapter_defs` each filter by ready names.
The unready **C bodies** are discarded; their names/dependency/refusal metadata
can still influence planning and collision checks. This does not authorize
dropping entire candidate records without replacement facts.

This changes the next-step priority: a conservative **definite-refusal
preflight** is now preferable to starting the broad annotation IR rewrite.
First recognize non-tail self calls in the compact runtime form where current
lowering must refuse, preserve ordinary/product route distinctions, and propagate
proven failures before expensive text construction. Reuse actual lowering rules
or a deliberately narrow sound fragment; never blacklist these four names.
An unknown case keeps ordinary lowering. Exact C must demonstrate unchanged
worker selection and fallback behavior, including scalar observers and devices.

379.40ms is about19.3% of Map's1,962.30ms diagnostic request. That is a generous
opportunity ceiling for avoiding **all** unready candidate construction, not an
achievable gain forecast: proving refusal and retaining dependencies still cost
time. Numeric's corresponding ceiling is only3.7%, and the two simpler cases
have no such opportunity. The new evidence therefore supports a promising
general mechanism, but **not general parity from that mechanism alone**.

Report identities: Map`eff3c93e7c210ceb8d2c0c6a32194932f3ff2b757fbb918810c656f0fec7cfcf`;
Numeric`b0ba5047b17a81d91089f4cae0f63c2f22a2a5a95d0cf04d5c66205a2e3a2bea`;
small`1c36978cc27d07d52f47030336439671219f7125d83c904d0a5e1c0a954c148c`;
functions65`e592f1fcf1a2233ebfa438f59ec13254175e6eaac11d184f0d956afd3ed295a2`.

### Remaining representation bounds

[Phase82 profiles](../../../implementation/phase82/profiles.json) are diagnostic,
not clean speed comparisons. Numeric annotation/preparation/final-native stages
are75.2/104.2/386.5ms; functions65 is6.4/43.3/183.8ms. Annotation plus preparation
is therefore179.4ms or49.7ms of the respective instrumented intervals, and
**not all of either region is removable**. The clean functions65 gap is179.5ms
on a different run. These clocks cannot be subtracted to estimate a speedup,
but they plainly contradict annotation fusion as the only general explanation.

Phase81 final-native versus upstream-emission times were already close on the
three IO sources. They are not identical pipeline boundaries: some selfhost
preparation happens earlier. Treat that as a reason to compare the complete
semantic-to-output region, not a reason to assume all native planning is excess.

Conditional whole-request estimates below are engineering hypotheses, not
measurements or additive percentages. They include new construction overhead.

| Experiment | Plausible benefit if the attribution holds | Focused prototype / complete integration | Main risk |
|---|---|---|---|
| Shared telescope extraction feeding kinds and product signatures |2–5% B2, highly workload dependent|1–2h /4–8h|Different normalization/fallback rules are accidentally merged.|
| Owned annotation/layout/erasure producer replacement |4–12% B2; less on low-annotation held-outs|2–4h narrow pilot /12–24h broad integration|Permission and demand facts still force retaining old trees; complexity rises.|
| Producer replacement plus consumer-oriented function body/analysis |8–20% B2 is a target to falsify; regression is possible|4–8h credible pilot /24–40h broad migration|Construction or duplicate fallback dominates; larger semantic surface.|
| Definite-refusal preflight and avoiding unready worker rendering |Fresh evidence supports an8–15% Map target,1–3% Numeric target; no expected gain on the two fully admitted cases|1–3h narrow pilot /4–8h integration; larger shared decision IR8–16h|A preflight duplicates lowering or conservatively rejects a worker that the old path admitted.|

These estimates are deliberately narrower than promising parity from one
unmeasured rewrite. The current1.328× B2 ratio requires24.7% less request time;
0.5× requires62.4%. None of the existing measurements establishes that budget
in removable native representation work alone. B1 has a separate generated-code
allocation problem, so its benefit must be measured independently.

The cheapest decisive sequence is:

1. Extend the new **candidate-fate** diagnostic to one array program and one
   higher-order/bang case, and retain construction/visit counts. Numeric, Map,
   small and functions65 are already measured. Keep correctness checks; do not
   use instrumented elapsed times as gains. Start the narrow definite-refusal
   pilot before a full representation migration.
2. Attribute inclusive regions without adding nested totals. Require evidence
   for at least15% whole-request removable work before a broad rewrite.
3. Pilot a fused native producer on a narrow semantic subset, comparing its
   erased body, references and permissions against the original pipeline before
   comparing C. Include erased dependent arguments, typed array variables,
   constructor quantities, match alternatives and proof rewrites as controls.
4. Time the complete request in fresh B1 and B2, including every new product
   construction and cleanup. Stop if a local win disappears or held-outs regress.
5. Only then extend the representation and run the shared broad/bootstrap gate.

If step2 cannot find that budget, prioritize frontend/world/report work or the
B1 execution representation. A universal native IR is useful only if its
construction replaces substantial current work and simplifies its consumers.
