# Certified borrowed-field emission experiment

Status: checked and measured prototype, selected for final Phase128 native
acquisition. The name-search kernel improves0.531184→0.368798s in five paired
clean rounds; this is not a whole-compiler measurement. The first combined
native image (before this template) improves7.79% on three cold requests.
Final native qualification remains separate.

Assemble `template.bend` on the checked combined Phase128 source, replacing
exactly `p111q_constructor_ids` and `p111q_stmt`. Append `controls-v3.bend`, export
`p128bf_controls`, and optionally export `p128bf_test_text` for inspection.
The runtime source/object and all independent verification stay unchanged.
Use `oracle-wrappers-v2.bend` for the independent ABI export. Earlier control
versions preserve two checker refusals: a match on a computed expression and
an unannotated constructor binding. They were corrected before execution.

Evidence: `selfhost/build/phase128/field-finite04/report.json` (21 predicates),
`field-timing01/report.json` (five clean paired runs),
`field-machine01/report.json` (exact source/machine excerpts),
`selfhost/build/phase113/p128-field-oracle02/report.json` (545 ABI checks), and
`selfhost/build/phase118/p128-field-emit01/report.json` (checked kernel and27
ordinary output lines). Exact wired source02 passes all100 finite predicates;
`native-admission02.json` binds it to the oracle and unchanged runtime.

The current reader calls `p118_rt_borrow_fields` for each boxed match and then
reloads fixed fields from scratch. This prototype preserves that scratch/status
interface but makes the readonly heap access visible to QBE. It intentionally
does not add a general raw pointer operation or change the ownership analysis.

Admission requires the exact existing import, result/argument widths, state
identity, authenticated stack-buffer origin, a symbolic constructor with known
descriptor arity, and width2–8. The emitter's constructor ID table retains arity
in its previously unused `dx` field; `da` remains the same numeric ID. Unknown,
packed width1, nullary, wrong-count and other imports use the previous emitter.

At runtime the template snapshots the input word, checks exact constructor
identity and `TAG_CTR`, and only then reads the heap. A wrong tag or identity
calls the original helper before any dereference. RFC handles preserve the
two-word header representation and 24-bit payload-location shift; ordinary
handles use the low40 location. Fixed field loads write the same scratch slots
and set the same count result. No reference-count, ownership, root lifetime,
scheduler or runtime error contract changes.

This is tied to the existing sequential CPU runtime ABI: `P111State.e.mem` at
offset0, RFC header representation, tag2, RFC highbit and 40-bit locations. The
CPU has no concurrent refcount mutation; the relaxed loads/acquire used by
`rfc_view` therefore do not add a concurrent synchronization obligation here.
This template is not qualified for device or concurrent runtimes. Existing
source-bound runtime identity and supported execution mode remain required.

Generated locals use the already reserved `p114t_` namespace and the existing
emission freshness counter. The fallback is rendered via an exact copy of the
previous dispatcher, preventing recursive expansion of its own fallback. The
generic verifier still rejects arbitrary dynamic pointers and out-of-bounds
access. This narrow late lowering assumes the complete original import passed
the unchanged independent verifier first, like the qualified private-array
templates.

The first falsifier is the actual name-search reader machine code and paired
runtime against the combined source, plus ordinary alias/shared-suffix/Unicode
and renamed numeric-spine controls. Do not infer success merely from template
presence. Preserve the unchanged import fallback and test malformed tag/CID
through an independent runtime fixture before promotion. A full compiler rebuild
is unnecessary until this small comparison shows a worthwhile gain.
