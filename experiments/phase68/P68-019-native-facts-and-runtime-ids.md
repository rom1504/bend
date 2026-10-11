# P68-019: reusable ownership facts and foreign runtime IDs

Prospective design: [native facts and calls](../../design/phase68/native-facts-and-calls.md).
Compiler20 B2 ownership analysis samples162–170ms because each variable queries
its erased body again. Hypothesis: share exact use facts, preserving alternative
maximum and sequence saturated sum, and recover a material fraction of that cost.
Require old/new decision equality, exact generated C and clean request timings.
Independently fix the known FID(Clo~apply) rejection against pinned upstream's
runtime-ID contract; preserve namespace and unknown-name behavior.
