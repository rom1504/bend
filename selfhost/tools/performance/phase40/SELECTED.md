# Selected frozen-plan execution

`selected-plan-run.py` reuses Phase35's input rehashing, serial supervised commands,
environment filtering and retained failures. It adds explicit skips and selects
only the named stage; preinstall does not automatically replay owners. The report
states skipped and selected commands; completion means those commands completed,
not that skipped gates are discharged. Root alone executes this runner.
Do not wrap the whole runner in the shared-lock bounded supervisor.

```sh
python3 selfhost/tools/performance/phase40/selected-plan-run.py \
  selfhost/build/phase40/final-plan02 --stage owner \
  --skip owner-counters --skip owner-close \
  --out selfhost/build/phase40/final-owner-launch01
python3 selfhost/tools/performance/phase32/bounded-run.py \
  --seconds 180 --rss-mib 2048 --available-mib 2048 \
  selfhost/build/phase40/counter-successor-run01 -- taskset -c 3 \
  /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase39/vector-counter-fixture-controls-v1.mjs \
  selfhost/build/phase40/final-plan02/owner/vector-fixtures/counters \
  selfhost/build/phase40/counter-successor01
```

After reviewing35oracles,5structures,5live boundaries and exact final emission/
successful supervised provenance, copy final-plan02/owner/reports.json into a
fresh owner-reports.json. Replace only cases.counters with the absolute path to
counter-successor01/report.json. Preserve original mapping/plan. The existing
collector and auditor accept this reviewed direct successor:

```sh
python3 selfhost/tools/performance/phase35/final-owner-close.py \
  selfhost/build/phase40/final-plan02/plan.json \
  selfhost/build/phase40/owner-reports.json selfhost/build/phase40/owner-report.json
python3 selfhost/tools/performance/phase40/selected-plan-run.py \
  selfhost/build/phase40/final-plan02 --stage preinstall \
  --out selfhost/build/phase40/final-preinstall-launch01
python3 selfhost/tools/performance/phase40/selected-plan-run.py \
  selfhost/build/phase40/phase36-owners01 --stage owner --skip close \
  --out selfhost/build/phase40/phase36-owner-launch01
python3 selfhost/tools/performance/phase37/phase36-owner-close-v2.py \
  FINALATTEMPT PREPARATION selfhost/build/phase40/phase36-owners01/cohorts \
  selfhost/build/phase40/phase36-owners01/mapping.json \
  selfhost/build/phase40/phase36-owner-close01/report.json
```

The old counter rebinder requires a same-plan failed launch and obsolete failure.
This selected route retains that historical precedent without creating a new
failure or fabricating a receipt. All other inherited/new semantic owners remain
mandatory. See INTEGRATION.md and integration-recipe.json for the other groups,
benchmarks, request cost and installation. Existing --owner-controls points to
fresh owner-report.json; it never selects an earlier-image owner result.

Preparation forms: PREPARATION is the manifest; PREPARATIONDIR is its parent.
Phase39 phase37-owner-plan.py specifically requires PREPARATIONDIR. The initial
phase37-owners01 manifest-path failure is preserved; phase37-owners02 is the
corrected fresh plan. Other selected runner commands consume plan directories,
not preparation manifests. No consumed runner/planner bytes change for this fix.
