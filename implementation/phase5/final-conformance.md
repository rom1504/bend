# Final Phase 5 frontend comparison

The final checked compiler preserves all 919 positive fixtures and reduces exact
live TypeScript differences from 560 to 444: **116 resolved, zero new**. Strict
check failures fall from 377 to 318, with 59 improvements and no strict-check
regressions. This is frontend evidence, not full language or runtime conformance.

The final genuine bootstrap API is
`5969c53d34a088bc9630eb2c065c2eea7fd260294cf3fefb14dffb305b7e4667`,
assembled source
`e3b927d13dc2645e19171b72de60c49dd5bc5e5059863937153b957e2ce0ec1d`.
The completed integration05 sweep contains all 2,756 observations across the same
1,378 pinned fixtures, with unchanged fixture bytes/oracles and pinned compiler
source identities. Workers report no failures/timeouts and no input/artifact
drift. This comparison ran no compiler and changed no compiler source.

The [machine-readable comparison](final-conformance.json) identifies every input
report and the [comparison tool](../../selfhost/tools/performance/phase5/final-frontend-comparison.py)
by SHA-256. The [original full-row comparison and consumed tool](final-conformance-history/manifest.json)
are retained separately; the compact final JSON changes representation only.
The campaign baseline is the retained Phase 4 combined-B1 report;
the live reference is Phase 5 `integration/reference-03.json`. All 2,756 live
reference observations equal the retained Phase 4 reference. It is a reused
freshly measured campaign reference, not a newly executed reference run.

| Measure | Campaign baseline | Final Phase 5 | Live pinned TypeScript |
| --- | ---: | ---: | ---: |
| Positive fixtures passing parse **and** check | 919/919 | 919/919 | 919/919 |
| Strict check passes / failures | 1001 / 377 | 1060 / 318 | 1375 / 3 |
| Exact parse-observation differences from reference | 185 | 128 | — |
| Exact check-observation differences from reference | 375 | 316 | — |
| Status/phase differences across both lanes | 50 | 16 | — |
| Same classification, different text/report | 510 | 428 | — |

All 459 negative parse probes remain **observations**, not checker passes.
The final check lane contains 141 passing negative strict oracles and 318 failed
ones. It observes 457 rejections and two acceptances, matching the reference's
status counts and individual check statuses. The two accepted negative fixtures
are `io/main_foreign.bend` and `reg/array_open_element.bend`; the pinned reference
also accepts them. Its third strict failure, `check/template_inst_cycle.bend`,
rejects with a diagnostic that differs from the fixture oracle. All three
reference failures remain explicit in the JSON, including exact diagnostics.

The workflow completes its requested inventory while retaining `pass:false`.
The frontend harness's own `complete:false` likewise reflects failed strict
expectations; it is not silently changed to success. Positive parse/check passes
do not establish program execution correctness. These runs overlapped other
correctness work, so their elapsed times are not controlled performance evidence.

## Remaining phase and acceptance differences

The remaining 16 status/phase differences occupy eight fixtures, with one parse
and one check observation each. None is new relative to the campaign baseline.

| Existing cause | Fixture keys (all `.bend`) | Remaining observations |
| --- | --- | ---: |
| Host missing-import classification: Bend reports `load`, TypeScript `parse`; both reject in both lanes | `import/cross_file_io`, `import/cross_file_proof`, `import/cycle_terminates`, `import/diamond_dedup`, `import/path_canonical` | 10 |
| `+` in a value-reference position: Bend rejects while parsing; TypeScript parses then rejects during checking | `comptime/err_plus_term`, `parse/plus_binder_term` | 4 |
| Dead prefix operator before `5`: Bend parses then rejects the unresolved name during checking; TypeScript rejects while parsing | `parse/prefix_operator_dead` | 2 |

Relative to TypeScript, the parse lane therefore has **two false rejections and
one false acceptance**. The check lane has no status/acceptance differences;
eight observations reject at different phases. Three of these also differ in
the `checked` flag. The ten missing-import observations differ in phase only,
alongside their retained diagnostic differences. This classification does not
turn earlier rejection into successful checker conformance.

The other 428 differences have equal status, phase, checked flag and exit status,
but different diagnostic/report text. They are **not necessarily cosmetic**:
the same phase can conceal a different selected error, parser state, expected
construct, or source origin. In total 159 candidate observations change from the
baseline; 116 become exact and 43 remain mismatches. No previously exact
observation becomes a mismatch. Original diagnostics are retained without
trimming or normalization in the four hash-identified input reports; the compact
JSON keys each remaining observation back to those records.

## Raw parser composition supplement

The genuine integration04 and integration05 APIs return deeply equal raw results
for pinned Base, list_sort, and the frozen integration04 compiler source
`8221634ef69e8970cecf62dd1a6643257a999d4cdc3fa2bae627f0f22a0bc69c`.
The compiler result serializes to 13,452,551 bytes with SHA-256
`fff10d2caabef553e6991d5f65fce673899867e4ebcff69fe00013f5c69320d2`.
Both isolated high- and low-surrogate inputs raise identical exceptions.
The [raw supplement archive](parser-expectation-combined-evidence/manifest.json)
preserves the actual bootstrap reports, consumed source identities and results.
This tests the composed parser change on the prior frozen compiler input; it
does not replace final-source checking or the independent self-host proof.
