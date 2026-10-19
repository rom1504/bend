# P112-001: expose scalar operations and eliminate repeated use analysis

Status: designed; no Phase112 targets executed yet.

[Design](../../design/phase112/qbe-parity.md). Baseline `d2b9069`.

Hypotheses: explicit scalar IR removes opaque primitive dispatch; retained
use-sets remove repeated traversal without changing emitted code. Test separately
before combining so timing and semantic effects remain attributable. First gates
are checked Bend source, independent scalar boundary observations, byte-identical
QBE for use-only changes and small matched runtime/compilation measurements.

All generated runs live in fresh `selfhost/build/phase112` directories (or
explicitly labelled Phase111 transport directories where existing tools require
them). Preserve failed receipts. Root owns serial guarded CPU3 execution.
