# Phase157 — same-workload bendc comparison

Starting point: `fd2e63e`, qualified Phase152 N2 unchanged. Compare one identical
captured compiler computation through upstream C/Clang, qualified direct QBE,
and pinned Lulzx/bendc C/Clang with explicit GC and RC policies. This is a
runtime/representation experiment, not a comparison of different compilers
compiling their own sources.

Use the retained Phase154 compiler-owner workload and its independent complete
QBE output oracle. Preserve the actual lowering, scalar transform, independent
verifier, emission, input loading and teardown. Extract an exact dependency
closure to keep acquisition bounded; do not replace work with a checksum-only
toy. Freeze common source, Base, input book and expected output before timing.

First authenticate the public bendc seed/runtime and compile the seed on x86_64.
Its direct native emitter targets AArch64, so this experiment uses its C backend.
Check common-source compatibility before building all roles. Ordinary source
checking and exact output agreement are separate gates. Preserve refusals and
failed acquisitions; do not count matching errors as successful outputs.

Build each role once, separate acquisition/check/emission/machine construction
from execution, then pilot for sufficient duration. Use balanced role rotations,
one CPU3 lane, one runtime worker and GPU off. Include input parsing and final
reclamation in elapsed time. Collect exact child user/system CPU and maxRSS;
hardware counters are optional and unavailable counters must remain unavailable.
Report complete process times, not a startup-subtracted headline. Zero-repeat
controls may diagnose shared input cost separately.

Use existing guarded build and measurement tools: default2GiB tree RSS,
16GiB available memory floor,5GiB free disk reserve and explicit whole-run disk
budgets. Close runs and preserve exact reproducibility evidence. No full compiler
rebuild, production edit or installed selection change is required. A large
backend difference motivates a specific representation/lifetime experiment,
not an automatic runtime migration. Small extracted-owner gains do not establish
whole-compiler or broad generated-program gains.
