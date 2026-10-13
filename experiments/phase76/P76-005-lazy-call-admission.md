# P76-005: shared lazy intrinsic-call admission

The scalar/prefix classifiers eagerly constructed intrinsic names, looked up
provenance, traversed arguments and rendered templates even for non-Ref heads
or ordinary user definitions. Share an explicit lazy admission: App, non-bang
Ref, native definition, then primitive name and exact saturation. The scalar
and allocating classifications consume that result. Also avoid inspecting
non-Mat/non-scalar nodes during early word-pattern preparation.

Hypothesis: less string allocation and repeated metadata work with complete C
byte identity versus candidate07. All algorithms remain Bend. Exact-output
screen, raw diagnostics and fresh B1/B2 comparisons decide retention.

## Final decision

The shared lazy intrinsic-call admission is retained in installed candidate12. Pattern-preparation changes are excluded with the rejected scalar-pattern prototype. The final combined safe change preserves all twelve C/binaries and selected conformance; its measured gain is 6.28% B1/1.84% B2. See final measurements for the compound result.
