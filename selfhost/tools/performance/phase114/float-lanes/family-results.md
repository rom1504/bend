# P114-012: three additional historical families

All 27 output observations passed in three matched rounds on CPU 3. The selected
baseline-to-candidate medians are mixed; the geometric mean relative to upstream
changes from 4.78485× to 4.76924×, a **0.33% reduction** across these three cases.
The [measurement report](../../../../build/phase112/p114-float-family01-measure/report.json)
and [pinned offline summary](family-results.json) retain every sample and actual
measured product identity.

| Program | Upstream ms | Selected ms | Float-lanes profile ms | Candidate/selected |
| --- | ---: | ---: | ---: | ---: |
| mandelbrot |50|269|275|1.0223|
| symreg |50|93|94|1.0108|
| raytrace |57|624|598|0.9583|

The apparent nonwins have **byte-identical QBE, assembly and object files**.
Mandelbrot uses signed 8.8 fixed-point U32 arithmetic; symreg evaluates U32
expression trees. Neither emitted product contains F32 operations or float operand
casts. Their timing differences therefore do not represent a generated-code
regression from this profile. Executable files are not byte-identical; no binary
layout or statistical explanation is inferred beyond the observed code identity.

Raytrace changes: QBE falls 1,991,789→1,981,566 bytes and the object
326,720→326,136 bytes. Static float operand casts fall 1,446→1,410 and GPR/XMM
moves 1,299→1,271. The complete ordered QBE floating-point operation sequence is
unchanged. Assembly still contains 512 scalar arithmetic operations and 31
comparisons; instruction selection changes one subtraction to an addition.
These modest whole-file reductions are consistent with limited eligible local
chains, but are not a dynamic hot-path fraction or a complete causal explanation
for the 4.17% raytrace improvement.

This is the predeclared P114-012 extension, using deliberately selected historical
programs rather than blind holdouts. The parent scalar-operands overlay is included
in the candidate; this extension has no scalar-operands-only timing arm. Public
and private signatures remain integer, and all original U64 word results remain
emitted. The result does not qualify the whole 45 corpus, promote the profile, or
establish a broad/native-compiler gain. Earlier [P114-011 results](results.md) and
all frozen modules remain unchanged. Inspection only read existing artifacts;
no new targets were run.
