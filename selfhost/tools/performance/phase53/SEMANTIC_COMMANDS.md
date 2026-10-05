# Phase53 independent semantic qualification

Root serializes target jobs. All acquisitions use the frozen Phase52 acquire-semantics-v2 producer, which owns its resource guard. Do not put a second supervisor around acquisition. Node controllers require the existing phase32 bounded supervisor, CPU3, 1GiB heap, 2GiB tree RSS and 4GiB available-memory floor. Never mix these untimed semantic observations into benchmark samples.

The corrected/default checkpoint passed all96 independent source scenarios. Pinned TS passed95, with original NaN-table golden40 observed as1. Candidate40 remains mandatory. Numeric cold controls observed candidate40 on every original and renamed fresh/repeated call. Corrected01 still violates pinned callback order in computed intrinsic operands; the new ordered candidate must satisfy those controls, without a waiver.

The consumed initial composition diagnostic showed healthy TS8/8 and corrected01 zero of8 order gates. The expanded composition reference passed18/18 in `selfhost/build/phase53/semantic-composition-reference02/report.json`. Source-v7/catalog-v8 includes opaque call, constructor field, Let argument, deferred closure, captured expression-Let alias, nested Let, sibling same-name captured binders, named partial and oversaturated calls, each getter/throw. Invalid predecessor source checks and the initial reference16/18 demand-checkpoint failure remain preserved. The sole checkpoint correction follows the exact pinned generated eta closure, and changes no complete event/value/error oracle.

For a final selected attempt, acquire the unchanged29 sources under Phase52 semantic-catalog-v8 and join the same four retained TS acquisitions using Phase52 semantic-full-join-v4. Then run semantic-source-v1 on that join. Acquire the two numeric sources under Phase53 semantic-numeric-catalog-v3, and run semantic-runtime-v2 with the new standard join, candidate numeric acquisition, and `selfhost/build/phase53/semantic-numeric-reference-rebind01.json`. This rebind preserves old checked TS source/module/catalog receipts, changes only the independently reviewed computed-event protocol, and makes no semantic claim.

Acquire the one composition source under Phase53 semantic-composition-catalog-v8. Run:

```sh
python3 selfhost/tools/performance/phase32/bounded-run.py \
  --seconds 60 --rss-mib 2048 --available-mib 4096 NEW_SUPERVISOR \
  -- taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/performance/phase53/semantic-composition-v3.mjs \
  NEW_CANDIDATE_COMPOSITION_MANIFEST \
  selfhost/build/phase53/semantic-composition-reference-rebind01.json NEW_REPORT_DIR
```

The source controller requires96 candidate source passes and retains exact TS95/differential95. Runtime controls require all34 candidate oracles, every reference healthy, all reference finite/order oracles, and preserve exact TS NaN failures separately. Composition requires all18 candidate and reference value/error/event oracles and exact differential agreement. Strict runtime/composition successors also check observation outcome/value/error independently of the inherited worker's mutation catch.

Only the final optimized selected image needs the unchanged maintained8 and census26 jobs:

```sh
python3 selfhost/tools/performance/phase47/qualify.py ATTEMPT NEW_MAINTAINED_OUT
python3 selfhost/tools/performance/phase53/direct-conformance-v1.py ATTEMPT NEW_CENSUS_OUT
```

Both own their existing execution guard. Explicit default/direct/legacy routing and release smoke belong to the release owner; these semantics controls explicitly acquire the direct backend and do not substitute for routing evidence.
