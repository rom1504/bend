# Cold constructor reconstruction and compatible storage reuse

This lane prepares source/data only. No Bend compiler, Clang or native program
was executed by the lane. Root owns the serial guarded target lane.

Registration: [P69-005](../../../../../experiments/phase69/P69-005-node-reuse.md).
Predecessors: P68-015 measured about 3% tree benefit from two lexical spares;
P68-018 measured about 8% from a runtime predicate omitting selected value seals.
The present experiment differs by removing seals **at known cold parent
construction sites**, avoiding that predicate, and combining with reuse.

## Saved-C preparation

From repository root:

```sh
taskset -c 0 python3 selfhost/tools/performance/phase69/node-reuse/prepare.py \
  --out selfhost/build/phase69/node-reuse-prep01
```

The completed preparation has four arms, all with `BANGS 0` so root should
compare them against the same sequential-mode control:

- `mode_only.c`: one mode edit, otherwise exact checked compiler23 source.
- `reuse.c`: keep the two storage locations consumed in the two-Node zipper;
  reuse them for the two inner Node results.
- `cold.c`: remove 26 eager seals at all 13 generated Node construction sites.
- `cold_reuse.c`: combine the two independently identified mechanisms.

The plan binds the original checked emission, source and native toolchain,
hypothesis, producer and every literal before/after edit. Reverse replay checks
that every arm recovers the exact original source bytes. Runtime helpers,
function entry and error polling, field keeps/drops, branches, scheduler ABI and
evaluation order remain unchanged. The producer recognizes names only to select
an explicit diagnostic site; the proposed compiler rule has no fixture names.

Original C contains two-level work: ordinary native workers and device/scheduler
fallback bodies. All 13 matched Node sites receive cold stores; only the hot
host zipper receives local spare reuse. Therefore CPU timing does not qualify
GPU behavior. No measured speedup is recorded in this lane until root executes
and records its independent comparison.

## Ownership argument and limits

`ctr_take` is unchanged. Its unwrapped case moves fields and returns the node's
storage. Its RFC case returns storage only when its owning reference is last;
otherwise it increments retained field references, drops one parent reference
and returns zero. Static locations are below `HEAP_OFF`. Reuse tests
`spare >= HEAP_OFF`, so shared and static inputs allocate new storage. The two
parents are fully read before either spare is overwritten. Each spare serves
one compatible two-word allocation. On the first-parent-match/second-miss path,
the retained first spare is freed before the original child drops. Spares are
local to a nonrecursive host worker; no new recursion or long-lived cache exists.

The cold-store arm has a different precondition: the parent constructor must
never be duplicated in the compiled program. It is insufficient that one match
happens to consume a unique parent. A later duplication of a parent containing
unsealed heap fields would break the shared `span_fade` invariant. Thus the raw
compiler and any checked program that duplicates a user value retain seals.
Cold parents can contain independently shared Base values: their values already
carry RFC wrappers created by actual duplication, and plain stores preserve
those wrappers. Dropping or matching an unshared parent simply moves/drops the
existing field ownership.

For the measured tree, `NATIVE_UNSHARED_ARRAYS 1` records the checked no-sharing
certificate. Its proof admits duplicated array-free trusted Base types only;
user types, closures and Base containers containing user types are not admitted
for duplication. Typed arrays also require scalar element layouts. Unknown
foreign/effect and proof-transport cases are excluded. Tree's reachable typed
flow passes owned Trees through functions/Node fields without duplication; the
only user recursive constructor is Node. This is the witness domain, not a
universal proof that the certificate can never have a bug.

Direct-load rewriting is deliberately not included. `ctr_take` already has the
ordinary no-RFC field-copy fast path; changing it would add another assumption
while measuring almost the same machine operation. Cold stores and reuse can
be tested without weakening that fallback.

## Small proposed compiler integration

`cold-constructors.patch` is a **prepared, untested, unapplied** Bend patch. It
adds one 11-line helper in the existing emitter and one checked-prefix macro,
reusing the existing no-sharing analysis result. Non-Base constructor identity
comes from `nc_ctor_identity`, not user spelling. Under
`NATIVE_COLD_USER_CTORS 1`, such parents emit plain fields; raw emission or
failed checked admission emits ordinary seals. Base constructors, closures and
tasks remain unchanged. Conditional preprocessor output has no runtime tag
predicate. No production lexical spare analysis is proposed until that arm
proves enough additional value to justify lifetime/fallback complexity.

The patch overlaps potential static-data emitter work. Root should adapt the
small constructor-node call sites and checked prefix after independently
reviewing the certificate. `patch-plan.json` pins its before/after source bytes.
Never apply it just because the saved-C benchmark becomes faster.

## Independent controls to run before promotion

Prepared Bend fixtures have independent arithmetic/string goldens:

- `fixtures/unique-rotation.bend`: a differently named recursive type and rotation,
  expected `26n`; cold user admission is expected.
- `fixtures/shared-user-refusal.bend`: consume a duplicated nested parent twice,
  expected `30n`; cold macro must be zero.
- `fixtures/shared-base-inside-cold.bend`: two distinct cold wrappers contain a
  duplicated dynamically produced String, expected `14n`; verifies that plain
  parent stores retain preexisting field RFC ownership.

These fixtures are prepared, not parsed/checked/executed here. Add existing raw
wrong-tag/error-order controls, shared closure/captured-user refusal and custom
Base identity tests. For spare reuse also check shared parent, static parent,
one mismatched branch and two mismatched branches. A static address may be read
but must never be overwritten or added to the free list. Full release/native
conformance remains root's separate integration decision.

## Typed private worker follow-up

[P69-008](../../../../../experiments/phase69/P69-008-typed-native-worker-parameters.md)
registers a second causal probe after root measured the cold/reuse arms.
`prepare-typed.py` prepares three signature-only derivatives; the existing
cold-only derivative is their primary baseline. `typed-worker-tree-prep01`
binds their exact edits and parent hashes. Only the C formal types of U32/Bool
arguments in two private workers change, preserving bodies and callers.

The [typed-worker design](../../../../../design/phase69/typed-native-worker-parameters.md)
explains the generic implementation. `typed-worker-candidate-v2/source.patch`
is the current **unapplied, unchecked** source proposal (+53 Bend lines).
It stores existing `N_Param` records in `NF_Worker` after lowering, keeping
`NC_Binding` unchanged in the ownership environment. Whole source live arity and
expanded field count must agree; mismatches retain generic signatures. Only
checked safe-layout/effect permission enables the generated C `NF_SCALAR=u32`
macro; raw code uses Term. The original v1 proposal and exact producer versions
remain preserved to avoid silently replacing inputs already reviewed.

Additional prepared controls (not executed by this lane):

- `scalar-and-large-nat.bend`: U32 maximum plus a Nat above 2^32, expected
  `8589934606n`; Nat must remain 64-bit.
- `tagged-user-enum.bend`: user enum tags must remain full Terms, expected `10n`.
- `scalar-widening.bend`: U32-to-Nat addition and multiplication must widen before
  arithmetic, while U32 addition must still wrap; expected `12884901887n`.
  This specifically checks C integer-promotion effects from narrowed formals.

Reviewer boundaries also include F32 bit/NaN preservation, Char range, erased
binder alignment, dependent/opaque arguments, expanded product slots, raw
high-bit values and tagged raw Bool fallback. Reuse remains only the saved-C
experiment and the [scoped-spare design](../../../../../design/phase69/scoped-native-spares.md).
