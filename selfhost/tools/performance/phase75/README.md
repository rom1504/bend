# Phase75 compilation and runtime methods

All target jobs use one CPU3 process tree, Node heap1024MiB/stack4096KiB,
RSS2GiB and a4GiB available-memory floor. Source/data preparation can use CPU0.
Raw outputs belong under `selfhost/build/phase75/`; use a fresh directory per
attempt. Historical phase outputs stay immutable. No method edits during a run.

- `development.json`: existing checked B1 build and focused36 workflow.
- `prepare-bootstrap.py`: genuine B2 emission and eight driver comparisons;
  supply an admission binding the exact candidate driver and added export roots.
- `prepare-compilation-v2.py`: freezes candidate images, request host, sources,
  prepared-Base protocol and independently executed complete-C oracles.
  `compilation/run.py --plan PLAN --group prepare|clean|profile` runs it.
  One round screens an idea; three rotated rounds compare selected images.
- `pair-compilation.py`: interleaves old/new B1/B2 and upstream against their
  own qualified C output. Prepare source plans before running any target, then
  execute only the resulting combined plan.
- `warm/`: the existing first-plus-five ordinary-request diagnostic in one
  process per source/role. It does not replace the fresh-process metric or prove
  mixed-workload steady-state throughput.
- `compare-native.py`: original six generated-program families, saved baseline
  Phase73/candidate/upstream binaries, fixed independent checksums.
- `coverage/`: acquire and compare the additional six families using unchanged
  Phase70 sources/oracles. Compile and runtime clocks remain separate.
- `prepare-custom.py`, `prepare-custom-raw.py`: bind the existing native100,
  raw31 and explicit additional controls to a checked snapshot/toolchain.
- `report-controls.mjs`:166 deterministic differential trust graphs, including
  cycles, unsafe branches, foreign/native declarations and duplicate names.
- `verify-js.py`: exact closure of all prior non-native exports; three new
  explicitly enumerated private exports are the only wrapper additions.
- `prepare-c-identity.py`: B1/B2 whole-C identity for a candidate's own validated
  twelve-program acquisition. Different hosts require separate acquisitions.
- `prepare-release-qualification.py`: own-source check, exact B3 and deferred
  install/verify/installed42/24/5 commands. Do not install before all gates pass.

`fixtures/user-chain64.bend` adds a user-dominated source outside the timing
harness; `small-choice.bend` adds a small non-harness checked program. Both have
literal output goldens and join the twelve existing native controls in
`selection-new14.json`.

Preparation, imports, checked emission, Clang and execution are separate.
Upstream checks Base within its ordinary request; Bend's explicit prepared Base
is outside the request clock. Backend products are disabled in the compilation
comparison. Every measured request must reproduce an independently executed
complete C file. Profiles and instrumented code are diagnostic only.

- `ctor-controls.mjs`:1,066 legacy/indexed constructor comparisons including
  duplicate names and nested cached graphs.
- `uses-controls.mjs`:65,000 full-U32 set membership, persistence and raw-term
  occurrence controls against JS Set and the retained linear predicate.
- `*-alignment-probe.py`: rejected saved-C/machine-layout diagnostics; their
  successful executions are not production changes or compilation speed claims.
