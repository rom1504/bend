# Checked bootstrap, native hosting and release reconciliation

The quickest test of our own C backend is to ask the existing JS-hosted Bend
compiler to compile the exact frozen native89 source S. This avoids another
600-second attempt by the slow upstream-built native host. It is a **cross-host
build by a Bend compiler**, not evidence that the native B1 emitted its own B2.
Clang compilation, native execution, self-reproduction and public launcher
admission are separate gates.

## First discriminator and required source repair

The original [worker](../../selfhost/tools/performance/phase90/bootstrap/emit-self.mjs)
uses the installed Phase82 B2 `098320e8…` and its previously prepared, API-specific
Base cache. It calls ordinary `inspect(..., {mode:'native'})`; it does not inject
an API, omit checking or broaden file-effect representation permissions.

Root's retained `selfhost/build/phase90/js-self01/report.json` records a failed
request after **23.178 seconds**, at **859,420 KiB** maximum RSS. The diagnostic
attributes the JavaScript stack overflow to `ns_image_terms`, which recursively
constructs a list containing the full native static image. This is distinct from
the native89 600-second self-emission timeout. Root owns the canonical repair of
both `ns_image_terms` and `ns_image_words`; new accumulator/reversal helpers must
be checked and compared before producing a new compiler image.

The next [worker](../../selfhost/tools/performance/phase90/bootstrap/emit-self-v2.mjs)
takes `CHECKED_ATTEMPT NEW_OUT`. It verifies the completed equality-derived B1
and strict frontend gate, uses its frozen driver and runtime, and prepares/verifies
the **new API's own** checked Base cache. Its report records the actual checked B1
parent. The old failed worker is preserved; a repaired B1 must not be relabelled
as the old B2. Import, Base preparation and request timings are separate.

The new checked B1/frontend gate passed, but `js-self02/report.json` records a
second failed complete-source C request: **73.166 seconds**, **1,172,248 KiB**
maximum RSS. It progressed beyond static-image conversion and overflowed during
final segment wrapping. This is another real scale bug, not a passing native
compiler build. Root owns the follow-up traversal repair.

[emit-self-v3.mjs](../../selfhost/tools/performance/phase90/bootstrap/emit-self-v3.mjs)
accepts `IMAGE_PINS QUALIFICATION_METHOD_PLAN NEW_OUT` for the faster genuine B2
diagnostic loop. It replays the recorded setup derivation, verifies real checked
generator/emission/eight-driver receipts through the unchanged reviewed setup,
and uses a private byte-identical ordinary driver with a new API-specific Base
cache. `Error.stackTraceLimit=100` helps localize additional overflow failures;
it changes no compiler source or permission. The original v1/v2 workers remain
frozen. Merely preparing this worker does not establish that the new B2 emitted S.

The frozen native subject remains source SHA
`4584cf083d9eddad6f1290c9472c3aac2708099caa716a27f5b53fbcbaee1618`
(1,755,310 bytes). Its nine effect providers, Base, native runtime and transport
assets are checked before and after emission. All four scalar/array/constructor
permission macros remain zero for this file-effect program. C output is capped
at 64 MiB. No new public cache consumer is admitted.

## Root-run checked B1 and genuine B2 workflow

All scripts below prepare or bind evidence unless explicitly described as target
workers. This audit ran no compiler or native target; root serializes the target
jobs under the existing memory/time guard. Python AST and worker JavaScript syntax
checks passed. The data-only `qualification-method01/plan.json` was prepared for
compiler01. Qualification and release plans are not completed gates.

1. Run the maintained checked workflow with
   [development.json](../../selfhost/tools/performance/phase90/bootstrap/development.json):
   equality profile, strict frontend36, one job, CPU3, 1 GiB JavaScript heap and
   4 MiB stack. Use a fresh `selfhost/build/phase90/compiler01` attempt and the
   180-second/2-GiB/4-GiB-available outer guard. This checks the inherited Phase88
   text/emit/observer changes and the new static-image repair together.
2. Run root's focused full-product/static-image controls. Run `emit-self-v2.mjs`
   with that exact attempt under a separate guard. The ordinary whole-source
   native emission remains the actual feasibility gate.
3. Use [prepare-bootstrap.py](../../selfhost/tools/performance/phase90/bootstrap/prepare-bootstrap.py)
   `plan ATTEMPT NEW_B2_DIRECTORY --admission
   selfhost/build/phase82/compiler04-admission.json`. This is an exact derivative
   of the Phase82 preparer, changing only its fresh output root to Phase90.
   The preserved admission remains valid only if the existing export and frozen
   driver checks succeed; no new roots are silently added for internal helpers.
4. Run the generated tiny split/unsplit control, full B2 emission and two eight-case
   driver probes serially. Compare the probes, then run the preparer's `pins`
   mode with the actual emission and comparison. This produces real B2 identity
   and receipts; it creates no upstream bootstrap report for B2.
5. Use [prepare-qualification.py](../../selfhost/tools/performance/phase90/bootstrap/prepare-qualification.py)
   with `--attempt ATTEMPT --b2 B2_DIRECTORY --out NEW_METHOD_DIRECTORY
   --qualification-out NEW_QUALIFICATION_DIRECTORY`. It copies the reviewed
   Phase67 setup/self-check/reproduction methods, verifies their frozen hashes,
   and changes only fresh Phase90 output paths. Run its two commands: a fresh
   B2 own-source check, then exact unsplit B2/B3 equality. The expected explicit
   unsafe proof-trust refusal remains separate from type acceptance.
6. After root reviews focused native/JS correctness and performance continuity,
   use [prepare-release.py](../../selfhost/tools/performance/phase90/bootstrap/prepare-release.py)
   with `--attempt`, `--b2`, `--qualification`, fresh `--out`, and the actual
   `--cc` / `--cpath` toolchain paths. It requires passed self-hosting receipts
   and prepares the real `release.mjs --install-b2 ATTEMPT IMAGE_PINS QUALIFICATION`
   command, followed by verification, B2-aware legacy42, default24 including
   relocation, and final verification. It does not execute installation.

The old Phase82 qualification preparer generated `--install-attempt`, which would
select B1. It is deliberately not reused for this B2 release. The B1-only helper5
controller is likewise not treated as a B2 package control. Actual installation
joins original checked B1 lineage, new B2 emission, driver comparison, fresh
own-source check and fixed-point receipts, and verifies live checkout bytes.
Rebinding the old release manifest to new source would not establish any of this.

The previous selected core workflow took approximately 245 guarded seconds
(checked build, tiny/full B2 emission, driver probes, self-check, fixed point,
install and release smoke). That is historical planning evidence, excluding new
focused gates, preparation/restoration and any new failures; it is not a promise
for the current run. It is much smaller than repeating an entire prior campaign.

## Native executable gates after successful C emission

[bind-build-v2.py](../../selfhost/tools/performance/phase90/bootstrap/bind-build-v2.py)
binds actual checked B1 C emission, guarded Clang command/input identities and the
resulting binary. [bind-build-v3.py](../../selfhost/tools/performance/phase90/bootstrap/bind-build-v3.py)
instead joins the actual v3 B2 producer/generator pins and final setup verification.
Neither grants launcher/cache admission or manufactures an upstream acquisition
receipt. The original installed-B2-specific binder is preserved.

Our retained C runtime omits `argv[0]`, whereas the private frozen `p86_cli` source
expects a leading program element. Invoke a successor binary with an explicit
sentinel **after** `--`, for example:

```text
CANDIDATE --threads 1 --gpu off -- phase90-native INPUT BASE RUNTIME EFFECT_DIR OUTPUT_PREFIX 1
```

Using the native89 argument helper unchanged would shift every argument. First
qualify live Small, Map, Unicode and file IO against independent ordinary Bend C
outputs. Then qualify the same requests with the private cache carrier and its
exact producer/consumer identities. Keep the existing native89 public launcher
restricted to its previously admitted binary/source/C tuple. A new native binary
must not inherit admission merely because it consumes the same carrier.

Phase89 already tested the retained runtime's argv behavior, decoder, successful
Unicode/empty file IO and refusal cases. If a successor compiler emits identical
program C, those runtime results can support that exact artifact; they do not
replace executing the new compiler's live/cache requests. Subsequent native
self-emission/fixed-point comparisons must use exactly the same frozen S, Base,
runtime/effects and input transport. Upstream-emitted C and our backend's C need
not match each other byte for byte.

## Bounded recursion and capacity audit

The static image is capped at 65,536 words. After the two conversion repairs,
its final length/join path uses tail-recursive `nt_count` and the Phase88 linear
text builders; runtime template joining traverses only four payloads/five chunks.
No additional obvious recursion over the entire image was found in this bounded
source audit. `ns_words` handles one constructor/product's fields; `ns_static_terms`
still follows AST depth and child width. `nv_ctor_names` remains right recursive
over constructor declarations, not static-image words. These are potential
separate scale limits, not demonstrated failures of the frozen S request.

The subsequent segment audit found the active `nf_wrap_segments` recursion and
the related `no_wrap_registered` traversal. `no_entry_defs` is also non-tail over
the full segment list, though file-effect S bypasses that observer-permission
branch. Table segment traversals, segment-name validation and final segment text
emission already use tail recursion. Late worker adapter/prototype/body builders
have separate non-tail recursion proportional to worker count, not the much
larger generated continuation count. Root is selecting the scoped repairs; this
audit does not claim their correctness or stack safety before controls.

The follow-up source review of `nf_wrap_segments_rev`, `no_entry_defs_rev` and
`no_wrap_registered_rev` found the same head computation/filter, left-to-right
processing, exact preserved segment fields and a single final reversal. The
`+entries` accumulator annotation is needed where both branch closures capture
the existing entries. Earlier syntax/affine failures remain root's separate
checked-build evidence; this source review is not a substitute for checking.

[segment-controls.mjs](../../selfhost/tools/performance/phase90/bootstrap/segment-controls.mjs)
is prepared for two **full exported APIs**. The genuine compiler01 B2 exports
these internal traversal functions; the checked B1 API does not expose all of
them. The harness compares 24 small complete products against the historical
API, including actual flat/product and nonempty observer wrappers, refused
arity/frame/kind/readiness combinations, empty routes, and composition. Four
65,536-segment candidate-only variants check every output field/order/body and
retained input without recursively serializing the long list. The large body
oracle is built from small historical wrapper outputs; entry eligibility/fields
also have an independent host-side fixture oracle. At preparation time only
syntax and export-presence checks ran; root executes and records target results.

The backend rejects more than 65,532 runtime segments, 65,536 constructors or
8-bit arity overflow. S has 3,974 `def` lines, 159 `type` lines and 656 `law` lines;
definition count does not bound closure-generated segments. Its size fits the
private 16-MiB source limit, but emitted C/Clang resource costs are still unknown.
The outer guard, not `inspect`'s asynchronous timeout option, bounds a synchronous
compiler request.

## Rechecking a native-profile source derivative upstream

[acquire-native.mjs](../../selfhost/tools/performance/phase90/acquire-native.mjs)
prepares the separate real upstream-built B1 lane. It accepts the exact native89
checked parent receipt, a source derivation receipt and a fresh Phase90 output
directory. The old parent's 279 input identities include historical checkout
files that have since changed; those remain preserved provenance, rather than
being misrepresented as source consumed by this new acquisition.

The new worker authenticates parent receipt `eb6d7435…`, frozen parent S `4584…`,
Phase86 upstream receipt `32bb9a91…`, all 67 upstream source/provider identities
and Node24.18.0 bytes. It independently replays and reverses the source edits,
copies the exact derivative, then runs actual upstream `book_load`, `book_valid`
with zero holes, `js_book` and `compile_book`. Loaded source and declared foreign
paths must belong to the admitted source/Base/upstream inputs. Every consumed
input is checked again after emission. A new `phase90-checked-upstream-native-source-derivative`
report records the real stages; no native B2 or cache admission is created.

The five-table receipt and the combined tables/stack-fix `.assembly.json` receipt
both passed offline input-hash and exact forward/inverse replay checks. The
combined source is `74b390d3…`; its normalized receipt is `209d3dfa…`. These checks
only establish the declared text transformation. Full acquisition/build and
live/cache/exact-C qualification remain root-run target gates. The existing
Phase86 build binder and `native_support.authenticate(image, None)` can consume
the eventual real checked report without relabelling its producer kind.
