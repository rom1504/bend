# Array work remaining after flat products

Offline inspection of product11 local-pair/editdist found two independent costs:
ordinary private call chains and retained uniform-array runtime helpers.
This is a mechanism comparison; it does not multiply historical timing ratios.
Exact inspected artifact hashes are retained in
`array-opportunities-evidence01.json`; no compiler or native target was executed
for that inspection.

The product11 hot DP cell crosses ten private calls: row→cell; cell through
f1/f2/f3/f4; f1→b2u; two calls from f4 to umin and each umin→umin.go. It also calls
four array-get pair helpers, generic array-set and the Succ destructuring helper.
Each of cell/f1/f2/f3/f4 has approximately2.1KiB of QBE stack frame for scratch;
the inspected frames have roughly20–29 memory moves plus outgoing stack args.
These are static machine observations, not sampled dynamic counts.

The pinned upstream local-pair binary's `spin_26` has an88-byte frame. Its
approximately26-instruction inner loop performs four packed reads and one write,
uses conditional moves for minima and has no calls. Allocation/free calls occur
outside that cell loop. The exact sources are:

- `selfhost/build/phase111/p113-products11-local-pair-emit/program.ssa`
- `selfhost/build/phase111/p113-products11-local-pair-build/program.s`
- `selfhost/build/phase93/pilot02/local-pair/upstream.1.c`
- `selfhost/build/phase93/pilot02/local-pair/upstream.program`
- `selfhost/build/phase93/broad01/editdist/upstream.1.c`

Runtime04 has both `NATIVE_SCALAR_ARRAYS` and `NATIVE_UNSHARED_ARRAYS` disabled.
Its uniform get performs `blk_keep`, including possible reference-counting and
cell replacement; set sinks old and seals new. The mature C checked path can
enable packed/unshared arrays from the `ns_*`/`nr_unshared` semantic certificate.
Changing the whole runtime representation alone would leave the private call,
argument-buffer and frame costs. No standalone factor estimate is justified.

Two composable falsifiable experiments therefore target the largest categories.
`direct-opt-products/` inlines eligible flat-product workers with simultaneous
result snapshots. The separate `array-fast/` profile reuses the mature checked
certificate but keeps uniform64 layout, emits guarded structured memory
operations and retains exact helper fallback. Its scalar guards explicitly
justify omitted reference-count effects; it does not rely on a blanket tag
shortcut. Qualification should first show fewer actual private/runtime calls,
then compare complete output and paired runtime against the same product
baseline. Packed32 representation and loop-invariant address hoisting remain
separate possible follow-ups, not prerequisites or claimed gains.
