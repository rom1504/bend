# Early return from a pure absorbing countdown arm

Returning the canonical leaf and the incoming path as soon as descent reaches a leaf removed **23.3–23.8%** of total BST64 runtime and **4.3–7.0%** of BST32 runtime across two assembler layouts and two sessions. All 32 candidate/baseline pairs favored the early return. The programs are two catalog fixtures of the same BST algorithm with different defaults and validation constants. In both, the current qualified Phase195 compiler emitted the identical descent worker. Transfer beyond this algorithm is open.

| Test | Project layout A / B | Default layout A / B | Positive-fuel steps | Absorbing-arm visits |
|---|---:|---:|---:|---:|
| BST64, size 64, seed 17 | 0.7675 / 0.7624 | 0.7623 / 0.7623 | 4,160 → 429 | 3,795 → 64 |
| BST32, size 32, seed 0 | 0.9567 / 0.9342 | 0.9305 / 0.9464 | 1,056 → 528 | 560 → 32 |

Entries are medians of four complete candidate/assembly-baseline pairs per cell. Roles alternate within each cell; session B reverses ordering. The project layout uses the pinned assembler flags. Direct qualified N1 binaries supplied the calibration and a correctness anchor. Counts come from separate instrumented executables making exactly one complete benchmark evaluation. Every removed positive step was a repeated visit to the leaf arm. Function call counts remained 64 and 32. BST32's ascending insertion touched more internal nodes per insert and reached the leaf later, leaving fewer fuel steps to skip. [All timings, exact counts and oracles](result.json)

## What was changed

The original loop has four logical inputs including remaining fuel, comparison key, tree and path. When fuel is zero it returns tree and path. When fuel is positive and the tree tag equals 164, its body replaces the tree word with canonical leaf K = 0x0100a40000000000 and leaves the path and key alone. K has the same tag. Every remaining positive iteration therefore repeats the same state, apart from decreasing fuel. Original worker machine code does no heap reads/writes, retains, releases, IO, calls or machine-stack growth on that repeated path. The eliminated fuel spill is private and separate from the result buffer. It never underflows on this path because the loop tests zero before decrementing. For any positive finite fuel, induction gives the same zero-fuel return value after canonicalizing once.

The projected code changes one constant's destination register from r13 to rsi and retargets the following unconditional jump to the existing product-return block. The zero-fuel edge keeps the original tree word, including every payload bit. Return status, ordered result writes, path identity and callee-saved restoration still use the same epilogue. Cases that encounter node/invalid tags use the original code. [Frozen old/new arm and trace inputs](frozen.json) · [Projection and exact-worker check](projection.py)

## How the model contributed

The earlier model ranked narrow tag equality first on a block covering 12.4% of sampled BST64 time. That instruction change failed the whole-program cutoff. Tracing the surviving tag comparison through the loop revealed the absorbing arm. This fifth hypothesis was frozen after those four timing outcomes. Three separate LLVM-MCA scenarios modeled only the data instructions from a positive tag match to the zero-fuel return. Repeated branch, cache and epilogue costs lie outside those regions. At incoming matching fuel 1, 8 and 32, the baseline contained 5, 96 and 408 instructions versus one constant load in the projection. Over 100 MCA iterations the modeled cycle pairs were 140→37, 2706→37 and 11506→37. Those local scores motivated a work-count test. They cannot predict the frequency of the absorbing edge; the independently instrumented executables supplied that measurement. [Raw MCA outputs and sealed guard](receipts.tar.gz)

## Checks and reproduction

Both uninstrumented siblings under both layouts and the direct original agreed with mature C on the ordinary point and additional size/seed inputs including 0, 1, 32, 61 and 64. The ordinary point validates all timed repetition and warmup counts. A separate direct-worker harness exercised 72 combinations per project-layout sibling in each fixture, including zero and positive fuel, noncanonical raw bits with the matching tag, opaque path values and caller-output canaries. These ABI stress words exercise the machine contract. Some are outside the source language's constructor representation. Extremely large fuel is covered by the decreasing-counter argument rather than a finite execution of the old loop. The full experiment took 19.707 s in one 96 MiB guard on CPU3, including independently regenerating BST32 assembly with the qualified compiler. No maintained compiler source was changed.

```sh
d=research/phase197/discovery-b
python3 -B "$d"/absorbing/projection.py
python3 -B "$d"/guarded.py discoveryBAbsorbReplay 85 96 "$d"/absorbing/run.py
```

The [typed admission analysis](admission.md) describes a conservative future compiler rule, refusal cases, and a separate text-search transfer candidate. A static scan of the 45 current binaries found this particular physical countdown-and-tag pattern in the two BST fixtures alone.
