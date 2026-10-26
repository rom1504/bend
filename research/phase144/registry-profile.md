# What the18-second registry interval actually does

The measured `p134e_begin`→`p134e_registered` interval is18.184 diagnostic
seconds, with566 interior samples after edge exclusion. It is not only a name
map or a function-table construction. Exact evidence: [registry-profile.json](registry-profile.json).

In the actual executing source `p134e_prepare` (57375) builds IDs and a fusion
index, prepares tables, then calls `p112c_index_with` (43512). That calls
`p112c_passes(...,1,6)`, constructing the legacy region registry through bounded
continuation-fusion passes. `p112c_add` (43457) tests readiness, rescans a body,
tries fusion and admits/freezes a new worker plan. Thus part of optimization and
worker discovery occurs after the earlier nominal optimizer stage.

The active-owner observations are:

- String equality74, append66 and `U32.show`8:148/566 (26.1%).
- `p112w_ready`33, `p111v_get`32, `p131i_insert`5:70/566 (12.4%).
- `p112r_buffer_sites`37 and `p112r_buffer`14 are visible inside region-body work.
- `p118z_runtime`33 and `p112t_runtime_call`19 expose runtime-signature predicates.
- Physical `term_drop`78 plus `span_fade`46:124/566 (21.9%). This overlaps the
  active owners and must not be added as another independent share.

There is no evidence that maps alone dominate this interval. Naming/text work,
repeated region scans, worker admission and memory management all contribute.
The sample supports a narrow concrete experiment: `p112r_buffer_sites` (43022)
repeatedly constructs `"p112f_" ++ U32.show(index) ++ "_local_scratch"` while
checking at most eight scratch-site names. `p112r_buffer` (43028) invokes this
inside body scans. A checked allocation-free predicate for this exact bounded
name grammar—or a representation retaining the scratch-site identity—could
remove construction plus comparison. It must preserve exact accepted strings,
site bounds and ordinary fallback. No measured fraction assigns all generic
String samples to this predicate, so the entire26.1% naming share is not its
promised gain.

A broader investigation is to retain verified region/worker decisions from the
preceding lowering/optimization path rather than rediscover them while preparing
emission. First establish whether the bodies and ready sets are actually equal;
reusing similar-looking decisions across changed ready contexts is not safe.
The observed passes are real work, but an earlier analysis may not have the
information needed to replace them.

The source/IR boundary matters more than the name “registry”: this is another
place where semantic planning and final emission remain interleaved. The stage
profile now gives it an explicit budget and a fast, falsifiable local target.
