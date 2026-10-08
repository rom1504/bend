# P67-003: a proof connected to compiler lowering

Registered October 8, 2026. [Design](../../design/phase67/native-speed-and-proof.md) ·
[Results](../../implementation/phase67/README.md).

Hypothesis: a small transformation in the native work can have explicit
semantics and a Bend preservation theorem checked by an independent kernel.
Record its exact domain, trusted assumptions, relationship to production code,
and rejected proof attempts. No unsafe proof or self-hosted type acceptance
counts as an independent correctness proof. First inspect existing kernel
availability and prove one small useful obligation before expanding scope.
