# P112-001: expose scalar operations and eliminate repeated use analysis

Status: implemented and locally qualified; full native integration and successor corpus gates pass.

[Design](../../design/phase112/qbe-parity.md). Baseline `d2b9069`.

Hypotheses: explicit scalar IR removes opaque primitive dispatch; retained
use-sets remove repeated traversal without changing emitted code. Test separately
before combining so timing and semantic effects remain attributable. First gates
are checked Bend source, independent scalar boundary observations, byte-identical
QBE for use-only changes and small matched runtime/compilation measurements.

All generated runs live in fresh `selfhost/build/phase112` directories (or
explicitly labelled Phase111 transport directories where existing tools require
them). Preserve failed receipts. Root owns serial guarded CPU3 execution.

Results: backward liveness preserves six complete QBE products and passes47
independent controls. Hosted 64/128/256-statement lowering takes0.612/0.184/0.123
times baseline; the compiler's full native speed is measured separately. Scalar
U32 plus local-loop/accessor changes reduce an arithmetic kernel from87.86ms to
5.51ms, but the six actual-program screen remains much slower than upstream.
This falsifies using the narrow kernel gain as a broad parity estimate. See
[the report](../../implementation/phase112/README.md) and exact raw receipt paths.
