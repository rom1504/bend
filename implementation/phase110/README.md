# Phase110 — ownership information that survives native lowering

[Design](../../design/phase110/ownership-laws-and-search.md) ·
[Experiment log](../../experiments/phase110/P110-001-owned-interfaces.md) ·
[Compiler guide](../../docs/self_hosted/OWNED_NATIVE_IR.md) ·
[Replay](../../selfhost/tools/performance/phase110/README.md).

Baseline `7fc45f3`, branch `selfhost/bootstrap`. The planned window is
2026-10-18 18:59:56–21:59:56 UTC. This report is being consolidated; final
accounting and the evidence manifest are added after the last bounded experiment.

The direct backend now preserves ownership into structured runtime operations,
accepts canonical checked entries and closed ordinary calls, and runs through a
qualified native Bend frontend. Its selected QBE policy uses **19.5% less worker
time on eleven fresh held-out reverse workloads** than Phase109's fused-QBE
baseline. On a separately matched compiler reverse kernel, it uses **14.7% less
time than the existing production Clang worker**. These are kernel results,
not a new whole-compiler or upstream speed ratio.

## What changed

The algorithms remain written in Bend. The pipeline preserves the original
checked `KDef` type alongside its `NativeErasedBody`, derives canonical entry and
closed-callee contracts, checks ownership operations, and lowers them into Nx.
Native requests emit QBE directly. A cached object supplies the production
allocator, tagged Terms and reference counts. The C emitter is an independent
backend control for the same graph; C strings and cproc are not intermediate
steps in ordinary direct worker compilation.

```mermaid
flowchart TD
  A[Native Bend parser and checker] --> B[Checked types plus erased bodies]
  B --> C[Canonical entry and closed-callee admission]
  C --> D[Owned operations and credit checks]
  D --> E[Structured runtime loads, stores and branches]
  D --> F[Conservative runtime fallback]
  E --> G[Nx library]
  F --> G
  G --> H[QBE and assembler]
  H --> I[Native worker plus cached production runtime]
  L[Local laws and mutation controls] -.-> D
  M[Independent graph and lifetime observations] -.-> I
```

Previously, even fused reconstruction crossed opaque helper boundaries for
known constructor tags, field positions and ownership transfers. The new private
runtime IR makes these facts available to machine lowering. Single-context
loads and the reference-count-one path are explicit; shared and static objects
retain the conservative fallback. A correspondence verifier regenerates the
private template from admitted ownership operations. It is a structural gate,
not a mathematical proof of runtime or machine semantics.

Ordinary calls transfer one ownership credit per argument and return one credit.
A returned physical word may alias an argument. Scratch transfers finish before
another call, runtime imports cannot masquerade as owning source callees, and
generated-name namespaces are checked. Canonical `String` and `List<&2,String>`
arguments/results support one to eight live arguments. Generic specialization,
arbitrary datatypes, closures, indirect calls, effects, parallel scheduling and
device execution remain outside this slice.

## Measured runtime results

![Separate worker comparisons](figures/performance.svg)

The final training comparison uses five alternating rounds, seven frozen input
families and eleven immutable worker binaries. Selection requires at least a 3%
gain over the relevant incumbent and improvement in every round. Extra complexity
does not win merely by producing the smallest noisy median. The final eleven
held-out inputs were frozen before selection and first executed afterward.

| Worker | Training / fused QBE | Fresh held-out / fused QBE | Decision |
|---|---:|---:|---|
| Compact general runtime IR, QBE | 0.7943× | **0.8051×** | Selected experimental QBE policy |
| Stored-field refinement, QBE | 0.7811× | Not selected for final evaluation | Incremental gain below 3% |
| Wrapper reuse, QBE | 0.8157× | Not selected for final evaluation | Slower than compact general |
| Combined refinement, QBE | 0.7920× | Not selected for final evaluation | Incremental gain below 3% |
| Delayed-load refinement, QBE | 0.7832× | Not selected for final evaluation | Magnitude/round rule fails |
| Wrapper reuse, Clang control | 0.6211× | **0.6582×** | Fastest control; not a QBE-backend replacement |

The QBE held-out geometric mean improves 19.49%; four individual cases regress
slightly, by 1.07–2.21%. Unique deep List/String cases take about 0.51–0.54× the
fused baseline time. Shared-root cases have less removable work. The Clang
control improves all eleven cases and the geometric mean by 34.18%.

![Per-input held-out results](figures/heldout.svg)

The separate `production-compare01` run uses the preserved production Clang
binary and the new QBE worker, the original thirteen semantic controls, five
alternating rounds, and 20 repetitions of 65,536 List<String> cells:

| Matched worker | Median worker time | Time / production Clang |
|---|---:|---:|
| Existing production Clang | 13.966 ms | 1.0000× |
| Selected direct QBE | 11.914 ms | **0.8531×** |

All five paired ratios are below one (0.806–0.856). This comparison uses a direct
current denominator; it does not multiply historical ratios. The existing reverse
worker already had a direct loop, so there is no trampoline-removal credit.
The compiler source used as input data in some reverse cases does not make those
measurements complete parser, checker or compiler executions.

The production comparison receipt omitted an explicit GCC pin because its tool
name filter missed the versioned executable basename. A subsequent read-only
audit found the current executable's exact hash equal to the historical tool.
Worker/runtime objects and the compared production binary are pinned; this
receipt limitation remains documented rather than retroactively rewriting it.

## Why some attractive variants did not win

Making ownership operations visible was useful. Moving every operation into a
more complicated helper interface was not. Typed pair returns, stored-child
refinements and wrapper recycling have different register and stack costs.
QBE and Clang prefer different code shapes.

On one explicitly selected unique-list path, machine inspection counts 100
instructions and five stack accesses for compact-general QBE. Delaying the old
child load reduces that to 79 instructions and two stack accesses, but does not
earn the required measured gain. It also leaves only six selected instructions
between the next-node load and the backedge, versus 56 in the simpler path.
Lost memory-latency overlap is a plausible explanation, not measured cycle
attribution. Instruction count alone is an inadequate cost model.

The final choice deliberately retains the simpler QBE profile. The original
generic Take/List.last comparison also showed essentially no gain (1.0147× the
fused control in that screen). Faster reverse does not imply every source
function becomes faster. See [ABI analysis](abi-audit.md) and the archived
disassembly/path selections for the exact assumptions and excluded paths.

## Laws and correctness evidence

Twenty-three distinct local laws were elaborated without opaque definitions and
checked independently through the existing BendTT/Lean path:

- Five field/selector laws and five additional reconstruction laws.
- Four stored-field invariance laws.
- Nine exclusive-wrapper reuse laws.

Fourteen well-typed model mutants distinguish the laws from mere typechecking:
the changed law-free models are accepted, while the unchanged laws reject them
in the source checker. That is not fourteen negative independent-kernel runs.
Two further mutations change actual compiled consumer instructions while leaving
the ownership graph unchanged; exact runtime observations catch the wrong field
and the lost remaining child. This demonstrates complementary coverage from
model laws and physical execution, not whole-compiler correctness.

The runtime bridge still needs concrete layout, writer, separation and
single-context premises. Stored-field and wrapper laws do not prove those
premises automatically. The actual probes cover reference counts one/two,
shared/static inputs, overlapping physical children, allocator handoff,
retained aliases, both release orders, scratch state and zero live allocations.
The selected general Take probe passes 120 observations; selected reconstruction
and wrapper probes each pass 70. Additional delayed-path probes retain their
own scope and results. These totals overlap and are not a count of unique
language-conformance tests.

Ordinary-call controls include actual compiler `nt_append`/`nt_reverse`, Base
List selectors, and independently frozen call shapes. Fresh append and call-shape
held-outs pass. Typed entry/closure controls refuse unsupported private callees,
generic parameters, erased/type mismatches and runtime-name impersonation.
Details are in [IR audit](ir-audit.md), [law audit](laws-audit.md) and
[independent coverage audit](coverage-audit.md).

## Native image and a useful failed experiment

The first general image embedded the complete 75,064-character Base text for
exact authentication. Emission exceeded its 300-second guard. A minimal probe
isolated a size-sensitive cliff: 1,024 characters emitted in 0.718 seconds;
75,064 characters exceeded 45 seconds. Splitting the text into 74 String helpers
also exceeded 45 seconds.

Source inspection explains a credible mechanism. Strings expand into constructor
syntax, while static interning caps the complete image at 65,536 words. The full
text needs 150,128 constructor words. Function splitting does not remove that
global representation pressure.

The successful mitigation packs the identical ASCII bytes into 18,766 U32 words,
requiring 37,532 list words in isolation. The comparator still checks every full
input codepoint, exact length and empty suffix. It is not a hash or truncated-byte
comparison. Eleven hosted controls and fourteen actual native controls pass,
including non-ASCII characters with the same low eight bits. Minimal emission
takes 4.825 seconds and machine construction 2.492 seconds. This is evidence for
a representation fix, not a precise attribution of every compiler stage.

The integrated `native-source05` then emits in **148.836 seconds** and builds
through cproc/QBE in **87.720 seconds**, with a 3.086 GB peak process tree.
These guarded acquisition clocks total 236.56 seconds and are paid once, not on
every direct worker request. The compiler/static cap and runtime are unchanged.

The resulting native image passes:

- Eight exact QBE/C products for four canonical closed roots, plus four refusals.
- Execution of those eight actual native-emitted products: 36 full-value,
  alias-release and heap-balance observations per backend.
- Actual Base `String.append`: 20 independent observations per backend, including
  Unicode, sharing and overlapping inputs. Qualified non-tail depth is at most
  1,024 first-input cells; arbitrary stack depth is not claimed.
- Eight unchanged products for the existing reverse/tail/last/append fixed
  contracts, followed by the old thirteen-case reverse execution gate on both
  QBE and Clang products.

The general command constructs its own checked Base seed and same-source closure.
It does not accept an unchecked caller seed or a flag saying that facts are
trusted. Requested entries must be reachable from checked `main`. Ordinary
requests run native Bend directly; acquisition still uses the mature C backend,
cproc/QBE and GNU tools. See [native usage](../../selfhost/tools/performance/phase110/native/README.md).

## What the research-loop measurements mean

![Research-loop accounting](figures/research-loop.svg)

An instrumented pass preserves all eleven original semantic fixtures and checks.
Only 2.93% of its outer clock is worker execution; observation is 52.18%, release
19.46%, graph setup 16.93%, and lifetime accounting/close 8.47%. Even eliminating
the worker cost would improve that fixed evaluation only 1.0302×.

The initial twelve-choice training campaign took 247.683 seconds. Calibrated
repetitions and a changed candidate matrix made later screens much shorter, but
that is an experimental-method change, not recursive compiler acceleration.
The final eleven-choice/five-round screen took about 56.9 seconds. Binaries and
the runtime are cached; expensive observation still dominates many cases.

A faster worker has not yet been substituted into the builder's own critical
path. There is no frozen-builder versus updating-builder causal experiment and
no demonstrated increase in validated discoveries per hour. The
[research-loop audit](research-loop-audit.md) specifies the smallest paired
experiment that could test that claim, including upgrade cost and break-even.

## Ambition reached and remaining boundaries

| Plan level | Result |
|---|---|
| 1×: useful ownership interface and meaningful laws | Implemented, measured and mutation-tested |
| 10×: composable calls, broader admission and bounded policy selection | Implemented; native request/worker gates and fresh evaluation pass |
| 100×: structured runtime decisions and measured improvement machinery | Runtime IR, refinements and loop accounting implemented; sustained recursive acceleration and full direct self-hosting remain unproved |

The installed production compiler and Phase108 full-language cproc/QBE reference
remain unchanged. Phase110 does not remeasure broad45 program runtime, production
B1/B2 compilation or upstream conformance. The last broad compilation figures
remain Phase105: prepared45 B1/B2 0.499×/0.517× upstream time, live Base
2.384×/2.231×, and prepared full compiler source 2.602×/2.965×. Those clocks and
denominators must not be replaced by this phase's faster kernel numbers.

The next high-value step is to preserve these ownership operations across more
real compiler computations, especially calls and allocations, while keeping a
small unchanged oracle. A separate data-constant representation would avoid the
literal cliff more generally. Expanding the machine backend or building another
full image without a smaller supporting experiment is not justified by this
phase's evidence.

## Evidence and accounting

Final source/role counts, elapsed-time accounting and a verified evidence capsule
are recorded here after consolidation. Failed image builds, rejected policies,
early unsupported facts and supervision failures remain evidence; they are not
silently converted into successes. No PR comment was posted.
