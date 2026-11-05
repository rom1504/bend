# Phase164: larger headroom, and the limit of direct-first

Bounded read-only audit for the Phase164 work starting at `d708eef`. No target,
compiler, build or production edit. Source/evidence inspected: Phase159–163,
maintained Phase152 backend, and authenticated bendc
`56edcc65b3527a75838011682c231072d5b46097` under `selfhost/build/phase158/current`.

**Hybrid direct-first is worth its current experiment, but there is no evidence
that it alone approaches either a five-second request or a fivefold full-build
gain. My strongest separate structural lead is the repeated construction and
querying of generic, String-keyed backend analysis environments. Start with the
scalar optimizer's complete per-function fact state, not another compact App.**
This is a concrete candidate for removing bookkeeping while retaining the same
optimization and final verifier. Its profitable extent is unmeasured; do not
assign the whole backend to it.

## The timing constraint comes first

The disjoint full-source rows in
[`implementation/phase161/profile-metrics.json`](../../implementation/phase161/profile-metrics.json)
are diagnostic CPU intervals, not clean timings to subtract from Phase152's
249.222-second cold build:

| Region | Diagnostic CPU seconds |
|---|---:|
| Parse/load + checking/publication + proof report |66.520|
| Generic segment body production |11.588|
| Private/direct candidate production |26.782|
| Initial optimizer, including its verifier boundaries |23.673|
| First independent final verifier |7.857|
| Observer composition and selected final admission |19.625|
| Registry preparation |16.190|
| Rendering/output and teardown |40.208|

The 44-second raw-lowering envelope is **not** 44 seconds of redundant generic
bodies. Direct-first still needs prepared source, direct candidate production,
use/layout/ownership facts, admission, useful optimization and output. Its
largest secondary opportunities are fewer generic verifier/registry/emission
products; those intervals also perform required work for retained programs.
Do not count their entire duration as removable or add overlapping sample views.

For a route-only change executed by the existing generation, even making every
post-frontend operation free leaves the observed 66.52-second frontend envelope.
A new compiler generation could execute that frontend faster, but Phase163's two
runtime transfers (0.993× and 1.070× reference) do not establish that multiplier.
The 2/8 closed-library admissions likewise cannot predict a full-source fraction.
This is a conditional Amdahl constraint, not a claim that diagnostic clocks are
an absolute hardware lower bound.

## One larger work category: analysis records and symbolic identities

The actual representation is much more expensive than its logical information:

* [`p111v_get`](../../selfhost/src/back/qbe/verify-segments.bend#L3) hashes the
  whole name for every tree lookup. `p111v_put` builds a nine-field KDef merely
  to store name/kind/width/capacity. `p111v_assign` performs a schema lookup and
  another insertion; branch intersection visits bindings, looks them up in the
  other state and reconstructs the result map. Name validation also walks each
  spelling (`p111v_name_chars`, line17).
* [`p113k_put`](../../selfhost/src/back/qbe/scalar-facts.bend#L284) stores a scalar
  fact as a KDef containing an `Epoch` KTerm and a `P113KValue` KTerm. It first
  calls `p113l_version`, which hashes/looks up the name, then hashes the same name
  again for insertion. The logical payload is version, bit bound, exact flag,
  low word and high word. [`p113l_relation`](../../selfhost/src/back/qbe/scalar-facts.bend#L796)
  additionally constructs `@condition:` names and looks up two versions to
  authenticate a conditional relation.
* This is visible in the retained real generated C, not just source syntax:
  [`request-c02/program.c:133710`](../../selfhost/build/phase160/request-c02/program.c#L133710)
  constructs `CN(0,9,...)` plus two `CN(0,8,...)` for each `F_p113k__put`, and
  contains both hash calls. Under that C runtime these are three logical
  allocations/28 requested words, before index path reconstruction. Cached tag
  Strings are not fresh allocations. This does **not** establish identical QBE
  allocations; the C02 route disables unboxing for its documented compatibility
  reason. In contrast `F_p111v__put` uses cached Absent constants: do not charge
  those as two additional fresh terms.

The active profile supports investigating this category. In the admitted
738-sample initial-optimizer interval, `p111v_name_chars`, `p111v_get`,
`p113k_get`, `p113k_put` and `p113l_version` account for 64+55+58+17+21 = 215
active-owner samples. The physical view separately sees 66 `index_hash` and 35
`String.cmp` samples. Those views overlap and cannot be added. The admitted
611-sample composition interval again lists 69 `p111v_get`, 34 name-character,
19 intersection-bucket and 14 put samples. These are observed ownership labels,
not inclusive function cost or a proven removable fraction. The separate
244-sample verifier interval fails the 500-sample quantitative gate.

The remaining allocation scale justifies seeking whole-category savings:
Phase162 counts 2.950 billion C02 logical requests for the full compiler request,
with 2.132 billion outside its measured parse/check/report intervals. It does not
locate those requests in these maps; a new count is needed before attributing a
large fraction to analysis state.

## What bendc does and does not demonstrate

bendc's [`Lo.program`](../../selfhost/build/phase158/current/bendc.bend#L25746)
lowers all declarations, performs a sequence of transforms, then raises them;
[`Gen.program`](../../selfhost/build/phase158/current/bendc.bend#L26462) performs
further representation/DPS passes before reachable C emission. It rebuilds maps
and is not a lazy or one-pass compiler. Its `Core.CVar` still stores a String
([core.bend:35](../../selfhost/build/phase158/current/core.bend#L35)); claiming that
bendc already solves all name work with dense IDs would be false.

The relevant responsibility difference is that its ordinary C route does not
construct and independently flow-verify our scheduled N111 program plus several
P113/P118 worker forms. Clang handles subsequent low-level optimization and
machine checking. Under the reproduced tracing-only policy,
[`Gen.shares.if`](../../selfhost/build/phase158/current/bendc.bend#L5299) also
bypasses per-binding sharing analysis. Our RC/ownership contract cannot adopt
that omission for free. Preserve our independent verifier and useful scalar
optimizations; change their substrate rather than deleting their obligations.

Several apparent shortcuts are already implemented or falsified:

* NativeStaticBody preparation/compaction is shared before both lowerers.
* Phase146 retains authenticated original verifier context and IDs.
* Phase147's [`verify-compact.bend`](../../selfhost/src/back/qbe/verify-compact.bend)
  already has typed schema facts and numeric assigned-flow IDs for initial direct
  admission. A proposal to invent that same verifier cache again is not new.
  Its boundary still maps symbolic operand names through `p147v_get`; it does not
  convert the scalar optimizer's generic fact map or all IR consumers to IDs.
* `p114s_ranges` is identity; there is no range pass to delete there.
* Phase163 restores inlining/scalar/cold facts because removing them regressed
  runtime. No evidence here shows the whole direct optimizer is run twice:
  active `p128raw_close` retries retained raw candidates, and `p126bp_complete`
  verifies the resulting closure; it does not call the inliner again.
* QBE emission already streams. A new generic “stream output” proposal misses
  the remaining per-character String construction/reclamation cost.

## Ranked decisive experiment

**First additional experiment after the hybrid gate: replace the private scalar
analysis store for one complete `p113k_function` invocation, then its actual
whole-request caller if it wins.** Use one retained, real branch-heavy compiler
worker plus an unrelated branch/alias control. Compare every returned
P113DFunction field and emitted QBE, not a fact-put loop or only the final value.

The initial candidate should use a dedicated persistent record/table for scalar
facts and conditional relations. Carry epoch and relation fields directly; keep
exact name matching/collision handling. This removes the three generic marker
objects without changing IR or trusting producer annotations. Preserve the
current branch join, terminal-arm treatment, call kills, reassignment epochs,
unknown/64-bit values and stale-relation refusal. A persistent structure keeps
branch snapshots ownership-safe; a shared mutable Array silently aliasing both
branches is not an acceptable shortcut.

If that complete pass wins, the larger version interns each function's local
spellings once into dense IDs and runs its analysis on numeric IDs, retaining a
reverse spelling table for exact output/diagnostics. P147's typed table/numeric
flow is a source precedent, not a certificate for this new pass. Account for the
initial indexing and any conversion back; do not time only the inner numeric
loop. Keep the old independent final verifier unchanged and require exact QBE
for ordinary complete requests. Stop if the conversion cost consumes the saving.

This is a better first test than replacing all KTerm variants or globally
interning every compiler name. The fact state is private, its lifetime is one
function, its payload and invalidation rules are explicit, and its complete
output can remain exact. It is nevertheless new implementation work, not a
free replacement of one type alias.

**Realistic bound:** a scalar-only candidate lies inside the 23.673-second
initial-optimizer envelope; even deleting that whole interval would save only
about 9.9% of the 239.98-second diagnostic process. The honest initial expectation
is a smaller single-digit percentage, not a fivefold gain. Extending the same
substrate across optimizer and independent checking has a deliberately loose
51.155-second envelope (23.673+7.857+19.625), about21.3%; much of it must remain,
and this overlaps hybrid's savings. No result permits adding the two forecasts.

The existing publication policy is the strongest **already measured** separate
algorithmic elimination: 358.9 million fewer checking allocations and 19.2s
less diagnostic C check time in Phase162, but only4.62% clean native whole-request
improvement in Phase156. It should be judged on those real limits, not recast as
an undiscovered five-second solution. If hybrid economics are capped, the typed
analysis-state experiment above is my next source-grounded candidate; there is
currently no single evidenced removable category that supports the desired
orders-of-magnitude claim.
