# Native compiler runtime migration and request assets

The migration keeps the compiler in Bend and removes the diagnostic C patch from
the final native image. Source D04 is unchanged. Native06 and genuine JS B2 each
compiled it with the new runtime and produced exactly the same 38,614,882-byte C
file, SHA-256
`dae071f0fae7aec4ae8036ccebe4954690a249e32f59a87ac485b2fa428016bf`.
The complete offline provenance join is recorded in
[`new-runtime-cross-host-equality.json`](new-runtime-cross-host-equality.json).

The actual native07 `-O2` build completed in 308.201 seconds with a
4,172,177,408-byte peak RSS. Its C input was the unpatched native06 emission,
independently equal to genuine JS B2. The image SHA-256 is
`d7c7a47917884b14fd3ef37471d9f2a8660d7c4ab9bcc93a249c7cb6d0e37d3e`.
[`native07-build-binding-preflight.json`](native07-build-binding-preflight.json)
records the offline binding check. Native07 then emitted its complete own-source
C in 164,322 ms, exactly equal to the native06 and genuine JS B2 outputs.
`native07-self01/report.json` records that successful actual request (SHA-256
`32cdb739600b73471e4579ab783f0503957b51b2eec81a5ad68097baa24cbc69`).
`native07-qualification01/report.json` passed all eight live/cached C checks, two
expected compiler rejections, and four generated-program builds/executions
(SHA-256 `81e9eaf6031c01f3fd88d9777e5944d857ca6e655c17242be23ed5b0e18c95e1`).
These are actual completed targets, separate from the build and offline checks.
Final admission is
`selfhost/build/native/releases/phase90-native07/admission.json`, SHA-256
`06c90774a4886aa0dedbb0f8c3847ecc7da6f124ae28d13e92040309d8a62926`.

Only three historical mutable paths needed explicit migration: the runtime,
runtime-template JSON, and typed driver. Before canonical integration,
`runtime-transition01/transition.json` froze their old bytes and the native06
producer identities. Historical receipts are unchanged. Authentication maps an
old identity to a frozen copy only when both the original path and bytes match
that explicit transition. New requests name the new runtime transport separately.
This avoids claiming that a qualified historical producer originally contained
the new runtime.

The new request launcher verifies a selected admission and its binary, Base,
runtime parts, effect files and optional immutable Base carrier. It does not
start Node or rehash the entire experimental ancestry for each compiler request.
Full ancestry is checked when admitting the image, then the admission is sealed.
The source-location ABI still binds the original checkout path; relocation is
not silently accepted.

The public asset capsule is deliberately smaller than an experiment backup. It
contains the files necessary to restore the admitted native request path, plus
the frozen Bend source and admission; generated C and the 800-file historical
proof chain remain in the separate evidence capsules. Restore verifies every
member's SHA-256, size and mode, writes missing files atomically, refuses existing
changes, and retains 160 MiB disk headroom. The executable is never run by this
tool. The final selected capsule is sealed only from the real admission. The CLI
also supports `--calls 5`, authenticates every repeated C output, and publishes
the first only after all five agree.

Two tooling failures were retained and corrected as fresh derivatives. The
scanner and B2 image receipts use file/hash identities without byte lengths;
the initial join helpers rejected those schemas before compiler requests.
Fresh methods compare them against independently measured full identities.
Separately, root review caught that the process guard intentionally marks rc1 as
`complete:false`. The original semantic helper wrongly required `complete:true`
for an expected rejection. The fresh v2 qualifier/admission and v3 request runner
require actual rc1, finalized time fields, no guard stop, an expected diagnostic
and no C output. Positive compilation still requires rc0 and `complete:true`.
No negative target was run under the incorrect helper.

[`public-assets-method-controls.json`](public-assets-method-controls.json)
records seven synthetic finalized-status cases and two archive corruption
rejections. These are offline tool controls, not compiler conformance evidence.
Final capsule and public-CLI controls have their own completed receipts. The
current entry's supported scope is one
source importing Base and the nine admitted effects; neither these gates nor
restoration establish unrestricted language, GPU or parallel-runtime conformance.

See the [migration and launcher instructions](../../selfhost/tools/performance/phase90/runtime-migration01/README.md)
for the exact current commands. The Phase89 launcher remains historical and does
not select this image.
