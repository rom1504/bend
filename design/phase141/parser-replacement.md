# Selected experiment: one top-declaration parser

Chosen at 22:00 UTC, after the first ten-minute audit. The incremental Phase140
parser mechanically cloned 34 ordinary parser functions, threading a stop cursor
and returning either the ordinary result or a complete checkpoint. Both versions
remained in the experimental compiler. This is one duplicated algorithm with
an unusually strong independent comparison, rather than a speculative new IR.

The candidate uses the stop-aware parser for both ordinary and incremental
requests. Ordinary `f_tops` and `f_top` retain their original laws and call with
stop zero. A small adapter unwraps the result. Its otherwise unreachable cut arm
resumes the full saved state with stopping disabled. No invented parser error,
source slicing, host parsing, or weakened cache admission is involved.

Delete the 32 internal ordinary-parser names and their duplicate laws. Keep both
external entry signatures and all five actual external callers. Retain the
stop-aware grammar, original expression parser, lexer, freshening, completion,
checker, proof declarations and independent final backend verifier. Exact
deletion blocks, callers and identities are in
`selfhost/tools/performance/phase141/parser/deletion-v01.json`.

The first assembled production candidate removes 501 physical / 393 code lines
from Phase140 source18: 64,408 → 63,907 physical, 46,808 → 46,415 code. Test-only
exports are composed separately. This nearly halves the duplicated slice; it
does not halve the compiler, remove a language capability, or establish a path
to 10,000 lines by itself. Historical original modules remain evidence and an
independent baseline, not a second active implementation in the candidate.

## Falsifiers and measurements

1. Independently check both frozen baseline and candidate testing APIs. Preserve
   original public laws and protected proof/verifier bodies exactly.
2. Compare complete parser results, including spans and errors, on upstream
   tests/demos, truncated inputs, UTF16 origins and actual compiler source.
3. Compare checkpoint capture, warm edits, changed boundaries, malformed suffixes
   and recovery against both the independent old parser and fresh ordinary parse.
4. Compare prepared-Base frontend and complete QBE on unrelated real workloads.
   Exact output establishes that this cleanup has not changed their generated
   program performance; parser correctness alone is not whole-compiler proof.
5. Measure ordinary and warm compiler cost. The extra stop parameter pushes some
   parser helpers across the current eight-argument private-worker cutoff. A
   meaningful native regression rejects the simple unification even if hosted
   performance and semantics pass. Do not hide this with source-size results.
6. Only after cheap gates, acquire one native candidate with qualified Phase137
   N3 and perform bounded independent requests. Broaden qualification only if
   warranted for adoption. Phase137 remains the qualified selection.

The source packager performs explicit declaration deletion and asserts retained
contracts; it implements no compiler semantics. Its lines, the comparison
harness, evidence, and research documents are reported separately from compiler
implementation savings. The experiment removes duplicate grammar maintenance,
not the genuinely necessary checkpoint lifetime/invalidation concept.
