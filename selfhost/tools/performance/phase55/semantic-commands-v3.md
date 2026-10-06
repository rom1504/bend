# Phase55 focused gates

Root schedules CPU3. Each command owns one outer guard; do not nest or overlap them with generation/retention jobs. Both output directories in each command must be fresh.

```sh
python3 -B selfhost/tools/performance/phase32/bounded-run.py \
  --seconds 120 --rss-mib 2048 --available-mib 4096 \
  selfhost/build/phase55/arity-controls03-supervisor \
  -- taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/performance/phase55/semantic-arity-controls-v3.mjs \
  selfhost/build/phase54/checked-graph02 selfhost/build/phase55/checked-host02 \
  selfhost/build/phase55/arity-controls03

python3 -B selfhost/tools/performance/phase32/bounded-run.py \
  --seconds 120 --rss-mib 2048 --available-mib 4096 \
  selfhost/build/phase55/host-controls01-supervisor \
  -- taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/performance/phase55/semantic-host-controls-v1.mjs \
  selfhost/build/phase54/checked-graph02 selfhost/build/phase55/checked-host02 \
  selfhost/build/phase55/host-controls01
```

The arity gate uses the ordinary driver's ABI2 completed program book, then actual lookup and selected annotation; it separates source-event and completed-book fingerprints. Six checked inputs, two real rejections, four independent arity goldens, erased/dependent matcher fields, and genuine unannotated fallback remain mandatory. Both roles use private byte-identical projects for driver/cache isolation. V1/v2 failures remain preserved: raw event duplication and lookup of an unfilled header were harness assumptions, not compiler semantic failures. Check-phase rejections are `checked:true/typeAccepted:false`, while parse-phase rejections are `checked:false/typeAccepted:false`, following the actual public driver contract.

The eight-case host gate compares exact actual helper-generated wrappers and evaluates fixed values/events using actual API runtime helpers. Native Nat only in a result (Number 9 must become BigInt 9), callback, Array element, and constructor field must retain conversion; erased Nat and recursive no-Nat graphs retain zero conversion. Two independent 260-field types each fit the 1024 scan but their combined signature exceeds it: status2 must use the original component wrappers, not reject. Canonical synthetic type graphs are a private helper boundary test; actual accepted source semantics and newly generated compiler usability remain separate qualification scopes.
