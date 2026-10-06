# Bend compiler progress

A visual GitHub Pages report on the self hosted Bend compiler, maintained in an independent website repository. It contains four metric sections in this order: compiled-program speed, compilation speed, conformance, and simplicity. Each speed section leads with an average relative to TypeScript, its evolution by dated compiler commit, and a program breakdown. The page also keeps 18 illustrated current and historical findings that readers can filter by metric. Every chart has recorded measurements and source links; SVG and PNG artifacts are available for download.

The saved evidence reaches **installed Phase 53 ordered02**, compiler commit and immutable report snapshot [`29dbaa41`](https://github.com/rom1504/bend/commit/29dbaa41fb7988baae8355b1fba24312976d598d), and includes earlier milestones discussed in [PR #1207](https://github.com/bendlang/bend/pull/1207). This is a pinned report: it does not automatically reflect the latest compiler checkout.

The website uses static HTML, CSS and a small script for finding filters. Normal text updates, site builds and validation use only the Python standard library; no packages or API keys are needed. Regenerating chart images separately requires Matplotlib.

## Update and preview

Run these commands from this website repository:

```sh
python3 scripts/build.py
python3 scripts/build.py --check
python3 -m http.server 8000 --bind 127.0.0.1 --directory site
```

Open <http://127.0.0.1:8000>. Stop the preview with Ctrl+C.

- Edit `progress.json` for editorial content: metadata, metric-card summaries, the 18 findings and their evidence links. Keep claims tied to recorded measurements and retain their scope.
- Edit `templates/index.html` for page structure and `site/styles.css` for appearance.
- Run `python3 scripts/build.py` after changes, then commit the source files and generated `site/` files together.
- Run `python3 scripts/build.py --check` before committing. It validates measurement relationships, checks chart input/output hashes, and fails when generated pages need rebuilding. This check does not import Matplotlib.

`site/index.html` and `site/progress.json` are generated. The latter contains the complete editorial configuration and research dataset. Use source files for edits. Site assets use relative URLs so the website also works at a GitHub Pages repository path.

## Update measurements and charts

The five research files retain graph-ready values, measurement boundaries, commits and source URLs:

- `history-research.json`: source-size history, paired compiler-checking results, separate Phase 36 compilation costs, and earlier findings.
- `conformance-research.json`: exact frontend comparisons, suite/target changes, and current validation scope.
- `runtime-research.json`: historical paired execution gains, the Phase 36 comparison, and findings.
- `runtime-average-research.json`: the fixed 45-case runtime average history through Phase 53, all individual timings, and 23 source-program groups.
- `compilation-average-research.json`: compilation sample histories for four, three and two programs, latest Phase 48 legacy timings, and the explicitly unmeasured Phase 53 direct default.

Update measurements in this order:

1. Find a committed report or existing CI result. Record the exact compiler commit, reference pin, workload, timing boundary, sample count and source URL in the appropriate research file. Keep changed workloads or timing boundaries separate; preserve relevant regressions and limitations.
2. Update the summaries, findings and checkpoint metadata in `progress.json` to match that evidence. If the graph needs a different layout or series, update `scripts/charts.py`.
3. Install the plotting dependency and regenerate the SVG/PNG chart pairs:

   ```sh
   python3 -m pip install -r requirements-charts.txt
   python3 scripts/charts.py
   ```

4. Build and validate the website:

   ```sh
   python3 scripts/build.py
   python3 scripts/build.py --check
   ```

5. Preview the results and commit the edited source files, generated charts, `site/charts/manifest.json`, and generated pages together.

The chart manifest records hashes of all five research files, the renderer, the plotting requirements and every SVG/PNG artifact. Changing any of those inputs requires chart regeneration before the site build can pass—even a research-file text edit changes its hash. Do not hand-edit generated chart files or the manifest to bypass verification. Editorial changes confined to `progress.json`, the template or CSS do not require chart regeneration.

For chart verification alone, run `python3 scripts/charts.py --check`; it also uses only the standard library. The committed artifacts let GitHub Actions validate and publish without installing plotting packages.

## Average and history definitions

The headline runtime figure is **1.07× TypeScript execution time**: the geometric mean of 45 per-case median-time ratios, across 23 program source files. Every case has equal weight. Each program bar groups that source's cases; programs with more cases have more weight in the headline. The full per-case table remains available.

The headline compilation figure is **9.86× TypeScript request time**, the latest measured legacy-JavaScript sample at **Phase 48**. It averages two fixed sources (Evening and lexer), including checking and library emission, with host import outside the request boundary. The same-window P47→P48 comparison uses 3.84% more request time. The earlier P42–45 four-program and P47 three-program averages remain visible, disconnected at workload changes. These different averages cannot be read as a continuous throughput trend. **Phase 53 direct-default compilation throughput has not been measured** in a comparable published benchmark.

The compilation history figure also shows the earlier **P8–24 compiler-source checking observations: 205.26s → 11.16s, or 73.20× → 2.99× TypeScript process time**. All 15 saved observations appear as unconnected points on a labeled logarithmic scale. Compiler sources evolve across releases, and the TypeScript pin changes at P23. These observations exclude code emission and are separate from the recent four-program request average, so the two panels cannot be read as a single continuous benchmark or overall controlled speedup. The adjacent P9 and P16 callouts show independently measured same-source reductions of 67.9% and 59.6%; the expanded tables retain all observations, reference pins and paired release comparisons.

The runtime history keeps the same 45 cases through 13 recorded release checkpoints, with a labeled logarithmic ratio scale and visible breaks at the Phase 41 timing change and Phase 52 JavaScript interface change. Phase 52 direct JavaScript was opt-in; Phase 53 makes it the default. Phase 40 reuses 42 unchanged benchmark comparisons plus three fresh cases. Dates identify compiler commits, not acquisition timestamps. Historical campaign values are descriptive; paired speedups use fresh baselines from the same report. Phase 52 measures a 2.34× speedup, and Phase 53 measures 5.58% more speed (5.28% less execution time).

The current conformance headline is **96/96 independent source-oracle observations**, up from 95/96 in Phase 52, across the same 29 fixtures. Pinned TypeScript still passes 95/96 because its NaN fixture does not satisfy the unchanged source expectation. The separate full frontend history ends at its last fresh acquisition in **Phase 45: 3,026 main and 196 broader exact observations**. Current numeric, composition, overapplication, direct-backend and interface checks have separate, overlapping scopes. The 26 direct census outcomes include 18 runtime passes, four expected rejections and four not-applicable cases; they are not 26 runtime passes.

Simplicity history now reaches **26,151 physical / 21,523 code Bend lines in 103 modules**. The direct backend reduces generated JavaScript size while adding compiler source to preserve legacy compatibility. Code-line counts exclude whole-line comments and blanks; they are kept separate from earlier nonblank counts.

Build validation recalculates headline averages, verifies that source groups partition all 45 runtime cases, checks each compilation cohort and its average, and checks early checking ratios, paired reductions and semantic denominators. The six dashboard figures retain all earlier milestones and show the new measurements; three older chart pairs remain as historical artifacts.

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
