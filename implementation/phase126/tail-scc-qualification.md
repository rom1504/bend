# Tail SCC ordinary qualification

The root-run final32 controls pass all ten exact frozen lines from
`tail-scc/ordinary-v05.bend`. Actual emitted wrappers `owner/owner_more` call
`$p126scc.6`, and `turn/turn_more` call `$p126scc.8`. Both joined bodies contain an
entry jump plus two transition backedges. Therefore the tests with 100001 fuel steps (200002 internal transfers per deep call)
exercise the new path, including full-width 2^40 arguments, argument permutation,
and a dynamically constructed String passed twice with its ordinary ownership
credits. The non-tail pair has no admitted direct worker and retains fallback.

The source contract explicitly annotates the three forward-calling helpers
`@unsafe`, as required for user mutual recursion. The kernel rejects live use of
an unfilled user law unless the current definition has that annotation; Base's
laws have native trust. This is an ordinary typed source-language recursion
permission, not a compiler or native-verifier relaxation. Earlier syntax and
unfilled-law failures remain preserved in versions01–04 and their root receipts.

All 16 pure finite controls also pass, including the original direct verifier on
a generated joined worker and its wrappers. Exact receipts and emitted-path pins
are in [tail-scc-qualification.json](tail-scc-qualification.json). This note reads
root-produced evidence only and makes no isolated runtime-speed claim.
