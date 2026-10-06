# Full compiler image: ordinary-driver gate

The Phase55 split emission separates the **subject compiler source** from the
**generator compiler API**. The controlled comparison subject remains Phase54 graph02, source
SHA256 `32cddcf1a970a9726a9785b30269cdd8a0047f917f769a964995fa6a0633de84`.
Consequently the ordinary-driver source oracle is Phase54 graph02's checked API,
even if a newer generator emits the direct image. Comparing with the generator's
own changed source would answer a different question.

The additive [driver probe](../../selfhost/tools/performance/phase55/bootstrap/driver-probe.mjs)
accepts a successful Phase55 full-image receipt, verifies both checked attempts,
the exact subject source, the append-only API derivation, all consumed inputs,
output module, runtime and requested 77 roots. Each source/direct role copies
identical subject driver/runtime bytes into its own fresh directory. Ordinary
Base caches therefore bind the actual role API hash and cannot modify a frozen
attempt or accidentally reuse the other role's cache.

The probe calls unchanged `loadApi`, `inspect` and `execute`, using an explicit
`BEND_TYPED_API`. It supplies no injected API override and has no fallback route.
Its eight existing-fixture requests cover parse success and rejection, check
success and rejection, JavaScript emission, execution returning `42`, C emission,
and successful check replay after the failures. C execution and compiler-source
self-check are separate gates. Durable progress records show where a bounded
worker stops if importing or using the full image proves expensive.

The [data-only comparison](../../selfhost/tools/performance/phase55/bootstrap/compare-driver.mjs)
requires exact observations, diagnostic text and emitted JS/C byte hashes. Only
role-local input file paths are represented by their verified content hashes.
It also requires identical subject, generator and emission bindings. Source and
direct workers are serialized under the existing supervisor; the prepared plan
is `selfhost/build/phase55/bootstrap-driver-plan01/plan.json`.

## Executed generation and driver results

The optimized generator completed the fixed Phase54 subject in **96.2277 seconds**
(`selfhost/build/phase55/bootstrap-full-host02/report.json`). Its 3,895,592-byte
module has SHA256 `6c8055de86c34065ce7ff76a851835e039046ab23e1da707406345d9dc5cb090`,
exactly the earlier arity01 image. That image passed all **eight exact driver
comparisons**, retained in
`selfhost/build/phase55/bootstrap-driver-arity01-comparison.json`. This is an
explicit same-byte qualification join, not a second driver execution for host02.

The separate host02 own-source image completed in **103.9479 seconds**
(`selfhost/build/phase55/bootstrap-own-host02-full01/report.json`). Its
3,900,194-byte module has SHA256
`ae5abd461c24f707747f37b187cedcecd86f5d3c727950f8f8a332fd9dca4091`.
Its own source/direct workers passed all **eight exact comparisons** in
`selfhost/build/phase55/bootstrap-own-host02-driver-comparison01.json`.
These are complete full-image generation and ordinary-driver usability results.
Emission inherited exact-source checking from the checked subject; neither run
freshly checked the compiler source using the generated direct image.

## Conditional export-cost follow-up

[jd_host_exports](../../selfhost/src/back/js/direct/host.bend#L218) currently
creates a public wrapper for every eligible selected non-Base definition. The
compiler bootstrap requests 77 public roots but their reachable private helper
closure can be much larger. Each wrapper runs compile-time arity and host-type
analysis, including result, input and input-writeback Nat-conversion queries.
This is a structural source observation. A read-only inventory of the frozen
subject driver found all 69 actual literal API method references within the 77
roots, as well as every entry in its dynamic loader/backend requirement lists.
This establishes interface coverage, not executed behavior of the new image.
The split diagnostic subsequently established the cost of its separate
`library-exports` phase.

If exports dominate after the profiled constructor-query fix, a small additive
interface could take **private definitions and explicit public roots separately**:
`jd_library_selected_exports(book, definitions, exportNames)`. It would keep all
private definitions, their call graph and dependency closure; only public wrapper
selection would use the requested names. Validate unique requested names and
eligibility, preserve the documented public key order, and fail on a missing
root. Keep ordinary `jd_library_selected` and library CLI export behavior intact.
A host facade that hides extra keys after import does not avoid their generation.

The comparison would require identical private generated definitions, exactly
the requested public keys, unchanged method values/results/errors, and the full
ordinary-driver gate above. This changes the explicit export inventory, so it
must be a separately recorded experiment rather than weakening the existing
full-output byte-equality gate. No export selection, compiler source, or consumed
split tool was changed here. The selected optimization retains the full export
inventory; explicit-root export selection remains unimplemented.

The unconsumed per-export diagnostic successor is
`selfhost/tools/performance/phase55/bootstrap/emit-split-v2.mjs`. It calls the
existing `jd_host_exports(book, [definition])` for every selected definition in
order, retaining the original predicate and wrapper analysis. Durable events
record each name, source kind, declared arity, duration and output size. Its tiny
gate requires exact concatenated-versus-whole export bytes and complete
split-versus-original library bytes before a full run is allowed. It does not
filter private helpers. Diagnostic forcing, concatenation and progress IO can
affect timing and GC, so these stage times are not a clean compiler benchmark.

The root deferred that additional per-export run after the first complete v1
image showed 121.39 seconds in exports out of roughly 198.5 seconds overall.
The selected experiment instead addressed repeated host-type analysis and
retained complete fixed-subject module bytes. Per-export v2 remains prepared,
unexecuted, and conditional on an unresolved export-cost question.

## Own-source identity and scope

`selfhost/build/phase55/bootstrap-own-host02-plan01/plan.json` records the separate
sequence for the optimized compiler's own source. It binds `checked-host02` API
`cfde1ebf44d958e593331cfd9af77f7b6ee657441dbd582db8d27f3928815a62` and its exact
assembly `e4383fa08d621716acac437224de182af52e0b16c32b3f29b2614fc1ad1d6710`,
retaining the same 77 public roots and unchanged core/driver/runtime pins. Its
source oracle is the host02 checked API, matching that own-source subject.
Tiny/full/driver outputs are fresh and separate from the fixed Phase54 comparison.
Its executed results are recorded above. They do not establish fresh direct-image
self-checking, direct self-emission, or a compiler fixed point.

## Deferred next gate: direct self-emission

The bounded follow-up would use this direct image (B2) through the unchanged
ordinary driver and its unsplit `jd_library_selected` API to emit the same exact
host02 source as B3. Admission would join the checked host02 source/bootstrap,
the successful B2 emission receipt, and its successful ordinary-driver comparison;
B2 would remain an emitted image, never a fabricated checked attempt. Retain the
same 77 roots, runtime, frontend completion stages and inherited-check lane,
then require complete B2/B3 byte equality without normalization. Durable phase
progress and the existing bounded process limits would make failure reviewable.

This would establish an **emission fixed point**, separately from fresh compiler
self-checking. No B2→B3 tool or execution was added in this phase. Direct
self-emission, fresh self-check, and migration of the remaining legacy compiler
clients are deferred: this scoped timeout fix ends with full generation and
ordinary-driver qualification.
