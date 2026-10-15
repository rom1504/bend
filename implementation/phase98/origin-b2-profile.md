# Complete origin B2 ownership profile

The exact final B2 image successfully compiled its complete `2a72bbdc…` source
under the existing Phase88 sampler. The sampled run returned zero, reproduced
the complete 38,327,511-byte C output (`6ae1675a…`) and the exact clock-stripped
diagnostic, and finished normally. This is a full end-to-end capture, with no
watchdog termination. The request-specific findings below use all **8,823
request samples**, delimited by the validated `IO.now` marks; Base preparation,
runtime setup and output writing are outside that denominator.

The [accepted windows receipt](../../selfhost/build/phase98/ownership-origin-b2-self01/windows.json)
binds the exact image `c481bd2c…`, image-specific sampler, unchanged preparation
inputs, raw samples, analyzer output and successful process receipt. There were
no overruns, dropped samples, thread overflows, clock failures or disarm
failures. Sampled threads account for 99.99991% of recorded process CPU. The
guard measured 142.024 seconds and 1.526 GiB peak tree RSS; the marked request
lasted 141.169 seconds. These profiler clocks describe capture scope, not a
speedup measurement. Base has only eight samples and runtime setup none.

A fresh [offline attribution report](../../selfhost/build/phase98/ownership-origin-b2-attribution01/report.json)
adds decoded physical owners, authenticated C spans, exact image disassembly
and a raw-PC split of the inlined equality worker. Its
[method](../../selfhost/tools/performance/phase98/comparison/origin-b2-profile-attribution.py)
runs no compiler or benchmark and changes no pinned input.

## Where the request spends CPU

| Sampled leaf | Samples | Request share |
| --- | ---: | ---: |
| `term_drop` | 2,891 | 32.77% |
| `span_fade` | 1,318 | 14.94% |
| `NF:p88_string_eq_go` | 743 | 8.42% |
| `WL:$direct.String.append` | 373 | 4.23% |
| `WL:$direct.p88_string_eq` | 345 | 3.91% |
| `WL_BEND_CLO_APPLY` | 341 | 3.86% |
| `rfc_wrap` | 254 | 2.88% |

Together the three ownership helpers account for 4,463 samples, **50.58%**.
All 4,463 have a recovered physical owner under the existing unwinding method.
This identifies the compiled owner of the cleanup call, not a logical call tree
through musttail-eliminated ancestors.

| Physical owner of ownership-helper samples | Cleanup samples | Request share |
| --- | ---: | ---: |
| `$direct.kc` | 625 | 7.08% |
| `p88_string_eq_go` | 414 | 4.69% |
| `$direct.p88_string_eq` | 390 | 4.42% |
| `$direct.dn` | 344 | 3.90% |
| `$direct.nb_contains` | 245 | 2.78% |
| `native_k_44186` | 205 | 2.32% |
| `$direct.dk` | 192 | 2.18% |
| `$direct.index_find` | 189 | 2.14% |
| `$direct.has_name` | 179 | 2.03% |
| `p98_tag_eq_read` | 168 | 1.90% |
| `$direct.nt_choose` | 127 | 1.44% |

## The borrowed equality route is active

The observer has been inlined into `NF:p88_string_eq_go`, so that symbol's
8.42% share cannot be attributed wholesale to the owning fallback. In the
[exact walker disassembly](../../selfhost/build/phase98/ownership-origin-b2-attribution01/walker.asm),
the two shared-root tests branch to `0xc6279f`. The borrowed pointer walk and
result checks occupy `[0xc6279f, 0xc628ed)`: that interval has direct field loads
and branches, no call instruction, and **577 samples**. This is 77.66% of the
worker's leaf samples and 6.54% of the request. The C mapping is the
[`term_peek` observer](../../selfhost/build/phase98/origin-b1-self01/execution/output.1.c:41639)
already established by the [static mechanism audit](own-backend-mechanism.md).

The other leaf samples are 79 in the entry/owning-fallback region (which also
contains the shared-root test), 51 in the first saved-root disposal prelude and
transfer, and 36 in remaining common exits/fallback cleanup. These are machine
regions, not invocation or branch-frequency counts.

The owning adapter still disposes its saved roots. Its first-root `term_drop`
call at `0xc62922` has 236 ownership samples at return-PC-minus-one `0xc62926`.
Another 178 samples occur at `0xc62aa6`; this second-root site is in a merged
tail also reachable from the fallback, so all 178 cannot be charged to the
borrowed adapter. The public equality wrapper also retains its input roots and
performs final disposal. Across that wrapper and walker, leaf samples plus
their physically owned cleanup total 1,892 samples (21.44%). This is a disjoint
observed bucket, **not removable time**: character comparison and final disposal
remain necessary operations.

## Remaining mechanisms and next opportunities

1. **Lower saturated Boolean choice with known closures to direct control flow.**
   [`kc`](../../selfhost/build/phase98/origin-b1-self01/execution/output.1.c:86892)
   and [`nt_choose`](../../selfhost/build/phase98/origin-b1-self01/execution/output.1.c:102869)
   sink the unselected closure and invoke the selected closure with `Unit`.
   Their combined 752 cleanup samples are 8.52% of the request; their leaf plus
   cleanup bucket is 9.66%. The two `kc` call sites in the saved assembly account
   for all 625 of its cleanup samples. A general lowering could avoid building
   some short-lived branch closures, but it must preserve argument demand,
   effects and capture ownership. The separate 3.86% generic closure-apply leaf
   share cannot all be assigned to these two owners.

2. **Extend retained field observation with an explicit escaping-child rule.**
   [`dn`](../../selfhost/build/phase98/origin-b1-self01/execution/output.1.c:75875)
   and [`dk`](../../selfhost/build/phase98/origin-b1-self01/execution/output.1.c:74707)
   consume a nine-field `KDef`, return one field and dispose the others; their
   other branches also consume index wrappers. `ks` similarly projects from
   term constructors. Cleanup under `dn`, `dk` and `ks` totals 635 samples
   (7.20%). The tag reader adds another 168 (1.90%) and remains a consuming
   `KTerm` projection in both C products. A sound borrowed projection must retain
   any child that escapes before disposing the parent and keep the generic
   fallback; the current String observer does not supply this rule. The samples
   do not distinguish individual constructor branches within these owners.

3. **Investigate String construction at concrete append callers.**
   The C explicitly schedules `native_k_44186` from
   [`String.append`](../../selfhost/build/phase98/origin-b1-self01/execution/output.1.c:94083).
   That [continuation](../../selfhost/build/phase98/origin-b1-self01/execution/output.1.c:94164)
   allocates an `SCON`, seals its fields, and returns it. Its 205 ownership
   samples all land in `rfc_wrap` at return-PC-minus-one `0x2b948c`; it also has
   218 leaf samples. Together with append's own leaf and cleanup samples, the
   mapped construction bucket is 840 samples (9.52%). In the final
   120–141.169-second window, append alone is 19.35%, this continuation's leaf
   is 10.43%, and its `rfc_wrap` call is 10.20%. This supports investigating a
   builder or chunked output representation at the actual callers. It does not
   establish quadratic prefix growth or identify the logical emitter caller.

4. **Audit equality boundary ownership before proposing further fusion.**
   The borrowed walk is already active. Further experiments should target
   repeated retain/finish/adapter boundaries with a complete lifetime contract,
   or reduce repeated comparisons at callers. Deleting root disposal because
   it is hot would violate the current owning interface. The 21.44% physical
   equality bucket is useful for prioritization, not a savings prediction.

The five request windows contain 1,875, 1,875, 1,875, 1,875 and 1,323 samples.
Cleanup dominates throughout; the final window has substantially more mapped
String reconstruction. These wall intervals are not compiler-stage boundaries.
The capture demonstrates both active observation and substantial remaining
ownership/construction work in the actual B2 image. It does **not** isolate why
B2 benefits less than B1: that causal comparison requires a matched successful
current B1 profile. No partial or divergent old watchdog profile is used here.

The [separate TypeScript context](../../selfhost/build/phase98/origin-ts-self-plan01/report.json)
puts unsampled B2 request time at 3.122 times the two-run TypeScript median.
Even an unrealistic deletion of **all** time sampled in the three ownership
helpers would leave `3.122 × (1 − 0.5058) ≈ 1.543` times that median, if all
other work stayed fixed. This is at most a 2.02-fold native speedup from deleting
only that measured helper work; parity would require about 67.97% total time
removal. Ownership work alone is therefore insufficient under this model.
The [arithmetic receipt](../../selfhost/build/phase98/ownership-origin-b2-attribution01/removal-bound.json)
pins both inputs and the assumptions. This is an illustrative ceiling, not a
measured gain or a bound on broader transformations that also remove other
work; the TypeScript and native compilers emit different backend C products.
