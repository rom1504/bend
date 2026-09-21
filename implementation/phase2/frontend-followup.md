# Remaining frontend acceptance differences

After the phase 2 compiler freeze, four fresh probes compared the live pinned
TypeScript compiler with the unchanged pre-repair checked Bend API. Both suspected
grammar differences reproduce. No compiler source was changed for this audit.
The paired observations are retained in
[frontend-next-grammar.json](evidence/frontend-next-grammar.json).

| Witness | Pinned upstream | Bend compiler |
| --- | --- | --- |
| `def main() -> List<&1, U32>: [7; 16]` | Parse rejection at `;` | Check accepts |
| Same declaration with `[7, 16]` | Check accepts | Check accepts |
| `def ignore(~unused, x: U32) -> U32: x`, called with `ignore(~&1, 7)` | Parse rejection: missing `:` | Check accepts |
| Same template with `~unused: Quant` | Check accepts | Check accepts |

The snippets above abbreviate multiline fixture layout. The evidence embeds the
complete source and hashes. These are demonstrated grammar compatibility defects;
the probes do not establish invalid proof acceptance or memory unsafety.

The semicolon difference follows from `src/front/lexer.bend`'s `f_skip`, which
treats semicolons as general whitespace. Upstream skips whitespace and comments,
then consumes semicolons explicitly in selected body contexts. A global change
would affect bodies, IO, matches and expressions. A future repair should separate
expression whitespace from statement separators, retaining valid body-semicolon
controls and rejecting semicolons in lists, call arguments and constructor fields.

The smaller template repair is in `f_validate_param` / `f_tele_binder`: a bare
parameter currently defaults to `Quant`, including a `~` parameter. Require a
colon and explicit type for template parameters while preserving permitted plain
quantity parameters and bare names that fill existing laws. Test both the fresh
witness and upstream `comptime/err_untyped.bend`, with typed-template controls.

The four-probe batch ran briefly on CPU0 alongside the full TypeScript reference
suite. Its 17.4-second elapsed time includes contention and fresh-process overhead;
it is correctness evidence, not a performance comparison. These follow-ups were
initially left outside the frozen v1 compiler and its ongoing validation.

## Bounded v2 repair

The subsequent authorized v2 candidate fixes both witnessed cases without changing
the global whitespace helper. Its telescope parser permits an omitted type only
for unmarked plain binders, matching the upstream rule. List parsing rejects a
semicolon before the first element and at subsequent element boundaries, before
the existing skip helper can consume it. `f_list` also preserves argument-parser
errors instead of converting their empty child list into an empty list literal.

[frontend-grammar-v2.json](evidence/frontend-grammar-v2.json) records 25 fresh
paired cases: ten former invalid acceptances now reject during parsing, and
fifteen positive controls still accept. The controls include marked typed
parameters, ordinary bare quantity parameters, law fills, typed arrays, nested
lists, and statement/IO semicolons. The unchanged original 21-case frontend matrix
also passes against the checked v2 API. These acceptance and phase checks do not
claim exact diagnostic compatibility. Semicolons in other expression/delimiter
contexts remain outside this bounded repair.

One initial positive control used `* 4` for an array count; upstream requires the
Nat literal `* 4n`. The control was corrected before the final matrix, and was
excluded from before/after change counts. Its original source and failed attempt
remain archived. Compiler v1 reports and immutable bootstrap inputs were retained.
