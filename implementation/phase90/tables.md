# Phase90 native table-builder candidate

The longer self capture reveals a different late cost from the first minute.
At120–180 s,3,747 of3,749 samples are String.append, its continuation or rfc_wrap
(99.95%). One recovered `span_fade` return site is in `NB_SEG_IDS_GO` at
`0x47e2bf`. The exact unchanged source contains five table loops that append each
new row to an ever-growing String accumulator. That supplies a concrete scaling
hypothesis; physical stacks do not prove that every append sample belongs to
that one loop.

**The overall capture is rejected.** The sampler recorded11,250 samples with no
loss, and its local reader produced windows, but
[`late-self01/report.json`](../../selfhost/build/phase90/late-self01/report.json)
has complete:false, diagnosticUsable:false and inputsUnchanged:false. Root edited
canonical `static.bend` while it ran. The exact executed native binary and frozen
input remained unchanged; the enclosing admission still fails and is not relabeled.
Use this only as an exploratory lead, followed by clean independent controls.

The relevant source path is `nr_compile_prepared` → native compilation/finish →
`ne_program_runtime` → `nb_emit`. `ne_program_runtime` builds the runtime payloads
from tables/show text, static image/declarations, segment bodies and effects.
`nb_emit` combines segment IDs, constructor IDs, register macros, arity/flag/result
tables and dispatch entries. Five helpers have the same repeated-prefix pattern:
`nb_seg_ids_go`, `nb_arities_go`, `nb_result_words_go`, `nb_flags_go` and
`nb_dispatch_go`. This is separate from the root's static-image/list stack repairs.

The isolated [candidate and controls](../../selfhost/tools/performance/phase90/tables/README.md)
replace each growing String with reversed row chunks, flattened once by the
existing `nt_text_finish`. Each public `_go` preserves its original accumulator,
index, row order and exact suffix. For row lengths L₁…Lₙ and prefix P, the old
builder repeatedly copies earlier prefixes; the new accumulator copies each row
and P once when finishing. Shared-input ownership costs remain and a faster full
request is not established by this source argument alone.

The exact tiny fixture covers six inputs and108 full String observations against
original functions and an independent codepoint oracle. Its first acquisition
failed before code generation because the fixture omitted the real declaration
for law-filling `nc_ctor_codes`; the original source/report are preserved. V2 adds
that exact law and leaves observations/function bodies unchanged. Root's V2 gate
now passes: acquisition2.125 s and Clang1.723 s; JS/native stdout is exactly
identical (22,071 bytes, SHA256
`01736d1a1e4a5018f9b2a74673ceb1bda557cfcba6ca2586eab2cfbc4fbce98a`).
All108 observations and5,338 codepoint/length words match the independent oracle.
The [comparison receipt](../../selfhost/build/phase90/tables-control02/comparison.json)
has SHA256 `c26ae71dc848ad3e6bfa62a4777152c6615cc7c0f2e6f4ebac267d583d1ebf02`;
the [checked acquisition](../../selfhost/build/phase90/tables-control02/report.json)
has SHA256 `f76189f2b01abac12e5829bb2b4f5758db16351def92bb063d788d17bfb64e38`.
These are bounded correctness controls, not a performance gain. Root owns all
target executions; this lane ran none.

Two frozen native sources are available. Tables-only0431ecd5… changes only the
five original builder definitions plus helpers. Combined74b390d3… also carries
root's five canonical tail-loop fixes and helpers from static/flat/observer
integration. Ten explicit replacements replay and reverse against original
native source4584cf08… byte-for-byte. Only two exact String.eq tokens in inserted
canonical functions become the already-qualified native p88 helper. Existing
Phase89 owned/chunk work is preserved; no wholesale module replacement occurs.

Production and release decisions remain separate: fully check the combined Bend
source, compare tiny and whole emitted outputs, establish native self-emission,
then verify ordinary JS behavior and speed before sharing the table change with
the canonical compiler. No speedup, native-B2 correctness or default promotion
is claimed by this preparation report.

The table-only candidate changes five original definitions and adds five private
chunk helpers; definitions outside those replacements remain byte-identical.
It preserves every original row/suffix expression, initial accumulator, index
increment and dispatch order. That is an exact source transformation argument,
backed by the 108 observations, rather than a proof over all possible inputs.
Whole emitted C equality is still the relevant integration gate. The combined
native candidate includes independent canonical stack repairs, so any observed
full-run speed gain cannot be attributed solely to these five table changes.
Before canonical promotion, obtain ordinary JS/B2 full-output equality and a
bounded compilation-speed screen: linked-string asymptotics do not by themselves
predict the cost of V8 strings and additional chunk-list allocation.
