# Remaining opportunities after Phase102

This supersedes the [initial candidate audit](next-opportunities-initial.md).
The frozen final source is `b3927732…902d1f`,39,370 physical lines. Observer
result projection, bounded compositional inlining and eligibility filtering
were implemented during this campaign; they are no longer untested suggestions.
Native qualification and final runtime receipts belong in [the report](README.md).

## 1. Reuse retained aggregate observations

Bring Phase99's existing `nob_*`/`nog_*` aggregate-root work into the composed
worker plan, starting with scalar-only results. Previous compiler profiles found
KDef/KTerm projections and equality boundaries expensive. The final compiler
has substantially different call paths, so refresh its unchanged-binary profile
before assigning a percentage gain. Reuse existing nested alias, Unicode and
full-field controls. Root ancestry, retained lifetime, opaque fields and raw
provider authority are the main correctness boundaries; escaping children need
a separate rule.

## 2. Remove repeated eligibility scans

`nd_comb_fresh` still repeats a body/actual/environment scan for reserved IDs.
Phase99 already has a single-interval scan and 44 differential cases. This is a
small, general compiler-speed experiment: preserve first-binding, malformed
Var, reversed ID numbering and overflow behavior; require exact emitted C and
measure a branch-heavy request before rebuilding the compiler. Phase102 already
hoists the inline size/admission predicate out of three dependency rounds.
These two changes must not be conflated.

## 3. Close the dynamic-call boundary, then shrink the scheduler

The [scheduler survey](scheduler-pruning-investigation.md) finds 11,629 of 20,991
cases without a literal-FID host path in its diagnostic model, about 4.16 MB of
text. This is an opportunity estimate, not permission to delete them. Foreign
and numeric callable IDs, closure/static-data/task producers, stable FID table
positions and device paths need a complete reachability boundary. Start by
recording post-lowering callable construction edges. A sound conservative
closure could reduce C/Clang cost without touching application algorithms.

## 4. Generalize composition through the existing IR

The scalar observer-projection pass proves one bounded composition using the
existing schema and owned cleanup. Study other product consumers that become
ready after observer routing, then retry existing product lowering where its
preconditions apply. Avoid accumulating independent shortcuts with overlapping
ownership rules. The successful pattern is to make current analyses available
to one another; it does not establish that every composition is safe to fuse.

## 5. Explain the remaining parallel renderer gap

The final production renderer screen is 0.988× upstream with one worker and
1.129× with four. It is faster than installed Phase98 at both sizes, and uses
less memory. Inspect task size, allocation balance and output joins using the
existing 1/2/4-worker fixtures before changing granularity. A one-round broad
fixture timing is not enough to rank small scheduling changes.

## Efficient next iteration

Select one causal question from a current profile. Use the retained source/API
and exact saved products for a short ablation; preserve complete outputs and
negative controls. Measure the relevant application plus one regression case,
then the six large app points. Only a retained source earns native image
construction and the wider 45-program runtime check. Exact C identity permits
binary reuse with original build provenance; it never creates fresh timing data.

Keep whole-workflow clocks separate: compiler request time, Clang image build,
application runtime and harness acquisition. The bounded-inlining failure and
cold-list regression show why a locally good transformation needs a broad
check, but neither justifies repeating the entire release gate after every edit.
