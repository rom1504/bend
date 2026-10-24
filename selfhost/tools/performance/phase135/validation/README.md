# Phase135 bounded validation

These tools transport bytes, freeze identities and orchestrate existing checks.
They do not implement Bend lowering, semantic cache keys or optimization policy.
The coordinator runs targets in the single controlled native lane.

## Real compiler edit

`full-session-v01.py` freezes and runs the historical Phase132 one-declaration
compiler edit through the existing native session. Its complete A/B QBE oracles
bind the exact actual source paths. `ordinary-baseline-v01.py` measures ordinary
uncached B using the same executable and unchanged ordinary entry. Both preserve
the original source, images and independent oracles.

The [edit contract](../../../../../design/phase135/edit-contract.md) explains
clock boundaries, invalidation and expected evidence. The extracted emitter
slice is source-only and must be checked before use; a lexical packaging closure
is not a semantic cache dependency proof.

## Framed machine images

`machine-smoke-plan-v01.py` freezes a metadata-only first native FIFO test:
A and B are the same **original absolute Lexer source path**, and both payload
oracles are the independent original Lexer QBE. It records the forthcoming
image path without pretending acquisition has finished. The existing joined
supervisor authenticates the completed exact image receipt at execution time.
Only the coordinator runs the emitted resource-guarded command. This smoke
tests native framing, transport and machine caching; A=B is not an edit result.

```sh
python3 selfhost/tools/performance/phase135/validation/machine-smoke-plan-v01.py \
  --out selfhost/build/phase135/machine-native-smoke-plan01
```


`machine-gates-v01.py` adapts the already executed Phase132 gates without changing
the original tools. Preparation requires:

1. A complete ordinary aligned monolithic build of the exact independent full B
   QBE, using the same runtime object.
2. Complete cold and reused framed B builds, each checked against that entire
   independent QBE payload. Cold uses a distinct initially empty cache.
3. The machine agent's comparison proving identical current unit keys and exact
   loaded ELF sections/headers between cold and reused B.
4. A separate complete producer-status join: producer image, source pins,
   exit code zero and exact machine-report pins. A machine consumer's successful
   EOF alone does not prove the compiler succeeded. The machine reports retain
   their explicit unpublished status until their external producer is joined.
5. The supervised cold-replay receipt, binding current retained B, the exact cold
   machine result, and successful exits of both replayer and machine consumer.

The initial expected join fields are `complete`, `producerExitCode`, `producer`,
`sources`, `machineReports`, and `inputs`. This is a boundary contract for the
existing coordinating supervisor, not another execution service. If the actual
supervisor uses another schema, adapt and re-freeze this metadata reader before
running; never hand-mark an incomplete original receipt as complete.

```sh
python3 selfhost/tools/performance/phase135/validation/machine-gates-v01.py \
  --prepare \
  --monolithic MONOLITHIC_B_BUILD_JSON \
  --cold COLD_B_BUILD_JSON \
  --warm REUSED_B_BUILD_JSON \
  --comparison COLD_REUSED_ELF_COMPARISON_JSON \
  --producer-join SUCCESSFUL_PRODUCER_JOIN_JSON \
  --replay-join SUCCESSFUL_COLD_REPLAY_JOIN_JSON \
  --out selfhost/build/phase135/machine-gates-plan01

python3 selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase135/machine-gates-guard01 \
  --seconds 240 --rss-mib 3072 --available-mib 16384 --file-mib 128 --cpu 3 -- \
  python3 selfhost/tools/performance/phase135/validation/machine-gates-v01.py \
  --run --plan selfhost/build/phase135/machine-gates-plan01/plan.json \
  --out selfhost/build/phase135/machine-gates-executed01
```

The three compiler roles are **monolithic edited B**, **cold partitioned edited
B**, and **reused partitioned edited B**. They compile the same frozen Lexer,
Closures256 and Map128 sources at their original absolute paths. All three roles
must emit the existing independent *edited-main* QBE oracle. No source-path
normalization, broad local-name replacement or candidate-derived oracle occurs.

Two rounds reverse both role and case order: 18 requests comprise the nine
mandatory complete-QBE gates plus nine timing repeats. Each request retains its
own raw product and process wall/CPU/RSS receipt. Compiler-request ratios are
per-case paired observations with a geometric summary, not a replacement for the
frozen broad benchmark or evidence about every Bend workload. The same runtime,
carrier, source and compiler-image identities are verified before and after.

Then the existing aligned builder compiles and executes all three outputs from
monolithic and cold roles: six ordinary-output gates. Reused-role outputs have
already proved byte-identical to the same QBE. Their generated programs can use
the same downstream products under the pinned runtime/tool/flag contract.

This last fact is **generated-code preservation**, not a fresh program-runtime
speed measurement. Do not reinterpret one ordinary smoke execution as a runtime
benchmark. Conversely, partitioned compiler code layout can differ from the
monolithic compiler, so its own request timing must actually be measured.

No broad 45-program campaign, new compiler acquisition, runtime change or full
self-hosting qualification is included. Promotion and larger validation remain
separate decisions after these finite gates and actual end-to-end costs pass.

## Final metrics without target reruns

`analysis-v01.py` reads only bounded JSON receipts, checks their cross-links, and
produces a fresh `finalmetrics.json`. It does not read generated QBE, assembly or
executables, invoke targets, or authenticate new compiler semantics. Run it only
after the coordinator has frozen the final paths and all writers have closed.

```sh
python3 selfhost/tools/performance/phase135/validation/analysis-v01.py \
  --ordinary-baseline ORDINARY_B_REPORT \
  --semantic-session ORIGINAL_UNFRAMED_FULL_SESSION_REPORT \
  --native-session FINAL_FRAMED_NATIVE_JOIN \
  --cached-replay MATCHED_A_ONLY_CACHE_REPLAY_REPORT \
  --cold-replay INDEPENDENT_COLD_REPLAY_REPORT \
  --cache-snapshot A_ONLY_VIEW_SNAPSHOT_JSON \
  --cache-membership ACTUAL_A_ONLY_REPLAY_MEMBERSHIP_JSON \
  --gates-summary MACHINE_GATES_SUMMARY_JSON \
  --guard acquisition=ACQUISITION_PROCESS_JSON \
  --guard native_session=SESSION_PROCESS_JSON \
  --guard machine_gates=GATES_PROCESS_JSON \
  --out selfhost/build/phase135/finalmetrics.json
```

Additional `--guard LABEL=PROCESS_JSON` arguments retain acquisition, baseline,
replay, failed attempts and other closed process-tree costs separately. The
analysis makes no grand total from overlapping or nested clocks. It reports the
old same-image cache comparison separately from the newer instrumented native
image; stage fractions include render backpressure. Matched backend-only replay
includes preflight, reports A-only snapshot acquisition separately, and verifies
every B unit hit against both original native B and exact A membership.

The three-case compiler-request summary is recomputed from paired observations
and retains per-case ratios. It produces no new upstream ratio, full N2 score,
generated-program runtime claim, or end-to-end edit speedup from isolated machine
replay savings.
