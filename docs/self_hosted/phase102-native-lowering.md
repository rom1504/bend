# Phase102 native lowering

Phase102 implements composable C-backend mechanisms in the compiler written
in Bend. Corrected candidate04 is the native default; the installed JS release
remains separate. A checked testing API, an acquired native
B1 binary, and an admitted B1/B2 release are different qualification levels;
consult the [promotion report](../../implementation/phase102/default-promotion.md) for the
actual evidence and selected candidate.

| Mechanism | What it removes | Admission and fallback |
| --- | --- | --- |
| Saturated selector specialization | Allocation of literal branch closures around small selector functions | Only bounded closed selector syntax, saturated calls, safe literal usage and fresh variables. Nonliteral arguments retain ordered evaluation. Other calls use ordinary lowering. |
| Tail recursion modulo constructor (TRMC) | A saved continuation per element while building lists, strings or ordinary boxed data | Retry the existing non-tail-self refusal only; the recursive call must be the final constructor field. Constructor prefix fields and recursive arguments retain their original order. Unsupported forms retain scheduler lowering. |
| Owning-observer forwarding | Reconstruction-only dependency cycles that prevented a caller from becoming a direct C worker | Reuse an already admitted borrowed observer and its owning result adapter. Existing root/schema/residual checks, private-name freshness and scalar fallback policy remain. Ordinary dependency admission runs again; mutual C recursion is not enabled. |
| Scoped local worker calls | Scheduler continuation frames around already admitted ordinary callees | Only exact request-local checked permission, saturated calls and an admitted boxed-result worker. Argument ownership uses the existing local-value rules. This permission does not grant packed arrays, scalar narrowing or factory omission. |

TRMC builds a private root with one outstanding final-field slot. Its public
wrapper returns the same ordinary one-Term result; partial construction never
escapes and the wrapper releases it on failure. The representation remains the
existing linked constructors. The String-specific append intrinsic and Phase101
chunk-storage experiment are separate controls, not prerequisites.

The private state has five words: root, pending slot, reusable cell, its allocation
class, and the pending destination's sealing policy. The policy belongs to the
previous parent, not the next child. Both recursive and terminal stores follow
the same cold/HOT conditional as ordinary constructor emission. Mixed-policy
diagnostic controls check the generated preprocessor decisions and complete
outputs; shared roots retain their normal ownership handling.

The selected construction candidate also keeps at most one uniquely taken heap
cell per private worker, reusing it only for the same allocation class. Static
cells and shared roots are excluded; unused cells are freed on success or failure.
Ordinary matching and constructor stores retain their previous behavior. The
helpers are emitted only when a ready TRMC worker exists. A separate measured
policy raises the existing forced-inlining source budget from4KiB to8KiB.
The first unrestricted composition hits the420s native image-build limit. The
successor also limits forced-worker dependency depth: three immutable passes
select small leaves and two caller levels from the final admitted worker graph.
It computes that set once, then shares it across declarations and bodies.
Clang remains free to inline other calls; this is a hint policy, not a bound on
machine-code size. Compiler-image build cost is checked separately from runtime.

The observer bridge keeps original owned roots alive while a proven observer
borrows them. Its owning adapter returns the original result contract. For
example, comparison need not rebuild strings merely to return those strings
with an ordering result. The ordinary worker then depends on this admitted
adapter, allowing callers to enter the existing ready closure. Missing early
observer metadata conservatively retains hot ownership handling; it does not
grant a new cold-constructor certificate.

Candidate03 also composes an owning observer with an immediately
consuming pure projection. A bounded structural certificate must select the
observer schema's exact scalar result, preserve strict evaluation, and prevent
variable capture. It then reuses the existing adapter emitter to compute the
observation and release owned roots without allocating discarded result shells.
Unknown or effectful projections keep ordinary lowering. The checked API and
23 helper controls pass; actual C activation is confirmed in three applications
and five controls. Candidate04 retains both original and replacement dependencies
for inline-cost selection, preventing projection from introducing the forced
hints that slowed candidate03's folds. Its native images have independently
completed qualification; source/API checks and native gates remain distinct evidence.
See the [projection report](../../implementation/phase102/projection-integration.md)
and [default native compiler](NATIVE_PHASE102.md).

Local scheduler calls require checked provider identity and no reachable bangs.
Such requests cannot offload device work, so the compiler marks their scheduler
segments host-only using existing metadata. Raw requests and programs with
reachable bangs retain their prior scheduling path. General CPU parallelism is
distinct from GPU offload and is retained. No GPU qualification or universal
correctness proof follows from finite CPU controls.

## Reproduce source without selecting a compiler

The compact profile composes an exact Phase102 recipe after the authenticated
Phase98 profile. Both replay forward and inversion return exact source bytes;
the original D04 source comes from the already committed baseline capsule.
No generated 1.7 MB compiler source needs to be added to the repository.

The default compiler's source profile is `phase102-lowering04`, including bounded inlining,
observer projection and destination-correct cold stores. `lowering01` preserves
the failed first native B2 build; `lowering02` preserves the semantically admitted
intermediate image with a runtime regression. `lowering03` retains the qualified
checkpoint with fold regressions. The command records how profile04 was made;
use fresh profile/verification names when repeating packaging:

```sh
python3 -B selfhost/tools/performance/phase102/package-source-profile.py \
  --recipe selfhost/build/phase102/projection-cost-source01/changes.json \
  --out selfhost/tools/native/profiles/phase102-lowering04 \
  --verification-out selfhost/build/phase102/profile-replay04 \
  --name phase102-lowering04
```

The packager verifies parent/capsule/recipe identities, emits a deterministic
`changes.zip`, records parent pins, then invokes the unchanged source-only
replayer and compares the complete result to the candidate. Its verification
receipt is not a compiler build or semantic qualification.

Once that named profile exists, replay it independently:

```sh
python3 -B selfhost/tools/native/profile.py \
  --profile selfhost/tools/native/profiles/phase102-lowering04/profile.json \
  --out-source /tmp/compiler-phase102.bend \
  --receipt /tmp/compiler-phase102-replay.json
```

These commands never change `selection.json`, the default profile, or the
installed compiler. Native qualification must separately bind exact source,
upstream-built B1, self-built B2, generated-program behavior and resource limits.
The [modular integration plan](../../implementation/phase102/modular-integration-plan.md)
records how to migrate the mechanisms while preserving the existing native
NC_Text, permission and ownership prerequisites.
