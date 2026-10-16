# P99-006: isolate large-image continuation dispatch

Status: diagnostic intervention, before execution. Production unchanged.

Large images use noinline wl_target to keep the static dispatch table out of each
segment's LLVM callgraph. Tiny append probes use direct wl_tab lookup instead, so
their timings did not test that source of the B1/B2 gap. Do not remove the existing
scaling workaround without checking compilation memory.

First compare three versions of the exact already-emitted append micro: ordinary
small-table dispatch, forced large-table accessor, and an immutable-in-use table
pointer whose pointer object is volatile. The latter tests a load instead of a
function call while preventing constant propagation. This is patched-C causal
evidence only, not an implemented Bend compiler optimization or a qualified image.
Preserve full outputs and run balanced single-worker samples. Inspect assembly.

If useful, test actual large-table LLVM scaling under a strict RSS/deadline bound,
then integrate the equivalent emitter/runtime change. Expected whole-compiler
gain is unknown; the observed append bucket gap is not wholly dispatch overhead.
Do not change reference-cell access, atomic ordering, thread or device semantics.
