# P67-001: remove unnecessary native value transport

Registered October 8, 2026 before current native measurements or integration.
[Design](../../design/phase67/native-speed-and-proof.md) ·
[Results](../../implementation/phase67/README.md).

Hypothesis: generic argument, closure and continuation transport still explains
a material native gap; lowering already-known values/calls directly can improve
multiple program families with a small semantic change.

First establish current TypeScript/Bend C output and execution using the same
Clang and inputs. Numeric, array and closure workloads form the initial screen;
tree, Map and lexer test transfer. Preserve ownership and evaluation order.
Reject if the output opportunity disappeared, dynamic work is not removed,
semantic controls fail, or clean timings show no useful benefit. Larger whole
compiler gates follow only a surviving general candidate.
