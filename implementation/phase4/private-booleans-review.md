# Independent review of private Boolean specialization

**Semantic decision: approved for the private compiler image.** The reviewed
transformation preserves the relevant evaluation order, partial application and
fallback behavior. Combining it with the stability cache is also structurally
sound for the frozen variants; promotion should use the combined image's own
correctness and performance gates. This approval does not extend to public
libraries or arbitrary host-supplied JavaScript function graphs.

[Review evidence](evidence/private-booleans-review.json) records exact source,
tool, test and comparison hashes. This was an independent read-only inspection
of the prototype and its existing results, not another benchmark run.

## Evaluation and error order

The actual checked `Bool.and` definition is a matcher on its first argument.
It returns a one-argument function: the false branch returns False and the true
branch returns its second argument unchanged. The replacement reuses two frozen
private `fn(1, ...)` handlers for exactly primitive `true` and `false`. Their
bodies implement those same results; original `G["Bool.and"]` is untouched.

The outer application still evaluates its second argument eagerly, including
when the first argument is false. This is not a JavaScript `&&` rewrite. If the
first argument is not a native Boolean, the helper calls the original matcher
at the original first-argument demand point, before the second argument is
evaluated. In particular, the runtime's request/fail-stop error remains earlier
than an error in that second expression. `Bool.not` uses `!` only for primitive
Booleans; all other inputs retain the original matcher behavior.

Underapplication, empty follow-up applications and overapplication still pass
through the original `call`/`apply` machinery. Reusing the handler changes its
allocation identity, but the image's data-only transport exposes no function
objects or callbacks and both handlers and their empty bound arrays are frozen.
That privacy and immutability contract is essential. It would be unsound to
promise identical function-object identities through an unrestricted public ABI.

Tail-site replacement eliminates pure matcher evaluation at its tail forcing
point. It does not evaluate a later argument early or introduce an observable
callback/effect. Resource exhaustion and exact allocation identities are not
semantic equivalence claims.

## Rewrite and composition guards

The prototype requires exact hashes for both emitted matcher bodies and the
native True/False representation. It edits only tokenized deferred `G` workers
and their specialized worker copies. Only one explicit argument qualifies;
empty, multiple and spread arguments do not. Runtime implementation, quoted
source text and the original global definitions retain their behavior.

The composition adapter first requires its literal stability-call delta plus
helper suffix to reproduce the independently tokenized stable-only image
byte-for-byte from canonical specialization. It then applies the same five
stability-call replacements to the Boolean variant. The Boolean helpers neither
add nor change that call prefix, and the helper names are disjoint. Each variant
is specialized once; no second specialization or replacement of the original
Boolean globals occurs.

## Evidence and measured scope

All **300 actual-image controls** pass: Boolean and raw fallback operands,
partial/overapplication, eager second-argument failure, request fail-stop before
that failure, function-valued second operands and repeated handler reuse.
The **24-observation alternating matrix** also passes exact result and output
comparisons across three fresh pairs per workload.

| Request median | Private control | Boolean specialization |
| --- | ---: | ---: |
| Tree | 2.101 s | 2.013 s |
| List sort | 3.659 s | 3.498 s |
| Bytes rejection | 1.579 s | 1.475 s |
| Real compiler-core library | 28.115 s | 25.874 s |

The compiler-core reduction is 8.0%; it is not a whole-compiler speedup claim.
Process-wall medians, shared-host conditions and all samples remain in the
archived comparison. The composed variant needs its own observations rather
than adding the two optimizations' standalone percentages.
