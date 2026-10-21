# Phase124: complete helper calls returning to local continuations

The optimizer is implemented in checked Bend in `ready-call/model.bend`.
Host code composes exact declarations, authenticates artifacts, invokes existing
tools, and records observations. It does not lower Bend programs. The selected
source excludes the separate `frame-buffer` experiment and test-only predicates.

Read [the design](../../../../design/phase124/local-ready-resume.md),
[report](../../../../implementation/phase124/README.md), and
[semantic interface](../../../../docs/self_hosted/local-ready-resume.md).
The original45 manifest, batch profile, output oracles, Phase118 runtime, and
Phase123 aligned machine builder are unchanged. The trusted verifier is unchanged.

## Reproduction and stages

With authenticated Phase123 assets present:

```sh
python3 -B selfhost/tools/performance/phase124/reproduce.py \
  --out selfhost/build/phase124/FRESH-source
```

This checks the composition recipe and exact resulting bytes. It does not type
check, acquire an executable, or change a selection. Use the existing Phase111
checked-API acquisition, exporting `p88_cache_prepare p86_plan
p111_runtime_admission p111_emit_admitted`, for a new source acquisition.

Run all compiler/API/native target work through `phase111/guard.py` with one serial
CPU3 lane, `--rss-mib 2048 --available-mib 16384 --file-mib 64`, an appropriate
deadline, and a fresh output directory. Do not run parallel acquisitions. The
retained guard `process.json` files contain exact executable arguments.

`phase118/emit-integrated.mjs` checks each original source and the independent
parent-derived graph before emitting. It takes a checked API receipt, source
manifest, fresh Phase118 output and explicit frozen case names. Set
`P118_RUNTIME_REPORT=selfhost/build/phase118/runtime-extend01/report.json`.
For ordinary alias/depth controls additionally set `P118_CASE_MANIFEST` to
`selfhost/tools/performance/phase124/controls/cases.json`.

Use `phase123/functional-aligned.py` for complete ordinary outputs, `screen.py`
for paired original benchmark runs against Phase123/upstream, and the unchanged
`phase118/cost-v2.mjs` for whole prepared hosted compilation costs. The cost tool
requires explicit parent selection/API/runtime identity. `screen-frame.py` is
only the rejected frame-versus-ready ablation, with different baseline provenance.
Each output has a fresh path; do not overwrite or relabel earlier receipts.

## Fast and broad loops

1. Pure admission/refusal controls: checked test API and `finite.mjs` (17 rows).
2. Independent list/tree controls: complete output including retained aliases and
   ordinary deep inputs, not checksum-only observations.
3. Frozen RLE, lexer, tree-bitonic and map-churn: original-source paired runtime;
   this subset is a diagnostic, never the whole-corpus score.
4. Early paired compiler cost for RLE/lexer; deterministic QBE hashes per role.
5. One original45 emission and runtime gate, after a useful capability is shown.
   `phase123/summarize.py` and `phase123/deficit.py` retain the historical score and
   positive log-slowdown diagnostic without changing cases or weights.

The first five-case emission hit a60-second deadline after four cases completed.
`completed-prefix.py` rechecks every input and completed output, records the
incomplete parent/guard, and explicitly excludes the unfinished case. The original
batch remains failed. This bounded recovery is not permission to mark arbitrary
partial experiments successful. Final qualification uses a fresh complete batch.

## Evidence and limitations

`ready-call/evidence/` retains source/IR call-graph accounting; `machine.py`
authenticates binaries and records read-only disassembly. Whole-function static
counts are not executed-instruction measurements, and a merged region must not be
compared with only one of its former fragments. `controls/compiler-analogue.md`
identifies a possible compiler workload without claiming measured transfer.

`accounting.py` counts guarded wall time including failed jobs and checks serial
execution. It does not meter agent inference, quota, or CPU billing. `seal.py`
preserves bounded receipts, outputs, methods and machine excerpts, including
negative attempts; large binaries/SSA remain external with recorded identities.
Replay the sealed capsule without extraction using `seal.py replay ARCHIVE`.

No full native compiler acquisition, N1/N2 qualification, installed promotion,
GPU/parallel throughput claim or recursive-acceleration claim follows from these
hosted compiler and generated-program experiments.
