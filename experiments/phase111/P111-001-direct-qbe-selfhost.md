# P111-001: full generic segments directly to QBE

Decision: implement and qualify. Correctness: not yet measured. Performance:
not yet measured. Production: unchanged.

[Design](../../design/phase111/direct-qbe-selfhost.md).

Hypothesis: retaining semantic operations before C text and targeting the
existing portable one-pointer segment ABI removes cproc from full native Bend
compilation without replacing the runtime or duplicating the checked frontend.

Controls: selected Phase102 native compiler and Phase108 full C/cproc/QBE route;
independent fixture outputs and negative checks. Preserve exact source/tool/
runtime identities, resource guards, failures and output artifacts.

First gate: closures, non-tail continuation and IO through actual checked source.
Decisive gate: full compiler emits QBE, its directly built successor emits itself
again, with semantic and product consistency checks. No full build before the
small gate. Kernel results do not establish full self-hosting or upstream parity.

Report and evidence will be recorded under `implementation/phase111/`.
