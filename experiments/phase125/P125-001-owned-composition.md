# P125-001: ownership-preserving append composition

Status: selected typed variant; broad and native qualification complete.

Final independent transfer32.37% less runtime; RLE5.49% less in the broad run.
Raw-only regressed5.84%, RFC1/result-only variants were neutral. See the
[final report](../../implementation/phase125/README.md) and
[negative/transfer evidence](../../implementation/phase125/optimization-findings.md).

Design: [owned composition](../../design/phase125/owned-composition.md).
Parent: Phase124 source02, commit06dea60. Started2026-10-22 20:50:53UTC.

Hypothesis: a checked append operation can transfer an exclusively owned prefix
to its final result without taking/freeing/reallocating every cell. A read-only
layout/uniqueness check followed by a single suffix attachment preserves source
evaluation order and allows an unchanged fallback for shared/static inputs.

Disproof signals: no measurable clean-runtime gain, cost of scan exceeds saved
allocation, representation cannot prove exclusive mutation, alias/effect/order
mismatch, no unrelated transfer, or unacceptable compiler/qualification cost.

Ceilings and independent controls: selfhost/tools/performance/phase125/ceilings/.
All results and rejected attempts will be linked from implementation/phase125/.
