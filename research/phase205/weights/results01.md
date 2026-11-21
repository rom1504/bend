# Frozen Phase200 fixed-work ceilings

Arithmetic ceiling only, not a new measurement or demonstrated implementation. Source transfer means all observed inputs sharing the explicit source hash, not a proof that a rule transfers. Lexer, Unicode text, tree-bitonic, BST and expression are separate explicit groups; combined scenarios are unions without double counting. C parity is a reference scenario, not a physical lower bound; zero-cost elimination is the absolute source-only bound with everything else fixed. Original Phase200 guard failed disk budget; all captured observations were independently recovered. Dispersion flags and frozen fixed workloads remain unchanged.

Candidate 17.810074651 s; C 10.941416148 s; ratio 1.627766864. Signed excess 6.868658502 s; positive per-case excess 8.340235689 s.
To reach 1.5× C: save 1.397950428 s (7.849212% of candidate time); target 16.412124223 s.

| Family | Cases | Candidate s | C s | Signed excess s | Positive excess s |
|---|---:|---:|---:|---:|---:|
| lexer | 3 | 1.918631045 | 0.683555164 | 1.235075880 | 1.235075880 |
| raytrace | 3 | 3.091074261 | 1.900960342 | 1.190113919 | 1.190113919 |
| bst | 2 | 1.154127560 | 0.414456801 | 0.739670759 | 0.739670759 |
| test-evening-program | 1 | 0.926928571 | 0.264588113 | 0.662340459 | 0.662340459 |
| map-churn | 2 | 0.969980106 | 0.342390369 | 0.627589737 | 0.627589737 |
| test-rle-roundtrip | 1 | 0.975238393 | 0.420436067 | 0.554802326 | 0.554802326 |
| mandelbrot | 3 | 1.232487231 | 0.756278257 | 0.476208974 | 0.550771539 |
| record-aggregation | 2 | 0.807680387 | 0.310250940 | 0.497429448 | 0.497429448 |
| test-map-set-ops | 1 | 0.601646175 | 0.234550438 | 0.367095737 | 0.367095737 |
| test-morning-program | 1 | 0.484679464 | 0.157938041 | 0.326741423 | 0.326741423 |
| editdist | 3 | 0.925627435 | 0.604790799 | 0.320836636 | 0.320836636 |
| complete-generic-row32 | 1 | 0.375428571 | 0.116431440 | 0.258997131 | 0.258997131 |
| tree-bitonic | 3 | 1.059370653 | 0.810780291 | 0.248590362 | 0.248590362 |
| unicode-text | 2 | 0.388512596 | 0.157284043 | 0.231228553 | 0.231228553 |
| numeric-recurrence | 2 | 0.608314304 | 0.406552230 | 0.201762074 | 0.201762074 |
| local-fold | 3 | 0.793435796 | 0.854671070 | -0.061235273 | 0.161221693 |
| local-pair | 1 | 0.303017857 | 0.200926372 | 0.102091485 | 0.102091485 |
| symreg | 3 | 1.070842715 | 1.006966189 | 0.063876526 | 0.063876526 |
| scalar-region-8192 | 1 | 0.000101563 | 0.210999735 | -0.210898173 | 0.000000000 |
| closures | 2 | 0.011669881 | 0.146238793 | -0.134568912 | 0.000000000 |
| list-pipeline | 2 | 0.075313488 | 0.286968870 | -0.211655382 | 0.000000000 |
| expression | 2 | 0.035966598 | 0.653401786 | -0.617435188 | 0.000000000 |

| Source-group scenario | Cases | C-parity saving s | Zero-cost ceiling s | Whole / C at parity | Required group speedup |
|---|---:|---:|---:|---:|---:|
| lexer | 3 | 1.235075880 | 1.918631045 | 1.514886057 | 3.6848520635909843 |
| unicode-text | 2 | 0.231228553 | 0.388512596 | 1.606633534 | impossible |
| tree-bitonic | 3 | 0.248590362 | 1.059370653 | 1.605046737 | impossible |
| bst | 2 | 0.739670759 | 1.154127560 | 1.560164028 | impossible |
| expression | 2 | -0.617435188 | 0.035966598 | 1.684197876 | impossible |
| lexer+text | 5 | 1.466304433 | 2.307143640 | 1.493752728 | 2.537572442601199 |
| lexer+text+tree-bitonic | 8 | 1.714894795 | 3.366514293 | 1.471032601 | 1.7101371985116929 |
| lexer+text+tree-bitonic+bst | 10 | 2.454565554 | 4.520641853 | 1.403429765 | 1.4476748540935784 |
| lexer+text+tree-bitonic+bst+expression | 12 | 1.837130366 | 4.556608451 | 1.459860777 | 1.4425773280936165 |

Exact rational seconds, every case/source hash, scenario membership, dispersion flags and a 1.5× selected-source-speedup scenario are retained in JSON.
Reproduce: `python3 -B research/phase205/weights/analyze.py --out /tmp/phase205-weights.json`. Use `--report` for an extracted archived report with identical bytes.
