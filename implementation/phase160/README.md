# Phase160 — what bendc teaches us about our actual self-compilation

We can now execute **the same complete Bend compiler implementation** through
bendc/C and our QBE backend, holding its input, checking, optimization, final
verification and complete output fixed. On the full compiler input, the first
fresh pair is **223.237s QBE → 167.602s C**, a24.92% time reduction, at
**1043.4 → 4074.7MiB peak RSS**. Both emit exactly118,227,421 QBE bytes.
The much larger gains on smaller inputs do not transfer unchanged. A subsequent
single-setting collection-budget test reaches **138.383s**, 38.01% less than QBE,
at 5057.3MiB RSS. The complete output remains identical.

This is a useful execution comparison, not a promoted compiler or evidence that
switching to bendc makes our self-build take a few seconds. It measures
source-to-QBE, including live Base preparation and process teardown, excluding
machine construction. The compiler algorithms remain written in Bend.

[Design](../../design/phase160/README.md) · [Measurements](metrics.json) ·
[Boundary audit](../../experiments/phase160/cross-build-audit.md) ·
[Work census](../../experiments/phase160/comparison-boundaries.md) ·
[Reproduction](../../experiments/phase160/README.md).

## The controlled comparison

| Compiled input | Our QBE-built compiler | Same compiler, bendc/C-built | Time reduction | Peak RSS, QBE → C |
| --- | ---: | ---: | ---: | ---: |
| Ordinary Map,1.8KB | 2.953s | 1.157s | 60.83% | 33.4 → 228.3MiB |
| Actual checker source,182KB | 24.117s | 10.689s | 55.68% | 141.7 → 680.6MiB |
| Full compiler source,3.085MB | 223.237s | 167.602s | 24.92% | 1043.4 → 4074.7MiB |
| Same full input, C collection factor1 | Same223.237s reference | 138.383s | 38.01% | 1043.4 → 5057.3MiB |

One fresh observation per role/input, one CPU3 lane, identical input/Base and
independent whole-file QBE oracle. These are screens, not repeated medians or
confidence intervals. The stronger inference is that a large small-program
advantage can shrink materially on actual self-compilation.

The executable source is Phase156's independently checked complete request
closure, with its original `old` branch selected in both roles. This keeps all
reached compiler work, while excluding unrelated CLI facilities. It is not the
qualified Phase152 executable and its223s is not a new qualified cold-build
score. Source whitespace normalization needed by bendc passes exact independent
parser equivalence over4,890 rows/35,201,512 canonical bytes, excluding only
source spans. Complete products equal the separately qualified QBE oracle.

The C image uses current bendc56edcc65, pinned Clang-O2, tracing/no-local-free
policy, private Phase159 bounded allocator search, and **BEND_UNBOX=0**.
Nine legacy IO registration arities are adapted explicitly. QBE retains its
ordinary ownership runtime. The comparison therefore bundles code generation,
calling convention, representation and memory-management policy; it does not
isolate Clang or establish default bendc performance. Both request paths still
check source and verify their emitted IR. Disabling bendc checking while
acquiring the independently checked C image does not disable request checking.

## Important negative results

The unmodified current bendc seed did not emit our request compiler within180s
with checking or120s without it. Top-level emitter parsing plus AST printing
took1.014s; the separate checker-parser path took10.693s. These are different
parsers and neither is the whole pipeline. The bounded-search seed unlocked
complete emission in40.762s, showing that parsing was not the stalled step.

The first acquired C compiler then **failed ordinary Map correctness**. Source
inspection found a concrete code-generation error: the unboxed call passed a
function list where an outer error String belonged. The malformed diagnostic
was consistent with that exact wrong projection. This failure supplies no
performance result. Disabling the existing unboxing policy, without patching
the compiler algorithm or repairing generated C by hand, removes that path and
passes all three complete output comparisons. See the
[counterexample audit](../../experiments/phase160/request-failure-audit.md).
This is a bounded compatibility result, not general qualification of bendc.

The final C image cost40.586s emission plus93.330s Clang construction, excluding
the separate inherited source check/equivalence gate. Earlier failed acquisition
and exploratory builds also count in [research cost](cost.json). A new C image
is not free just because its subsequent request is faster.

## Full-scale profiling explains why the pilot gain shrinks

The accepted full-input capture has1,672 physical CPU samples,99.94% sampled
thread CPU coverage,99.94% symbol resolution and zero loss/overruns. The earlier
8ms capture had36 overruns and is retained as **rejected**; its counts are not
pooled. The100ms capture still passes the exact118MB output gate. It is a
diagnostic, not an additional clean timing. See [profiles.json](profiles.json).

| Physical work in the C-built compiler | Accepted sample share | Approximate clean CPU equivalent |
| --- | ---: | ---: |
| Tracing, collection and rescanning | 55.62% | 93.19s |
| Allocator refill/search | 5.86% | 9.82s |
| Generic closure application, `apply` | 7.95% | 13.33s |

These are disjoint leaves, not inclusive stages. All named GC helpers together
account for61.66%; inlined runtime work can appear under generated functions.
One fixed sampling period can alias, and the seconds scale a separate clean CPU
measurement. Removing100% of these costs is not a realistic speed estimate.

The one-variable falsifier changes only `BEND_GC_FACTOR` from0.5 to1 in the
same executable. Its next allocation budget is the maximum of live-heap-scaled
headroom and the existing minimum/growth allowance. Full request time decreases
**167.602 → 138.383s (17.43%)**; RSS increases **24.12%**. All independent output
bytes still match. This single screen demonstrates collection-cadence
sensitivity. It neither proves region allocation safe nor qualifies a new
default runtime; no memory guard or semantic gate was relaxed for the test.

This changes the interpretation substantially: the C-built compiler is not
spending all167s executing the logical algorithm. Repeatedly tracing the live
compiler graph consumes most of the sampled time. Our QBE profile instead shows
substantial local ownership/reclamation/transport. Simply copying either memory
policy is therefore not a convincing route to few-second self-compilation.
We need fewer temporary objects, cheaper ownership boundaries and clearer data
lifetimes as well as efficient ordinary execution.

The emitter already streams output. `p134e_registered` retains original segments,
derived functions, legacy entries, IDs/indexes/signatures and catalogues while
the cursor produces temporary text. Do not blame a retained118MB output String:
that is not the maintained path. Separating durable admitted IR from temporary
work is a grounded hypothesis; deciding when each graph dies still requires
accounting for its remaining verifier, fallback and public consumers.

The C profile also exposes real control-as-data overhead. A sampled `L4672`
belongs to `index_find`; its generated C builds both conditional branch closures
and invokes `kc`/`apply` to choose one. This resembles the old
[Phase83 bootstrap finding](../../research/compilers_architecture_and_techniques/phase83/stage-gap.md),
not a newly invented mechanism. Our direct JS backend already removes many such
selectors, and earlier broad source expansions yielded only small gains. This
new C observation does **not** prove that the same closure overhead survives in
the current hot QBE worker or explains all GC. Inspect the actual admitted path
and count allocation sites before proposing a source-wide rewrite.

## What the actual self workloads differ on

Current bendc's matching own source/imports contain about1.641MB/4,036 textual
declarations. Our qualified input contains3.085MB/8,265 rows before Base.
Historical bendc's smaller published source is a third, separately pinned
version. Never compare these counts or clocks as identical workloads.

| Current bendc self-emission policy | Unchecked | Checked |
| --- | ---: | ---: |
| Original current runtime | 16.974s | 39.728s |
| Same seed C, private bounded-search runtime | 5.981s | 11.374s |

Each is one observation; all four exactly reproduce the current4,628,175-byte
seed C. This transfers the Phase159 runtime hypothesis to real bendc
self-emission. It is not a speedup of our compiler. The historical published
source remains4.499/8.810s medians from Phase158, with different source/runtime.

Our native compiler has4,291 source-owner groups but73,926 emitted QBE functions,
including56,649 generic continuation segments and private workers. Current
bendc emits4.6MB C for itself; ours emits118.2MB low-level QBE. These are different
abstraction levels, not a25× instruction ratio. Both implementations transform
the loaded program; historical bendc is not secretly an allocation-free,
reachable-functions-only compiler.

The existing complete QBE profile places about101s in raw lowering, initial
optimization and output/cleanup, plus63s in parse/load and checking/publication.
Its physical ownership/allocation/reclamation/register-transport share is42.71%,
overlapping those stages. Removing checks cannot explain or close the gap and
would invalidate the comparison. The complete work census keeps nested timers
and differing declaration definitions explicit.

## A separate concrete source-work opportunity

An exact root-main source closure preserves every mapped runtime owner while
reducing the native acquisition input from3,085,157 to1,697,879 bytes and8,265
to5,007 declarations. It retains294 types/550 laws and passes an independent
whole-book source check with zero holes. Retained declaration bytes/order and
paired law/definition groups are exact. Maintained JS/C implementations remain
in the repository; this is a target-specific assembled input.

This is **44.97% fewer source bytes**, not a44.97% measured build-time gain.
Removing type-only definitions may renumber constructors or change tables.
Native output/ABI and self-reproduction qualification remain pending. It cannot
by itself remove the backend work for the surviving runtime owners. The
parse/check envelope suggests a useful but limited acquisition saving; a
proportional28s saving within63s is a hypothesis, not an observation.

## What to do next

1. **Test compact lifetime-bounded compiler work.** Preserve the admitted durable
   graph while making one complete per-function lowering/emission computation
   avoid temporary pointer graphs and repeated ownership/continuation transfers.
   Include output conversion and destruction in the measurement. The accepted
   C profile and old QBE profile identify different expensive treatments of the
   same graph-heavy work. The goal is to remove that work, not select the better
   of two costly memory policies. First capture actual allocation/retention by
   source owner; use the existing source-rooted profiler and whole-output oracle.
   A new small speed result must transfer to full source before integration.
2. **Qualify the target-specific source closure as an independent quick win.**
   It is already prepared and source-checked. Compile original full source with
   the resulting image, audit any constructor/table changes, then measure its
   smaller-input self-build. Keep all JS/C/QBE functionality in maintained source.
   Roughly10–15% whole-build saving is a planning hypothesis from the frontend
   envelope, not a forecast established by the44.97% byte reduction.
3. **Audit hot control/representation boundaries before adding passes.**
   Compare `index_find`, borrowed readers and closed recursive regions across
   actual C/QBE machine paths. Reuse the existing verified selector/borrowed-call
   machinery when possible. Do not redo Phase83's source-wide branch expansion
   or claim that all generic `apply`/GC time is removable.

The ambitious route to50s combines less source work, compact persistent facts,
short-lived per-function state and direct stack-safe execution. This experiment
does not establish a5–10× gain or justify replacing the whole backend. It does
provide a full-input executable ceiling and a working oracle for deciding which
cross-layer changes are worth trying. The138s diagnostic is useful evidence of
headroom, not the new qualified compiler build time.

## Scope and preservation

Production source, qualified Phase152 N2 and installed JS/C/QBE selections are
unchanged. No45-program campaign or new full fixed-point qualification was
needed for this research-only comparison. Exact QBE equality on the three
measured requests preserves those products, not all possible program behavior.
Checking, finite output equivalence and mathematical proof remain distinct.

Two bounded agents audited feasibility, source work and the independent
comparison. Root owned the serial target lane. Full C requests explicitly used
a6GiB RSS cap after smaller memory observations, retaining16GiB available RAM
and the5GiB disk reserve; peak child RSS reached4.94GiB in the cadence test.
No OOM occurred. Only three
already archived Phase153 duplicate raw products were pruned under authenticated
receipts; no phase-directory deletion. Fresh equal outputs were deduplicated
after timing and byte validation, never used as target inputs or overwritten.

All successes, timeouts, correctness failures, profile-quality refusals, source
bridges and methods are retained in the content-deduplicated evidence capsule.
The prepared complete-parser fallback was not executed once the full compiler
comparison became possible. Keeping that unrun contingency is not a claimed
measurement or a second maintained compiler.

The23 guarded jobs consumed28.30min of serial target-lane time:

| Work | Guard wall time |
| --- | ---: |
| Private seed/request acquisition | 6.22min |
| Complete request comparisons | 9.59min |
| Full diagnostic profiles, including rejected capture | 5.74min |
| Failed acquisition/correctness attempts | 5.03min |
| Current bendc own self-emission | 1.25min |
| Parsing, source check and equivalence gates | 0.47min |

This excludes source analysis, agent work, preparation, reporting and evidence
packaging; it is not total research time or quota consumption. No quota telemetry
was available. Rejected attempts are included rather than timing only successes.
