# P68-023 — Unreachable bang references contaminate native scheduling

- Owner: root; independent source confirmation by architecture, code-shape and
  sampling lanes. Registered during P68-022 before diagnostic execution.
- Decision: investigate saved-C mechanism only; compiler source unchanged.
- Correctness/measurement at registration: not yet measured.

## Claim

Compiler23 scans bang references across the entire book before traversing from
`main`. Unused imported original mains call tree `bsort!`/`scan!` and lexer
`batch!`, whereas the benchmark wrappers call their ordinary `bench` entries.
Their dead references mark reachable definitions and generated continuations
bang-capable: tree `BANGS 39`, lexer `BANGS 16`, versus upstream `BANGS 0`.
This disables the ordinary sequential runtime path and excludes some ordinary
workers even though the reachable benchmark contains no corresponding bang call.

**Hypothesis:** correcting only the global runtime mode in saved C removes a
substantial part of the runtime deficit. It does not test additional gains from
corrected worker admission. No timing estimate is assumed.

## Smallest test and limits

Fresh derivatives replace exactly one `#define BANGS 39/16` with `BANGS 0`,
leaving FID tables, code and runtime otherwise exact. Use identical Clang flags,
single guarded CPU3 target, GPU off and independent outputs. Smoke repetitions
1 and17; compare original/diagnostic/upstream in three balanced orders at the
previous fixed work counts and >=100ms interval floor. Include threads4 oracle
controls, without treating their timing as a speed result.

These are pure benchmark workloads with existing sequential parallel-let
fallbacks. Correct digests do not qualify arbitrary concurrent foreign effects,
GPU execution, error polling, raw APIs or a compiler change. A failed oracle,
timeout or absent material gain rejects/narrows this particular mechanism.
Keep the original C, failed attempts and receipts. Report runtime-mode results
separately from broader reachability/worker-admission hypotheses.

The [survey report](../../implementation/phase68/c23-parity-survey.md) records
outcomes and next compiler-level counterexamples. A general fix would derive
bang facts from the same live erased definition closure used for emission,
including reachable closure targets and actual parallel/foreign boundaries.
