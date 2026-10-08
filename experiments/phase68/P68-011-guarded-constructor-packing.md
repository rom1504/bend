# P68-011: exact-payload packing for one-field constructors

Registered before implementation or target execution, 2026-10-08. Owner:
method-review lane; independent source reviewer: correctness lane. Root alone
executes targets. This is a general native representation experiment proposed
after the remaining-worker source audit, not a workload-name optimization.

**Hypothesis:** a one-field ordinary constructor whose evaluated `Term` fits
`LOC_MASK` can use the existing `TAG_PAK` representation, avoiding its node and
later reference-count wrapper. A runtime guard retains the original boxed path
for every other word, including heap pointers, closure handles, reference-count
flags and large raw numeric values. This may close an allocation gap in
recursive scheduler code even when direct-worker eligibility matches upstream.

The first discriminator is a source-derived C experiment on the already
qualified Flat06 tree and lexer acquisitions. It changes every matching emitted
one-field constructor allocation pattern, independently of constructor names.
The original acquisitions, executables, compiler sources and timing receipts
remain immutable. This diagnostic is not a newly qualified compiler image.

## Representation invariant and open boundaries

The runtime payload is 40 bits. For `w & ~LOC_MASK == 0`, `term_tag(w) == 0`,
`term_rfc(w) == false`, `term_triv(w) == true`, and `rfc_seal(e,w) == w`.
`term_pak(cid,w)` retains the constructor identifier and its exact payload.
Generated one-field matches already test `TAG_PAK` and return `term_loc`;
readback does the same. Keeping or dropping this packed value requires no heap
ownership because its only field is trivial. Evaluate the field exactly once
before choosing the branch. Wider fields use the original allocation/seal path.

There are two explicit promotion boundaries. Runtime `ctr_take` itself does not
decode packed values, although generated matches bypass it for this case.
Valid one-field effect requests contain a continuation closure and therefore
take the boxed branch; malformed raw immediate continuations require separate
analysis. Foreign C can inspect constructor layout directly. Dynamic packing
of a Nat or Bool wrapper extends upstream's static one-w32-field packing and
must not silently change a required foreign layout. The pure saved-C
discriminator does not settle either boundary. No universal public/raw or
foreign compatibility claim is made at registration.

## Cheapest disproof and controls

Root may compile each fresh diagnostic with the exact saved recipe's Clang,
flags and runtime protocol, require full existing output oracles, and compare
the same plan. Inspect generated code/assembly to establish whether scalar
guards disappear and node/reference-count allocations shrink. Stop on any
output mismatch, unsafe raw fallback, unaccounted field evaluation, negligible
allocation opportunity, or a meaningful runtime/Clang regression.

Before compiler integration: test zero/max40/max40+1/full64 fields, shared and
dropped values, boxed pointers, nested constructors, constructor return/readback,
foreign producers/consumers, and error-order/raw continuations. Preserve all
failed evidence. Product flattening, direct worker admission and inlining are
held fixed within a comparison; no GPU performance claim is planned.

Status: source investigation; no target executed, correctness result or promotion.

## Source proposal and first frozen discriminator

The [design](../../design/phase68/guarded-constructor-packing.md) records the
runtime proof obligations and conservative boundaries found during review.
The first candidate restricts packing to encoded non-Base constructor identities
and disables it for any non-Base foreign definition in the whole book. It adds
21 Bend lines in existing emit/book modules, no runtime/host/schema/module change.
Low-level emission without explicit permission remains boxed. The isolated
[v2 patch](../../selfhost/tools/performance/phase68/constructor-packing/v2/candidate.patch)
has SHA256 `5153c3eac7b4ed9fe582a7bddd129584e2ce03f282dfef19916935f85626e366`;
v1 remains preserved with its missing-permission-macro limitation.

Saved-C plan `selfhost/build/phase68/packing-c-diagnostic01/plan.json` has SHA256
`040494be97849b2de736ec7f908d005982d44b4cb15d044d03e7bd0e98570cb6`.
It changes 21 tree and 12 lexer encoded one-field constructor sites, leaving
Base/IO constructors unchanged. The data preparation's initial imported-parser
failure and exact one-edit correction remain recorded. The root-only runner
uses the existing guard and full original oracles. No target result is attached
to this source-only update.

## Root-executed saved-C result

Root closed the frozen diagnostic with two passing smoke runs and all twelve
measurements correct and at least 100 ms. All full output oracles passed.
[Portable evidence](../../implementation/phase68/evidence/packing-c-diagnostic01.json)
binds original acquisitions, exact changed C, binaries, plan, runner and raw
execution report (`54edc15a80c55b0f181e9290f11ec350b4196c0427259f939531112d8e956afe`).

| Case | Baseline samples (ms) | Candidate samples (ms) | Median ratio | Reduction |
| --- | --- | --- | --- | --- |
| Tree | 210, 213, 209 | 165, 161, 160 | 0.766667 | 23.33% |
| Lexer | 169, 168, 167 | 163, 159, 156 | 0.946429 | 5.36% |

Three rounds alternate baseline/candidate order under one guard. The saved
baseline binaries are reused, while diagnostic C is compiled with the original
Clang recipe. Candidate build times are 7.60 s and 7.84 s, versus original
acquisition clocks 7.62 s and 7.86 s; these are single builds in different
campaigns, not a paired compilation-speed result. Binary sizes change by +768
bytes (tree) and -144 bytes (lexer).

Decision: the diagnostic supports integrating a small checked compiler candidate
after products, subject to source review and focused controls. It establishes
no broad conformance, foreign/raw ABI, genuine-B2, GPU or six-family speed claim.
Independent review found a missing `Absent` foreign-function declaration case
in the initial permission fence; its correction must be frozen before source
integration. The diagnostic programs contain no such declaration and its
observations remain valid for their pinned sources.

The correction is frozen in
[v3](../../selfhost/tools/performance/phase68/constructor-packing/v3/freeze.json),
patch SHA256 `63c8c8fbd700b52bc8155f10cc0524b35ff1f95ef6ff9d15a3f3b9026d9710c1`.
The independent correctness lane rehashed all inputs/outputs and verified the
sole v2-to-v3 expression change: non-Base explicit Foreign values or absent
Def laws disable packing, while ADT/Ctr absent metadata does not. Recursive
child/index scanning and the emission helper remain intact. Final source review
PASS; compiler/control targets are still required. Products v2's owner confirms
the frozen book seam composes with this patch. Earlier proposals remain preserved.

## Preserved checked-build corrections

Root's packing-build12 rejected matching the local `+boxed` value in
`ne_single`. V4 extracts the same prefix/boxed-code/suffix concatenation into
`ne_single_result`, whose parameter is matched; independent source review
confirmed no generated-C operation or freshness change. Root's packing-build13
then rejected repeated consumption of the definition variable `d` in the
foreign scan. V5 changes that pattern binder to `+d`, retaining the exact scan.
Both failed attempts remain intact; neither produced a qualified candidate.

The current isolated source is
[v5](../../selfhost/tools/performance/phase68/constructor-packing/v5/manifest.json),
full patch `f19fa2e4b98c2c5b808bc6abfb00db6ea0b7873e6ebddf7be9acdf4e4f94274c`.
Focused [controls](../../selfhost/tools/performance/phase68/constructor-packing/controls-v1/README.md)
compare exact product10 with the next successful strict packing image. They
include a separately labeled runtime representation witness, not only output
equality and permission-source checks. Control plans await that actual image;
no result is implied by their preparation.
