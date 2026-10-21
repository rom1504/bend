# Phase123: preserve predicates and expose scaled addresses

Two small Bend changes make the unchanged edit-distance program substantially
faster. A four-role longer comparison measures Phase121 at4306ms, predicates-only
at2792.5ms, predicates plus scaled addressing at2549.5ms, and upstream C at2023ms.
That is **40.8% less runtime than the parent and1.26× upstream**, versus2.13× before.
The four rotations retain all outputs and show similar differences. These are
per-case results, not full-corpus parity or compiler-throughput improvements.

[Design](../../design/phase123/typed-private-computations.md) ·
[Reproduction](../../selfhost/tools/performance/phase123/README.md) ·
[Backend explanation](../../docs/self_hosted/native-predicates.md).

The final candidate combines the two Bend rules with an explicitly qualified
GNU assembler branch-alignment policy. **All405 final original45 output/count
observations pass.** The ordinary-assembler comparison is preserved separately;
its two list regressions motivated the alignment ablation and build-only gate.

| Same-run original corpus metric | Phase121 parent | Final candidate |
|---|---:|---:|
|44-point geometric runtime / upstream|2.15074×|**2.00584×**|
|Mean positive log-slowdown, natural log|1.01575|**0.94810**|
|exp(mean positive log-slowdown)|2.76142|2.58079|
|Programs above2× upstream|31|**24**|
|Programs above1.1× upstream|40|40|
|Sum of44 fixed-batch medians|28,414ms|27,372ms|

Runtime improves **6.74% on the historical geometric metric**, and **6.66% on
positive log-slowdown**. The latter gives fast programs zero credit rather than
letting them cancel slow ones, so this gain is reducing the remaining deficit.
The fixed-batch sum improves3.67%, and positive excess time falls20,335→19,296ms.
Equal weighting of the frozen family labels gives6.73% less runtime and2.05886×
upstream. Forty points still exceed1.1×: broad parity remains unresolved.

The largest final point slowdown is2.03% (RLE), within the variation of these
short screens; no point exceeds2.5% regression. This is not a statistical guarantee
against regressions on unmeasured workloads. Three round-level geometric ratios
are0.9301/0.9403/0.9316, descriptive observations rather than confidence intervals.
The earlier ordinary-assembler score was2.01248× with confirmed list regressions;
it is retained rather than replaced silently. [Branch-layout ablation](branch-alignment.md).

| Representative original program | Parent | Candidate | Upstream |
|---|---:|---:|---:|
|Editdist|430ms|253ms|202ms|
|Local-pair, derived from editdist|435ms|253ms|201ms|
|Mandelbrot|802ms|699ms|200ms|
|Mandelbrot grid5/31|403ms|310ms|201ms|
|Scalar-region8192, derived from Mandelbrot|431ms|343ms|200ms|

[Results](results.json) retain all44 points, the unchanged zero-work sentinel,
positive-log and family metrics, cost screens and negative findings.
[Candidate](candidate.json) pins the checked source/API/runtime and final machine
builder. The installed and qualified native selections do not change.

## Mechanisms

1. Existing scalar facts now retain the origin of an actual comparison through
   copies and exact0/1 Boolean diamonds. Root and destination versions prevent
   reuse after writes; general joins discard facts. An eq/ne0/1 retest becomes
   a U32 copy or xor1 of the still-live original comparison. Arbitrary words and
   nonzero high-word constants keep the original path. This repairs information
   lost between inlining, representation conversion and scalar lowering, without
   another whole-body analysis pass or a workload-name rule.
2. The existing packed-array address template emits multiply-by4 instead of
   shift-by2. They agree modulo2^64. The pinned QBE1.3 amd64 address matcher
   recognizes `Omul` by1/2/4/8 in `amd64/isel.c:opn` and folds it through `amatch`;
   it does not match `Oshl` there. The generated loads/stores now use scale4 index
   addressing. Array masks, handle guards, ownership and fallback stay intact.

Mandelbrot’s active `mit` worker falls122→99 whole-function instructions, with
comparison materializations (`setcc`)7→2 and zero calls in both. This supplies
a separate source-level mechanism for transfer to its scalar-region derivative.

The edit-distance hot loop falls65→49 instructions with predicates, then to44
with addressing; stack-memory operands fall9→4. All three loops have zero calls.
Whole-function counts include entry guards and the cold fallback call and must
not be mistaken for inner-loop costs. Upstream and mature C have26 loop instructions
and no stack operands. Remaining excess includes tagged-handle-derived address
state, masking, copies, Boolean cost materialization and register pressure.

## Controls and transfer

Final combined controls check600 independent BigInt input pairs, seven literal
transform/refusal/verifier expectations,80 modular scaling boundaries,450 masked
addresses, and nine exact GET/SET/SWAP templates. Shifts outside0..3 retain the
original statement. The host never dereferences diagnostic pointers. Ordinary
unsigned and renamed RLE controls have25+56 complete expected output lines.
These are finite controls, not a formal compiler-correctness proof.

Predicate-only transfer screens on recurrence, tree-bitonic, lexer, expression128
and original RLE are neutral. The combined local-fold screen is also neutral.
The broader run also finds gains on Mandelbrot and its scalar-region derivative.
Local-pair is derived from editdist; scalar-region reuses Mandelbrot helpers. The
frozen catalog assigns separate labels to those cases, but they are not four
independent algorithms. Do not infer broad parity from these local gains.

## Negative experiments and what they taught us

Explicit RLE state arguments reduce runtime approximately10–14% in short source
ceiling screens. Both the supposed outer-only and full variants are flattened
into the same four state lanes by existing machinery; they do not isolate nesting
depth. The actual encoded-list construction, expansion and digest remain.
These are changed-source diagnostics, not automatic compiler improvements.

A narrow strict-subterm product-layout prototype checks successfully but does not
admit original RLE. The source has `Pair(U32,Pair(U32,List<P2>))`: owner-head
resolution leaves inner Pair application syntax, while field resolution expands
it to Sigma, defeating exact syntactic subterm matching. The prototype is excluded.
Its positive control also fails parsing at a computed destructuring; recursive
and dependent controls stay refused. This is recorded as incomplete qualification,
not a passing product-layout test. Expanding normalization is not justified by
this modest source ceiling alone.

The more substantial RLE barrier is now precise. Its helper calls are complete
P113D workers, not entries in the P112 ready-worker registry used by the recursive
region planner. In addition, that planner cannot resume locally after a helper
call. Supporting only one boundary would not enable the actual program. The
[audit](../../selfhost/tools/performance/phase123/ready-call/audit.md) sketches an
immutable callable view and one explicit call/resume node while preserving the
existing explicit continuation stack. It is not implemented in this candidate.
The old terminal complete bridge remains separate: its historical1.51% four-case
gain does not establish the value of this larger extension.

Rejected attempts are retained: an incorrect two-argument call to unary U32.shl in address
version01 failed checking; an emission mistakenly launched with that failed
receipt refused it immediately. Earlier RLE source syntax also failed checking.
No guard limit, output oracle or verifier was weakened to make these pass.

## Scope and next step

This is still the compiler written in Bend, emitting direct QBE. Python/JS only
compose exact source declarations, transport checked APIs and evaluate independent
oracles. No new backend, runtime, public ABI or optimization search framework.
The qualified Phase118 native image and installed selections remain authoritative.
There is no new N1/N2 self-reproduction, native compiler-speed or recursive research
acceleration claim.

The best next substantial experiment is a checked local call/resume region on RLE
plus an unrelated heap-owning walker. Preserve ownership, argument snapshots and
explicit stack depth; require actual selection and complete outputs before a broad
campaign. Keep the old fallback for unknown/cyclic callees. Separately, BST needs
construction/consumption elimination, not more call-dispatch tuning: the prior
profile put51.3% in take/constructor leaves and only0.5% in control transport.

## Compiler cost and simplicity

The final three-case checked-hosted prepared request screen (editdist, Mandelbrot,
RLE) is0.97485× parent:2.52% lower observed time, with Mandelbrot essentially
neutral. The earlier predicate-only two-case screen was+0.53%. Taken together,
these establish no material hosted-cost penalty in these screens; they do not
establish native N1/N2 throughput or a robust universal compiler speedup. Every
cost sample reproduces its own frozen emitted QBE exactly.

Compiler source grows52,669→52,764 lines (+95,0.18%), adding comparison-origin
facts within the existing scan and one address-scale producer. No new IR variant,
whole-body traversal, runtime ABI or backend. Emitted QBE total falls
39,467,748→39,460,096 bytes (0.019%);10/45 outputs remain byte-identical. These
are source/text sizes, not memory or complexity proofs. Experimental tools,
finite controls and rejected prototypes are kept separately from active source.

## Research cost and preserved abstraction

At20:12:57UTC,50.87min elapsed includes27.74min in34 serial guarded jobs:
10.90min checked program emission,10.57min machine builds/output/runtime checks,
5.01min compiler-cost measurement,1.09min API acquisition and0.17min finite
controls/queries. Three failed processes cost8.40s; the separately handled layout
parse refusal is also retained. Peak process-tree RSS is1.866GiB with23.24GiB
minimum available. No resource-limit failure or native output mismatch occurred.
There was one45-program emission and two machine-policy runtime gates, the second
justified by the real list regression. No full compiler image rebuild. Two agents
performed bounded offline source/control and semantic audits; root owned CPU3.
Agent inference/quota cost is unavailable and is not inferred from elapsed time.
[Accounting](accounting.json) and the verified[evidence capsule](evidence/summary.json)
retain failed attempts, exact commands and small raw receipts.

The abstraction worth preserving is the **semantic predicate origin**, independent
of QBE text: canonical value, inversion and mutation epochs. Legality is separate
from the copy/xor realization and the machine-level profitability check. Array
index identity/masking likewise stays semantic; multiply-versus-shift is a target
selection decision. The branch-alignment experiment reinforces that profitability
belongs in measured machine policy, not in the semantic proof. No universal IR
was added to preserve these distinctions.

The compiler/optimizer itself remains an important future workload. This cycle
measures its hosted request cost but does not demonstrate a generated native
compiler speedup or faster subsequent discovery. The next bounded call/resume
experiment should include an extracted compiler analogue before any full image
acquisition. See[remaining opportunities](remaining-opportunities.md).
