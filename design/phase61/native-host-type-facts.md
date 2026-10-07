# Native scalar facts for host type analysis

The state04 MapSet profile attributes much of the remaining normalization,
substitution and type-key serialization to host marshalling analysis. The
classifier repeatedly expands native U32/F32 through their Word(32) constructor
graphs. Pinned TypeScript `comp.ts::js_marshal` treats these WORDS types as
Nat-free leaves. The current Bend classifier only stops at native Nat.

In `state04-b2-latency01/cpu-map-numeric01`, the Map count view places 476 of
1,728 samples under `jd_host_nat_status` (27.55%, inclusive). The allocation
profile's same ancestor has 54.65% of 586,671,136 sampled bytes. These overlapping
CPU/allocation shares are diagnostic opportunity, not removable fractions or
predicted speedup. In particular, not all remaining `subst` cost is checking.

## Proposed implementation

`back/js/direct/host-native.bend` prepares two facts once at `jd_exports` entry.
An owner must be a native ADT with zero arity/templates. The unchanged public
`jd_host_nat_status` must return zero for that owner's closed U32/F32 type with
the existing 1,024-visit bound. Positive and unknown results refuse the fact.
This is a proof using the actual immutable book, not an assumption from its name.

The resulting flags are installed in an immutable analysis-only KDef under
`$JD.Host.NativeWord`. Preparation always overwrites this fact, including zero
on failure. Source names cannot begin with `$` (`front/validate.bend::f_valid_name`).
The selected definition list is unchanged, so the fact is never emitted/exported.
Only the export traversal receives the prepared context. Other callers without
the fact use the original classifier.

Three internal host queries use the new bounded walker. A proved U32/F32 is a
leaf only when the actual normalized ADT also has no arguments. All other
traversal, erasure, native Nat detection and specialization rules remain. The
original public classifier and the marshalling depth bound of 64 stay unchanged.
There is no mutable host cache or cross-request state.

## Deliberate resource-policy change

The internal walker still charges a maximum of 1,024 visited nodes, but proved
native leaves no longer charge their hidden Word graph. Therefore some valid
graphs that previously exhausted the implementation budget can now complete.
This admission expansion is authorized and tested explicitly; it is not claimed
to preserve the old refusal set. It cannot justify dropping a required Nat
conversion. A proof-budget failure itself falls back to the old traversal.

## Falsification and qualification

The focused controller uses genuine old/new checked B1 APIs and freshly checked
Base. It retains eight exact host-wrapper and runtime-event cases, including Nat
results, callbacks, Array restoration, recursive no-Nat types and aggregate
budget fallback. Further controls reject fake/native-positive, missing, wrong-kind,
parameterized and budget-unknown proofs; verify forged-fact replacement and actual
type argument checks; and distinguish public budget parity from internal admission.

After static review: checked source build, focused controls, complete saved output
comparison, genuine B2 generation/ordinary-driver qualification, and the unchanged
Numeric/MapSet/raytrace request screen. Broad semantic and held-out gates remain
necessary before selection. No source build, runtime benefit or promotion is
claimed by this design checkpoint.
