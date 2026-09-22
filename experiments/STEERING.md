# Current compiler experiment strategy

Evidence cutoff: 2026-09-22, 18:41 UTC, after both final private gates and
bounded residual profiles.
Next review: after the idle-host frontend scheduling comparison.
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
  cost on tested subsets. Its initial whole-source failure (`F is not defined`)
  exposed an invalid lexical capture; the correction and counterexample are
  retained. Both corrected default and combined profile now emit exact H twice.
  Control/profile means are 805.634→787.260 seconds, 2.28% less wall; individual
  pairs improve 3.91% and 0.75%, with visible drift and 3.16% higher mean
  maximum-child RSS. This is a modest additional profile gain.
- The final private frontend independently preserves all 2,756 raw results and
  verdicts. Canonical named-profile packaging must reproduce exact image bytes
  and pass its guards; the default remains unchanged.
- The corrected Boolean/stability four-way comparison passes all 48 observations.
  Core median request time is 26.902→23.855 seconds, 11.3% less. Final successful
  small private requests take 35.0%/36.9% less time than public H, but remain
  5.14×/8.05× the pinned TypeScript request time. Do not extrapolate either result
  to full-source wall time.
- Native parallel annotation is rejected: two-worker component wall is 11.5%
  worse in both orders, despite exact annotation trees. Propagated task-mode
  eligibility is a concrete suspicion, not a causal result.

## Ranked next decisions

| Rank | Route | Cheapest useful test | Stop or promotion criterion |
| --- | --- | --- | --- |
| 1 | Shorten full frontend validation through scheduling | Complete four-core run, idle serial bracket and reverse four-core if useful | Exact all-observation/history audit; record wall and aggregate live RSS |
| 2 | Expose the proven private profile as opt-in | Reproduce both exact images through canonical package after timed scheduling | Default61e7/profile4318, package and refusal tests, unchanged public ABI |
| 3 | Quantify typed-worker/matcher family | Bounded counters on actual final private core; exact output required | Stop if safe attribution fails or selected family is too rare; counts are not time |
| 4 | Preserve reproducible experimental starting points | Finish bounded profile and complete gate archives | Hash actual artifacts, retain failed attempts, document scope and restoration |
| 5 | Typed workers spanning matches | Follow the new lowering design only after rank3 | Demand/error order, capture, partial/overapplication and deep-stack controls before timing |
| 6 | Constructor continuation or typed emission facts | Prove one dependency/demand boundary and count actual repeated work | Multi-day architectural work; no broad migration during final gate window |

The four-core scheduling interval reserves all physical cores; other agents may
prepare documentation and small metadata audits but must defer compiler work.
Do not add percentage gains from overlapping transformations, and do not equate
profile samples with an achievable whole-compiler speedup.

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

Root owns strategy, evidence archives, documentation, commits and pushes.
Direct-calls agent owns the exclusively scheduled frontend comparison.
Compact-index independently audits final gates and integrates the named profile
after the timed interval. Lexer-analysis archives the negative annotation result
and prepares bounded matcher-family counters. All 59 production modules and the
checked source remain frozen. Timing still has shared cache/memory and operating
system effects; "no competing compiler experiment" is not OS isolation.

Do not mutate source or a tool consumed by a running experiment. Preserve frozen
controls and invalid attempts. Read the [ledger](ledger.md) before assigning the
next wave; append a new frontier after a decisive result.
