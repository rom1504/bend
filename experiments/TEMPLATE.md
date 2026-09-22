# P4-NNN — Short falsifiable hypothesis

- Owner / independent reviewer:
- Started / evidence cutoff / timebox:
- User objective served; investigator-proposed approach:
- Correctness status and exact scope:
- Measurement status and scope:
- Decision: investigate / defer / reject / promote.
- Related attempts, counterexamples and implementation report:

## Claim and cheapest disproof

**Hypothesis:** [Concrete mechanism, target workload and expected observable gain.]

**Invariant:** [Why ownership, forcing/error order, ABI, imports or cache identity
permit this change. State private-only assumptions explicitly.]

**Falsification / stop condition:** [A counterexample, absent opportunity,
regression, resource threshold, or timebox expiration.]

**Alternatives and rank:** [A few genuine alternatives and why this test comes
first; omit for routine fixes.]

## Controlled setup

- Compiler implementation / stage: pinned TypeScript, checked B1, public H,
  private H or native Bend; exact version/commit and proof status.
- Baseline / candidate source and artifact identities; dirty overlays included.
- Runtime, canonical Base, host/helpers, harness and toolchain identities.
- Input/fixture selection, emitted-code mode and expected outcomes.
- Changed factor; independently held controls; other concurrent CPU/memory work.
- Process model, affinity, stack/heap/deadlines, repetition/order, cache state.
- Measurement boundary: request, process wall, build, execution and/or peak RSS.
- Exact commands/configuration and immutable evidence manifest links:

```sh
# Minimal reproduction; give required environment and artifact preparation.
```

## Gates and observations

| Attempt / artifact | Correctness result | Time / memory | Interpretation |
| --- | --- | --- | --- |
| [Unique run ID and retained report] | [Exact verdict/phase/checked/diagnostic/output, or failure] | [All samples; units] | [Supports, refutes, invalid or unresolved] |

List cheap boundary tests and focused differential cases before any broader
suite. Include positive and negative cases, applicable ABI/partial/overapplication,
ordered effects/errors, fresh-source/import changes and cache invalidation.
For emitted programs, record both compilation and actual execution observations.
State selected/completed/failed/skipped counts; a selected subset is not a full
suite. Explain excluded or contaminated timings and retain them. Separate a
single exploratory observation from a repeated comparison.

## Independent audit

Reviewer, reproduction/inspection performed, counterexamples sought, findings,
corrections and unresolved limits. Identify any result only inherited from an
earlier report rather than rechecked here.

## Decision and next discriminating test

What is established, what is not, benefit versus risk, and exact promotion scope
if any. Name the smallest remaining test and the condition for abandoning it.
Link the resulting ledger entry/frontier; do not silently promote a prototype
into the normal compiler or change a public contract.

## Preservation

Tracked reports/scripts/configs; raw artifact identities and durable location or
regeneration recipe; failed attempts and superseded claims; omitted files and
reasons; missing dependencies or preservation gaps. Record the checkpoint commit
when one exists. Keep drafts and measured results labeled as such.
