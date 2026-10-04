# P43-005 — Cheaper equivalent entry guard

Owner: phase43_guards. Domain: generated JS runtime entry proof. Correctness:
syntax checked, semantic root execution pending. Measurement: not run. Decision:
investigate, no promotion. Plan: [design](../../design/phase43/guards.md).
Implementation: [packet](../../implementation/phase43/guards.md).

Hypothesis: an already successful complete host guard proves absence of Array/
Object marker descriptors; subsequent scalar/local guard can reuse this logical
fact within the same invocation and avoid temporary descriptor arrays/closures,
without mutable cross-call caching. Expected campaign target 1.2–2× short list
workload; narrower first-ablation prior 1.05–1.2×, disclosed before measurement.

Falsifier: loss of canonical private activation, unequal complete value/error/
demand trace, stale proof after host mutation or reentry, or null throughput gain.
Preserve unmodified saved module and exact derivation identities. Root serializes
all semantic and timing work. Source runtime/emitter remain untouched by owner.

Rejected before execution: optimizing the ordinary standalone scalar guard would
remove observable Array.every/iterator hooks when no host guard dominates. The
survivor retains ordinary guards byte-for-byte and adds separate AfterHost helpers.

Dependency-specific numeric hook pruning is deferred: it requires a proved
compiler host-dependency domain and an explicit activation contract. Reusing the
existing private proof coverage is already shipped and is not this hypothesis.

Root's first oracle attempt failed in the harness before equivalence assessment:
empty child stdout caused JSON parsing to fail. Preserve
`selfhost/build/phase43/run-guards-oracle01` and the original oracle as
`selfhost/tools/performance/phase43/guards/oracle-v1.mjs`. Successor reports child
role, case, spawn error, status, signal, stdout and stderr before parsing; it does
not reinterpret an empty child result as success. Later derivation also tightened
the input-clause proof to the exact reviewed two-U32 clause and removed dead code
from the optimized helper. No throughput result exists.

P43-005b (separate, root-authorized): full total-U32 fusion-specific numeric host
domain. Preserve globals/protocols/integer intrinsics; omit only floating hooks
which neither private full loop nor old generic fallback observes. Versioned
saved-output tools and source hook proposal in the implementation packet.
Successive mutation oracle must show permitted private activation plus exact
unchanged value/error/trace for every omitted hook. No execution by owner.

Root exact AfterHost successor semantic oracle passes76 cases in
`selfhost/build/phase43/run-guards-oracle04/stdout.log`; canonical private fusion
activates once, Error reentry suspends/restores proof and all mutation traces agree.
Correctness status: selected saved-output semantic gates passed. Measurement:
still not run. Decision: continue independent U32 domain study; no promotion yet.
