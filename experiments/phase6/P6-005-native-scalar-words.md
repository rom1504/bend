# P6-005 — Inline proven native scalar constructor words

Preregistered 2026-09-23T05:12:19.754621+00:00, following campaign design commit `2815fa1`.
Owner: conformance_options. Root owns independent review, timing allocation,
integration and promotion. Status: proposed isolated candidate; no measurements.

## Hypothesis and invariant

`nc_compact` already converts fully recognized U32/F32/Nat literals into private
`NWord` nodes. `nc_sequence` nevertheless gives every constructor field a Let
continuation. Retaining proven immediate words directly in the `NCtr` argument
list should remove the measured quadratic live-prefix copying for literal-rich
records. Extend `nc_values` to print these words exactly as `nc_lower_live` does.

The fast path applies only to an `NCtr` sequence child whose tag is `NWord`.
It does not optimize NCall sequencing, references, applications, arbitrary
constructors, foreign calls, or nonliteral words. Still advance the fresh counter
for each original field, preserving reserved temporary identities. Nonliteral
children retain their original nested Let order. A compiler-created NWord has
no evaluation effect, ownership allocation, reference or possible source error;
the ordinary constructor allocator, packed/unpacked representation, disposal and
sequential/task continuations for other children are unchanged. This is an
internal checked-compaction invariant, not a new malformed-private-IR contract.

Stop on changed accepted/rejected classification, output, error order, affine
ownership behavior, or failed checked build. Reject promotion if the large-record
case retains the quadratic literal continuation chain or if representative
nonliteral code regresses. Do not infer whole-source compiler speed from this
independent native backend change.

## Plan and resource bounds

1. Copy the complete current compiler into a disposable project under
   `selfhost/build/phase6/campaign/native`; patch only `back/native/bridge.bend`.
   Record the original module identities and exact patch. Build a genuine checked
   B1 plus the maintained equality derivative, using the pinned TS checkout,
   unchanged host/runtime/Base and maintained development workflow.
2. CPU3 correctness work, Node24.18, 4 MiB stack, 4 GiB heap. All jobs have finite
   outer bounds; build/selected gate at most 5 minutes. Different agents may run
   correctness concurrently, so none of these elapsed times is controlled.
3. Emit checked 32/64/128/255-field variants before invoking Clang. Record C bytes,
   segments, literal continuation bodies and register width. Use 90 seconds per
   emission and at most 6 minutes for the ladder. Compare with frozen final05
   source and retained baseline emissions; inherited sizes are not new timings.
4. Test mixed literal/nonliteral fields, unused fields, nested and shared affine
   records, packed and multi-field constructors, U32/F32/Nat boundaries, and a
   parallel path. Exercise actual JS and native output against fresh pinned TS.
   Preserve 255 accepted / 256 refused arity behavior. Test relevant runtime
   failures at earlier/later argument positions without treating a common crash
   or missing toolchain as a pass. Native binaries run with one and four threads.
5. Before Clang, inspect emitted size. Candidate C above 1 MB gets a separate
   bounded review; otherwise use at most 60 seconds build and 10 seconds/runtime
   per case, with a finite batch deadline. No GPU coverage is claimed.
6. Root reviews independent controls before any source promotion or controlled
   timings. Compiler emission, C size, native toolchain wall and generated-program
   execution remain separate outcomes.

The first mechanism checkpoint is due within 15 minutes; aim for a bounded
working candidate by 06:15 UTC. The campaign ends by 15:06:12 UTC. The prospective
size/speed estimates are hypotheses: 80–94% less C on the pathological record;
2–5× faster emission there; no guaranteed gain on whole-source JS compilation.
The inspected narrow rule may require only about 10 source lines, rather than
the earlier 80–200-line estimate.

## Evidence and outcome

Plans, complete inputs, fixtures, commands, successes and failed attempts will
be retained under the owned experiment directory and summarized in
`implementation/phase6/native-scalar-words.md`. Generated candidate artifacts
stay separate from the default release. This preregistered record remains an
input; actual outcomes belong in that report.
