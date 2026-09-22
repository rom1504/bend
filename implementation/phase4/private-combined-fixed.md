# Boolean/stability candidate after the scope correction

The corrected four-way comparison passed all 48 observations. Combining the two
private optimizations reduced median core request time by **11.3%**, with all
three core pairs improving. This supports testing an explicitly named candidate;
it does not replace the pending broad and whole-source gates.

The earlier [comparison](private-combined.md) remains separate because its base
transform had the subsequently discovered lexical-capture bug. This run uses
the corrected private control
`61e7d94c19bbda2de2a55037d5e2b992868a145ab6f29d557f4bc0885e759cb1`,
derived from completed, checked H
`b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8`.

The four variants share the exact host, runtime, canonical Base, source cases
and 63-export boundary. Their separate validated Base caches were primed before
measurement. Three fresh-process rounds alternate variant order, serially on
CPU 0, with a 4 MiB stack and 3 GiB heap. Another physical core was running the
whole-source control; these are coordinated same-machine measurements, not an
otherwise idle-machine claim. Every input/tool hash was rechecked at completion.

Median compiler request time, milliseconds:

| Case | Corrected private | Boolean only | Stable only | Combined |
| --- | ---: | ---: | ---: | ---: |
| Tree | 1993 | 1927 | 1960 | 1881 |
| List | 3559 | 3345 | 3466 | 3234 |
| Rejected bytes case | 1555 | 1437 | 1562 | 1446 |
| 312-declaration core | 26902 | 25452 | 25513 | 23855 |

Core control→combined pairs were 26.649→24.115, 26.902→23.843 and
26.995→23.855 seconds. Median complete child-process wall was 28.034→24.986
seconds, and median peak RSS 592,764→588,012 KiB. The small RSS difference is an
observation, not proof that all memory use decreases. The bytes workload remains
a checker rejection. Status, phase, checked flag, diagnostics and emitted hashes
matched exactly in all 48 rows; no successful-only timing subset was selected.

The corrected combination also passed:

- 300 Boolean and 3,786 stability controls, including successful finite-depth
  cases at 128, 512 and 1024;
- 14 exact observations across seven source/import edits using two reused APIs,
  including a repeated diagnostic and restoration after rejection;
- seven package/provenance controls, including unknown-profile and changed-H
  refusal, recorded exact body guards and consumed profile modules. A follow-up
  strengthens the gate to check prepared source/selected-variant hashes before
  use and recheck them afterward; two deliberately false recorded-hash fixtures
  are rejected;
- the escaped-string source that exposed the original scope bug. Its 41,155
  output bytes exactly match the corrected default/public H output, SHA
  `3f72bbdda80725b2ef31adc6bc8598ab725206de35976bae13150ae63ad3ab9b`.

## Isolated opt-in package

`selfhost/tools/performance/phase4/private-combined-package.mjs` creates a new
package directory by copying canonical tools and the reviewed transforms. It
does not edit the canonical package. Its copied builder accepts
`--profile=phase4-boolean-stable`; omitting the flag delegates to the unchanged
default transform. The named profile additionally pins the entire reviewed H,
besides the two Boolean, six stability-worker and runtime guards. A different H
requires re-audit even if its text differs only by a newline. The ordinary B1
edit loop does not depend on this profile.

Both builds retain genuine checked-proof validation and preserve any explicit
experimental proof status. These particular images use the completed proof.
The isolated default is byte-identical to the corrected canonical control.
The named image is byte-identical to the measured combination:
`4318bbcdb2040ad794387b1466b0bafbe12233e67983224c5a564d13fa5753a3`.
Its immutable image directory is
`selfhost/build/phase4/private/profile-combined`; the selected profile and all
consumed generator modules are recorded in its manifest.

From `selfhost/`, prepare and build an isolated candidate:

```sh
node tools/performance/phase4/private-combined-package.mjs NEW_PACKAGE
node NEW_PACKAGE/build.mjs PROOF/report.json PROOF/stage2.mjs \
  src/runtime.mjs NEW_IMAGE --profile=phase4-boolean-stable
node NEW_PACKAGE/run.mjs NEW_IMAGE INPUT.bend compile NEW_RESULT --cpu=0
```

The usual JSON-only request boundary, source auditing, immutable image checks,
bounded workers and verified output publication remain unchanged. No public
runtime, generated-program ABI or compiler source was edited for this profile.

All measurements, controls, consumed tools and copied profile modules are
archived with hashes in
[private-combined-fixed-evidence/manifest.json](private-combined-fixed-evidence/manifest.json).
Configuration files identify the checked source/API/proof prerequisites, which
are external to this compact archive. An earlier independent read-only review
of the isolated package preparer found no metadata or guard blocker; final
independent promotion review is still pending. Promotion is deferred to the separately recorded
broad frontend and exact whole-source output gates; this report was written
before those finished.

The later metadata correctness reruns briefly overlapped a separate root-owned
small timing matrix. Their retained capture timestamps and conservative
contention bounds are in
[correctness-check-contention.json](private-combined-fixed-evidence/correctness-check-contention.json).
They were not performance observations and occurred after the 48-row experiment
reported above. The other matrix's report owns any repeat or exclusion decision.
