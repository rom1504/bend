# P4-024 derived-B1 full frontend gate

The experimental native-string-equality B1 candidate preserved **all 2,756 raw
parse/check observations and harness verdicts** against the final checked B1
reference. The independent read-only audit also verified all **45 actual worker
histories**, each result digest and replay prefix, and **1,494 input mappings**.
The result remains 1,920 pass, 459 observed, and 377 fail. Existing failures were
retained, not converted to passes.

This supports the [bounded P4-024 experiment](b1-native-equality.md). It is not a
new checked bootstrap: `newBootstrap:false` is recorded throughout. The genuine
checked proof covers control `0653f21e7e227bf7bf7e3ad777630da64d520534753900636a571ed57a43f810`. The derived candidate
is `e95e119847307aa215765fcbea63d3b9e4a2bba625f3d30a915f298eb6ed9821`; before running, the tool independently rebuilt
its bytes using the exact reviewed transformation and checked the full image
and function-body guards. Public distribution and ordinary emitted code remain
outside this gate's claim.

## Method and retained results

The tool copied the completed P4-021 frozen harness, adapter and host. It
prepared a separate cache by checking Base with the candidate, validated its
compiler/Base/canonical-path/serialized-book identities, then ran four
persistent workers sharing cores 0–3. Each worker had a 4 MiB stack, 4 GiB heap
and RSS recycling threshold, recycled after 64 requests, and had a five-minute
per-request deadline. The sweep had a separate 15-minute outer bound; cache
priming had a three-minute bound. All consumed inputs remained unchanged.

The original runtime and canonical Base remained the same as the reference.
The gate checked every fixture hash, complete raw result, harness status/reason/
evidence, imported/foreign input mapping and session history. There were zero
worker failures/timeouts and zero result differences. The child harness exit
status remains 1 because the same 377 conformance failures remain present;
the enclosing gate's success means exact, complete observation parity.

Base priming took 3.721 seconds and the sweep took 232.622 seconds. These are
retained run durations, **not a controlled performance comparison**. No fresh
paired B1 scheduling control was run for this candidate. The separately
controlled P4-024 core pilot supports its own narrower performance claim.

The [durable archive](b1-native-equality-frontend-evidence/README.md) retains
reports, complete results, failed reproductions, histories, frozen tools,
control/candidate images, and original checked provenance. Archive verification
reopened every actual member and checked its relative path and bytes; no
compiler was rerun during archival or the independent audit.

## Reproduction

From `selfhost/`, with the preserved exact preparation and checked-scheduler
snapshot, use fresh output paths:

```sh
taskset -c 0,1,2,3 node tools/performance/phase4/derived-frontend.mjs \
  build/phase4/b1-native-equality/prepared/report.json \
  build/phase4/frontend-scheduling/snapshot NEW_FRONTEND

taskset -c 1 node tools/performance/phase4/derived-frontend-audit.mjs \
  NEW_FRONTEND/report.json NEW_AUDIT.json

taskset -c 1 python3 tools/performance/phase4/derived-frontend-archive.py \
  NEW_FRONTEND/report.json NEW_AUDIT.json NEW_EVIDENCE_DIRECTORY
```

The audit and archive commands execute no compiler. They fail on changed
identities, results, histories or input paths. Use the recorded Node 24 runtime
and the original canonical paths for an exact reproduction. Do not present the
derived image as a checked bootstrap, or this parse/check gate as generated-code
or arbitrary mutable-host API equivalence.
