# P75-007: runtime layout gate after scheduler-body removal

The six-round runtime gate detects tree+4.7% and Array.map+4.8% despite smaller
C and identical optimized worker sections. Other families move approximately
-3% to+1%. Do not promote on aggregate score alone.

The saved tree binaries have273 common function symbols, all273 with identical
sizes, and all273 at different offsets modulo64. Array.map has291 common
functions,287 of equal size and252 of those at changed modulo64 offsets. This
is evidence for a layout experiment, not proof of cause or instruction equality.

Test a single saved-C change: align host scheduler entry functions to64 bytes.
The existing WL_FN macro already marks these functions noinline/preserve_none;
add only aligned(64), leaving device switches untouched. Start with tree and
Array.map, then check all families if useful. Retain failed trials. A successful
saved-C falsifier must become an actual compiler/runtime change, pass emitted-C
identity and runtime/correctness gates, and earn new compilation measurements.
No benchmark names, fixed output substitutions or weakened checks enter production.
