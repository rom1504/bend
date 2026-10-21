# P124-001: complete helpers can resume inside a local recursive region

Status: planned. [Design](../../design/phase124/local-ready-resume.md).
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
