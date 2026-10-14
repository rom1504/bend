# Static image scaling repair

In progress; this checkpoint does not claim native self-reproduction or replace
the installed release.

The unchanged Phase82 B2 failed to emit the frozen native compiler source in
23.178 s of request time: `ns_image_terms` overflowed the 4 MiB JavaScript stack.
The static image admits up to 65,536 words, but both conversion directions used
non-tail list construction. Replace these two conversions with tail-recursive
accumulators and a final reversal. Constructor fields, names and order stay exact;
the production change adds eight physical lines.

The genuinely checked `compiler01` B1 passes all 36 focused frontend controls.
Its self-emitted JS B2 `23913710…` passes tiny split/ordinary-library equality
and all eight driver comparisons. The focused regression runs the actual public
full-library exports on 0, 1, 17 and 65,536 distinct Unicode-bearing words. It
checks every KTerm field, the complete round trip, and retained input lists.
Old B2 fails at 65,536; new B2 passes all cases in a 1.226 s guarded process,
273.6 MiB peak RSS. See [exact receipts](static-image-controls.json) and
[the runner](../../selfhost/tools/performance/phase90/bootstrap/static-controls.mjs).

An independent complete-source request through checked B1 gets past this failure
but exposes a second stack limit during `nf_wrap_segments`; its failed 73.166 s
request is preserved in `selfhost/build/phase90/js-self02`. Whole-segment wrapper
traversals are being repaired separately. No stack-limit increase is used.

The 180 s native diagnostic has 11,250 samples and no sampler loss, but its outer
input-consistency gate rejects my concurrent edit of canonical `static.bend`.
The exact native executable and its frozen source were unchanged. Preserve that
rejection: the late String.append plateau is an exploratory lead for a separate
table-builder experiment, not an admitted performance measurement.

The first nested bootstrap guard refused the shared target lock without running
a compiler. `bootstrap/run-plan.py` subsequently executes each recorded job with
one guard, serially. The failed attempt and successful steps remain distinct.
