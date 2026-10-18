# P108-001: retain mature semantics, change machine-code acquisition

Status: designed, implementation beginning. [Design](../../design/phase108/full-native-qbe.md).

Hypothesis: an ordinary-ABI segment trampoline plus cproc/QBE can build the full
Bend compiler without porting all semantic lowering to Nx first. Existing Bend
ownership/closure/array/IO decisions can remain unchanged. This trades a temporary
C frontend dependency for a much smaller correctness surface and enables genuine
full-image measurements of QBE.

Falsifiers: cproc cannot compile required C with a small honest portability layer;
segment state transport changes observable behavior; full compiler memory/build
cost is unacceptable; generated compiler execution is too slow for practical use.

Controls: independent frozen program outputs; original musttail backend; portable
runtime built with GCC/Clang to separate transport faults from cproc/QBE faults;
complete C-product comparison and repeated compiler requests. Keep timing,
correctness and default-promotion decisions separate. Evidence will be linked in
implementation/phase108/README.md; no result is asserted by this design.
