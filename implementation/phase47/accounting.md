# Source and output accounting for array06

2026-10-05. This compares the frozen Phase45 checked worker23 compiler with
Phase47 checked array06, with array04 retained as an intermediate checkpoint.
**The Array change increases source and
generated size; it does not reduce line count or conceptual complexity.**
Selection and runtime/compilation performance belong to the phase's other
reports. This accounting performs no compiler or target execution.

The retained producer is
[measure-size-v2.py](../../selfhost/tools/performance/phase47/measure-size-v2.py).
It pins and reuses the unchanged
[array04 producer](../../selfhost/tools/performance/phase47/measure-size.py).
The final raw result is `selfhost/build/phase47/accounting06/report.json`, SHA256
`0180d9917b792d516a8c628516e5a1eb41e1cafafb57fc84614c4288b14fc92b`.
Producer SHA256:
`8aa413827e967caf4e2b27bbdeb28137228986f155a2a6afb7e4cbf16390459b`.

The earlier `accounting04/report.json` remains unchanged, with SHA256
`b6e6531775cb0dd1b50de11fbeaf31fdfe41bbbad588a58181afaa5327058758`;
its consumed producer remains
`8e59af66ae57c32cb335bacd480404fa1c8e52105b45aab0f4028450cfcf8681`.

## Scope and identity checks

The producer joins each checked attempt to its frozen snapshot manifest and
verifies every counted Bend module against the attempt's frozen source hashes.
It verifies compiler API/runtime images, all three complete 45-point emission
manifests, emitted module bytes, and the checked acquisition receipt for each
representative source. All roles must have identical source hashes and
observation points. All 449 consumed files, including both producers
and Python executable, pass a final hash/size recheck before the report is
written. The tool refuses an existing output path.

Source counts include only the manifest's Bend modules. A physical line is a
decoded source line; a code line is nonblank and does not start with `#` after
indentation. `def`, `law` and `type` totals are syntactic top-level declaration
counts. They are reproducible size proxies, not a count of concepts or a
correctness measurement. Host tools, runtime JavaScript, tests and documentation
are excluded from these Bend totals and described separately where relevant.

## Maintained compiler source

| Measure | Worker23 | Array04 | Array06 | 23 →06 | 04 →06 |
| --- | ---: | ---: | ---: | ---: | ---: |
| Physical Bend lines |23,007 |23,213 |23,254 |+247 |+41 |
| Code Bend lines |18,983 |19,147 |19,175 |+192 |+28 |
| Definitions |2,594 |2,617 |2,622 |+28 |+5 |
| Laws |629 |629 |629 |0 |0 |
| Types |87 |87 |87 |0 |0 |
| Manifest modules |85 |86 |86 |+1 |0 |
| Bend source bytes |1,010,027 |1,022,193 |1,024,879 |+14,852 |+2,686 |

Physical source grows approximately 1.07% over worker23. That delta consists of:

| Module | Physical lines added | Code lines added | Definitions added | Bytes added |
| --- | ---: | ---: | ---: | ---: |
| `src/back/js/array-view.bend` |230 |177 |26 |13,595 |
| `src/back/js/emit.bend` |1 |1 |0 |86 |
| `src/back/js/region.bend` |8 |7 |1 |576 |
| `src/back/js/tree.bend` |8 |7 |1 |595 |

Relative to array04, `array-view.bend` adds 33 physical lines, 21 code lines,
four definitions and 2,088 bytes. `tree.bend` adds eight physical lines,
seven code lines, one definition and 595 bytes. `region.bend` changes by
three bytes without changing its line or declaration counts.

The manifest adds one module entry. The deferred 405-line JW cleanup pass is
absent from this final compiler; its preserved experiment is accounted for in
[worker-outcome.md](worker-outcome.md), not included as a production feature.

Conceptually, array06 adds a private representation contract to the existing
closed scalar-region path:

- A bounded audit admits only complete Array allocation/get/set graphs whose
  values cannot enter from, or escape to, the public Array ABI. Existing typed
  region and exact dependency proofs remain required.
- Request-local metadata selects raw backing-array representation. Admitted
  source applications normalize into the private helper/native calling path,
  preserving erased arguments and keeping raw arrays out of generic fallback.
- Ordered Array-set statements capture operands before mutation and return
  the same private array value. This preserves evaluation and alias behavior
  while avoiding repeated handle/view conversion.
- A dedicated runtime entry fence covers allocation hooks and rejects entry
  under an ambient region proof; refusal retains the original handle-based path.
- The final version reuses this contract for a bounded scalar-tree entry,
  checking both existing tree arms and preserving the existing frame emitter.
  Its raw tree path retains the `$s0 < 32n` entry bound and ordinary fallback.
- The runtime fence can omit floating-point-specific checks only after a
  complete absence check over the root's signature/body, checked arms and
  helper definitions. Unused or aliased F32 inputs still require those checks.

These are additional invariants and implementation responsibilities, even
though no new Bend datatype is declared. They are not a general effect/escape
analysis or general higher-order worker coverage.

## Runtime and compiler images

| Artifact | Worker23 bytes | Array04 bytes | Array06 bytes | 23 →06 | 04 →06 |
| --- | ---: | ---: | ---: | ---: | ---: |
| Maintained runtime fragment `src/runtime/js/core.mjs` |21,563 |22,383 |22,619 |+1,056 |+236 |
| Assembled runtime image `src/runtime.mjs` |56,140 |56,960 |57,196 |+1,056 |+236 |
| Checked API `checkedApi` |1,558,319 |1,575,096 |1,578,559 |+20,240 |+3,463 |
| Derived B1 API `api` |1,577,688 |1,594,694 |1,598,192 |+20,504 |+3,498 |

The runtime fragment grows from 362 to 377 physical lines: a single 15-line,
1,056-byte insertion containing captured hook identities and
`arrayViewHostGuard`. The assembled runtime changes by that **same insertion
only**. These are two representations of one maintained source change; adding
both deltas would double-count it. The exact inserted block has SHA256
`1646599c5b4d72dc3a42510a234f6e75c7e68864171ccad84dfbb4d2960733bb`.

Array04's distinct runtime block remains 13 lines /820 bytes, SHA256
`bac2c55a8006cbc7db24787be10223c607c5fead31098ec9abf303d3aecdd11d`.
Array04 →06 replaces that block; the net change is two lines /236 bytes.

The API images are generated artifacts, not extra maintained compiler source.
Their size changes are also not compilation-time measurements.

## Generated libraries: one representative per source

The complete corpus has 45 points over 23 exact source hashes. This table uses
the first matching manifest entry for each source, joined identically across
all roles. Full module sizes include the runtime prefix.

| Generated module | Worker23 bytes | Array04 bytes | Array06 bytes | 23 →06 | 04 →06 |
| --- | ---: | ---: | ---: | ---: | ---: |
| `local-row.mjs` |130,147 |148,609 |167,491 |+37,344 |+18,882 |
| `local-fold.mjs` |86,853 |91,281 |91,521 |+4,668 |+240 |
| `scalar-region.mjs` |94,518 |95,338 |95,574 |+1,056 |+236 |
| `mandelbrot.mjs` |171,037 |171,857 |172,093 |+1,056 |+236 |
| `editdist.mjs` |129,236 |147,698 |166,580 |+37,344 |+18,882 |
| `tree-bitonic.mjs` |136,945 |137,765 |138,001 |+1,056 |+236 |
| `lexer.mjs` |208,893 |209,713 |209,949 |+1,056 |+236 |
| `symreg.mjs` |157,343 |158,163 |158,399 |+1,056 |+236 |
| `test-morning-program.mjs` |129,995 |130,815 |131,051 |+1,056 |+236 |
| `test-evening-program.mjs` |176,010 |176,830 |177,066 |+1,056 |+236 |
| `test-rle-roundtrip.mjs` |113,218 |114,038 |114,274 |+1,056 |+236 |
| `test-map-set-ops.mjs` |389,034 |389,854 |390,090 |+1,056 |+236 |
| `raytrace.mjs` |292,104 |292,924 |293,160 |+1,056 |+236 |
| `mandelbrot-grid.mjs` |182,207 |183,027 |183,263 |+1,056 |+236 |
| `raytrace-active.mjs` |328,059 |328,879 |329,115 |+1,056 |+236 |
| `closures.mjs` |84,003 |84,823 |85,059 |+1,056 |+236 |
| `list-pipeline.mjs` |144,422 |145,242 |145,478 |+1,056 |+236 |
| `unicode-text.mjs` |154,455 |155,275 |155,511 |+1,056 |+236 |
| `map-churn.mjs` |246,492 |247,312 |247,548 |+1,056 |+236 |
| `numeric-recurrence.mjs` |82,337 |83,157 |83,393 |+1,056 |+236 |
| `bst.mjs` |118,146 |118,966 |119,202 |+1,056 |+236 |
| `expression.mjs` |93,552 |94,372 |94,608 |+1,056 |+236 |
| `record-aggregation.mjs` |239,842 |240,662 |240,898 |+1,056 |+236 |
| **Total** |**3,888,848** |**3,946,600** |**3,989,324** |**+100,476** |**+42,724** |

The producer removes only each role's uniquely present, exact runtime block
and compares the entire remaining byte sequence. **The same 20 of 23 modules
are then identical to both baseline and array04.** This is stronger than equal sizes, but establishes
emitted-byte identity only, not equal runtime performance after initialization.

The three remaining modules are local-row, local-fold and edit distance.
Relative to worker23, array06 adds 36,288 bytes each for local-row/edit distance
and 3,612 bytes for local-fold beyond the common runtime block. Summed growth
is 24,288 bytes of repeated runtime insertion plus 76,188 bytes of program
emission, approximately 2.58% of the original 23-module total.

Relative to array04, the new runtime block contributes 5,428 additional bytes
across 23 modules. Program emission adds 18,646 bytes each for local-row/edit
distance and four bytes for local-fold: another 37,296 bytes. The total
42,724-byte increase is approximately 1.08% over array04's library total.

The derived `local-row-observed.mjs` adapter is recorded separately, not counted
as a 24th source: 130,300 →148,762 →167,644 bytes, also +37,344 from worker23
and +18,882 from array04. All roles add the same 153-byte observation adapter
to their underlying local-row library.

## Reproduction

From the repository root, choose a fresh output path:

```bash
python3 selfhost/tools/performance/phase47/measure-size-v2.py \
  --baseline-attempt selfhost/build/phase45/checked-worker23/attempt.json \
  --previous-attempt selfhost/build/phase47/checked-array04/attempt.json \
  --candidate-attempt selfhost/build/phase47/checked-array06/attempt.json \
  --baseline-bundle selfhost/build/phase45/full-preparation-worker23/manifest.json \
  --previous-bundle selfhost/build/phase47/array04-full/manifest.json \
  --candidate-bundle selfhost/build/phase47/array06-full/manifest.json \
  --out selfhost/build/phase47/accounting06-repeat/report.json
```

This requires the retained raw snapshots and emission bundles, recoverable
through the campaign's preservation process. The report records every consumed
identity and the exact command. No Node process, compiler build, emitted-module
import or benchmark is launched by the accounting tool.
