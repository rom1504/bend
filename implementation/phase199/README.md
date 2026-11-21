# Phase199 direct x86 program runtime

## Where the gain came from

The previous compiler already fused the array worker, but still updated one U32 cell at a time. For this particular recurrence, each new accumulator is a prefix sum of old cells plus the incoming carry, modulo 2³². Four consecutive, distinct cells can be loaded together. Two shift/add steps compute their prefix sums, the incoming carry is added, and the four results are XORed with their indices and stored. The final sum carries into the next group.

The Bend selector matches the verified worker's data dependencies, effects, ownership/result convention and backedge. It accepts renamed temporaries and commuted addition and XOR. A representation guard preserves the original path for unsupported arrays. Short rings, misaligned starts and trailing cells preserve scalar ordering. The emitted direct-x86 object calls a 367-byte SSE2 runtime function implemented with C intrinsics. This experiment therefore measures Bend's ability to recognize and dispatch this computation; it also depends on the helper's machine code. [Lowering contract](../../research/phase199/scan-lowering/CERTIFICATE.md) · [Runtime implementation and controls](../../research/phase199/scan-runtime/README.md)

| Complete program | Candidate / matched Phase198 x86, two live link orders | Candidate / mature Bend C | Candidate SIMD / same candidate with scalar helper |
|---|---:|---:|---:|
| Fold, 4096 cells | 0.274 / 0.268 | 0.545 / 0.546 | 0.440 / 0.439 |
| Fold, 128 cells | 0.546 / 0.547 | 1.434 / 1.472 | 0.739 / 0.734 |
| Fold, 8192 cells | 0.261 / 0.260 | 0.523 / 0.523 | 0.430 / 0.430 |

Lower ratios are faster. These are three sizes of one family. Five balanced rounds across the matched programs produced 225 timed observations in 50 seconds. Replacing the SIMD leaf with a scalar one while keeping the caller object identical shows that moving the loop into the helper and vectorizing it both contributed. A second link order and the original runtime reproduced the direction. The scan-only change left the complete edit-distance and Mandelbrot object files byte-identical. [Exact objects, timing and methodology](../../research/phase199/scan-lowering/RESULTS.md)

## Correctness and integration

Five positive selector controls and 28 near misses passed. Independent execution of the real emitted worker passed 649 trials and verified 39,699 array elements, the carried result, ownership and output-buffer canaries. Shared, static and uniform representations took the fallback. The leaf also passed 59,136 full-state cases and a separate test crossing the 32-bit trip-count boundary. These are finite controls; reachability of the fast path and the compiler's source check provide separate evidence. [Worker oracle and receipts](../../research/phase199/scan-controls/README.md) · [Physical ABI audit](../../research/phase199/scan-lowering/machine-evidence/report.json)

The integrated compiler combines the scan with existing Bend selectors for word primitives, constant division and eligible public tail calls. The selected 1,969,124-byte source passed the pinned independent checker with zero unresolved holes. A qualified native QBE compiler builds the experimental N1. Its ordinary CLI emits direct x86 ELF objects. The original and live runtime bundles carry the same scan leaf and preserve the old exports. The installed Phase198 compiler remains the qualified reference. [Rebuild and source-selection evidence](../../research/phase199/composition/REPLAY.md) · [Native runtime packaging](../../research/phase199/native-use/README.md)

A separate register-reuse candidate stopped at the checked acquisition memory limit, 3,082 MiB against a 3,072 MiB cap. Its prior assembly witness has no measured compiler-level gain in this phase. [Attempt and controls](../../research/phase199/spill/RESULTS.md)

## Full native compiler result

The same timing session compared the Phase198 live executables, mature Bend C and the integrated N1 products. All 45 programs were rebuilt and checked. There are 44 runtime ratios because one correctness case performs zero work. Each of three roles occupied each timing position once. The 100 ms measurement floor and the frozen original workload weights were retained.

| Metric | Previous x86 | Integrated x86 |
|---|---:|---:|
| Geometric runtime / mature C | 1.2756 | 1.0007 |
| Equal-family geometric runtime / mature C | 1.1313 | 0.9138 |
| Mean positive log-slowdown | 0.6305 | 0.5185 |
| Cases above 1.1× C | 33 | 31 |
| Cases above 2× C | 21 | 17 |
| Fixed-batch equivalent, seconds | 19.393 | 16.769 |
| Fixed-batch runtime / mature C | 1.880 | 1.625 |

The geometric change against the same-session x86 incumbent is 21.55% less time. Mature C took 10.317 fixed-equivalent seconds. Excluding the absorbing scalar input, the C-relative ratio moves from 1.532× to 1.195×. Across the other 41 timed cases after removing the three folds, integrated x86 took 0.8357× previous x86 time. Broad differences include all portfolio rules, actual link placement, and run-to-run variation. The matched scalar helper experiment above isolates one cause.

Prior and candidate N1 catalog runs took 105.78s and 106.61s end to end. Summed object-emission times were 79.58s and 78.70s. These are separate acquisitions, each run once. Building the combined compiler executable took 188.31 seconds; its source grew by 21,558 bytes from the qualified source. All 45 integrated objects changed. Native N2/N3 self-reproduction and release certification remain open.

The first relink preparation rejected a relative path in the runtime receipt before linking. The retry resolved each path against the checkout and rechecked its original byte length and SHA-256. All 135 fresh preflight outputs and 405 timed outputs passed on the retry. [Authenticated timing and dispersion](../../research/phase199/broad/integrated-summary01.md) · [Breadth and compiler cost](impact.json)

## Transfer and next target

A separately authored packet-window program ran the same recurrence twice on a nonuniform 64-cell ring. All 65 observed words matched an independent Python oracle on ten inputs for the old native compiler, integrated native compiler and mature C. Dynamic call instrumentation confirmed both segments used the helper. In four balanced pairs per point, candidate/baseline runtime was 0.283 on the primary input and 0.538 on the shorter alternate. This establishes transfer across source structure, initial state and ring size within one algorithm. [Independent transfer and complete outputs](../../research/phase199/scan-transfer/README.md)

The next targets by remaining fixed-work excess over mature C are ray tracing (0.95s), lexing (0.94s) and BST (0.75s). The list pipeline also took approximately one third of its previous runtime in the integrated screen. Isolate the corresponding portfolio rule before attributing that improvement. Thirteen catalog cases crossed the dispersion threshold. Treat 1.0007× as measured geometric parity within timing variation. The fixed-work batch and 17 cases above 2× C are material remaining deficits. [Full per-case receipts](../../research/phase199/broad/integrated-evidence01/index.json)
