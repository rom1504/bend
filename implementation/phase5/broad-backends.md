# Final default compiler: broad JS/native validation

The fresh paired run completed **3,962 observations**, with all recorded compiler/host/input identities stable and no missing paired rows. Coverage is complete; strict conformance and infrastructure health are **not** passes. The chosen default, maintained equality-derived B1 SHA `e2b5463678a26558e8fea1d585782e0863f1046067949a374f0469080281b15a`, retains genuine checked parent `5969c53d…` and a separately verified derivation with `newBootstrap:false`.

| Compiler/lane | Observations | Strict pass | Strict fail | Not applicable | Unsupported | Crash | Timeout |
|---|---:|---:|---:|---:|---:|---:|---:|
| Pinned TS / JS | 999 | 842 | 0 | 121 | 36 | 0 | 0 |
| Derived Bend / JS | 999 | 720 | 158 | 121 | 0 | 0 | 0 |
| Pinned TS / native | 982 | 859 | 1 | 121 | 0 | 1 | 0 |
| Derived Bend / native | 982 | 703 | 157 | 121 | 0 | 0 | 1 |

A strict pass includes expected rejection/error cases, not only successful execution. All527 eligible negative observations were rejected by Bend;315 missed the strict diagnostic/phase oracle, spanning158 unique fixtures. Successful runtime results were604 JS/588 native for Bend and569 JS/588 native for TS. Among positive fixtures, Bend had614 JS and597 native strict passes,242 not-applicable observations, and one native timeout. The999 JS inventory contains735 positive/264 negative probes;982 native contains719 positive/263 negative. Another379 JS and396 native fixture/lane combinations were ineligible and are listed separately in preparation metadata; they were never counted as observed passes or not-applicable rows.

The paired report has354 exact differences across197 fixtures:299 diagnostic-only and55 other differences under the harness’s semantic comparison. Those55 are:

- 36 TS executions require unavailable Bun; Bend produced35 successful runtime outcomes and one expected runtime error.
- TS native `flatten/literal_rows_cubic.bend` hit Clang’s256 bracket-depth limit; Bend executed successfully.
- TS native `io/stack_fault_trap.bend` terminated with SIGSEGV; Bend returned a controlled expected runtime error.
- Bend native `reg/arity_wall.bend` exceeded the120-second probe deadline; TS passed.
- 16 negative observations rejected in a different phase:4 TS check → Bend parse,10 TS parse → Bend load,2 TS parse → Bend check.

These are not55new language-semantic failures. Existing diagnostic/phase differences remain failures, and environment differences remain explicit. The arity-wall timeout is the sole positive Bend failure in this selection. It emitted3,716,568 bytes of C but no binary before the deadline; the TS C is80,723 bytes. [The static footprint analysis](../phase6/native-arity-wall.md) identifies repeated scalar-field continuation frames and preserves the uncertainty about exact toolchain timing. No timeout rerun replaced this observation.

The run used four isolated workers sharing CPUs0–3,4GiB heap and4MiB stack each,120 seconds per probe,2,695 seconds for the target child and2,760 seconds outer cleanup bound. It ran02:38:49.554–03:08:40.743UTC on2026-09-23. Authorized short default-installation/diagnostic correctness work overlapped; **no performance comparison is claimed**. Fresh TS ran before the candidate. The immutable attempt05 host predates the later current-host `native-build.mjs` fix for a spawn error carrying exit status0. This run’s frozen helper identity is retained; it is not retroactively relabeled as the consolidated host.

Preparation04 prospectively selected the verified derivative; preparations01–03 remain untouched history. The actual invocation and environment are retained in `broad-run-01/launch.json`, explicitly recorded after launch. Reproduce into fresh directories from `selfhost/`, with the recorded Node and Clang environment:

```sh
node tools/performance/phase5/broad-backends.mjs prepare \
  build/phase5/integration/attempt-05 NEW_SNAPSHOT \
  --derivation=build/phase5/full-source-final/derived/api.mjs.derivation.json

timeout --kill-after=5s 2760s taskset -c 0,1,2,3 \
  node --stack-size=4096 --max-old-space-size=4096 \
  tools/performance/phase5/broad-backends.mjs run NEW_SNAPSHOT NEW_RUN
```

The derivative’s validated Base cache must exist in the attempt’s cache directory; preparation04 records the verified byte-exact cache copy. Preserve the current `CC`, `CPATH`, `LIBRARY_PATH` and `LD_LIBRARY_PATH` recorded in the archived launch file. Scope and refusal rules are in the [validation plan](broad-backend-validation-plan.md).

[Durable evidence](broad-backend-evidence/README.md) contains24,148 verified archive members, including raw reports/progress, all failed reproducers,1,196 actual C files and1,194 native binaries, genuine checked source/modules, derivation, frozen host and fixtures. The logical archive is107,566,763 bytes, SHA `f2697c3cf1cde72559750b5f8799d10a8c4a5f0970d083ee33c670576e424196`; three ordered parts keep individual repository files below size limits. Node/Clang/system dependencies remain external. `audit.py` derives counts from raw reports without rerunning a compiler; `archive.py` verifies every retained member. The optional public-H selected backend gate remains [prepared but unexecuted](public-h-backend-plan.md); its frontend/self-compilation evidence is not substituted for user-program backend coverage.
