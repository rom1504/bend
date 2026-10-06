# Generating the compiler with its direct JavaScript backend

A compiler image is an executable JavaScript module containing the compiler's
Bend implementation and its public API. Generating that module is a much larger
compilation than compiling a small user program. It is also distinct from running
the resulting compiler or measuring programs compiled by it.

Phase55 resolves the full-image timeout without changing the export interface:
the fixed Phase54 compiler source now produces its complete image in **96.2 s**,
and the optimized compiler's own source produces an image in **104 s**. Both
images pass the ordinary driver's eight parse/check/error/JS/C/replay controls.
These are single, CPU-pinned diagnostic observations, including provenance
verification; they are not compiler-throughput parity measurements.

## What changed

Arity recovery used to discard matcher type annotations and search every datatype
for a constructor. Checked annotations already identify its owner. Using that
owner avoids repeated whole-book searches, while unannotated or unknown types
retain the existing fallback.

Export generation separately rechecked recursive types for every argument,
result and back-conversion. One completed whole-signature proof that no Nat
conversion is required now permits all those conversions to remain empty.
Nat-containing signatures and analysis-budget exhaustion keep the original
per-component path. No runtime guard or conversion was removed speculatively.

Together the changes add 27 physical lines. The fixed-source image before and
after the second change is byte-identical, including all public/private exports,
runtime code and host wrappers. Export generation falls from 121.4 to 20.9 s.

## Reproduction and the fast loop

The [Phase55 report](../../implementation/phase55/README.md) and its publication
index bind exact source, generator, Node, runtime, configuration and output
identities. Raw `selfhost/build/phase55/` paths refer to the archived experiment
directory; restore that evidence before replaying its frozen plans. Historical
plans contain absolute paths and must be rebound to a fresh checked attempt when
working in another checkout. Do not overwrite consumed attempts or receipts.

1. Build one checked candidate with the [development workflow](../PHASE5_DEVELOPMENT.md).
2. Run the compact arity and host-conversion controls against the prior checked
   compiler. These took 23 and 15 seconds respectively in Phase55.
3. Keep the compiled subject fixed while changing the generating compiler. The
   restricted image first proves the instrumented emission path equals the
   ordinary library call exactly; then emit the full 77-root compiler image.
4. Compare complete module bytes and run the resulting image through the
   unchanged driver. Generation success alone is insufficient.
5. Emit the candidate's own source separately. Run broad semantic, native and
   release checks only for the selected candidate. Reuse dated program timings
   only when the complete benchmark modules remain byte-identical.

The [Phase55 method guide](../../selfhost/tools/performance/phase55/README.md)
names the controllers and plans. Compiler jobs use one CPU, a 1 GiB Node heap,
a 2 GiB process-tree RSS limit and a 4 GiB available-memory floor. Analysis and
review can run concurrently without competing benchmark workloads.

## Bootstrap boundary

The generating checked B1 image still descends from the pinned TypeScript seed
and reviewed image transforms. The emitted B2 images contain the compiler
implemented in Bend and use the direct runtime. Normal compilation has no
TypeScript fallback.

The compiler source proof in this experiment is inherited from that exact checked
bootstrap; the new direct image has not freshly checked its own complete source.
B2 generating a byte-identical B3 would be an additional emission fixed-point
test. Neither that test nor migration of every legacy image-transform client is
claimed here. The working legacy bootstrap remains available.
