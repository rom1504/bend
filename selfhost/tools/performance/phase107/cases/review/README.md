# Independent source boundary probes

These are source-level probes, separate from constructed IR. Before counting a
negative result as useful, establish that source checking succeeds and rejection
comes from the deliberately narrow experimental lowerer.

| Source | Expected boundary |
| --- | --- |
| erased_local | Accept; erased Nat.add is never lowered/evaluated; result n+seed modulo2^32 |
| erased_function | Accept; erased lambda is never lowered; result n |
| refuse_higher_order | Checked source, refuse live higher-order argument |
| refuse_box | Checked source, refuse custom constructor/projection representation |
| refuse_named_u32 | Checked source, refuse non-native type despite spelling U32 |
| refuse_bool_entry | Checked source; selecting bench refuses live Bool at the external integer ABI |
| default_bool_arm | Coverage probe: accept with min(n,seed), or explicitly refuse fallback matching |

The wildcard arm's checked-core representation is deliberately not assumed in
advance. Acceptance needs both branches checked against the independent answer;
refusal identifies a coverage limitation. The other classifications are proposed
test expectations, not execution results. Root schedules capture/lowering and
records actual outcomes separately.
