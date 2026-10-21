# Phase120: bounded numeric optimization experiments

[Design](../../../../design/phase120/first-cycle.md) ·
[Results](../../../../implementation/phase120/README.md) ·
[Word findings](word/results.md) · [Region findings](regions/results06.md).

All compiler transformations are Bend modules. Python/JavaScript here compose
declarations, authenticate artifacts, call checked Bend APIs, invoke the existing
backend, check independent outputs, and measure. They do not implement a second
compiler. The experimental producer is the checked Bend compiler hosted in JS;
new native N1/N2 images are a separate qualification, not included in this cycle.

The parent is qualified Phase118 safe03. Use its authenticated source, API,
runtime and original45 benchmark products; see the [Phase118
instructions](../phase118/README.md) if rebuilding those assets. The benchmark
manifest, literal outputs, upstream binaries, repetition counts and runtime
arguments are unchanged. Historical artifacts are required; this is not a
standalone benchmark that downloads today's upstream.

From the repository root, compose the exact experimental integration source:

```sh
python3 -B selfhost/tools/performance/phase120/reproduce.py \
  --out selfhost/build/phase120/my-source
```

`candidate-recipe.json` pins every module and the expected complete source.
The command authenticates inputs and checks the resulting source hash. It does
not select a production compiler. `prepare.py` records every overridden parent
or module declaration and rejects undeclared overlaps. Failed earlier versions
are retained under `word/` and `regions/`; use the recipe, not a directory glob.

Check a fresh source/API with Phase111 `check-api.py`, exporting
`p88_cache_prepare p86_plan p111_runtime_admission p111_emit_admitted
p113a_lower_request p113a_verify` plus the relevant controls. Every target
command uses `phase111/guard.py --seconds LIMIT --rss-mib 2048
--available-mib 16384 --file-mib 64 --cpu 3 --out FRESH_GUARD -- COMMAND`.
Keep target commands serial; offline source inspection may run concurrently.

The retained checked API is `selfhost/build/phase111/p120-combined-api01/report.json`.
The later API03 reproduces exact45+6 QBE bytes with the same runtime, but remains
unselected after its whole-cost screen. `candidate-recipe.json` reproduces01;
`candidate-recipe03.json` preserves the later composition for research.
Controls and original command lines are preserved in the evidence capsule:

- `word/controls.mjs`:14 admission/refusal cases,60 independent BigInt values.
- `checks-v2.mjs`: explicit `:unit` calls for17 word-width controls and,
  in unselected03,13 prefilter controls;
  nine constructor-ID controls use a zero-argument export.
- `regions/shortcut-controls.mjs`:27 eligibility/profit/budget/identity controls.
- `combined-controls01.json`:six ordinary programs with unchanged literal
  outputs, including floating-point rounding, NaNs, signed zero and conversions.
- `phase118/emit-integrated.mjs`: checked request-bound emission, independently
  checked parent IR, unchanged runtime. Its historical output namespace is
  `selfhost/build/phase118/p120-*`; set `P118_RUNTIME_REPORT` to the Phase118
  `runtime-extend01/report.json`. Set `P118_CASE_MANIFEST` for ordinary controls.
- `phase118/functional-v2.py`: builds ordinary controls and runs the exact oracle.

For generated-program timing, call `screen.py --emission REPORT --out FRESH
--label UNIQUE --rounds 3 --scale 4` under the guard. It builds each candidate
once, then rotates candidate/actual Phase118/upstream execution order. All three
products must match the frozen full output/count oracle. `scale` multiplies the
frozen repetition count; it changes duration, not source inputs. The broad run
contains all45 original programs and405 observations, with44 ratio-eligible
cases. `scalar-region-0` remains a correctness case without a timing ratio.

Use `summarize.py --out FRESH.json SCREEN_REPORT...` for medians and geometric
ratios. Compare aggregates only for identical populations. `machine.py` retains
authenticated disassembly and whole-function static counts; those counts are
neither executed instruction counts nor historical hot-loop counts.

For compiler cost, use the existing `phase118/cost-v2.mjs` under pinned
`selfhost/.bootstrap/bun-1.4.3/bun`. Set parent selection/API/emission and candidate
emission environment variables as in the retained guard command. It measures
one warmup and three rotated paired rounds, checking deterministic emitted bytes.
`stage-cost.mjs` separates word analysis from verification on a fixed prepared
graph. Neither measurement is native B1/B2 throughput or upstream parity.

After all guards finish, `accounting.py --out FRESH.json` totals exclusive guard
categories, including failures. `seal.py seal` archives small receipts, outputs
and copied methods. `seal.py replay ARCHIVE` checks every member digest without
extracting files. Large compiler sources, generated SSA, runtime objects and
binaries stay outside the capsule; their recorded identities remain in receipts.
Digest replay verifies evidence integrity, not compiler correctness or timings.
