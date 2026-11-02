# Phase152 evidence and replay

`phase152.tar.gz` contains 1,862 exact payloads. `capsule.json` records size and
SHA256 for every payload and 1,256 byte-identical aliases. Archive size is
15,789,935 bytes, SHA256
`4823d475a3124ba302464bc1c2d69d1cd9a83ef08ad5a5cdc537b82188633621`.
Every member was decompressed and verified; an independent read-only audit
repeated archive, member, alias and qualification-pin verification successfully.

Included are frozen small source assemblies, selector/control inputs, complete
small QBE and assembly products, raw timing/output reports, process guards,
negative results, closed-run receipts, and both old/corrected host methods.
The full compiler source is included and deduplicated. Files above 5 MiB,
executables, objects, large generated APIs, the complete compiler's QBE/assembly,
and external runtime/toolchain assets are not embedded. These remain in explicit
hot locations or verified local retention under `selfhost/build-retention/phase152/`.
The capsule is reproducible evidence, not a standalone compiler toolchain.

Extract into an empty isolated scratch directory, never over live build roots.
Check the archive and every member against `capsule.json`, then restore needed
alias paths by copying their recorded payload bytes. An alias's `payload` names
the stored member, not an external download. Source/recipe/image pins are also
in [qualification.json](../qualification.json). Reacquire unavailable large
assets with the pinned toolchain and independently qualify them; do not substitute
an arbitrary installed compiler.

## Replay order

1. Read the frozen `*-guard/process.json` command, limits and resource observations,
   followed by each referenced build/report manifest. Keep exact sources, Base,
   runtime, QBE and machine-tool identities. Every new invocation uses a fresh
   run root under the maintained disk/process guard; the recorded output roots
   are immutable evidence, not destinations for a replay.
2. For the narrow experiment, use the frozen reference/candidate source recipes
   and checked APIs. `controls-api02` / `controls-run01` execute 66 finite rows.
   The Phase151 frozen `probe-source02/probe.bend` preserves its original dispatch
   references; current maintained dispatch definitions already contain the
   candidate and cannot serve as the old comparator.
3. Native witness acquisition uses `baseline-dispatch01` and `candidate-dispatch01`
   sources/products and their exact commands. Timing uses the retained 20-million
   call, seed4294967290 schedule and complete observations. Reuse the safe usage
   and unrelated search witnesses as independent transfer controls.
4. `composite01/compiler.bend` is the integrated qualified source. Maintained
   source transport produces the same bytes. `composite-api01` records the
   independent checked hosted acquisition. Native generation commands in
   `native-n1`, `native-n2`, `native-n3` use respectively the pinned Phase147 N2,
   new N1 and new N2. Their build receipts include complete product hashes.
   Compare QBE/assembly/objects; the ELF files are not identical.
5. Qualification uses `n1-focused`, `n2-all`, `hosted-js-focused` and
   `hosted-c-focused02`. Preserve the failed older/newer C-route observations;
   the corrected adapter is required for the successful C route. These ordinary
   gates do not imply full language, parallel/GPU or new kernel-proof coverage.
6. `compiler-fixed.manifest.json` and `compiler-bench01` bind four balanced request
   rounds. `programs45-fixed.manifest.json` and `programs45-bench02` bind the broad
   two-round scale1 run. `programs-resolution01` repeats only the four unresolved
   fast points plus the zero control at scale64. The combined 44-point ratio is
   explicitly derived in [metrics.json](../metrics.json); the initial report's
   low-resolution aggregate stays incomplete. Do not fabricate a uniform-scale
   aggregate or reuse manifests after changing a consumed method.
7. `program-qbe-identity.json` records all 45 unchanged QBE/assembly/object products.
   For future changes, compare complete emission before repeating machine builds
   and timing. Exact unchanged products are preservation evidence, not new timing
   samples. The checked API is the economical early transformation loop.

The three promoted standalone modules are retained as direct archive members:

- `selfhost/tests/phase150/lexer-candidate.bend` (12,276 bytes).
- `selfhost/tests/phase151/dispatch-candidates.bend` (1,789 bytes).
- `selfhost/tests/phase152/prepared-constants.bend` (5,205 bytes).

All three also recover from Git `75bc607`; their exact archive bytes were verified
against working copies before retirement. Production now owns the implementation
in its five maintained modules. Controls and probe consumers remain source files.
Historical reference dependencies recover from Git `0bdc7f0` or the frozen phase
assemblies. Their old manifests describe historical experiments, not today's
compiler assembly recipe.

[Cost](../cost.json) records all 51 guarded jobs, including failed attempts.
[Retention](../retention.json) records their completed closure without pruning.
The independent verifier found no missing/extra/duplicate archive members, and
all 18 qualification pin references matched disk (17 unique files).
