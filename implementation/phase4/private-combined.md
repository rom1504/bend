# Private Boolean and stability combination

The four-way experiment passed all 48 selected observations, but **is not
approved for integration**. Its original private control later failed full-source
emission because two hoisted workers lost lexical helper bindings. That failure
also applies to the base transformation used by all four variants here. A fixed
image needs new gates and measurements; these results are not a whole-compiler
speed claim.

The completed checked H has SHA
`b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8`.
All variants use the same host, runtime, canonical Base and 63-export boundary,
with independent validated Base caches primed before timing. Earlier isolated
stable/weak-head experiments used a 54-export boundary; their absolute timings
are not substituted here. Three serial rounds alternate variant order, using
fresh Node processes pinned to CPU 0 with a 4 MiB stack and 3 GiB heap.

Median compiler request time, milliseconds:

| Case | Private control | Boolean only | Stable only | Combined |
| --- | ---: | ---: | ---: | ---: |
| Tree | 2088 | 2094 | 2044 | 1930 |
| List | 3652 | 3386 | 3593 | 3376 |
| Rejected bytes case | 1602 | 1459 | 1596 | 1508 |
| 312-declaration core | 26913 | 25727 | 25086 | 24522 |

The combined core median is 8.9% lower, with median process wall 28.184→25.752
seconds and peak RSS 606,976→603,396 KiB. Variation matters: the first core pair
regressed (27.896→28.341 seconds), while later pairs improved. Standalone gains
cannot be multiplied. All statuses, phases, checked flags, exact diagnostics
and emitted hashes matched. The rejected bytes case remains a rejection.

Composition starts from the same original H. It proves byte-for-byte that the
stable-only image equals canonical specialization plus the precise five-site
memo delta and helper, then applies that disjoint delta to the Boolean-only
image. It never specializes an already specialized output. Combined-image gates
passed 300 Boolean controls and 3,786 stability controls, including successful
deep finite terms at depths 128, 512 and 1024. The standalone shared-source and
shared-book controls are recorded in the stability report; a new combined
reused-source gate was deferred when the full-source scope bug took priority.

Reproduce preparation, focused controls and the matrix with
`selfhost/tools/performance/phase4/private-combined-{prepare,test,compare}.mjs`
and the archived configuration files. The Boolean gate uses the existing
`private-booleans-test.mjs` with control/combined as its two images. Exact
consumed tool snapshots, complete observations, configurations and hashes are
retained in [private-combined-evidence/manifest.json](private-combined-evidence/manifest.json).
The preparation still requires the original checked proof and its source/API
artifacts; the compact archive does not contain those large images. Current
canonical tools include the subsequent scope correction and therefore will
produce different image identities. Reproducing these historical timings
requires the archived consumed tools, not the latest transform.

Decision: retain the measured combination as a candidate, fix lexical capture
first, then require the relevant focused, broad and full-source gates before
supporting a named optimization profile. Ordinary public runtime, emitted
program/library ABI and the checked B1 development loop are unchanged.
