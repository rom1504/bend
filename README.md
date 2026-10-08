# Bend compiler progress

A visual GitHub Pages report on the self hosted Bend compiler, maintained in an independent website repository. It contains five metric sections in this order: compiled program speed, second stage compiler compilation speed, first stage compiler compilation speed, conformance, and simplicity. Each speed section leads with an average relative to TypeScript, its evolution by dated compiler commit, and a program breakdown. The page also keeps 31 illustrated current and historical findings that readers can filter by metric. Every chart has recorded measurements and source links; SVG and PNG artifacts are available for download.

The saved measurements reach **installed Phase 66 final07**, compiler commit and immutable report snapshot [`2035010d`](https://github.com/rom1504/bend/commit/2035010d3d7045bbd0364c141e1da0007476cbc1), and include earlier milestones discussed in [PR #1207](https://github.com/bendlang/bend/pull/1207). The current TypeScript reference is [`0592662`](https://github.com/bendlang/bend/commit/059266225b77c8ca256ac6b25ee5c21449bab151); older measurements retain their original pins. This is a recorded snapshot from October 8, 2026, not an automatic view of the active compiler checkout.

The installed compiler is the validated **profile7 derivative of checked B1**. It emits a genuine direct JavaScript compiler, **B2**, which is measured and qualified separately and has not replaced the installed B1 API. B2 freshly checks its own source and emits **B3**, whose bytes exactly match B2. The program-speed metric times independently executed B1-generated benchmark programs; exact B1/B2 byte equality covers all 23 modules and 45 observed points.

The website uses static HTML, CSS and a small script for finding filters. Normal text updates, site builds and validation use only the Python standard library; no packages or API keys are needed. Regenerating chart images separately requires Matplotlib.

## Update and preview

Run these commands from this website repository:

```sh
python3 scripts/build.py
python3 scripts/build.py --check
python3 -m http.server 8000 --bind 127.0.0.1 --directory site
```

Open <http://127.0.0.1:8000>. Stop the preview with Ctrl+C.

- Edit `progress.json` for editorial content: metadata, metric-card summaries, the 31 findings and their evidence links. Keep claims tied to recorded measurements and retain their scope.
- Edit `templates/index.html` for page structure and `site/styles.css` for appearance.
- Run `python3 scripts/build.py` after changes, then commit the source files and generated `site/` files together.
- Run `python3 scripts/build.py --check` before committing. It validates measurement relationships, checks chart input/output hashes, and fails when generated pages need rebuilding. This check does not import Matplotlib.

`site/index.html` and `site/progress.json` are generated. The latter contains the complete editorial configuration and research dataset. Use source files for edits. Site assets use relative URLs so the website also works at a GitHub Pages repository path.

## Update measurements and charts

The six research files retain graph-ready values, measurement boundaries, commits and source URLs:

- `history-research.json`: source-size history, paired compiler-checking results, separate Phase 36 compilation costs, and earlier findings.
- `conformance-research.json`: exact frontend comparisons, suite/target changes, and current validation scope.
- `runtime-research.json`: historical paired execution gains, the Phase 36 comparison, and findings.
- `runtime-average-research.json`: the fixed 45-case runtime average history through Phase 66, all individual timings, and 23 source-program groups.
- `compilation-average-research.json`: B1 compilation histories for changing program cohorts, through the current 23-source sample, with separate checking, request-only and import-inclusive clocks.
- `second-stage-research.json`: B2 compilation history through the current 23-source comparison, separate compilation-only and import-inclusive clocks, historical clean self-emission measurements, qualification gates, and allocation diagnostics.

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

The chart manifest records hashes of all six research files, the renderer, the plotting requirements and every SVG/PNG artifact. Changing any of those inputs requires chart regeneration before the site build can pass—even a research-file text edit changes its hash. Do not hand-edit generated chart files or the manifest to bypass verification. Editorial changes confined to `progress.json`, the template or CSS do not require chart regeneration.

For chart verification alone, run `python3 scripts/charts.py --check`; it also uses only the standard library. The committed artifacts let GitHub Actions validate and publish without installing plotting packages.

## Average and history definitions

The headline runtime figure is **1.05× TypeScript execution time** (unrounded: 1.049281626×): the geometric mean of 45 per-case median-time ratios across 23 program source files. Every case has equal weight; equal-source weighting gives 1.046986711×. The full per-case table remains available. Fifteen cases beat TypeScript. The latest campaign passes all 669 samples; the paired P65 → P66 execution change is +0.03765%, effectively flat. Mandelbrot and raytrace retain the largest source-level gaps. Five role/case pairs keep their drift or spread flags in the evidence.

The headline **B2 compilation figure is 1.32× TypeScript time**, and the **B1 figure is 1.40×**. Both now measure **compilation alone**: the first ordinary check plus library-emission request, after imports and API loading. A prominent secondary figure includes imports and API loading: **B2 0.990389×; B1 0.982634×**. Each matrix equally weights 23 sources, using the median of three rotated fresh processes per role and source: 207 exact-output workers. Standard-library caches are prepared first. Process launch, cache preparation, provenance and output validation are outside both clocks. These are fresh-process observations, not end-to-end CLI, cold-filesystem or steady-state measurements.

The latest paired P65 → P66 compilation changes are **B2 −0.230% and B1 +0.530%**, effectively flat. The TypeScript reference changes at P66, so the current values are not directly comparable with the previous reference’s headline. Both the old and new Bend compilers are freshly timed against the new TypeScript reference in the current campaign. The website’s former P58 two-program headline included imports and API loading; current primary headlines also change the clock and expand to 23 programs. Charts visibly separate these boundaries.

The compiler histories now retain the broad P60 survey and the optimization releases at P61, P63, P64 and P65. Their separately controlled B2 compilation reductions are **45.71%, 20.55%, 12.47% and 9.03%**, respectively. These are individual campaign comparisons, not quantities to multiply into a single measured speedup. P59, P60 and P62 are measurement or diagnostic phases; their labels do not invent new compiler releases. Each point retains the measured compiler identity, acquisition phase, cohort, reference and clock.

The historical **P58 clean B2 own-source emission** observations remain **223.475 → 36.058 seconds**, a descriptive **6.20×** speedup. They use each release’s changed source and an earlier retained campaign control under the same method. P66 freshly passes own-source checking and exact B2/B3 reproduction, but no new comparable clean-emission timing is claimed. Historical P58 qualification times of 11.712 seconds for source checking and 39.199 seconds for reproduction remain tied to P58; neither substitutes for its clean emission benchmark. Historical allocation observations retain their sampled cumulative scope, separate from retained memory or peak RSS.

Earlier B1 compilation results keep their original scopes. The P48 legacy-JavaScript sample is 9.86× TypeScript request time, averaging two fixed sources with host import excluded. P42–45 four-program and P47 three-program averages remain visible, disconnected at workload changes. The P56–58 two-program observations include import and API loading. The current broad first-request compilation and import-inclusive figures have separate clocks. Changed workloads and timing boundaries cannot be read as one continuous throughput trend.

The compilation history also preserves all 15 **P8–24 compiler-source checking observations: 205.26s → 11.16s, or 73.20× → 2.99× TypeScript process time**, as unconnected points on a labeled logarithmic scale. Compiler sources evolve across releases, and the reference pin changes at P23. These observations exclude code emission. P9 and P16 callouts retain independently measured same-source reductions of 67.9% and 59.6%, with their original reference pins and paired release comparisons.

The runtime history keeps the same 45 cases, with visible breaks at the P41 timing change, P52 JavaScript interface change and P66 TypeScript reference change. P52 direct JavaScript was opt-in; P53 made it the default. P40 reuses 42 unchanged comparisons plus three fresh cases. P58 freshly measures all 45 cases for both its P56 control and selected release. P59–65 contain no new complete runtime campaign; the latest graph adds a P65 control freshly measured in P66, then selected P66. Compiler dates and acquisition phases remain distinct. Historical campaign values are descriptive; optimization claims use the fresh paired baseline from their report.

The current conformance headline is **1,045 distinct golden passes across 1,170 JavaScript-eligible fixtures**, versus TypeScript’s 1,044. It combines **991 fresh Node passes** with **54 Bun passes** reused only after proving identical emitted modules and runtime. The remaining inventory is **123 unprintable-main exemptions, one shared Process.run failure and one graphics deferral**. Every observed TypeScript-passing fixture passes Bend; these finite results do not mean every fixture, backend or proof obligation is complete.

The updated frontend inventory contains 1,587 fixtures and **3,174 exact parse/check observations**, including negative diagnostics. An executable dependency audit and fresh strict36 validation transfer these observations to final07; they were not all re-executed on that final image. Current B1 and B2 separately pass source96, numeric34, composition18 and overapplication2 controls. These overlapping suites are not summed with the broad census. B2’s source check and byte-identical reproduction are recorded self-hosting gates; its 3,282 unsafe definitions retain their expected proof-trust refusal. Native, GPU and mathematical-proof claims remain separate.

Simplicity history reaches **28,490 physical / 23,353 code Bend lines in 115 modules**. P66 adds 94 physical lines (+0.331%), 69 code lines and 13 definitions over P65. The current census has 3,282 definitions, 642 laws and 119 types. The maintained Bend module boundary excludes host/runtime support, generated artifacts and tests. Code-line counts exclude whole-line comments and blanks and stay separate from earlier nonblank counts. Source growth and additional preparation mechanisms remain visible alongside their measured speed benefits.

Build validation recalculates headline averages, verifies the 45-case runtime partition, checks compilation cohorts and averages, and validates historical checking ratios, paired reductions and conformance denominators. Nine dashboard figures retain earlier milestones and show the current measurements; three older chart pairs remain as historical artifacts, for **12 SVG/PNG pairs** in total.

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
