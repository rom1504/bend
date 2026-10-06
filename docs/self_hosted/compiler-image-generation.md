# Generating the compiler with its direct JavaScript backend

A compiler image is an executable JavaScript module containing the compiler's
Bend implementation and its public API. Generating that module is a much larger
compilation than compiling a small user program. It is also distinct from running
the resulting compiler or measuring programs compiled by it.

Phase56 now reaches an **emission fixed point**: the direct B2 compiler emits a
complete, byte-identical B3 image in **250.719 s**. B2 also freshly type-checks its
own complete source in **29.681 s**, while retaining the explicit proof-trust
refusal for its 3,012 unsafe definitions. These are separate executed gates.

The installed package now uses the checked **B1 `string01`** API. Installation,
verification before and after smoke testing, 42 explicit legacy checks and 24
default direct checks all pass. B2 and B3 remain separately qualified emitted
direct compiler images; neither replaces the installed B1 API or its checked
attempt. The
[Phase56 equality report](../../implementation/phase56/string-equality.md)
records their exact identities and retained results.

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

Those Phase55 changes add 27 physical lines. The fixed-source image before and
after the second change is byte-identical, including all public/private exports,
runtime code and host wrappers. Export generation falls from 121.4 to 20.9 s.

Phase56 additionally implements canonical native `String.eq` with JavaScript
strict equality inside its function definition. Ordinary call sites retain
their argument ordering and partial-application behavior. This avoids repeatedly
walking the Base comparison implementation for primitive JavaScript strings,
without adding a compiler cache or changing the runtime. The existing native
identity and arity checks still exclude same-named user functions.

## Current qualification

| Gate | Phase56 result |
| --- | --- |
| Checked B1 build and focused frontend | PASS, 36 probes |
| B1 emits its complete B2 image | PASS, 84.426 s, all 77 requested API roots |
| Ordinary source/direct driver comparison | PASS, eight exact observations, including emitted JS/C bytes |
| B2 emits B3 through the ordinary unsplit API | PASS, 250.719 s, complete image byte equality |
| B2 freshly checks its own source | Types accepted in 29.681 s; proof-trust refusal retained |
| B2 semantic controls | PASS, 96 source, 34 numeric, 18 composition and two overapplication cases |
| Installed checked B1 release | PASS, installation, both verifications, 42 legacy and 24 default checks |

B2 and B3 are both **3,896,951 bytes**, SHA256
`3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`.
The checked B1 package API has the distinct SHA256
`128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`.
The [conformance report](../../implementation/phase56/conformance.md) records
the independent semantic oracles and their overlapping scopes. These counts do
not establish full-language conformance; the pinned TypeScript reference's
documented NaN failures remain visible.

## Reproduction and the fast loop

The [Phase56 report](../../implementation/phase56/string-equality.md) identifies
the current generation, reproduction and fresh-check receipts. The historical
[Phase55 report](../../implementation/phase55/README.md) and its publication
index preserve the earlier source/generator comparison. Raw build paths identify
retained experiment directories; restore archived evidence before replaying
frozen plans. Historical plans contain absolute paths and must be rebound to a
fresh checked attempt when working in another checkout. Do not overwrite
consumed attempts or receipts.

1. Build one checked candidate with the [development workflow](../PHASE5_DEVELOPMENT.md).
2. Run focused controls for the changed mechanism against the prior checked
   compiler. Phase56 includes 484 String pairs and callback, throw, partial-call
   and native-identity controls.
3. Keep the compiled subject fixed while changing the generating compiler. The
   restricted image first proves the instrumented emission path equals the
   ordinary library call exactly; then emit the full 77-root compiler image.
4. Compare complete module bytes and run the resulting image through the
   unchanged driver. Generation success alone is insufficient.
5. Emit the candidate's own source separately, then use that actual direct image
   for B2→B3 reproduction and a separate fresh source check. Run broad semantic,
   native and release checks for the selected candidate. Reuse dated program
   timings only when the complete benchmark modules remain byte-identical.

The [Phase56 recipes](../../selfhost/tools/performance/phase56/README.md) name the
current controllers, selected image bindings and plans. The
[Phase55 method guide](../../selfhost/tools/performance/phase55/README.md) retains
the older experiment; its whole-source pins are not a String01 replay recipe. Compiler jobs use one CPU, a 1 GiB Node heap,
a 2 GiB process-tree RSS limit and a 4 GiB available-memory floor. Analysis and
review can run concurrently without competing benchmark workloads.

## Bootstrap boundary

The generating checked B1 image still descends from the pinned TypeScript seed
and reviewed image transforms. The emitted B2 images contain the compiler
implemented in Bend and use the direct runtime. Normal compilation has no
TypeScript fallback.

The emission runs inherit checking of the exact frozen source. The separate
fresh B2 check starts with an empty private Base cache and accepts the source's
types, but reports `proofTrust: failed` and `kernelChecked: false`: all 3,012
definitions remain explicitly unsafe, with no additional unsafe declarations.
Neither type acceptance nor B2/B3 byte equality is a mathematical correctness
proof. Migration of every legacy image-transform client remains separate; the
working checked bootstrap stays available.

## Remaining compiler costs

The successful B2→B3 run spends **89.031 s** in emitted reachability and
**111.679 s** in the unsplit library-emission call. These measured stage timings
identify substantial remaining work; they do not attribute it to a particular
algorithm, allocation pattern or JavaScript optimization decision.

The previous B2 reproduction exceeded its **300 s** deadline. Its separate
55.839 s fresh check ran under V8 profiling, whereas the new 29.681 s check was
unprofiled and used changed source, so those checks do not provide a controlled
speedup ratio. The retained flat profile identified `String.cmp` and its helper
as hot code; the full offline profile processor later hit its isolated 512 MiB
heap limit. A summary-only processor completed. These facts support the equality
experiment without claiming complete profile attribution or a compiler/system
OOM.
