# Exact native milestone pilot

The first small request passes: the unchanged Phase142 N1 object, relinked with
optional milestone instrumentation, emits the exact frozen 577,297-byte Lexer
QBE product. All eleven direct dispatch markers occurred once, in order, and
their addresses agree with the actual linked image. The data-only join is
`selfhost/build/phase143/milestones01/lexer02-verification-v02.json`; exact input
pins and interval values are preserved in [milestone-pilot.json](milestone-pilot.json).
No full-source milestone request was executed by this investigation.

| Diagnostic entry interval | Wall milliseconds |
| --- | ---: |
| Base preparation | 230.35 |
| Parse/load | 56.18 |
| Checking plus publication | 43.75 |
| Proof dependence report | 9.80 |
| Owned/foreign eligibility | 7.83 |
| Main eligibility | 0.42 |
| Checked context reconstruction | 22.09 |
| Annotation/reach preparation | 16.63 |
| Annotation layout check | 3.76 |
| Erasure/request finalization | 22.77 |

The complete diagnostic request took 1.558 seconds. These entry intervals
include continuations and reference management. Backend, rendering and final
teardown remain unsplit. This pilot validates the boundaries and output, not
instrumentation neutrality or full-compiler proportions.

Two negative observations are retained. The first launcher refused explicit
`BEND_PROFILE_COUNTERS=0` before starting the target. The successful request
sets only `BEND_MILESTONES_OUT`; the runtime already disables counters when no
event path is supplied. The first offline verifier then rejected relative
`--image` and `--source` arguments even though their original guard input
snapshots authenticated the exact absolute files. Frozen v01 and its failed
receipt remain unchanged. Version v02 checks unique explicit option positions,
allowed absolute/repository-relative spellings, and the original snapshot's
full path/size/hash; it does not infer an unrecorded working directory.

A full-source diagnostic run is now technically viable, but should be selected
only if exact phase ceilings can change the next implementation decision. Its
cost must be accounted separately from a clean baseline, and selected compiler
source, output semantics and production selection remain unchanged.
