# Static-image resource controls

Both controls are source-only preparations; root owns execution and receipts.
Use a fresh Phase69 output and the existing single CPU3 guard. Keep a 15-second
compiler-request timeout and 2 GiB tree limit; do not expand literal depth until
a small input is qualified.

1. `long-string-2000.bend` is an actual user program with a 2,000-codepoint,
   2,800-byte literal and two consuming traversals. Baseline/candidate output
   must be `4000n`. Emit through each compiler, record stack/RSS/time separately,
   and execute candidate threads 1/4. Its candidate image should have 4,000
   words for the String, plus any independently reachable static data. This
   tests erasure, compaction, image preparation, native emission and lifetime
   together. It does not claim arbitrary-depth inputs are stack-safe.
2. `image-boundaries.mjs` exports `runStaticImageBoundaries(api)` without executing
   the compiler on import. Root's guarded query runner may call it on the new
   API and preserve the returned JSON. It materializes a real 65,534-word scalar
   prefix, then tests exact fit, overflow refusal, deduplication at the bound,
   dynamic parent/static child fallback, and packed nodes. A separate actual
   65,535-word prefix tests the one-word-remaining boundary. All list lengths
   are checked against size. This isolates the real production cap code without
   constructing a pathological 32K-deep String or a quadratic 32K-definition
   reachability book. It is an internal state-boundary control, **not** evidence
   that a full source program was compiled at the cap.

Do not spend a broad compiler run just to hit this numerical boundary. The
ordinary three graph fixtures and the long literal establish actual emitter
integration; the short helper experiment addresses the boundary branch itself.
