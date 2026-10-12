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

Compiler16 passed199,400 controls and checked36/B2driver8, but its first screen
moves B1/B2 ratios2.910/1.879 to2.934/1.941. Array/lexer B2 are roughly unchanged;
numeric is slower. This is insufficient evidence of a gain and adds code, so
retain the simpler compiler14 set. Compiler16 and all unexecuted prepared plans
remain evidence; none are called release qualification.
