# P54-002: compact SCC and bounce analysis

Hypothesis: replacing per-node transitive closure with indexed graph traversals
preserves all direct emitter facts while reducing asymptotic work and retained
storage enough for compiler-sized inputs.

Falsifiers: changed component ordering, missing recursive/unknown-tail facts,
different output on admitted baseline programs, lost refusal diagnostics, or
compiler-scale resource use outside the bounded execution policy.

[Design](../../design/phase54/backend-cleanup-and-direct-bootstrap.md).
Keep the old bound for initial parity controls; qualify larger inputs before
changing it. Graph scale, compiler-image ABI and self-reproduction are distinct
gates. Failure at one must not be relabeled as success at another.
