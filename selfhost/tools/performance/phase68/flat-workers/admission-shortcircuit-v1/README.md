# Flat admission short-circuit v1

Isolated source proposal against the flat06/v3 flat.bend baseline; no production edits or target execution. Only nf_admit_pass and nf_deps_ready change.

The actual checked flat06 api.mjs evaluates source && through eager Bool.and (line13081), so every admission pass scans dependencies even for already-admitted or failed candidates. nf_deps_ready (line16394) likewise evaluates every dependency, including native classification for self and admitted names, and continues after a failed dependency. Explicit nt_choose makes the pure analysis conditional.

The predicates are mathematically unchanged: a candidate is added exactly when absent from ready, code has no error/segments, and all dependencies are self, native, or admitted. Worker order and prepend order remain unchanged. Compiler emission, scheduler/runtime ownership, native eligibility, and generated calls are untouched. Record exact compiler and generated-C equality in root-owned qualification; no measured speedup is claimed.

The product owner can compose the two definition replacements independently of the evolving product interface. Old baseline/proposals remain immutable.
