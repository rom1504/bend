# Final evidence tools

`seal.py` is a narrow Phase125 sealer adaptation. It retains the8MiB member and
64MiB payload bounds, deterministic tar/gzip metadata, exact ordered member
inventory and byte-digest replay. Roots include Phase126 tools/build/docs,
Phase118/111/113/112 `p126-*` outputs and Phase111 `p118-p126-*`, including failed
attempts. Small notes, diffs, bounded machine disassembly, original controls and
one-hop pinned recipe inputs are included. Prior evidence directories are not
embedded recursively. Full compiler/API source, SSA, whole assembly and
ELF/object files stay external with their existing pins; unpinned omitted files
receive streaming identities at final sealing time. Replay verifies archived
bytes, not external products or experiment success. No seal has been run during
tool preparation.

After all campaign reports and outputs are frozen, root may run:

```sh
python3 -B selfhost/tools/performance/phase126/seal.py audit
python3 -B selfhost/tools/performance/phase126/seal.py seal \
  --out implementation/phase126/evidence
python3 -B selfhost/tools/performance/phase126/seal.py replay \
  implementation/phase126/evidence/receipts01.tar.gz
```

`summarize.py` takes repeatable `--screen REPORT` and a fresh `--out FILE`. It
authenticates small recorded stdout/stderr, requires complete/correct reports,
unchanged product identities between rounds and matching runtime arguments.
It calculates the Phase123 median/geometric ratios with explicit population
labels (`partial-original-subset`, `original44-timed-only`, `full-original45`).
Only the frozen manifest's zero-work point is excluded from ratios. Any zero
observation at a timed point refuses instead of silently shrinking the sample.

Per-case output includes all samples, minimum/median/maximum, range divided by
median, median absolute deviation, same-round ratios and their spread. Aggregate
positive-log slowdown is `mean(max(log(candidate/upstream),0))`, with strict
counts above1,1.1,2,5,10. Observed-family weighting and batch sums are reported
separately. No independent attempts are pooled. Three-case metrics are not broad
parity and descriptive spread is not a confidence interval.

The tool also accepts `compare-existing.py` reports with arbitrary variant names.
It emits a complete pairwise ratio matrix. Relative deficits name their reference
(`baseline` if present, otherwise the first declared variant); they are not
presented as upstream deficits when upstream is absent.

```sh
python3 -B selfhost/tools/performance/phase126/summarize.py \
  --screen selfhost/build/phase126/typed-screen05/report.json \
  --screen selfhost/build/phase126/local-screen06/report.json \
  --out selfhost/build/phase126/screens-summary01.json
```

At campaign completion, add `--account-guards` and optionally
`--campaign-end 2026-10-23T01:59:00+00:00` using the actual endpoint. Accounting
requires finished, nonoverlapping outer `*guard*/process.json` receipts and
includes failed guards once, without summing their child stages again. Its
default endpoint is the last finished guard, not the invocation's current time.
Guard directories without process receipts are listed but assigned no invented
duration. Editing/reasoning and billing are not metered.

`compare-existing.py` is root-only under the usual CPU3 guard. Repeated
`--variant LABEL=SCREENREPORT` selects each report's candidate binary; `--case`
accepts original45 case names. It checks exact source, verified QBE, aligned
builder, runtime and binary lineage; no builds occur. Variants rotate each round
and use the unchanged frozen complete-output/count oracle. `--rounds` and
`--scale` affect only repeated execution. Every original report is read-only.
