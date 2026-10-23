# Phase130 reproduction tools

Read [design](../../../../design/phase130/README.md),
[report](../../../../implementation/phase130/README.md) and
[transport guide](../../../../docs/self_hosted/prepared-base-transport.md).
Compiler logic is in Bend modules under `base/`; host scripts authenticate,
compose exact declarations, transcode a private transport, orchestrate targets
and compare evidence. Scalar sources are rejected ceilings, not compiler passes.

Start from the exact qualified Phase128 artifacts. `prepare.py` composes
`base/mode-cursor-v02.bend` and `base/mode-controls-v01.bend` against that source;
its manifest records the exact17 overrides. Acquire a checked API using the
existing `phase111/check-api.py`, exporting the normal native entries and
`p130m_controls`. `base-equivalence-v2.mjs` requires the original API, candidate API,
compact carrier receipt, fresh output and the frozen Phase129 profile manifest.
The complete source archive is in `implementation/phase130`.

Run executable tools under `phase111/guard.py`: CPU3, available memory16GiB,
ordinary RSS1–3GiB, full image RSS6GiB, explicit wall/file limits. A single root
lane owns target execution. Source preparation and metadata audits do not require
a target lane. Never modify previously acquired modules/artifacts in place.

- `native-request.py`: original or compact carrier, exact input pins and raw QBE.
- `admit.py`: decoder-only source/runtime binding after complete equivalence.
- `qualify.py`: binds actual hosted/N1/N2 and focused19/ordinary45 receipts.
- `timing-plan.py`, `timing-run.py`: preserve the original three-case benchmark,
  toolchain, correctness oracles and rotated schedule; only carrier policy differs
  by native role. Request time and machine-build time remain separate.
- `base-proxy-run-v2.py`: integrated decimal/compact decoder against old decoder.
- `scalar-run-v2.py`: correct milliseconds-to-seconds conversion for IO.now.

Earlier versions and raw failures are retained. `scalar-run.py` contains a known
unit-label error: raw IO.now integers are milliseconds, not nanoseconds. Its
ratios are valid; use v2 for new experiments. Neither scalar source ceiling is an
automatically applied optimization, and the measured variants were slower.

Native semantic gates reuse `phase123/build-aligned.py` and Phase125's focused19
and full45 runners. Both formats reconstruct identical preparation. Actual N1
self-emission explicitly exercises compact input; inherited ordinary gates use
decimal input, establishing backward compatibility. The installed selection is
unchanged; qualification is a separate artifact from acquisition admission.
