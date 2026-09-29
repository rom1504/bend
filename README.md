# Bend-in-Bend compiler: PR #1207 research report

**Agent-generated technical report — Codex.** Prepared for [bendlang/bend#1207](https://github.com/bendlang/bend/pull/1207), following human review of the draft and authorization to publish. The compiler and source evidence are pinned to [`5350b2f`](https://github.com/rom1504/bend/commit/5350b2fec8f6f8484c7a689e915b359d7ce86847); this separate branch hosts the report, diagrams and reproducible chart data.

- [Technical report](report.md)
- [Historical metrics](figures/historical-metrics.png), [PDF](figures/historical-metrics.pdf), [SVG](figures/historical-metrics.svg)
- [Paired gains and tradeoffs](figures/paired-gains-and-tradeoffs.png)
- [Main findings diagram](figures/main-findings.png)
- Individual charts: [checking](figures/checking-history.png), [conformance](figures/conformance-history.png), [source size](figures/complexity-history.png)
- Source-linked tables: [checking CSV](checking-history.csv), [conformance CSV](conformance-history.csv), [complexity CSV](complexity-history.csv)
- [Chart data](chart-data.json), [data preparation](prepare_data.py), [plotting script](render_charts.py)

The research JSON files retain the historical extraction as prepared during review, including their original draft metadata. They contain 15 speed milestones, 13 main conformance milestones, and 49 source checkpoints with 27 selected complexity milestones. Charts use a readable subset. All measurements are retrospective evidence; preparing this report did not rerun the compiler benchmarks.

## Reproduce the figures

Requires Python 3, NumPy and Matplotlib:

```sh
python3 prepare_data.py
MPLCONFIGDIR=/tmp/bend-pr1207-mpl python3 render_charts.py
```

To recount canonical compiler Bend modules from a clone containing the historical commits:

```sh
python3 research/complexity-census.py /path/to/bend-fork /tmp/source-history.json 5350b2fec8f6f8484c7a689e915b359d7ce86847
```

Each speed observation has its own paired baseline and frozen input. The earlier self-emitted compiler/full-emission timings are distinct from later checking-only measurements. Exact frontend agreement is finite tested coverage, not universal language or backend conformance. Canonical source counts exclude host/runtime, generated files, tests and archives. See the report for full boundaries and limitations.
