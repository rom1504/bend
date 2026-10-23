# Remaining opportunities after source32

This is a bounded static audit of **source32**, not a new profile or benchmark.
The compiler SHA is `40c469114c4d1c75dceab456e1979bb5c0278744a02e6dbe4a37e63667740abb`.
Exact current QBE, executable, upstream C/executable and runtime-object hashes,
decoded function excerpts and disassembly are preserved in
[`remaining32/report.json`](../../selfhost/tools/performance/phase126/machine/remaining32/report.json).
Source32 contains the flat-observer closure, Nat.divmod product lowering and
tail-SCC work; their earlier absence is not a remaining opportunity.

The root-run focused screen still measures records **2.84×**, evening **6.12×**
and map churn **3.27×** upstream. These whole-program ratios do not attribute
time to any mechanism below. No current dynamic share was collected here.

## 1. Carry flat observations through the outer Map continuation

**Observation.** The new private `$product.Map.bit` exists, but `Map.get`,
`get.go`, `seek`, `seek.go`, `put.go` and the record aggregation loop remain
generic scheduler entries. In actual source32 `Map.get`'s MNode branch:

```text
take3(node) → keep(position) → ctor3(position, left, right)
→ save rebuilt root/default in explicit frame
→ jump to boxed public Map.bit
```

The retained machine code really calls take3, keep, ctor3 and jump; this is not
just verbose intermediate syntax. The boxed private Map.bit still constructs
its final pair even though its flat counterpart avoids it. Upstream's
`WL_CASE(FID_MAP_GET_GO)` instead uses `_nd_0 = _sp_0` and related assignments
to reuse the consumed MNode location on several branches (retained C line 5798
onward). Other upstream branches still allocate and preserve continuations.

**Hypothesis and prerequisite.** Project an already-verified flat helper and
its immediate local return consumer together, preserving the explicit stack,
captured owning values and evaluation order. That can remove a routing-result
box/take and scheduler transition without first making the entire large Map
worker private. A broader immutable binary-ADT observer could also remove
root reconstruction. It is not a trivial relaxation of existing admission:
the current observer schema requires two constructors, one nullary, one
recursive field and scalar companions; Map has three constructors, two
recursive children and owned key payloads. The actual source32 private-worker
refusal must be queried; body size alone is not an established explanation.

**One-hour falsifier.** Spend approximately 10 minutes extracting exact refusal and
return-frame facts, 25 minutes implementing one general ready-flat-helper/local
consumer projection, and 25 minutes checking an ordinary renamed binary search
with retained root/key aliases and found/missing branches, then records and
one unrelated helper-return consumer. Require actual removal of box/take or
scheduler work and a matched runtime benefit. If the projection needs a new
ownership schema, stop at that boundary and use an independently checked
borrowed binary-search ceiling to decide whether the larger change is worth
building. This is the highest-value cross-layer experiment, not a promise to
finish general Map borrowing in an hour.

**Impact/risk.** Potentially material for repeated map traversal and its callers;
there is no defensible corpus percentage or parity forecast yet. Preserve
shared/static owners, keeps for escaping keys, continuation liveness and
fallbacks. Phase126's rejected local tree reshape shows why eliminating
allocations alone does not establish a timing gain; do not revive generic cell
credits merely to reproduce an allocation count.

## 2. Project certified borrowed field reads into the reader's scalar region

**Observation.** Source32's private `Map.bit.go` borrowed reader still calls
`p118_rt_borrow_fields` for every SCon with known CID 25 and arity 2, reloads two
scratch fields, and repeats. Its actual machine frame is `0x808` bytes, with
callee-preserved register traffic around the call. The generic helper repeats
constructor-count/CID/arity/tag checks and a copy loop before returning. Its
RFC resolution via `term_peek` remains semantically necessary. At the selected
character there is also a generic Nat.sub operation; no claim is made that
this dispatch dominates the whole program.

**Hypothesis/falsifier.** Under the existing authenticated observer layout,
match and output-capacity certificate, compare a distinct typed borrow2 helper
with a projection that resolves the borrowed owner and directly defines two
SSA fields. Preserve RFC acquisition, packed/static cases, all ownership and
unknown-case fallback. Reuse shared/static/retained-alias controls and test
String comparison plus an unrelated List observer. This is a bounded helper
experiment before extending the observer domain.

**Impact/risk.** Likely a smaller local gain than opportunity 1, with useful
transfer to current String/List readers. Older Phase122 records samples put
6.35% of leaves in the generic borrowed-field helper, but that is not a
source32 share or a speedup bound: caller spills and removed checks may move
the result either way. Compiler lexing transfer remains unmeasured.

## 3. Expose Nat.divmod's constant divisor without recreating two divisions

**Observation.** Source32 has successfully removed Nat.divmod's heap tuple.
Map.bit now places 33 in a register, calls `p126_rt_nat_divmod`, then loads two
words from its 16-byte output. The helper computes quotient and remainder with
one hardware unsigned 64-bit division. Upstream's retained `WL_FID_MAP_BIT`
uses multiply by `0x0f83e0f83e0f83e1`, shift and subtraction for division by 33;
the constant is visible to its native optimizer. Source32's ordinary boxed
Map.bit still constructs a later final result pair; its flat counterpart does
not. These are distinct costs.

**Hypothesis/falsifier.** An exact verified projection into scalar QBE could
remove call/output-buffer transport and expose constants. First inspect whether
one quotient plus `r = a - q*b` produces better code: blindly emitting both
udiv and urem can introduce two divisions where the helper currently has one.
Retain divisor-zero `(0,a)` semantics, full-width arithmetic and independent
zero/high-Nat/variable-divisor controls. Do not assume QBE strength-reduces
constants, or reuse a U32 magic-division rule for the full Nat contract.

**Impact/risk.** A modest independent experiment, below the outer control and
ownership barrier. Historical Phase122 Nat.divmod leaf shares were about 3.05%
for map churn and 0.8% for evening, before tuple elimination; they cannot
justify a large current prediction. Prefer opportunity 1 over spending another
cycle solely on this last buffer.

The next decisive information is whether a general flat-helper/local-resume
projection removes work in an actual outer caller. Preserve the qualified
source32 compiler while answering that question; another full rebuild or
broad profile is unnecessary for the first falsifier.

## Output-preserving preparation cleanup

The completed root-run `phase118/p126-final32-cost/report.json` measures
**+8.75%** geometric whole prepared-request time on RLE/lexer and **+13.21%**
inside the admitted entry. RLE is 4.221→4.639 seconds; lexer is
8.055→8.668 seconds. These timings do not identify the responsible pass.
The candidate emits 19 additional chunks for each request, so some extra
lowering/verification/rendering is legitimate new output, not removable waste.

**Concrete static duplication.** `p126bp_close` calls
`p113pl_inspect_request(request)` after the original program and borrowed workers
are already available. That repeats `p112s_prepare`, bang/signature analysis
and candidate lowering for the whole source catalogue. Then
`p113d_pass_function` immediately discards candidates whose symbols are already
in the merged ready index. Exact source32 locations are
`compiler.bend:46079` (repeat preparation), `:46031` (candidate enumeration),
and `:44685` (ready-name discard); the new closure is in
`product-primitive/flat-observer-v02.bend`.

**Small first cleanup:** give a late-only candidate enumerator the existing
`p113e_signatures(merged, missing())` index. Before invoking
`p113pl_flat_candidate`, test whether its exact signature symbol
`nm(dv(info))` is already ready. If so, omit that candidate. Keep full source
names for signature/bang derivation, preserve boxed candidate bundles and
their order, and retain the unchanged final closure/verifier. A flat factory
produces exactly one deterministically named candidate; the old closure would
discard it regardless of its body or error. Boxed factories can additionally
produce TRMC/stream workers, so skipping an entire source definition merely
because its public entry exists would be unsound as an output-equivalence
claim. This narrow change needs no persistent cache or new IR.

Check exact QBE bytes against frozen source32 for both cost fixtures and a
product-heavy record request, then rerun the same paired cost measurement.
This is a plausible recovery of part of the overhead, **not** a measured
attribution or promise to recover all 8.75%. Broader prepared-state reuse is
worth considering only if this exposes substantial repeated lowering cost.
The SCC pass already uses indexed identities and reciprocal-call filtering;
table-call emission already builds one compact catalogue and skips empty
catalogue searches. Neither justifies a speculative replacement cache before
the simpler guaranteed-unused lowering is removed.
