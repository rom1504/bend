# Phase190: register and memory optimization investigation

**The full native45 screen improves geometric-mean program runtime from 3.980427× to 3.083793× our mature C backend**, or **0.774739× the freshly timed frozen x86 baseline (22.526% lower time)**. All 45 programs pass exact-output observations; 44 are runtime eligible. The 38 eligible held-out programs reach **0.778100× baseline**. The ≤2× C target and 0.5× stretch remain unmet; 37/44 candidate cases still exceed 2× C. The largest regression is `local-pair`, **13.393% slower than baseline**.

The compiler optimizations and admission checks are written in Bend. Host adapters freeze inputs, transport checked API bytes, build/link exact products, run independent output observers and time native executables. The selected compiler now has actual native N1 acquisition and a 45-program finite gate; the broad runtime products below were emitted by that N1. N2 self-compilation, all64 backend cases, all10 runtime controls and exact N2→N3 object reproduction pass. N2 reproduces all45 measured benchmark objects and135 linked code/data sections. Installed promotion is separate.

[Full runtime table](runtime-summary.md) · [Runtime data](runtime-summary.json) · [Design](../../design/phase190/README.md) · [Hypothesis records](../../experiments/phase190/README.md) · [Legality scope](legality.md) · [Machine audit](baseline-machine.md) · [First-screen evidence](first-screen.md).

## Qualification status

| Required campaign outcome | Status at this report cutoff |
| --- | --- |
| Selected full source and switches | Frozen `selected-source01/compiler.bend`, SHA-256 `60b0b0265bca50d423beb865237800f53eeeb9f2e7caed270bf7be39933068d7`; policy 2 and nine experimental Boolean switches enabled |
| Selected-bundle development measurement | runtime06 completed on all six development cases; four balanced rounds |
| Held-out transfer | 39/39 observed, 38 ratio eligible; held-out geometric mean 0.778100× baseline |
| Full native45 runtime aggregates | 45 cases complete, 44 eligible; candidate 3.083793× mature C, 0.774739× baseline |
| Checked-hosted/native product comparison | Six development objects and 18 linked `.text`/`.data`/`.rodata` sections exactly equal |
| Actual native compiler acquisition and finite qualification | QBE-produced candidate **N1** acquired in 159.472s; native45 passes 45/45 in 99.420s |
| Native reproduction and broader gates | N1→N2 succeeds in 241.793s; actual N2 passes all 64 backend cases; N2→N3 reproduces the exact object in348.274s. All10 runtime controls pass; all45 N1/N2 benchmark objects and135 linked sections equal. |
| Installed release | Phase189 retained; no installed-selection or public-command promotion is performed in this campaign |
| Final retention closure and whole-campaign cost | All59 guarded jobs closed;46 successful/13 failed;39.582min guarded work including54.984s failures. Candidate and baseline artifacts retained. |

## Full native45 runtime and held-out transfer

The [retained full summary](runtime-summary.json) is a byte-for-byte copy of `broad-summary01.json`; its [readable table](runtime-summary.md) includes every case. [broad-runtime02](../../selfhost/build/phase190/broad-runtime02/report.json) uses three position-balanced rounds for C, frozen baseline and candidate. It authenticates 565 input pins and revalidates 461 pilot and 405 timed output observations. `scalar-region-0` remains correctness-only, with no ratio. No flagged case is excluded. Held-out means excluded from this campaign's tuning: several cases are variants of familiar families, not independently sampled new languages or algorithms.

| Population | Observed / eligible | Baseline / mature C | Candidate / mature C | Candidate / baseline |
| --- | ---: | ---: | ---: | ---: |
| Full catalog | 45 / 44 | 3.980427 | 3.083793 | 0.774739 |
| Development | 6 / 6 | 4.448932 | 3.353552 | 0.753788 |
| Held-out | 39 / 38 | 3.911103 | 3.043229 | 0.778100 |

All ratios use **our mature C backend** as the C denominator, not upstream C or QBE. Against C, the baseline has 40/44 cases >1.1× and 40/44 >2×; candidate has **40/44 >1.1× and 37/44 >2×**. Mean positive natural-log slowdown decreases **1.450104→1.250028**. Against baseline, candidate has one case >1.1×, none >2×, and mean positive log slowdown **0.003076**.

Fixed-equivalent workload sums are **10,181.843 ms C / 48,173.809 ms baseline / 38,881.989 ms candidate**. Candidate/baseline total ratio is **0.807119×**, candidate/C **3.818757×**. These project original catalog repetitions from measured per-invocation medians; they are not adaptive batch weights or wall times.

Three eligible cases regress versus baseline: **local-pair 1.133934× (+13.393%)**, **variation-editdist-3-123 1.004854× (+0.485%)**, and **editdist 1.004831× (+0.483%)**. The other 41 eligible cases improve. The larger local-pair regression is retained as a concrete limitation; no source or oracle was changed to hide it.

Four max/min dispersion flags exceed 1.10×: **raytrace/C 1.147493×**, **scalar-region-8192/candidate 1.135000×**, **variation-tree-bitonic-6-17/candidate 1.101523×**, and **coverage-closures-64/baseline 1.108911×**. They are review triggers, not automatic exclusions or significance tests.

Existing runtime-report family aggregates show the remaining gap. Equal-source geometric mean across 23 source groups improves **3.999882×→3.113974× C**. Selected family geometric means below include the largest remaining deficits and the fold/closure mechanisms; all families remain in the raw report.

| Family | Baseline / C | Candidate / C |
| --- | ---: | ---: |
| local-pair | 7.652664 | 8.677619 |
| editdist | 7.724380 | 7.726965 |
| lexer | 6.135855 | 5.175386 |
| test-evening-program | 5.576568 | 5.080966 |
| tree-bitonic | 5.340154 | 4.824309 |
| map-churn | 5.178638 | 4.719168 |
| mandelbrot | 7.991654 | 4.553184 |
| local-fold | 7.662182 | 3.002748 |
| closures | 0.231143 | 0.085034 |
| list-pipeline | 0.954081 | 0.770759 |

The independently reauthenticated [family/fixed-work diagnostics](runtime-diagnostics.json), generated by [family-diagnostics.py](../../selfhost/tests/phase190/family-diagnostics.py), give equal weight to each of **22 families** after geometric averaging within a family: **3.940599×→3.129292× C**, candidate/baseline **0.794116×**. Positive fixed-work excess over C, summing only positive per-case time deficits at original catalog repetitions, falls **38,095.184→28,872.360 ms**. Candidate’s positive excess over baseline is **228.052 ms**. These diagnostics retain every eligible case and do not replace the historical equal-case 44-case geometric mean.

The direct-object compiler still has material residual gaps in pair, edit distance, lexer and tree workloads. This corpus-wide improvement does not meet the requested ≤2× C objective, establish causality for individual combined changes, or qualify a release.

## What was investigated

- [H1](../../experiments/phase190/H1-registers.md): loop/invariant-weighted saved-register placement and bounded liveness across control edges. The combined alpha screen reduced frame traffic but regressed fold runtime.
- [H2](../../experiments/phase190/H2-predicates.md): direct comparison/branch emission and a repeated-predicate certificate requiring every read to have an adjacent matching producer. It does not assume repeated names are SSA values.
- [H3](../../experiments/phase190/H3-physical-operands.md): use physical register/memory operands directly where width and alias rules permit; retain scratch paths otherwise.
- [H4](../../experiments/phase190/H4-joint-allocation.md): joint coloring across four saved and five caller registers with reserved-home, interference, incoming-ABI and call-crossing checks.
- [H5](../../experiments/phase190/H5-caller-preference.md): prefer a legal caller register before the full color search. The incremental runtime change was small.
- [H6](../../experiments/phase190/H6-local-values.md): bounded straight-line alias/width facts and selected modulo-U32 arithmetic cleanup, followed by existing dead-code elimination.
- The runtime06 bundle additionally enables complementary-branch simplification and copy-affinity coalescing. Its incremental gain combines both additions; no isolated causal contribution is claimed.

These rules operate after native IR admission and retain fallback paths. Structural arguments and finite controls are not a BendTT theorem, an independent proof of interference-graph completeness, or a proof of whole-compiler correctness. The [legality note](legality.md) states those boundaries.

## Development evidence retained without exclusions

| Screen and candidate | Baseline / C | Candidate / C | Candidate / baseline | Limitation |
| --- | ---: | ---: | ---: | --- |
| [01: alpha](../../selfhost/build/phase190/development-summary01.json) | 4.501827 | 4.360254 | 0.968552 | Three balanced rounds; fold +8.280%; tree dispersion |
| [02: operands](../../selfhost/build/phase190/development-summary02.json) | 4.459956 | 4.234034 | 0.949344 | **Four roles/three rounds unbalanced**; fold dispersion |
| [03: joint bundle](../../selfhost/build/phase190/development-summary03.json) | 4.450419 | 4.016364 | 0.902469 | Four balanced rounds; no >1.10× spread flag |
| [04: caller preference](../../selfhost/build/phase190/development-summary04.json) | 4.447879 | 3.994628 | 0.898097 | Four balanced rounds; only 0.372% below same-run joint |
| [05: local values](../../selfhost/build/phase190/development-summary05.json) | 4.463038 | 3.868291 | 0.866739 | Four balanced rounds; expression baseline spread |
| [06: selected bundle](../../selfhost/build/phase190/development-summary06.json) | 4.442246 | 3.368413 | 0.758268 | Four balanced rounds; final expression spread 1.175000× |

Each row freshly times the retained executable baseline and C reference. Cross-row ratios are not paired ablations. The ~9.7% joint result combines allocation, operand selection and predicate changes; no isolated causal allocation gain is claimed. Single-screen medians and max/min flags do not establish significance.

Screen02 operands regress versus same-run alpha on numeric (+0.301%), ray (+1.210%) and tree (+1.942%) despite improving the geometric mean by 1.924%. Its fold C/baseline max/min spreads are 1.110000×/1.122549×, and role positions are unbalanced. Screen04 caller preference regresses fold 0.143% versus joint, with map unchanged. These observations remain part of the record.

Screen05’s local-value bundle medians are retained below. Expression baseline spread is **1.119617×**, over the 1.10× review threshold; it remains included. Local values regress expression **0.750%** and tree **2.256%** against the same-run caller parent.

| Development case | Local / C | Local / baseline | Local / caller |
| --- | ---: | ---: | ---: |
| local-fold | 6.292032 | 0.808693 | 0.924041 |
| coverage-numeric-recurrence-256 | 3.104247 | 0.839789 | 0.968675 |
| variation-ray-active-64-2440 | 2.800640 | 0.825011 | 0.905032 |
| coverage-map-churn-32 | 4.584380 | 0.892205 | 0.979926 |
| coverage-expression-32 | 2.674251 | 0.889667 | 1.007500 |
| tree-bitonic | 4.996059 | 0.953290 | 1.022556 |

All six local-value cases exceed both 1.1× and 2× C; none regresses versus the frozen baseline. Mean positive natural-log slowdown is **1.352813 against C**, zero against baseline. Fixed-equivalent workload sums are **1,780.021 ms C, 7,441.852 ms baseline, 6,704.000 ms caller and 6,419.230 ms local**. These use original catalog repetitions and per-invocation medians, never adaptive calibration counts. They are not wall times. The catalog’s zero-work case remains correctness-only and is absent from these six.

## Selected bundle: runtime06

All six improve versus the frozen baseline. The geometric-mean ratio is **0.873025× same-run local** (12.697% lower time). Fold reaches **0.367119× baseline (63.288% lower time)** and **2.848058× C**, but map and expression regress **3.827% and 0.982%** versus local. Expression’s final-role spread is **1.175000×** and stays included. These are development observations, not held-out transfer or significance claims.

| Development case | Final / C | Final / baseline | Final / local |
| --- | ---: | ---: | ---: |
| local-fold | 2.848058 | 0.367119 | 0.448047 |
| coverage-numeric-recurrence-256 | 2.967467 | 0.808754 | 0.974925 |
| variation-ray-active-64-2440 | 2.758473 | 0.834255 | 0.988525 |
| coverage-map-churn-32 | 4.811270 | 0.933092 | 1.038269 |
| coverage-expression-32 | 2.703624 | 0.903355 | 1.009823 |
| tree-bitonic | 4.816622 | 0.910400 | 0.977965 |

All six remain >1.1× and >2× C; none exceeds 1× baseline. Mean positive log slowdown is **1.214442 against C**, zero against baseline. Fixed-equivalent sums are **1,778.848 ms C / 7,366.865 ms baseline / 6,384.147 ms local / 5,765.083 ms final**; final/baseline **0.782569×**, final/C **3.240908×**. Calibration counts do not weight these sums.

The [full frozen source](../../selfhost/build/phase190/selected-source01/compiler.bend) is 1,714,595 bytes, SHA-256 `60b0b0265bca50d423beb865237800f53eeeb9f2e7caed270bf7be39933068d7`. Policy is 2; branch selection, liveness, physical operands, repeated-predicate reuse, joint allocation, caller-first selection, local values, branch complements and coalescing are enabled. The [full-source check](../../selfhost/build/phase190/selected-check01/report.json) completed successfully. Actual native acquisition and its finite boundaries are recorded below.

The measured hosted API uses a separate [extracted source receipt](../../selfhost/build/phase190/coalesce-api-source01/manifest.json), SHA-256 `4b24b96f1109fe4ff2d2bb3aabb7a01d842adc655762b2890294bfb28368014e`; [final emission](../../selfhost/build/phase190/final-emit01/report.json), [build](../../selfhost/build/phase190/final-build01/report.json) and [runtime06](../../selfhost/build/phase190/runtime06/report.json) bind its products. Do not conflate this fixture API identity with the complete native source.

## Exact source, control and machine evidence

The earlier screen05 [local source receipt](../../selfhost/build/phase190/local-api-source01/manifest.json) binds SHA-256 `f8a49abb69798cfb0c49356bf875d7f2c41f368a741da4cacf6f1ba407d8d544`. [local-api01](../../selfhost/build/phase190/local-api01/report.json), [emission](../../selfhost/build/phase190/local-emit01/report.json), [build](../../selfhost/build/phase190/local-build01/report.json) and [runtime05](../../selfhost/build/phase190/runtime05/report.json) retain the checked producer, generated products and exact-output observations. This is an extracted checked API source identity, not the final complete native compiler source identity.

[controls01](../../selfhost/build/phase190/controls01/report.json) passes 48 structural rows and six machine routes. [operand-controls01](../../selfhost/build/phase190/operand-controls01/report.json) adds one structural row and 25,766 independent observations per route. [integrated-controls01](../../selfhost/build/phase190/integrated-controls01/report.json) and [caller-controls01](../../selfhost/build/phase190/caller-controls01/report.json) each pass 78 structural rows and 12 routes; width observers perform 280 observations per route. [local-controls01](../../selfhost/build/phase190/local-controls01/report.json) passes nine structural rows and 1,400 independent observations per route. Direct-object and GNU-as executions consume the same typed sequence but use independent C output oracles.

The fold [alpha audit](../../selfhost/build/phase190/machine-audit-alpha02/report.json) records **66→59 positive-path instructions and 21→10 frame references**, yet runtime01 fold slows 8.280%. The [joint audit](../../selfhost/build/phase190/machine-audit-joint02/report.json) records **66→39 and 21→2** for its integrated bundle. These are static path counts, not dynamic instruction counts, cache misses or DRAM traffic. The [selected-bundle audit](../../selfhost/build/phase190/machine-audit-final02/report.json) records **66→27 instructions and 21→0 frame references** on the fold positive path. This selected bundle includes complement/coalescing changes beyond local values; the count is not a local-value-only ablation.

Failed checked acquisitions and subsequent source identities remain linked in the [experiment index](../../experiments/phase190/README.md). Failed gates are not passes. The failed [complement-controls01](../../selfhost/build/phase190/complement-controls01/report.json) is not a pass. Its later [final-controls01](../../selfhost/build/phase190/final-controls01/report.json) successor passes 12 coalescing, 24 complement and nine local structural rows plus six machine-route executions (complement oracle: 4,840 observations per route; local: 1,400). Runtime06 measures the resulting bundle; broad native N1 output/runtime evidence is recorded above, while N2/N3 and broader native gates remain separate.

## Compiler cost is separate from generated runtime

| Checked hosted acquisition, six programs | Source preparation seconds | Typed selection seconds | Object emission seconds |
| --- | ---: | ---: | ---: |
| Baseline API | 29.992174 | 14.724725 | 7.010083 |
| Alpha | 29.355918 | 20.145993 | 7.380454 |
| Operands | 29.254927 | 19.571195 | 6.931040 |
| Joint | 29.400787 | 19.525693 | 7.022019 |
| Caller preference | 30.263044 | 20.809466 | 7.280719 |
| Local values | 29.832659 | 19.572428 | 6.952904 |
| Selected final bundle | 29.690998 | 19.813000 | 6.908240 |

These single acquisition intervals come from the emission receipts pinned by the linked summaries. Selection rises 36.817% for alpha against the baseline API and remains above that baseline in later candidates. Object/render timing includes host serialization and writes. The separate baseline API receipt is not the producer of the old retained baseline executables; no native compiler-throughput improvement or campaign-total cost is inferred.

## Actual native producer and remaining qualification

[Native N1 acquisition](../../selfhost/build/phase190/native-image01/report.json) completed in **159.472s**, using the qualified Phase186 QBE N2 to compile the frozen complete selected source. The produced executable is **N1**, SHA-256 `2ba6c0ac428bf0c06b5e87dc8ab57496f90d982c5808d939f45e3c74a2282243`; the acquisition receipt’s input producer stage N2 must not relabel that output as N2.

That actual N1 emits direct objects for [native45-01](../../selfhost/build/phase190/native45-01/report.json): **45/45 programs pass their independent full-value/count oracle**, in **99.420s** for the acquisition/observation job. Its complete program manifest supplies the candidate role in broad-runtime02. This is finite native45 evidence, not native64, self-reproduction or whole-compiler correctness.

[hosted-native-compare01](../../selfhost/build/phase190/hosted-native-compare01/report.json) authenticates the six frozen development cases: **all six emitted objects and all 18 linked `.text`, `.data`, `.rodata` sections match exactly** between the checked hosted producer and actual native N1. Whole-ELF identity and all-input compiler equivalence are not claimed.

The actual N1→N2 direct-object self-build [native-self01](../../selfhost/build/phase190/native-self01/report.json) succeeds in **241.793s**. Its 22,740,720-byte executable is 10.79% smaller than the installed Phase189 executable; this combines changed compiler source and code generation, not a same-source size ablation. Actual N2 passes all **64/64** finite backend cases in the [qualification gate](../../selfhost/build/phase190/native64-01/report.json), whose guarded wall time is104.484s. The [N2→N3 reproduction](../../selfhost/build/phase190/native-reproduction01/report.json) succeeds in **348.274s**, with the same 27,530,720-byte object SHA-256 `4f8031ed3d6caf5499f549d0e5a3d2884b7e5b159a1fc74b2154a571399e8428`. Linked executable metadata differs; whole-executable identity is not claimed.

The broad result supports transfer to held-out native programs, with the local-pair regression and unmet ≤2× objective preserved. The installed Phase189 image and asset selection remain unchanged. The qualified candidate is available through explicit image/receipt selection; no public-command installation gate was performed.


## What we learned and what remains

The useful discovery was composition of general machine-level facts: a verified
coloring alone left width copies, scratch transfers and redundant predicates;
local value facts, physical operands, paired predicates and copy affinities
allowed those costs to disappear together. The frozen fold loop changes from
66instructions/21frame references to27/0 and becomes about2.7× faster. This is
not a claim about DRAM misses: the observations establish less executed code
and stack transport, without hardware cache-counter evidence.

The [local-pair regression](local-pair-regression.md) is a useful counterexample.
Fewer whole-function instructions can coexist with more work in a repeated
address chain. Four exit-only handles occupying registers are a plausible
placement cause; no causal ablation was run. The next general hypotheses are
loop-sensitive live-range placement and combining scaled addresses with memory
operations. C's fold still performs two updates in15instructions; more registers
alone do not close that difference. Do not introduce workload-name exceptions.

The same exact compiler source and output object take241.793s with its QBE-built
N1 executable and348.274s with its x86-built N2 executable, a1.44038× complete
self-build ratio in one observation each. This is distinct from the3.08379×
user-program ratio to C. It is not an old/new matched compiler-throughput gain.
The added analyses increase checked-API selection cost, and native compiler
speed must remain a separate optimization objective.

JS/C/QBE source profiles and their maps are byte-identical to57dc784 according
to the [227-dependency audit](../../selfhost/build/phase190/unchanged-targets01/report.json).
The selected x86 source grows38,477→39,642lines, +1,165 (+3.03%), and
1,657,315→1,714,595bytes (+3.46%). The maintained backend adds1,169net lines;
fixtures, immutable experimental harness versions and evidence are separate.

The [reusable experiment ladder](../../selfhost/tests/phase190/README.md) now
supports cheap checked-API experiments, independent C observers, frozen held-out
selection, native product comparisons and separate cost accounting. Six candidate
screens preceded one selected native qualification campaign. The earlier fold
regression, unbalanced screen, rejected profile pooling and label-contract error
remain evidence. Astra-high agents handled bounded audits, harnesses and reporting;
root owned the single target lane and integration. Agent quota/billing is not
observable here and is not estimated from process time.

This demonstrates a reusable optimization and a cheaper way to reject candidates,
but **not recursive acceleration**. We did not randomize research policies or
measure a causal increase in validated discoveries per total agent/compute budget.
There is no new BendTT theorem or whole-compiler correctness proof.

## Final qualification, cost and use

Actual N2 [native45-02](../../selfhost/build/phase190/native45-02/report.json)
passes45/45 independent outputs in136.456s. The authenticated
[generation comparison](../../selfhost/build/phase190/native-generations-compare01/report.json)
finds all45 objects and135 linked sections byte-identical to N1's measured
products. [Runtime controls](../../selfhost/build/phase190/runtime10-01/report.json)
pass10/10 in11.272s. The installed selector and every bound installed file
retain their starting bytes.

The usable candidate is `selfhost/build/phase190/native-self01/program`, with
its adjacent `report.json` binding actual N2. Use the maintained builder with
`--host native --stage N2 --target x86 --emit object --mode cache`, that explicit
`--image` and `--image-receipt`, and `selfhost/build/phase190/assets.json`.
Executable SHA-256:
`2e5ecea6fcb794480e08d0c2fb4c33b6b39d5760e234fccdb0f487b37ee5b326`.
Ordinary installed commands still select Phase189.

The [cost inventory](costs.json) accounts for59 serial guarded jobs,46 successful
and13 failed. Total guarded wall time is39.582min; failures consume54.984s.
Peak recorded process-tree RSS is2.160GiB. Roughly two hours of research also
include analysis, coding, agent work, metadata processing and reporting, which
overlap target jobs and cannot be recovered by adding guard durations.
Agent billing/quota is unavailable.

| Guarded activity | Seconds |
| --- | ---: |
| Checked API acquisition, including failures |176.620|
| Small independent machine controls |168.640|
| Hosted emission of development programs |418.922|
| Linking development programs |33.677|
| Runtime campaigns |434.164|
| Native image acquisition and self-reproduction |751.133|
| Native45/N2/backend qualification |340.784|
| Native runtime controls |11.439|
| Profile, diagnostic and source check |39.563|

All59 jobs have retention closure receipts. No Phase190 source/product/failure
was pruned. The verified historical retention operation reclaimed429.76MiB net
before the native campaign; its plan and restore evidence remain. The5GiB disk
reserve remains enforced.

The [evidence index](evidence.json) links both portable capsules, runtime data,
source identities and gate receipts. The [first capsule](evidence/REPRODUCE.md)
retains development/failure/profile evidence; the
[qualification supplement](qualification-evidence/REPRODUCE.md) retains native
checks, unchanged-target audit and regression inspection. Reproduction requires
authenticated baseline/tool assets; metadata alone does not recreate missing
executables. No further target campaign is needed to establish these results.
