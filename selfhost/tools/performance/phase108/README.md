# Full-compiler QBE loop

[User guide](../../../../docs/self_hosted/QBE_COMPILER.md) ·
[Design](../../../../design/phase108/full-native-qbe.md) ·
[Report](../../../../implementation/phase108/README.md).

This route uses existing Bend-owned semantic lowering, cproc's C frontend and
QBE's machine backend. It is separate from Phase107 direct Nx source admission.
`compile.py INPUT --out FRESH` is the convenience build interface after image
qualification. `--seconds 1200` allows an explicitly expensive full-self request;
ordinary programs use the default300-second ceiling and usually take seconds.

## Fast loops

- Source-only controls: `python3 -B selfhost/tools/performance/phase108/coverage/verify.py`.
- Prepare unchanged compiler algorithms plus four metadata definitions:
  `python3 -B selfhost/tools/performance/phase108/prepare.py --out FRESH`.
  The default v3 runtime is materialized from exact authenticated recipes.
- `coverage/run.py --runtime RUNTIME --out FRESH` runs six independently specified
  output controls and three source negatives through the selected producer and
  QBE. `--compiler IMAGE` runs the same suite through a new native image.
- `compare.py --runtime RUNTIME --compiler IMAGE --out FRESH` compares entire C
  products and diagnostics on six real benchmark sources. `--source PATH`,
  `--live`, `--calls 5` and `--rounds N` select smaller, live, repeated or paired
  clocks. Its only normalization is the exact four missing bootstrap macros.
- `profile.py` reuses the existing main-thread CPU sampler against an unchanged
  executable. Sampling results are diagnostics, separate from clean clocks.

Run target methods under `phase86/guard.py`, serially on CPU3. Keep one process
thread and GPU off for controlled clocks. The full cproc build requires about
3.1GiB process-tree memory for the pointer-ABI image; use a4GiB cap with16GiB
available-memory floor. Initial3GiB guard rejection is retained, not an OOM.

## Full image acquisition

`toolchain/setup.sh` acquires pinned cproc and QBE source and applies two recorded
patches. Setup is an explicit maintainer/network step, never a hidden fallback in
ordinary requests. See `toolchain/receipt.json` and the toolchain audit for hashes.
The selected native compiler/assets must already be restored.

1. Run `prepare.py --out SOURCE_DIR`; it runs no compiler. Preserve its manifest.
2. Under a guard, `run.py emit SOURCE_DIR/compiler.bend --runtime SOURCE_DIR/runtime.c
   --out EMIT_DIR --seconds 240` uses the selected trusted native B2.
3. `runtime/bridge-metadata.py EMIT_DIR/program.1.c EMIT_DIR/portable.c
   --receipt EMIT_DIR/metadata.json` adds only the absent register metadata.
4. Under the4GiB guard, `run.py build EMIT_DIR/portable.c --backend qbe
   --out BUILD_DIR --seconds 280` produces the full Q0 compiler.
5. Run the frozen controls, whole-product comparison, and full self-emission with
   `run.py emit SOURCE_DIR/compiler.bend --runtime SOURCE_DIR/runtime.c
   --compiler BUILD_DIR/program --out SELF_DIR --seconds 1150`.
6. Require the complete self C to equal the parent's bridged C, then build it
   directly through QBE. No metadata bridge is required for this successor.

Every output directory is fresh. The user guide's image pointer is written only
after actual gates; preparation alone does not qualify an image. Ordinary builds
never use `runtime/rebind.py`: that research helper only replaces exact literal
runtime parts to avoid repeating unchanged semantic compilation while testing ABI
variants. It verifies exact inversion and preserves all program text.

## Boundaries

cproc/QBE currently does not inline C helpers. Five scalar accessors are explicitly
expanded for this backend; general runtime helper calls remain a speed limit.
The atomic/CLZ support object is GCC compiled and retains real atomics. Compiler
and runtime source are authenticated independently of generated binaries. The
Linux x86-64 constructor extension rejects unsupported forms and priorities.
No GPU/parallel scaling, all-language correctness proof or upstream speed-parity
claim follows from these finite gates.
