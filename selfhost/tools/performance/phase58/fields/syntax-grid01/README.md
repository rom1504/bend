# Independent JavaScript field-syntax screen

Unexecuted protocol. This is a JavaScript microexperiment, **not Bend/TypeScript
compiler output or a checked compiler image**. The fixed proposed policy is
computed ordinary keys for width <=4, literal ordinary keys above4. The screen
can support or refute that policy; it does not search for a best threshold.

The frozen config selects widths1,2,4,5,8,12 × immediate projection / loop-carried
record / opaque escape × numeric / mixed payloads: 36 cases. Three fresh rotated
rounds compare both roles, giving216 fresh-process samples. Each worker validates
its full checksum and escaping records against an independently written
array-valued trusted model before and after 350ms warmup plus150ms measurement.
Every timed batch contributes to an independently predicted aggregate checksum.
Only ordinary constructor-key syntax differs between the generated role bodies;
the producer asserts exact inversion of those key tokens.

Numeric fields use deterministic U32 arithmetic. Mixed records additionally
contain deterministic strings. Loop-carried records feed the previous complete
field digest into the next record; opaque escape sends every record to an
external64-slot ring. Immediate and loop-carried contexts additionally expose
every256th record, preventing complete unobservability while retaining bounded
storage. This does not guarantee that V8 materializes every intermediate object:
scalar replacement is part of the measured question. No I/O, callback side
effect, coercion or custom-host contract is varied. All keys are ordinary fN
keys; source-level __proto__ safety is covered by the separate genuine checked
field controller, not this numeric width experiment.

Root runs this only after the active V8 diagnostic, with one outer guard:

```sh
python3 -B selfhost/tools/performance/phase32/bounded-run.py \
  --seconds 180 --rss-mib 2048 --available-mib 4096 \
  selfhost/build/phase58/js-field-grid-screen01-supervisor -- \
  taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --max-old-space-size=1024 \
  selfhost/tools/performance/phase58/fields/syntax-grid01/grid.mjs \
  screen selfhost/build/phase58/js-field-grid-screen01
```

The launcher has no resource guard, launches samples serially and gives each
worker a256MiB heap and10s subprocess ceiling. CPU affinity is inherited. The
planned active microcode windows total108s, plus process/oracle/progress overhead;
180s is a bounded ceiling, not a requested duration. Pin/hash/Node identities,
generated code, per-process checksums, timings, RSS, stdout/stderr and every
sample are retained. Failures leave partial evidence. Per-case role medians and
ratios are descriptive three-sample statistics; there is no pooled overall
threshold selection or confidence interval.

If root finds a consistent independently reviewed boundary across contexts and
payloads, use the unchanged `withheld` mode in a fresh output/supervisor to test
widths3,6,7,9,10,11 (another216 samples). A narrow width policy must survive both
the withheld cases and genuine compiler/generated-program qualification before
source adoption. Flat/noisy or context-conflicting results stop this synthetic
hypothesis. Regardless of outcome, the completed whole-rollback compiler
regression remains independent evidence and must not be erased or averaged into
these microtimings.
