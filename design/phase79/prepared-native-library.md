# Phase79: a prepared native Base library

Phase78 compiler21 is the baseline: paired fresh B1/B2 requests take1.73205×/
1.38187× upstream. Native execution is effectively unchanged, all23 JS benchmark
sources remain exact, and the selected source qualifies. Ordinary non-IO held-outs
improve only about2–4%; broad claims from the IO loop are inappropriate.

## Hypothesis and discriminator

Compile reusable Base work once using the same immutable checked Base world that
already supports prepared annotations. The first prototype produces annotations,
pre-compaction erased bodies/arity, and successful segment-free ordinary workers.
Only Base definitions inside the admitted disjoint context may reuse them. Compiler
algorithms and product construction remain Bend; JavaScript transports the data.

The first discriminator must reproduce the existing C exactly and save at least
15% on the fresh prepared-library request after reading, checksum verification,
decoding, admission and lookup. A failure stops expansion. Keep the ordinary
prepared-frontend-only clock as a separate role, and report complete one-time
construction time, artifact size, RSS and break-even request count. Small and
functions65 are held-outs: no useful Base work must mean no large product decode.
Never call this a gain on the old clock without identifying added preparation.

## Stable product boundary

Use a separate versioned native-product artifact, bound to compiler, Base, source
path, span/core ABI and the exact prepared-world graph. Reuse requires the current
successful owned request, `base_annotation_allowed` and its hash-disjoint suffix
check. Changed/custom Base and missing, stale, malformed or corrupt products use
ordinary compilation. Public raw entry points do not infer permission from book
markers; source validation still sees the original book and binder ranges.

The producer annotates the checked Base using native stops. It computes erased
ordinary bodies and runtime arity, prepares its internal native context, builds
product signatures and lowers worker candidates. Preserve only successful workers
with no scheduler segments and no static-image address references. Local worker
fresh counters start at parameter arity; global scheduler continuation IDs and
request-relative static addresses are not cached. Request-specific lowering stays
ordinary, and the existing admission/retry mechanism still checks dependencies.

A private KDef/KTerm transport carries fields already understood by the Base-arena
codec: annotated definitions, erased body facts and worker code/params/dependencies/
shape/fresh counter. Do not add a second ad-hoc JavaScript compiler. The same
source Base and dependency signatures must determine cached code: validate this
with exact-C comparison across diverse request closures, custom constructors,
product withdrawal and fallback paths, not only common library-name overlap.

## Observer extension only after a win

If the first discriminator succeeds, cache positive symbolic observer results or
their emitted worker/adapter pair. Recheck current entry arity, dependency admission,
private-name collisions and scalar fallback readiness. Keep per-request ownership,
roots and representation permissions. Raw/bang behavior and negative candidate
results are not cached. Unlike the rejected early-observer rewrite, this aims to
avoid symbolic analysis itself, not merely its small unused fallback body.

## Promotion

Use one guarded CPU3 process tree,2GiB aggregate RSS/4GiB available floor,Node1GiB
heap/4MiB stack. No agents or PR comments. Start with checked B1 and exact old C;
run full B2/self-check/fixed-point, raw/native/bang/effect/product controls and
installed/relocated checks only after a worthwhile prototype. Keep failures and
ordinary fallback timings. A prepared-library result, an ordinary cold request,
and a persistent-process session remain three distinct measurements.
