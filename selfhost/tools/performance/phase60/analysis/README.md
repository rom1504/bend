# Broad diagnostic classification

`summarize-v2.py` reads completed Phase60 campaign receipts. It imports no compiler
and executes no target. Run data processing on CPU0 after root opens an analysis
window; never compete with clean measurement. The input population is the exact
catalog's 23 compilation inputs, retaining their 45 inherited runtime oracles.
The source/module byte counts are recorded data, not additional compilation.

```sh
taskset -c 0 python3 selfhost/tools/performance/phase60/analysis/summarize-v2.py \
  --catalog selfhost/tools/performance/phase60/catalog.json \
  --report "$STAGES_REPORT" --report "$CPU_REPORT" --report "$ALLOCATION_REPORT" \
  --out selfhost/build/phase60/diagnostic-analysis02
```

Output must be fresh and inside Phase60. Reports can be supplied separately for
an interim readback, with their exact modes/coverage retained. Each campaign must
have one observation for every source/role. Failed or skipped observations remain
in the output and prevent a full pass; they are never replaced by successful
observations from another process. All consumed identities are rehashed before
writing. Clean three-round statistics belong to `../analysis-clean.py`.

## Partition policies

- **Stage wall clocks:** reuse Phase59's exclusive parent/child accounting.
  Cache validation and Base span walking contribute once to cache/identity;
  new-source span walking belongs to source loading. TS `js_lib` is a coarse
  interval compared with B2's combined reach/planning/library work. Checking
  includes B2 specialization/completion. One observation is a diagnostic screen,
  not an estimate of variation or a precise ranking of close cases.
- **CPU:** every original sample contributes one unit. The reviewed Phase57
  `cpu_views` function independently verifies the retained signed timestamp
  policy and count summary. A refused weighted view remains refused; population
  comparisons use counts consistently, never a mixture of counts and time.
- **Allocation:** every recorded sample contributes its size exactly once.
  Values estimate cumulative allocation including collected objects, not peak
  memory, exact object counts or time savings.
- **Stage ancestry:** the nearest exact API URL/function boundary wins.
  Anonymous frames or shared SCC labels alone do not establish a stage. Missing
  ancestry stays unassigned. TypeScript `file_book` is a separate source-specific
  bin, not an asserted equivalent of Bend emitted reach.
- **Frame-name families:** actual B2 self frames are grouped by explicit name
  prefixes for String, emitted references, indexes, substitution and primitive
  metadata. A shared SCC leader identifies a named worker, not every source
  member or a unique source operation. These shares complement ancestry; the two
  views overlap and must not be added. Raw names/locations and other/GC mass are
  retained. Absence from one sampled profile is not proof of absence of work.

Subset selection follows the measurements. It will combine distinct observed
families, an opposite/negative case, and held-out checks; it will not select only
the largest two costs or treat 45 runtime points as 45 independent compilations.
20/60-second plans must include measured worker/preflight costs and explicitly
state rounds, role order, cache preparation and deadline margin. Existing image
bindings remain honest: a future compiler candidate needs its own qualified
image/preparation, rather than relabelling these unchanged-image observations.

The original reader and `diagnostic-analysis01` failure are retained unchanged.
V2 preserves allocation samples missing from the V8 tree in total/unattributed
bins; one TS local-fold sample contributes 138,000 such bytes. This data-reader
failure was not a target failure. See `summarize-v2.derivation.json`.
