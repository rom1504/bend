# Phase137 — Borrowed queries that survive inlining

**The qualified native candidate reduces a controlled full cold build from
373.5 to 346.4 seconds (7.26%).** Small compilation requests remain approximately
unchanged. All45 historical benchmark wrappers emit exactly the previously
measured QBE, preserving their generated code.

The main finding is a composition problem: early inlining copied owning record
operations into callers before existing borrowed readers could replace them.
Keeping complete query boundaries lets those optimizations work together without
repeating preparation. Large kernel gains transferred to the full compiler, but
at a much smaller percentage. This does not achieve upstream request parity,
a60-second cold build, or general incremental frontend compilation.

[Design](../../design/phase137/README.md) · [Metrics](metrics.json) ·
[Experiment](../../experiments/phase137/P137-001-borrowed-query-boundaries.md) ·
[Qualified native evidence](native-qualification.json) ·
[User guide](../../docs/self_hosted/preserved-query-boundaries.md) ·
[Reproduce](../../selfhost/tools/performance/phase137/README.md).

## Measured results and their limits

| Measurement | Parent/reference | Candidate | Meaning |
|---|---:|---:|---|
| Full cold source→executable |373.511s|346.391s|7.26% less time; same frozen compiler source, one fresh serial pair |
| Same-source full self-request |350.187s|325.880s|6.94% less time; N1 versus N2, identical106,285,793-byte QBE output |
| Small native request screen |1.000×|0.9992×|Approximately neutral;27 rotated observations, three sources/rounds |
| Fresh small request / upstream |1.4070×|1.3957×|Separate27-observation block; still roughly40% more request time |
| Generated unchanged compiler A, small requests |1.000×|0.9895×|Same source built by the two generators; no observed regression |
| Extracted actual compiler queries |190.288ms|130.863ms|31.23% less time, five rotated rounds |
| Unrelated nine-field record query |227.974ms|80.059ms|64.88% less time, five rotated rounds |
| Full fixed-source QBE volume |107.059MB|105.879MB|1.10% less text; not a compact-IR breakthrough |
| Compiler source lines |58,392|58,569|+177 lines including controls, +0.30% |

The cold input is unchanged Phase131 source `1bc5930e…728f9`, exactly the Phase136
workload. The fresh parent observation is close to Phase136's375.923s. The cold
clock includes native startup, source/Base preparation, checking, lowering,
verification, rendering/transport, QBE, assembly and linking. Both use the same
compact prepared Base, cached runtime and machine tools. There is no reused
semantic or object result; OS page caches were not flushed. One full pair is an
observation, not a confidence interval. Native peak process-tree RSS was1.020GB
versus1.008GB; no OOM occurred.

The self-request uses the new compiler source, so its350.2→325.9s pair must not be
substituted into the historical cold-input comparison. The small upstream block
improves0.80% versus its same-block parent; the separate0.9992× screen supports
calling small-request latency approximately unchanged. The native/upstream
request-plus-machine-child sum is0.6824×, but native prepared Base/cached runtime
and upstream source Base/full C/Clang construction differ. That is not compiler
request parity, full-source upstream parity, or generated-program speed.

All45 native benchmark wrappers are byte-identical to the products behind the
retained Phase131 broad runtime result, approximately1.663× upstream on44 timed
points. No fresh broad runtime ratio is claimed. Actual program execution is
also checked by ordinary45. The additional unchanged-compiler-A experiment uses
both executables already produced by the cold comparison;27 small requests pass
exact QBE oracles and give0.9895× geometric execution time. This checks transfer
without another full image acquisition.

## Implementation and causal evidence

The integrated source changes nine existing declarations: four width bounds
8→16, one early-inlining profitability entry, three actual compiler query bodies,
and the obsolete width9-refusal control (now17). Five scalar predicates preserve
operand order, first-match semantics, BookCache behavior and missing results.
Unknown, escaping, packed or unsupported cases keep their existing fallback.

The policy defers early inlining for exact9–16-field consuming reads inside the
existing return-shape walk. It adds no second whole-body pass or duplicate
preparation. Borrowing legality, root/alias checks, buffer capacity, runtime and
independent final verification stay separate and unchanged.

The actual full compiler receives the same improvement as the proxies:
`lookup` falls590→203 QBE lines with local take9 sites3→0;
`nc_ctor_owned` falls560→151 with local take9 sites4→0. The timed record loop
falls333→183 lines. Linked machine calls reach guarded readers. All seven relevant
reader bodies are byte-identical to the previous experimental variant: reaching
them is what changed. These static counts are not dynamic allocation counts.

[Independent source/ownership audit](audit/README.md),
[linked machine evidence](audit/machine01/report.json), and
[full-compiler transfer audit](audit/full-query.md) preserve the exact products.

## Negative results and remaining tradeoffs

Width alone was neutral. Source factoring alone was neutral. Width plus factoring
improved only the parser query because its SCC already resisted early inlining.
Reordering predicate arguments and specializing constant kinds did not restore
other call sites. Those variants and raw timing rounds remain archived.

The broad retention policy also increases calls to still-owning `dn`/`dk`/`dc` by
148 static sites. `is_cache` and `dc` continue to extract owned fields. This is a
plausible offset, not proof of a runtime regression; the unchanged-compiler test
is approximately neutral/slightly better. Do not equate fewer inlined takes with
eliminated dynamic ownership work. The actual full-cold improvement is7.26%, not
the31–65% proxy result.

The next bounded experiment is preserving complete consumers while still
inlining plain owned getters, with both original and composed source controls.
Also capture the exact refusal for the remaining BookCache predicate before
changing any helper-depth/fuel limit. Larger savings require eliminating scans
and preserving exact facts earlier. [Next opportunities](remaining-opportunities.md).

## Qualification and selection

Source SHA256 `2620d59a3a20fa5d5d27bbf3b12ceb7304439b27093fff1c0f383da03e4ecf38`
is independently source-checked and passes50 exact finite controls. Protected
verifiers/entries and eleven proof-source declarations are unchanged; no new
whole-compiler theorem is claimed. Qualified Phase134 N2 builds N1; N1 builds N2;
N2 emits byte-identical Q3. N2/N3 pass focused19 each; N3 passes ordinary45.
Both reproduced object files are identical; no ELF-byte fixed point is claimed.

The final research image is `selfhost/build/phase111/p137-n3/program`, with the
unchanged Phase128 runtime. [Selection](candidate.json) preserves the old qualified
source and image. The installed CLI is unchanged. No PR comments were posted.

## Research cost and reproducibility

Three bounded agents prepared source/fixtures and independently audited semantics,
call paths and qualification. The coordinator owned one serial CPU3 target lane;
source checking used CPU6 serially.35 guarded jobs consumed41.06 minutes in total,
including acquisition, rejected hypotheses, native qualification, two full cold
builds and the final comparisons. Peak target-tree RSS was2.04GiB during checked
API acquisition; full native work stayed near1GB. Inspection-path mistakes and an unsupported guard CLI flag were corrected
before target execution; no failed compiler/runtime experiment is hidden.

The complete turn took approximately84 minutes, including source investigation,
independent audits, metadata/replay checks, reports and publication. These
non-target activities partly overlap guarded execution.

Wall time and model quota are different quantities; billing/token usage is not
available in these receipts. There is no demonstrated recursive research
acceleration. The avoided work is concrete: no repeated broad runtime campaign,
no duplicate preparation experiment, and unchanged compiler-A binaries were
reused for the extra generated-code check.

[Small-experiment capsule](evidence01/receipt.json) ·
[Native/full-build capsule](evidence02/receipt.json). Exact methods, source inputs,
logs, receipts and the canonical reproduced QBE are retained. The archive lists
large reproducible products kept locally rather than duplicating every binary.
