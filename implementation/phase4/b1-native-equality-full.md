# P4-024 derived-B1 complete-source gate

The experimental B1 derivative compiled the entire frozen compiler source and
emitted **1,143,517 bytes exactly equal to both original checked fixed-point
outputs**, stage 2 and stage 3. The independent audit compared actual byte
buffers, not only the reported hashes. Output SHA-256 is
`b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8`.
The result is `status:ok`, `phase:compile`, `checked:true`, with the verdict
`All terms check.`

This completes the separately authorized whole-source correctness gate for the
[bounded B1 equality experiment](b1-native-equality.md), alongside its
[full frontend preservation gate](b1-native-equality-frontend.md).
**It is not a new checked bootstrap or a paired full-source speed comparison.**
The default B1, Bend source modules, runtime and public emitted compiler remain
unchanged; the tested candidate is still an explicitly derived JavaScript API.

## What was verified

The audit reproduced the candidate bytes from exact checked B1 `0653f21e…`
using the full-image and original-function-body SHA guards. Candidate
`e95e1198…` is the same artifact that passed the 909 helper controls, 12 selected
observations and complete frontend gate. The genuine checked-build report
continues to describe only the original B1. No replacement bootstrap metadata
was fabricated for the derivative.

The complete frozen source is `34c6ef63…`. Its original proof records checked
B1→H and checked H→H stages with unchanged inputs and identical output. The
audit independently verified the actual source and both outputs, the original
checked seed/proof chain, all recorded input identities, and the worker's
explicit `library` request. The consumed driver and helper bytes match those
of the original proof. Runtime `26f5eee2…` and canonical pinned Base
`b8c2734d…` also match.

The candidate reused its own already validated Base cache from the pilot.
The audit checked candidate/Base hashes, canonical Base path, `check_book`
validation marker and complete serialized-book hash. Cache bytes were frozen
inputs. OS caches were not flushed. The worker's result named exactly the
complete compiler source and canonical Base as consumed source files.

## One retained observation

The child ran on CPU 2 with Node v24.18.0, a 4 MiB stack, 12 GiB heap and a
15-minute process deadline. Its exit status was 0, with no signal or timeout.
The report finished at 19:26:03.179 UTC on 2026-09-22.

| Quantity | Observation |
| --- | ---: |
| Complete child-process wall | 348.373 s (5m48.373s) |
| Host `inspect` request wall | 347.098 s |
| Process peak RSS | 2,841,452 KiB |
| Actual emitted compiler | 1,143,517 bytes |

These are one successful workflow observation. No contemporaneous alternating
unmodified-B1 whole-source control was run, so no full-source speed ratio is
asserted. The smaller paired core pilot supports its own narrower performance
claim; this run establishes complete-source output preservation.

## Reproduce or audit

The [durable evidence archive](b1-native-equality-full-evidence/README.md)
contains 255 verified regular members: raw reports/logs/config/request/worker,
actual output, consumed tools and source/proof/runtime/Base/cache artifacts.
The archiver reopened every actual compressed member and verified its path,
size and SHA-256. Node's exact executable identity is recorded externally.

From `selfhost/`, using the preserved exact inputs and fresh output paths:

```sh
node tools/performance/phase4/derived-b1-full.mjs \
  build/phase4/b1-native-equality/pilot/report.json \
  build/phase4/combined-fixedpoint/report.json NEW_FULL_SOURCE

taskset -c 1 node tools/performance/phase4/derived-b1-full-audit.mjs \
  NEW_FULL_SOURCE/report.json NEW_FULL_AUDIT.json

taskset -c 1 python3 tools/performance/phase4/derived-b1-full-archive.py \
  NEW_FULL_SOURCE/report.json NEW_FULL_AUDIT.json NEW_FULL_EVIDENCE
```

Reserve CPU 2 before the first command; the launcher selects it explicitly.
The audit and archive commands execute no compiler. They retain the experimental
boundary and fail on changed candidate, source, proof, cache, host, runtime,
Base or emitted bytes. Restoring evidence is not permission to relabel the
candidate as a checked build or silently update its reviewed hashes.
