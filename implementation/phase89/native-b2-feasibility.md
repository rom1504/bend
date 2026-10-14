# Phase89 native B2 feasibility: source and host audit

Read-only audit of source at Phase88 commit `da6420b`, 2026-10-14. No compiler,
benchmark, binary, build, download or release command was run. This document
separates demonstrated source obstacles from unmeasured full-compiler risks.

Native B2 is a plausible next qualification, but the existing native B1 cannot
compile a runnable copy of its own entry unchanged. The immediate obstacles are
the foreign-effect allowlist, an actual argv convention mismatch, and the build/
cache admission protocol. General import discovery is not required for the first
assembled-source attempt. Native B2 performance is unknown: its emitted runtime
and lowering differ materially from the upstream-built native B1.

## Existing artifacts and the exact chain

The selected B1 is `selfhost/build/phase88/compiler-native02`, built from the
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

## Immediate obstacles and minimal changes

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
runtime and vendored providers. This distinction explains why today's entry can
read source files while refusing to compile a file-reading successor.

The native backend already has generic file handles, result/pair construction
and asynchronous file work. `file_read.c` and `file_write.c` guard optional
read-bytes/read-at/write-bytes registrations with constructor macros. This is a
usable implementation to test, not proof that these providers have passed the
new compiler-entry workload. Test UTF-8 strings, failures and affine file-handle
threading through the exact emitted program.

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

These are proposed gates, not completed experiments or measured time estimates.
Root should run them serially with the existing resource guard.

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
- Existing full upstream acquisition used about63.7s for C emission, and the
  Phase88 ClangO2 build took175s/approximately4GiB peak. Our emitter's source size,
  emission time, Clang time and B2 runtime are unknown. Its generic fallback and
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
