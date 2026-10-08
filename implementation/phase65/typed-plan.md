# Phase65 typed backend products

Status: H1 rejected for advancement after exact controls and an inconclusive speed screen.
The installed Phase64 compiler is unchanged. Root alone runs compiler targets and
may freeze an isolated candidate snapshot. No global annotation API change is
approved for release by this document.

## First discriminator: retain an already computed type head

`selfhost/src/check/annotate.bend:annotate` currently computes
`wnf(cb(e), ty)` to read back a checked expression, then stores the original `ty`
in its `Ann` node. Layout, call analysis and direct lowering subsequently inspect
that node and normalize the original type again. The experiment stores that
already computed head instead. It adds one helper and five physical Bend lines;
there is no new cache, table, prepass, per-consumer guard or extra normalization.

The isolated [patch](../../selfhost/tools/performance/phase65/typed-plan/normalized-head/candidate.patch)
has SHA256 `be6af4e32eb7c0514ba8d880761bf41e496781b6661f74ea3ad7d3713e764c51`.
[Metadata and exact before/after identities](../../selfhost/tools/performance/phase65/typed-plan/normalized-head/candidate.json)
bind the producer. It is a diagnostic hypothesis, not an established equivalence.

This differs from the rejected Phase64 child-type optimization. That candidate
added guards and helpers to nine consumers; the new candidate changes the
producer and retains work it already performs. It also differs from Phase63
lower-once emission and retained arity, both of which remain in the baseline.

## Contract and unresolved boundary

The producer preserves the order of beta reduction, WNF, recursive annotation
and wrapping. Definition types, constructor declarations, source bodies supplied
to checking, quantities and binder identities remain unchanged. Only annotation
nodes introduced during readback store a different second child. Existing
application-spine annotations already store normalized callee heads.

That is not enough to prove the optimization safe. Public `annotate`,
`annotate_book` and `annotate_selected` products have observable syntax. WNF may
remove an alias that a later syntax-sensitive or bounded consumer treats
specially. Annotation uses the checked book; direct lowering uses the canonical
annotated overlay. Equivalent heads must remain valid across that exact context
transition, including recursive aliases, native host layouts, specialization,
SCC order, reachability and analysis refusal budgets.

The diagnostic patch deliberately changes the shared producer so value can be
measured cheaply before introducing a production interface. Promotion requires
either a private selected-direct annotation producer preserving public APIs, or
an explicit stronger compatibility result. Threading policy through 32 helpers
or cloning their recursive component before a positive result would add
complexity without evidence. No claim is made for arbitrary forged raw terms,
other backends or externally visible annotation byte equality.

## Exact controls and fast loop

The [diagnostic controller](../../selfhost/tools/performance/phase65/typed-plan/normalized-head/compare.mjs)
creates an append-only derivative of a verified checked B1. It switches the
entire recursive producer between the candidate and the exact original formula
inside that same image. Explicit JavaScript compositions force every Bend
trampoline result. The ordinary driver and an explicit supplied API are used in
both roles; these runs provide correctness/work counts, never performance data.

For each role it compares:

- Complete request status, phase, checked flag and diagnostic, including refusals.
- Selected definition order/kinds and the entire retained definition text index.
- Every retained definition's complete call fact, SCC member order and bounce flag.
- Layout results, full module bytes and supplied independent runtime values.

The initial 16 cases include six maintained context fixtures (the corrected
mutual-recursion fixture is explicitly version 2), Numeric/Map workloads,
dependent family/type aliases, overapplication, erased partial closure,
rewrites, open-Array refusal and definition budgets zero and one. A catalog
argument supports the maintained broader source set. The controller also counts
lexical `wnf`, `subst` and `j_type` calls by public stage. Counts do not equal time:
even a useful stored head may leave cheap WNF calls in place while eliminating
expensive unfolding inside those calls.

Run the small exact subset first, then the full controls. If outputs/refusals
agree, use an uninstrumented candidate for a balanced fresh-process B1 screen.
A positive screen merits genuine-B2 comparison and broader qualification;
negative work-count/time evidence should stop this prototype before interface
expansion. Root owns target scheduling and memory limits.

## Current attribution and broader opportunity

Fresh Phase65 genuine-B2 profiles keep plan selection as the largest backend
boundary. Diagnostic sampled plan time is about 37/130/339/157 ms for
Numeric/Lexer/Map/activeRay; annotation 3.4/12.4/87.8/33.8 ms and layout
3.3/25.3/37.8/13.8 ms. These profiles include import and instrumentation and must
not be substituted for clean clocks or added across overlapping ancestry.
Map raw-arity ancestry is about 41 ms, substantially less than its complete
339 ms plan boundary. A broader signature cache alone cannot explain the whole
gap. Exact caller evidence also finds substantial substitution allocation under
`j_app_type` and constructor specialization, but allocation bytes are not CPU
savings.

If the normalized-head discriminator works, the next useful extension is to
feed retained heads directly into their owned layout/lowering consumers, rather
than adding arbitrary memoization. If it fails, preserve the counterexample or
negative receipt and investigate a distinct typed product with original syntax
retained separately. Existing SCC and annotation traversals impose a real
ordering dependency; deriving call edges from emitted text after SCC-dependent
lowering is not a sound shortcut.

## Results

State02 passes the focused same-image producer comparison: 16/16 cases,
13 exact complete modules, 38 independent runtime value observations and three
exact refusals. The open-Array diagnostic and definition-budget zero/one
rejections are unchanged. All plan text/call/SCC/layout comparisons pass.
[Compact receipt](evidence/normalized-head-controls01.json) binds the full raw
report and controller. State01 was an invalid discriminator because the workflow
captured restored baseline source; it is preserved, and the controller now binds
the actual snapshot annotation source to the candidate's exact SHA.

Numeric annotates 48 expressions and shows identical query counts in both roles.
Map annotates 3,686 expressions. Its plan-stage recursive substitution entries
fall 102,461 → 100,208 (2,253 fewer, 2.20%), and layout entries fall
47,096 → 42,164 (4,932 fewer, 10.47%). Annotation, checking and final host emission
are unchanged. All lexical WNF and j_type entry counts are identical: retaining
the head avoids internal substitution, not complete normalization calls. These
7,185 avoided substitution entries are a limited result, not evidence for the
larger typed-pipeline speed estimate.

The [balanced checked-B1 screen](evidence/state02-b1-screen.json) closes with
8/8 exact-output workers over two sources and two rounds. Numeric median
299.854 → 300.549 ms (+0.23%); Map 1,312.134 → 1,303.009 ms (−0.70%). The
equal-source geometric mean is 0.997670× baseline (−0.23%), below the earlier
identical-image A/A noise floor. These data do not establish a useful speed win.

**Decision: reject H1 advancement.** Keep the isolated candidate, semantic
receipts and negative measurement. Do not spend effort isolating a new public/
private annotation entry, and do not run B2 qualification for this candidate.
The installed producer remains unchanged. This rejects this particular retained
head design, not all producer-owned backend facts.

## Bounded follow-up source review

The strongest straightforward whole-traversal extension is **retaining closed
Base call-row products**, after the separately owned Base annotation experiment.
`jd_calls_rows` already computes each ordinary definition's raw arity and full
`JDCallScan` before building global graph tables. Keep those exact row products
at the immutable Base producer; selected requests can reuse admitted rows and
still run indexing, reverse edges, SCC partition, source-order grouping and
bounce propagation. This is not another cache around `jd_emitted_arity`.

The actual Base-products census attributes 35.0 instrumented ms to 65 Map Base
call-body roots, versus 1.04 ms for 28 source roots. Numeric and Lexer Base shares
are only 0.032 and 0.115 ms. Sixteen repeated Base products across three requests
match, but most large Map products were observed once; this is not yet a complete
context proof. The opportunity is about a few percent of Map compilation, not
the whole approximately 100 ms inclusive call-analysis ancestry. The decisive
next test is exact Base-only/current-context row equality and marginal artifact
size/decode cost; implement only after annotation retention earns its costs.

Admission must bind actual Base definitions and callee/native dependencies,
original arity/unknown/edge results, successful scan status and producer/API
identity. Preserve selected row order, definition and duplicate-edge budgets,
per-row refusal and global SCC work. Missing, altered or unproved rows use the
existing analysis. Caching only successful rows must never turn an old failed
scan into success. No patch was prepared in this bounded follow-up.

A second, broader direction is **eliminating generic match/reconstruction
allocation** in generated code. `jd_doc_match_emit_at` owns the scrutinee and
constructor telescope, but generic `jd_match_fields` currently returns strings;
ordinary environment entries lose the link between field binders and their
original object. Existing `$JD.View`/`$JD.U32Fragment` inverse proofs cover native
scalars, not generic Data objects. A scoped origin fact could make exact
constructor/field reconstruction recognizable without runtime identity guards.

That recognition alone does not permit reuse. Returning the original object can
change host/FFI identity and aliasing; property getters, proxies or intervening
mutation can change field-read observations. Native Array views also allocate
slices and must be excluded. The pinned TypeScript `js_expr(Ctr)` creates a fresh
object literal and `js_match` opens fields; it provides no generic reconstruction
reuse precedent. The existing Lean research explicitly distinguishes pure CSE
from ownership/escape proofs and warns that JS lacks a complete alias count.

The simplest proven general scope is a **fresh, private, nonescaping ordinary
Data allocation** whose fields are reconstructed unchanged before any effect or
escape. Current lexical backend facts do not establish that scope across calls.
A source-only census or isolated compiler-image counterfactual could estimate
headroom, but unconditional generic reuse is not a production-safe shortcut.
A broader implementation needs origin plus escape/effect summaries, or a narrower
validated immutable compiler-product boundary; no generic framework or patch is
justified by this 15-minute review alone.
