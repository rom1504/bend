# Source complexity accounting

The current manifest and every listed Bend module match the selected checked snapshot. Counts use the unchanged Phase47 rules; they measure source size, not correctness or speed.

| Metric | Phase56 String01 | Selected Phase58 | Change |
| --- | ---: | ---: | ---: |
| physicalLines | 26,246 | 26,533 | +287 |
| codeLines | 21,585 | 21,801 | +216 |
| definitions | 3,012 | 3,051 | +39 |
| laws | 629 | 629 | +0 |
| types | 100 | 101 | +1 |
| modules | 107 | 108 | +1 |
| bytes | 1,180,940 | 1,196,246 | +15,306 |

Physical lines include comments and blanks. Code lines exclude blank and comment-only lines. Declarations are recognized at line starts. Generated compiler images and runtime support are reported separately in the JSON receipt.

| Changed module | Status | Physical lines | Code lines | Definitions | Types |
| --- | --- | ---: | ---: | ---: | ---: |
| `src/back/common/queries.bend` | changed | +21 | +14 | +2 | +0 |
| `src/back/js/direct/calls.bend` | changed | +2 | +2 | +0 | +0 |
| `src/back/js/direct/choices.bend` | added | +99 | +73 | +15 | +0 |
| `src/back/js/direct/constructors.bend` | changed | +110 | +88 | +16 | +1 |
| `src/back/js/direct/core.bend` | changed | +2 | +2 | +0 | +0 |
| `src/back/js/direct/host.bend` | changed | +0 | +0 | +0 | +0 |
| `src/back/js/direct/ordered-values.bend` | changed | +0 | +0 | +0 | +0 |
| `src/back/js/direct/ordered.bend` | changed | +2 | +2 | +0 | +0 |
| `src/back/js/direct/pattern.bend` | changed | +39 | +28 | +5 | +0 |
| `src/back/js/direct/reach.bend` | changed | +12 | +7 | +1 | +0 |

98 source modules retain exact bytes. Native modules exact: True. Runtime/support/driver inventory exact: True.

Receipt: [source-accounting-reach01.json](/home/ai/bend2/build/publish/bend/selfhost/build/phase58/source-accounting-reach01.json). It pins both attempts, the inherited counting method, every source input and the final rehash. No historical archive was opened.
