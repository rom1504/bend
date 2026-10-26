# Isolated append benchmark screen

`bench-commands-v01.sh` is a prepared, root-only CPU3 sequence. It compares the
checked Phase143 parent with `append-source01`, not the larger unchecked
`integrated-source02`. The four cases, sources, outputs, arguments and batch
counts come unchanged from the frozen Phase131 benchmark campaign:

| Case | Repetitions | Warmups | Arguments | Role |
|---|---:|---:|---|---|
| Unicode text 16 | 8,272 | 4 | 16, 17 | String transfer |
| Unicode text 64 | 2,024 | 4 | 64, 123 | String transfer |
| RLE roundtrip | 970,904 | 4 | 0, 0 | List append transfer |
| List pipeline 128 | 99,496 | 4 | 128, 17 | Unrelated already fused control |

The last case previously ran in about 31 ms. Its millisecond resolution limits
interpretation of small differences; the report flags every interval below
100 ms. Counts are not increased after observing candidate results.

Both current producers emit complete QBE using the checked Bend sealed cursor.
The build tool checks retained Phase131 products before building anything. Reuse
requires byte-identical complete QBE, exact runtime, assembler/QBE/linker and
build-method identities, successful build statuses, and intact object/binary
pins. A candidate identical to its newly built baseline may reuse that binary.
Otherwise it invokes the unchanged Phase123 branch-aligned builder. No current
baseline is replaced by an old timing measurement.

Each of the eight products first passes a one-iteration native smoke using the
original `phase112/benchmark45/run.py::observation` oracle. The same oracle checks
the exact semantic output, warmup success count, measured success count, elapsed
integer, exit status and empty stderr in all 32 timed observations. Four rounds
alternate baseline/candidate order. The report retains all raw observations,
paired ratios and medians; this is a diagnostic subset, not the historical
44-program score or an upstream comparison.

Both capability masks and static `p125_rt_concat_typed` call counts are recorded.
The isolated candidate also certifies that existing helper as live-bank safe.
The earlier ordinary List fixture changed capability mask 11 to 15, whereas the
String fixture stayed 15. Consequently a List gain may combine append behavior
and recovered register transport. A String result with unchanged mask is the
cleaner test of the newly admitted source-level append helper. Static call
counts alone do not establish that the timed computation takes that path.

The plan and scripts are prepared only. Completed reports in
`selfhost/build/phase144/append-bench-*` are the authority for actual execution,
reuse decisions, correctness and measurements. No native acquisition or default
compiler change is part of this screen.

## Completed isolated screen

Root executed all four jobs successfully. All four current baseline QBE products
were byte-identical to the retained Phase131 products, permitting authenticated
binary reuse. The candidate needed three fresh builds; the List pipeline reused
the exact same binary as baseline. Eight smoke checks and all 32 timed complete
output/count checks passed.

| Case | Baseline ms | Candidate ms | Median candidate / baseline | Actual QBE difference |
|---|---|---|---:|---|
| Unicode text 16 | 282, 279, 282, 280 | 282, 272, 277, 273 | 0.97865 | Guarded concat call, unchanged fallback and capability15 |
| Unicode text 64 | 286, 287, 288, 292 | 277, 275, 276, 278 | 0.96174 | Same guarded concat addition |
| RLE roundtrip | 1137, 1141, 1132, 1130 | 1040, 1032, 1035, 1030 | 0.91097 | Only capability11→15 in program descriptor |
| List pipeline 128 | 31, 33, 36, 32 | 31, 38, 32, 37 | 1.06154 | None: exact same QBE and executable file |

The List pipeline's apparent 6.15% regression is an unchanged-binary negative
control. Both roles executed the same pinned path/hash, so it is not caused by
this compiler change. No longer rerun is needed to establish that identity. It
illustrates why a 31–38 ms interval is unsuitable for small performance claims.

RLE's improvement isolates the restored live-register transport certificate;
there is no newly introduced concat call in that program. Unicode's smaller
improvements are the evidence for newly admitted String append. Their complete
QBE differs by just the guarded helper call and branch, retaining the existing
fallback verbatim. These are preliminary four-pair measurements, not a broad
qualification or a predicted full-compiler speedup. The helper still scans and
checks the whole left spine; sharing or a static node uses the original fallback.

`bench-audit-v01.json` pins both source products and executable products and
records exact changed lines, capabilities, all timing arrays, and binary identity.
Root's authoritative execution receipts are
`append-bench-builds01/report.json` and `append-bench-timing01/report.json` under
`selfhost/build/phase144/`. The complete guarded sequence took 15.52 s for the
32 measured program invocations plus per-observation handling, excluding emission
and builds.
