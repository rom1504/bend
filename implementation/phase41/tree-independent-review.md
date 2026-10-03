# Phase41 tree acyclic-wrapper source review

Static review of the isolated proposal in
`selfhost/tools/performance/phase41/tree/tree-acyclic-wrapper.bend` and its
patch. Reviewed patch SHA256: `5288a7c12a6a35e719ba914afcbd9ef3faca268902b1209ebdadc0241911acb2`.
No build or runtime was run by this reviewer.

No blocker found in planner recursion, continuation-stack selection, or
transitive backedge refusal. `j_component_wrapper_calls` invokes a nested
planner only after the candidate has positive own-reference count. Its
`j_component_select` therefore takes the already-admitted recursive branch and
does not scan another wrapper. Each candidate and wrapper retains a complete
pure-graph closure check; for a wrapper, `j_component_closed` rejects a
dependency that references the wrapper. The compact declaration is selected
only when the wrapper has zero own references, emits one phase-0 body under
`$step`, and returns its value without allocating continuation frames.

The witness is a global reference-count check, not a proof that the wrapper
contains a saturated call to that candidate. Root accepted this witness under
the existing typed `JPure` graph and requested fixture coverage. The planned
fixture cases should keep that distinction visible: direct saturated call,
first-class-only reference, and transitive backedge refusal.

Root separately reports a checked source build (44.66 seconds), passing
actual controls (124 oracle rows and 17 boundaries), and a three-rotation,
three-point screen with 1.40–1.45x gains. These are root-run results, not
independent reviewer verification; they do not by themselves complete frontend
gates or compiler promotion.
