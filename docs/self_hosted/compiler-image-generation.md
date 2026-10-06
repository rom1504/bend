# Generating the compiler with its direct JavaScript backend

A compiler image is an executable JavaScript module containing the compiler's
Bend implementation and its public API. Generating that module is a much larger
compilation than compiling a small user program. It is also distinct from running
the resulting compiler or measuring programs compiled by it.

Phase58's direct B2 compiler emits a complete, byte-identical B3 in **39.199 s**
and freshly type-checks its own complete source in **11.712 s**. The latter retains
the explicit proof-trust refusal for all 3,055 unsafe definitions. These are
separate executed gates; reproduction inherits exact source checking and does
not replace the fresh check.

The installed package uses the checked **B1 `last01`** API. Installation,
release verification, 42 explicit legacy checks and 24 default/relocated checks
pass. B2 and B3 remain separately qualified direct compiler images; neither
replaces the installed B1 API or its checked attempt. The
[Phase58 report](../../implementation/phase58/README.md) binds their identities.

## Current changes

The [allocation guide](compiler-allocation.md) explains six general changes:
record-key syntax, constructor queries, scalar Word residuals, literal-choice
continuations, distinct emitted dependency edges and one dispatcher per mutual
tail component. Their typed admission and fallback rules remain separate from
runtime helpers and from saved-image diagnostic transformations. Native modules,
runtimes and the typed driver retain their Phase56 bytes.

## Earlier changes: Phases55–56

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

| Gate | Phase58 result |
| --- | --- |
| Checked B1 build and focused frontend | PASS, strict 36 probes and final broad matrix |
| B1 emits its complete B2 image | PASS, 76.859 s, all 77 requested API roots |
| Ordinary source/direct driver comparison | PASS, eight exact observations, including emitted JS/C bytes |
| B2 emits B3 through the ordinary unsplit API | PASS, 39.199 s, complete image byte equality |
| B2 freshly checks its own source | Types accepted in 11.712 s; proof-trust refusal retained |
| B2 semantic controls | PASS, 96 source, 34 numeric, 18 composition and two overapplication cases |
| B2 versus selected B1 program emission | PASS, all 23 raw source modules and 45 observed points equal |
| Installed checked B1 release | PASS, installation, integrity, 42 legacy and 24 default checks |

B2 and B3 are both **3,821,470 bytes**, SHA256
`a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081`.
The checked B1 package API has the distinct SHA256
`641381f638f1f4c1c8b349bef06502b42738c1c7feff0391f2e09b90f4ef282a`.
Their common checked source is
`85454aab7a6ef25d1e78970b1c24d68ac2a90a23a4b39b64a30de311c2fc5091`.
The [qualification record](../../implementation/phase58/validation.md) separates
independent semantic oracles and overlapping scopes. These counts do not establish
full-language conformance; pinned TypeScript's documented NaN failures remain
visible. Emission phase timings include diagnostic progress and identity work,
and are not warmed request-throughput measurements.

## Reproduction and the fast loop

The [Phase58 report](../../implementation/phase58/README.md) and
[qualification record](../../implementation/phase58/validation.md) identify the
current generation, reproduction and fresh-check receipts. The historical
[Phase55 report](../../implementation/phase55/README.md) and its publication
index preserve the earlier source/generator comparison. Raw build paths identify
retained experiment directories; restore archived evidence before replaying
frozen plans. Historical plans contain absolute paths and must be rebound to a
fresh checked attempt when working in another checkout. Do not overwrite
consumed attempts or receipts.

1. Build one checked candidate with the [development workflow](../PHASE5_DEVELOPMENT.md).
2. Run focused controls for the changed mechanism against the prior checked
   compiler. Phase58 includes constructor/prototype, residual-bit, callback,
   reachability-budget and shared-dispatcher controls; preserve earlier semantic
   and native-identity gates as separate checks.
3. Keep the compiled subject fixed while changing the generating compiler. The
   restricted image first proves the instrumented emission path equals the
   ordinary library call exactly; then emit the full 77-root compiler image.
4. Compare complete module bytes and run the resulting image through the
   unchanged driver. Generation success alone is insufficient.
5. Emit the candidate's own source separately, then use that actual direct image
   for B2→B3 reproduction and a separate fresh source check. Run broad semantic,
   native and release checks for the selected candidate. Reuse dated program
   timings only when the complete benchmark modules remain byte-identical.

The [Phase58 qualification record](../../implementation/phase58/validation.md)
names the selected gates and image bindings. Historical
[Phase56 recipes](../../selfhost/tools/performance/phase56/README.md) need newly
bound inputs; their retained results remain in the
[Phase56 report](../../implementation/phase56/string-equality.md). The
[Phase55 method guide](../../selfhost/tools/performance/phase55/README.md) retains
the older experiment; its whole-source pins are not a last01 replay recipe. Compiler jobs use one CPU, a 1 GiB Node heap,
a 2 GiB process-tree RSS limit and a 4 GiB available-memory floor. Analysis and
review can run concurrently without competing benchmark workloads.

## Bootstrap boundary

The generating checked B1 image still descends from the pinned TypeScript seed
and reviewed image transforms. The emitted B2 images contain the compiler
implemented in Bend and use the direct runtime. Normal compilation has no
TypeScript fallback.

The emission runs inherit checking of the exact frozen source. The separate
fresh B2 check starts with an empty private Base cache and accepts the source's
types, but reports `proofTrust: failed` and `kernelChecked: false`: all 3,055
definitions remain explicitly unsafe, with no additional unsafe declarations.
Neither type acceptance nor B2/B3 byte equality is a mathematical correctness
proof. Migration of every legacy image-transform client remains separate; the
working checked bootstrap stays available.

## Current measurements and remaining costs

The selected B2→B3 run spends 7.497 s in emitted reachability and 8.217 s in the
unsplit library-emission call. These are observed stage times, not evidence that
either cost is wholly removable. The [compiler latency report](../../implementation/phase58/latency.md)
separates clean first/later requests from instrumented emission and saved-image
experiments. Program execution is measured separately.

## Historical costs: Phase56

The Phase56 B2→B3 run spent **89.031 s** in emitted reachability and
**111.679 s** in the unsplit library-emission call. These measured stage timings
identified substantial work at that checkpoint; they did not attribute it to a particular
algorithm, allocation pattern or JavaScript optimization decision.

Before that Phase56 success, the prior B2 reproduction exceeded its **300 s** deadline. Its separate
55.839 s fresh check ran under V8 profiling, whereas string01's 29.681 s check was
unprofiled and used changed source, so those checks do not provide a controlled
speedup ratio. The retained flat profile identified `String.cmp` and its helper
as hot code; the full offline profile processor later hit its isolated 512 MiB
heap limit. A summary-only processor completed. These facts support the equality
experiment without claiming complete profile attribution or a compiler/system
OOM.
