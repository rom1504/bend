# Consuming one constructor field: bounded source audit

No maintained QBE runtime operation combines a constructor take with selecting
one escaping field and dropping the others. `p111_rt_take` and the constant-arity
`p125_rt_takeN` retain every child of a shared parent. `p118_rt_borrow_fields`
and its `p128bf_*` renderer template only copy borrowed views: their original
owned root must remain live. They cannot replace a consuming projection.

This began as a proposal and offline census. A private saved-IR ceiling pilot is
now prepared below; the maintained compiler/runtime and installed image are
unchanged. This lane has executed no compiler or native targets.

## Actual generic opportunity

The fresh N2 profile's getter assembly inspection is backed by a retained real
checker product. `projection-census.json` pins that complete QBE file and the
offline census method. It finds **86 terminal projection-shaped branches in
69 functions**, across arities2–9;83 have at least one explicit sink. Every
observed sink list is in increasing field order. These are static shapes, not
dynamic counts or semantic admission decisions.

For example, the `tg` KTerm branch takes8 fields, sinks1,4,5 and returns0.
Fields2,3,6,7 are already scalar and have no sink. The `nm` KTerm/KLambda/KLiteral
branches all return one loaded field. The `dn` and `dk` KDef branches each take9,
sink all eight unselected fields and return one. Constant-return branches are
deliberately outside the initial pattern. Names are examples only; matching
must use the actual checked operation sequence.

The smallest general admission is a terminal case body containing exactly:

1. One ordinary constructor take with a known bounded arity and scratch buffer.
2. Its complete, distinct field loads at exact eight-byte offsets.
3. An ordered subset of distinct field sinks, with no other observable work.
4. A return of exactly one loaded field, never one of the sunk fields.

Every unsunk/unreturned field must have an existing scalar/triviality certificate;
the runtime can additionally require that its actual representation is trivial
and non-RFC. Reject duplicate sinks, stale/reused locals, intervening calls,
stores, special Array/Word/Nat take operations, dynamic indices, extra return
values or escaping scratch addresses. Preserve the original constructor test
and fallback branches. A raw textual resemblance is insufficient admission.

An initial private import could take `(state,parent,count,index,drop_mask)` with
count≤32 and the mask encoding the verified increasing sink order. It consumes
the parent and returns an owning Term. The IR verifier/import signature must
state that ownership contract; it is not the existing borrowed-read signature.
The compiler recognizer and verifier remain Bend code. A host-side saved-QBE
rewrite is acceptable only as a clearly labeled ceiling experiment.

## Runtime equivalence and the necessary refusal path

For a valid shared parent, the original path bumps every child, drops one parent
reference, and then sinks the unused owning children. Most child bumps and sinks
cancel. A fast path can instead retain the escaping child and release the parent,
but **blind cancellation is incorrect**: an unused child can overflow during the
original temporary bump, or be an unsealed nontrivial child. Either produces an
error before the original sinks. The transformed operation must preserve that.

Start with the already admitted single-mutator host runtime only. Before any
mutation, retain the original arity/tag checks and require:

- A nontrivial RFC constructor parent with current count>1. Unique raw parents,
  RFC count1, static parents and packed forms use the complete original path.
- Every child is either non-RFC/trivial or a nontrivial RFC child with positive
  count. Unsealed children, malformed zero counts and RFC-tagged trivial words
  decline to the original path without mutation.
- For every RFC child, its current count is at most
  `RFC_CNT - count - 1`. With at most `count` aliases among the fields, this
  conservatively proves that every original temporary bump succeeds. It avoids
  an O(n²) alias census. Near-overflow cases run the exact original sequence,
  including its first error and preceding mutations.
- Every omitted scalar field actually is non-RFC/trivial. Otherwise fall back:
  the original does not sink that field, so arbitrary RFC payloads cannot be
  canceled as though a sink existed.

Once these checks pass, keep the selected child once and drop the original parent
once. The parent remains live, so no unselected child can be freed. Repeated
child aliases have the same final counts: all canceled bump/sink pairs disappear
and the selected owned result adds exactly one reference. The same reasoning
allows a child alias of the parent while it remains shared, though well-formed
compiler Data is acyclic. The conservative high-count refusal covers that alias
in the overflow argument as well.

The preflight still reads every child and its RFC header. It saves scratch copies,
unneeded reference-count writes, sinks and call plumbing; it does **not** eliminate
all pointer-chasing cost. Multiworker/device/atomic modes must retain the original
operation: a preflight count bound is not stable under concurrent increments.
Allocation, publication, serial-provider authority and unique-parent destruction
stay unchanged. Errors cannot be weakened merely because malformed states are
uncommon in checked programs.

The fallback must reproduce the original take, all loads, exact ordered sinks and
selected result; invoking only `term_sink(parent)` would wrongly consume the
selected child on a unique parent. Arity/type failures must retain original
diagnostic ordering. The first implementation should share the original runtime
checks and avoid inventing a broader unchecked projection API.

## What the existing profile supports

The accepted N2 full-request capture has5,484 samples,99.35% process-CPU coverage,
zero loss and4.58% unresolved leaves. Constructor-take leaves account for10.98%,
sink leaves4.01%, and drop/fade leaves18.34%. Their disjoint physical union is
**33.33%**, a very loose envelope containing many unrelated consumers and necessary
work. It is not a projection saving forecast. Take+sink alone totals14.99%.

No current caller attribution says what fraction belongs to these86 static
branches, and preflight preserves some of that work. Therefore there is no
defensible measured whole-request gain yet. As arithmetic sensitivity only,
removing one quarter of the14.99% take+sink envelope would save3.75% of request
CPU; removing half would save7.49%. Neither fraction has been observed. Earlier
5–12% suggestions are hypotheses conditional on caller cost, not estimates
established by this profile. Do not scale diagnostic seconds onto clean clocks.

## Cheapest useful ceiling experiment

Reuse the real nonempty checker from `checker-workload.md`, not a repeated getter
microbenchmark. It performs320 real load/check operations on10 varied fixtures;
its full parsed books and complete checking values have independent frozen
reference controls. The32-round execution oracle is
`[320,192,128,0,10464,2377378021,2469680293]`. The complete-value gate remains
necessary because that timed digest alone is not collision-free.

1. Freeze the existing `checker-baseline01/program.ssa`, its machine/runtime
   receipts and independent oracle. Use the identical method/runtime/toolchain
   on both arms. The candidate-selected checker SSA is not retained, so begin
   with the explicitly pinned existing baseline product rather than silently
   substitute a different generated program.
2. Prepare one private runtime helper plus a conservative saved-IR substitution
   for the eligible terminal branches. First require an exact branch manifest
   and an inverse replay to the original SSA. No function-name whitelist.
   Preserve ignored branches and untouched definitions byte-for-byte. This
   prototype measures opportunity, not compiler-pass correctness.
3. Reuse the controlled C runtime differential approach only with valid ordinary
   published states: unique, shared, static, packed and duplicate-child cases.
   Compare complete arena/allocator state and literal result values, and require
   disabled/atomic behavior to remain exact. The earlier draft proposed failure
   probes; that conflicts with STEERING and is withdrawn. Unsealed, zero-count,
   near-overflow and first-error obligations are structural reviews only. Do not
   execute malformed runtime bodies or custom failure probes.
4. Root builds the small runtime and two checker objects under the existing
   serial CPU3 guard, then runs four balanced pairs with complete stdout/stderr
   gates. Compilation is separate from execution timing. Fresh processes charge
   startup and teardown. Reuse the existing64-round source only if the frozen32
   workload is below the timing floor; do not change rounds after seeing ratios.
5. If that actual checker is neutral, stop. If it materially improves, apply the
   same structural experiment to the current compiler's retained IR, or first
   acquire an explicitly pinned copy if unavailable. One exact full-source QBE
   request plus the existing real verifier point tests transfer before a proper
   Bend lowering pass is integrated. The getter-only result cannot justify a
   whole-compiler claim.

Optional counters may report shared/unique/refused calls and skipped child
bumps/sinks by shape. Keep their timings diagnostic. The important falsifier is
the complete real computation with preserved owning behavior and exact fallback,
not an isolated field-load instruction count.

## Prepared private ceiling pilot

`tools/prepare-projection.py` creates a fresh source-only package from the exact
retained checker IR and machine receipt. It authenticates all input hashes and
selects84 of the86 structural branches. The other two fail its additional
whole-function scratch-buffer nonescape check. Every selected branch starts with
the complete ordinary take, has all exact field loads, sinks only distinct fields
in increasing order and returns one unsunk field. No other branch operation is
allowed. The scratch buffer must be a private2048-byte stack allocation whose
address is used only by recognized take/load/address operations.

The original constructor guards and all untouched code remain exact. The private
helper gets six arguments: state, parent, arity, selected index, sink mask and
original take kind. The last argument preserves the original generic versus
fixed-arity fallback, including its checks. All candidate literals are bounded
and recorded in `edits.json`; unsunk scalar fields also face the runtime trivial
guard before fast-path cancellation. This is still a host-side measurement
substitution, not a qualified Bend compiler pass.

The source package is `selfhost/build/phase169/projection-source01/plan.json`.
Its candidate39,879,316-byte IR has SHA256
`cd02d63ba3c4f89ae3d69f71c09cc2e9936aeef7d606a2bc7e06e7aeba1bab29`.
`projection-replay.json` independently replays the inverse from that actual file,
checking every replacement and unchanged gap against the original SHA256
`d55e0c88d43d279e112c6371bb67b92c72aade8824a52704c11713b044350281`.
The maintained runtime is copied unchanged and the55-line private helper appended.

`tools/projection-controls.c` builds all dynamic objects through ordinary runtime
constructor/seal/keep APIs in a pristine bounded arena. Four actual projection
shapes, three ownership states and duplicated/distinct children give24 cases.
Each compares the entire8192-word arena/allocator state before and after retained
root consumption, and checks the selected child's literal payload. Static and
packed ordinary forms are additional controls. There are no failure-target cases,
forged reference counts, unsafe generated bodies or custom signal/error handlers.

Root's command inside one maintained resource guard is:

```sh
python3 -B experiments/phase169/tools/run-projection.py \
  --plan selfhost/build/phase169/projection-source01/plan.json \
  --out selfhost/build/phase169/projection-run01
```

Suggested budget:120seconds,1GiB memory,256MiB fresh disk, serial CPU3. The runner
first builds/runs the valid controls for serial/atomic modes with the fast flag
off/on, then requires atomic binary identity. It compiles the transformed checker
IR once and links helper-disabled and helper-enabled variants. Four alternating
three-arm rounds compare the existing original checker, the ABI-only rewrite and
the fast rewrite, with the exact independent320-case stdout and empty stderr.
All inputs are reverified afterward; complete receipts survive failure. No result
is yet claimed. The proposed helper plus structural rewrite is bounded; this is
not a new compiler image campaign or profiling framework.

## Source anchors

- `selfhost/src/runtime/qbe/runtime.c:919`: `rfc_bump` checks after increment.
- `selfhost/src/runtime/qbe/runtime.c:1061`: `span_fade` retains every field before
  releasing the parent; `ctr_take` keeps its unique-parent transfer distinct.
- `selfhost/src/runtime/qbe/runtime.c:3951`: ordinary checked take ABI.
- `selfhost/src/runtime/qbe/runtime.c:4665`: existing borrowed-field operation.
- `selfhost/src/back/qbe/lower.bend:451`: complete field take/load construction.
- `selfhost/src/back/qbe/direct-lower.bend:539`: scalar field-kind refinement.
- `selfhost/src/back/qbe/borrowed-regions.bend:985`: existing independently bounded
  borrowed-field template, useful structure but a different ownership contract.
- `native-profile-findings.json`: exact current capture and machine pins.
- `projection-census.json`: real checker IR pin and all86 structural candidates.
