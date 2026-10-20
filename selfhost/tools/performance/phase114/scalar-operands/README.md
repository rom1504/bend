# Explicit scalar operands, P114-008

This optional Phase114 prototype bypasses a private input buffer for selected pure floating-point operations. The hypothesis is recorded in [P114-008](../../../../../experiments/phase114/P114-008-scalar-operands.md). It is separate from the qualified `final-source01` checkpoint. A successful compiler-source check does not establish native correctness or a speed improvement.

The existing lowering writes operands into a scratch array, then calls an intrinsic. The selected renderer later replaces supported calls with scalar QBE instructions, but retains the argument stores. The prototype recognizes the original structured store/call group and renders its already evaluated operands directly. It does not parse or rewrite QBE text.

`modules01.json` freezes the parent, reviewed modules, runtime and sole override, `p113e_private`. The original renderer is preserved as `p114so_private_original`. The whole-function audit admits a buffer only if every use is understood; an escape, alias, unrelated call, read or destination reuse retains the original path. Supported operations are U32-to-F32 conversion and the existing F32 arithmetic/comparison primitives. Both operands are read before any result assignment. Width conversion and floating-point behavior follow the selected renderer exactly.

This first experiment rewrites top-level statement groups only. Nested rendering, runtime templates, public entry points, recursive paths, ownership operations and the original IR verifier remain unchanged. Scratch allocations may remain even when their input stores disappear. It does not yet retain F32 values across operations, remove array output-buffer traffic, or claim that all static stores are dynamically hot.

## Reproduction

All compiler/API, QBE, native build and program runs belong to the root's serial target lane. These commands are recipes, not evidence that the jobs passed.

The original `prepare.py` and failed `scalar-operands-source01`/API01 preserve a source-transport mistake: the first method omitted the parent `import Base` prefix. Root's versioned `prepare-v2.py` preserves that prefix exactly. It produced `scalar-operands-source02`; its checked API is `selfhost/build/phase111/p114-scalar-operands-api02/api.mjs`. The Bend implementation modules were unchanged by that correction.

```sh
python3 -B selfhost/tools/performance/phase114/scalar-operands/prepare-v2.py \
  --out selfhost/build/phase114/scalar-operands-source02
```

Use a fresh output name when the recorded output already exists. After acquiring a checked API, authenticate exact source composition without executing compiler targets:

```sh
python3 -B selfhost/tools/performance/phase114/scalar-operands/admit.py \
  --source selfhost/build/phase114/scalar-operands-source02 \
  --api-report selfhost/build/phase111/p114-scalar-operands-api02/report.json \
  --out selfhost/build/phase114/scalar-operands-admission01
```

This receipt binds the exact parent import prefix, every declaration, the original fallback, the fixed runtime and the successful checked API. Its admission establishes source correspondence; ordinary program semantics and native performance need the following gates.

Run the structural control under the existing target guard:

```sh
selfhost/.bootstrap/bun-1.4.3/bun \
  selfhost/tools/performance/phase114/scalar-operands/controls.mjs \
  selfhost/build/phase111/p114-scalar-operands-api02/api.mjs \
  selfhost/build/phase114/scalar-operands-controls01
```

The driver uses the actual frozen Bend source, the mature checked frontend, runtime admission and unchanged final IR verification. It retains before/after QBE and hashes for the same private functions. Arithmetic and conversion must remove stores while retaining the operation sequence. The function combining unsupported `F32.sqrt` with addition must retain its original scratch path exactly. Missing admitted functions fail the structural gate rather than silently passing via fallback.

`controls/manifest01.json` separately freezes complete stdout for an ordinary executable: arithmetic result bits, comparison outcomes including signed zero, square root, and the U32-to-F32 rounding boundary. Prepare its existing emit/build/observe jobs:

```sh
python3 -B selfhost/tools/performance/phase114/controls/prepare-jobs-v2.py \
  --api selfhost/build/phase111/p114-scalar-operands-api02/api.mjs \
  --runtime selfhost/build/phase113/runtime-products-build01/runtime.o \
  --prefix selfhost/build/phase111/p114-scalar-operands-control01 \
  --out selfhost/build/phase114/scalar-operands-native-jobs01.json \
  --manifest selfhost/tools/performance/phase114/scalar-operands/controls/manifest01.json \
  --all --pipeline array
```

That plan has three normal jobs and was prepared without executing them. Root executes it through the existing guard. Only after structural and complete-output gates pass should the existing frozen ray, scalar and local-pair products be used for a small matched speed screen. The first two include relevant scalar operations; local-pair is primarily a no-regression control. Broad qualification and any selection decision are separate.
