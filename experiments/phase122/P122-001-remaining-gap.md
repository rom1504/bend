# P122-001: profile the remaining native runtime deficit

Status: planned. See [design](../../design/phase122/remaining-gap-profiles.md).

Hypothesis: the40 still-slow timed points share representation, ownership or
control-boundary costs that larger semantic transformations can eliminate.
Competing explanation: numerical code mainly needs optimizations absent from
QBE, while structural programs need separate mechanisms. Existing C products
help distinguish these explanations but do not isolate backend vintage.

Use authenticated unchanged programs, fresh clean timings, physical-PC profiles,
generated-code inspection and original full-output oracles. No optimizer changes
in this investigation. Record weak/negative evidence and avoid treating helper
sample percentages as achievable speedups.
