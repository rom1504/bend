# Independent native generalization coverage

## Question and preselection

Does the compiler improve ordinary native programs beyond the six families used
to develop Phase68–69? In particular, can a structural observer analysis help an
unrelated user ADT while preserving performance on programs it cannot admit?
Select this addition before acquiring or timing the Phase70 candidate. Keep all
six outcomes, including refusals, shared failures and regressions. No expected
speed gain is an inclusion criterion.

The existing native loop contains numeric recurrence, array fold, captured
closures, bitonic tree sorting, Map churn and a lexer. The JS catalog contains
45 input points in 23 source files; it does not constitute 45 independent
programs or native coverage. Reuse three already independently specified JS
families and one upstream test algorithm, then add a separately authored ADT
observer and a workload for the existing String comparison implementation.

| Additional family | Fixed size / seed | Coverage and selection reason |
| --- | ---: | --- |
| List pipeline | 128 / 17 | Generate, filter, double and fold a list. Allocation and composed consuming traversals, without a root-preserving result. |
| BST | 32 / 17 | Existing fueled zipper insertion followed by an ordered fold; irregular trees and explicit product state. Native timing holdout. |
| Expression | 128 / 123 | Construct and interpret an unbalanced arithmetic AST with Add/Mul/Sub and wrapping words. Native timing holdout. |
| Array map | 512 / 17 | Repository U32→Bool→U32 `Array.map` and fold, with varying initialized prefix. Deliberate scalar-layout and nonobserver control. |
| Tape observer | 64 / 17 | Independent `End/Link{U32,Tape}` ADT, preserving root reconstruction with scalar accumulator, shared alias and complete subsequent root traversals. |
| String ordering | 32 / 17 | Equal roots, strict prefixes, both unequal orders, early/late exit, Unicode, generated shared prefixes and static strings. Consume both returned roots. |

The first three source files remain unchanged. Array-map imports the original
test's mapping/conversion/folding functions and replaces only the workload
generator. The two new observer workloads are not copied from generated C and
contain no backend admission names. Their descriptions are workload coverage,
not promises that the observer pass will admit them. A refusal is a valid
performance result. BST/expression become native holdouts only: they are already
visible in historical JS work and must not be called globally unseen programs.

## Specification and observation

All six export `bench(size: U32, seed: U32) -> U32`. The shared batch generator
comes unchanged from Phase46: invocation i uses `size+(i&1), seed+(i&15)`, giving
16 independently computed expected values. Every invocation contributes to an
ordered wrapping digest; the native program prints the base result, warmup
digest, measured digest and measured integer milliseconds. Repetitions/warmups
are command-line parameters, independent of kernel size and I/O frequency.
There is no print in a workload's inner loop. The timer includes the measured
digest's formatting/print, consistently with the original six-family method.

The [Python oracle](../../selfhost/tools/performance/phase70/coverage/oracle-v2.py)
does not import either compiler or generated code. It reuses prior independent
list/BST/expression specifications; BST is modeled by sorting, and the AST by a
scalar recurrence without constructing an AST. Array-map is a Python list and
predicate count. Tape is an integer sequence plus mathematical sum/hash. String
ordering uses Python Unicode code-point ordering and hashes both full roots.
Each family has four extra small reference points, including empty and singleton
inputs. These source-only values are not claimed as executed compiler checks.

Full-root digests detect many corruption errors but can collide. Tiny controls
owned by the independent correctness lane must still exercise return identity,
field permutation, aliasing, shared tails, unsupported layouts and refusal.
Performance checks do not establish those semantic claims.

## Acquisition and fast loops

The [coverage tools](../../selfhost/tools/performance/phase70/coverage/README.md)
produce exact, hash-bound successors of the existing native freeze/emission/run
and three-role comparison methods. Historical methods and raw evidence remain
unchanged. All outputs are fresh directories below `selfhost/build/phase70`.
Source-only preparation runs on CPU0. Root alone owns target execution on CPU3,
with the existing execution guard, 2 GiB process-tree ceiling, 4 GiB memory
floor, 1 GiB Node heap and 4 MiB stack. Each native process has the inherited
45-second bound; acquisition emission and Clang have separate bounds.

The v2 corpus preserves the original proposal and fixes one source admission
issue: Tape's computed tuple destructuring moves to a parameter helper. The
mathematical workload and all expected values stay unchanged. First run the
six-entry `selection-check-v2.json` through a cheap checked-source gate. Batch
wrappers deliberately have no `#|` timing goldens because the fourth line is a
variable clock; this gate binds their independent catalog/oracle instead.

1. Freeze catalog/source/oracle/toolchain identities before target execution.
   Acquire Phase69 checked B1 and pinned upstream C once for the additional
   selection. Then acquire the frozen candidate once. Source checking, emission,
   C compilation and the three output oracles are mandatory; preserve failure.
2. Calibrate separately. Baseline/upstream share one recipe; the candidate has
   its own recipe. Merge calibration rates into one common count per family,
   aiming for a 300 ms fastest role and at most 3 seconds slowest. If a sample
   is below 10 ms, repeat calibration using its generated larger plan. If the
   role spread cannot fit the bounds, retain the case and explicitly revise the
   bounds. Never reduce its input, remove it or time different work per role.
3. Routine rejection loop: Tape plus Array-map. Use three rotated roles and
   rounds on already built binaries. This deliberately pairs an observer with
   a nonobserver. A 20-second execution budget is a planning target, not a
   guaranteed duration. Include String ordering and List pipeline for a deeper
   roughly 60-second screen. Acquisitions are outside those budgets.
4. Freeze the implementation before opening the BST/expression timing holdout.
   Measure all six additions in a separate three-role campaign. Reuse artifacts
   across timing rounds; rebuild only when their compiler/source inputs change.
   Rerun old six-family qualification only at integration, not after each edit.

Every final interval must have exact oracle outputs, a valid millisecond clock
and at least 100 ms duration. Three rounds rotate baseline/candidate/upstream
positions. A failed interval is retained and receives no speed ratio; a new
count plan means a new complete selected campaign. Native compilation time and
code size remain separate from runtime.

## Acceptance and limits

Report all six new family ratios, per-role sample counts, spread, checked source
identities and failures. Keep the existing six-family geomean separate. An
optional 12-family equal-family summary must name the union and preserve both
component summaries; it must not overwrite the historic denominator. The new
samples add native mechanisms and independent ADT syntax but are a small,
in-memory, CPU/single-thread selection. They do not cover arbitrary native IO,
foreign callbacks, GPU execution, services, large heaps or all Bend programs.

Correctness controls, runtime transfer, B1/B2 compilation cost and source-size
change are separate decisions. First require semantic controls and no important
runtime regression; then use compilation profiles for the next optimization.
No compiler promotion or performance result follows from writing this corpus.
