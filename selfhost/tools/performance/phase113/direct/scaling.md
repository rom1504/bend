# Source31 lowering scaling audit

Source-only inspection, 2026-10-20. No compiler, API, benchmark, or generated
program was executed for this note. The reported frontend 204 seconds and
unfinished lowering after more than 394 seconds are observations supplied by
the root runner, not measurements made here. They do not identify a slow pass.

The inspected assembled source is
`selfhost/build/phase113/wide-source31/compiler.bend`, 2,232,290 bytes,
SHA256 `287c85558f3eb40d5576b51a4f7c0238100a9c4c93fc36ee52e3b8bc4e2ac303`.
The active receipt is
`selfhost/build/phase111/p113-final31-full-emit/report.json`. Its lowering entry
is `p113a_lower_request`; the selected source, rather than the unoverridden
module defaults, establishes the composition below.

## Findings, in order to isolate

1. **Four complete verifications are inside the lowering timer.** At assembled
   lines 44741 and 47608, the selected chain is
   `p113a_finish(certificate, p113k_lowered(p113i_lowered(p113pl_lower_request(request))))`.
   `direct-opt/pass.bend:39` and `scalar-facts/entry.bend:25` each verify both
   their input and transformed candidate. On a valid successful path this is
   four `p113d_verify` calls before the runner's explicit final verification.
   Assembled lines 45115–45131 show that each also calls `p112s_verify` on the
   unchanged original generic/static program, then verifies all direct
   functions. The inliner output and range input checks even examine the same
   graph. The receipt's `explicitVerificationPasses: 1` describes the outer
   runner, not these internal optimizer checks. This is certain repeated work;
   its fraction of elapsed time is unknown. Preserve the gates for the first
   diagnostic run. A later implementation can reuse validated immutable
   originals and the adjacent postcondition instead of recomputing them.

2. **Product planning adds whole-body work before admission.**
   `products/plan.bend:52` constructs the complete generic/static fallback and
   separately constructs direct candidates. `p113pl_candidates` builds a boxed
   candidate for every eligible definition and a second flat candidate when a
   product signature exists. Each performs body compaction/reapplication and
   lowering before the closed-call filter decides whether it can be used.
   There is an arity bound, but no candidate body-size bound at this stage.
   This is deliberately more work than the old generic path; an unsupported
   candidate can also lower substantial subtrees before returning an error.
   The actual number and sizes of such candidates on the compiler are not yet
   recorded.

3. **Known product lets retain a quadratic suffix pattern.**
   `products/liveness.bend:30` (`p113px_known`) reconstructs the entire remaining
   sequence. `products/layout.bend:36` (`p113p_bindable`) then scans it for both
   maximum and minimum uses. `products/lower-helpers.bend:111`
   (`p113pl_bind_flat`) scans ownership uses, substitutes the virtual bundle
   throughout that suffix, and calls the lowerer again, rebuilding its
   liveness plan. A chain of known flat bindings can therefore visit suffixes
   of lengths n, n-1, ..., 1: O(n²) syntax work even though ordinary boxed lets
   use the persistent suffix-use plan. This is a concrete possible scaling
   mechanism, not evidence that compiler functions contain enough such chains
   to dominate. A future fix should retain substitutions in a scoped bundle
   environment or update cached analyses with a proved rule; simply deleting
   the use checks would change ownership admission.

4. **Range joins traverse all accumulated facts, and ranges run twice.**
   `scalar-facts/domain.bend:91` rebuilds a joined map by visiting the complete
   left map and querying the right map. The join sites in
   `scalar-facts/walk.bend:23` and `:71` retain facts for prior assignments,
   without liveness pruning or a changed-name set. Sequential branches after
   growing prefixes can cost O(branches × accumulated facts), potentially
   quadratic within a function. The selected bottom-up override at
   `scalar-facts/bottom-up.bend:6` runs `p113k_function` after inlining each
   eligible function; the final `p113k_lowered` runs it again over all functions.
   This may be useful optimization, but it is repeated analysis. The <4096-node
   range limit bounds admitted function size, not aggregate compiler work.

5. **Inlining has bounded expansion but repeated size/shape scans.** The
   selected `direct-opt-products/policy-wide.bend` allows 384-node callees,
   2048-node callers and a 1024-node expansion budget; the selected site cap is
   16. `p113j_cost` scans expanded size and scratch requirements per considered
   site, and table insertion scans the completed function for eligibility.
   `direct-opt/eligibility.bend:83` saturates the numeric size at 4096 but still
   traverses every node: saturation is not an early traversal cutoff. Expanded
   bodies and longer renamed identifiers increase subsequent verifier/range
   work. This is bounded amplification, not evidence of exponential expansion.

## What the source does not support blaming

`direct/plan.bend:73` performs at most 32 dependency passes, uses indexed ready
lookups, and reuses already lowered candidates. It does not re-lower bodies on
each pass. The inliner also has an indexed callee table and one callee-before-
caller traversal. Width legalization and QBE emission occur after the current
lowering timer; they cannot directly explain a stall still inside lowering.
No evidence here establishes a leak or a particular runtime/compiler speedup.

## Smallest ordinary stage-isolation experiment

Use the same pinned compiler input and checked API. Run the frontend once and
retain its actual `NR_Request` in memory. Add diagnostic exports, if needed,
which expose the existing Bend stage functions without changing their bodies:

1. Time `p113pl_lower_request(request)` and retain its exact result.
2. Time `p113i_lowered(result)` and retain its exact result.
3. Time `p113k_lowered(result)` and retain its exact result.
4. Construct the unchanged array certificate/facade, perform the normal final
   verifier, and emit normally. Keep the original source31 path as the baseline.

The host only transports existing values and records timestamps; it must not
implement lowering, bypass verification, or serialize large graphs inside a
timed stage. Record direct-function count and total/max body-node counts after
each stage, outside those timers. These three boundaries first distinguish
candidate construction from inlining/verification and range/verification.

Only split the slow stage further: product lowering into generic fallback,
signature/candidate construction, and closed admission; optimizers into their
existing pre-verifier, transformation, and post-verifier. Compare the final
verified output with the unmodified route. That gives attributable evidence
before changing policy, adding candidate limits, or removing redundant checks.
