# P48-002: Scalar values across private calls

Status: **deferred** after independent semantics, executed-constructor witnesses
and weak/adverse timing screens. Neither physical convention is selected.

Hypothesis: Eliminate executed nonescaping state tuples crossing private calls while preserving demanded fields and shared persistent consumers.

Design: [mechanism](../../design/phase48/aggregate-transport.md);
[overall contract](../../design/phase48/composable-representations.md).
Baseline: Phase47 array06 API `28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f`,
runtime `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.

Falsifier: changed observable value/error/order/alias; no actual private entry or
removal of executed work; unfavorable runtime/compiler/size tradeoff on independent
sources. Diagnostic ablations do not qualify compiler source changes.

## Outcome

The scalar03 implementation removes actual private state tuple construction:
the maintained RLE witness changes array-literal executions **15→3**, while
persistent `Con`/`Nil` remain **24/7**, result 11 and one private entry unchanged.
The corrected pass has 26 synthetic graphs / 69 observations; actual emitted
recursion has two graphs / 30 observations; renamed source controls have
74 oracles / 13 boundaries /four activation checks. The first implementation's
nonterminal-Case failure and the later register-clear correction are preserved.

The four-point corpus screen is weak: RLE gain 0.9580×, Map 0.9224×,
records64 0.9963× and records256 1.0362×. Three fresh balanced rounds and
substantial sample drift do not establish a stable improvement. Six additional
scale points keep the exact source unchanged and remain outside full45 weights.
Scalar gains range 0.9373–1.0319×; the separate flat-result-vector alternative
ranges0.9365–1.0213×. Both regress the largest non-tail diagnostic by about 6.7%.
Each is compared to its own fresh baseline; this is not a direct comparison
between the two candidates. No controlled compiler-cost/full45 candidate gate
was justified by this result.

The vector source controls retain all 74/13/four checks and require an explicit
alternative constructor witness. They do not weaken scalar03 expectations.
The vector actual-emitter gate also passes two graphs / 30 observations
(`jw-vector01/report.json`, SHA-256
`3537f62013398fb0ee2ed2e5615511d13df496e3b9505be2ae95568452b6d610`).
Its historical RLE 15→8 count is an unexecuted expectation. No further vector
four-point corpus screen or full qualification is justified by the weak scale
result; these checks cannot establish speed benefit by allocation count alone.

The proposals add 565 physical Bend lines (scalar) or 537 (vector), plus a JSON
module entry. Source-array counts are an intermediate mechanism measure, not
proof of physical heap allocation or useful speed. Defer this implementation
rather than spending more complexity on unmeasured follow-on cleanup.

[Detailed outcome and exact receipt hashes](../../implementation/phase48/aggregate-transport.md).
[Durable complete patches and payloads](../../selfhost/tools/performance/phase48/proposals/aggregate-transport/README.md)
preserve failed01, terminal-Case02, cleared-register03 and vector01. The
proposal manifest is SHA-256
`7047e651f72844a69636a832095231fdf9ce5bd53da9259271c65035eb7b8913`.
No selected release or primary benchmark weights change.
