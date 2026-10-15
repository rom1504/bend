# Phase95: attribute native ownership costs before optimizing

Baseline: `5544d3b`, pinned upstream `0592662`, installed Phase90 and frozen
native source D04. Phase94's proved environment fusion saved helper time but
did not materially change compilation. Keep that candidate unpromoted.

## Question and first discriminating measurement

Which compiler operations cause the native runtime's substantial reference-count
and cleanup work, and can a small general transformation remove enough of it
to improve real compilation without changing generated programs?

Reuse the Phase88 ownership sampler. Its executable-specific `.eh_frame` table
recovers bounded physical return addresses without rebuilding or modifying the
native compiler. Bind the table and preload to current native B1, and later B2
where it changes the decision. Existing IO clock marks delimit preparation and
request intervals. Musttail-erased logical callers remain unknown; do not present
physical return sites as a complete Bend call tree.

Start with five Map requests and exact complete-C checks. Then capture one
complete native self-compilation if the short control validates the method.
Use sufficient sampler capacity for the roughly140-second source request and
a bounded deadline/RSS guard. Preserve lost/overrun samples and failed analyses;
do not silently relax quality rules. A rejected capture can guide an explicitly
exploratory experiment but cannot supply an accepted timing or correctness claim.

## Candidate gate

Map dominant ownership sites back to exact generated C and Bend source. Distinguish
projection, shared traversal, eager closure disposal, string construction and
final result consumption. Sampling alone does not measure allocation counts or
prove time removable. Reuse prior research and rejected hypotheses before adding
an implementation. Two offline agents may audit source and measurement in parallel;
root alone runs targets serially. Freeze methods before executing them.

Select one high-cost mechanism with a small falsifier: actual helper products,
varying input size/sharing, independently expected output and consumed results.
Use ordinary safe Bend where possible, a frozen reference and a connected proof
where tractable. A diagnostic generated-C modification must be labelled as such
and cannot become the shipped implementation. No weakened ownership checks,
benchmark-name special cases or changes to pinned upstream.

Only a plausible general saving earns a checked isolated compiler image and a
balanced six-source comparison. Require the45 original complete C products to
remain identical, or explicitly validate any justified changed product. Preserve
JS-hosted behavior where shared source changes. A material benefit earns full
native B1/B2/self-hosting and applicable conformance gates before promotion;
otherwise retain the experiment and say why it stopped.

## Resources and report

Reuse binaries and existing oracles. Check disk/memory before large products;
one compiler build at a time, bounded process-tree RSS and available-memory floor.
Record actual target occupancy, failures and useful decisions separately from
elapsed research time; do not infer quota usage. Keep changes in fresh Phase95
paths until qualified. Commit/push design and evidence/report; no PR comment.

Report physical attribution, candidate correctness, helper speed, B1/B2 compile
time, compiled-program continuity and complexity separately. The outcome may be
a promoted improvement or a measured rejection with a stronger next hypothesis.
