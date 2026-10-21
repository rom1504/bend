# A smaller loop can lose to its instruction layout

The first broad candidate improves the44-point aggregate6.15%, yet the two fused
list cases slow down. Longer unchanged-binary replay confirms366/327ms (+11.93%)
and387/319ms (+21.32%) for128/512. This is not dismissed as timer quantization.
The SSA diff contains two Boolean retest→copy rewrites; no new list construction.

The selected stream worker actually shrinks34→33 instructions and keeps zero
calls. In the parent, its compare/conditional branch starts0x405bc0/0x405bc4.
The unaligned candidate moves the pair to0x405bbe/0x405bc1, across a32-byte boundary.
That provides a specific machine-layout hypothesis; static size alone predicts
the wrong outcome. No sampled hardware-event evidence identifies the precise
microarchitectural cause, so we do not claim a measured decoder or fusion stall.

GNU assembler on this host documents `-mbranches-within-32B-boundaries`. The
experiment passes that option to the same assembler, with exactly the same checked
QBE input, QBE executable, runtime object and linker. It changes no Bend program,
IR, generated assembly text or runtime. The assembler selects ordinary instruction
padding/prefix placement. This is a toolchain-policy experiment, not a host-language
compiler pass or handwritten machine-code patch.

Three rotated, larger-batch observations per role give:

| Case | Aligned | Same candidate, ordinary assembly | Upstream |
|---|---:|---:|---:|
|List128|95ms|110ms|600ms|
|List512|92ms|117ms|598ms|
|Editdist|756ms|758ms|604ms|
|Mandelbrot|2093ms|2088ms|595ms|

All36 complete output/count observations pass. Lists recover14–21%; the two winning
scalar programs are neutral. The stream worker remains33 instructions; the
assembler's layout policy, not fewer operations, explains this ablation. This
supports the boundary hypothesis on this hardware, without proving a universal
CPU effect. `alignment-machine04/report.json` retains exact assembly and commands.

Qualification of the final policy passed405 runtime/output observations in one
additional runtime/build-only original45 campaign, reusing the already-verified emitted QBE.
No final point regressed more than2.5%; the two list regressions were removed. The expensive45-program emission
is performed once. Both the ordinary-assembler baseline and negative list result
remain preserved. Installed tools and qualified native images are unchanged.
