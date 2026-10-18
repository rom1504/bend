# Phase110 ownership IR and bounded research loop

[Design](../../../../design/phase110/ownership-laws-and-search.md) ·
[Experiment](../../../../experiments/phase110/P110-001-owned-interfaces.md).

This is an additive experimental compiler path written in Bend. It reuses checked
NativeErasedBody facts, explicit ownership operations and the shared native IR.
Python assembles exact source snapshots/supervises processes; JS transports facts
and calls the checked Bend API. Neither implements a source optimization.

The campaign is in progress. Root serializes compiler/target work on CPU3 under
`../phase86/guard.py`. Do not wrap the law checker in another guard: it owns that
lock itself. Preserve fresh output directories and immutable receipts.

- `assemble.py --out DIR`: compose the checked API source and exact width profile.
- `calls/prepare.py --source SOURCE --out DIR`: add closed owning ordinary calls
  using authenticated declaration replacements; historical files stay unchanged.
- `build-api.py --source SOURCE --out DIR --calls --runtime-ir`: check/build the
  small development API, under the outer guard.
- `emit.mjs API CAPTURE OUT CONTRACT POLICY`: Bend lowering and QBE/C emission.
- `run.py`: compile multiple worker policies with one cached production runtime
  object, compare every result to the independent harness oracle.
- `search.py`: serial, alternating, immutable worker evaluation; optional frozen
  `--calibration` controls per-workload repetitions.
- `relink.py`: reuse qualified worker objects with an independent held-out harness.
- `contracts.py`, `probe.py`: actual ownership ABI and physical-graph obligations.
- `laws/README.md`: safe source-connected laws, independent kernel and mutants.
- `controls/README.md`: frozen training/held-out inputs and replay commands.

Policies include the Phase109 incumbent, inline tags, constant specialization,
atomic pair reconstruction/take, and private structured runtime templates. The
private template verifier regenerates the graph from checked ownership operations;
it is a correspondence gate, not a mathematical proof of machine semantics.
Ordinary opaque libraries still refuse raw memory operations. Single-thread and
runtime layout premises must remain explicit.

Use the small API and kernels before native image acquisition. No broad45 or full
self-reproduction is needed for each local policy. The selected production compiler
and Phase108 full-language cproc/QBE bootstrap remain unchanged.
