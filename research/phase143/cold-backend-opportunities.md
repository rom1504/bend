# Phase143: cold backend work that can actually disappear

Source-only audit, 2026-10-26, repository HEAD `4fd100d`. No compiler executions,
new performance measurements, production changes or qualification were performed.

**Start with the repeated occurrence checks in `nd_comb_fresh`, then investigate
fragment-preserving emission.** The first has a small exact semantic boundary
and can replace up to128 repeated syntax traversals with one. The second has
a larger measured stage envelope but needs a native discriminator: streaming
the complete module was already implemented, and naive fragment batching was
previously slower. Neither is evidence for a10× cold-build speedup.

## Identities and the important path distinction

Inspected source is the Phase142 experimental candidate,
[`indexed-source02/compiler.bend`](../../selfhost/build/phase142/indexed-source02/compiler.bend),
SHA256 `15f5cada2710119cce19a0cfe961c21f61edc5f0b048f90359090a0c1817dac1`.
It is source-checked and native-acquired, **not selected or fully native-qualified**;
the installed/qualified Phase137 compiler remains separate. See
[candidate identity](../../implementation/phase142/candidate.json).

The ordinary native request follows:

```text
p111_native_request
  p134e_compile_source -> p86_plan
    parse/import -> checking -> report/ownership/entry gates
    book_context_world -> reach_book/annotate_selected -> jl_checked_error
    nr_prepare_annotated
  p134e_plan -> runtime admission -> p128raw_lower_request
    constructor catalogue -> p112s_prepare
    p111_compile_defs + p113pl_candidates
    p113d_passes
  p114s_open -> p114s_inline -> p114s_ranges -> p114s_close
  p113a_finish -> p113a_verify -> borrowed/helper closure -> p126bp_complete
  P134Planned -> p134e_begin/next -> File.write
```

The `p140s` cold session is a **different algorithm**: it builds parser/checker
checkpoints, dependency graphs, raw/private products, optimizer/verifier caches,
late-plan caches, registry keys and retained rendered pieces even when none can
hit. Its raw path also shares a constructor catalogue that the ordinary path
still rebuilds. Therefore cold-session timings are not ordinary timings with
a zero hit rate, and ordinary requests do not pay all Phase140 cache machinery.
The ongoing ordinary baseline must remain the primary cold denominator.

Ordinary source anchors: frontend37846–37953, raw55910–56030,
borrowed closure56103–56142, emission57361–57585. Incremental anchors:
raw60190–60270, backend62145–62204, session62214–62260. These line numbers
refer to the pinned source above.

## What the profiles bound—and what they do not

The last fine-grained **ordinary** stage measurement remains Phase136, using
qualified Phase134 N2. Its separate diagnostic executable writes exact QBE to
a file; the354.248s stage sum is not the375.923s overlapped source-to-executable
baseline. [Original metrics](../../implementation/phase136/metrics.json):

| Ordinary diagnostic work | Seconds | Share |
|---|---:|---:|
| Frontend, excluding Base acquisition |152.111|42.94%|
| Raw preparation/lowering |59.411|16.77%|
| Opening verification |10.983|3.10%|
| Inlining plus commit |17.073|4.82%|
| Ranges plus commit |9.013|2.54%|
| Closing verification/borrowed-helper work |40.665|11.48%|
| Rendering/writing/associated reclamation |64.760|18.28%|

Eliminating the entire historical rendering interval would give only1.224×
overall acceleration; halving it gives1.101×. Raw lowering has an optimistic
1.202× elimination bound. These are Amdahl calculations on old stage clocks,
not current gain forecasts. Verification and helper closure are not one
removable77.7s verifier. Parsing/checking are outside this audit's implementation
scope and alone defeat an extremely small cold-build target.

The newer [Phase138 ordinary profile](../../implementation/phase138/profile.json)
has10,785 samples, near-complete main-thread CPU coverage and exact output.
Active owners include `nc_occurs`2.46%, `nc_occurs_list`1.48%,
`nc_uses_term`1.02%, `p111v_get`3.89%, `nol_scalar_specs`0.68%, and
`String.append`4.22%. `term_drop`+`span_fade` are25.67% of physical leaves.
Active contexts are not inclusive caller stacks, and ownership intersects
these costs. Do not add them or treat required ownership work as pure waste.

The Phase142 profile also preserves **cold-session** interiors, useful for
locating work but not substituting for the ordinary denominator. Derived by
reading the existing [summary](../../selfhost/build/phase142/native-context-plan01/analysis/summary.json),
without running a target:

| Cold session interval | Timer | Interior samples | Source-connected observations |
|---|---:|---:|---|
| Raw preparation |74.643s|3,259|`nc_occurs`398 + `nc_occurs_list`274 =20.62%; `nc_uses_term`132; `p131i_insert`330|
| Backend |98.020s|4,428|`p131i_insert`14.77%, `p111v_get`10.89%, name validation4.20%, `p113k_get`4.11%, scalar catalogue2.35%|
| Registry |16.308s|343|String equality20.41%; only a partial conservative interior|
| Render/close |53.362s|2,195|String append20.50%, body flattening5.38%, retained-byte accounting4.56%|

These are conservative CPU-ordinal interiors, not exact timestamps or complete
interval distributions. In particular, retained-byte accounting belongs to the
incremental path and cannot be charged to ordinary rendering. Parent Phase141
produced this capture, before Phase142's indexed graph walks.

## Ranked experiments

The time estimates below are implementation/information budgets, not promises.
All candidates must keep the same checking, admitted optimization policy and
independent final verifier. First compare complete QBE, not just successful exit.

### 1. Replace repeated freshness scans with one exact occurrence query

`nd_comb_fresh` at32513 scans the **same** body and arguments for every proposed
fresh ID, then checks the same binding environment. Three important callers are
`nd_comb_try`, `no_adapter` at36048, and the native combinator path at38414.
The latter two request64 IDs. An all-clear result can therefore walk the body64
times and the argument trees64 times. The syntax is unchanged throughout.
`nbc_select` already bounds its selected body to at most32 syntax nodes;
its argument trees are not bounded by that check. `no_adapter` is the C-style
observer adapter, not evidence of an active ordinary-QBE hot caller. Dynamic
caller attribution remains necessary before assigning the context exposure.

`nc_uses`/`nc_uses_list` and `NU_Set` already implement the exact membership rule
of `nc_occurs`: a `Var` is a leaf, even if a malformed raw Var has children;
other nodes visit `ks`. Build one set from body plus arguments and query the
same `nc_id(n)` sequence, retaining the original `nc_word` collision checks.
An alternative is one syntax traversal testing the forbidden fresh-ID set,
which may avoid inserting every unrelated variable. Choose by measured cost.

This is local analysis reuse on immutable input, not a cache across revisions.
Keep `left=0` as an immediate success; consider retaining the original scan for
one ID or early failures. Preserve U32 arithmetic and `nc_id` exactly rather
than assuming mathematical nonwrapping intervals. Do not silently generalize
from syntax variables to binder-aware free-variable analysis.

**Cheapest falsifier:** extract actual call inputs from a frozen compiler-derived
lowering request; compare every Bool with the original, then time the complete
consumer including summary construction. Include64 clear IDs, collision at
first/last ID, argument-only collision, environment-only collision, zero count,
U32 boundaries and Var-with-children. A native kernel can establish transfer
before another full compiler build. Add an unrelated closure/record wrapper.

**Expected scope:** the historical ordinary occurrence contexts total3.94%;
the recent cold raw interior has20.62%, but neither establishes the share of
these particular callers. A few percent whole-request improvement is credible
only if attribution confirms them. This is the highest information-per-cost
experiment: roughly20–45min to a bounded source/semantic discriminator, then
one small native measurement. No whole-request percentage is demonstrated yet.

The related `nq_layout_dep` at33202 walks one type once per seen ID. It can use
the same exact membership mechanism, but many lists may be short; measure it
separately. Phase131's summaries accelerated `ns_unshared_terms` and `nh_terms`,
not these consumers. Reuse that experience, not its old speedup number.

Follow-up source preparation is now available in
[`phase143/occurrences`](../../selfhost/tools/performance/phase143/occurrences/README.md):
the original route, an existing-NU_Set summary and an allocation-free modular
interval predicate. Thirty expected-result controls compare allthree routes;
fourteen direct interval controls cover additional U32 boundaries. These files
are isolated, unexecuted prototypes at this audit checkpoint, not an adopted
optimization or a proof. Root owns checked acquisition and performance evidence.

### 2. Compute immutable book facts once per request

There are concrete repeated calculations, without a need for persistent caches:

- Ordinary `p128raw_lower_request` derives the constructor catalogue for static
  preparation; `p111_finish` at39567 derives the identical catalogue again.
  Phase140's `p140or_catalogued`/`p140or_finish` already demonstrate the explicit
  shared-value seam. Extract just this cold-path sharing, not dependency/cache
  machinery. The same `nc_bangs_names(book,names)` also appears twice in
  `p128raw_prepared` after static preparation.
- `nol_finish` at36319 and `p128bl_finish` at55344 append
  `nol_scalar_specs(book,book)` for each successful observer schema. The ordinary
  scan calls these through `no_observer_plan`; retries can reach the nested
  schema path. This whole-book catalogue is independent of the owner.
- The incremental late cache computes the catalogue once for its global gate,
  but a miss still reaches ordinary plan construction. Merely adding a cache
  catalogue did not replace those schema calls.

**Falsifier:** prepare the immutable catalogue once at the observer-pass boundary
and pass it explicitly into both schema-completion paths. Compare complete
NO_Schema/NO_Plan values, ordering, diagnostics and QBE on original book and
alias-body changes. Scalar admission can normalize alias bodies; headers or
nominal ADT names are not a sufficient cross-request key. Keeping the value
within the exact request avoids that invalidation question entirely.

This is a small cheap change, approximately30–60min to a checked candidate.
Direct scalar-catalogue owner exposure is only0.68% in the historical ordinary
profile; constructor queries also serve many other consumers. It is a useful
cleanup, not a credible10× plan. Reject a global sidecar wrapper that makes
every ordinary query slower when metadata is absent; Phase135 already found
mixed request costs from that approach.

### 3. Preserve text fragments through the function output boundary

The outer cursor already streams private/legacy/public functions, then data
slices of128 items. Whole-output retention, the old private-block join and the
extra per-piece newline append were addressed in Phase134. Do not propose
those again. `nt_text_finish` at30447 traverses each reverse-list fragment once;
it is linear, not a quadratic append of the growing output prefix.

The remaining issue is representation and multiple linear passes:
instruction helpers build linked String lines, `p111q_body_text` flattens them,
private/public emitters concatenate headers/body/footers, and `File.write`
consumes the resulting String into runtime output bytes. Reclaiming those
intermediates is real work. Even ordinary function rendering keeps this boundary.

**Discriminator:** retain one real small, medium and large verified function
plus IDs, then compare current rendering with a fragment-preserving output
cursor. Use the same native File.write endpoint and independent complete bytes;
include generated function text, IO errors, ordinary LF protocol, total elapsed
time and maximum live storage. No compiler rebuild or host code generator is
needed for the first extracted rendering experiment.

Do not assume writing each line is profitable: it multiplies effects/runtime
transitions and writes. Phase134 batching incurred extra length scans and joins
and was slower. If fragment output is slower, the next meaningful experiment is
a bounded byte-oriented output representation/ABI, not another String batching
loop. That is a separate, larger runtime-contract change, not free cleanup.

This has the largest clear backend stage envelope (historically18.28%), but
the saveable fraction is unknown. A50% interval reduction would mean about9.1%
less whole-request time on that historical distribution. Budget roughly1–2h
for a useful native fragment discriminator; a generalized byte writer is longer.

### 4. Use one function summary for repeated admission/rendering walks

Per private function, `p113i_function` separately visits params, clean structure,
size and stack; the successful inliner immediately calls `p113k_function`, then
the pipeline calls ranges again. Rendering separately counts array operations,
collects buffers, discovers selected calls, allocas and multi-result calls.
All are concrete source traversals, but no current profile isolates their sum.

A small immutable summary of one actual body can carry size/stack/template/
alloca/multi-result facts to its immediate consumers. Keep any original-order
error checks and recompute after a body rewrite. Avoid a generic callback walker
or a universal IR refactor. First instrument/count actual visits and do a paired
consumer experiment. A useful first result should take1–2h, not another large
architecture campaign.

Do **not** skip the second range pass on an idempotence assumption. Phase134's
exact within-request memo was mixed (Lexer better, closures worse, Map neutral)
and was excluded. Its input/output key distinction and negative results remain
relevant. The existing verified-commit reuse already avoids rechecking identical
bodies under exact ordered headers; proposing that again counts no new saving.

### 5. Improve verifier table representation without removing verification

`p111v_get` hashes String names for a KDef index and returns a nine-field KDef
whose useful payload is kind/width/capacity. `p111v_put` allocates that generic
row repeatedly; local-table branch intersections and updates add work. The cold
backend profile makes this significant, but whole-phase attribution is absent.

A dedicated scalar verifier row/index or query-plus-consumer interface could
reduce generic products/reference churn while keeping the exact verifier.
Preserve full names/hash collisions, first-match/error order, absent versus
zero values, duplicate declarations, branch intersection and reserved names.
Do not renumber all compiler IR to try this. Compare complete error strings on
invalid IR and a real verified segment kernel first. This is medium complexity,
roughly1–3h to a convincing prototype, with no justified gain estimate yet.

## Larger structural avenue, with a hard evidence gate

Raw preparation constructs generic fallback segments and private candidates
for the same names. Some private candidates are later rejected or superseded;
many generic dispatch segments remain in the final image. Private-first lowering
with on-demand generic fallback could remove construction, verification and
rendering together, but it also changes fresh-ID allocation, function/table
identity, ownership and fallback reachability. Dynamic dispatch, continuation
and error paths prevent treating every replaced worker as dead.

Do not begin that rewrite from static counts. First record which generic owners
and candidates survive every final runtime/descriptor root, and attribute their
actual construction time. Phase132's syntactic dead-private graph is evidence
for investigation, not permission to omit lowering. A small source-connected
family with identical final products would establish value; otherwise this is
not yet the best use of the next iteration.

## Recommended sequence and stopping rules

1. Parent establishes same-source ordinary baseline; keep session cold separate.
2. Run the exact `nd_comb_fresh` consumer discriminator, including preparation.
   If it fails on native compiler-derived inputs, retain the negative and stop.
3. Share identical constructor/bangs/scalar catalogues within one request where
   the source seam is already explicit. Require complete output and unchanged
   admission/error order; no cross-request memo framework.
4. Run the extracted fragment-rendering discriminator before a generalized
   emitter/runtime rewrite. Use both actual output and peak memory as evidence.
5. Acquire and broadly qualify only a composition with measured native request
   benefit. Keep the independent final gates, existing proof declarations and
   qualified fallback. Exact QBE/runtime preserves the tested generated programs;
   it is not a proof of universal compiler correctness.

The two conceptual gains worth pursuing are **one analysis per immutable input**
and **avoid building data solely to immediately flatten/consume it**. Both can
accelerate cold and warm work. More late caches or a backend switch cannot make
the present frontend, repeated syntax scans and String construction disappear.
