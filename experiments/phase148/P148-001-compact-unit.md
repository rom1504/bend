# P148-001 — one compact body across optimization and admission

Status: design/implementation; no measured gain yet.

Hypothesis: preserving numeric identities and physically contiguous instructions
across actual scalar optimization and admission removes repeated name resolution,
wide records, temporary lists and ownership work. A smaller verifier environment
alone is insufficient evidence. Include conversion and final decode/cleanup.

Prediction: at least2× on a complete affected native region would support broad
extension. This is a decision target, not a whole-compiler forecast. Compare
exact transformed functions and errors, then the independent final verifier and
emitter. Original arithmetic/epoch/predicate behavior remains the semantic oracle.

Falsifiers: conversion dominates; native arrays cause expensive transport;
branch cloning dominates; direct workers disappear; scalar optimization choices
or errors change; only one synthetic family improves; cold time does not transfer.

The [design](../../design/phase148/README.md) records1×/10×/100× scope and gates.
The [fixture audit](../../research/phase148/fast-loop.md) identifies retained real
functions and independent contexts. No full compiler rebuild is justified until
small native evidence supports one.
