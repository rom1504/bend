# Reproduce Phase164

Use the unchanged maintained workflow and explicit assets described in
[`docs/self_hosted/workflow.md`](../../docs/self_hosted/workflow.md). All target
commands must run inside `selfhost/tools/build-retention/guard.py`, with fresh
guard/artifact roots, the ordinary 5GiB reserve, CPU3, one runtime thread and GPU
off. Exact original commands, limits and input identities are in each capsule
member `*-guard/process.json`. Do not reuse an already populated output directory.

## Sources and selected compiler

Qualified producer: Phase152 N2, SHA256
`d62712958b53ecdbe19998ca54c9184f895b556acc661ad014dae89754b952bd`.
Pinned Base/carrier/runtime and QBE/assembler identities are in each native
request/build receipt. Source assembly is the unchanged
`experiments/phase163/tools/prepare.py`; it authenticates the maintained parent
and refuses protected declaration overrides.

The capsule contains exact prepared `compiler.bend`, exports and manifests for
all candidates, including failures. Restoring a snapshot is preferable when
reproducing an earlier variant: source modules at HEAD represent the final
experiment, not every earlier intermediate. In particular, do not load all
Phase164 Bend files through a wildcard.

The retained mixed native source uses `hybrid-adapter`, `hybrid-lower`,
`hybrid-verify`, `hybrid-entry`, `hybrid-render`, `hybrid-retained` and
`native-entry`, in that order, exporting `main`. The source manifest is
`hybrid-native-source03/manifest.json`. API snapshots add the appropriate
structural controls/aliases and exports recorded in their manifests.

The imports-only API uses `hybrid-imports-only`, `imports-api`,
`hybrid-imports-controls`, and `imports-controls-api`. It calls the original
`p134e_plan`; it must not load the mixed renderer/lowering modules.

## Measurements

1. `tools/lower.mjs` takes candidate API receipt, qualified API receipt, pinned
   Base path, fresh output and explicit native45 names. It reuses one checked
   request for both roles, alternates emission order and records exact QBE.
   `tools/machine.py --emission ... --timing-rounds 2 --out ...` constructs both
   machine products and checks the frozen catalog's complete value/count oracle.
2. `tools/requests.py --emission ... --candidate ... --out ...` runs two reversed
   native source-to-QBE pairs. Each role must match its independent hosted output;
   only blank lines are normalized. It does not require changed code to equal
   the original compiler's QBE.
3. The maintained `native.py` constructs mixed N1 and N2 from the same frozen
   source. `tools/self-emission.py --build <N2 receipt> --out ...` invokes N2 on
   that same source, hashes every output byte and compares with the N1-produced
   stream. This last boundary excludes machine construction.

Tool paths above are under `experiments/phase164/`. Original hot products or
their exact local archives are required where receipts authenticate them.
Method snapshots in the capsule preserve earlier tool hashes where an optional
workload/source-generation parameter was subsequently added.

## Index reconstruction experiment

The two alternative modules are `index-zipper.bend` and
`index-zipper-fused.bend`; load exactly one. Both expose `p164x_insert` without
replacing maintained insertion. The source order is chosen deliberately:

1. Zipper module; optional `zipper-controls.bend`.
2. `selfhost/tests/phase163/direct-runtime.bend`, for complete data consumption.
3. `zipper-workload.bend`, followed by the appropriate explicit main fixture.

The API exports `p164xc_controls/case/edge` and `p164xw_map/run`. Acquire it with
the checked hosted workflow, then run `tools/zipper-controls.mjs` on that receipt.
This compares complete constructor objects and writes independent expected
runtime outputs. Neither host tool implements insertion or optimization.

`tools/zipper-native.py --controls ... --out ...` uses the four explicit source
snapshots ending `source01`; `--source-generation 2` selects the fused `source02`
snapshots. It uses the **qualified baseline compiler for both algorithms**, checks
expected complete stdout during construction and performs four reversed runtime
pairs. The final native controls source additionally exercises all 17 finite
controls, including aliased roots and malformed deep trees. See its ordinary
native build receipt and `zipper-controls.expected`.

The native admission check decodes `_FID_` decimal symbol components (ignore the
trailing underscore). Both emitted images contain ordinary `p113d_*` workers for
`$direct.p164x_walk` and `$direct.p164x_unwind`. Their presence is not a proof
of dynamic call frequency or allocation reuse.

## Evidence and restoration

`evidence/capsule.zip`, inventory and seal preserve exact source, receipts, raw
samples, logs, earlier method versions and final closure authority. Large QBE,
assembly, objects, APIs and ELF bytes are outside this Git capsule, in the local
hot roots or authenticated archives recorded by closure receipts. Four compiler
`.s`/`.o` files were selectively pruned after exact archive verification; restore
them through the recorded archive plan before rerunning a machine audit.
These same-filesystem archives are not off-host backups. Rebuilding from source
does not promise byte-identical historical executables.
