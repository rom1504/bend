# Phase66 final data checks, writer closure and archive plan

This document records the prepared method. All owners have acknowledged closed
raw writers, all targets ended and installation passed. Root explicitly authorized
[the final07 closure config](closure-authorization-final07.json); the actual seal
and archive receipts, once written, establish completion. Root executes those
commands once.
All commands below are data work on CPU0; none executes a compiler, generated
program, release installer or installed CLI. Actual target gates remain root's
serial CPU3 work and must finish first.

The frozen selected state is now **attempt07** at root-reported commit
`f9667c2`: selected B1 `bb6c6e2a…`, assembled source `1b29d5c4…`, actual B2
`0067736c…`. The [final census](../../../../implementation/phase66/evidence/simplicity-final07.json)
and [source audit](../../../../implementation/phase66/evidence/source-freeze-final07.json)
are complete, as are its own-source/B2-B3, frontend/JS, B1/B2 compiler timing
and four Base gates. Generated-program runtime, final native/compiler/release
joins, installed interfaces, time accounting and preservation also pass. The
[authorized config](closure-authorization-final07.json) pins their actual bytes
and schemas; the earlier skeletons remain non-authorizing history.
All failed06, earlier04/05 measurements and complete Bun evidence are preserved.

## Before closing any writer

1. Close actual selected-image frontend, primary JS, native/backend, self-check,
   B2/B3 reproduction, B1/B2 emission, Base products/custom fallback and release
   gates. Report explicit unsupported cases and fixture/oracle failures. A closed
   report need not mean every fixture passed; it must accurately classify them.
2. Close the five metric axes separately: generated-program runtime, B1 compiler
   latency, B2 latency, conformance, and source/host/image simplicity. Keep the
   old/new TypeScript pins and B1/B2 image roles distinct. Full timing and gate
   elapsed time are different clocks.
3. Root runs the existing
   [release plan](release/release-qualification-plan-v1.py) against the final
   immutable attempt. The release owner produces the data join binding install,
   verify-before, legacy42, default24, verify-after and the exact installed
   checkout/lineage/file identities. This closure method does not rerun those
   commands or replace that owner's admission decision.
4. Reuse the completed final07 simplicity census linked above while that source
   remains selected. Repeat only if the selected source changes, preserving all
   earlier checkpoint outputs. The general invocation
   is below; replace `FINAL_ATTEMPT` and `B2_RECEIPT` with real repo paths rather
   than guessing identities from a directory name.

   ```sh
   taskset -c 0 python3 -B implementation/phase66/simplicity-audit-v2.py \
     --attempt FINAL_ATTEMPT \
     --b2-report B2_RECEIPT \
     --output implementation/phase66/evidence/simplicity-final.json
   ```

   The census must include physical/code lines, definitions/laws/types/modules,
   selected raw and equality-derived B1 sizes, actual B2 size, host/runtime
   source sizes and exact input identities. Do not rename raw B1 as selected
   B1, count generated output as handwritten compiler complexity, or erase the
   +57-line attempt03/04 checkpoint when a successor is selected.
5. Run the prepared preservation successor only after clean timing stops. It
   rehashes the complete 17,894-file closed Phase65 tree, both published parts,
   their concatenated stream, and every member; it never extracts there. It
   also checks the 110 inherited files, seven previous-installed raw copies and
   all 299 baseline-source copies. The latter retain deleted old provider files;
   their original live paths are allowed to have changed or disappeared.

   ```sh
   taskset -c 0 python3 -B selfhost/tools/performance/phase66/preserve-closed-v2.py \
     --output implementation/phase66/evidence/closed-evidence-preservation.json
   ```

   This explicitly fixes the predecessor helper's single-archive assumption:
   the Phase65 manifest has `archive.file: null` and two ordered parts. Phase66
   installed-before paths are repository-relative; the helper confines and
   normalizes both absolute and relative paths.
6. Bind the final installed files to the release owner's actual passing join.
   Require selected API, checked parent, bootstrap and derivation reports, Base,
   ordinary/direct runtimes and every installed checkout pin to match the final
   frozen source. Include the seven previous installed artifacts in history and
   raw copies. A data hash check alone is not the installed CLI qualification.
7. Finish the final compiler/release joins, time-account report, compact evidence
   and external prerequisite inventory. If the final native toolchain recipe
   adds prerequisites beyond the recorded attempt04 pins, append a separately
   pinned successor inventory before archival. The current inventory explicitly
   retains its older evidence identities rather than claiming final07 execution.

## Root's explicit seal contract

After every owner acknowledges no pending raw writes, root prepares a fresh
configuration outside the raw tree. The actual authorization remains a tracked
method artifact, pinned by the final raw seal. It must contain:

```json
{
  "kind": "phase66-root-closure-authorization",
  "allRawWritersStopped": true,
  "compilerTargetsClosed": true,
  "installationVerified": true,
  "sourceCommit": "ACTUAL_40_CHARACTER_SOURCE_COMMIT",
  "ownerAcknowledgements": {
    "root": true,
    "correctness": true,
    "measurements": true,
    "bootstrapRelease": true,
    "backend": true,
    "baseHost": true,
    "documentationArchive": true
  },
  "copies": [
    {
      "role": "compilerQualification",
      "source": "implementation/phase66/evidence/ACTUAL_COMPILER_JOIN.json",
      "copy": "selfhost/build/phase66/final-closure/compiler-qualification.json",
      "bytes": 0,
      "sha256": "ACTUAL_SHA256",
      "assertions": {"complete": true, "pass": true}
    }
  ]
}
```

The example is deliberately incomplete and will be refused. Populate six
required roles with exact source byte counts/hashes and actual receipt-field
assertions: `compilerQualification`, `releaseQualification`, `timeAccount`,
`finalSimplicity`, `protectedInputs`, and `installedFiles`. The time-account
source must be `implementation/phase66/evidence/time-account-final.json`.
The release join may supply both release and installed-file roles, with separate
fresh copy names. Additional metric/reuse receipts can be copied too. Assertions
must reflect each receipt's real schema; they do not reinterpret failures as
passes. Final qualification readers remain responsible for semantic admission.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase66/seal.py \
  --config ACTUAL_CLOSURE_AUTHORIZATION.json
```

The tool verifies all required source receipts before copying, checks each
copy/source again, rechecks protected inputs, then writes `writers-closed.json`
last using the actual time. No broad file-count scan is treated as proof of
writer closure. Historical `.active` markers are preserved as bytes and are not
deleted merely because the campaign is closed. Partial failed seal outputs are
preserved and must be diagnosed; the tool refuses to overwrite them or an
existing closure. Once sealed, nobody writes under `selfhost/build/phase66`.

## Publication after explicit closure

The Phase65-derived [archive producer](archive-v2.py) is bound by
[`archive-derivation.json`](archive-derivation.json). It:

- requires explicit closed targets, installed qualification, root and owner
  acknowledgements, all six final receipt roles and their exact copied bytes;
- inventories every raw regular file and directory, including empty directories,
  failed attempts, malformed JSON, full logs, executable outputs and cache files;
- raises on traversal errors, symlinks or special entries instead of skipping
  them, preserving names, regular bytes and permission modes;
- writes an ordered gzip stream split into parts of at most **50 MiB**, keeping
  the temporary complete stream outside the repository;
- checks every part and complete stream, then reopens **every member once** and
  verifies its exact ordered name/type/mode/size/content hash;
- rehashes the entire original inventory, protected predecessors and all control
  files afterward, and publishes `manifest.json` last, only on success.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase66/archive-v2.py
```

The published manifest and README are outside closed raw. Existing or failed
publication trees are never overwritten. The rendered README provides a full
standard-library restore: all parts/members are verified before any destination
is created, restoration requires an absent raw tree, restored bytes are checked,
then permission modes are applied and verified deepest-first. No post-closure
target execution or archive verification output may be written inside raw.

Historical Phase65/63/58/55/45/22 archives retain their original transports and
limits. Do not repartition, reopen for writing or overwrite those capsules.
The [prerequisite inventory](archive-prerequisites.json) and
[notes](archive-prerequisites.md) identify their different formats and recorded
Node/upstream/Clang requirements. The acquired Bun1.4.2 zip, binary, official
release metadata and acquisition receipt are inside Phase66 raw and retain
their hashes/modes; Bun is not an external binary prerequisite. They are explicit prerequisites, not a claim
that every historical toolchain or transitive replay is packaged here.

Archive integrity, restored evidence, source qualification, metric comparisons,
installed release admission and elapsed-time accounting remain separate facts.
