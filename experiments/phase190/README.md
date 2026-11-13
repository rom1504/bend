# Phase190: bounded register and memory experiments

The [design](../../design/phase190/README.md) targets direct-object x86 runtime ≤2× mature C (0.5× stretch); these are aspirations. The first five screens still leave every tested x86 case >2× C.
The compiler algorithms and legality checks remain in Bend. Host scripts authenticate sources/products, run independent observers and summarize observations. This index freezes evidence through runtime05; later work is not credited here.

| Hypothesis | Prediction and evidence record | Current decision |
| --- | --- | --- |
| H1 | [Weighted placement and liveness](H1-registers.md) | Small bundled gain; fold regression; no isolated placement result |
| H2 | [Adjacent and repeated predicate certificates](H2-predicates.md) | Finite controls pass; benefit not isolated |
| H3 | [Physical operand selection](H3-physical-operands.md) | Exploratory incremental gain with regressions and unbalanced timing |
| H4 | [Unified nine-color allocation](H4-joint-allocation.md) | Integrated bundle improves development runtime; no allocation-only attribution |
| H5 | [Caller-register preference](H5-caller-preference.md) | 0.372% incremental screen gain; no significance claim |
| H6 | [Local copy and width facts](H6-local-values.md) | 3.296% incremental gain; expression/tree regressions retained |

| Screen | Tested candidate / C | Candidate / frozen baseline | Sampling limitation |
| --- | ---: | ---: | --- |
| [runtime01](../../selfhost/build/phase190/development-summary01.json), alpha | 4.360254 | 0.968552 | Three balanced rounds; tree-bitonic spread 1.151220× |
| [runtime02](../../selfhost/build/phase190/development-summary02.json), operands | 4.234034 | 0.949344 | **Four roles, three rounds: unbalanced positions**; fold dispersion |
| [runtime03](../../selfhost/build/phase190/development-summary03.json), joint bundle | 4.016364 | 0.902469 | Four balanced rounds; no >1.10× dispersion flag |
| [runtime04](../../selfhost/build/phase190/development-summary04.json), caller preference | 3.994628 | 0.898097 | Four balanced rounds; no >1.10× dispersion flag |
| [runtime05](../../selfhost/build/phase190/development-summary05.json), local values | 3.868291 | 0.866739 | Four balanced rounds; expression baseline spread 1.119617× |

Each row uses that screen’s freshly timed frozen baseline; cross-row differences are not paired ablations. All screens use the same [six development cases](../../selfhost/tests/phase190/cases.json); **0/39 held-out cases** are represented. Zero-work remains correctness-only when encountered.
The summaries retain flagged cases and authenticate runtime outputs/pins. Native programs were executed, but their compiler producer was a checked hosted API: **no native candidate compiler qualification, self-reproduction, promotion or installation** is established.
The [first-screen report](../../implementation/phase190/first-screen.md) preserves alpha’s 8.280% fold slowdown despite 66→59 static instructions and 21→10 frame references. Fewer frame references do not establish fewer cache misses or faster execution.

Failed checked acquisitions remain evidence, not passes: candidate [01](../../selfhost/build/phase190/candidate-api01/report.json), [02](../../selfhost/build/phase190/candidate-api02/report.json), [03](../../selfhost/build/phase190/candidate-api03/report.json), [04](../../selfhost/build/phase190/candidate-api04/report.json), [05](../../selfhost/build/phase190/candidate-api05/report.json), [06](../../selfhost/build/phase190/candidate-api06/report.json), [07](../../selfhost/build/phase190/candidate-api07/report.json), [operand01](../../selfhost/build/phase190/operand-api01/report.json), and [joint01](../../selfhost/build/phase190/joint-api01/report.json). Later accepted source snapshots have separate identities; failure causes are in each receipt’s captured diagnostics.
The local-copy/width experiment now has the bounded development evidence in H6. Further complement/coalescing changes have no runtime result through this evidence cutoff; final held-out and native outcomes remain pending.

## Final selected-bundle and transfer evidence

[H7 composition](H7-composition.md) records runtime06 and the selected bundle.
The subsequent frozen 45-program native campaign measures3.980427→3.083793×
our mature C backend (22.526% less runtime across44 eligible cases). The38
eligible held-out programs improve22.190%. All45 independent outputs pass.
Local-pair regresses13.393%; two edit-distance points regress~0.5%; four
dispersion flags remain included. See the [full report](../../implementation/phase190/README.md)
and [per-program results](../../implementation/phase190/runtime-summary.md).
Earlier cutoffs above remain historical evidence, not the final outcome.
