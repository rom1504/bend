# Phase189: direct-object x86 default

Direct ELF objects become the default for public x86 executable builds and
`--run`. Explicit `.s` output still emits assembly. The shared typed instruction
implementation remains Bend; the object route skips the external assembler and
retains the authenticated runtime and linker.

[Design](../../design/phase189/README.md) ·
[Usage](../../docs/self_hosted/x86-objects.md) ·
[Reproduction](../../selfhost/tests/phase189/README.md) · [Evidence](evidence.json).

## Scope and identities

This is qualification and release integration of the Phase188 compiler, not a
new optimization. No compiler algorithm or runtime source changes. JS, C and
QBE installed components retain their exact previous artifacts and source
identities. The x86 component has its own authenticated source profile.

The selected candidate is the actual object-built N2:
`942b88c7f3049113ddeb9a3e6d2f502c73c36675508f42a3652ced53da3ae098`.
Its checked source is
`83e9714d63565fee22f7daec69f1c71779000dc8e59674588d66e52522cb7ae2`.

The genuine chain is a qualified Phase186 QBE N2 producing x86 N1, then N1
producing object-built N2, then that N2 producing N3. N3 completed in 331.693s
and emitted exactly the 30, 141,784-byte object that produced N2:
`05d00d3fc98df1ad88346df437e7a142b8e15d455d6221df166dd4759c8bd3d3`.
No generation is relabeled to fit the older assembly-only release chain.
This fixed point establishes reproduction, not whole-compiler correctness.

## Interface and compatibility

The public launcher reads the qualified release's `defaultEmission` and requires
agreement with the operational assets. Missing metadata preserves the older
assembly default, including rollback. Unknown or mismatched values refuse.

The maintained executable builder defaults x86 source builds to objects.
`--emit assembly`, assembly IR input and typed assembly references retain the
assembly route. Raw `request.py` emission and the generic bootstrap adapter keep
their existing assembly default; `--emit object` selects the binary contract.
The generic object's final O3 emission is distinct from the actual executable
N3 built for this release. Binary bytes are never decoded as assembly text.

The finite qualifier supports explicit object emission with the same catalog,
whole-output oracles and stage-specific refusals. Bench acquisition retains its
explicit assembly products; machine profiling can sample the linked ELF from
either format. Assembly owner maps need `--emit assembly --retain-ir`.

## Validation and publication

All 64 cases pass through actual N2 direct-object emission: 61 exact-output
executions and three stage-specific refusals, zero unsupported cases (109.821s).
All ten current runtime controls pass (12.131s). These builds omit `--emit` and
therefore also verify the executable builder's new default. The qualification
uses a frozen asset manifest; publication does not invalidate its recorded inputs.

The independently reviewed release audit passes, and the transactional install
and operational-map publication both completed. Installed x86 N2 is now the
candidate above, with `defaultEmission: object`. All three other component
records remain exactly unchanged. Their old canonical source bytes are retained
as an authenticated installed snapshot; they are not rebound to today's source.

139 metadata/transport controls pass: 68 build/gate cases, 18 Python public
controls, 14 JS launcher controls and 39 release/preparation/rollback controls.
These are separate from the real target executions. The review caught and fixed
an admission gap: matching summary fields alone no longer qualify a native
generation without the corresponding successful actual compiler job. Missing,
mismatched and timed-out jobs are rejected; the real receipts already satisfy
the stronger checks.

All 14 installed public controls pass: explicit assembly plus independent link,
ELF, `--run`, argv, both launchers, ordinary C/JS, type rejection, no-overwrite
and symlink refusal. Temporary public build products are cleaned.

N2 and N3 complete objects are identical. Their linked ELFs differ in symbol
metadata and GNU build-id; all other file-backed sections, including `.text`,
`.data` and `.rodata`, match. No whole-ELF identity is claimed.

Rollback files remain under `selfhost/build/phase189/install01`, with the exact
old operational maps retained by preparation/publication. The previous Phase183
x86 image remains available. Verified retention recovered 1,035,546,624 bytes
before the target gates: only archived generated texts were pruned, and one
identical assembly pair was hardlinked. Images, objects, sources, receipts and
installed/rollback artifacts were preserved; the shared lock was not replaced.

## Performance boundary

No fresh generated-program speedup is claimed. Phase188 already showed all 45
assembly objects and all 90 linked code/data products equal their Phase187
counterparts. Its same-source direct-object build improved 315.348→205.019s,
but was still 1.039× assembly's 197.400s. This release chooses the native Bend
object path and removes the assembler dependency for executable construction;
it does not claim that this default is faster on every workload.

N3's 331.693s is execution by object-built N2, whereas Phase188's 208.552s N2
acquisition used QBE-built N1. These different producer architectures must not
be reported as a same-compiler timing regression.
