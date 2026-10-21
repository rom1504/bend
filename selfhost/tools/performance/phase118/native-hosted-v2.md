# Hosted stack diagnostics, revision 2

The first Phase118 full hosted acquisition failed before producing QBE or a
native image. The preserved receipt is
`selfhost/build/phase111/p118-native-float01-full-emit/report.json`: frontend
254.448807s, runtime admission 0.078595s, integrated entry 332.238216s, total
588.321702s. `sourceChecked` and `runtimeAdmitted` are true; `irVerified` and
`complete` are false. The recorded exception is a host JavaScript `RangeError`,
not a Bend verifier rejection. It has no stack trace, so the exact failing helper
cannot be inferred from that receipt. The process retained only its method and
report, not a reusable request or structured-IR snapshot.

`native-hosted-v2.mjs` preserves the exact checked `p111_emit_admitted` call,
required exports, stages, chunk writer, and output authentication. It adds only
error name/message/stack capture at the stage and top-level catches, requests up
to 64 host stack frames, and writes a separately pinned `error-stack.txt` on
failure. `native-hosted-v2.json` records the old and new method hashes. No pinned
runner, compiler, runtime, evidence collector, or prior report was changed.
The root must bind this new method explicitly in a fresh qualification plan;
the old plan remains evidence for the failed original method.

Source evidence already establishes two stack-growth hazards in the selected
`p118-float-api01/api.mjs`, without executing a new reproducer:

- `$p118z_segments$` at lines531–540 directly evaluates its recursive result as
  an argument to `$Bool$and$`. Even an earlier false predicate does not short
  circuit JavaScript argument evaluation. The corresponding complete function
  and flat body walkers also need inspection.
- `$no_effect_definitions$` near line500 recurses through the chosen `nt_choose`
  closure over the 3,225 reachable definition names. That permission traversal
  may run before the transport gate. A stack-safe rewrite must retain the exact
  native/foreign/filled-definition predicates and their ordered short circuit.

These are source hazards, not retrospective identification of this exception.
Replacing methods on the exported API object would not trace internal calls:
generated helpers call lexical `$name$` functions. Manually calling separate
lower/verify/prepare exports would be a distinct diagnostic route and would not
qualify the actual integrated entry. Full request serialization would introduce
another large recursive traversal and storage cost; this revision adds none.

The cheapest next step is source review plus inspection of generated loop code
for the bounded helper overlay, followed by the established ordinary exact-QBE
controls. The next justified full acquisition should use the corrected actual
entry and this stack capture. There is no saved frontend request to make a
zero-frontend retry of the failed process possible. No synthetic graphs, custom
failure reproductions, target runs, or stack-limit increase are proposed.
