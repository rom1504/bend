# Pinned TypeScript comparison for the combined Phase 4 compiler

The pinned TypeScript compiler takes **50.937 seconds** to compile the exact
combined Phase 4 source (median of three fresh processes); median process wall
time is **51.443 seconds**. Every run emits the same 1,206,611-byte library and
passes checking, ownership, exact library-root selection, syntax and selected
execution controls. The actual checked stage2 H classifier also confirms all three ordered root sets.
Stage3 is still running: this report does not yet establish a completed combined
self-hosting fixed point or an H/TypeScript speed ratio.

[Archived results and provenance](evidence/typescript-final/summary.json) retain
all three raw sample reports, requests, the complete measurement report, the
consumed tool, checked-build metadata and the compressed emitted library.

| Fresh process | Compiler interval | Process wall |
| --- | ---: | ---: |
| 1 | 51.550 s | 52.030 s |
| 2 | 50.829 s | 51.361 s |
| 3 | 50.937 s | 51.443 s |

All 1,522 roots match the checked B1 classifier in order. The three emitted
libraries have SHA
`1ef1d0d00271c8ae8340a5e69e0d6fb481bfd38f958853294ef931f3f5bd8457`.
The compiler interval contains load, check/ownership and emission; phase timings
are retained separately. No sample failed or was excluded.

The source is `selfhost/build/phase4/combined-checked/compiler.bend`, SHA
`34c6ef63931e522a96a4203f8bbd8e103d3a27636cce5dd42d9ec57a8587d122`.
The genuine `phase4-checked-overlay` report records checking, ownership, closure,
all source-module identities, existing requested roots and unchanged inputs.
Its B1 API SHA is
`0653f21e7e227bf7bf7e3ad777630da64d520534753900636a571ed57a43f810`.
No Phase 3 bootstrap metadata is fabricated or reused for this new build.

## Comparable work

Each worker uses unchanged `bend.ts` and `comp.ts` from revision
`6018e28ecc67cf1fffc0c20c64b11023474c2df8`, copied into a private snapshot.
The Base symlink resolves to the same canonical upstream Base path as the
combined self-emission proof; Base SHA is
`b8c2734d45ec6b4ce70fee70ff06ef35e08fce885af8852d8eb77dbff020e946`.
The effect files, Node executable, source, checked build, frozen host and runtime
are hashed. The upstream checkout must be tracked-clean before and after.
Git inspection and subprocess output use asynchronous file-backed capture.

A worker loads the complete source and Base, checks the book, applies ownership
and unresolved-hole/law gates, and emits a library. There is no persistent Base
cache. Roots follow the Bend `j_library_roots` policy: non-template definitions
with values, excluding ordinary Base definitions but retaining Base foreign
definitions. The limited B1 default export list is not used as the root set.
An export-only adapter exposes the actual checked B1 `j_library_roots` worker;
it must produce exactly the same ordered roots from complete checked TypeScript
metadata. No classifier worker body is changed. The retained metadata supports
an additional actual-H classifier check. That check passed against stage2 SHA
`b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8`.
Its proof snapshot explicitly records `proofComplete: false`. A retained preflight
also verifies successful stage exit without a signal and matching source, Base,
runtime, initial-compiler and host-helper identities.

Compiler time begins after loading the TypeScript implementation modules and
ends after library emission and output byte counting. Root-metadata transport,
file writing, hashing and the separate classifier oracle are outside that
interval. Process wall time includes startup, imports and that transport. Syntax
checking, importing the emitted module, exact export-order comparison and two
ASCII-helper execution controls are separate gates.

Workers run on physical CPU0 with Node v24.18.0, a 4 MiB Node stack and 12 GiB
heap limit, matching the proof's Node resource flags. The H proof runs separately
on CPU2; these observations are not same-core, interleaved pairs. Other physical
cores are active, so shared memory and scheduling effects remain possible.

## Reproduction

From the repository root, use a fresh output directory:

```sh
NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
timeout 620s taskset -c 0 "$NODE" --stack-size=4096 --max-old-space-size=12288 \
  selfhost/tools/performance/phase4/final-fullsource-typescript.mjs \
  selfhost/build/phase4/typescript-final-config.json \
  selfhost/build/phase4/typescript-final-replay
```

The configuration supplies `launch`, `cpu: 0`, `repetitions: 3` and
`timeoutMs: 180000`. `launch` points to `combined-launch.json`; the tool validates
its checked source/API records directly against the Phase 4 build report.
Compiler outputs, request files, raw per-sample reports, metadata and process
logs remain under `selfhost/build/phase4/typescript-final/`.

Once stage2 has a verified checked-emission record, verify its actual classifier:

```sh
"$NODE" --stack-size=4096 --max-old-space-size=12288 \
  selfhost/tools/performance/phase4/final-fullsource-typescript.mjs --verify-h \
  selfhost/build/phase4/typescript-final/report.json \
  selfhost/build/phase4/combined-fixedpoint/report.json \
  selfhost/build/phase4/typescript-final-h-verification
```

That verification snapshots the proof report and records whether stage3 was
complete at that moment. A successful stage2 root check alone is not a claim
that stage2 and stage3 form a byte-identical fixed point.
