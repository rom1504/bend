# Phase94: proof and native optimization loops

[Report](../../../../implementation/phase94/README.md) ·
[Law and proof](../../../proofs/phase94/README.md) ·
[Summary](evidence02/summary.json) · [Raw archive](evidence02/raw.zip) ·
[Archive manifest](evidence02/archive.json).

The production-connected helper is proved equivalent and locally faster, but
the six-source compilation screen is neutral. This is an isolated experiment,
not an installed compiler. Commands below run from repository root and require
the pinned Phase86/90/92/93 inputs referred to by the receipts. Restore those
through their phase instructions if absent; do not silently use another release.
All output directories must be fresh. Only root runs guarded targets, serially.

## Fast loops with acquired artifacts

```sh
# Source check, elaboration, independent acceptance and false-equality rejection.
python3 -B selfhost/tools/performance/phase94/proof-check.py \
  --out selfhost/build/phase94/proof-NEW

# Three bad helper implementations must fail the frozen Bend law.
python3 -B selfhost/tools/performance/phase94/mutations.py \
  selfhost/build/phase94/mutations-NEW

# About 13 seconds of target time: four helper workloads, calibration and scaling.
python3 -B selfhost/tools/performance/phase94/micro-run.py \
  --out selfhost/build/phase94/micro-NEW --scaling

# About 22 seconds: 24 native compiler pairs, identical complete C required.
python3 -B selfhost/tools/performance/phase94/compiler-compare.py \
  --mode screen --rounds 4 --out selfhost/build/phase94/screen-NEW

# About 39 seconds: candidate C equals all 45 historical native products.
python3 -B selfhost/tools/performance/phase94/compiler-compare.py \
  --mode broad45 --out selfhost/build/phase94/products-NEW
```

These durations exclude setup, file authentication and Python orchestration.
The proof targets occupy about 1.8 seconds combined with a cached kernel.
The micro loop checks independent numerical oracles and retains all pilots,
calibration, timed samples and doubled-count controls. Compiler comparisons
authenticate the same source/cache/providers and equal O2 build flags, require
byte identity of full C outputs, retain paired ordering and recheck input hashes.
`broad45` measures product continuity, not a new program-runtime score.

## Proof foundation and restoration

Use the official [Lean 4.34.0 release](https://github.com/leanprover/lean4/releases/tag/v4.34.0),
Linux x86-64 archive `lean-4.34.0-linux.tar.zst` (580,367,391 bytes), SHA-256:

```text
caaa98356098c85dc0fcbbd28e1ec66f39eb6551829972b752ff20e1286b646b
```

Extract into `selfhost/build/phase94/toolchain/` with executable modes intact.
Keep the matching standard library, shared libraries and `.olean.server` files.
Source and `.ilean` files were omitted from this installation to save space;
all 12,695 retained file identities are in the archived extraction/server-files
manifests. The archive release metadata, failed download and relocation receipts
are preserved. Do not rerun disk deduplication as a proof prerequisite.

The proof runner uses the unchanged `bend2/bendtt.lean`, copied to
`selfhost/build/phase94/kernel/BendTT.lean`. It was compiled once using:

```sh
python3 -B selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase94/kernel-build-NEW \
  --seconds 180 --rss-mib 2048 --available-mib 4096 --cpu 3 -- \
  env LEAN_STACK_SIZE_KB=4096 \
  selfhost/build/phase94/toolchain/lean-4.34.0-linux/bin/lean -M1400 \
  -o selfhost/build/phase94/kernel/BendTT.olean \
  selfhost/build/phase94/kernel/BendTT.lean
```

`kernel/Run.lean` contains only `import BendTT`. The cached module and build
receipt are included in the capsule; the runner binds their exact identities.
Its experimental replay uses the archived `kernel-build02` receipt rather than
automatically trusting an arbitrary replacement build. To authenticate a restored
official toolchain, run `proof-check.py --audit-toolchain --out FRESH` first.
Fast mode rehashes key files and manifests but reuses the completed full audit
subresult in `proof-replay01`; that run's later definition-inventory failure is
explicit, and its failed overall proof verdict is never reused.

This is a pinned experimental replay tool, not a general Lean package manager or
an adversarially secure toolchain loader. It rejects changed proof bytes and
elaboration inventories. New laws require their own frozen identities and review.

## Isolated compiler and adapter controls

`integration01/prepare.py --out FRESH --with-controls` prepares the candidate,
review patch, exact forward splices and executable control source. It runs no
targets and changes no production file. Its `--replay changes.json --out FRESH`
mode reconstructs the same source from the recorded baseline and splices.

`acquire.mjs SOURCE FRESH_OUT` checks the complete source and emits upstream C,
authenticating the pinned upstream tree first. Run it using the pinned Node
24.18.0 with `--stack-size=4096 --max-old-space-size=2048` under the common guard.
Proof CLI checks use pinned Bun; this C acquisition uses Node. The archived
`compiler-acquire01`, `compiler-build01` and
`controls-*` commands contain the exact successful argument vectors and budgets.
The experimental compiler uses Clang O2, matching baseline B1; tiny helper and
adapter controls use C11/O3 for both implementations. No generated C was patched.

`micro-template.bend` is instantiated with either the separate reference sequence
or `H.npe_extend`. Both complete instantiated sources and binaries are archived
under `micro03`; raw acquisition errors remain in `micro01` and `micro02`.
`profile.py` repeats a pinned native workload under the existing native sampler.
The retained Map profile has two overruns and supports exploratory leaf inspection
only; it is not caller attribution or evidence that this helper dominates.

## Evidence and exclusions

`collect.py --out FRESH` authenticates accepted inputs, summarizes the completed
runs, checks serial target intervals and archives raw Phase94 data. It runs no
targets. [evidence02](evidence02/summary.json) includes the accepted CSVs, adapter
controls, execution ledger and a 932-member archive verified by size and SHA-256
after compression. `evidence01` preserves the first collector's external-path
failure and original method. The official Lean archive/extracted distribution is
excluded from `raw.zip`; its JSON manifests remain inside.

For restoration, extract the ZIP from repository root only after checking its
SHA-256 against `archive.json`; verify every member against that manifest, and
restore executable modes from each member's `mode` field. Existing historical
files must match rather than being silently overwritten. Complete historical
dependencies outside Phase94 are identified in receipts and their earlier
capsules; this ZIP is not a standalone copy of the whole repository/toolchain.

Do not pool `compiler-screen01` with the accepted `compiler-screen02`: its final
method-immutability check failed. `method-initial.py` recovers the exact earlier
method for review. The repeat fixes coordination without discarding its history.
No B2/full-self promotion, broad conformance, GPU/parallel qualification or fresh
user-program runtime campaign is implied by this evidence.
