# Did the small-query code generation transfer to the compiler?

Yes, statically. The full integrated source is identical in the two native
emissions: `2620d59a3a20fa5d5d27bbf3b12ceb7304439b27093fff1c0f383da03e4ecf38`.
Q1 was emitted by the qualified producer; Q2 by the resulting candidate N1.
[full-query01/report.json](full-query01/report.json) pins both successful requests,
their producer images and full products. The
[streaming extractor](../../../selfhost/tools/performance/phase137/audit/full-query-v01.py)
retained only 142,442 and 174,531 bytes of selected function bodies from the
roughly 107 MB inputs. It did not create a whole-function map or whole-IR String.

| Actual compiler function | Q1 | Q2 |
|---|---:|---:|
| `lookup` | 590 QBE lines; 3 local take9; 54 sinks | 203 lines; 0 local take9; 15 sinks |
| `nc_ctor_owned` | 560 lines; 4 local take9; 58 sinks | 151 lines; 0 local take9; 13 sinks |
| `f_find` SCC worker | 155 lines; guarded helper absent | 155 lines; guarded helper available |

The Q2 call paths match the successful small fixtures:

- `f_find` at QBE line 142182 enters `$p126scc.1014`; the latter calls
  `p137q_key_eq` at 142153, whose adapter reaches the borrowed reader at 142008.
- `lookup` at 271463 calls `p137q_name_eq` at 271605. Its adapter has the private
  reader call at 177871 and the owning fallback at 177876.
- `nc_ctor_owned` at 324265 calls `p137q_is_adt`, `p137q_is_ctr` and `db` at
  324298, 324327 and 324348. Each has the expected guarded borrowed adapter.
- The scalar `da` getter also receives its existing borrowed implementation.

The owning `is_cache`, `dc`, `dn` and `dk` implementations remain. The first two
are still actual query dependencies. Named static paths prove neither that
runtime guards accept particular arguments nor how much of a request is spent
in them. Thus neutral small native-request timings cannot be explained by these
full-image reader paths simply failing to be emitted. They could still reflect
guard refusal, a smaller hot-path share, surviving work or offsetting costs.

## A concrete offset to measure: retained owning getters

The separate [full direct-call census](full-calls01.json) streams call sites
without retaining IR. It distinguishes private functions from generic segment
and fallback definitions; only the private counts are compared here.

| Private call target | Q1 static sites | Q2 static sites | Q2 implementation |
|---|---:|---:|---|
| `dn` | 1 | 35 | Owning String projection |
| `dk` | 34 | 119 | Owning String projection |
| `dc` | 1 | 30 | Owning list projection |
| `da` | 18 | 60 | Guarded scalar reader/fallback |
| `db` | 2 | 29 | Guarded scalar reader/fallback |
| **Total** | **56** | **273** | |

The broad wide-take profitability policy preserves 148 additional call sites to
the three owning-result getters, without enabling a borrowed result for them.
This is a plausible offset to the scalar-query gain. It is not yet a measured
dynamic penalty: site counts are not call frequencies, and smaller code can
also help instruction layout.

Whole-image static take9 sites fall from 271 to 19, while the runtime helper
remains inside the owning callees. Much of that count reduction is moving
duplicated instructions back into shared functions. It must **not** be reported
as a 93% reduction in executed extraction or reference counting. Similarly,
whole-image static sink sites fall from 53,870 to 51,190, but generic fallback
and optimized bodies coexist in those totals.

The high-information follow-up is to separate scalar-observer boundary retention
from ordinary owned-result getter retention using already verified result facts,
and to measure the actual guard decisions in the retained query paths. Neither
requires a universal IR rewrite. This audit made no new candidate and executed
no compiler or generated program.

## Why the nine-character cache-kind observation may still fail

This remains a source-grounded hypothesis, not an observed refusal. Existing
emission receipts do not retain the rejected `NO_Plan` for `p137q_is_cache`.
There is no explicit eight-character String limit in the selected literal
lowering: `no_literal_string_step` (36924) expands one step and re-enters the
budgeted evaluator. Virtual argument validation allows depth16; nine `SCon`
cells plus a `Chr` scalar do not by themselves exceed that structural bound.

A more concrete limit appears across helper composition. Ready virtual helpers
can specialize with source-stack depth below16 (`p131rv_reference`, 57801),
but **unsummarized ordinary helpers still require depth below8**
(`p128br_reference`, 55537). `p88_string_eq_go` recursively calls itself while
comparing each character with `Char.is_eq`. The pinned Base definition
`selfhost/.bootstrap/upstream-phase66/bend2/base.bend:1845` implements that
comparison as an ordinary two-scalar helper. Native `Char` is a scalar, not a
borrowed root (`nol_scalar`, 36645; `nol_root_specs`, 36692), and the observer
summary admission requires at least one root (`nol_result`, 36760).

Consequently, successive virtual equality specialization can grow the helper
stack until the nested scalar helper reaches the stricter depth8 gate, even
though the outer ready helper permits depth16. This is a more specific next
diagnostic than assuming that constructor width or the literal itself is
unsupported. The independent global evaluation budget4096 is another possible
earlier refusal. First capture the exact rejected plan error, remaining fuel
and call stack for the unchanged cache predicate; do not blindly raise either
limit or change the frozen integrated compiler.
