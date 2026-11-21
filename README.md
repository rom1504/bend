# Bend compiler progress

The static report follows program runtime, second-stage and first-stage compilation, conformance and maintained source size. Its November 21 snapshot covers [Phase 203](https://github.com/rom1504/bend/blob/2dec06c6138c2597e1843f5c14a5c4c614bf9924/implementation/phase203/README.md).

The upstream version changed to Bend 2.0.40 in Phase 182. JS and C upstream timings keep their historical pins. The x86 target compares generated programs with mature self-hosted C. Full cold builds include linking, and each trial names its source and producer. Phase 200 supplies the latest complete x86 runtime suite. Phase 203 supplies the latest measured x86 self-build. Finite qualification and research observations are identified separately.

## Update and preview

Normal builds use the Python standard library. Regenerating charts additionally requires Matplotlib. All builds read saved website data, never the compiler checkout.

```sh
python3 scripts/charts.py
python3 scripts/build.py
python3 scripts/build.py --check
python3 -m http.server 8000 --bind 127.0.0.1 --directory site
```

Edit the source data and templates; commit them together with generated HTML, JSON, SVG and PNG files. `scripts/build.py --check` verifies measurement relationships, chart provenance hashes and generated-page freshness without importing Matplotlib. `scripts/charts.py --check` checks chart inputs and artifacts. Source edits to chart data require regeneration, even if only a note changed. Never bypass verification by hand-editing the manifest.

## Source files

- `progress.json`: snapshot metadata, retained JavaScript card descriptions and earlier findings.
- `recent-findings.json`: current and earlier mechanism/impact stories and the separate Phase104 research outlook.
- `targets-research.json`: pinned backend campaigns, all 45 x86 cases, historical QBE comparisons, cold-build pairs and experiment figures.
- `native-research.json`: native runtime, historical paired B1/B2 changes, Phase105 upstream process-time comparisons, 45-point/23-source breakdowns, separate full-source measurements and the Phase104 audit/screen.
- `applications-research.json`: three application cards, six current full-process comparisons, actual preview provenance and historical scaling.
- `history-research.json`: canonical source-size history, separate assembled profiles and earlier paired compiler-checking results.
- `conformance-research.json`: frontend history, distinct native/CLI/proof scopes and historical JavaScript census.
- `runtime-average-research.json`: complete 45-case JavaScript timing history and current evidence-reuse boundary.
- `compilation-average-research.json` and `second-stage-research.json`: historical and Phase91 JavaScript-hosted compilation campaigns, with cohort, clock and reference boundaries.
- `runtime-research.json`: earlier paired program-execution improvements.
- `scripts/build.py` and `scripts/native_report.py`: validation and static report rendering.
- `scripts/charts.py` and `scripts/native_charts.py`: reproducible scientific plotting and chart hashes.
- `templates/index.html`, `site/styles.css`, `site/app.js`: presentation and progressive enhancement.

`site/index.html` and `site/progress.json` are generated. The latter exports the complete source configuration and research datasets. All relative asset links work beneath the GitHub Pages repository path. The real rendered application PNG is copied from committed compiler evidence; the planner SVG illustrates a checked sample fixture.

## History rules

Preserve earlier numerical rows and source identities. New native cohorts do not replace JavaScript history. Different sources, clock boundaries, references and target backends require separate graph segments or panels. Independent paired gains are not multiplied into a synthetic current comparison. Missing timings are not zeroes. Retained exact-output evidence is labeled as reuse, not fresh execution.

The historical compiler-source checking drop (205.26 s to 11.16 s), paired early reductions, Phase58 clean B2 self-emission (223.475 s to 36.058 s), and later broad JavaScript optimization campaigns remain available. Their changing source/cohort boundaries are kept explicit. Native request improvements, full compiler-source emission and C-toolchain construction remain separate workloads. Application process results include startup and IO and are not averaged into the warmed 44-point runtime metric.

## Publish on GitHub Pages

The website is published at <https://rom1504.github.io/bend/> from the dedicated [`progress-site` branch](https://github.com/rom1504/bend/tree/progress-site) of `rom1504/bend`. This branch contains only the website sources and generated artifacts, with independent history from the compiler branches.

GitHub Pages uses **GitHub Actions** as its publishing source. The `.github/workflows/pages.yml` workflow validates every push and pull request targeting `progress-site`; successful pushes upload `site/` and deploy it. The `github-pages` environment permits deployment from `progress-site` only.

For subsequent updates, work from the independent `/home/ai/bend-progress` checkout:

```sh
python3 scripts/build.py
python3 scripts/build.py --check
git add .
git commit -m "Update compiler progress report"
git push origin progress-site
```

Regenerate charts first when their inputs change, as described above. The workflow deploys the checked-in artifacts without running compiler builds or benchmarks. Watch [deployment runs](https://github.com/rom1504/bend/actions?query=branch%3Aprogress-site) for the result.

The setup follows GitHub's [custom Pages workflow guide](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages).

## Keep compiler work independent

Use committed compiler changes and existing CI results as sources for progress updates. Record the commit, date, and evidence behind a reported result. Update this website repository without editing the active compiler checkout or requesting extra work from its agent.

The build reads only this website's saved data. There is no automatic compiler checkout, benchmark run, test run or live metrics fetch in this workflow. New compiler work appears on the website only after its recorded evidence is incorporated here.
