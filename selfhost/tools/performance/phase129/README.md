# Phase129 research/profile reproduction

Run from the repository root. The selected compiler and generated programs are
unchanged. All target executions use one guarded CPU 3 lane; all output oracles
come from qualified Phase128 receipts, not newly learned output.

```sh
python3 -B selfhost/tools/performance/phase129/prepare-profile.py \
  --out selfhost/build/phase129/profile-fresh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase129/profile-fresh-guard --seconds 240 \
  --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase113/run-jobs.py \
  --plan selfhost/build/phase129/profile-fresh/jobs.json \
  --out selfhost/build/phase113/p129-profile-fresh
```

`prepare-profile.py` uses the frozen three-source native timing receipt and
budgets 8ms/13ms repeats separately. Actual generic profiler quality gates remain
unchanged. Use fresh output paths, then `profiler/compare.py` with the three
resulting reports. The retained run is `selfhost/build/phase129/profile01`.

`prepare-context.py prepare --out FRESH` writes a reversible runtime relink plan
and authenticated owner map. Run generic `profiler/build-runtime.py` under the
same guard, storing its report at `FRESH/build/report.json`, then call
`prepare-context.py seal --out FRESH`. It creates `FRESH/jobs.json` for the same
guarded serial runner. This adapter intentionally uses the retained `profile01`
manifest as its frozen workload definition. No whole compiler is rebuilt.

For the completed experiment:

```sh
python3 -B selfhost/tools/performance/phase129/summarize-context.py \
  --capture selfhost/build/phase129/context02 \
  --out selfhost/build/phase129/context-summary-fresh
```

The report generator binds the exact archived campaign paths, including the
generic combined comparison at `complete-comparison01.json`:

```sh
python3 -B selfhost/tools/performance/phase129/report.py --out /tmp/p129-report.json
```

It never executes a target. See the [implementation report](../../../../implementation/phase129/README.md)
and [profiler guide](../../../../docs/self_hosted/PROFILING.md) for interpretation.
Archived absolute paths record original provenance; relocated runs require
fresh path-bound manifests. Keep original qualified objects and compiler images.
