# Late checked frame imports: experimental capability boundary

This is additive, unqualified Bend code. It changes no maintained definition.
Root owns all source checks, generated programs and timings; no result below is
an executed-test claim.

Files: `selfhost/tests/phase171/checked-imports.bend`,
`checked-import-emission.bend`, `checked-import-controls.bend`, and the standalone
`recursive-tree.bend`. Earlier `frame-inspection*.bend` is optional inspection,
not a required dependency. Do not include `fail-fast.bend` in the first treatment.

## Actual implementation

`p171_request` first runs the complete maintained `p168_request_mode(1,request)`.
It retains its real `P113DProgram`, adapter map, generic families and static image.
The unchanged `p167ob_final` checks those originals and old private workers.
The existing authenticated public view is separately checked with
`p118b_verify_functions` before any frame selection.

For source-derived ordinary definitions, the actual retained owner segment is
looked up by `p113d_public(book,source)`. `p114h_plan` receives a callable view
containing **only the frozen checked old direct workers**, with no legacy region
readiness. Thus accepted self recursion uses the existing explicit frame stack;
no newly imported worker is visible to another import's analysis. Each
`P171Import` binds source name, complete owner segment, exact referenced
continuation family, full typed plan, full dependency-worker snapshot and rank1.
The unchanged `p114h` limits/hygiene/body checks apply. There is no name whitelist.

Ordinary candidates are then re-lowered and admitted against old signatures plus
proposed import signatures. Repeated static preparation must reproduce every
static node/word exactly before its operand addresses can be used. Candidate
selection is a producer step, **not authority to emit**.

`p171_verify` repeats original/old-worker admission, re-derives every import from
the actual original index and frozen old-worker view, compares complete plan and
family fields, rejects duplicate identities and non-1 ranks, then projects the
actual newly admitted callers with `p118b_project_functions`. The unchanged
`p113e_functions` validates those caller bodies using only this independently
reconstructed signature environment. No empty or surrogate `P113DFunction` is
created for an import. Newly admitted functions are checked in dependency order;
they cannot replace an import or old dependency identity.

`P171Program` is therefore an inspection/proposal record, not a proof token.
The public emission entry always repeats verification before accepting it.
The compiler's existing structural verifier and `p114h` transformation remain
trusted compiler implementation; this is not a BendTT semantic proof of either.

## Emission and ABI

The unchanged original generic program remains the source of FIDs, constructors,
static data, generic-verifier obligations and fallback/continuation bodies.
Each selected import emits exactly one saved `p114h_private` worker and a real
one-result direct-symbol forwarder. A small external cursor interceptor replaces
only that selected owner's public rendering with the existing `p113e_public`
wrapper. It handles empty cursor transitions itself so the old cursor cannot
silently select a second `p114r`/`p114g`/`p114h` body. Other pieces, chunk boundaries,
private emitters, region emitters and tables use the maintained cursor unchanged.

The same-request array certificate, reserved-name checks, live-register
eligibility and cold-constructor application remain. `p171_plan(P86Plan)` keeps
the maintained runtime-admission ordering and `compile: ` diagnostic prefix.
`p171_plan_text` returns `NC_Result`; the hosted driver only transports bytes.

This first experiment intentionally does **extra** candidate construction,
verification and comparison. It can establish a runtime calling capability and
unblock caller admission; it cannot claim compiler-work reduction. Generic
family omission belongs to a later early-producer change after measured transfer.

## Root-run gates

Exports: `p171_plan`, `p171_plan_text`, `p171_request`, `p171_verify`,
`p171c_summary`, `p171_controls`. `p171c_summary` returns old-function, import and
added-function counts plus an empty-error bit. An import count of zero falsifies
coverage on that input; it is not a passing import test.

The nine `p171_controls(request)` results must be empty at indices0 and8
(identity and equivalent record reconstruction). Indices1–7 must refuse rank0,
missing family, invalid plan, wrong owner arity, wrong source identity, duplicate
imports and a wrong-arity new caller. A `coverage gap:` result means the input
produced no usable import and none of these semantic gates was exercised.
These mutate compiler data only; no malformed runtime is executed.

The valid recursive-tree fixture independently expects the complete value
`[127,8128,8128,127]`, including repeated reads of the retained root. It provides
non-tail two-child recursion, not a function-name admission rule. Root should
also use the retained real Map/checker complete-product oracles. The generated
QBE intentionally changes; exact baseline QBE equality is not expected. Baseline
and treatment use the same runtime, QBE toolchain, source and input.

Before timings: source acceptance; nonzero actual imports; positive and negative
compiler-data gates; complete baseline/treatment outputs; emitted direct
forwarder plus exact planned frame worker; and an actual added caller if claiming
an admission cascade. A speedup of an already framed root alone would not prove
that callers were unblocked. Stop rather than acquire a full compiler if the
real complete computation is neutral.

## Source-check history and callback audit

The first frozen source (`import-source01`) failed the upstream type check at
`p171r_body`: `p134v_list` requires an affine `A -> A -> Bool` comparator, whereas
`p171r_stmt`/`p171r_case` had shared-argument signatures. Only those two signatures
were corrected for source02; source01 and its failed receipt remain retained.
This is a source-admission failure, not a semantic-control result.

A bounded peer audit found that unknown/dynamic jumps cannot survive
`p112t_scalar_safe`; self edges use local frames, other callable edges use the
frozen view. A follow-up source inspection of maintained `runtime.c:4055–4391`
finds `p111_rt_op` dispatches arithmetic, conversion and array primitives, with no
source FID invocation or callback argument. `p111_rt_closure:3965` only constructs
captures; it does not invoke the closure. This supports the rank argument; it
does not replace the original ownership, source-permission or generated-program
gates. No malformed runtime/failure probes were run.

Source02 then passed acquisition: `selfhost/build/phase171/import-api02/report.json`
records `complete: true`; stderr says `Checked 10 API exports`. Frozen source
SHA256 is `200e1fabcdca157af05d5eb26fc5bcd2a7265632a863b01d2cd0c282c95297d2`.
This establishes source admission only. Import coverage, compiler-data refusals,
complete generated outputs and runtime gains remain separate pending gates.

The first workload request (`import-controls01`) stopped at frontend admission:
`load: pilot requires import Base`. The standalone tree fixture omitted that
header. Its exact prior bytes are retained at
`selfhost/build/phase171/method-history/recursive-tree-without-base.bend`; the
current fixture adds only `import Base`. No import-semantic controls ran in that
attempt. Compiler/API source02 is unchanged.

The second tree request (`import-controls02`) also stopped before import analysis:
main passed U32 literal `7` to the Nat depth parameter. The maintained qualified
closure fixture uses the required `11n` syntax. The current tree uses `7n`;
prior bytes are preserved as `method-history/recursive-tree-u32-depth.bend`.
The List return and compiler/API were unchanged. This is another frontend fixture
failure, not a semantic rejection or import-coverage observation.

The corrected tree then passed `import-controls03`: all nine expected outcomes,
including both accepted records and seven compiler-data refusals. Its complete
stdout/runtime oracle was not part of that job. The common diagnostic mentions
family/dependency/rank, but this set does not independently mutate the frozen
dependency snapshot; do not credit that unrun negative. Source SHA is
`71b79a2c178b25e14d5af9e56bf84eb0fa9ee1e1d32a0da1c735ab59ef0d0920`.

`inspect-imports.mjs` is a separate authenticated metadata producer. It reports
actual imported families and newly proposed workers, typed call sites and their
transitive dependency closure. These are static counts; final emission admission
and dynamic speed remain distinct. Its derivation and deferred upstream-oracle /
real-workload commands are `import-inspection-derivation.json` and
`import-transfer-recipes.json`. No compilation/execution was performed by this
source-audit lane. A local `node --check` attempt could not run because Node is
not on PATH; it supplies no syntax-check result.

## Real-workload falsifier

The root ran the authenticated inspector on the frozen 39,333-byte verifier
source (`import-inspect-verifier01/report.json`). It found 93 existing direct
workers, **zero eligible imports and zero newly admitted callers**. The hosted
inspection took31.302s including repeated proposal preparation; this is not a
compiler-speed result. This rejects the proposed import bridge as a useful
optimization for that workload under its current admission rules. No native
image or machine campaign was launched. The nine finite tree controls remain
valid but do not demonstrate transfer. Defer this branch until there is evidence
that a measured hot region meets its source/dependency requirements.
