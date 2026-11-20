# Phase195 source-to-object compiler cost

N1 1.012847× Phase194 time (+1.28%); N2 1.003597× Phase194 time (+0.36%).

All 32 complete outputs and empty-stderr oracles were revalidated; medians and geometric means were recomputed.

| Request | N1 baseline s | N1 candidate s | N1 ratio | N2 baseline s | N2 candidate s | N2 ratio |
|---|---:|---:|---:|---:|---:|---:|
| coverage-numeric-recurrence-256 | 0.936685 | 0.955015 | 1.019569 | 1.124939 | 1.127944 | 1.002671 |
| coverage-expression-32 | 1.024803 | 1.035706 | 1.010640 | 1.256955 | 1.245031 | 0.990514 |
| tree-bitonic | 1.334318 | 1.338375 | 1.003041 | 1.559021 | 1.584725 | 1.016487 |
| test-map-set-ops | 4.198375 | 4.274892 | 1.018225 | 5.118916 | 5.143929 | 1.004887 |

Four development source-to-object requests, two reversed rounds per stage, fresh compiler processes and cached Base. Includes startup, checking, lowering/optimization and object emission. Excludes linking and generated-program execution. All samples retained.

N1 compares compiler implementations produced by the same frozen QBE seed/toolchain. N2 measures the net compiler implementation and generated x86 change. The screens are separate; two rounds provide a bounded guardrail, not statistical significance or broad compiler/research-throughput evidence.

N1 measured report: `/home/ai/bend2/build/publish/bend/selfhost/build/phase195/compiler-cost-n1-01/report.json`.

N2 measured report: `/home/ai/bend2/build/publish/bend/selfhost/build/phase195/compiler-cost-n2-01/report.json`.
