# Final checked16 compiler-cost gate

The final four-case gate **passes all36 fresh checked-library requests**. Relative to Phase41 checked01, checked16 request medians fall6.17% for tree and6.03% for numeric recurrence, while local pair rises5.79% and list pipeline rises6.69%. This is a mixed compiler-cost tradeoff, not a uniform improvement or an isolated plan-cache gain.

The [raw report](../../selfhost/build/phase42/integration03/compiler-cost/report.json) records260.802seconds for the measured runner. This excludes prior independent output acquisition/planning and is not the whole campaign duration. Its [bound config](../../selfhost/build/phase42/integration03/cost-plan/config.json), SHA `daff93048ff7143a4d12f3228619ceebcdab6f5e7c1513df2bab9acf7b1e6e04`, uses the unchanged normal-library worker SHA `f0dea569bdb02df60ed1156b0cead389e197291f1c3a3c6775102c7a03790f42`. Four cases × three roles × three rotations give36 serial fresh processes. Order rotates TS/baseline/candidate, baseline/candidate/TS, candidate/TS/baseline; configured affinity is CPU3, stack4096KiB, heap1024MiB, supervised RSS/available2048MiB and per-request deadline180seconds. No new execution or large-file hashing was performed to write this account.

## Checked-library request cost

Cells are median [minimum–maximum] in milliseconds, from three samples. Change compares candidate with baseline request medians.

| Case | Phase41 baseline | Checked16 candidate | Change | Pinned TS |
| --- | ---: | ---: | ---: | ---: |
| Local pair | 1789.871 [1782.239–1814.514] | 1893.430 [1886.338–1922.471] | +5.79% | 339.109 [338.448–340.763] |
| Tree bitonic | 2413.645 [2412.355–2413.909] | 2264.798 [2257.299–2284.859] | -6.17% | 329.439 [319.165–426.648] |
| Numeric recurrence1024 | 1458.640 [1337.696–1472.189] | 1370.703 [1368.222–1496.334] | -6.03% | 266.933 [266.245–268.852] |
| List pipeline512 | 2280.692 [1986.193–2471.548] | 2433.276 [2242.574–2663.576] | +6.69% | 430.634 [429.481–593.852] |

TS list request samples are593.852,429.481 and430.634ms: the high sample is about38% above the median. The corresponding host import also rises to308.984ms. TS tree varies319.165–426.648ms as well. Baseline/candidate list ranges overlap substantially, and numeric recurrence also has overlapping ranges; three rotations do not establish a variance model or statistical significance. Pair and tree request ranges are separated in this run, but that remains a finite screen, not a universal claim. Compare these final same-run results rather than transferring the earlier checked13 −10.03%/+12.03% tree/list estimates.

The request boundary is the normal inspect/Base pipeline for Bend and book_load/book_valid/js_lib for pinned TS. Lazy Bend API loading and normal Base-cache handling remain inside inspect. These timings therefore do not isolate emission, graph analysis, cache lookup or type checking. All checked16 source changes are included; request-local plan reuse may avoid duplicate walks, but this experiment does not isolate its contribution from fusion, proof, direct-call, native-container or hybrid changes.

## Import, verification and process boundaries

Host import is measured separately before the request. Bend imports the driver here and loads its large API lazily in inspect; TS imports its compiler modules here. This different loading boundary is why the host-import columns must be reported alongside request cost.

| Case | Baseline host import, ms | Candidate host import, ms | TS host import, ms |
| --- | ---: | ---: | ---: |
| Local pair | 3.748 [3.743–3.769] | 3.893 [3.814–3.929] | 211.655 [210.198–211.856] |
| Tree bitonic | 3.686 [3.677–3.728] | 3.866 [3.807–3.878] | 210.162 [209.979–257.155] |
| Numeric recurrence1024 | 4.127 [3.706–5.247] | 3.799 [3.790–5.900] | 209.768 [209.571–209.989] |
| List pipeline512 | 3.912 [3.777–5.499] | 3.873 [3.807–7.642] | 211.770 [209.050–308.984] |

The worker's preflight attempt verification is outside request/import timing. Across all twelve samples per role, its observed ranges are1710.626–2319.787ms baseline,1741.951–2186.983ms candidate and1617.168–1840.942ms TS. Full process wall time also includes process startup, input verification, output writing/exact comparison and postflight checks. Subtracting request from process medians would not measure a single isolated phase, and independently computed medians do not generally add.

| Case | Baseline process wall, ms | Candidate process wall, ms | Change | TS process wall, ms |
| --- | ---: | ---: | ---: | ---: |
| Local pair | 6326.983 [6308.859–6382.889] | 6426.825 [6408.605–6669.865] | +1.58% | 4875.610 [4875.515–5040.221] |
| Tree bitonic | 6883.442 [6875.433–6971.266] | 6774.003 [6736.796–6816.095] | -1.59% | 4833.887 [4833.600–5229.807] |
| Numeric recurrence1024 | 6362.125 [5753.229–6927.512] | 6107.856 [5875.663–6524.586] | -4.00% | 4772.847 [4714.668–4896.402] |
| List pipeline512 | 7289.954 [6425.487–7315.772] | 7534.969 [6753.028–7699.691] | +3.36% | 4955.784 [4936.622–5734.791] |

## Memory and output size

Supervised peak process-tree RSS is shown in MiB (bytes÷1048576). The raw report also retains worker maxRssKiB independently. Median RSS rises modestly in all four cases: roughly0.24–0.82%. This is not evidence that the request cache is allocation-free; temporary graph retention and other compiler changes are combined.

| Case | Baseline peak tree RSS, MiB | Candidate peak tree RSS, MiB | TS peak tree RSS, MiB |
| --- | ---: | ---: | ---: |
| Local pair | 515.00 [514.62–516.55] | 518.53 [516.68–518.91] | 498.76 [497.50–499.15] |
| Tree bitonic | 516.40 [515.55–517.54] | 520.58 [517.99–520.71] | 498.81 [498.70–504.89] |
| Numeric recurrence1024 | 512.14 [510.59–512.80] | 513.39 [511.84–513.90] | 494.38 [492.93–495.28] |
| List pipeline512 | 517.82 [515.97–517.98] | 522.08 [520.80–523.86] | 512.50 [509.01–512.59] |

| Case | Baseline emitted bytes | Candidate emitted bytes | TS emitted bytes |
| --- | ---: | ---: | ---: |
| Local pair | 124,927 | 126,998 | 12,457 |
| Tree bitonic | 109,624 | 133,674 | 10,593 |
| Numeric recurrence1024 | 79,458 | 79,709 | 4,699 |
| List pipeline512 | 142,134 | 140,303 | 40,351 |

Each timed output must match its own independently acquired checked-role bytes exactly. Cross-role emitted code and runtime hashes need not be equal. Output growth/shrinkage is therefore reported separately from source complexity and does not itself explain the measured request deltas.

## Frozen image identities

These identities are read from the already verified plan; this account does not rehash compiler artifacts.

| Binding | Phase41 baseline | Checked16 candidate |
| --- | --- | --- |
| manifest SHA256 | `df79fadeab5eff7e405aea636488108a894da3d39bb2dc8207b3def8eae9feba` | `f9ffcd71a338df6f39bfd818021dbc6f73868742fe57789ca834066f8645ca1b` |
| api SHA256 | `9900abf49719575db7f7bbee32c6b16e10bcd554f9de22cde0799eb859cc6f0b` | `63ddb2dd35554aafafc26dbdff4aba86b5d3774cd0d99a9509ccf237d210ba54` |
| runtime SHA256 | `51bb6046a8ac116865e2b1ed94b5587d1257f951aed536da77da3e91338eac49` | `6dbda18f176702557041530652690601c32b09261327ad49af7bf0cc8e7fb81c` |
| base SHA256 | `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661` | `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661` |

Baseline attempt is selfhost/build/phase41/checked01; candidate is selfhost/build/phase42/checked16. Both roles retain their own verified API/runtime/driver/Base-cache binding. TS uses pinned upstream commit `018751270e800bc222a93dad7f257083ee53a5f7` through its explicit upstream modules and independent output receipts; its inherited attempt metadata is verification provenance, not a claim that TS executes the Bend API. The config enumerates all source, acquisition receipt, worker, driver, verifier and cache identities.

Compiler-cost admission is complete for these four cases. It does not establish generated-program runtime parity, application-wide compile throughput or release installation; those belong to the separately bound runtime/semantic/publication gates. The added compiler complexity must be justified by those runtime results while retaining the pair/list request regressions as material costs.
