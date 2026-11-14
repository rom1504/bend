# Phase195 — remove the large x86 execution gaps

Start: 2026-11-14 01:56 UTC, baseline `5c67ac5`. Objective: direct-x86
compiled-program runtime at mature Bend C parity, retaining correctness,
stack safety, reasonable compiler cost and a coherent Bend implementation.
Current measured reference is 1.971034× C across44 eligible native45 cases;
QBE is1.348552× C. Parity requires49.27% less runtime geometrically.
These are goals and baselines, not predicted outcomes.

## Selection before implementation

The previous campaign removed real work but did not price its dynamic share.
This cycle starts with current physical profiles and actual C/QBE/x86 code.
One main agent controls the CPU3 execution lane. Bounded Astra High agents own
float/ray composition, ordinary placement, ownership, profiling, independent
falsification and retention. No competing heavy timing jobs.

Competing hypotheses, initially unproved:

1. Selection and allocation disagree. Certified predicate/address selection
   removes intermediates after placement; original interference may retain
   avoidable spills. Preserve original emission semantics but give allocation a
   conservative description of the actually selected computation.
2. Existing certified QBE capabilities do not compose into x86. Ray's four
   constant-table calls per sphere and remaining runtime operation dispatch
   are concrete witnesses. Reuse semantic admission before inventing new IR.
3. Global allocation silently falls back above its body/name budgets. Measure
   actual selected hot functions before raising bounded limits or redesigning
   the allocator. Larger graphs must earn their compiler-cost increase.
4. Shared ownership/product boundaries retain avoidable work. Check actual
   selected paths; cold generic workers do not establish a dynamic opportunity.

## Efficient experiment ladder

- Reuse Phase194 products and calibrated workloads. Profile ray/editdist first,
  then a small tree/Map/lexer transfer group. Hardware counters unavailable under
  current permissions; physical PC samples are not stall or cache-miss counts.
- Inspect selected IR, physical homes and actual machine code. For each candidate
  record the removed work, plausible whole-request ceiling, unknown costs and
  cheapest semantic/performance falsifier. Reject duplicated prior mechanisms.
- Build checked experimental APIs from the exact Phase194 source. Run independent
  component oracles and small real programs. Require actual admission/machine
  change before timing. Aim for large kernel improvements across unrelated
  workloads; a small successful peephole does not establish a parity route.
- Compose only compatible successful candidates. Freeze ten development/35
  held-out native45 cases; new diagnostics remain separate. One broad balanced
  runtime comparison follows promising small screens. Preserve every regression.
- Perform independent source checking, final-verifier/ABI/ownership controls and
  native generations only for an integrated candidate that earns qualification.
  Keep the installed release and all qualified references intact. No theorem or
  recursive acceleration is inferred from self-reproduction.

## Deliverable and resources

Compiler transformations stay in Bend. No benchmark-name matching, altered
oracles, relaxed verifier or backend substitution. Preserve failed hypotheses,
exact identities and all source/runtime/compiler cost distinctions. Report
geometric and equal-family runtime, positive-log deficit, fixed-work excess,
threshold counts, compiler requests and source growth. Commit and push selected
work and honest evidence, without posting PR comments.

All target jobs use one outer resource/disk guard and retained closures,5GiB
reserve and bounded roots. Archive/verify/restore only individually reviewed
historical generated text if space is needed; never discard current evidence.
