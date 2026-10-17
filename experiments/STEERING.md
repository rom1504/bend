# Current frontier: Phase105 native compilation measurements

[Report](../implementation/phase105/README.md) ·
[Protocol](../docs/self_hosted/NATIVE_COMPILER_COMPARISON.md) ·
[Replay](../selfhost/tools/performance/phase105/README.md).

The requested measurements are complete. Current candidate04 native B1/B2 and
pinned upstream TS/Bun compile identical sources to C. Across 45 closed points
with equal weight per 23 original programs, prepared process ratios are
0.499×/0.517× upstream; live-Base ratios are 2.384×/2.231×. Keep these distinct.
For the complete compiler source, repeated prepared times are 126.051s/143.646s
versus 48.442s upstream: 2.602×/2.965×. Single live controls are separately labelled.

All 693 timed requests, 45 reference acquisitions and 12 selected product
executions pass. Native B1/B2 emit identical C. The precise child clock excludes
supervision startup/polling; internal request clocks have unequal boundaries.
Selected Clang build observations are separate from compiler latency and are
not repeated performance estimates. No generated-program speed campaign or
new full-language qualification was performed. No compiler/release changes.

The [evidence capsule](../implementation/phase105/evidence/README.md) preserves
raw observations, source and method pins, complete C/products and logs. Root ran
762 serial guarded jobs: 32.86min runner wall, 28.00min child time. No OOM, timeout,
disk exhaustion or PR comment. These are measurement-run costs, not token usage
or total conversation wall time.

## Next work, only when requested

- Attribute full-source costs common to the Bend implementation/representation
  and costs specific to its own generated executable. B2 is 1.140× B1 there;
  matching B1 alone would leave the 2.602× upstream gap. Do not infer the cause
  from timings alone or extrapolate prepared small-program wins to self compilation.
- Investigate live-Base preparation separately: broad pooled preparation is
  1405ms/1314ms B1/B2 versus 58ms/78ms using the existing carrier. Upstream has
  source Base in both measured modes; no equal-prepared upstream API was tested.
- The [fast native backend proposal](../design/phase105/fast-native-backend.md)
  remains unimplemented. Its structured native IR/Cranelift/caching roadmap
  addresses machine-build cost and must measure the resulting compiler's speed.
- The [recursive research plan](../design/phase104/recursive-improvement.md)
  remains a hypothesis. A faster compiler or emitted-C fixed point does not
  establish accelerating discovery of validated improvements.

Use the one-round prepared six-case screen first, then live mode, broad cases
and complete source as justified. Preserve exact source/image/assets, failure
records and output checks. Root alone runs serial guarded CPU3 targets; agents
may prepare or review offline. Do not rebuild large compiler images after each
small edit, and do not repeat the entire Phase105 campaign for every candidate.

## Installed implementation and historical context

[Candidate04 promotion](../implementation/phase102/default-promotion.md) remains
current. The [Phase103 public CLI](../docs/self_hosted/NATIVE_CLI.md) is written
in Bend and uses no Python/Node/Bun host for ordinary requests. Its entry differs
from the supervised same-source stage pair measured here. The installed JS
release and its scope remain separate. Preserve conformance and compiled-program
speed while optimizing compiler speed; report source/tool complexity separately.

The preceding detailed frontiers, including Phase103/102 history and older
qualification limits, are preserved in the
[previous committed steering](https://github.com/rom1504/bend/blob/4a8ae61/experiments/STEERING.md).
See [the ledger](ledger.md) and linked reports for their evidence. Older source
and guard-clock ratios are not interchangeable with these fresh process clocks.
No next optimization or backend implementation is automatically started by this
completed measurement campaign.
