# Phase140 session frontend source review

Reviewed `session/frontend-v01.bend`, SHA256
`f2f140da99141ff754f67d71971d65a7966b9b9e7ac976880a10b0d4c656ee53`,
against selected Phase137 source `2620d59a…ecf38`. This is a source review;
combined checking and request equality are separate gates.

The wrapper preserves the original order and current-revision data:

1. The parser bridge preserves header/import errors and returns actual validated,
   globally freshened `FPrefixLoad`.
2. A nonempty frontend error remains `parse: …` before checking.
3. `p140cb_check` preserves ordinary Base eligibility and original final TODO and
   diagnostic completion. A nonempty checker result remains `check: …`.
4. `driver_report_data` consumes the current original event book, not the saved
   checkpoint's completed output.
5. `driver_emit_owned(book)` precedes `j_compile_error(book)`, with the original
   `compile: …` error transport.
6. `book_context_world(book,load,world)` consumes the actual successful new
   result with its current load and authenticated prepared world. The owner
   reuse adapter starts exactly where original `p86_plan_context` started.
7. Every frontend failure returns the entire previous `P140FCache`; a successful
   annotation/erasure plan publishes the new parser/checker/owner state.

The hard-coded epoch string is acceptable only inside this explicitly private,
fixed-producer, fixed-Base in-process session. It is not an authentication token
for external checkpoint values or a portable artifact identity. Root evidence
must pin the producer source/API, Base and other environment identities. Candidate
compiler source revisions are ordinary inputs and do not change the producer.

One adjacent issue was reported to root: reviewed `session/backend-v01.bend`
SHA256 `c19fd013…d8cf21` has `p140s_finished` publish new frontend/raw/backend cache
unconditionally, even on `P111Emission.error`. That disagrees with the stated
full-request-success publication policy. Carry the previous `P140SCache` to that
boundary and retain it on an emission failure. This review does not claim that
root has or has not already fixed it in a later version.

`cut-v01.bend` selects a checker cut from actual source events. It excludes Base,
chooses the first law/fill event with the requested semantic name, and returns0
for an absent owner. It performs no host source interpretation. A new requested
cut controls cold/miss capture; it does not invalidate an independently admitted
existing checkpoint. If policy demands forced cold for an unknown owner, clear
the checkpoint explicitly. Its7 finite controls are ready for the next combined
checked API; no separate acquisition was launched for this small helper.
