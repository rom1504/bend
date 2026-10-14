# Phase89 native B2 feasibility: source and host audit

Initial read-only audit of source at Phase88 commit `da6420b`, 2026-10-14;
subsequently updated with root's completed, serial guarded controls and full
self-emission attempt.
The audit/preparation agent ran no targets or builds. This document separates
finite controls, the completed timeout, and still-unmeasured successor behavior.

## Current status: native B1 passes; full self-emission times out

The new upstream-built native B1 `compiler-native-self01` passes all eight
live/cache exact-C gates (Small, Map, Unicode and entry-shaped file IO), plus
all45 broad catalog-point C comparisons. A separate full frozen compiler source
self-emission reaches the600s deadline without producing C. **No native B2
has been built or executed.** The stop is a deadline, not OOM or a demonstrated
semantic refusal.

| Current native B1 artifact | SHA256 |
| --- | --- |
| Binary,10,019,312 bytes | `8bacae268296d6fe16d02ce50a7a2189bd587506c074532c6e5d74e622716e45` |
| Frozen Bend source,1,755,310 bytes | `4584cf083d9eddad6f1290c9472c3aac2708099caa716a27f5b53fbcbaee1618` |
| Upstream-emitted C,17,762,895 bytes | `b156023421863836c4a0a752b61f9d538282aa376359716a36909f131e9555ff` |

The immutable [eight-gate receipt](../../selfhost/build/phase89/native-b1-nine-gates01/gates.json)
is complete/passing. The encompassing [optional self-emission report](../../selfhost/build/phase89/native-b1-nine-gates01/report.json)
remains failed:600.022s wall,1,079,590,912 bytes peak tree RSS, return−9 from the
deadline guard, no completed request clock and no emitted compiler C. These are
different records; the successful gate receipt does not turn self-emission into
a success. The [new image's broad45 report](../../selfhost/build/phase89/nine-broad01/report.json)
is independently complete/passing, with unchanged inputs and all45 exact C
hashes matching previously executed Phase88 points. It reuses that prior
execution evidence; it is not a fresh generated-program speed measurement.

The versioned [native89 launcher and admission](../../selfhost/tools/performance/phase89/native-launcher.md)
bind this exact image, nine providers and private prepared cache. Its admission
manifest is pinned; all ten separate wrapper success/refusal controls pass.
Restoration verifies all12 selected assets and recovers a missing executable
with unchanged admission. Source optimizations stay in the
explicit native build profile; canonical production and installed Phase82 JS B2
remain unchanged after the [ordinary JS ablations](js-integration.md).

[Bounded partial capture](../../selfhost/tools/performance/phase89/partial-capture/README.md)
provides separate diagnostic evidence. The retained60s self-prefix capture has one timer
overrun and remains [explicitly unqualified](partial-self02-unqualified.json);
the strict analyzer was not weakened. Its exploratory samples cannot establish
a completed compilation profile, removable-time forecast or native B2 result.

The earlier audit below is retained with its original producer facts. Its
foreign-effect and new-B1-build proposals have since been implemented and gated;
its first full S→C2 attempt has now timed out. Argv adaptation, native-produced
build/cache provenance and actual B2 execution remain future boundaries.

## Completed small controls

Root's [native-b2-run02 report](../../selfhost/build/phase89/native-b2-run02/report.json)
is complete and passes. The original argv fixture omitted `+` on its reused
index; the checker rejected it. That failure is preserved in evidence01. The
corrected source, SHA256 `3ed0bbbdb2ca6650da88f445769c8e48daab955d77b29db5277963c9f16fea3e`,
declares `+index`; no assertion or ownership check was weakened.

| Control | Producers and full-C equality | Native execution | Emitted policy |
| --- | --- | --- | --- |
| Argv | JS B2 and native B1, exact134,135-byte C | Zero/one/three payload arguments pass, including spaces/Unicode; retained runtime omits executable name | Four checked policy macros1 |
| Decoder | JS B2 and native B1, exact1,489,523-byte C | Unchanged16-assertion fixture returns exactly `True{}` | All four macros0 |
| Entry-shaped file IO | JS B2,377,752-byte C; not emitted by native B1 | Empty/Unicode full copies and missing-file/early-EOF/oversize refusals all pass | All four macros0 |

Full emitted-C SHA256 identities, respectively:

```text
argv     7f8c8cededcefbc4bf090e455192e67080a43ee043c6168edbc81934d2e627d0
decoder  9c2e054f4364209c763182ced09b4b01456a4a49bfa364ace491f2fd802260d7
file-io  13248086372f28686773f613257426824ef47d114aec22360c0932d92eceecbc
```

The policy fields are `NATIVE_TYPED_SCALARS`, `NATIVE_COLD_USER_CTORS`,
`NATIVE_SCALAR_ARRAYS`, `NATIVE_UNSHARED_ARRAYS`. Decoder/file IO passed through
the conservative representation. The runtime remained
`0e52adc8d206f7c07944567adddaefaedfb7830ad23d2ba6bbca64dd2e4fb245`,
template `f9f5a1c98f17f892d891032ca35489234e43d3b4112a18e592e6da408b09736c`.
The producer identities remain Phase82 JS B2 `098320e8…` and Phase88 native B1
`5babec07…`. Three expected program refusals have nonzero guard status, but their
specific exit/error/output-absence checks pass; resource stops are not accepted.

At that checkpoint these three small falsifiers did not establish native-B1
file-effect admission. The later nine-effect B1 gates above supersede that
limitation: actual native B1 now emits the same file-IO C in live/cached modes.
The historical file-IO row remains correctly labeled JS-B2-produced. Native B2,
its prepared-Base admission and self-emitted compiler C remain unestablished.

## Existing artifacts and the exact chain

The initial Phase88 baseline B1 is `selfhost/build/phase88/compiler-native02`, built from the
upstream-emitted `selfhost/build/phase88/native02/compiler.c`. Its source is
`native02/compiler.bend`, 1,750,898 bytes, SHA256
`08ea659193cc0c5f040f209e63e9b6df71ff3c928784db81706c264b41d05e4f`.
The source is below the entry's 16 MiB input limit. Upstream C is 17,765,427 bytes;
the native binary is 9,964,168 bytes. These are existing Phase88 artifacts, not
predictions for our emitter's compiler output.

The intended proof is:

```text
frozen compiler source S + private native entry
  upstream check/C emission -> Clang -> native B1
  native B1 checks/emits S   -> C2 -> Clang -> native B2
  native B2 checks/emits S   -> C3
  require C2 == C3, then representative program C and execution gates
```

Clang is a toolchain step in both native stages. A JS-hosted Bend compiler
emitting the same C2 is useful independent evidence and a cheap falsifier; it is
not a replacement for the native B1→B2 provenance chain. Upstream C and our C
need not be identical. Compare our C across equivalent compiler execution hosts,
then compare C2/C3 for the same frozen source, entry and external assets.

`selfhost/tools/assemble.mjs:6` already joins modules into one source with exactly
`import Base`, rejects other module imports, deduplicates declarations, and
orders types, laws and definitions. `phase88/acquire.mjs:35` uses it with the
manifest plus copied entry. Freeze this assembly, including the safe consuming
equality derivative from `phase88/strings/native-assembly.py`, once for all
stages. Do not regenerate from mutable production between stages.

## Initial obstacles and minimal changes

The first row has been implemented for the exact nine-effect image above.
The remaining rows describe successor/B2 boundaries, not missing functionality
in the already qualified live/cache B1 requests.

| Boundary | Actual evidence | Smallest candidate change / gate |
| --- | --- | --- |
| Self-compiler IO effects | `phase88/entry.bend:176` admits only args.c, print.c, now.c; `p86_effect_read` refuses everything else. The same entry itself calls IO.print_err and File.open/read/size/write/close. | A fresh private entry may admit exactly these six additional vendored files, authenticated before and after execution. Keep arbitrary foreign paths refused. |
| Argument convention | Upstream `bend2/comp.ts:5938` starts `io_argv=argv; io_argc=1`. Retained `src/runtime/native/runtime.c:2265,3076` starts argc=0 and argv+1. `p86_cli` at entry:370 consumes a leading program element. | Record producer/runtime convention in the launcher. For a retained-runtime B2, pass one explicit program sentinel after `--` before INPUT, or use a separately checked entry adapter. Never blindly reuse B1 argv. |
| Optimization permission | `scalar-array.bend:44` accepts foreign definitions only named IO.args/IO.print/IO.now; `request.bend:49` derives packed/unshared policy from that certificate. `typed-driver.mjs:932` independently hashes the same three effects. | Preserve the certificate. New file effects use conservative permission; do not expand root-observer or scalar-array permission merely to compile the entry. |
| Build provenance | `phase88/native_support.py:54` expects an upstream checked-acquisition report with load/check/emit-c stages; native request reports have a different schema. | Add an explicit native-produced stage receipt binding parent image, source, full checked request, runtime/effects, output C and Clang guard. Do not manufacture upstream stages for native emission. |
| Prepared cache consumer | `native_support.py:21,92` admits the exact native02 binary/source/C triple. A different B2 must refuse under this policy. | First establish live B2 behavior; independently qualify cached B2, then add its exact identity under a new versioned admission record. Never remove consumer binding. |

The entry needs eight reachable provider files: args.c, now.c, print_err.c,
file_open.c, file_read.c, file_size.c, file_write.c, file_close.c. Existing print.c
can remain allowed for user programs, yielding a nine-file private allowlist.
IO.die uses the ordinary Halt constructor/event-loop path rather than a separate
provider. All these providers already exist in `selfhost/src/runtime/native/effs/`.
The emitter parses them through `kf_source`, then rewrites IDs through
`nc_foreign_source`; do not insert arbitrary raw C after that validation.

The existing B1 itself can execute file IO because upstream compiled its entry
and linked upstream effects. Its *output compiler* uses the retained selfhost
runtime and vendored providers. This distinction explained why the initial entry could
read source files while refusing to compile a file-reading successor.

The native backend already has generic file handles, result/pair construction
and asynchronous file work. `file_read.c` and `file_write.c` guard optional
read-bytes/read-at/write-bytes registrations with constructor macros. The bounded
entry-shaped file control now passes UTF-8 strings, failures and affine handle
threading. The complete successor compiler has not exercised these providers.

## Private entry derivative, now checked and built

`selfhost/tools/performance/phase89/native-b2/extend-entry.py SOURCE NEW_SOURCE`
replaces exactly one byte-identical `p86_effect_file` definition using frozen
old/new blocks. It accepts the unchanged entry inside a new owned/chunk compiler
assembly, and refuses an unknown or already modified definition. The prefix and
suffix remain byte-identical and receive separate hashes in its derivation
receipt. The output is explicitly `checked:false`: root must check the entire
new compiler and acquire/build a distinct B1 before executing it.
That subsequent full check/acquisition/build has completed for source4584cf08…
and image8bacae26…; the transport receipt correctly retains its original
`checked:false` fact rather than claiming it performed that later check.

`nine-effects.json` supplies exact external hashes for the nine vendored files,
canonical Base, runtime/template and both definition blocks. The helper retains
only the two existing exact Base-relative path spellings (`effs/NAME` and
`./effs/NAME`). Unknown filenames, other directories and arbitrary foreign paths
still produce the existing refusal. No source algorithm, IO helper, entry check,
foreign-ID parser, `ns_definitions`, argv or cache-admission bytes are changed.
Although the entry still calls the checked native API, the unchanged certificate
rejects its new file effects and keeps conservative representation. Do not
generalize the three-name observer/scalar policy as part of this change.

The launcher must authenticate all nine exact files before and after requests;
the old three-effect authentication is insufficient for this new image. Its
source/C/binary identity also needs explicit live/cache admission under a new
receipt. Existing native02 identity and sealed evidence remain unchanged. First
repeat the file-IO control through the new actual B1 and require exact JS-B2 C;
only then attempt frozen full compiler S→C2. Both the actual-B1 file-IO gate and
the bounded full-source attempt have now run; the latter timed out as recorded
above. Preserve the explicit retained-B2
argv adapter when that later stage becomes runnable.

## Representation and cache inheritance

The B1 executable runs upstream's current C runtime. B2 will run the retained
selfhost runtime described by `src/runtime/native/ORIGIN.md`, including its
scheduler, reference counting and generic Term ABI. The audited runtime source
and the five canonical output chunks can be reused unchanged as *inputs*;
their identity does not make the two executing compilers have the same runtime.

The cache does not copy runtime addresses, constructor IDs or a C heap image.
`phase88/base/decoder.bend` reconstructs named Bend Data using typed wrappers and
backward-reference Arrays. Therefore a different native representation is not
intrinsically a cache-format blocker. Preserve the actual Base, source origin,
term/span/world versions, producer identity, complete carrier hash and bounds.
The source carrier and its JS producer may remain explicit bootstrap assets.
Calling this native B2 would describe the compiler's production chain, not claim
that every prepared-library artifact was itself produced natively.

However, the decoder uses `Array<P88Node>` and `Array<String>` (`decoder.bend:30`
and `:377`), which fail the current scalar-only whole-program array certificate.
Even without file IO, this entry should not be expected to receive the packed
scalar/observer policies used by selected small programs. Broadening that policy
is a separate optimization/correctness project, not a prerequisite to the first
generic-layout B2. Other native worker optimizations remain independently gated.

Reuse the existing 16 decoder controls and complete-product comparison protocol
(`base/fixtures03`, `base/compare-products.mjs`) before admitting a new consumer.
The existing full-product proof is a checked JS derivative proof; the old native
startup/output checks bind native B1 only. For B2, require live versus cached
complete generated C/verdicts, source-span refusals, Map and repeated requests.
A small selfhost-emitted native decoder control is a cheap way to exercise
shared Data, Array.get/set and Unicode before constructing a full B2.

## Fastest falsification sequence

Gates1–4 now pass in the finite scopes recorded above. Gate5 has completed as a
600s deadline failure without C2, so gate6 has not run. Upstream-execution
comparison in gate1 was an initial proposal; the retained argv lane records its
actual producers separately. The sequence below remains the original dependency
plan, not a claim that all stages completed or a measured time estimate.
Root runs targets serially with the existing resource guard.

1. **Argv only.** Compile a tiny IO.args program through current native B1, build
   it, and observe the retained-runtime list with zero, one and multiple payload
   arguments. Compare to the upstream-built equivalent. This uses only today's
   admitted effects and decisively tests the known leading-program mismatch.
2. **Pure decoder through our emitter.** Run the existing standalone 16-control
   source through native B1→our C→Clang, requiring the expected `True{}`. This
   tests generic arrays/shared Data without full compiler assembly or new file
   effect admission. Preserve malformed-payload refusal expectations.
3. **Entry-shaped IO through the JS-hosted Bend compiler first.** A tiny program
   with the actual p86_read_file/p86_write_file control flow should round-trip
   empty/Unicode files, verify exact EOF, read size, write stderr, obtain time,
   and handle a missing input correctly. Use the same vendored effects and
   conservative permission as the proposed native entry. This can falsify the
   retained backend/provider boundary before paying for a new native B1 build.
4. **One new B1 entry build.** Only after those pass, freeze the narrow extended
   entry, exact provider hashes and updated admission schema; acquire/check/build
   it once. Repeat the IO control through this actual B1 and require exact C
   against the independent JS-hosted Bend emitter using the same frozen input.
5. **Full S→C2 without Clang first.** Have native B1 compile the assembled source
   under an explicit larger deadline but a fixed memory/output guard. Retain the
   complete refusal if it hits a checker/layout/segment limit. Compare C2 to the
   independent JS-hosted emitter if that gate is affordable. A valid complete C2
   is the prerequisite for the expensive Clang step.
6. **One guarded Clang build, then B2 smoke.** Start with live Base and the fixed
   argv adapter; run small plus Unicode/error cases, then Map/Lexer. Qualify cached
   mode separately. Next have B2 emit S again and compare C3 byte-for-byte to C2.
   Only then broaden execution coverage and assess first/fifth compilation speed.

For each gate retain the input source, API/native producer, Base, runtime parts,
selected effect bytes, command, guards, complete C and execution stdout/error.
Use a new output path on failure; do not relabel an unexecuted or refused stage.

## Full-scale risks that source inspection cannot settle

- `validate.bend:60` caps segments at65,532 and constructor IDs at65,536; arities
  are bounded at255. `book.bend:276` reserves binder IDs from4,000,000,000 onward.
  Keep these explicit rejections. An offline scan of upstream-emitted native02 C
  finds12,691 numeric FID definitions (maximum12,690) and197 CID definitions.
  Different segmentation means those counts do not prove our emitter fits.
- The initial full upstream acquisition used about63.7s for C emission, and the
  Phase88 ClangO2 build took175s/approximately4GiB peak. The size of our emitter's
  complete compiler C, Clang time and B2 runtime remain unknown. Native B1 did
  not finish full self-emission within the600s process guard. Its generic fallback and
  compiler-scale unsafe code may expose bugs absent from the45 program points.
  Treat budgets as stop limits, not predictions or automatic reasons to retry.
- `phase86/guard.py` has a64MiB output-file limit and native.py has a600s maximum
  request timeout. Check actual source/output growth before changing either.
  The16MiB input cap covers S today; it need not cover the much larger emitted C,
  which this entry writes but does not reread as Bend input.
- Preserve Phase88's Data observer repair and consuming equality source. Do not
  revert to reusable affine observer closures merely because the output runtime
  has a different representation. Native B2 needs the same focused safety gates.
- Native B2 speed and B1/JS parity are separate metrics. A successful bootstrap
  can still run slower, particularly when compiler-wide generic-array admission
  disables policies that benchmark programs receive.

The first three controls are small existing-API jobs plus tiny Clang programs;
they should precede any full acquisition. The complete native fixed point is an
integration project, not an inexpensive extension of a small-program benchmark.

## Local upstream executable packaging source

This section preserves the initial bounded source-only audit. Later engine
download/packaging experiments and their exact identities are recorded in
[the engine report](engines.md); this paragraph does not describe their current
installation state.

Exact release packaging source was **not found in the bounded local search**.
`SITE_REPO` is unset. The documented sibling `bend-lang.com` checkout is absent
beside the publish checkout, workspace and pinned bootstrap checkout; no
`release.ts` was found in a depth-three scan of the workspace and bootstrap
trees. This is not a claim to have searched the entire machine.

Relevant source is present at:

- `selfhost/.bootstrap/upstream-phase66/gates/_lib.ts:32`: resolves SITE_REPO or
  sibling `bend-lang.com`.
- `selfhost/.bootstrap/upstream-phase66/gates/ping.ts:45,193`: expects
  `release/release.ts`; invokes it with `--dry TARGET`, `BEND_REPO` and `DL_DIR`.
  The gate checks the executable/archive, installer, version and digests.
- `selfhost/.bootstrap/upstream-phase66/bend2/bend.ts:894`: `$bunfs` compiled mode
  loads `../bend2/base.bend` and effects relative to the real executable path.
- `selfhost/.bootstrap/upstream-phase66/bend2/main.ts:63`: guide assets are beside
  that bend2 directory. Its Bun.build call at:484 is a browser page bundler,
  not the missing executable-release builder.

Thus an experimental Bun executable can be distinguished from the exact upstream
release. The local source establishes its required external asset layout, but
not the complete release flags, asset list or installation procedure. Recreating
those details without release.ts would be a new packaging experiment. No such
package was built or downloaded during this audit.
