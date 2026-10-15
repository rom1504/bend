# Native profile promotion after actual gates

This is an offline plan, not a release admission. No launcher, canonical compiler
source, installed JS image, or historical receipt has been changed by this lane.

## Existing reusable boundaries

The current public launcher is
`selfhost/tools/performance/phase90/runtime-migration01/native.py`. Its `load`
requires the historical D04 source digest, Phase90 runtime digest and exact Base
carrier digest. Its `native_args` always includes the own-runtime sentinel. A new
pointer alone therefore cannot select the proposed source or an upstream-built
native B1. Do not relax or rewrite that historical method: existing receipts and
its public capsule bind its exact bytes.

The native B1/B2 distinction already has an explicit implementation in
`selfhost/tools/performance/phase92/comparison/support.py:native_args`: B1 omits
the sentinel because upstream IO.args supplies the executable head; B2 inserts
it. Both stages use the same Base, runtime/template/five parts, nine effect files
and private carrier. The carrier binds the original Base path and stamp.

Current Phase98 source/build/gate machinery already handles new exact source
identities without claiming qualification from a build:

- `qualification/{bind.py,support.py}` authenticate actual upstream checked B1
  or candidate-B1-emitted B2 C, successful guarded Clang command and unpatched C;
  they compare the exact `p86_*` transport definitions with D04.
- `qualification/request.py` records candidate-source self output and exact
  diagnostics against the independently emitted candidate-source reference.
- `qualification/gates.py` records eight live/cache controls plus three exact
  rejections, or all45 retained C identities. B1 and B2 get separate reports.
- `qualification/conformance.py` reuses the real Phase92 eligible69 execution
  harness and explicitly excludes31 unsupported cases. The final collector,
  not the plan, establishes observed passes.

Use the immutable methods snapshot actually selected for each run, currently
`selfhost/build/phase98/qualification-methods02/methods/`; later prepared backend
changes have distinct snapshots. The controller must not silently update an
already frozen method while a run is using it.

## Keep the implementation small

Add one maintained native-host directory, for example `selfhost/tools/native/`,
with `launch.py`, `admit.py`, `assets.py` and a short README. A tiny
`selfhost/native.py` can be the stable public entry if desired. These are proposed
paths, not files already created. There is no reason to copy the full Phase90 or
Phase98 qualification tree into this directory.

`launch.py` should be a small, explicitly derived successor to Phase90 native.py:
preserve bounded subprocess execution, exact before/after input binding,
1-or5-call complete-C equality, no-overwrite atomic output publication, and
retained success/failure receipts. Replace only the historical-schema/source
constants with a versioned release schema and explicit `--stage b1|b2` selection.
Choose B2 as the normal default only after its own acceptance gates and timing
are known. An upstream-built B1 remains clearly labeled B1. No request launches
Node or rebuilds the compiler.

`admit.py` runs offline once after targets. Reuse the Phase98 authentication and
actual guard verification helpers rather than writing a second compiler
qualification system. It must validate the real selected source/builds and all
required completed reports, then write a compact immutable release manifest
under `selfhost/build/native/releases/phase98-<profile>/admission.json`. A small
tracked selection file points to that exact manifest by full pin. The immutable
manifest, selection and pinned release methods are delivered together.

`assets.py` should reuse the well-tested archive primitives from Phase90
`public-assets.py` through one explicit derivative/extraction: path containment,
unique member order, streaming SHA256, exact sizes/modes, 160MiB headroom,
verify-only operation and atomic restoration of missing files. Only selected
manifest enumeration and schema names need differ. Avoid dynamically pretending
a Phase98 manifest is a Phase90 one or monkeypatching historical module globals.

## Manifest and admission obligations

The new manifest needs these concrete identities and facts:

1. **Profile/source.** Exact immutable winning Bend source, original D04 pin,
   complete sequential source-replay recipe, method/helper inputs and declared
   line/byte delta. Replay and inverse must recover the source exactly. Candidate
   examples prepared so far are `held-source02`, `tag-source04` and
   `scalar-source01`; none is a final selection merely because it exists.
2. **Two producer records.** Separate B1/B2 binaries, emitted C pins, source pins,
   build receipts, exact Clang flags/executable, upstream revision and actual
   producer identity. Both images must be built for the same final source.
   B1 records the upstream C runtime; B2 records own C/runtime. C is never patched.
3. **Request transport.** Exact Base/runtime/template/five parts/nine providers,
   carrier and stamp, Base canonical path, sentinel value and per-stage sentinel
   policy. Admit cache reuse only after unchanged entry/cache ABI is checked and
   actual new-image live/cache products agree.
4. **Self evidence.** Actual candidate B1 and B2 self emissions, exact source,
   complete output identities and full diagnostics. A source-only optimization
   should agree with baseline native B2 compiling this candidate source, not
   historical D04 self-C. A changed emitter needs its separately stated oracle
   and fixed-point gates; merely agreeing with itself does not prove semantics.
5. **Semantic evidence.** Completed B1/B2 live/cache and rejection reports, all45
   selected C products, and selected runtime/conformance reports. Match every
   producer/source/runtime identity. Reject unfinished rows, resource stops,
   stale inputs, unexpected stderr, missing outputs and wrong counts. Source-only
   exact historical C can reuse historical executed-program evidence. Changed
   observer lowering cannot: it needs independent expected outputs and actual
   generated-program execution, including its layout/ownership refusal controls.
6. **Scope.** Single-source Base entry, nine providers, one CPU worker and the
   finite qualified corpus; no claim of full frontend/GPU/parallel conformance,
   universal compiler correctness, ELF fixed point or TypeScript speed parity.

`publicAdmission:false` in a private build receipt must remain unchanged. A new
public manifest records that its separate gate collection has now passed; it
does not rewrite that receipt or reinterpret a plan as a pass. A profile that is
fast only as B1 should not inherit B2 acceptance or speed claims.

The compact request loader verifies the selected manifest and actual chosen
binary, source and request assets before and after execution. The expensive
historical report closure is validated at admission/seal time, not every request.
Keep complete source/C/build/evidence pins in the manifest even where ordinary
request loading does not need to read a large historical C file.

## Preserve the JS release and historical native07

These are explicit native-profile source transforms. They do not alter
`selfhost/src/`, `selfhost/dist/`, `selfhost/cli.mjs` or installed JS release
selection. A later canonical helper integration would be a separate checked-JS
workflow and performance gate; it cannot be inferred from native source gains.

Leave these historical files and their capsule untouched:

```
selfhost/tools/performance/phase90/runtime-migration01/native.py
selfhost/tools/performance/phase90/runtime-migration01/native-admission.json
selfhost/tools/performance/phase90/runtime-migration01/public-assets01/
```

The old direct command remains an explicit native07 selection. The new README
should show both that historical command and the new stable stage-selectable
command, with no implicit fallback after a new-image failure.

## Restore and close the release

Seal one public request capsule containing the new selection/manifest, both
qualified binaries, derived Bend source and its small replay inputs, original
D04 source when needed to reproduce the profile, unchanged Base/carrier/runtime
parts/providers, launcher, guard and minimal helper dependencies. Deduplicate
identical paths. Do not copy all historical logs or both large self-C outputs
into the ordinary request capsule; preserve them in the phase evidence archive.

Use repository-relative archive member paths plus the recorded canonical checkout
root. The carrier's source-location ABI means restoration at another root is a
new preparation/admission exercise, not a safe path-rewrite shortcut. Restore
must refuse changed existing bytes/modes and never replace current assets.

After offline archive verification, run actual public CLI controls for cached and
live requests, five repeated requests, invalid source, changed admission digest
and refusal to overwrite; record the exact launcher and selected stage. The
public controls are new evidence, distinct from private `gates.py` success. Then
update `docs/self_hosted/NATIVE_HOST.md`, `selfhost/README.md`, the current
scoreboard and the experiment ledger with exact source/stage/timing scope.
Preserve the former scores as history. Only then select and publish the new
default native release.

## Prepared final59b36 release recipe

The stable host now exists at `selfhost/native.py` and
`selfhost/tools/native/{launch.py,assets.py,cli-controls.py,profile.py}`; this
supersedes the earlier proposed-file wording above. No selection has been made.
The main source is the permission02+held-simple+tag-v4 composition,59b36a1c…2714.
Its actual upstream-built B1 receipt is `selfhost/build/phase98/combined-b1.json`.
The B2 build/admission must still be the actual completed same-source result.

The reproducible source profile is only15,554 compressed delta bytes plus a
1,851-byte manifest in `selfhost/tools/native/profiles/phase98-comparison01/`.
It reads original D04 directly from the already committed Phase90 public capsule,
checks the entire capsule hash and exact member bytes, then applies and reverses
all1,375 exact edits. Neither the1.75MB assembly nor the parent experiment tree
needs to be committed as text. A data-only real replay already verified the
actual final source and wrote `selfhost/build/phase98/profile-replay01.json`.
That receipt meets the existing admission source-recipe shape, with finalsource
and D04 identities plus compact reproduction assets. It introduces no new source
semantics; universal source proofs and native acceptance remain separate.

Reproduce to a fresh output, without invoking a compiler:

```sh
python3 -B selfhost/tools/native/profile.py --out-source /tmp/compiler-native-phase98.bend --receipt /tmp/compiler-native-phase98-replay.json
```

Admission can use the already verified `profile-replay01.json` as
`--source-recipe`. The rest of its arguments must name actual final B1/B2 self,
controls,broad45,69-case conformance and backend-specific reports. Do not select a
build-only receipt. After admission succeeds, root can create a temporary pointer
under `selfhost/build/phase98/`:

```json
{"kind":"bend-native-compiler-selection","version":1,"complete":true,"admission":{"file":"ABSOLUTE_ADMISSION_PATH","sha256":"ACTUAL_SHA256","bytes":0},"defaultStage":"b2"}
```

The bytes field must be the actual admitted manifest length; the example is a
schema, not an executable or admitted selection. Root then runs:

```sh
python3 -B selfhost/tools/native/cli-controls.py selfhost/build/phase98/public-selection01.json ACTUAL_COMPLETED_CONTROL_REPORT selfhost/build/phase98/public-cli01
```

This prepared derivative of Phase90 cli-controls exercises both stages' cached
Small,live file IO and five-call Map outputs against the exact new C products
already in the admission's control receipt. It also tests default B2 selection,
no-overwrite refusal,changed-manifest refusal and exact invalid-source diagnostic.
It records all nine requests and checks selected assets before and after.
Preparation has parsed this method and reviewed its actual upstream report schema;
no successful public CLI result is claimed before root runs it.

Only after those controls pass should the exact temporary pointer be selected as
`selfhost/tools/native/selection.json` and sealed with `assets.py` as documented
in the native host README. Retain CLI request directories in the evidence capsule:
they are under `selfhost/build/native/requests`, outside the ordinary Phase98 tree.
The public asset capsule includes both images and source/profile assets; full
large generated C,individual gate history and CLI evidence stay separately archived.
Historical native07 remains explicitly selectable through its unchanged launcher.
