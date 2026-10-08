# Private-worker force-inline diagnostic

Pre-registered as P68-008. `prepare.py` performs data-only source transformation;
it never invokes Clang or a generated program. Root-owned prepared artifacts:
`selfhost/build/phase68/flat-inline-proposal01/diagnostic.json` and its numeric /
array C files. Old flat06 files are read and hash-checked, never changed.

Root execution helper: `run-plan.py --manifest
selfhost/build/phase68/flat-inline-proposal01/diagnostic.json`. The helper pins that
exact manifest hash, uses the existing guard, writes `execution.json` beside the
manifest, and refuses an existing execution receipt or executable. It has only
been syntax-parsed in the preparation lane; root owns execution. Its commands
already pin targets to CPU3; the supervising Python process may run on CPU0.

The manifest contains exact Clang and runtime command arrays, receipt paths,
independent smoke/plan02 digests, baseline executable identities, and twelve
alternating baseline/candidate measurement commands. Pass those command arrays
unchanged to the existing `programs/support.py` ExecutionGuard; do not add another
taskset wrapper. Use its recorded 2GiB RSS / 4GiB available-memory limits, a
90-second Clang deadline, 20-second smoke deadline, and 45-second runtime deadline.
Do not run compilation or target work concurrently.

Before timing, require successful compilation, binary size at most the recorded
eight-times-baseline cap, and exactly four decimal output lines whose first three
equal expectedSmoke. For every measurement require the same first-three check
against expectedPlan02 and the existing child receipt clock bound. Keep below-
100ms observations explicitly timing-unqualified; do not recalibrate plan02.
Record Clang time/peak RSS and resulting binary identity/size. Use nm/objdump to
verify the hot calls disappeared after compilation. This is a diagnostic only;
no production policy, success or speedup is implied by prepared commands.

The inverse text replacement is asserted byte-for-byte equal to original C.
Numeric changes 28 declarations for 14 workers; array changes 34 for 17. Original
worker graphs pass the existing source gate and have maximum depths 4 and 6.
Both include a 265,784-byte cold worker body, so broad forced inlining can increase
code size substantially. That risk is deliberately measured rather than hidden
by choosing only benchmark-specific names.
