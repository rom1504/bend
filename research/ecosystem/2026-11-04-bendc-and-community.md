# Bend ecosystem survey: lessons for the self-hosted QBE compiler

Source inspection on 2026-11-04. Our checkout is `e9f4fc1` on
`selfhost/bootstrap`; qualified native selection remains Phase152 N2. This is
research, not a benchmark campaign or upstream migration. No external project
was built or executed and no public comments were posted.

The strongest finding is **architectural headroom worth measuring**, not an
established speed ratio. `bendc` is a serious alternative self-hosted Bend2
implementation with a different calling convention and memory policy. It also
offers examples of proofs attached to production transformations. Community
projects supply realistic workloads and several independently useful optimization
and correctness findings.

## 1. bendc: inspect its current source, not just its headline

Pinned repository: [Lulzx/bendc, `56edcc65`](https://github.com/Lulzx/bendc/tree/56edcc65b3527a75838011682c231072d5b46097).
The main file's downloaded Git blob was verified as
`cb128617e38e12d7355c334f35c11b23150beeca`. The GitHub connector returned empty
content for this >1MiB file; a read-only raw download supplied the actual source.
Other files were read through the GitHub connector.

### Actual implementation and complexity

- Bend implementations of parsing/checking, an executable Core IR, optimization,
  C and JS emission, GPU generation, AArch64 instruction emission and object writing.
- C runtime with tracing GC, optional reference counting, borrowed reads,
  early reclamation/reuse, work stealing and Metal support.
- Native backend writes Mach-O or ELF objects directly and links the separately
  compiled runtime/effect support. It is AArch64-only; native `!` calls use CPU.
- Self-reproduction, diverse double compilation, TinyCC and a separate C
  interpreter bootstrap have concrete scripts, not merely roadmap entries.

Current source line counts, counting newline-terminated physical lines:

| File | Lines |
| --- | ---: |
| `bendc.bend` |31,028|
| `check.bend` |8,581|
| `core.bend` |2,352|
| `asm.bend` |1,191|
| Imported embedded JS/channel sources |705|
| These compiler/import files combined |43,857|
| `rt/bendrt.h`, separately |4,941|

This excludes Base, proof modules, tests, generated seed and other runtime/host
files. Our qualified assembled compiler is66,399 lines, also a different scope.
The README's roughly22,000-line compiler and520-line runtime descriptions are
stale. This is not evidence of equivalent scope in one third of our code.
Eight proof modules add roughly18,000 lines of their own.

Sources: [compiler](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/bendc.bend),
[runtime](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/rt/bendrt.h),
[native design](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/README.md#the-native-backend).

### Published speed is striking but not comparable yet

The author reports2.13s compiling bendc to C with the C-built compiler,2.55s with
the direct-native compiler, and a3.5s check/codegen/assembly/link native build
versus20s through C/Clang. Other README sections contain older/different compiler
sizes and timings. These are author measurements on an Apple M4 Pro, with other
jobs running and best-of-N selection. We have not reproduced them. Our roughly
205s Phase156 result is a different compiler, source, host architecture, runtime,
input version and measurement setup. **Do not claim a60× or100× comparison.**

The [bootstrap script](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/bootstrap.sh)
and [selfcheck target](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/Makefile)
explicitly use `--no-check` and `BEND_NO_FREE=1`. This does not mean its normal
CLI skips checking: `Main.run2`, `Main.run4` and `Main.run5` call `Main.check`.
It does mean seed reproduction timings must not be presented as fully checked
compilation timings. Build time from committed C is another distinct metric.

Generated-program performance is mixed. Its published16-program/3-mode table
has bendc winning10 of48 combinations and upstream winning38; notably bad tree
cases remain. Its benchmark method uses interleaved best-of-three runs and
records GPU fallback diagnostics. This supports studying individual mechanisms,
not declaring its runtime generally superior.
[Table and caveats](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/README.md#the-official-runtime-benchmarks),
[actual harness](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/bench/official.sh).

### Three mechanisms most relevant to our profiles

**A. Ordinary calls and different lifetimes.** Each def becomes an ordinary C
function; self tail calls become loops, and constructor-building recursion can
use destination passing. Full calls are direct, partial calls build closures.
Tracing GC is the default general memory policy. Its compiler is deliberately
built without explicit early frees, leaving collection enabled; this is not
permission to leak all allocations. Optional RC makes its published compiler
and checker examples slower while reducing memory. This cannot alone explain
the apparent cross-project timing gap, but it is directly relevant to our
Phase153 ownership/reclamation/register-transport share.

The tradeoff is material: its runtime reserves a4GiB virtual stack per Bend
thread (`BEND_STK`), rather than establishing bounded native-stack consumption
for arbitrary non-tail recursion. Virtual reservation is not4GiB resident memory.
We must preserve our stack-safety obligations when considering ordinary calls.
[Function emission](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/bendc.bend#L9758),
[stack implementation](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/rt/bendrt.h#L2630).

**B. Native observations avoid reconstruction.** `String.cmp` returns original
strings, `String.eq` borrows them, `Map.bit` reads the original key, and
`Map.get`/`Map.has` walk the original trie instead of rebuilding the path merely
to return it. The runtime source explicitly describes the removed work; the C
emitter enables these natives. This is stronger evidence than a generic claim
that maps or strings are slow.
[Runtime implementations](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/rt/bendrt.h#L3444),
[emitter switches](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/bendc.bend#L25948).

We already have consuming String helpers and borrowed scalar observers. The
missing general capability identified in our [Phase153 report](../../implementation/phase153/README.md)
is preserving a selected borrowed descendant across a helper return while the
caller retains its root. Do not reimplement an existing String optimization and
count it as a new idea. Trace actual `lookup`/`f_find` consumers and their generated
ownership work first.

**C. High-level compositional optimization before machine emission.** Its Core
IR preserves explicit calls and argument relevance. Production applies monadic
expansion, beta reduction, known-constructor elimination, literal propagation,
dead lets and inlining before lower-level emission; specialization and fusion
operate on the same representation. This removes complete temporary computations.
It is not evidence that we need a universal new SSA IR: the useful lesson is
preserving enough common semantics to compose transformations.
[Core](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/core.bend),
[production pass composition](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/bendc.bend#L22664).

### Proofs are unusually useful, with explicit boundaries

Seven implemented Core passes have semantic proofs: erase, reduce applied
lambdas, resolve known constructors, eliminate dead lets, propagate literals,
inline and substitute. We verified production references to the same functions
at compiler lines22366,22667 and23579. The model is a fuelled evaluator with
abstract native operations and explicit compatibility assumptions.

These are not equivalent guarantees for every pass. Some proofs allow any
target result if the source fails; exact program equality can require a successful
result containing no closure. Lowering proves round-trip/scope properties, not
preservation of the source language's meaning. Fusion/specialization laws cover
instances, not the actual pass implementations. Concrete heap management,
effects, code generation and substantial simplification remain outside the claims.
[Laws](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/LAWS.bend),
[dead-result relation](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/DEAD.bend#L176),
[lowering boundary](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/LO.bend#L5).

The pinned push [CI run38428417048](https://github.com/Lulzx/bendc/actions/runs/38428417048)
passed proof checks in both checkers on Linux ARM/macOS. The CI commands are
`--check-only`, not independent Lean/BendTT `--verdict`; its own checker is a
port of upstream's. The Nov2 latest-upstream [weekly run41471048840](https://github.com/Lulzx/bendc/actions/runs/41471048840)
failed earlier tests and skipped proof steps. That is compatibility evidence,
not a failed theorem. Published conformance totals concern upstream2.0.34, not
an established qualification against today's upstream HEAD.

For us: prove a small transformation the actual compiler calls, with explicit
heap/error/effect obligations. Do not replace the independent final verifier or
native gates with a pure IR theorem.

## 2. External forks and contributor work

All PRs below were unmerged when inspected. Author timings are not ours.

| Source | Concrete finding | Relevance |
| --- | --- | --- |
| [PR2037](https://github.com/bendlang/bend/pull/2037), Sebastian Breguel, `b0975dc5` | Constructor telescope reuse for identical argument objects; skip the discarded final telescope continuation. Huge pathological improvement, ordinary checks around noise. | Find work whose result is genuinely unused; do not project pathological ratios or blindly transfer pointer-identity caches. |
| [PR2036](https://github.com/bendlang/bend/pull/2036), Nico Abril, `e827da8a` | Keep eligible wide parameters boxed until needed; open repeated boxed uses once. Reported fixture131→65 registers and Clang1.14→0.31s. Ownership/closure exclusions matter. | Explains why maximal flattening can enlarge live state and hurt both compiler and program speed. Relevant to our large continuation frames. |
| [PR2012](https://github.com/bendlang/bend/pull/2012), Victor Correa, `f27fd28e` | Direct native-array-to-list construction removes split/copy intermediates. [User replication](https://github.com/bendlang/bend/pull/2012#issuecomment-6591418014)0.894→0.261s, five alternating Linux runs, but no whole-application win. | General complete producer/consumer elimination with ownership-specific cases; honest transfer boundary. |
| [Issue2038](https://github.com/bendlang/bend/issues/2038), Backplane / `i2cjak/bend` | Large real application, paging and separate-compilation experiments; lower memory sometimes costs much more time. Parse-only prefixes and template-key collisions produced correctness failures. | Real scale stress and concrete invalidation hazards for our retained incremental work. Not a production cache to copy. |
| [PR1818](https://github.com/bendlang/bend/pull/1818), Oxura, `dcbf033f` | Local conversion memoization stores completed successful pairs; recursive key equality uses sharing shortcuts; explicit soundness invariant/fuel boundary. | Reuse established facts with precise identity, and measure the cost of comparing cache keys themselves. |

Backplane sources: [paging patch](https://github.com/i2cjak/bend/commit/1c474f0f052550dfd2bfe271341e8656c3db758a),
[separate-compilation findings](https://github.com/i2cjak/bend/blob/03c6a4cf87fd79cc388469383bf02718c3449add/docs/separate-compilation-experiment.md).
Also watch [draft deforestation PR2031](https://github.com/bendlang/bend/pull/2031);
its current dependent-signature exclusions and narrow observed benchmark coverage
matter more than its headline. This was a bounded survey, not a census of every fork.

## 3. User projects we should learn from

- **[ot-json1-bend](https://github.com/jasonphillips/ot-json1-bend/tree/4ea7b90d4755a32d02b43343edb9aac518e66183):**
  real collaborative-editing/ShareDB application, recorded sessions, differential
  tests, fuzzing and shrinking. Its [fastjs passes](https://github.com/jasonphillips/ot-json1-bend/blob/4ea7b90d4755a32d02b43343edb9aac518e66183/harness/fastjs/fastjs.ts)
  simplify closures, beta-reduce, move argument work into branches and turn
  recursion/list construction into loops. The build explicitly calls these
  unproved post-emission JS transforms: package timings are not stock upstream
  backend timings. Excellent corpus and hypotheses; lazy evaluation needs
  totality/effect/error restrictions before transferring to our supported domain.
- **[lawful-bytes](https://github.com/luiscleto/lawful-bytes/tree/ae92fdac52f3141a95d04c44978205dd0ca7d90a):**
  packed four-byte/U32 storage with wordwise operations and refinement against a
  list view. Its proof work caught a real search/masking bug. Useful model for
  verified representation changes in lexer/input storage; not merely another
  synthetic equality law. Related lawful-arrays and lawful-halves cover arrays
  and ordered balanced fork/join. Halves has O(k log k) splitting/flattening and
  assumes roughly balanced work; it does not provide a QBE scheduler for us.
- **[framebender](https://github.com/luiscleto/framebender/tree/a59b18d03cab794445d415e47c1950bea176f0cf):**
  VCF normalization with real text, sorting, batching and file handling. Its
  [benchmark](https://github.com/luiscleto/framebender/blob/a59b18d03cab794445d415e47c1950bea176f0cf/docs/BENCHMARK.md)
  pins versions/hardware, checks records, interleaves runs and reports weak cases.
  Native IO/compression/indexing is outside its proof boundary. Good additional
  pure kernels and small end-to-end fixtures; not a claim of fully proved native IO.
- **[bend2-lsp](https://github.com/don2e4/bend2-lsp):** pinned checker+Base,
  unsaved import overlays, proof/unsafe diagnostics, worker watchdog/replacement
  and tests. Useful frontend/conformance/cancellation cases. It wraps the upstream
  checker and is not an independent semantic oracle.
- **[akitaonrails/bend-tests](https://github.com/akitaonrails/bend-tests):**
  actual2.0.16 application ports, a total JSON parser and reports separating
  checking from expensive native construction. Good historical corpus; old
  missing-feature statements are not current ecosystem facts.

These are Bend2 leads. Older Bend1/HVM interaction-net projects should not be
treated as implementations of the current BendRT/proof/ownership architecture.

## 4. What I would do next

Keep the Phase156 publication gain and its planned narrow integration. Before
another broad QBE optimization campaign, the highest-information experiment is
an **identical-source cross-compiler workload comparison**, not another comparison
of each compiler compiling its own unrelated source.

1. Extract the same real checker/lowering/lookup computations already used by
   our fast loop. Establish one compatible source/Base revision and independent
   output oracle. Run them through upstream C, our qualified QBE and bendc C;
   try bendc's GC/no-early-free and RC policies separately. No AArch64 backend is
   required on our host. Charge setup, checking, output and cleanup consistently.
2. Compare instructions, allocation/ownership traffic, peak RSS, emitted size
   and complete execution time. Only then expand to compiling the identical
   compiler source, if all supported-language gates pass. This can falsify the
   tempting claim that runtime architecture explains most of our deficit.
3. If lookup traffic is decisive, test a borrowed-descendant-to-scalar consumer
   with a held root, explicit escape ownership and unrelated transfer. If
   scheduled calls/frames dominate, test a safe direct-call region without
   relaxing stack guarantees. If GC policy dominates, evaluate bounded phase
   lifetimes or a separately qualified tracing policy; never just suppress frees.
4. Attach one real semantic proof to the selected transformation, using a small
   executable model and explicit native assumptions. Keep all independent gates.
5. Add one bounded JSON1 or packed-text workload to the held-out corpus, rather
   than another arithmetic microbenchmark.

Priority: same-source runtime/calling-convention comparison first; borrowed
read/lifetime boundaries next; production-linked proof architecture and external
workloads alongside. A new backend, wholesale IR rewrite, automatic parallelism
or GC replacement is not justified merely by someone else's self-build time.

Parallelism deserves particular restraint: bendc reports its own compiler going
from0.85s to1.75s with implicit parallelism, and now uses task-age/site cutoffs.
That supports measuring grain size and total work before enabling threads. Our
qualified QBE runtime remains serial; these source ideas do not qualify a new
parallel route.
