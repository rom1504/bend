# Broad default-CPU C comparison

This optional follow-up reuses the checked JS-hosted Bend B1 and Phase88's 45
previously executed catalog points. It compares complete minimized preprocessor
outputs against independent old B2 C. It does not build native compiler images
or execute generated programs. Native self-emission and its real gates take
priority.

`prepare.py manifest FRESH_DIRECTORY` verifies the sealed Phase88 capsule,
manifest, source pins and prior successful C/execution reports, then checks all
45 archived B2 outputs in memory. It restores no C files. Existing prepared
metadata: `selfhost/build/phase90/broad-token-oracles01/manifest.json`.

The runner extracts one baseline at a time with `prepare.py extract`, verifies
its complete digest/length, and uses a newly opened read-only regular file as
Clang stdin. After the complete equal-output comparison it removes only that
temporary baseline. Its exact archive member and original digest remain in the
report. Current C and both full preprocessing outputs remain for review.

Root runs the following serially, using fresh output and guard directories:

```sh
python3 -B selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase90/BROAD_GUARD --seconds 30 \
  --rss-mib 1536 --available-mib 4096 --cpu 3 -- \
  /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/performance/phase90/broad-tokens01/run.mjs \
  selfhost/build/phase90/compiler06/attempt.json selfhost/build/phase90/BROAD_OUTPUT \
  --seconds 20 --guard-dir selfhost/build/phase90/BROAD_GUARD
```

Use `--seconds 20`, `60` or `300` for deterministic nested tiers of 4, 16 or 45
points; use outer guards of 30, 70 or 310 seconds respectively. These are actual
budgets, not measured runtime promises. The worker stops before a new request
or preprocessing step if its budget expires; the outer guard bounds an ongoing
request. An interrupted or incomplete selection is not a passing comparison.
Every report lists selected, unselected and actually completed points. Twenty
seconds selects pair, closure, Unicode and map-churn cases; sixty adds numeric,
tree, lexer, expression, list, record, array and representative workloads.

`--check-only` validates bindings without loading/running the compiler, spawning
Clang, or extracting C. `broad-token-preflight01/report.json` passed this check
for the 20-second tier. No broad target comparison has yet been executed by this
preparation lane. `derivation.json` records exact reversible edits from the
previously executed four-case `whitespace-check-v3.mjs`.

The equality claim is restricted to default CPU preprocessing. It does not
qualify GPU branches, arbitrary raw `N_Segment` text, all Bend programs, runtime
performance, a native build or a native fixed point.
