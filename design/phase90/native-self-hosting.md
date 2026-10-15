# Phase90: finish native self-compilation and reduce shared-data costs

User authorizes continued implementation after Phase89, not merely another
investigation checkpoint. Start at73c9f9e on selfhost/bootstrap. Preserve native89
8bacae26…, source4584cf08…, installed JS B2 098320e8…, pinned upstream0592662,
all prior evidence and unrelated Phase6/68 work. No PR comments.

## Required outcomes

1. Obtain a complete, checked C emission of the frozen native compiler source;
   identify and fix semantic/layout/resource failures instead of hiding them.
2. Build a native compiler with our own C backend, verify actual compiler requests,
   and pursue native self-reproduction with byte-identical successor C. Record
   each producer explicitly: upstream-built native B1, JS-hosted Bend producer,
   own-backend native image, native-produced successor. A JS bootstrap does not
   establish the native B1→B2 chain by itself.
3. Reduce measured complete-request cost without changing generated program
   behavior; preserve the six-source cold/repeated loop and45-point broad C gate.
4. Reconcile current source with the installed JS release through checked build
   and self-hosting qualification; never rewrite the old manifest to claim a proof.

## Investigation and implementation order

**A. Scale and stage attribution.** The previous60s prefix does not explain the
600s timeout. Use the exact existing native image and sampler with a bounded
180–240s capture at16ms intervals; extend only the watchdog's diagnostic limit.
Retain normal/stopped controls, exact image/unwind/provider pins, lost-sample
checks and rc77/incomplete status. CPU samples in elapsed-time bins are not stage
clocks. If necessary build one source derivative with explicit plan/check/prepare/
emission clocks, preserving values and recording instrumentation overhead.

In parallel with offline inspection, prepare a JS-hosted Bend emission of the
same frozen source. Root executes it serially with the native profile. This
separates native execution cost from a general backend/checker limit and gives
an independent complete-C oracle before an expensive native successor build.
Start with a90s/2GiB guard and bounded Node heap, observe progress before changing
limits. A larger budget needs a concrete stage/resource justification.

**B. Shared observation falsifiers.** The exploratory prefix attributes30.42% of
samples to equality ownership,9.40% to definition-name projection. These are
budgets, not promised gains. Existing False-first comparator is rejected by the
language's match-order rule; do not repeat argument permutations or weaken rules.
Inspect actual source and generated C for safe consuming result threading,
chronological indexed lookup and redundant projections. Preserve returned whole
products, first-match order, diagnostic order, source positions and alias liveness.
Tiny equality/lookup scaling matrices precede a full compiler acquisition.

A diagnostic borrowed-root C kernel may establish a lowering opportunity, but it
is not a production Bend implementation. Our upstream-built native B1 cannot
benefit automatically from changes only to our own C emitter. If the own-backend
native image becomes viable, inspect its existing observer/scalar policies before
adding or broadening optimizations. File IO and generic arrays do not gain scalar
permission merely because a compiler benchmark would benefit.

**C. Integrate a measured winner.** Fully check a frozen source derivative, compare
small complete products, acquire/build once, then live/cache Small/Map/Unicode/
file-IO gates and paired six-source clocks. Exact C is the program-speed guard;
changed C requires execution and relevant speed comparisons. Run45 broad points
only after a meaningful fast-loop result. Repeat full self-emission after fixing
an identified mechanism, not by blindly raising a timeout.

**D. Self-host and release.** First qualify the own-backend compiler's argv, file
IO, Base decoder, negative inputs and direct requests. The retained runtime omits
program argv; preserve the explicit adapter. Bind its real producer/build lineage
without pretending it was upstream-built. Obtain successor C and require exact
reproduction plus source-specific C/behavior controls. Refresh JS source/release
via the existing checked-B1/equality/self-release workflow, with ordinary frontend,
backend and installed/relocated checks appropriate to the final source changes.

## Efficient execution and resource policy

Root alone executes compiler/native targets. Three bounded agents prepare late
sampling, own-backend bootstrap/release, and shared-data source controls offline.
No competing compiler builds or benchmark clocks. Normal CPU3/2GiB RSS/4GiB
available-memory floor; full Clang only6GiB with16GiB available. Keep Node heap
bounded, output files64MiB and at least160MiB disk reserve. Preserve lazy native
address-space reservations; do not impose a tiny virtual-memory cap.

Prune only byte-verified duplicates from committed evidence capsules, with exact
restoration receipts. Keep installed/native image dependencies and unrelated
work. Retain failed attempts at fresh paths. Commit design, useful intermediate
findings and final implementation/report; user already authorizes pushing.

A failed approach triggers the next justified approach within the task. Finishing
a report is not the stopping condition. Report unsolved limits honestly, but
continue toward a usable self-reproducing native compiler while meaningful
implementation work remains. Separate benchmark ratios, actual stage completion,
conformance, program-speed preservation and production complexity throughout.

## Measured follow-up: code formatting and bounded heap

After indexed fork closure, genuine JS B2 reaches final native code formatting.
The55–60s profile window is85.82% GC with `nt_lines_rev`/String reversal in the
remaining samples. Clean1GiB and1.5GiB heap attempts abort at64.94/67.68s, below
the2GiB RSS guard and with more than24GiB host memory available. Do not continue
raising heap limits. These are contained target heap failures, not host OOMs.

Test eliminating body indentation in `ne_segment`: the emitter currently scans
every body character, reverses the accumulated text, and retains the resulting
string ropes with all other generated segments. Indentation is cosmetic for the
C syntax we emit. First audit multiline literals, line splicing, directives and
foreign-code insertion; do not assume arbitrary C text is whitespace-insensitive.
The standalone text helper's API can remain unchanged.

Use a one-line source candidate and the checked B1 full-source fast loop before
another B2 build. Changed C is expected; old byte-hash gates cannot be relabeled
as passing. Compare complete preprocessed token streams under identical filename,
flags and includes, retain macro/line-sensitive controls, and execute selected
generated programs. If the candidate succeeds, apply the same check across the
broad catalog and obtain an independent full compiler emission/fixed point.
Separate this formatting change from the already-tested indexed closure and
from the unexecuted explicit-laziness candidate.

For the long first own-backend Clang build, allow one independent correctness
qualification job concurrently: Clang on physical cores2/3, qualification on
physical core0. Each remains root-run and guarded, with maxima6GiB+2GiB RSS;
Clang retains its16GiB available-memory floor. Do not run native benchmarks or
profiles concurrently, and do not use overlapping job wall times as performance
comparisons. This bounded exception replaces idle validation waiting without
relaxing either process-tree memory limit or the reserved host-memory floor.

Actual execution retains the existing global target lock: the attempted overlap
was rejected before launching a child. Do not bypass that lock. Targets remain
serial, and no measured overlap is claimed.

Two optimized full-Clang attempts (O1 and O1 without heuristic inlining) reach
the6GiB RSS guard at roughly91–95s. The same source builds atO0 in99.9s/3.17GB
using an explicitly recorded cdecl fallback. Its C is2.17times the source size
whose upstream-built optimized image already required4.30GB. Therefore admit
one full-Clang-only10GiB RSS cap, retaining16GiB available memory, the global
serial lock,64MiB output cap and420s deadline. Require240MiB initial disk reserve.
This is a bounded toolchain-scale experiment, not an unrestricted heap increase
or a change to normal2GiB compiler-request limits. Preserve pass timing/trace
metadata to distinguish actual build work from resource-cap failures. Test an
LLVM analysis-cache invalidation option only if this exact Clang supports it.

## Large dispatch tables: measured build repair and integration

The one10GiB attempt also reached its cap. A bounded pass/RSS diagnostic
localizes the late growth to LLVM callgraph construction. Generated return
macros expand to references to the shared39,642-entry function table at15,296
sites. A noinline host accessor prevents each function's reference graph from
walking that initializer. The two-edit diagnostic builds atO1 in267.681s with
3.885GiB peak RSS; four small dispatch compile/execution controls also pass.
Do not increase the memory cap further.

First qualify actual native06 requests and self-emission against independent
complete C. Then integrate the accessor for host tables with at least4,096
entries, together with upstream's O0 attribute guard. Place the conditional
after the emitted FID_ENTER macro, regenerate all runtime template parts through
the checked Bend scanner, and update the driver's template identity. Small
optimized programs keep their existing direct dispatch. The threshold is a
conservative policy, not a measured crossover.

Preserve the diagnostic image's actual patched-C provenance. Final qualification
uses explicit new runtime assets, independently matching JS-B2/native emissions,
and a native-produced successor that reproduces its own C. Freeze historical
runtime dependencies before updating canonical assets; do not rewrite earlier
receipts or weaken their checks. Refresh the installed JS release through a
new checked snapshot and real self-hosting gates after final runtime integration.

## Completion

The native successor now reproduces its unpatched complete C exactly, independent
JS B2 agrees, and all eight live/cache, two negative and four program execution
gates pass. The public native launcher and restoration capsule are qualified.
Canonical runtime/template/driver identities moved together; the installed JS B2
was rebuilt and freshly self-qualified, with installed/relocated checks passing.
See the [final report](../../implementation/phase90/README.md) for timings,
production size, finite scope, failures and remaining performance work.

The initial legacy release smoke exposed a sandbox-dependent Node pipe capture
error. Identical bounded pipe/file diagnostics outside the sandbox passed with
byte-identical binaries. The unchanged smoke was rerun at a fresh path with
approved outside-sandbox execution and all resource guards retained. No production
host workaround or compiler semantic change was needed; both outcomes are kept.
