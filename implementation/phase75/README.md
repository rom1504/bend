# Phase75: avoid repeated work in native compilation

[Design](../../design/phase75/native-compilation-parity.md) ·
[Interim measurements](interim-measurements.json).

Work in progress; installed Phase73 remains the production compiler.
The first balanced three-round screen moves B1/B2 C-request ratios to
2.844×/2.006× upstream, from the historical Phase73 3.596×/2.297×.
Those historical samples were not interleaved with this candidate. Subsequent
one-round screens are recorded separately and do not establish final speed.

Worker admission now precedes generic lowering for checked, non-bang programs.
Already-admitted host functions retain their curried entry adapters and optimized
workers while avoiding unused scheduler bodies. Raw and bang programs preserve
the original lowering/error path. Native source shrinks about 40% on the initial
numeric/array sources; optimized worker sections remain byte-identical.
The three-family runtime screen passes all 27 intervals with no slowdown
(numeric 252→252ms, array169→169ms, lexer298→292ms). Broader runtime qualification
is still required before promotion.

Later candidates selectively retry only workers that reference withdrawn
product signatures, share an erased runtime closure within a request, return
trust verdict/names together, and reuse the checked lookup context. Each passes
focused36 and genuine B2 driver8 checks and reproduces the complete earlier
candidate C on the three compilation sources. Compiler07 additionally tests
sharing completed safe trust closures; 166 differential graph controls pass.

Failed compiler01 (affine rest capture) and compiler03 B2 preparation (new export
missing from the bootstrap root list) are retained. No failed run is counted as
passing evidence. No subagents, PR comments or reference-source edits.

Request timing excludes imports, explicit prepared Bend Base, Clang and program
execution; upstream checks Base inside its ordinary request. Backend products
remain disabled in this comparison. All compiler transformations are in Bend.

## Review and broader gates in progress

The candidate08 interleaved comparison has45 exact-C requests. B1 moves
3.604×→2.321× upstream (35.6% less time), B2 2.295×→1.683× (26.7% less).
[Raw paired samples](paired08-samples.json) retain every interval. Its separate
first-plus-five repeated-request screen reaches1.10× B2/upstream using the last
three medians; that is neither a cold-parity nor a steady-state claim.

Candidate09 corrects two review boundaries before promotion: cached runtime arity
must already exist in an owned request (raw static preparation does not evaluate
new telescopes), and injected native APIs retain their earlier host call sequence.
Checked36, B2 driver8, exact B2 C for twelve programs, raw31 and additional14
controls pass. Integration and self-reproduction are still in progress.

The broader runtime gate blocks promotion for now: tree takes311ms vs297ms for
Phase73, and Array.map478ms vs456ms. Other families range from about3% faster to
1% slower. The optimized worker region is unchanged for tree. All273 common tree
function symbols retain their sizes but change their modulo64 address offsets.
[P75-007](../../experiments/phase75/P75-007-runtime-layout.md) tests alignment;
this remains a hypothesis, not an explanation established by equal symbol sizes.
The installed compiler is still Phase73. Do not treat the compilation gain as
an approved tradeoff for those runtime regressions.

## Runtime-safe continuation

The runtime guard rejected host-body omission. Tree recovery from function
alignment did not generalize to Array.map; hot/outline/bank/branch variants failed
and forced block alignment made tree slower. The macro-wide alignment attempt
also failed to compile after affecting a function-pointer typedef. All remain
retained as rejected diagnostic attempts. No runtime/toolchain change was adopted.

Compiler10 restores exact original C for numeric/array/lexer. Compiler11 adds a
private first-winner constructor index (1,066 differential checks); its one-round
B2 screen is1.93× upstream, with complete C identity. This is a screen, not final
balanced evidence. Compiler13 compact U32 occurrence sets pass65,000 controls;
compiler14 removes the rejected host-omission implementation and is being measured.
Compiler12 was an accidental duplicate build after a manifest-path edit assertion;
it is not counted as a new candidate or speed result. Installed Phase73 remains.
