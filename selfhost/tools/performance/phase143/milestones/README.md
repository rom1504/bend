# Optional same-engine stage milestones

This diagnostic adds a small reversible delta to the existing context runtime,
then relinks the **unchanged Phase142 N1 program object**. It does not rebuild
compiler QBE, modify compiler source or install a compiler. The prepared markers
are exact `$direct.*` dispatch entries, not named factories that can create a
closure before its body executes. Their FIDs and linked addresses must agree
with the exact current QBE/ELF map.

`prepare-v01.py --profile selfhost/build/phase143/profile01 --out FRESH` writes
the runtime delta, generated bounded rank table, build plan and provenance.
It runs no build or target. `jobs.json` contains only the guarded small runtime
compile and relink; the coordinating agent owns execution.

Enable only for a sequential single ordinary request, using a fresh dedicated
`BEND_MILESTONES_OUT=/absolute/sidecar.json`. This sidecar is written at normal
process exit; successful stdout and stderr remain unchanged. Event counters must
be disabled and no events-output path may be set. Existing `native-request.py`
can supervise this image under the existing resource guard: its ordinary
command, Base/carrier admission and expected-QBE comparison remain unchanged.
Keep `env BEND_MILESTONES_OUT=...` in the recorded outer guard command so the
sidecar is explicitly bound to that request.

Each dispatch performs an optional bounded rank lookup. Only eleven selected
entries read monotonic wall/process CPU clocks; the recorder allocates no state
per dispatch. The fixed rank table covers FIDs 0..2163, with eleven rows. It
records duplicate/out-of-order/missing markers as invalid attribution rather
than inventing intervals. Private helper calls or inlining may bypass a marker;
this is a decisive falsifier of the proposed boundary, not permission to relax
the test.

Required first gate: build the diagnostic runtime, run one small real request
with its existing independent whole-QBE oracle, then run the data-only verifier:

```sh
python3 -B selfhost/tools/performance/phase143/milestones/verify-v01.py \
  --plan PATH_TO_MILESTONE_DIRECTORY/manifest.json \
  --build PATH_TO_MILESTONE_DIRECTORY/build/report.json \
  --request PATH_TO_NATIVE_REQUEST/report.json \
  --sidecar ABSOLUTE_FRESH_MILESTONE_SIDECAR \
  --guard PATH_TO_REQUEST_GUARD/process.json \
  --out FRESH_VERIFICATION.json
```

The verifier independently joins successful output, actual build commands,
unchanged object lineage, fresh sidecar binding, exact ELF dispatch addresses,
eleven unique ordered entries and monotonic timestamps. A failed marker gate
still retains the correct program-output evidence but admits no stage timings.
Do not launch another full-source run unless this small gate passes and exact
native intervals would change the next optimization decision.

Intervals expose Base preparation, parse/load, checking/publication, report,
eligibility, context, annotation, layout checking and erasure/request completion.
They include scheduler and reference-management work between entry boundaries.
They do not isolate checker publication from type checking or prove a particular
pass's optimization ceiling. The final verifier remains enabled. Measure the
added runtime hook's overhead against the same clean image before reporting a
clean speed change; no neutrality or performance improvement is assumed.
