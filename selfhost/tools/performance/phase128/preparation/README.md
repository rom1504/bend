# Phase128: skip guaranteed-unused late flat lowering

Status: implemented Bend overlay; independent checked acquisition, exact-output
comparison and performance measurements belong to the coordinating agent's
single resource lane. This directory does not claim a measured improvement.

The experiment targets the Map-specific repeated native lowering measured in
[P127-003](../../../../../experiments/phase127/P127-003-repeated-lowering.md).
It removes a subset of the repeated candidate lowering. It does **not** remove
the second `p112s_prepare`, signature derivation or the boxed candidate bundles.

## Parent and assembly

Start from `selfhost/build/phase127/live-bank-source01/compiler.bend`, SHA256
`f4eb3c6b8aca8cdfc72c8eb308db83af50c6bee888a93b69415a77aa5101318d`.
This is Phase126 selected source32 plus Phase127's audited runtime-admission
repair; it is not the excluded source33 optimizer experiment.

Use the existing exact declaration composer from
`selfhost/tools/performance/phase126/prepare.py` as an imported utility:

```python
composed, added, protected = compose(
    parent_text,
    [Path("selfhost/tools/performance/phase128/preparation/late-flat.bend").read_text(),
     Path("selfhost/tools/performance/phase128/preparation/controls.bend").read_text()],
    {"p126bp_close"}, set())
```

Authenticate the parent hash, pin both module hashes and place the result in a
fresh Phase128 build directory using the root's acquisition workflow. Do not
invoke that Phase126 script's CLI: its CLI intentionally selects Phase125.
The only existing declaration replaced is `p126bp_close`. Export
`p128prep_controls` from the checked API; twelve rows must end in `:pass`.
`p128prep_flat_needed(info, ready)` is also available for focused admission
controls. No new runtime helper, target lowering rule or source-name special
case is introduced.

## Why the skipped work cannot affect final QBE

The existing late path reconstructs every candidate, then
`p113d_pass_function` drops a candidate when its name is already `P113Direct`
in the merged ready index. That branch precedes dependency checking and does
not change functions, the ready index, the waiting list or the admitted count.

`p113pl_flat_candidate` emits exactly one function. Its symbol is always
`nm(dv(lookup(signatures, name)))`; see `p113pl_flat_entry` and
`p113pl_candidate_code`. The new enumerator checks exactly that symbol with
the unchanged `p113d_ready`. If it was ready before the first pass, it remains
ready throughout dependency closure. Removing this candidate therefore leaves
every pass state and termination decision unchanged, including admission order.
Fresh names are local to each flat factory, so skipped lowering cannot advance
a shared numbering counter.

The proof does not require a valid discarded body: both successful candidates
and candidates with lowering errors or unresolved dependencies would have been
dropped. It does require that the candidate's **exact generated symbol** is
ready. Merely finding its source name, public wrapper or a non-direct record is
insufficient. The finite controls cover those distinctions, exact private-QBE
equality with a different discarded body, an invalid discarded body, a forward
dependency and an unresolved dependency. They also check that the independent
function verifier still rejects an invalid retained signature.

The source checks, full source-name list, bang/signature derivation, boxed
factory bundle and candidate order are unchanged. `p113d_passes` still receives
the same ready index, reversed merged functions and fuel32.
`p126bp_complete` still invokes `p118b_verify_functions`,
`p113a_verify_after`, `p114t_verify_done` and the ordinary admitted emitter.
Preparation errors retain their exact diagnostic candidate path.

This is a source-level argument plus finite controls, not an empirical
whole-compiler equivalence result. Full QBE bytes must match on real requests.

## Decisive evaluation

1. Check the assembled compiler through the existing checked API acquisition.
   Run `p128prep_controls`; run existing Phase126 flat-observer controls and
   Phase127 transport controls unchanged.
2. Emit **complete QBE** from the parent and candidate on identical prepared
   requests, Base, runtime identity and source. Require exact byte equality on
   Map churn, a product-heavy record request and unaffected lexer/closures.
   Include a late-fusion/TRMC fixture if available: boxed bundles must survive.
3. Only after equality, compare paired complete hosted request cost. Existing
   program outputs and code quality are unchanged when emitted bytes match;
   no machine rebuild is necessary for the first cost screen.
4. A worthwhile hosted improvement justifies the parent's native acquisition
   and paired N1 request measurement. Report native separately from hosted.
   Source growth, extra ready-index lookup cost and full-compiler scale remain
   part of the decision. Do not automatically launch N1/N2 qualification.

The candidate performs one additional ready lookup for each eligible flat
signature in the late pass. It does no extra lookup in ordinary initial
lowering. Its benefit therefore depends on how many already-ready flat
factories would otherwise be lowered and how expensive those bodies are.
The Phase127 direct-entry counts do not give the inclusive saved fraction.

## Preserved negative evidence and boundaries

Phase126 source33 is **not** an earlier rejection of this skip. Its
`product-primitive/optimize-new.bend` reruns the existing inliner/range pass on
new late workers after closure, with a fallback to the unmodified closure.
It rewrote nine records workers and eight evening/Map workers; lexer and RLE
QBE stayed byte-identical. A separate five-case runtime screen differed by
about0.3%, without a directly interleaved causal pair. The extra machinery was
excluded for insufficient demonstrated benefit and source32 stayed selected.
See [the source33 ablation](../../../../../implementation/phase126/product-observer-report.md)
and [Phase126 conclusions](../../../../../implementation/phase126/README.md).
This overlay does not revive source33's optimization pass.

Skipping all boxed work because a public symbol is ready is rejected as an
equivalence argument. `p121f_selected` may produce stream or callback private
workers and `p118t_retry` may add a TRMC worker. A present public entry alone
does not show that those private symbols are already ready. The current
overlay preserves that entire factory, including its append-wrapper handling.

A possible next bounded extension is **complete bundle identity**: determine
which existing stream/callback factory applies, then skip only if every one
of its deterministic output symbols is ready. For generic/TRMC factories the
relevant outcome depends on lowering failure, so retain them unless a stronger
sound precondition is established. Do not add these analyses before the narrow
flat filter shows useful cost recovery. Reusing initial checked candidates or
prepared state could eliminate more work, but requires threading lifetime and
ownership through the pipeline; that larger change is deliberately deferred.
