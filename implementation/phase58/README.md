# Phase58: allocation and generated-code improvements

Work in progress. The [design](../../design/phase58/compiler-allocation-and-code-generation.md)
sets the scope and admission criteria. The installed Phase56 release remains
unchanged until the combined candidate passes the final gates.

## Decisions and evidence so far

Four isolated source changes are being tested: ordinary literal record fields
(with computed `__proto__`), allocation-free intermediate constructor misses and
checked owner lookup, proven U32 residual reconstruction, and structural literal
choice lowering. The last two require focused demand, alias, effect and stack
controls; passing source checking alone does not qualify them.

The first fixed-source saved-B2 field-syntax screen passed both independent
lexer-output oracles and emitted identical bytes. One fresh process per role
measured import/API/first request at 3,193.23 versus 2,362.77 ms, and one subsequent
request at 2,073.66 versus 1,576.14 ms. That is a promising 24–26% time reduction,
not a stable throughput estimate or a production-release result. See
[latency evidence](latency.md).

The fields and cumulative lookup builds each pass all 36 initial paired checks
with zero exact differences. Their configuration omitted `strictExact`, whose
default is false; their actual results still have zero exact differences.
Controllers requiring that flag refused them before target observations. Those
refusals are preserved, and successors independently verify the actual exact
results. New builds explicitly enable strict exact checking; the scalar build
passes that gate. No checked receipt is edited to change its claimed scope.

## Detailed records

- [Constructor lookup and allocation](lookup.md)
- [Scalar residual reconstruction](scalar-residual.md)
- [Compiler latency](latency.md)
- [Qualification plan and limits](validation.md)

Root owns all compiler/generated-program execution on CPU3. Agents prepare
isolated source patches, focused fixtures, read-only analysis and independent
review. Every target has a bounded heap and process-tree memory guard; historical
Phase54–57 raw evidence and inherited unrelated work are preserved. Failed runs
remain part of the record. No PR comment is part of this work.
