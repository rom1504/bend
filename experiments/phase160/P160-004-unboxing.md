# P160-004 — one-policy correctness ablation

The default-policy cross-built request fails ordinary Map before producing QBE.
Its malformed array-lowering diagnostic is not a performance result. Static
audit finds a concrete projection error: P113DProgram.functions is passed where
the enclosing P113DLowered.error String is required. See request-failure-audit.md.

Disable only bendc's documented BEND_UNBOX policy; keep OPT defaults, source,
Base, private bounded-search runtime and the exact legacy effect adapter fixed.
Emit after independent source checking/equivalence, build at the same-O2 level,
then repeat the original complete-output Map gate. Do not patch the compiler
algorithm, edit the wrong C projection by hand, or weaken any verifier.

If this fails, retain the counterexample and stop the full cross-build rescue;
the complete-parser fallback is prepared. If it passes, run an actual checker
source request, then the original full compiler input, keeping whole-process
time, memory and independent QBE bytes. This is a bounded ablation, not general
correctness or qualified promotion of bendc's backend/runtime.
