# Phase58: allocation and generated-code improvements

Work in progress. The [design](../../design/phase58/compiler-allocation-and-code-generation.md)
sets the scope and admission criteria. The installed Phase56 release remains
unchanged until the combined candidate passes the final gates.

## Decisions and evidence so far

Four source changes have passed focused controls and are in implementation
checkpoint `33b9a53`: ordinary literal record fields
(with computed `__proto__`), allocation-free intermediate constructor misses and
checked owner lookup, proven U32 residual reconstruction, and structural literal
choice lowering. These controls include demand, alias, effect and default-stack recursion.
Passing focused controls does not replace the broader release gates.

The first fixed-source saved-B2 field-syntax screen passed both independent
lexer-output oracles and emitted identical bytes. One fresh process per role
measured import/API/first request at 3,193.23 versus 2,362.77 ms, and one subsequent
request at 2,073.66 versus 1,576.14 ms. That is a promising 24–26% time reduction,
not a stable throughput estimate or a production-release result. The subsequent
three-round screen confirms 24.6% less import-plus-first time and 22.5% less later
request time, still on one input. See
[latency evidence](latency.md).

The fields and cumulative lookup builds each pass all 36 initial paired checks
with zero exact differences. Their configuration omitted `strictExact`, whose
default is false; their actual results still have zero exact differences.
Controllers requiring that flag refused them before target observations. Those
refusals are preserved, and successors independently verify the actual exact
results. New builds explicitly enable strict exact checking; the scalar build
passes that gate. No checked receipt is edited to change its claimed scope.

## Detailed records

- [Literal fields and special names](literal-fields.md)
- [Literal choices and tail boundaries](literal-choices.md)
- [Constructor lookup and allocation](lookup.md)
- [Scalar residual reconstruction](scalar-residual.md)
- [Compiler latency](latency.md)
- [Qualification plan and limits](validation.md)

Root owns all compiler/generated-program execution on CPU3. Agents prepare
isolated source patches, focused fixtures, read-only analysis and independent
review. Every target has a bounded heap and process-tree memory guard; historical
Phase54–57 raw evidence and inherited unrelated work are preserved. Failed runs
remain part of the record. No PR comment is part of this work.

## Focused admission

Lookup preserves 135 actual annotated queries plus four fallback queries. Across
those 139 rows, `missing` calls fall from 4,248 to 3; the actual annotated subset
falls from 2,391 to zero. The one-pair lexer timing screen is essentially flat.
These query-local counts do not imply an equivalent whole-request speedup.

Scalar controls pass 1,728 counted observations per role across baseline,
candidate and pinned TypeScript, including callback mutation, aliases and float
fallback. Choice controls pass the independent values/effects, exact refusal
checks and 100,000-step self/mutual recursion at the default Node stack. Fields
pass 17 observation groups per role including `__proto__`, getters and callback
order. Failed fixture and controller attempts are retained and explained in
the detailed records.

The selected combined checked build is `checked-choice01`, with strict exact
36-case agreement. Final broader admission and performance comparisons are in
progress. The source commit is pushed; installation has not occurred.
