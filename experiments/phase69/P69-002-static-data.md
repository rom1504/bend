# P69-002 — Immutable native constructor images

Registered before implementation or execution. Owner: static-data agent; root
owns integration and all compiler/native targets. Source baseline c84246e,
compiler23 / b2ec0a2; upstream pin unchanged.

P68-024 established that a saved-C immutable String image removes 473,088
allocations in the counted lexer cycle and 10.1% lexer time; together with
corrected scheduling, 21.8% less time. This phase tests the general emitter.

Prepare each reachable ordinary definition once after erasure/compaction. Only
closed graphs of known immutable constructors and immediate scalar words may
enter STAT_IMG. Use existing constructor IDs, deterministic bottom-up offsets,
structural interning, a bounded image and the existing static-region ownership
rules. Mutable arrays, effects, foreign-owned representations, malformed arities
and nonconstant children retain ordinary allocation. Preserve the one-field
packed representation and the optional unboxed-product route.

The request-local cache follows the existing BookCache private-payload pattern:
its original source index remains exact and previous payloads are discarded.
No source definition or JS/backend input is replaced. Scheduler, ordinary worker
and product-worker paths consume the same prepared body and static graph.

Controls: repeated consuming matches; two uses of the same graph; static tails
inside dynamically allocated constructors; nested user ADTs and packed scalar
fields; independent constants and different module names; Unicode String; IO
request output; user foreign fallback; malformed/raw and nonconstant fallback;
threads 1 and 4. Compare emitted image and program output to pinned upstream,
then use balanced six-family runtime and B1/B2 request screens. No timing or
correctness result is claimed at registration.
