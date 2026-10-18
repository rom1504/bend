# Phase110 additive runtime ABI candidate

This records source design and bounded assumptions. Root-run receipts establish
which candidates pass execution and whether any measured gain exists. Phase109
source, frozen captures, runtime objects and baseline evidence remain unchanged.

## Mechanism and ablations

Phase109's fused worker retained three per-cell calls: constructor identity,
generic binary reconstruction, and transfer of the remaining scratch child.
The new `nxo_lower110_policy` preserves the original `NxoOp` graph and its
ownership verification, then admits two separately named policies:

- `tagged` replaces borrowed constructor identity with `(word >> 40) & 65535`.
  The tag local and comparison remain U64, avoiding an unspecified truncation.
  The generic `rt_rebuild2` and scratch transfer stay unchanged.
- `specialized` additionally chooses `rt_rebuild2_cC_kK(ctx,parent,other)` from
  the constructor identity and retained-child index already known in verified
  `Take2; Build2; Tail2`. These constants remain literal in the runtime helper.

The separate typed pair facade upgrades that specialized graph into a single
two-result operation. Its runtime `rt_pair_rebuild2_cC_kK` returns a 16-byte
`NxRtPair { first, second }`, containing the new constructor and the remaining
old field in that order. It neither reads nor writes context scratch. Its
platform aggregate calling convention and generated QBE call sites require
actual machine inspection; a C struct declaration alone does not prove that
every intermediate spill disappears.

No source function name participates. The adjacent ownership pattern, generic
tail permutation conditions and refusals are inherited from Phase109. Calls
remain ordered effects; ownership results never become arbitrary memory
addresses. The safe generic `nxo_law_select` is called directly by candidate
lowering to select retained index and remaining variable. Its separate laws
cover logical selection and ownership-model reconstruction, not C refcounts.

## Authentication and ownership

`runtime/materialize.py` requires a complete authenticated Phase109 runtime
materialization whose production source SHA-256 is
`9e1c59078878be94052cb4d2d63a713e19e29b41ed3f94b034f2175a50efd0a9`.
Every recorded source/adapter/output pin is rechecked. The complete old runtime
is retained as a byte prefix, the exact `term_aux` accessor is checked, and the
TermABI shift/mask are recorded in the new manifest. Runtime acquisition is
separate from ordinary worker build and execution clocks.

The extension appends descriptor-specialized adapters to that runtime. They use
the exact production `ctr_take`, `heap_alloc`, `cls_fit`, and `rfc_seal` helpers;
there is no allocator change. `spare >= HEAP_OFF` is the only shell-reuse rule.
Shared parents retain children through `ctr_take` and allocate a new shell.
Static parents can return a nonzero immortal location and also allocate, so
they cannot be overwritten. Both new fields remain conservatively sealed.

All four binary descriptor/index combinations have machine declarations. Three
have well-typed witnesses in this fixed catalogue: Con keeping field0, Con
keeping an SCon tail, and SCon keeping its Char head. SCon keeping field1 has no
well-typed source witness because every admitted binary tail is an ADT, not
Char; its presence does not broaden checked-source admission. The trusted ABI
still requires typed checked inputs, original descriptor binding, valid live
single-thread context and independently verified structured ownership. It does
not promise defined behavior to a fabricated native caller.

## Prepared controls and limits

`lower/controls.bend` covers policy names, alias/effect refusals, retained index,
preserved remaining-child transfer, eliminated calls, machine typing, and
ownership/unknown-policy refusal before code construction. It supplements the
unchanged Phase109 controls and independent checked-fact mutation gates.

`runtime/contract-controls.c` supplies eighteen operation cases: specialized or
pair result transport, three valid descriptor/index shapes, and unique/shared/
static parent ownership. Each observes results, releases both result owners,
then observes retained aliases before release. Context close checks scratch
and actual allocator live words. Frozen expanded worker inputs are separate.

These checks do not prove the production runtime, source lowering, arbitrary
native callers, threads, general data layouts or full-compiler speed. Detailed
executed counts, failure records, machine evidence and timing decisions belong
to the integration report.

## Explicit follow-up variants

The original adapter and materializer remain intact after the first freeze.
`materialize-variant.py` authenticates that original Phase110 output, then
creates a fresh runtime with either the same constructor helper call or the
explicit `direct` constructor variant. The latter spells precisely the original
three operations, `rfc_seal(head)`, `rfc_seal(tail)` and `term_ctr(cid,loc)`, at
each specialized call site. This prevents an out-of-line `nx_construct2` from
hiding a literal constructor identity again. The runtime ownership primitives
are unchanged. Separate runtime objects permit a matched source-body ablation.

An independently selectable `--take-pair` extension implements
`rt_pair_take2(ctx,parent) -> (field0,field1)` with the original `ctr_take` and
`spare_free`. It consumes the parent, transfers both children atomically and
does not touch scratch. The separate IR conversion recognizes exactly the
adjacent trusted take/field0/field1 sequence and preserves its scalar status
result as zero. The six cases in `take-controls.c` cross List/String with
unique/shared/static ownership, checking retained aliases after both extracted
owners are released.

This extension applies to the actual Base `List.tail` and `List.last.go` bodies
without a source-admission change. Both already fit the original constructor/
match/return/self-tail subset. `tail` drops the head and returns the tail;
`last.go` drops the previous accumulator and transfers tail/head to its next
iteration. Neither has a `Build`, so reconstruction fusion cannot explain a
gain on those bodies. They distinguish general transfer-ABI usefulness from the
original reconstruction workload.

## First machine inspection

The offline [`machine01/report.json`](evidence/machine01/report.json) authenticates
all twelve `build01` binaries against their completed build receipt and retains
worker/runtime disassembly. No target ran during inspection. These are static
sites in the nonempty list loop, excluding callees and exceptional paths:

| Worker | Bytes | Loop sites | Calls | Stack memory sites |
| --- | ---: | ---: | ---: | ---: |
| Fused QBE | 138 | 25 | 3 | 0 |
| Tagged QBE | 128 | 21 | 2 | 0 |
| Specialized QBE | 115 | 18 | 2 | 0 |
| Pair QBE | 110 | 17 | 1 | 4 |
| Fused Clang | 102 | 17 | 3 | 0 |
| Tagged Clang | 103 | 15 | 2 | 0 |
| Specialized Clang | 96 | 13 | 2 | 0 |
| Pair Clang | 68 | 9 | 1 | 0 |

The QBE aggregate call receives its results in RAX/RDX, then stores both to the
return pad at `-16/-8(%rbp)` and reloads both every iteration. Clang carries the
same two results directly in registers. Thus register return and register-only
transport are different claims. The automatic loop finder only selects an
unconditional backward jump; GCC's conditional backedges are retained as
assembly without an automatic loop-site count.

The shared GCC runtime's generic rebuild uses dynamic indexing into a stack
array. Specialization eliminates that indexing and keeps both children in
registers. However, specialized rebuild still tail-jumps to `nx_construct2`,
and pair rebuild calls it while preserving the remaining child across the call.
The helper still receives constructor ID as an argument. These are observed
boundaries motivating the explicit direct-constructor variant; site counts do
not attribute cycles or establish a measured speedup.

## Private generated runtime template prototype

`runtime-ir/lower.bend` builds the common reconstruction fast path as typed Nx
loads, stores, branches and scalar operations. It does not parse emitted C or
emit a C worker string. The original `NxoOp` graph and safe selection helper
remain present until checked admission and ownership verification. Constructor
and retained-field constants remain graph constants.

`Nx110RtWorker` stores the original owned graph beside the machine graph.
`nx110rt_verify` independently checks ownership, regenerates the entire machine
graph from that semantic graph and compares canonical structural serialization,
then checks machine types/imports/exports. A caller cannot add an arbitrary
memory operation without breaking regeneration. The unchanged public
`nxlib_verify` still rejects the generated memory-bearing graph. This is a
compiler admission certificate, not a proof that arbitrary fabricated native
callers or unauthenticated erased facts are safe.

Worker entry calls checked private accessors once to obtain the heap and
allocator pointers. They require the live single CPU context, scratch empty,
the host allocator and `KEEP_WORDS == CAP_WORDS`. The authenticated materializer
records word size8, location width40, RFC flag63, count width24, heap lower bound
51413376, class0 head offset0, class0 length offset256 and limit32768. Compile-time
assertions reject a different host/runtime layout. Those pointers exist only
inside the exact private graph; the ordinary opaque library does not admit
the private capability.

The fast branch admits a non-RFC dynamic parent, or an RFC parent with count1
whose decoded source shell is dynamic. An RFC redirect to static storage is
not reusable. Shared and static parents take the unchanged specialized runtime
fallback **before any fast-path mutation**. A successful branch loads both old
children, frees a consumed wrapper through the exact class0 hot-list transition,
conservatively seals both new fields using the exact hot allocation and wrapper
representation, writes the original shell and forms the tagged constructor.
Uncommon allocator handoff/miss paths call the original production helpers.
This handles the common count1 sealed-tail case, unlike a raw-parent-only fast
path. No new allocator, free list or ownership policy is introduced.

The `single` view uses one aligned U64 RFC-cell read under the explicit existing
single-thread/no-concurrent-mutation contract. The `atomic` control instead calls
the unchanged production `rfc_view`, including its relaxed loads and acquire
behavior. Ordinary loads are not claimed equivalent for a concurrent runtime.
Both preserve the same logical ownership and fallback cases.

Twelve structural controls cover exact regeneration, closed public memory
admission, view policy and effect boundaries. Separate generated operation
probes reuse the exact template builders and expose the second owner through a
test-only scratch adapter. Independent physical-alias/allocator controls and
root-run worker tests are required before interpreting any performance result.

The existing scalar `NxOffset` originally admitted only U32 byte offsets and
the QBE backend always zero-extended them. Source review found that boundary
before private template execution. Two exact authenticated declaration
overrides extend the experimental assembled profile to admit U64 offsets and
preserve their full width during QBE emission. U32 offsets retain their previous
zero extension. Historical Phase106/107 files are unchanged, five width controls
cover the extension and refusals, and public opaque `NxLibrary` still refuses
both kinds of offset. This extension avoids silently truncating a production
Term location to the earlier synthetic-memory ABI's width.

## Separate compact-predicate and generic-operation candidates

The optional predicate override keeps the original template source intact. It
uses the exact equivalence `(term_tag(word)==CTR && !term_rfc(word))` iff
`(word >> 56)==2`, and expresses the dynamic bound as `HEAP_OFF-1 < loc`.
The first rewrite follows from the authenticated top-byte layout; its separate
finite control exhausts all256 possible top bytes. These changes target the
Boolean comparison chains seen in QBE's actual machine code, with no ownership
or allocator change.

`runtime-ir/general.bend` separately extends the private operation builder.
Generic `Take2` now uses the same unique classification, transfers both children,
then releases a last-owner RFC wrapper through class0 and the consumed dynamic
shell through class1. The class1 head/length byte offsets are8/264 and its length
increment is2. Handoff still calls the exact production `heap_hand(e,1)`.
Shared/static cases invoke unchanged take/field imports before any fast mutation.
This applies to actual `List.tail`, `List.last.go` and other independently
verified deconstructions that have no rebuild operation.

Reconstruction now accepts an adjacent `Take2; Build2` followed by any verified
continuation. It retains the constructor, selected-field, external-owner and
fresh-destination guards. The original ownership verifier checks the entire
suffix, so a consumed retained child cannot escape or be consumed again, while
the remaining child and new constructor keep their original ownership credits.
The transformation crosses no instruction. The logical reconstruction law
equates the complete local result and supports pure continuation by congruence;
it does not prove an arbitrary effectful Nxo suffix interpreter. That bridge
still depends on the independent ownership verifier and runtime observations.

The generalization has separate exact declaration overrides and runtime
materialization, fourteen structural/admission controls, and a generated
`nx_ir_probe_take2` entry using the same primitive builder. A synthetic checked
one-step helper that ordinary-calls the actual `nt_reverse` after reconstruction
tests `Take; Build; Call; Return`. Its declared result is full reverse; it tests
pass usefulness and ordinary-call ownership, not a newly measured real compiler
hotspot. Original Phase110 candidates remain frozen for separate comparisons.

## Stored-field invariant ablation

The separate `runtime-ir/stored-field-overrides.json` changes only
`nx110rt_rebuild_fast`: it omits resealing the retained child loaded from the
eligible dynamic shell. It continues to seal the external new field, release a
last-owner wrapper, transfer the remaining owner, and use the same shared/static
fallback. No new runtime helper or per-iteration check is added.

This depends on a stronger, explicit source-admission invariant. The frozen
public/trusted constructor writer and specialized reconstruction adapters seal
both fields before storing a dynamic binary constructor. The private writer
preserves that property by transferring an already sealed retained field and
sealing its arbitrary external field. The raw static writer is confined below
`HEAP_OFF`. Eligibility checks the decoded source address even for a count1 RFC
parent, so an RFC wrapper around a static shell cannot enter this fast branch.
A raw static constructor is **not** a fixed point of `rfc_seal`; if stored as a
child of a dynamic constructor, the dynamic writer wraps it first. The argument
is therefore about stored representation, not merely `term_triv`.

`stored-field-admit.py` creates a source-only receipt for the exact assembled
candidate and runtime. It recursively verifies runtime receipts, the complete
Phase109 runtime hash, exact admitted component composition, private template
declarations and allowed overrides, and closed ordinary-call admission. Seven
mutations refuse unsealed dynamic fields, a relocated static writer, an unknown
raw writer, omitted external sealing, RFC-to-static fast admission and an
unselected ablation. Seven separate Bend controls cover graph certification,
opaque-memory refusal, the remaining allocation site and unchanged fallbacks.
These are authenticated experimental premises and finite controls, not a
mechanized C heap or whole-pass proof. The independent safe seal model lives in
`laws/seal/` and describes its separate representation correspondence boundary.

The offline machine artifacts make the removed work concrete. Against the
compact/general candidate, the stored-field candidate shrinks single-view QBE's
list worker from768 to614 bytes and from203 to163 static instruction sites;
Clang shrinks from647 to499 bytes and from164 to138 sites. The second
`rt_ir_alloc0` call site disappears in both. String workers show the same site
reduction. `evidence/machine04` records compact/general and
`evidence/machine03` records the stored-field candidate. These counts include
cold paths and are not dynamic instruction counts or timing attribution.

## Direct production comparison preparation

The exact historical denominator survives at
`selfhost/build/phase109/suite01/fused-reverse-kernel/production-clang`, SHA256
`2df265ca811978c101d1a6cb10e8bf542b87a439f8771d4fb60f3c271d142ee9`.
`paired02` pins that binary; its earlier 14.085081ms observation is historical
context and will not be used as a fresh denominator.

`runtime/prepare-production-compare.py` freezes a new direct comparison for a
qualified final QBE object. The original intermediate objects and rendered
harness sources were pruned, so the preparer restores the harness from frozen
source/data and checks every restored byte against the original build hashes.
The denominator binary is reused unchanged; the candidate links its qualified
worker/runtime objects to the restored harness compiled with the original GCC
recipe. Both run all13 old independent controls, then one warmup each and five
alternating rounds of20 reversals of65,536 cells. The final ratio must use both
newly measured medians from that single campaign, with per-round ratios and
ranges. This is a finite worker-kernel comparison, not full-compiler performance.

## Exclusive wrapper-spare candidate

`runtime-ir/wrapper-spare.bend` is a separate generic reconstruction experiment,
exclusive with stored-field omission. The original retained-head sealing remains
present. After both children have been loaded from an already admitted unique
dynamic parent, a last-owner RFC wrapper can become an exclusive class0 spare
when the external other field is a raw constructor. Raw static constructors are
included because production `rfc_seal` also wraps them. Shared and static source
shells, including count1 redirects to static shells, retain the prior fallback.

The private `ir_spare` local starts at zero. Only that eligible last-owner
wrapper can populate it. If not reserved, the wrapper is released through the
existing free transition. If reserved, the unchanged retained-head seal runs,
then the spare receives the external constructor's location and count1. The new
RFC word consumes the spare and the local is cleared. The source shell and
remaining child follow the original reconstruction ownership protocol. The
reserved wrapper never enters the free list, so no new allocator or block
representation is introduced.

Logical values, independent owners and eventual zero-live accounting must match
the original operation. Wrapper addresses, free-list ordering, handoff timing
and transient allocation counts need not match: skipping a free followed by an
allocation is the intended change. Exact private graph regeneration checks this
one template; eight source refusals cover invalid reservation, wrong location,
count, missing reset/release/seal and static admission. Ten Bend controls retain
the closed memory boundary and original fallbacks. The separate physical probe
suite checks raw dynamic/static external fields, the class0 handoff boundary,
existing RFC external fields and shared-parent refusal in both release orders.

## Required private namespace separation

The wrapper audit exposed a concrete verifier gap beyond ordinary ownership
credits. An adversarial ownership graph could name a child `ir_old1`, which was
already a declared U64 runtime temporary. Generic Take2 would then assign the
first child to `ir_old1` before copying the second child, duplicating one owner.
The original credit check and machine type check could accept that graph, and
exact regeneration alone did not prevent the collision. Authentic source
lowering always generated `p*`/`v*` names, so this finding does not change its
previous machine products or timings.

The required additive namespace override now checks every ownership word,
including ordinary-call arguments/results and both branch bodies, against only
`p0..arity-1` and `v0..next-1`. Internal runtime, tag, status and tail-move names
cannot become owning source words. Eighteen controls include a data-only witness
of the earlier credit/type acceptance and the final certificate refusal; the
adversarial worker is never emitted or executed. Stored-field and wrapper-spare
admission tools have separate v2 files that require the namespace guard and
reject its removal. Historical candidate files and observations remain intact.

The later [wrapper machine analysis](evidence/machine05-analysis.md) finds that
actual QBE code performs the intended allocator bypass. On the explicitly
selected steady unique path, however, ten removed heap/allocator accesses are
replaced by ten added stack accesses: compact/general and wrapper both execute100
instructions with21 memory reads/writes. Clang instead reduces69 to54
instructions and18 to6 accesses. QBE materializes and spills shared RFC-encoding
intermediates before the spare/allocation choice, while Clang keeps them in
registers. The recorded next investigation is one common encoding block after
storage selection; no new variant was implemented for this analysis.

## Combined spare and stored-field experiment

Before fresh heldouts, the machine finding motivated two final exact source
overrides over the frozen wrapper candidate. `wrapper-combined-overrides.json`
removes the retained-field seal using the separately authenticated dynamic
stored-field fixed-point invariant. `wrapper-delayed-overrides.json` additionally
moves both old-child reads after external-field sealing. Neither changes the
classifier, external sealing, wrapper encoding, shared/static fallback, runtime
imports, or allocator. Both old-child reads still precede either shell write.
The variants are alternatives; neither applies the standalone stored-field
override to the original reconstruction function.

The combined writer preserves the stored-field invariant inductively: it keeps
the retained field word unchanged, and seals the external field by the ordinary
or reserved-wrapper transition. The independent seal and spare models compose
under their existing premises. The laws review explicitly does not claim those
models prove delayed-load commutation.

Delayed reads require a separate physical frame premise. The eligible class1
source shell remains allocated and unmodified while external sealing writes
only a fresh or exclusively consumed class0 wrapper, free-list state, and
allocator metadata. The consumed parent wrapper is distinct from its decoded
source shell. Free blocks cannot overlap allocated live payloads; allocation
extends a fixed heap base and invokes no user callback. Thus the original two
payload words remain available after sealing. Existing RFC external fields are
unchanged, while raw static external fields receive a wrapper without modifying
static payloads. Legal external aliases to retained or remaining descendants do
not change this argument: sealing changes the wrapper cell, not the aliased
payload. A raw external alias to the uniquely owned dynamic source itself is
excluded by the valid acyclic ownership premise. Shared, direct-static and
count1 RFC-to-static source shells still fall back before private mutation.
The frozen wrapper module's introductory comment describes its original early
loads; the selected delayed override and its admission receipt explicitly
replace that order.

`wrapper-combined-admit.py --variant combined|delayed` requires the conjunction
of the exact stored-writer closure, exclusive spare template, canonical private
namespace, regenerated graph, and closed owning-call catalogue when present.
Sixteen source refusals cover both representation and ownership premises,
including omitted external sealing, source-shell substitution for the spare,
child loads from the wrapper, early shell stores, missing namespace checks,
unsealed dynamic writers and raw writers in the heap. Ten shared Bend controls
cover certificate admission, opaque-memory refusal, the remaining allocation
site and fallbacks. Source-only receipts are
`wrapper-combined-admission-sourcecheck01` and
`wrapper-delayed-admission-sourcecheck01`; they run no target. Actual prepared
API/native source must receive a fresh admission receipt for its exact bytes.

The normal assembler now selects `compact-general-wrapper-combined` or
`compact-general-wrapper-delayed`; ordinary-call preparation adds the required
namespace and closed catalogue. Frozen `bridge11`/`call-source11` contain the
combined variant, and `bridge12`/`call-source12` the delayed variant. Both exact
call sources passed all16 admission refusals against `runtime-general01` in
`wrapper-combined-admission-source11` and
`wrapper-delayed-admission-source12`. API preparation detects the exact selected
template and requires runtime admission before compiling it. Normal emission
and physical-probe emission check the combined control report, while probes
re-authenticate the exact source against their selected runtime, including the
probe adapter. These integration checks were source/data only; target execution
remains with the root's serial guard.

## Final machine finding and selection scope

[The final offline audit](evidence/machine06-analysis.md) confirms that delayed
loads repair the wrapper candidate's QBE spill problem. On the selected count1
unique-list path, wrapper-only executes 100 instructions and 15 stack accesses;
combined executes 89 and 13; delayed executes 79 and 2. The delayed worker shrinks
to 658 bytes, versus 894 for wrapper and 768 for compact/general. Its next-owner
load moves from 56 instructions before the backedge in compact/general to 6,
which exposes a possible latency-hiding tradeoff. These are source-selected
machine paths, not cycle attribution.

The final matched training decision remains authoritative: combined and delayed
QBE achieve 0.99708 and 0.98602 times the compact/general incumbent, missing the
predeclared 3% and every-round gates. Delayed's unique-string gains coexist with
list and shared regressions. Compact/general therefore remains the QBE choice;
wrapper-only wins the separate Clang choice. A conceptual next investigation
would keep the next-owner load early inside a self-contained spare branch,
without carrying those values across a cold allocator path. No additional
variant was implemented.

After selection, all 11 fresh heldouts pass semantics. Aggregate ratios against
fused QBE are 0.80510 for compact/general QBE and 0.65816 for wrapper Clang. QBE's
four individual regressions range from 1.01065 to 1.02208; wrapper Clang has none
in that set. A separate five-round, matched 20-by-65,536-cell comparison gives
compact/general QBE 0.85309 times the preserved production-Clang binary. That is
a direct fresh denominator, not a product of historical ratios. These are
finite worker-kernel results, not full-compiler speedups. The root's final
selected general Take/rebuild, wrapper spare, and delayed overlap/rebuild/spare
probes all passed; this audit adds no target execution.

## Post-selection ordinary-call diagnostic

Actual source transfer exposed a separate cost: every ordinary recursive
`Base.String.append` invocation calls both checked runtime pointer accessors,
while reverse amortizes them across its tail loop. The additive
`context-calls/` facade prepares two private ABIs behind unchanged checked
public wrappers: forwarding the stable heap/allocator pointers, or loading
them from authenticated context offsets. The original owning graph and its
certificate stay intact. Only closed worker calls are renamed; exact full
machine regeneration covers pointer order, function bodies and exports.

Both forms retain initial context validation. Runtime source review establishes
stable bases within one synchronous single-thread context and requires scratch
exhaustion before internal calls. The direct-load form adds assertion-only
runtime layout checks and uses alias-safe pointer representation reads in its
C emitter. This is a distinct diagnostic after frozen selection, with no
heldout-based policy replacement. Final `context-source07` and
`context-admission07` pass seven exact source/runtime refusals. The root's API07
and emission04 pass 31 Bend controls, nine exact emissions and 54 malformed
certificate refusals. Earlier affine-binding, annotation and comparator-match
failures remain preserved. The exact full-codepoint comparator lowers to a
host loop with `continue`, avoiding the generic equality's stack overflow on
large serialized graphs without weakening equality.

[The final context machine audit](evidence/machine08-analysis.md) pins all 18
successful worker executables. Both variants remove two getter callsites from
each recursive String.append body while preserving both getters in the public
wrapper. QBE threaded forwarding grows the private body from 548 to 568 bytes
and adds a spill site; authenticated context loads shrink it to 522 bytes with
the original three-argument recursive ABI. Clang shows the same direction for
code size and stack use. All 234 original semantic observations pass. Across
five paired rounds, QBE threaded/context medians are 0.904/0.884 on shared512 and
0.850/0.857 on unique1024, versus the same compact/general baseline. Clang
medians are 0.882/0.907 and 0.834/0.843. These reused-case diagnostics do not
change selection or imply direct fused/production comparisons. The first
Clang header failure is preserved; the successful runner pins the same added
standard include directory for every Clang mode. Full premises and replay
instructions are recorded in `context-calls/README.md`.

The separate synthetic wide gate passes all six builds and 24 ownership
observations. [Its offline audit](evidence/machine09-wide-analysis.md) confirms
the public nine-argument ABI in both backends and actual eleven-argument
private forwarding in QBE, including five stack slots. Clang eliminates the
unused borrowed pointers and hoists the returned final owner, leaving an
eight-argument private call despite disabled inlining. Its eleven-argument
machine behavior is therefore not claimed. This ABI witness has no timing
measurements and does not change the selected native image.
