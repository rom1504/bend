# P124-001: complete helpers can resume inside a local recursive region

Status: selected as an experimental checked-hosted source; native qualification deferred. [Design](../../design/phase124/local-ready-resume.md).
Parent: Phase123 source04, preserving its exact runtime and qualified experimental
machine-build policy. Root owns all guarded targets; source/control agents are offline.

The hypothesis is elimination of generic continuation round trips across an already
verified helper, through one explicit call/resume node and authenticated callable
view. Actual RLE helpers reside in a different registry than current readiness.
Preserve ownership, exact captures, evaluation order and bounded native stack.

Falsify on original RLE, unrelated heap-owning walker, independent refusal/output
controls and a complete compiler-cost screen. No source-name recognizer, blanket
terminal bridge, verifier weakening or native image build. Report failed admission
and cost regressions before any broad campaign.

Outcome: all405 broad observations pass; runtime2.00033→1.92014×upstream,
positive log-slowdown0.94870→0.90847 (4.24% less). RLE22.82% less; the
generate-and-lex family34.49–37.13% less; Unicode text3.59–3.87% less.
Compiler hosted two-case cost0.99532×parent, approximately neutral. Source+172
lines; runtime unchanged. The separate small frame expansion is excluded.
[Report](../../implementation/phase124/README.md) includes exact qualification,
remaining deficit, ownership/stack evidence and experiment accounting.
