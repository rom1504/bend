# Final artifact frontend validation plan

Status: static preparation only. No compiler, test, syntax check or archive job was launched to prepare this plan. The final full-source performance window and separate genuine fixed-point proof retain exclusive machine access first.

After the completed proof, run the existing full inventory through four persistent workers on CPUs 0–3, first with public H and then with the final maintained equality derivative. Each must produce all **2,756 parse/check observations for 1,378 pinned fixtures**, exactly matching final checked B1's raw semantic result objects and harness verdicts. Known strict failures remain failures. A complete artifact-equivalence gate does not imply full-language conformance.

## Scheduling evidence and limits

The closest retained H-family inventory is Phase4's **private** H image: one persistent worker took 2,337.382 seconds (38m57s); an earlier private-H observation took 2,562.167 seconds. These are not public-H timings. The Phase2 public-H gate checked only 50 selected frontend cases in 106.212 seconds; its workload is not representative enough to extrapolate a full inventory. There is no evidence-backed guarantee that final public H finishes in 45 minutes on one core.

Root therefore chose the simpler four-worker full-inventory schedule rather than introducing sharding and merge code. The initial outer bounds are 30 minutes for H and 15 minutes for the derivative, with a 02:45 UTC campaign cutoff. Prior Phase4 four-worker derivative validation took 232.622 seconds, but the final source/host differ; that historical observation is not a promised five-minute duration. Root will assess actual progress and remaining campaign time. A timed-out attempt stays incomplete with its progress, worker records and failure retained; coverage is not reduced to manufacture a pass.

Broader execution/backend gates wait for these frontend gates, then use the available cores under root's scheduling. The 03:39:36 campaign end reserves room for their completion and final reporting. No speed comparison is intended: these are resource-bounded validation runs with recorded setup and workflow times.

## Genuine lineage

The thin wrapper [final-artifact-frontend.mjs](../../selfhost/tools/performance/phase5/final-artifact-frontend.mjs) verifies:

- The normal checked attempt-05 and actual bootstrap/module provenance.
- A completed unchanged `selfhost.mjs` proof at `build/phase5/final-selfhost/proof-01/report.json`, with successful input-verified stage2 and stage3, exact byte equality, genuine B1 as initial compiler, and matching final source/Base/runtime/host.
- The completed P5-023 six-row comparison and maintained derivation report. Every measured Bend output must match the proved H bytes. The derivative retains its own derivation identity; neither H nor the derivative receives a fabricated checked-bootstrap report.
- The final B1 reference report at `attempt-05/validation-001/frontend.json`, including healthy infrastructure, complete duplicate-free inventory and matching compiler/Base/runtime identities.

The wrapper copies the same frozen host/adapter/harness bytes, separately validates one on-disk Base cache per artifact before the sweeps, and invokes the maintained `tools/conformance/run.mjs`. It does not implement compiler logic, alternate oracles, new probe scheduling or sharding. Settings remain four workers, 300-second request limit, 4MiB Node stack, 4GiB heap/RSS bound, and recycling after 64 requests.

The audit requires unchanged fixture and input hashes/canonical paths, unchanged consumed artifacts, no crashes/timeouts/unsupported observations, exact result objects and status/reason/evidence fields, and all 2,756 observations mapped uniquely to closed worker histories. Actual request IDs, lanes, result digests and replay-prefix validation must pass. Raw known failures and generated-H diagnostics are compared directly with B1, without normalization.

An artifact-local priming failure, timeout or comparison failure is retained and the other artifact can still run within the remaining deadline. There is no implicit retry, reduced inventory or successful overall gate unless both artifacts pass. Shared provenance and input identities are verified before each artifact and after any failure; identity drift stops the entire campaign rather than continuing under changed inputs.

## Launch after root clearance

Copy the [example config](../../selfhost/tools/performance/phase5/final-artifact-frontend.config.example.json) to the final run location with absolute paths. Adjust its prospective deadline if the proof finishes later, before the config is consumed. The example points to the actual planned proof path, not a substitute proof.

```sh
node --stack-size=4096 --max-old-space-size=4096 \
  selfhost/tools/performance/phase5/final-artifact-frontend.mjs \
  FINAL_CONFIG.json NEW_OUTPUT_DIRECTORY
```

All process supervision uses the maintained file-backed bounded helper. Base priming, immutable proof checks and post-run audits are outside the harness wall observation. Final implementation status and results belong in a separate report; this plan records no successful generated-H frontend execution yet.

## Prospective launch adjustment — 2026-09-23

The genuine proof completed at 02:10:22.188 UTC. Before launching either frontend sweep, the actual configuration reduces H’s cap from 30 to **25 minutes**, retains the derivative’s 15-minute cap subject to the unchanged **02:45 UTC** global deadline, and keeps all 2,756 observations per artifact. This reserves approximately seven minutes for the derivative; setup and priming also consume the shared budget. The exact configuration and consumed wrapper snapshot are retained in `selfhost/build/phase5/final-artifact-frontend-launch/`. This is a prospective scheduling adjustment, not reduced coverage or a timing comparison.
