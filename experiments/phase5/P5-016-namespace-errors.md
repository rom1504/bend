# P5-016 — Preserve namespace parser errors

Owner: compact_index. This is a bounded semantic repair, with no performance claim.
The initial witness `(0 : U32]` is accepted by the port although pinned TypeScript
rejects its closing delimiter. `f_group` passes the failing `f_expect` result to
`f_group_namespace`, which calls `f_namespace`; that transformer can discard the
namespace argument entirely for literals and ordinary references, losing Error.

Change only `f_group_namespace` in an isolated genuine checked source snapshot.
On an Error namespace result, preserve an existing earlier Error anywhere inside
the first expression, using the existing `f_error_term` rejection-path scan;
otherwise propagate the namespace Error. For non-Error namespace results, call
the original transformer unchanged. This does not turn namespace syntax into a
term annotation, alter parser precedence, or change the public result ABI.

Fresh paired controls must cover wrong/missing/EOF closing delimiters, malformed
namespace expressions, earlier direct and nested errors, proper literal/reference/
operator/nested namespaces and corresponding execution. Accepted raw books must
remain exactly equal to the baseline. The live pinned compiler defines acceptance
and first-error behavior; incorrect test assumptions remain in failed attempts.
Exact diagnostic fidelity is a separate gate from acceptance/phase parity.

Use CPU1 short correctness processes with 4 MiB stack and 4 GiB heap, only after
root releases benchmark holds. No broad suite or job longer than three minutes.
Preserve original source, bootstrap/input identities, failed and successful reports,
then request review before production promotion. Coordinate the single function
with P5-011's unrelated `f_law_where` transport change in the same source file.

## Selected result and promotion

The isolated candidate repairs six fresh invalid acceptances. Sixteen selected
checks, fourteen exact execution observations, seven accepted raw graphs and
three earlier-error controls pass in their stated scopes. Two initial test/audit
assumptions were corrected in separate attempts and remain archived. Eight
focused diagnostic differences and the separate namespace-name validity/first-
error residual remain explicit. Root approved and promoted only the reviewed
function; see [the report](../../implementation/phase5/frontend-namespace-errors.md)
and its verified archive. No performance or full-conformance conclusion follows.
