# Current compiler experiment strategy

Evidence cutoff: 2026-09-22, 19:33 UTC, after derived-B1 exact source emission
and the substitution-worker rejection.
Next review: each P4-026 full-source comparison row, then the completed comparison.
Authorized work window ends approximately 20:16 UTC. Complete other evidence and
documentation while the final comparison runs; stop it by 20:09 for final review.

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
- Four-core frontend scheduling preserves every observation and history, with
  3.47× throughput against an idle serial bracket. Canonical private packaging
  reproduces the exact default/profile images and passes 25 cases/seven guards.
- Guarded B1 equality passes 909 helper controls, twelve selected observations,
  the full frontend sweep and an exact whole-source H emission. Opposite-order
  core gains are 35.58%/35.13%. The 348.373-second full-source observation needs a
  fresh controlled comparison before making a whole-source speedup claim.
- The counted substitution family is frequent, but its narrow saturated-worker
  prototype improves the core by 7.25% then 1.99%. Reject it at the preregistered
  consistent-5% threshold despite 157 semantic controls and four exact outputs.

## Ranked next decisions

| Rank | Route | Cheapest useful test | Stop or promotion criterion |
| --- | --- | --- | --- |
| 1 | Measure whole-source B1 equality gain | Fresh control/candidate/candidate/control emissions on CPU2 | All exact H, unchanged inputs, both request/process pairs improve >5%; stop by20:09 |
| 2 | Complete durable evidence and final report | Archive latest gates and rejected worker, review links/identities | Preserve actual artifacts and failures; state experimental/default boundaries |
| 3 | Generalize equality safely in a later investigation | Define a checked-build transformation contract valid across changed sources | Exact-body/full-provenance guard, Unicode/error controls, no invented bootstrap |
| 4 | Investigate shared identifier/index costs later | Separate tag tests, name hashes and list membership counts | Count before migration; do not reintroduce rejected eager suffix indexing |
| 5 | General typed workers/constructor continuations later | Explain why a broader lowering overcomes the P4-025 null before implementation | Demand/error/deep-stack controls, real-core threshold, then broad gates |

P4-026 is the final timed experiment. Its plan was committed before execution,
with an absolute deadline that leaves time to preserve incomplete results if
necessary. All other compiler execution is stopped while it runs. The P4-024
single full-source correctness observation is excluded from its paired samples.
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
Direct-calls agent archives the derived full-source correctness gate.
Compact-index prepares the final B1 full-source comparator. Lexer-analysis
archives the rejected substitution-worker experiment. Root owns the final
comparison on CPU2 and final documentation. All 59 production modules and the
checked source remain frozen. Timing still has shared cache/memory and operating
system effects; "no competing compiler experiment" is not OS isolation.

Do not mutate source or a tool consumed by a running experiment. Preserve frozen
controls and invalid attempts. Read the [ledger](ledger.md) before assigning the
next wave; append a new frontier after a decisive result.
