# Phase41 lexer feasibility

Correctness: static contract and source inventory only; no compiler patch.
Measurement: not run. Decision: defer full lexer integration in this bounded
campaign; no installed/generated-program gain is claimed.
[Prospective contract](../../design/phase41/lexer.md).

The compiler has useful existing building blocks, but the manual roughly 2×
complete-component result cannot be promoted by a single type whitelist edit.
The minimum surviving contract spans several independent owners:

| Boundary | Existing gate | Required narrow extension |
|---|---|---|
| Native String/Char | `j_pure_type_head`, `j_region_local_check_head` | Exact built-in ABI plus internal owned values; preserve Unicode and checkedChar |
| Sigma purity | `j_pure_type_head` | Specialized exact two-field nondependent native Sigma with independently proved full fields |
| String/Char literals | `j_pure_expr_on` | Exact closed native literals and their ordinary constructor checks |
| Nullary template | `j_pure_eligible`, `j_pure_call`, runtime `scalarCapture` | Exact literal-only zero-argument helper and descriptor capture, without broad nullary graph admission |
| Bool.and | `j_pure_bool_native`, runtime `native` capture list | Exact native signature and immutable wrapper capture; retain ordinary ABI |
| String recursion | `j_component_plan`, `j_component_match`, emitter match | Only exact SCon tail gets structural descent provenance; do not admit Char/Sigma fields as recursive String children |
| Host ownership | runtime `scalarGuard`, `regionHostGuard` | String global/static/prototype descriptor ownership and marker hooks before proof opens |

`local.bend` already admits specialized Sigma layouts and complete two-field
native arrays in private direct lowering. This does **not** mean JPure proves
such a tuple, nor does it admit public Mode/tuple arguments. A step-only worker
therefore cannot enter from the ordinary generic lexer using existing scalar
root admission. Entering through line/batch still requires the whole reachable
String producer/consumer proof. Avoid an expensive build of a known incomplete
type-only patch.

Native String constructor and split demand are observable: `core.mjs` ctor
SCon calls global String.fromCodePoint; fields SCon calls codePointAt twice and
slice once, preserving full astral head and remaining string. None of these
String bindings is owned by the current numeric/scalar guard. Changing either
method to a callback remains invisible to that guard, so blanket String purity
would permit callbacks while the proof is open. Reentry, dependency mutation or
throw from these callbacks breaks the private no-callback premise.

The isolated [cheapest falsifier](../../selfhost/tools/performance/phase41/lexer/string-host-counterexample.mjs)
appends diagnostic exports to an unchanged emitted lexer in a fresh Phase41
directory. It tests codePointAt and fromCodePoint wrappers, confirms that the
existing scalar/host guards still return true, checks complete Unicode values,
and restores descriptors in finally. It is unexecuted by this owner; root may
run it serially against a selected installed emitted module. This is a proposal
counterexample, not a failure of current compiler behavior: current String
admission is refused.

No production source, runtime, dist, historical evidence or pin is edited. The
documented route is feasible as future dedicated work but is too broad for the
bounded reliable-gain-per-hour screen. A direct first-order tail loop alone
would still need these independent ownership gates. Existing Phase40 manual
controls/timings remain retained without being rerun or pooled.
