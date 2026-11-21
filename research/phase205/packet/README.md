# Independent packet transfer and eager-zero control

Execute only under the coordinator's lane authorization:

```sh
python3 -B research/phase205/measure/job.py packet-transfer01 120 24 \
  python3 -B research/phase205/packet/run.py \
  --out selfhost/build/phase205/packet-transfer01 --seconds 110
```

The exact argv is also in `argv.json`. Defaults are `selfhost/build/phase201/p204image03/program.gz` and `p205image01/program.gz`; sibling `results.json` receipts authenticate source and decompressed ELF. Override `--baseline`/`--candidate` for fresh images. Both compile the same `packet.bend` once and use the identical pinned Phase200 live-plus-scan runtime. This source and these inputs are independent of native45.

The framing definitions come directly from the independently named packet control. The measured expression remains `join(separator, fields(delimiter, repeat(n, block)))`. Runtime arguments are repetitions, warmups, repeat count, block size and seed. The block is generated dynamically once before warmups and timing, then shared across timed calls. It includes a delimiter every fourth raw word; other words depend on the seed and index. The transform hashes every returned U32 word using FNV-style XOR/multiply and an independent multiply/add accumulator, and reports output length plus both hashes. This is complete traversal, not a collision-free mathematical equality proof. Native per-invocation success checks are anchored to the first digest, which every process must match against the independent Python oracle.

Positive cases use16 and128 repeated blocks with `(block size16,seed17)` and `(block size31,seed123)`. Adverse cases use `n=0` with a precomputed65,536-word block, seeds17 and4294967295. Correct baseline render returns the empty result after preserving original argument evaluation. An eager transformed `h(block)` inside each render is charged by the timed loop even at zero; construction of the original block is excluded from both roles' timed interval. A Nat-zero branch must preserve that already-completed argument evaluation.

`make-fixture.py` supplies an independent imperative scalar-word expansion and exact digest oracle for all six cases. It creates source/metadata only, never executes Bend. At this checkpoint the fixture has not been source checked or compiled; the guarded native job is the first such test and fails closed on compiler, linker, full-output/count, elapsed-format or timing-resolution errors.

Four rounds alternate role positions, two appearances in each position per role. Calibration targets140 ms and every measured interval must meet100 ms. All pilots/samples and complete raw outputs are retained. Results include per-case ratios and dispersion, and separate positive/zero-adverse/all geometric means and fixed100-invocation totals. Zero cases are measured directly, never inferred from the positive runs. Neither native45 weights nor its C timings are reused here.
