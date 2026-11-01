# P147-001 — Compact identities across a complete verifier computation

Status: proposed. See [design](../../design/phase147/README.md).

Prediction: compact identities and dedicated schema/live-state records can remove
repeated string lookup and generic record reconstruction. The useful result is
lower total native schema→flow→join→error→cleanup cost on real raw/direct functions,
not fewer allocations alone. Aim for a substantial region improvement; full-build
savings are bounded by freshly measured exclusive stage costs.

Falsifiers: conversion dominates; direct workers disappear; errors/order differ;
sharing/branch state leaks; a second workload regresses; full-request gains vanish.
No performance result or correctness claim yet.
