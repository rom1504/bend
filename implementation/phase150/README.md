# Phase150 — faster parsing, literal-pattern costs and parallel validation

The preferred lexer is a validated **component candidate**, not a newly
qualified full compiler. On the frozen 3,068,721-byte compiler input it lexes
4.43× faster and reduces complete parser time by 9.62%. The first implementation
made its parser executable 43.87% more expensive to build. Profiling exposed why;
the final implementation removes that acquisition penalty.

The independent two-process validation pilot reduces elapsed time by 40.78% on
its two fixed correctness jobs. Upstream migration remains separate because its
runtime flags, JS representation and checker interfaces have changed.

[Design](../../design/phase150/README.md) · [Metrics](metrics.json) ·
[Cost and retention](cost.json) · [Evidence](evidence/README.md) ·
[Historical preferred Bend implementation](https://github.com/rom1504/bend/blob/75bc607/selfhost/tests/phase150/lexer-candidate.bend).
Phase152 integrates it into the [maintained lexer](../../selfhost/src/front/lexer.bend)
and retires the duplicate experimental module; the frozen evidence remains unchanged.

## Measured results

All target work used the existing guarded execution lane. Ordinary measurements
use CPU3; the separate-process pilot alone uses CPU0/1. The native component
producer is qualified Phase147 N2, with its pinned Base, carrier and QBE runtime.
Current maintained declarations supplied the reference parser; no historical
parser executable supplies the timing baseline.

| Matched experiment | Reference | Preferred scalar lexer | Observation |
| --- | ---: | ---: | --- |
| Lexing the compiler source | 4.2375s | 0.9570s | 4.43× faster |
| Complete parse/load interval | 30.535s | 27.597s | 9.62% less time |
| Complete parser process, including input/observation/teardown | 31.497s | 28.552s | 9.35% less time |
| Building the parser executable | 46.525s | 45.591s | Earlier penalty absent; no significant acquisition speedup claimed |
| Two independent correctness jobs | 3.269s serial | 1.936s parallel | 40.78% less elapsed |

Lexer/parser runtime rows use two alternating pairs. The reference acquisition
is the mean of two builds; the preferred acquisition has one observation.
These are small screens, without confidence intervals. The parallel figure is
also two pairs and includes coordinator startup and all child work. It is not
parallel speedup of one compiler request, nor a CPU-efficiency measurement.

There is **no new whole cold-build measurement**. This result does not turn the
historical 258-second staged build into a 100-second build. The parsing share
alone is too small to support that claim. The stronger result is a reproducible
example of avoidable frontend expansion, and a cheap way to investigate it.

## What actually changed

The lexer unpacks `SNil`/`SCon` directly, uses scalar character comparisons,
constructs lookahead text only for accepted tokens, and calculates quoted-token
width and final position during scanning. It preserves the existing seven-field
`FToken` and all parser consumers. There is no packed-IR conversion, array adapter,
new cache, changed optimization policy or disabled final verifier.

The preferred module is 217 lines, with 27 helper definitions and two private
types. The original literal-pattern variant is preserved at commit `6e88473`;
the grouped and scalar variants are preserved in the evidence capsule. Only the
preferred experiment module remains at HEAD. Production `selfhost/src/` and the
installed selection are unchanged.

## The important negative result

The initial direct literal-pattern lexer was about 5.6× faster in its lexical
screen and improved complete parsing, but parser acquisition rose from 46.525s
to 66.934s. A reversed-order repeat reproduced the penalty with exact emitted
QBE. QBE text grew only 0.69%; that did not explain the extra twenty seconds.

We reused the existing authenticated Phase147 profiler executable and object
bridge, avoiding a compiler rebuild. Both compiler-emission profiles matched
their complete retained QBE outputs. Seven frontend/lowering intervals explain
21.430s of the 21.972s diagnostic wall-time increase:

| Interval | Additional time |
| --- | ---: |
| Parse/load | 4.923s |
| Checking/publication | 4.640s |
| Annotation/reach | 3.581s |
| Raw lowering | 3.132s |
| Erasure/finalization | 2.870s |
| Layout check | 1.258s |
| Static preparation | 1.026s |

Initial optimization and final rendering were essentially flat. Source inspection
traces character patterns through `Chr`, U32 literal expansion into 32 `WCon`
bits, match hit/miss construction and body substitution. Checking, annotation,
erasure and lowering subsequently revisit the enlarged intermediate terms.

Grouping two dispatch functions reduced small-probe acquisition from 30.766s
to 24.186s. Replacing literal character patterns with scalar predicates reduced
it to 8.599s while retaining a large execution improvement. Those three proxy
acquisitions are single observations; they support the representation hypothesis
rather than quantify a whole-compiler gain.

Whole-profile quality and exact stage-clock admission pass. Every individual
stage has fewer than 500 samples, so owner/leaf samples remain descriptive. No
sampling gate was weakened. Diagnostic emission clocks exclude QBE construction
and are not substituted for the clean acquisition measurements.

[Profile evidence and source trace](../../research/phase150/parser-acquisition-profile-results.md).

## Correctness and scope

- Each lexer variant passes 315 exact token-list controls and ten comparator
  controls. They cover all seven fields, list shape, EOF/NUL, Unicode, cursor
  wrapping, disabled metadata, operators, comments, quotes and error behavior.
- Native reference and candidate compare all 850,068 tokens of the frozen compiler
  source exactly. The preferred candidate also matches Base and Hashmap token
  outputs, rather than relying solely on a checksum.
- Fifteen complete hosted parse graphs are byte-identical, including source
  metadata and diagnostics. Bend independently checks eight expected successes,
  seven expected failures and successful declaration counts.
- Native complete-parser observations have the same full-result checksum.
  That checksum is an observation, not a replacement for the exact token/graph
  gates and not a whole-input graph equivalence theorem.
- Eight independent correctness reports pass in the process-parallel pilot.
  QBE, assembly, objects and stdout match across schedules. Full ELF files differ
  because of linked artifact paths/build IDs; no ELF identity is claimed.

Independent source checking is not an independent BendTT equivalence proof.
No new full native self-reproduction, original45 qualification, generated-user-
program runtime score, or upstream compilation ratio is claimed. The ordinary
qualified native compiler remains Phase147.

## Parallelism and upstream

The new coordinator is Bend. It uses the existing asynchronous legacy-JS process
provider under pinned Node, launching separate single-mutator native processes.
The pinned Bun execution returned errno1 for pipe controls; the same generated
artifact passed under Node. Timeout/cancellation controls and independent child
reports passed. Peak aggregate RSS was 156.13MiB, with no new swap/OOM activity.
CPU totals were not collected, and this two-case pilot does not qualify a general
scheduler or parallel QBE heap. [Results and replay](../../research/phase150/parallel-validation.md).

The upstream assessment covers `0592662..e9d269b` (246 commits). Important
migration boundaries include `+RTS` flags, JS Nat/tag/Char changes and the
`safe_check` return contract. No migration or pin change was mixed into the
comparison. [Assessment](../../research/phase150/upstream-assessment.md).

## Research cost and retained failures

The 66 guards account for 821.21s (13.69min): 404.16s acquisition/source checks,
294.55s execution controls and measurements, and 122.50s profiling/attribution.
Peak aggregate RSS was 939.03MiB. Three bounded workers performed independent
research, source work and audits; the coordinator owned all target execution.
Guard time is not total agent effort, and token/quota counters were unavailable.

Ten guards were non-successful: one expected cancellation, two Bun provider
controls, two initial coordinator source-check failures, and five incomplete
source-slice dependency selections. All were preserved and resolved or explicitly
rejected; the candidate's semantic gates passed. Two additional guard command
admission errors occurred before any target ran. All 66 runs were classified,
archived and verified in 38.37s; no pruning or OOM occurred. The compact committed
evidence capsule is 8.90MiB. No full compiler acquisition was commissioned.

## Next decision

Retain the scalar lexer for the next justified integration checkpoint. Its
complete-parser improvement is useful but falls short of the ambitious 2×
complete-region gate; another full compiler qualification solely to advertise
the lexical microbenchmark would be poor use of this investigation's budget.

The highest-information next experiment is the same acquisition/execution
counterfactual on `p88_roles`, then `p112fp_binary`. The audit finds 77 numeric-
leading rows in 17 ordinary compiler functions, after excluding controls and
protected proof helpers. This is a source inventory, not a hotness measurement.
The already optimized runtime-name classifiers need their own execution gate;
scalarizing every pattern blindly could undo runtime wins.

The larger architectural hypothesis is to retain compact literal-pattern
information through checking and traversal, materializing bit structure only
where semantics require it. Dependent refinements, constructor discrimination,
affinity, evaluation order and diagnostics make this more than textual rewriting.
Prove one narrow useful contract and measure actual intermediate work before
introducing a general IR node or rewriting the matcher.

[Literal-pattern audit and ranked bounded targets](../../research/phase150/literal-pattern-audit.md).
