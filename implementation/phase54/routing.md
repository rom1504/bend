# Maintained compiler-image routing

Ordinary public JavaScript compilation defaults to the direct callable ABI.
Current self-hosted compiler-image workflows still require the legacy emitter
and runtime. Phase54 makes that internal choice explicit and restores the
intended compiler-image backend. It changes no public default, compiler Bend
source or runtime; emitted-byte equality has not been measured in this task.

Two maintained command producers omitted their selector:

- `selfhost/tools/conformance/selfhost.mjs` emits successive checked compiler
  images with `--library` and tests stage byte identity.
- `selfhost/tools/conformance/verify-seed.mjs` emits a checked seed's source and
  tests whether the output equals that seed.

Both now add `--legacy-js` to the existing library argv. Resource flags, selected
API, source, Base, legacy runtime, provenance checks, timeout handling and output
identity requirements remain intact. The previous omission was a static routing
gap; this task did not execute either compiler-image workflow or establish a
new fixed point. No historical producer or frozen snapshot was edited.

## Audit and verification

The maintained bootstrap tool `stage0-library.mjs` explicitly uses the pinned
upstream `C.js_lib`; it does not rely on the public driver default. Private
compiler-image worker/session and reference/control worker requests already
select `backend:'js'`. Development tools have no additional implicit library or
compile inspection calls. The ordinary public smoke uses the new public default
intentionally and needs no legacy selector.

The new host-only controller is
`selfhost/tools/performance/phase54/compiler-image-routing.mjs`. It extracts each
actual maintained spawn expression, evaluates it with an inert spy, and checks
exact CLI argument order, Node resource flags, source/output paths, process
options and compiler/Base/runtime environment. Negative controls remove the
legacy selector or replace it with direct and must fail. Four further checks
require explicit legacy API routing in the private-image callers. Six grouped
checks passed on CPU0, with no child process, compiler, Bend program or build.

Raw receipts are under `selfhost/build/phase54/routing01/`: `report.json` binds
controller/tokenizer/input hashes; `edit-receipt.json`, saved before bytes and
per-file diffs preserve the narrow command changes. Both maintained commands
also pass Node syntax checking. This is routing verification, not semantic,
performance, memory, self-reproduction or release qualification.

The edited paths are outside the authoritative 103 protected inherited files.
No protected file was staged or modified. No commit or installation was made.

## Remaining compatibility dependency

Legacy compiler-image generation remains deliberate. Private images presently
package the descriptor runtime, and their optimization/host ABI controls depend
on it. Direct compiler-sized reachability has separate scaling bounds and has
not been qualified as a replacement image path. A later migration must first
qualify direct compiler images and their full runtime/dependencies, then migrate
the G-dependent private-image transforms and provenance/identity pipeline before
removing these selectors or the legacy emitter. The loader already bypasses
positional compiler-ABI conversion when a module has no G export, so rewriting
that conversion is not necessarily a prerequisite for a direct image. The public
`--legacy-js` contract remains another separate compatibility obligation.
