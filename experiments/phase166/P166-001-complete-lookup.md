# P166-001 — execution cost around the same compiler lookup

Hypothesis: our existing consuming equality is adequate, but its surrounding
ownership, index and call boundaries execute more work under QBE than under
bendc. Reuse complete source-derived lookup results and independently digest
all fields. Compile identical source bytes through explicit QBE/C/bendc routes,
keeping target-specific runtime/toolchain policies visible. Separate acquisition
from clean repeated execution; inspect the actual slow region afterwards.

Reject a speed explanation from an unobserved result, unequal source/work,
different semantic output, incomplete controls, insufficient timing or a
microbenchmark that bypasses the actual lookup boundary.
