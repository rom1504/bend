# Phase144: exact first-prior parser lookup

The isolated native parser now shows a measured improvement; see the final
results below. Full compiler qualification and selection remain coordinator-owned.
The selected
Phase143 source is
`a51a4a6d0a32e118ca75eac96fb4e64bae0fcf951b09ee859c2632f65550bd4e`.
The coordinator's refreshed profile places `f_find` at 26.8% of samples in the
first 30 seconds and 20.4% in the next 30 seconds. Those window percentages are
not a whole-build saving or a count of calls covered by this candidate.

## Why the existing index cannot replace the lookup

In that exact source:

- `f_find` at line12669 scans a flat prior list and returns the **first** matching
  definition. It does not treat a `BookCache` row as an index barrier or search
  constructor children.
- `index_build` at line6416 builds the tail first and inserts the head last, so
  it also implements first-element precedence when given the same list.
- `f_source_body` at line15220 initializes the existing scope index with
  `index_build(List.reverse(prior))`. Consequently that index has the opposite
  duplicate precedence from `f_find` on this input. Reusing it would silently
  change parser behavior.
- `f_context_declare` at line11672 publishes a mapped header with an absent
  body. A current local declaration list can still contain the original body
  or law event. The index is therefore not a blanket replacement for raw local
  searches either.
- `index_find` returns `missing()` on failure, whereas `f_find(name,[])` returns
  the requested name in a `Missing` record. Testing only the kind is insufficient:
  an actual matching record may have kind `Absent` or `Missing`.

These distinctions matter for ordinary law filling and duplicate diagnostics,
not only synthetic malformed records.

## Narrow candidate

[prior-v01.bend](../../selfhost/tools/performance/phase144/parser/prior-v01.bend)
adds six helpers and one optional field to `FParseScope`:

```text
priorView : Maybe<KDef index>
None                    => original f_find
Some(index_build(prior)) => indexed first-prior lookup
```

`f_body_header` builds the view once, only on the successful header branch.
Every normal contextual declaration updates it with the same mapped record
prepended to `prior`. The original prior list, name index, constructor index,
namespace and aliases remain available and unchanged. The four routed consumers
are `f_context_family_input`, `f_context_mark_input`, `f_do_header_resolved` and
`f_do_resolved` (five call sites). The original `f_find` remains the independent
reference and fallback.

For nonempty names, a found record is accepted only when its complete stored
name equals the query. A miss constructs the original named missing value.
Empty names retain the original flat scan because index sentinels also expose
an empty name. Patricia collision buckets are handled by the existing index.

All old scope constructors initially produce `None`. This is conservative for
raw APIs and incremental parser entries that bypass `f_body_header`: those paths
retain the original behavior, and are not claimed to gain speed. Existing
incremental scope equality additionally compares the optional view, so it cannot
accept a less precise checkpoint because of this change.

The source composer extends 26 declarations containing the internal scope type
or patterns. Most changes only add the field. The old local-search algorithms,
original `f_find`, constructor index, index primitives, proof declarations and
final backend verifier remain unchanged. The external `FResult` shape does not
change.

## Evidence and falsification

The current candidate is `selfhost/build/phase144/parser-source02`, SHA
`1879103e32ec1778c58fe42c2e0c06d1300c7129e384aedc72cdc8a51e79df71`.
It is reproduced by `prepare-v03.py` from the selected source and the two Bend
modules. Source01 is retained: its first API check rejected a test fixture's
twice-used scalar parameter because `version` lacked `+`. Source02 changes only
that fixture annotation; it is not evidence of compiler correctness or speed.

The planned finite controls compare complete KDefs to the original lookup:
first/last duplicates, real `Absent`/`Missing` kinds, Unicode, the actual
`Unit`/`p143CollisionlrXlHP` hash collision, no child descent, ordinary cache rows,
index variants, empty names, namespace publication and repeated declaration
updates. There are 27 controls.

[parse-screen-v01.mjs](../../selfhost/tools/performance/phase144/parser/parse-screen-v01.mjs)
requires separately checked original and candidate APIs. It compares complete
external raw parse products—including every term/span and first error—then full
frontend request products. Law, template, duplicate and error fixtures accompany
three unchanged real sources: Lexer, Map churn and closures. The latter also
require complete generated QBE to match independently frozen native products.
The host script only invokes checked Bend and observes data and bytes.

The initial timing discriminator is complete hosted frontend cost, charging
construction and updates of the new index. It is not a native RC/reclamation
measurement. If construction costs exceed avoided scans on ordinary requests,
do not proceed directly to a full image build. If small requests improve, the
next useful holdout is actual compiler-source parsing and its covered-call
fraction; only then consider a native candidate. Additional local-list indexing
is a separate hypothesis requiring an exact raw-body provenance contract.

No speedup, parity claim, production promotion or new native qualification is
established by the source audit alone.

## First screen correction and native discriminator

The coordinator checked source02 successfully. In `parser-screen01`, all 27
finite controls passed and the first nine raw parse products were exactly equal.
The run then rejected a wrong test expectation: raw parsing accepts a name such
as `Unknown` in a marked type; unresolved-name checking happens later. The
candidate did not differ from the reference. `parse-screen-v02.mjs` changes only
that expected raw verdict and records this distinction; screen01 remains intact.

`prepare-native-v02.py` packages a separate native parser workload. The current
`parser-native-source02` pair contains 7,022 original and 7,073 candidate lines,
about 310KB each. It retains the actual parser, loader, prepared-Base carrier
decoder and their transitive dependencies. Six ordinary `p86_plan` prefix
declarations are copied mechanically, changing only their private continuation
and result names, and stop immediately after `f_prefix_graph_trace`. No checker
or backend is included. Both slices must use the same qualified Phase143 N2
producer and runtime, rather than compiling each with itself.

The timed input is the exact Phase142 compiler source and logical path already
used for the Phase144 residual profile. File input is outside the local clocks;
prepared-Base decoding has its own interval; the complete parse/import/freshening
prefix has its own interval. The prepared seed remains live through the end of
the parse clock. Error inspection, full tagged-field checksum and reclamation
are charged to a separate observation interval. External process timing charges
all of these operations and input IO.

`native-oracle-v01.mjs` first compares the complete extracted old/new parse trace
and seed on that actual input, then checks the Bend checksum against an
independently implemented host walk over every external `FResult` field. The
32-bit checksum is only a native regression check; complete hosted data equality
and exact source provenance supply the stronger structural oracle. This smaller
native workload can falsify the claimed parser opportunity before an expensive
full compiler image is acquired. Its different code layout and terminal consumer
remain limitations when predicting whole-compiler speed.

The initial slice source02 failed checking at `norm_defs_join`: the extraction
utility's default last-declaration map had omitted the earlier law. This was a
packaging error caught before a native build. `prepare-native-v03.py` computes
dependencies from combined same-name law/definition groups, then copies every
selected original declaration span in original order with its annotation. The
fresh source03 pair is 8,652/8,703 lines (340,416/341,778 bytes); the additional
lines are preserved signatures and their dependencies, not an added algorithm.
Each selected span has a source line range and digest in the manifest. Source02
and its failed check remain evidence rather than being overwritten.

Source03 exposed a second extraction defect: the old double-quote-only masker
misread a character literal and hid `f_lex_scanned`. Source04 replaces that masker
with the existing Phase141 census lexer, covering strings, character literals
and comments. It also checks declaration boundaries against the masked source
and audits the packaged declaration rows for every missing internal name or
constructor owner. Both variants have zero missing dependencies in that audit;
the resulting 8,726/8,777-line sources are still subject to independent checking.
These packaging failures are research cost and do not indicate a parser mismatch
or speed improvement.

## Checked and hosted results before native acquisition

Source04 passed both checked slice APIs:
[original](../../selfhost/build/phase111/p144-parser-slice-original03/report.json)
in 3.395s and
[candidate](../../selfhost/build/phase111/p144-parser-slice-candidate01/report.json)
in 3.140s.
The [full-input oracle](../../selfhost/build/phase144/parser-native-gates01/oracle/report.json)
passed complete parse-trace and prepared-seed equality over 3,535,203 compared
object pairs. The independent host observer and both checked Bend observers
agreed on checksum `2842271599` over 16,769,616 words.

| Hosted full-input operation | Original | Candidate |
|---|---:|---:|
| Prepared Base decoding | 0.748s | 0.747s |
| Complete parse/import prefix | 95.069s | 63.458s |
| Independent host observation | 1.124s | 1.282s |
| Bend observation | 0.463s | 0.490s |

The parse interval is 33.25% lower in this **single, original-first hosted
comparison**. This is not a native measurement, an interleaved timing result,
or a whole-compiler speedup. Exact whole-data equality took another 5.660s. The
complete oracle cost 169.516s and peaked at 3,098,992,640 bytes of RSS, close to
the 3GiB guard. Do not repeat this large hosted validation for each timing round.

The completed [small differential](../../selfhost/build/phase144/parser-screen02/report.json)
also passed 27 finite controls, ten raw parser cases, seven frontend cases and
three full generated-QBE bridges. Its three-round hosted frontend median ratios
were 0.9810 for Lexer, 0.9914 for Map and 1.1046 for closures. Thus index-building
cost is not free: the small closure request regressed about 10.5% in this screen,
even though full-source parsing improved. These frontend intervals include more
than parsing and do not provide a native profitability policy by themselves.

Recorded failed target work before this gate totals 7.524s: the fixture-affinity
check (5.762s), incorrect raw-parser verdict screen (0.696s), missing-law slice
check (0.233s), and quote-mask slice check (0.833s). Successful candidate API,
small differential, two slice APIs and full hosted oracle total 245.816s, excluding
the separately shared parent API, outer guards, source packaging, agent effort
and any later native acquisition. Both failed attempts and successful receipts
remain linked locally; no cost is silently counted as optimization work.

The next native run is prepared by
[native-timing-v01.py](../../selfhost/tools/performance/phase144/parser/native-timing-v01.py).
It validates both completed build receipts against the exact source pair,
qualified producer/runtime, carrier and structural oracle, then starts with one
original/candidate pair. It only extends to three total pairs if both parse
intervals are below 45s and the observed complete-process cost fits the remaining
budget. Later pairs alternate order. Base decoding, parsing, observation,
external process wall/CPU and peak RSS are separate fields. Native results remain
pending at this point.

The first native timing harness run passed all receipt admission but failed the
CLI protocol in 11.6ms: the compiled entry expects an ignored first token, whereas
native `IO.args` contains only the arguments following `--`, excluding `argv[0]`.
The program reported `expected INPUT BASE CARRIER STAMP` and exited2 without
parsing. This is not a native performance result. `native-timing-v02.py` supplies
`phase144-parser` before those four fields and binds the inspected runtime argv
contract. The unchanged images are reused; `timing-jobs-v03.json` requests only
one clean pair because the coordinator already has a separate full-program
diagnostic profile. Timing01 and its 0.730s harness cost remain preserved.

## Native result and transfer to the full compiler profile

The [one-pair native measurement](../../selfhost/build/phase144/parser-native-timing02/report.json)
passed both runs with empty stderr and the independently established checksum
`2842271599`. Both executables were produced by the same qualified Phase143 N2,
runtime and machine-build policy, on the same fixed Phase142 compiler input.

| Native interval or resource | Original | Candidate |
|---|---:|---:|
| Base preparation | 0.207s | 0.208s |
| Complete parse/import prefix | **44.572s** | **31.175s** |
| Observation/checksum | 0.600s | 0.605s |
| Complete process wall | **45.449s** | **32.055s** |
| Complete process CPU | 45.336s | 31.991s |
| Peak RSS | 307.1MiB | 309.2MiB |

Parsing fell **30.06%** (13.397s), and complete process time fell **29.47%**.
This is one original-first pair, so the report's `medians` and geometric ratios
each summarize one observation per role, not a replicated confidence interval.
The result agrees with independent evidence; the coordinator requested one pair
rather than repeating this relatively expensive experiment.

The full-compiler diagnostic intervals provide transfer evidence:
[Phase143 profile](../../selfhost/build/phase144/stages02/stage-profile.json)
versus [integrated Phase144 profile](../../selfhost/build/phase144/integrated-stages01/capture-stages.json).
On the same source, their actual `p86_plan` → `p86_plan_loaded` interval fell
from **47.950s to 35.906s**, or 25.12% (12.044s). Within those intervals, `f_find`
accounted for 480/1,497 active-owner samples before and 27/1,121 afterward:
32.06% → 2.41%. These are samples, not call counts or independently additive
costs. The large sampled linear-scan burden mostly disappeared, while other
parser work remained.

The 12–13s absolute saving agrees across the extracted clean native workload
and the full diagnostic compiler. Their absolute timings are not interchangeable:
the full profile has instrumentation, different machine layout and additional
integrated changes. The isolated pair supplies the narrower causal experiment;
the full profile supports transfer. Neither result means the complete compiler
build improved 25–30%. Against a roughly 315s whole-build baseline, a standalone
12–13s parser saving would be about four percent, with other stages unchanged.

The two native slice acquisitions cost **119.015s** combined
([original](../../selfhost/build/phase134/parser-native-source04-original/report.json),
[candidate](../../selfhost/build/phase134/parser-native-source04-candidate/report.json)).
The successful paired harness cost **78.902s** including admission, separately
from the earlier checks, full hosted oracle, failed argv attempt and root guards.
These costs explain why another full parser verification or native pair should
only be paid for after a relevant code change.

The experiment establishes an algorithmic improvement on an actual hot compiler
path without replacing its representation or weakening validation. The remaining
parser gap is now distributed among equality, contextual elaboration, token and
constructor operations. Another blanket `f_find` campaign is unlikely to repeat
this gain. Preserve exact name precedence and raw-body provenance if extending
the index to local declaration searches, and use the new residual profile to
rank that work against larger backend costs.


## 2026-10-26 consolidation update

The roughly315s whole-build example above is historical scaling arithmetic.
The current clean source01 same-input comparison is304.534→266.862s; the
separate serial-runtime observation is249.679s. These values do not turn the
isolated parser result into a complete-build speedup or assign the entire
integrated gain to parsing. Final03 has a different compiler source and its
self-source Q3 timing is a separate metric. See the
[consolidated evidence boundaries](../../implementation/phase144/profiler-and-cost-findings.md).
