# Generating the compiler with its direct JavaScript backend

A compiler image is an executable JavaScript module containing the compiler's
Bend implementation and its public API. Generating that module is a much larger
compilation than compiling a small user program. It is also distinct from running
the resulting compiler or measuring programs compiled by it.

Installed **Phase61 state08** uses a checked B1 API. Its genuine direct B2
freshly type-checks the complete source in **11.397 s of check-request time**
(**17.248 s internal / 17.385 s supervised**) and emits a byte-identical B3 in
**34.386 s internal / 34.568 s supervised**. All 3,192 unsafe definitions retain
the expected proof-trust refusal. Type acceptance, reproduction and installation
are separate gates; none establishes kernel proof validity.

Release installation, integrity verification, 42 explicit legacy checks and
24 default ordinary/relocated checks pass. B2/B3 remain separately qualified
direct compiler images; the installed package retains its checked B1 lineage.
The [State08 results](../../implementation/phase61/state08-results.md) bind the
artifacts and completed gates, including preserved failures and their successors.

## Current changes: Phase61

The [compiler-request guide](compiler-request-pipeline.md) explains prepared
frontend state, private loader provenance, dependent-term cursors, persistent
books, structured emission metadata and host transport. Its fallback and trust
boundaries remain explicit. The [source footprint](../../implementation/phase61/source-footprint.md)
separates Bend changes from the changed typed driver/workflow and unchanged native
modules and runtimes.

## Retained changes: Phase58

The [allocation guide](compiler-allocation.md) explains six retained changes:
record-key syntax, constructor queries, scalar Word residuals, literal-choice
continuations, distinct emitted dependency edges and one dispatcher per mutual
tail component. Their typed admission and fallback rules remain separate from
runtime helpers and from saved-image diagnostic transformations. At that
checkpoint, native modules, runtimes and the typed driver retained Phase56 bytes.

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

## Current qualification: Phase61

| Gate | State08 result |
| --- | --- |
| Checked B1 build and frontend controls | PASS, 36 strict paired probes and final 14-step checked matrix |
| B1 emits complete genuine B2 | PASS, 86 roots, six bootstrap commands and eight ordinary-driver observations |
| B2 fresh own-source check | PASS type acceptance; expected refusal for 3,192 unsafe declarations |
| B2 emits B3 | PASS complete image byte equality |
| Genuine B2 semantic matrix | PASS; original failed receipt-validation attempt preserved |
| B2 versus selected B1 program emission | PASS, 23 raw modules and their 45-point mapping equal |
| Installed checked B1 release | PASS, integrity, 42 legacy and 24 default ordinary/relocated checks |

B2/B3 are **3,978,248 bytes**, SHA256
`23bd6a48b9ed48b58bdc81245c3e40978735f8386c3eb6029b92701511986477`.
The installed checked B1 API SHA256 is
`97f412afb692cc9f187144e418fb153f35f62fb6ff5eda698e28ebc3eaf260c8`.
Their complete checked source SHA256 is
`268b3cf2e1f1c2810c372925ccd1ad7eb91225853d432ca9517f05f2ecefd42e`.
The [results matrix](../../implementation/phase61/state08-results.md) records the
individual scopes; overlapping gates are not a unique whole-language test count.

## Historical qualification: Phase58

The following results retain their original last01 artifact and source scope.

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
The Phase58 checked B1 package API had the distinct SHA256
`641381f638f1f4c1c8b349bef06502b42738c1c7feff0391f2e09b90f4ef282a`.
Their common checked source is
`85454aab7a6ef25d1e78970b1c24d68ac2a90a23a4b39b64a30de311c2fc5091`.
The [qualification record](../../implementation/phase58/validation.md) separates
independent semantic oracles and overlapping scopes. These counts do not establish
full-language conformance; pinned TypeScript's documented NaN failures remain
visible. Emission phase timings include diagnostic progress and identity work,
and are not warmed request-throughput measurements.

## Reproduction and the fast loop

The [State08 results](../../implementation/phase61/state08-results.md) identify
the current generation, reproduction and fresh-check receipts. The historical
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
   ordinary library call exactly; then emit the full selected export closure
   (86 roots for State08).
4. Compare complete module bytes and run the resulting image through the
   unchanged driver. Generation success alone is insufficient.
5. Emit the candidate's own source separately, then use that actual direct image
   for B2→B3 reproduction and a separate fresh source check. Run broad semantic,
   native and release checks for the selected candidate. Reuse dated program
   timings only when the complete benchmark modules remain byte-identical.

The [State08 results](../../implementation/phase61/state08-results.md)
name the selected gates and image bindings. Historical
[Phase56 recipes](../../selfhost/tools/performance/phase56/README.md) need newly
bound inputs; their retained results remain in the
[Phase56 report](../../implementation/phase56/string-equality.md). The
[Phase55 method guide](../../selfhost/tools/performance/phase55/README.md) retains
the older experiment; its whole-source pins must be rebound for the current
source. Compiler jobs use one CPU, a 1 GiB Node heap,
a 2 GiB process-tree RSS limit and a 4 GiB available-memory floor. Analysis and
review can run concurrently without competing benchmark workloads.

## Bootstrap boundary

The generating checked B1 image still descends from the pinned TypeScript seed
and reviewed image transforms. The emitted B2 images contain the compiler
implemented in Bend and use the direct runtime. Normal compilation has no
TypeScript fallback.

The emission runs inherit checking of the exact frozen source. The separate
fresh B2 check starts with an empty private Base cache and accepts the source's
types, but reports `proofTrust: failed` and `kernelChecked: false`: all 3,192
definitions in the selected source remain explicitly unsafe.
Neither type acceptance nor B2/B3 byte equality is a mathematical correctness
proof. Migration of every legacy image-transform client remains separate; the
working checked bootstrap stays available.

## Current compiler-request measurements

The balanced [State08 campaign](../../implementation/phase61/state08-results.md#balanced-broad-compiler-measurements)
passes all **207 workers: 23 sources × three roles × three rounds**. Equal-source
median B2/TypeScript geometric means improve **2.476542× → 1.433877×** for
import + API load + first compilation and **3.816429× → 2.071828×** for
compilation alone.
These are genuine B2 requests in fresh processes with prepared persistent Base
caches; preparation and post-return byte validation are outside the clean clocks.
They are not cold OS-cache or installed checked-B1 CLI measurements. No new
669-sample generated-program runtime campaign or speedup is claimed.

## Historical costs: Phase58

The Phase58 B2→B3 run spent 7.497 s in emitted reachability and 8.217 s in the
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
