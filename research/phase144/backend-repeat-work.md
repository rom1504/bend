# Bounded backend repeated-work investigation

The **actual second range-pass census has passed** on Lexer, Map and closures.
The root executed the checked compiler stages; this investigation only prepared
and analyzed them. No pass has been removed. The result narrows the opportunity:
69 of72 outer calls are unchanged, but only37 have an unchanged inner input.

## Measured context and limits

The authenticated Phase143 stage profile gives44.631 diagnostic seconds for
raw generic/private lowering,41.635 for initial optimization,22.396 for the
following independent verifier,24.219 for observer composition/final admission,
18.284 for registry preparation and51.845 for rendering/output. These are
entry intervals, including continuations and reclamation, not isolated helper
costs. See [stage-profile.md](stage-profile.md).

In the initial optimizer interval, `p111v_get` has220/1,299 samples,
`p113k_get`117 and `p131i_insert`105. These are disjoint active-owner labels,
but do not identify caller origins or divide the interval into inline versus
range work. In particular, they do not prove that the entire41.635s is range
analysis. Eliminating the whole interval would remove only12.6% of this330.6s
diagnostic request; the proposed experiment can remove at most part of it.

The integrated candidate's separate clean266.86s versus fresh parent304.53s
observation, reported by the root, must not be used as the denominator for these
older diagnostic component times. This investigation establishes no new native
speed measurement.

## Exact repeated transformation

The frozen integrated source is
`selfhost/build/phase144/integrated-source01/compiler.bend`, SHA-256
`992893e6cf6a5bf7d6d092812b3a5da20852feca882005f32a91e607cef0483b`.

1. `p113i_function_done` calls `p113k_function` after successful inline scanning
   and the16,384-byte stack bound (lines46439–46443).
2. `p128raw_session_finish` calls the committed inline stage and then
   `p114s_ranges_lowered` (55991), whose `p114s_ranges` applies
   `p113k_functions` to the whole current list (48303).
3. `p113k_function` analyzes only bodies with `p113i_size(body)<4096` (47703).
   A large-body hit can save only a size walk, so a count of repeated functions
   is not a useful gain estimate without their sizes and execution costs.
4. Range facts use persistent indexes and epochs. `p113k_put` constructs a
   nine-field record plus two term records and queries the previous epoch;
   joins query records and rebuild a merged fact map. The second pass starts
   those facts afresh. This gives a concrete category of work to eliminate.

This is a rediscovered seam, **not a new optimization result**. Phase134 already
tried retaining exact inner `(input, output)` memos and comparing outer inputs.
That design was not selected because retention, comparison and cleanup costs
outweighed its savings. Its source and negative evidence remain authoritative:
[range-reuse-audit.md](../../selfhost/tools/performance/phase134/compact/range-reuse-audit.md)
and [verification-reuse.md](../../implementation/phase134/reuse/verification-reuse.md).
The latter reported only1 changed outer function per Lexer/closures/Map request,
but outer no-change does not prove the inner transformation was also unchanged.

## Cheapest decisive experiment

`verifier/range-second-pass-v01.mjs` uses checked Bend to execute the actual raw
lowering, `p114s_open`, `p114s_inline`, outer `p113k_functions`, original
`p134v_commit` and independent `p113e_verify`. It compares complete functions,
not hashes or statement counts. Every changed function and the complete before/
after products are retained as bounded graph snapshots.

The optional existing `p134rk_functions` export replays the old instrumentation
only to observe exact inner inputs and outputs. Its cost is reported separately;
this is not a proposed runtime cache. The census records:

- Total and changed functions, complete first mismatch, and full retained data.
- Direct/scalar node counts, calls and branches before/after.
- Whether the instrumented inline candidate equals the actual committed result.
- Whether an inner range call occurred and whether its input equals its output.
- Whether the actual outer input equals the recorded **inner input** and, if so,
  whether the repeated output matches exactly.
- Outer transform/commit and independent-verifier hosted times separately.

If the replay equals the actual committed list, a changed outer function with
an executed inner call is a concrete counterexample to casually assuming range
idempotence. If many exact repeat inputs are large gated bodies, the opportunity
should be rejected early. If expensive analyzed bodies frequently repeat
unchanged, a producer-carried unchanged flag becomes worth a small experiment.

Root-only sequential jobs are pinned in
`selfhost/build/phase144/range-census-plan01/jobs.json`; the preparer is
`selfhost/tools/performance/phase144/verifier/prepare-range-census-v01.py`.
They check unchanged integrated source with10 explicit exports and run Lexer,
Map and closures under CPU3,3GiB RSS and a16GiB available-memory floor.
There is no existing retained full-compiler intermediate range product in the
inspected Phase144 artifacts, so none is claimed in this initial census.

## Possible smallest production follow-up, conditional on the census

Do not ship the Phase134 memo again. If the new census supports it, have the
range producer return a conservative `unchanged` Boolean while constructing its
normal result. This must mean exact equality of the complete function, not
“same number of statements” or “no familiar optimization fired.”

For fixed pure range implementation `F`, if the producer establishes `F(x)=x`,
then running `F` on that same output is redundant: `F(F(x))=F(x)`. This requires
no universal idempotence theorem. No original input graph or second equality
walk needs to be retained. Unknown or changed cases run the existing outer pass.

Carry the flag only through an **accepted** inline commit; an inline rejection
must clear it because the actual outer input can revert to another function.
Headers, list order, cleanliness, stack admission, inline-table publication and
the independent final verifier remain unchanged. Adding flags to the existing
range result records and their combinators could cost roughly150–250 lines of
coordinated edits; this is an implementation estimate, not an accepted design.
An arbitrary public Boolean is not proof evidence: only this closed, fixed
producer may create it. A source-connected equivalence contract and deliberately
false unchanged flags belong in the controls if implementation is justified.

## Other leads screened, not selected

- Registry preparation is not simply wasted map construction. It performs up
  to six legacy worker/fusion rounds. Some later entries render only a forwarder
  to an existing direct function (`p113e_old_private`), but their readiness also
  affects other workers. Skipping them without preserving those dependencies
  could change generated program quality. A forwarder count is not a proof that
  their entire preparation was unused.
- Generic Patricia insertion costs about12 sample-period seconds across the
  whole older residual profile. Faster insertion alone cannot supply a major
  whole-request gain, and index hashing, construction and destruction must be
  counted together.
- `p113k_join_record` does perform a second lookup of an already found right
  fact. Reusing the projected fields is a small exact cleanup, but current
  samples do not attribute enough time to joins to prioritize it over the
  complete repeated-pass falsifier.
- Raw generic lowering and private lowering both remain substantial. Avoiding
  generic bodies for verified direct workers could have a larger ceiling, but
  continuation identities, escaping dispatch references and fallback contracts
  make this a later cross-stage experiment rather than a cheap patch today.

## Executed census: narrower than the outer no-change count

The root's `selfhost/build/phase144/range-second-pass02/report.json` passes all
three requests, including complete committed replay equality, retained original
program/IDs, and the independent final direct verifier. The first runner failed
only in its host observer: `P113DScalar` stores its child as `stmt`, not `scalar`.
The failed receipt and runner remain unchanged; v02 changes that field access
alone and its derivation receipt records the difference.

| Request | Outer unchanged / all | Inner range executed | Inner unchanged / exact repeat | Exact repeated size / all size | Outer stage, hosted s |
| --- | ---: | ---: | ---: | ---: | ---: |
| Lexer |30/31|30|11|718/5,020 (14.3%)|0.84845|
| Map |33/34|33|23|632/1,320 (47.9%)|0.06432|
| Closures |6/7|6|3|8/223 (3.6%)|0.02604|

Sizes above reproduce `p113i_size` exactly from the retained graphs: a scalar
wrapper contributes its nested scalar statement size, direct branches include
both bodies, and totals saturate at4096. None of these72 functions reaches the
4096 size gate. The source-pinned, target-free analysis is
`selfhost/build/phase144/range-second-pass02-size-analysis.json`.

Each changed outer function is an SCC worker (`$p126scc.30`, `.70`, `.4`) that
**did not execute the inner range pass**. Its first recorded difference changes
an operation statement into a constant. No observed function contradicts
idempotence, but these finite observations do not establish idempotence. In
particular,32 inner calls changed their input; an honest producer-unchanged flag
cannot skip those subsequent calls merely because their observed outer output
happened to be unchanged.

Even removing the entire measured outer stage would save at most its recorded
0.848/0.064/0.026s in these hosted runs. Those are13.9%,1.1%,3.7% of the sampled
frontend-through-verifier intervals, excluding diagnostic replay; they are
**not complete compilation or native cost fractions**. Assuming cost scales
with the exact node counts would illustrate only0.121/0.031/0.00093s for the
safe repeat subset. This is not a measured gain or a rigorous per-body ceiling:
fact-map sizes, branches, calls, JIT and reclamation change unit costs.

**Decision:** defer producer-flag plumbing rather than infer a major gain from
the69 unchanged outputs. The potential150–250-line change needs a native
compiler-hot range observation before implementation. Do not restore the
previously rejected deep-equality memo. The evidence remains useful if a later
range refactor can produce an exact unchanged fact almost for free.
