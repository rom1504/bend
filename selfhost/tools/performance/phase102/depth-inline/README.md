# Actual-C bounded forced-inlining prototype

This offline experiment demotes `NF_INLINE` to ordinary `INLINE`; it changes no
body, call, ownership operation, parameter, result or admission decision. It is
separate from compiler-image qualification. Root owns builds and executions.

Parse every emitted NF definition and its actual NF callees, skipping comments
and quoted text. Only originally forced-inline definitions with a C body at
most 8192 UTF-8 bytes are eligible. Starting from an empty set, perform exactly
three immutable passes: admit a definition only if every NF callee is in the
previous set. Thus the selected set contains leaves and at most two caller
levels. Missing callees, cycles, oversized bodies and originally ordinary INLINE
functions are not selected. Every declaration and definition receives the same
hint. The exact inverse checks all other source bytes are preserved.

This literal C graph is intentionally distinct from the Bend integration policy:
`NC_Text` excludes some emitted scaffolding, and a TRMC public wrapper/private
inner body share one logical `NF_Worker` in Bend. This prototype counts actual
body bytes and treats those emitted C functions as distinct vertices. Therefore
it can be stricter. It establishes a compile-time ablation, not byte identity
with Bend-emitted output or an installable compiler. Ordinary Clang inlining is
still allowed; bounded forced depth is not a bound on final machine-code size.

```sh
python3 -B selfhost/tools/performance/phase102/depth-inline/prepare.py \
  --source selfhost/build/phase102/native-chain01/b1-self/execution/output.1.c \
  --catalog selfhost/build/phase102/reuse-bend-catalog01/catalog.json \
  --out selfhost/build/phase102/depth-inline-c01
```

The output contains `compiler.c`, app C, per-source graph records and a pinned
catalog. Its generated `prepare.py` supports the existing saved-app runner.
Synthetic controls exercise depth, cycles, absent callees, original hints,
body size, arbitrary names, declaration consistency and exact inverse. None
execute a compiler or generated program. First compare guarded Clang completion
and resource use, then app outputs/runtime. Only actual Bend source and native
chain checks can qualify the eventual compiler policy.
