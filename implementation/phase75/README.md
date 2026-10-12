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
