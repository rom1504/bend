# P75-015: pack adjacent binder IDs into bitmap leaves

Compiler14 preserves complete original C in nine requests; its B2 screen is
about1.88x TS. New profiles still charge44ms leaf time to occurrence traversal,
26ms to NU insertion and200ms to GC. Binder IDs are often adjacent. Store32
membership bits per Patricia leaf rather than one key per leaf, preserving
full32-bit IDs, immutable old sets and duplicate insertion sharing. This cuts
interior paths and allocations without changing the analysis or user code.
Use the same differential set/raw-term controls, plus dense32-bit word boundaries,
then clean three-family timings before integration. No C/runtime modification.

Compiler15 was rejected by the checked bootstrap: U32.shr/shl are unary, not variable-count shifts. Compiler16 uses existing shrn/shln with bounded Nat counts. No failed candidate is benchmarked.
