# Direct public tail transfer on Map and lexer

The checked x86 selector reduces the Map/set fixture from 30.513 to 26.751 µs per invocation, a 12.33% reduction. It takes 2.541× mature Bend C's 10.527 µs. Lexer takes 1,013.889 µs with the selector and 1,017.606 µs on the incumbent. That 0.37% median change lies within the variation of this session. [Runtime, counter, and guard receipts](receipts.tar.gz)

| Ordinary program | Incumbent µs | Tail-transfer µs | Mature C µs | Candidate / incumbent | Candidate / C | Favorable rounds |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Map/set | 30.513 | 26.751 | 10.527 | 0.87668 | 2.54121 | 6/6 |
| Lexer | 1,017.606 | 1,013.889 | 384.309 | 0.99635 | 2.63822 | 5/6 |

The rule recognizes terminal transfers in an ABI11102 public worker where the checked guarded transport sets the same known target function in either arm. It preserves the original argument movement and frame restoration, resets the scheduler's next-function slot to STOP, and jumps directly to the target. The existing slow transport validates the function and argument count before a successful transfer. Its result is zero. The ordinary scheduler performs the same STOP reset before calling that segment. The native selector changes one existing declaration, `x190_step`, and adds five reachable helpers. The earlier checked machine controls passed 13 admission/refusal rows and 769 independent C observations on each of the direct-object and rendered-assembly routes. [Selector](../../heap/select.bend) · [Source mapping](../../heap/source-mapping.json) · [Controls](../../heap/controls-v2.bend)

The Map object has 272 qualifying direct jumps across 74 targets. Lexer has 56 across 19. Disassembly found no corresponding jump in either baseline object. Every candidate site reloads STOP and restores the frame before the public jump. Two untimed counter binaries increment a distinct slot per target at those same assembly sites. Subtracting their counts at one, five and nine repetitions independently gave exactly the same four-invocation difference, target by target. Map executes 417 transfers per invocation. The leading destinations include Map.msb.u and its conditional worker (35 each), Map.diff and Map.from_list.go (25 each). Lexer executes 1,026, including 511 to batch, 256 to gen, 256 to line, and three to harness-related entries. Map executes about 13.6 times as many selected transfers per millisecond of incumbent runtime as lexer. [Counter and paired measurement](measure.py)

The two Map objects define the same 957 functions. Exactly 228 functions change and all 228 contain a newly selected transfer. Lexer changes 51 of its 249 functions, again exactly the callers containing new transfers. All remaining 927 function payloads match byte-for-byte across the two comparisons. Total function bytes grow by 2,820 for Map and 616 for lexer. Linked code addresses and external relocation resolution can still differ. [Function-level object comparison](function-delta.json)

The timed candidate binaries came from the ordinary machine builder linking checked direct ELF objects with the unchanged runtime. Their canonical checksum outputs were 11111 and 1822208108. Two extra lexer inputs matched mature C at 3462121268 and 3601667849. Each case ran all six permutations of the incumbent, candidate and mature-C roles, independently calibrated. Each accepted sample took 138–151 ms. The 36 observations fit in one guarded CPU 3 session lasting 12.64 s. This two-program exploratory measurement leaves full-compiler self-hosting, other catalog families and an independently repeated runtime session open.

## Recovery and replay

The original 45 s batch verified all 275 inputs before emission, produced both complete checked object/assembly rows, then reached its deadline during final reauthentication. Its original role report, batch report and guard remain sealed as failed. The independent recovery reads those completed rows, validates the exact producer, emitter, preparation and input sets against the frozen plan, and rehashes 420 distinct files. These include the historical candidate pins, machine-control outputs, source mapping and baseline products. The standard builder separately admitted the fresh input receipt with a single checked emitter before linking. The runtime job authenticated its 431 input files and checked the timed products again at completion. The raw archive contains both the failed original receipt and the independently verified product receipt. [Original status](../../heap/status.json) · [Recovery method](recover.py) · [Raw receipts](receipts.tar.gz)

From the repository root, `recover.py` takes a fresh output directory. The measurement accepts the recovery at the paths below. The archive command preserves both runs’ raw evidence. Each guarded invocation requires a fresh output directory and the shared CPU 3 slot.

```sh
python3 -B research/phase198/reuse/tail/recover.py --out selfhost/build/phase198/heap-tail-auth01
python3 -B research/phase198/qualification/job.py reuse-public-tail01 26 48 python3 -B research/phase198/reuse/tail/measure.py --out selfhost/build/phase198/reuse-public-tail01
python3 -B research/phase198/reuse/tail/archive.py
```
