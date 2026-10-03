# Phase41 final admission review

## Verdict

I recommend admitting the frozen tree wrapper to the release candidate, with
the compiler-cost shift disclosed as a tradeoff and postinstall still required
before any release-complete claim. Generated-program results support the
campaign's primary objective: the three tree workloads improve by about
33.6–37.2% in the five-round final runtime comparison, with the reviewed report
showing complete balanced samples. `local-pair` is effectively unchanged;
`scalar-region-8192` and `coverage-numeric-recurrence-1024` move about +2.14%
and +0.70%, respectively. The reviewed source report says the wrapper changes
only three selected modules; the other 42 remain byte-identical.

Compiler request cost is a real tradeoff, not a compiler-speed claim. For
`tree-bitonic`, its median rises from 2,248.000 ms to 2,460.593 ms (+9.46%,
about 212.6 ms). The three-sample ranges overlap narrowly (baseline
2,230.315–2,424.281 ms; candidate 2,389.673–2,606.845 ms), so this is an
adverse median shift without a cleanly separated range. The other three
compiler-cost cases show no clear regression. I would record the tree result as
a cost risk and prioritize planner cost in follow-up work. If the campaign
policy treats this median shift as a confirmed regression, its stated rule
requires rejection or a corrective experiment; accepting it then needs an
explicit, documented exception tied to the substantially better generated
runtime. It should not be silently called neutral.

## Evidence state

The selected-image preinstall audit reports 14/14 gates passed, including
frontend exact agreement, owners, canonical source and expanded/backend
observations. The compiler-cost job completed and passed its receipt checks.
`final-runtime01` now has a complete passing receipt. I reviewed those
artifacts read-only; I ran no jobs.

The independent tree-source review is against patch SHA256
`5288a7c12a6a35e719ba914afcbd9ef3faca268902b1209ebdadc0241911acb2` and found
no planner, stack or transitive-closure blocker. The saved-output and actual
controls are also root-reported as passing, separate from this source review.

Postinstall installation, installed verification and the 42 ordinary and
relocated CLI checks are still pending in the evidence I reviewed. Keep the
final release status open until their successful receipt is recorded.
