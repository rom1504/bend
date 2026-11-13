# Reuse verified recursion plans in direct x86

This experiment follows the first Phase192 development screen, rather than
assuming register cleanup can close the remaining gap. The nine-case screen
improves 8.05% geometrically, dominated by numeric recurrence taking 0.51429×
Phase191 time. It does not establish a broad-suite result. Shared-address
selection initially missed fold's eleven-row computation; the sixteen-row
revision is separately controlled. Predicate normalization is not credited with
a large lexer gain.

The more consequential finding is a missing backend capability. QBE's public
renderer selects verified recursive continuation plans from the shared cursor.
`x181_program_public` currently ignores that context and emits the generic
segment. Current QBE products contain recursive-region workers in 27 cases
across 14 families excluding ubiquitous String.length; x86 contains none.
This is static coverage, not a speed prediction.

Fresh tree/expression/lexer profiles support testing this boundary. Descriptive
per-repetition expression evaluation leaf cost is approximately 1.166 µs in x86
and 1.138 µs in C, while total sampled-run cost is 5.790 versus 2.189 µs. Much
of the deficit is outside the arithmetic leaf: continuations, transitions and
wrappers. Lexer similarly has a large generator/continuation contribution.
These observations do not prove that all excess can be removed. Profiles use
different repetition counts and retain unresolved sample weight.

## Small general implementation

Consume the existing checked `P114HPlan`, with its original eligibility,
hygiene, closure and callable-registry conditions. Do not implement a second
recognizer or parse QBE text. Preserve complete-direct-worker precedence and
the existing mode-zero fallback. First use the original ready registry;
extended helper-resume policies require their own qualification.

Lower its structured statements into one `P113D` worker with explicit descend
and unwind state. Reuse x86 instruction selection, allocation and `Again` loop
transfers. Keep continuation frames on the existing runtime stack. Track local
depth; depth zero returns without touching the caller's frame. Snapshot arguments
before backedges, preserve push/pop/capture order, and dispatch only to verified
closed continuation cases. Native CPU recursion is not an acceptable substitute.

The public adapter reads the same parameters and returns through the existing
runtime protocol. Unsupported plans or unavailable helper references keep the
original segment. No installed selection changes during this experiment.

## Decision ladder

1. Query actual H admission for expression, tree and lexer, using the retained
   checked continuation probe. Confirm the proposed capability reaches hot code.
2. Source-check the experimental module. Independently audit stack depth,
   argument snapshots, case captures, ownership, state and fallback behavior.
3. Execute small independent source oracles covering nested continuations,
   sharing, an external caller frame and deep stack-safe recursion. Inspect
   generated code for actual removal of internal jump/return transitions.
4. Compare complete development workloads with the frozen Phase191 and first
   Phase192 candidate. Keep policy ablation and compiler-emission cost separate.
   Reject the port if it merely moves comparable work into a mode dispatcher.
5. Only after transfer, freeze the composition for all45 outputs and runtime;
   then acquire and qualify native generations once. Preserve failures.

The opportunity is reuse of an existing semantic capability across backends.
The scope ambition is much larger than a peephole, but neither parity nor a
particular whole-suite factor is promised. It is a compiler improvement, not
evidence of autonomous recursive acceleration.
