# Map native closure-sharing discriminator

These small programs isolate the Phase86 native observer failure before another
19.54MB compiler image is built. They are experiment sources, not production
changes. `acquire.mjs` fully checks each program with pinned upstream0592662 and
saves complete raw C/JS. Checking and execution are separate: `@unsafe` permits
some programs to check even though their requested closure sharing is not a
supported native runtime operation.

| Fixture | Question | Observed check / JS / native |
|---|---|---|
|`law-eager.bend`|Original separate law plus two branch thunks capture k|pass /83 / sharing fail-stop|
|`typed-eager.bend`|Does spelling the signature inline change sharing?|pass /83 / sharing fail-stop|
|`law-match.bend`|Change only eager thunk construction to a case split|pass /83 /83|
|`typed-match.bend`|Fully affine direct match without unsafe|pass /83 /83|
|`typed-thread.bend`|Pass k once into a branch-dispatch helper|pass /83 /83|
|`safe-eager-negative.bend`|Does safe checking reject the double capture?|reject; no emission|
|`typed-double.bend`|Two actual calls, independent of choice syntax|pass /83 / sharing fail-stop|
|`data-double.bend`|Represent a reusable continuation as Data|pass /83 /83|

All eight predictions were confirmed by root-owned guarded runs in
`selfhost/build/phase87/map/summary.json`; raw output is in each role's
`stdout.log`/`stderr.log`. The seven positive sources fully check; all seven raw
JS images print83. Four native controls print83; the three closure-sharing
controls exit1 with `bend: runtime fail-stop`. The safe negative fails checking
with `k (consumed more than once)` and emits no program.

Law-eager and typed-eager produce byte-identical C and JS; law-match and
typed-match also produce byte-identical C and JS. The signature spelling is not
the cause. The29 guarded jobs consume15.842s summed target wall time over a22.651s
campaign span; peak process-tree RSS is240.92MiB. This is a correctness fast loop,
not a generated-program speed benchmark.

Both Bool arms execute across the two calls to `run` in
the branch controls. The closure captures its `seed` parameter rather than being
a static closed lambda. Pure numeric output avoids foreign-effect adapters and
string-equality derivatives. Use the complete generated raw JS unchanged.

Run one fixture at a time from the repo root, fresh directories, under the existing
guard. Example (replace CASE and NEW_OUT with absolute paths):

```sh
python3 -B selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase87/map/NEW-guard --seconds 30 -- \
  /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/performance/phase87/map/acquire.mjs CASE NEW_OUT
```

`NEW_OUT`'s parent must exist. The acquisition verifies retained Phase86 upstream
pins and current manifest upstream; it copies its own script and fixture and
records hashes/phases. It does not invoke Clang or execute emitted code. Check
`report.json` before running `program.cjs` or building `program.c`. Compile with
the same pinned Clang22/O2 flags as Phase86, then run `--threads 1 --gpu off`.
Keep expected failing native runs and the safe checker refusal as nonzero raw
receipts. Root owns all target execution, serially, with bounded RSS and time.

The strongest early sequence was law-eager, law-match, typed-eager, typed-double,
data-double. Preserve complete emitted code as well as outputs; the small controls
establish the ownership mechanism, not a complete full-compiler repair.

Direct matches are only a partial source remedy: the full observer intentionally
uses the same continuation while evaluating both symbolic match branches.
`noa_match_fields` must ultimately receive a duplicable continuation description
or construct separate fresh continuations from duplicable captured data. Passing
an existing closure through a typed wrapper does not make it shareable.
The [investigation](../../../../../implementation/phase87/map-investigation.md)
maps all eight proposed continuation frame shapes. That repair remains a design;
the production observer is unchanged.
