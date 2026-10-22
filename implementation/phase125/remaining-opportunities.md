# Remaining opportunities after owned composition

The broad score is1.89221× upstream, but40/44 timed cases still exceed1.1× and24
exceed2×. The three ray cases account for4664/17531ms (26.60%) of positive excess time.
Mean positive log-slowdown0.89500 is a more useful deficit diagnostic
than optimizing the already unusually fast four cases. The changes in this phase
remove real work without materially changing that distribution.

## 1. Carry a private producer destination through composition

This phase's direct result ABI and runtime-check removal are not sufficient.
RLE's source-level repeat-into-tail ceiling is18.0% faster, while the final automatic
composition improves5.49%. Both eliminate six reconstructed cells; the ceiling
also avoids producer destination work and a later ownership walk. That is evidence
of a missing composition capability, not evidence for another helper variant.

This is the cheapest strongly motivated composition experiment, not a promise
of the largest broad gain. The smallest next experiment should start from a checked pure producer whose
fresh tail destination is already known. Carry that destination privately through
the local resume, along with its owning result. The consumer may attach a suffix
without rediscovering ownership only while the destination has not escaped,
been aliased, or crossed an effect/publication boundary. Unknown paths retain the
existing worker. Preserve source evaluation order; a changed-source ceiling that
reorders work is not a proof of automatic legality.

Compare original, source ceiling, runtime scan and carried destination on RLE and
the varying-value map/append transfer. Count actual constructors/takes/extends and
inspect machine code before another broad campaign. Then test a real compiler
string/list builder. The compiler's current reverse/reverse `nt_append` does not
match this phase's structural append certificate; it requires a separate proof.

The observed18% RLE ceiling bounds this particular source variant, not all possible
optimizations. No measured global gain or implementation time follows from it.

## 2. Preserve matched layouts and virtual product fields

The current verifier proves construction metadata but not the actual shape of a
take operand. Consequently, the new take ABI deliberately retains those checks.
Do not remove them based on a frequently matching benchmark. A control-flow-bound
constructor witness could both justify direct field access and enable virtual
products across helper/resume boundaries.

Start with a product already created and matched inside a closed region. Keep
field ownership, use counts, evaluation order and escape/materialization boundaries
explicit. Test nested/shared products and transfer to BST or tree reconstruction.
Do not revive generic cell credits or infer uniqueness merely from a tag match.
The previous explicit-state RLE ceilings were modest; a wider representation
change needs stronger source and dynamic evidence before implementation.

## 3. Persistent typed F32 calls and loop state

The Phase122 profile found88.5% of active-ray samples inside private workers and
11.5% in generic primitive dispatch, with repeated integer/float transfers and no
sampled global scheduler. Local helper cleanup is therefore unlikely to close
its much larger deficit. Retain F32 representation through calls and backedges,
with explicit boundary adapters and unchanged rounding/NaN/signed-zero behavior.

This has the largest measured family deficit; give it priority if the private
destination prototype cannot quickly demonstrate broader transfer. First compare
integer ABI, typed ABI only, and typed loops on the exact intersection
and nearest computations, plus an unrelated recurrence. Upstream's packed
arithmetic is a separate capability: mature self-hosted C was still3.41× upstream
in the earlier diagnostic. Matching its scalar lowering alone is not a parity
argument. Reuse the Phase122 frozen code/profile evidence before collecting more.

## What to stop or defer

- Stop spending repeated full campaigns on a one-percent helper adjustment.
- Do not use static refusal/site counts as a runtime priority list.
- Do not retune the four already-fast cases to improve only the geometric mean.
- Keep broad native qualification at integration boundaries, not per prototype.
- Defer additional backends and an autonomous policy-search framework until a
  new useful transformation or a cheaper complete experiment is demonstrated.

Parity needs more categories of work to disappear. The next design should state
which information survives longer, what work it eliminates, the exact correctness
obligation, and a cheap rejection criterion before expanding the compiler.
