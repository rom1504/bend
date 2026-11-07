# After the indexed-store falsifier: optimize a complete ownership boundary

Independent source/evidence assessment at `be1b798`, with current Phase173
experimental files inspected. No compiler targets or new measurements were run
for this note. The recommendation is **not to migrate the compiler into this
store yet**. Preserve the useful execution fixes, and next test a complete
producer/consumer on the representation the compiler already produces.

## What the experiment established

The initial store was2.003× slower. Fixing bounded tail components and the
boxed-to-flat argument boundary makes import, export, references and compaction
direct. Direct destination construction then reaches91.048ms against78.806ms
for the original KTerm computation, still1.155× slower. The complete962,601-byte
outputs match an independent oracle. See
[`abi-direct-store-pair03/report.json`](../../selfhost/build/phase173/abi-direct-store-pair03/report.json).

This rejects “dense indexes alone make this computation faster.” It does not
reject durable IDs across several consumers. Nor does it prove conversions are
the remaining bottleneck. The direct-destination result includes input creation,
import, compaction, frames, ownership, input validation, printing and teardown.
It does not export an output graph: it constructs the required KTerm directly.

The indexed-output candidate took93.690ms in its own paired experiment. Removing
45,139 output-store writes and135,417 subsequent logical reads therefore yielded
only a modest difference between the observed candidate clocks. These counts
are not runtime allocations, and the two experiments do not isolate every
machine-layout effect. They are strong reason not to forecast gains from node
counts alone. The later known-tag dispatch comparison separately saves3.45% of
the indexed candidate's whole runtime; it is not a new original-KTerm comparison.

Remaining structural costs are visible in source:

- Import duplicates observable tree occurrences; it does not preserve the
  original graph's pointer sharing. The original KTerm graph remains live.
- Native arrays already have constant-time reads. Reading `Array<P173Node>`
  still returns an owned record, including its shape/payload references.
- A shallow Tuple result can still contain a boxed Store. Flattening a Store
  argument can merely move its take to the next helper rather than remove it.
- Explicit worklists and an extra independent store scan are real extra work.
  Eliminating scheduler transitions does not eliminate these costs.

## Conversion ceiling: what can and cannot be inferred

Let the existing complete chain cost `F + sum(k_i)`, and an indexed chain cost
`F + I + V + E + A + sum(s_i)`. `F` is common setup/output, `I/E` import/final
export, `V` store validation, and `A` extra ownership/frame/adaptation work.
Reuse pays only when `sum(k_i - s_i) > I + V + E + A`. Repeating the same pass
artificially is not evidence that the selected compiler has that reuse.

For the measured91.048/78.806ms pair, eliminating boundaries alone would need
to remove **at least12.242ms,13.45% of the candidate, just to tie**. A2× reduction
of the complete original pilot needs51.645ms,56.72% of the candidate. Neither
has been attributed to conversions. There is no defensible measured
conversion-only speedup estimate, and no measured break-even number of passes.
The common output cost also prevents extrapolating these ratios to pass-only
cost or a full self-build.

A durable graph could win if its producer writes IDs directly and enough real
consumers remain in that graph. But zero import/export would then require moving
their producers/consumers, not omitting costs from a benchmark. Keeping the
current owned-node reader would still leave repeated input-ownership work.

## One cheap composed-store decision, if needed

The actual adjacent chain is
[`p112s_defs`](../../selfhost/src/back/qbe/static-data.bend):
`nc_compact(nc_definition(...)) → p112s_term → NativeStaticBody/static image`.
Unlike repeated synthetic reference scans, these are successive real passes.
An indexed alternative could import once, compact IDs, perform static discovery
on IDs, and export the final body once. Preserve the original erased fact:
`p112s_def_step` deliberately retains it for later observers.

Compare three complete products: unchanged chain; directly fused KTerm chain;
indexed chain. Require complete static image, body, error and ordering equality,
then exact final QBE. A separate diagnostic boundary breakdown should charge
import, consumers, final export, validation and teardown. Do not use precomputed
indexed literals as the end-to-end candidate; they only establish an explicitly
labelled conversion-free ceiling. No broad image acquisition is needed.

However, the entire static-preparation region was only about4.13s in the retained
Phase171 diagnostic. Even deleting all of it cannot explain181→100s. I would
only run this if settling store amortization is itself the next decision; it is
not the primary cold-build breakthrough project.

## Preferred minimum alternative: publish an erased closure in one computation

Target the actual
[`p143nr_visit`](../../selfhost/src/core/query-ownership.bend) computation:
`checked annotated definition → nc_definition_plain/nc_erase → nc_refs →
NativeErasedBody + ordered dependency worklist`. This already has a complete
oracle boundary in
[`p173v_erasure`](../../selfhost/tests/phase173/vertical.bend). It is a compiler
computation, not a replacement getter or a cache.

The smallest alternative retains KTerm and produces the final erased body plus
ordered references together. Match each input constructor once, carry its fields
through that whole transformation, and construct only the required output.
Collect dependencies during construction instead of walking the completed tree
again; do not add an indexed import/export. The final erased tree is required by
the existing compiler, so reference fusion alone does **not** eliminate its
allocation. Keep the annotated source book and its retained
aliases unchanged. Preserve definition order, duplicate reference occurrences,
dead-argument elimination, constructor identities, all required metadata and
the exact first diagnostic behavior.

This is more than attaching a counter to `nc_refs`: the producer owns dependency
publication. References must be collected from **surviving erased output**, not
from annotations, dead arguments or discarded terms. Native/foreign definition
construction and dependent telescopes retain their existing checked semantics.
`nc_erase_args` currently substitutes the original argument into the dependent
telescope before recurring; fusing the result must not substitute its erased
replacement. `wnf`/`subst` remain unchanged initially and their costs stay charged.

The first Bend implementation should use a consuming whole-tree transducer,
with no independent projection calls that repeatedly reacquire the same record.
This removes conversion entirely and can reduce repeated ownership of an input
record; it does **not** make all shared-child retention free. The source book
still owns those children, and the runtime must retain any field published in
the output. Actual machine code must establish the savings.

If that complete computation remains ownership-bound, the coherent next compiler
capability is a **constructive borrowed region over existing immutable KTerm**:
retain its root for the whole traversal; read descendants without intermediate
owning shells; retain each borrowed field once when publishing it into an owned
result. Owned temporary outputs from normalization remain separately owned.
Unknown calls, mutation, escape or unproved lifetime use the old path. This needs
a checked lifetime/escape plan and independently audited lowering; it is not a
feature already provided merely by a `+` source annotation. It generalizes the
existing observer idea to an allocating consumer without a new semantic store.

## Decisive gate and honest headroom

1. From the authenticated checked request, extract the actual annotated book and
   exact existing NR_Closure result. Use the real verifier and an unrelated
   constructor-heavy source; include erased dependent arguments and aliases.
2. Establish complete erasure/closure time before implementation, separate from
   printing and transport. If it is a small fraction of the request, reject it
   as the primary speed project rather than expanding the rewrite.
3. Test the consuming producer directly against every closure field, not a
   digest. Inspect/count eliminated second traversals and actual ownership
   calls. Charge unchanged normalization, substitution and book access.
4. Require a material complete-consumer win and transfer before a full compiler
   acquisition. The ordinary final verifier and exact whole-request QBE gate
   remain. Neither the source `law` signature nor N1/N2 agreement proves this
   transformation correct.

The full post-check frontend interval was18.281 diagnostic seconds; erasure and
dependency publication are only part of that. Deleting the entire interval is
an approximately10% ceiling relative to the180.677s clean total, **not a forecast
or an exactly additive timing comparison**. Halving that interval is a9.14s
scenario; this candidate cannot honestly promise it before attribution. Its
value is testing a reusable ownership/producer boundary that can later transfer
to annotation, substitution and optimizer transforms, not claiming a hidden80s.

Stop adding getters, node-layout variants or consumer ports solely to rescue the
store. Phase171's highly admitted borrowed selector gave only1.25% on the real
verifier; Phase172's deferred substitutions were neutral. Keep those negatives.
The demonstrated immediate research-loop gain is separate: complete checked-plan
binary replay preserves exact QBE while avoiding about38s of repeated hosted
work in the observed request. Use that to test larger backend hypotheses, while
retaining full preparation in every cold-build measurement.
