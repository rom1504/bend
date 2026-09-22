# Current compiler experiment strategy

Evidence cutoff: 2026-09-22, after the independently reviewed lexical-scope fix.
Next review: after the corrected full-source gate or fixed-base four-way matrix.
Authorized work window ends approximately 20:16 UTC; reserve the final 15 minutes
for evidence review, documentation, commits and push.

## User objective

Make the compiler written in Bend much faster, produce efficient code, and make
correct validation iterations much faster. Preserve correctness. The user also
requested the experiment-file methodology inspired by `rom1504/math`.
The routes below are investigator choices, not additional user requirements.

## Established position

- The normal checked B1 rebuild plus the first paired 21-case command takes
  37.217 seconds of child-process wall. Reused validation takes 9.328 seconds
  median. This is the preferred focused edit loop.
- Combined source passed checked self-reproduction; full H self-emission took
  1,591.343 seconds. Pinned TypeScript compiles the identical source/root policy
  in 51.443 seconds process-wall median. They were separate runs on different
  physical cores; the roughly 30.9× gap is descriptive, not a controlled causal
  comparison of optimization versions.
- All 2,756 frontend observations remain unchanged. There are still 560 exact
  differences from upstream. Preservation does not establish full conformance.
- Native O2 same-source alternating comparisons have medians 284.807→245.364
  seconds for old/new compiler; all emitted libraries equal the new H. There is
  visible control drift, retained in the report.
- The explicit private compiler boundary removes substantial generic dispatch
  cost on tested subsets. Its first whole-source attempt FAILED in emission:
  hoisted workers lost block-local helper table `F`. P4-016's correction passed
  25 package tests, 14 actual-worker controls and the escaped-string byte check.
  Its full-source rerun is pending; no successful private full-source time yet.

## Ranked next decisions

| Rank | Route | Cheapest useful test | Stop or promotion criterion |
| --- | --- | --- | --- |
| 1 | Complete corrected private full-source gate | Cheap scope gates have passed; bounded full request is running | Exact full H bytes and resource evidence required |
| 2 | Combine exact Boolean matchers and pure stability facts | Three-round real-core four-way comparison, exact controls, RSS | Advance only for a repeatable whole-workload gain; require broad frontend and full-source gates before support |
| 3 | Final small B1/H/private/TypeScript matrix | Frozen final identities, alternating fresh workers | Separate successful emission from exact rejection and startup |
| 4 | Make the fastest validated workflow convenient | Run genuine focused CLI on the chosen artifact | Preserve all verdicts/diagnostics, reuse bounds and fresh source/import behavior |
| 5 | Reduce remaining generated matcher dispatch | Exact Con/arity2 pilot has now failed its material-benefit threshold | Retain P4-015 rejection; require a stronger mechanism before reopening |
| 6 | Broader term-layout or typed intermediate representation | Quantify residual allocation/dispatch after current specialization | Do not start a migration on operation counts alone; require a boundary and an isolated material result |

Ranks 1–4 are integration/measurement work, not new algorithmic hypotheses.
Ranks 5–6 are alternatives if evidence and remaining time justify them.
We cannot obtain another order of magnitude by adding the percentage gains of
overlapping micro-optimizations.

## Known obstructions

- Public function objects, getters, rebinding and argument arrays are observable.
  Private-image assumptions cannot be exported to the ordinary library ABI.
- The first telescope prototype changed error order; its correction must remain.
  Substitution stability is weaker than normalization stability.
- Weak-head pair memoization regressed core time by 4.4% and memory by 2.9%.
  High hit counts are not a sufficient reason to retry it.
- Direct private tag comparisons did not improve the real core. Nullary sharing
  gave only a small inconsistent core gain. Ordinary function uncurrying has
  zero eligible sites in the actual image.
- Full-source inspector sampling failed after 30 minutes. Use bounded small
  profiles and counters; keep full-source builds as integration gates.

## Assignment and resource state

Root owns strategy, integration, ledger, commits and pushes. Direct-calls agent
finishes its frozen four-way comparison, then owns the private scope fix.
Compact-index agent independently reviews the fix; lexer-analysis archives the
rejected Con-arm pilot and its preservation audit. Root reduces the actual
emission failure on CPU2. Coordinate other timed work; shared cache/memory
interference remains possible even on different cores.

Do not mutate source or a tool consumed by a running experiment. Preserve frozen
controls and invalid attempts. Read the [ledger](ledger.md) before assigning the
next wave; append a new frontier after a decisive result.
