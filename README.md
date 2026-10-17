# Bend compiler progress

A visual GitHub Pages report maintained in an independent website checkout. The five metric sections retain this order: compiled program speed, second stage compiler compilation speed, first stage compiler compilation speed, conformance, simplicity. Native results lead; expandable JavaScript reports preserve the earlier graphs, all measurements and their boundaries. Three application previews and six recent findings explain the practical gains; 31 earlier findings remain in an expandable archive.

The snapshot reaches **Phase 104**, committed evidence [`8d6f9b4`](https://github.com/rom1504/bend/commit/8d6f9b495ad7e4de72c63bc104a16ec90cbc3b71), collected October 17, 2026. The current native core is **Phase 102 candidate04**; Phase 103 adds its public Bend CLI. Phase 104 authenticates the native lineage and adds 16 requests on two development cases, with no compiler promotion or broad performance rerun. The upstream compiler reference remains `059266225b77c8ca256ac6b25ee5c21449bab151`.

## Current measurement boundaries

- Native generated-program time: **1.043461× upstream-generated C**, geometric mean across 44 positive-work points. Equal-source weighting gives **1.065286×**. The paired current/Phase98 ratio is **0.936547×**. One zero-work control has no timing ratio.
- Native B2 compilation: **0.724500× Phase98 request time**; complete-process ratio **0.689040×**. Native B1: **1.026011× request** and **1.026269× process**. Six sources, four balanced rounds. These do not establish a current native-versus-upstream compiler average.
- JavaScript-hosted Phase91: B2 **1.306596×**, B1 **1.408445×** upstream request time over 23 sources; import/API-inclusive **0.981387× / 0.969726×**. The separate C3 output cohort is still a JavaScript-hosted compiler. JavaScript program runtime **1.049×** retains earlier timing through output-identity evidence.
- Native conformance: 69 eligible fixtures and 3 expected rejections per stage, 31 exclusions, 45 native semantic catalog points, 70 backend obligations. CLI controls: 41/41 and 6/6 complete C/verdict pairs. JS frontend: 3,173/3,174 exact; an invalid proof is rejected with shortened B2 diagnostics after deep rendering overflows the JS stack. Historical JS execution retains 1,045 passes and its original exemptions/failures/deferral.
- Canonical source: **34,231 physical lines / 134 modules**. Assembled native core **39,372**, public CLI compiler **39,545**: a separate counting boundary. Public CLI policy is 152 Bend lines; OS provider 246 C lines; startup 19 C lines.

Native B1/B2 emit identical complete self-C. B3 C exists but its executable was not built; there is no B3 timing. Historical C emission and Clang construction remain separate clocks. The public Phase103 bridge and CLI entries differ, so its packaging is not a new matched-source fixed-point claim. Ordinary native requests need no interpreter, while build and development tools retain their dependencies.

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
- `recent-findings.json`: six current mechanism/impact stories and the separate Phase104 research outlook.
- `native-research.json`: native runtime, B1/B2 request/process comparisons, scoped histories, self-emission observations and Phase104 audit/screen.
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
