# Version 2 diagnostic execution

Use `catalog-v2.json` explicitly for emission, construction, and runtime.
The old sources/catalog remain frozen. The root's first checked emission
passed ten sources, then rejected the memory helper's live use of an unfilled
forward law. Version 2 places `Array.get` and the next iteration in the same
directly recursive function. Only the two memory source files and their pins
change; all mathematical outputs and declared work are unchanged.
`oracle-v2.py` checks all 24 finite source/output points without target runs.

Correction to the original README: the fourth stdout line is **milliseconds**,
matching the existing `bench.observation` contract, rather than nanoseconds.
No program protocol changed.

The new `runtime-loop.py` imports Phase185's calibrated timing engine and the
maintained `bench` helpers. It authenticates all twelve catalog cases, source
and output pins, four explicit role manifests, and executable pins. It does
not establish new compiler-producer qualification; that remains with the
acquisition receipts carried in each supplied manifest.

The merge is metadata-only and requires these four aliases in order:

```sh
python3 selfhost/tests/phase194/diagnostics/runtime-loop.py \
  --catalog selfhost/tests/phase194/diagnostics/catalog-v2.json merge \
  --role c C_MANIFEST C_SOURCE_ROLE \
  --role qbe QBE_MANIFEST QBE_SOURCE_ROLE \
  --role baseline BASELINE_MANIFEST BASELINE_SOURCE_ROLE \
  --role candidate CANDIDATE_MANIFEST CANDIDATE_SOURCE_ROLE \
  --out selfhost/build/phase194/diagnostic-runtime-plan-fresh
```

Run the following only inside the root-owned outer CPU3/disk guard:

```sh
python3 selfhost/tests/phase194/diagnostics/runtime-loop.py \
  --catalog selfhost/tests/phase194/diagnostics/catalog-v2.json run \
  --manifest selfhost/build/phase194/diagnostic-runtime-plan-fresh/manifest.json \
  --out selfhost/build/phase194/diagnostic-runtime-fresh \
  --seconds 240 --rounds 4 --target-ms 250 --cpu 3 --guarded
```

Before timing, the runner checks both `(32,17)` and `(1024,17)` for all twelve
programs on all four roles: 96 exact full-output/success-count observations.
It then runs the unchanged Phase185 calibration/serial-rotation engine on the
twelve timing points. Four rounds are the default; only multiples of four are
accepted, giving every role every position per program. Per-role calibration
targets 200–300 milliseconds, all pilots are retained and excluded from ratios,
and samples below 100 milliseconds refuse an admitted ratio. The complete
correctness-plus-timing campaign shares one deadline.

`report.json` records both-point correctness and the timing receipt;
`timing/report.json` contains pilots, calibrated counts, ordered samples and
the original summaries. `summary.md` lists per-program C/QBE/baseline/candidate
milliseconds, candidate/baseline ratio, and a max/min >1.10 range flag.
Incomplete or low-resolution timings do not get an admitted ratio.
The range flag is descriptive, not a confidence interval.

Every receipt is marked diagnostic-only and outside native45. Work differences
and finite limits from README remain applicable. In particular, the pressure
recurrence has the same checksum at the two sizes, mixed F32 adds conversion
work, and branchless predicates evaluate both alternatives. Neither source
spelling nor an equal checksum proves that expected machine operations survive.

At handoff, Python syntax, import/help, catalog identity and mathematical oracle
checks pass. No runtime target, compiler, or timing job was run by this author.
