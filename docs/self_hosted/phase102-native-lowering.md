# Phase102 experimental native lowering

Phase102 explores four composable C-backend mechanisms in the compiler written
in Bend. Source profiles remain separate from the installed Phase98 native
release and the installed JS release. A checked testing API, an acquired native
B1 binary, and an admitted B1/B2 release are different qualification levels;
consult the [phase report](../../implementation/phase102/README.md) for the
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

The selected construction candidate also keeps at most one uniquely taken heap
cell per private worker, reusing it only for the same allocation class. Static
cells and shared roots are excluded; unused cells are freed on success or failure.
Ordinary matching and constructor stores retain their previous behavior. The
helpers are emitted only when a ready TRMC worker exists. A separate measured
policy raises the existing forced-inlining source budget from4KiB to8KiB;
compiler-image build cost is checked separately from program runtime.

The observer bridge keeps original owned roots alive while a proven observer
borrows them. Its owning adapter returns the original result contract. For
example, comparison need not rebuild strings merely to return those strings
with an ordering result. The ordinary worker then depends on this admitted
adapter, allowing callers to enter the existing ready closure. Missing early
observer metadata conservatively retains hot ownership handling; it does not
grant a new cold-constructor certificate.

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

Root can package the final selected experimental recipe with fresh paths:

```sh
python3 -B selfhost/tools/performance/phase102/package-source-profile.py \
  --recipe selfhost/build/phase102/trmc-reuse-source02/changes.json \
  --out selfhost/tools/native/profiles/phase102-lowering01 \
  --verification-out selfhost/build/phase102/profile-replay01 \
  --name phase102-lowering01
```

The packager verifies parent/capsule/recipe identities, emits a deterministic
`changes.zip`, records parent pins, then invokes the unchanged source-only
replayer and compares the complete result to the candidate. Its verification
receipt is not a compiler build or semantic qualification.

Once that named profile exists, replay it independently:

```sh
python3 -B selfhost/tools/native/profile.py \
  --profile selfhost/tools/native/profiles/phase102-lowering01/profile.json \
  --out-source /tmp/compiler-phase102.bend \
  --receipt /tmp/compiler-phase102-replay.json
```

These commands never change `selection.json`, the default profile, or the
installed compiler. Native qualification must separately bind exact source,
upstream-built B1, self-built B2, generated-program behavior and resource limits.
The [modular integration plan](../../implementation/phase102/modular-integration-plan.md)
records how to migrate the mechanisms while preserving the existing native
NC_Text, permission and ownership prerequisites.
