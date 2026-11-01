# Phase151 scalar dispatch runtime screen

The first scalar spelling exposes a specific existing code-generation loss: each visited lazy chooser branch constructs and discards its ignored `Unit` argument. It is not evidence that scalar comparisons intrinsically lose to literal patterns.

The coordinator reported an initial matched two-table acquisition decrease around **1.43 s → 0.82 s**, but one-million-call local regions increased **37 → 66 ms** for roles and **81 → 110 ms** for binary. Exact controls and consuming hashes passed. These are initial screen observations supplied by the coordinator, not measurements rerun by this audit. Longer alternating runs and the complete decoder gate remain the coordinator's responsibility.

Inspection uses [probe-native01/program.ssa](../../selfhost/build/phase151/probe-native01/program.ssa) and [program.s](../../selfhost/build/phase151/probe-native01/program.s). The QBE digest is `ce4d2ca909ac855c8cae8a43c95bfeae75e55e5e7832c43995c25f1d67f00e9d`. Function symbols encode source names as decimal character codes; names below are decoded for readability.

| Direct worker | QBE start line | QBE lines | Static ctor/sink call sites |
| --- | ---: | ---: | ---: |
| `p88_roles` | 2810 | 157 | 0 / 0 |
| `p151_roles` | 2351 | 459 | 22 / 22 |
| `p112fp_binary` | 2218 | 133 | 0 / 0 |
| `p151_binary` | 1800 | 418 | 20 / 20 |

The original tables lower to whole-word comparisons interleaved with low-bit mask rejection tests, then return static list/string words. Their normal accepted and fallback paths contain no runtime calls. This emitted sequence is not simply a balanced search tree, although it originates in literal-pattern lowering.

The candidate equality tests become ordinary `cmpq`/`jz` instructions. There is no Bool heap construction or closure/apply call left in these direct workers. Instead, both sides of every chooser retain the following slice, shown exactly from QBE lines 1827–1831:

```qbe
%v_value =l call $p111_rt_ctor(l %state, w 0, l %v_scratch, w 0)
%v_p113p_move_73_0 =l copy %v_value
%v_v_5466 =l copy %v_p113p_move_73_0
%v_ignored =l call $p111_rt_sink(l %state, l %v_v_5466)
ret 144142675917964032
```

The two runtime calls survive in assembly. Candidate workers also retain a 2,048-byte stack scratch area and register save/restore around those calls. The count-zero constructor returns an immediate packed term; **these are call, arity-check and sink costs, not Unit heap allocations**. In the probe's uniform 16-input cycles, the linear chains visit an average 7.5625 roles comparisons and 7.1875 binary comparisons. Thus they execute respectively 15.125 and 14.375 extra constructor/sink calls per dispatch. These counts describe the source paths; they are not a measured attribution of elapsed time. The shared selector workers inline this same candidate sequence, so the costs remain on the measured path.

This is a recurrence of the documented Phase131 follow-on, [“keep prepared nullary constants through expansion”](../phase131/safe-codegen.md#follow-on-keep-prepared-nullary-constants-through-expansion), not a new discovery. Current [`nbc_definition`](../../selfhost/src/back/native/closed-match.bend#L109) still admits expansion through `nc_source_body`, while [`p112s_prepare`](../../selfhost/src/back/qbe/static-data.bend#L206) creates authenticated `NativeStaticBody` facts. Expansion can therefore recreate a raw Unit after static preparation. [`p114p_constructor`](../../selfhost/src/back/qbe/region-emission.bend#L37) specializes one-field constructors and sends the zero-field case to the ordinary runtime constructor; [`p111_partition_step`](../../selfhost/src/back/qbe/lower.bend#L369) emits the unused-value sink. The inspected maintained path has no general verified nullary-constructor/sink elimination that removes this sequence. Phase131's `selector-static-v03.bend` was explicitly an **unqualified** proposal to preserve authenticated packed-nullary, zero-payload facts through expansion; its restrictions and qualification work remain necessary. Arbitrarily deleting calls by runtime symbol or numeric constructor ID would not establish equivalent behavior.

The separate [dispatch-direct.bend](../../implementation/phase151/evidence/README.md) tests a source-level capability workaround. It passes computed predicates to finite helpers that match Bool parameters and directly return a value or call the next helper; no Unit thunk lies on either table path. A `tag < 12` guard protects roles leaves. Wrapped `(id - 26) < 10` accepts exactly binary IDs 26–35 and rejects underflow/high-bit aliases. Balanced subdivisions use at most five comparisons including the guard, with one comparison for out-of-range fallbacks. The public argument quantities and safety annotations match the originals, and every binary helper stays safe. Helpers are ordered before callers to satisfy safe forward-reference checking. The probe-only chooser remains available for unchanged consumers.

This alternative expands two small tables to 134 lines / 27 declarations, so it is a **capability experiment**, not a production recommendation. First require exact existing controls and inspect disappearance of constructor/sink calls; then charge acquisition, generated size and paired runtime. A general compiler fix would need the Phase131 admission/authentication obligations and compiler-cost accounting rather than multiplying source helper tables. This audit ran no compiler targets or benchmarks and made no production edits.
