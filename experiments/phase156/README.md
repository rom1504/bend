# Phase156 — transfer to actual compiler requests

This is an isolated experiment, not a new compiler selection. The baseline is
commit `209f2df` and qualified Phase152 N2. All compiler algorithms under test
are Bend modules in `selfhost/tests/phase156`; the host scripts assemble exact
declaration closures, run bounded jobs and compare evidence.

See the [design](../../design/phase156/README.md),
[report](../../implementation/phase156/README.md),
[publication invariant](../../research/phase156/publication-invariant.md), and
[independent semantic review](../../research/phase156/semantic-review.md).

## Reproduce without changing the installed compiler

The retained preparation manifests contain exact source, module, tool and
qualified compiler identities. `jobs.json` beside each manifest contains the
source-check and native-build commands. Use fresh output roots and the maintained
disk/process guard; never overwrite an existing preparation, native image or
measurement. `tools/prepare.py --help` documents the bounded extraction interface.
The mechanical original-ancestor clones are not a second maintained compiler.

1. `controls-prepare02` independently checks the publication, use-set and dense
   eligibility modules and emits a hosted control API. The Phase154 model needs
   its codec as well as its lowerer. The canonical source already includes the
   native-control comparison functions; do not append them again.
2. `controls02` uses `tools/controls-v2.mjs`. Its sole failed row incorrectly
   expected the ordinary parser to admit a duplicate declaration. Keep that
   failed report. `publication/duplicate-control.mjs` separately binds the exact
   failed receipt and checks both the correct parser refusal and direct checker
   duplicate-event rejection. Complete result equality is checked, including
   world state, diagnostics and scheduling-visible data.
3. `request-prepare01` checks and builds one native executable containing the
   original and candidate routes. Its CLI selects `old`, `publication`, `uses`
   or `both`. All routes use real live Base preparation and the maintained
   planner, final verifier and complete streaming writer.
4. `tools/requests-v2.py` accepts the checked preparation, inputs and explicitly
   bound control/correction receipts. It pins source, Base, producer and exact
   oracle product. Use `--oracles` only with the pinned nested receipts and
   retained bytes, not a case-name-only join. Unknown cases and roles are refused.
5. Compare complete QBE before deciding whether a different machine build or
   generated-program timing campaign is necessary. These requests produce IR;
   they do not measure execution of the programs represented by that IR.

The first actual requests are retained as `pilot01`. The full unchanged
3,085,157-byte compiler comparisons are `full01` and reversed-order `full02`.
The same input manifest names the
retained Phase152 N2→N3 QBE receipt as an independent oracle. That historical
request used cached Base; current timed roles both prepare Base live. Only exact
output identity is reused, never the old timing.

The executed full-source command, relative to the repository root, is:

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase156/full01-guard \
  --run-root selfhost/build/phase156/full01 \
  --seconds 660 --disk-mib 256 --rss-mib 2048 \
  --available-mib 16384 --file-mib 128 --cpu 3 -- \
  python3 -B experiments/phase156/tools/requests-v2.py \
  --manifest selfhost/build/phase156/request-prepare01/manifest.json \
  --inputs selfhost/build/phase156/full-inputs01/manifest.json \
  --controls selfhost/build/phase156/controls02/report.json \
  --correction selfhost/build/phase156/duplicate01/report.json \
  --out selfhost/build/phase156/full01 \
  --roles old,publication --rounds 1 --seconds 620 --child-seconds 300
```

Use different fresh guard/run roots when replaying this command.
`full02` uses the same command with fresh `full02`/`full02-guard` roots and
`--roles publication,old`. `map02` separately repeats Map in both orders using
`--oracles .../pilot01/report.json --cases map --roles uses,old --rounds 2`.

Source and toolchain acquisition dependencies must still be available under the explicit
manifests. The experiment capsule preserves observed artifacts; it does not
claim to bundle every external toolchain installation.

## Evidence limits

The pilot has one observation per role. The full-source follow-up adds the reverse
order, for two observations per role; Map also has a two-round balanced follow-up.
These are not confidence intervals. The larger shared experimental image and its
layout are not the same executable as the qualified production compiler. Compare
roles within the same experiment, not absolute seconds across historical images.
Exact QBE preserves the downstream product under the same toolchain; it is not
a fresh generated-program speed measurement or a compiler-correctness theorem.

Keep `controls.mjs`, `requests.py`, failed source preparation and the failed
control report as frozen historical methods. Their successors fix identified
harness issues rather than retroactively relabeling failed attempts successful.

`tools/summarize.py` only reads receipts and produces the tracked metrics. No
compiler, test or benchmark executes when summarizing.
