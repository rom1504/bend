# Phase118 hosted entry cost: source audit

This is an offline source audit, not a profile or a performance result for a new
candidate. No compiler, target, benchmark, or native acquisition was run here.

## Evidence and scope

Root's `selfhost/build/phase118/float-hosted-cost01/report.json` measures eight
ordinary fixtures, one warmup and three alternating paired rounds on CPU3 with
Bun1.4.3. Relative to Phase117, the geometric whole prepared request cost is
1.12501× and the admitted entry cost is 1.18662×. The entry includes lowering,
planning, verification and rendering; it does not isolate their shares. This is
hosted API execution, not N1/N2 throughput or upstream timing.

The inspected source is `selfhost/build/phase118/float-source01/compiler.bend`,
SHA256 `b16a71925e94585b5d66a010a8377a1f6500376de217d90fee7eb2e8fcb26c08`.
Its actual checked API is `selfhost/build/phase111/p118-float-api01/api.mjs`,
SHA256 `10998a568a26e90cc17c2914548ed4cf3a5c7df01fda10f8448bc9d62ea123f8`.
These measurements do not describe the later stack-repair sources.

## Ranked concrete opportunities

1. **Stop observer admission at the first rejected guard.** Source
   `p118b_eligible` at line51283 combines every predicate with eager `&&`.
   Actual generated API lines8696–8710 unconditionally compute both root counts,
   `nq_uses` and `no_wrapper_nodes`, then use nested ordinary `$Bool$and$` calls.
   The final argument runs the complete mature C `no_emit` even when
   `no_plan_error` already rejects the plan. This is direct evidence of avoidable
   work; it does not establish how much measured time that work consumes.

   The isolated `eligible-staged.bend` overrides only this function. Its nine
   lazy `nt_choose` guards retain the original source predicate order and the
   final `String.is_empty(nc_error(no_emit(...)))` gate. The schema/env setup
   remains unchanged. For total pure predicates on the existing generated
   plans, both versions return the same conjunction; rejection now suppresses
   later work. Every accepted plan still executes every original check. Nothing
   changes ownership, source permission, residual admission, lowering or runtime
   contracts. This needs a checked API and exact emission comparison before a
   paired entry-cost measurement. Expected implementation complexity is tiny;
   the speed gain is unmeasured.

2. **Share one exact prepared-book bang analysis.** `p113pl_prepared` at
   lines46065–46069 computes `nc_bangs_names(book,names)` for
   `p111_compile_defs`, then calls `p113pl_plan`, which computes the same analysis
   on the same immutable prepared book and names at lines46059–46062. This
   duplicate predates Phase118. A local helper can bind `bangs` once and pass it
   to generic lowering and a `p113pl_plan_with_bangs` continuation. No global
   cache, invalidation scheme or changed admission is necessary. Preserve the
   existing public wrapper for other callers. Exact output equality is the
   appropriate first gate. Do **not** automatically reuse that value for
   `p118e_permitted`/`p118i_borrow`: those observer scans use the original
   `NR_Request` book, whereas the duplicate above uses the prepared book.

3. **Eventually validate the observer residual without constructing discarded
   C text.** The accepted path above calls `no_emit` solely for `nc_error`, then
   `p118b_functions` at line51443 separately lowers the same residual to
   structured QBE workers. `no_emit_return`, `no_emit_loop`, `no_emit_let` and
   `no_emit_match_layout` at lines36440–36481 construct C text trees and strings
   which admission discards. `no_observer_plan` itself does not run this emitter,
   so this is a second backend's generation work, not a duplicated plan call.
   A shared checked-residual contract could make C and QBE consumers of the same
   validated representation. That is more work than guard staging: the current
   C residual check is an intentional independent gate and must not simply be
   removed. First measure how often plans reach it after staged rejection, then
   assess whether extracting its exact validation pays for the proof surface.

4. **Carry immutable verification context across the small derived additions.**
   `p118b_verify_functions` at line51529 rebuilds original segment signatures and
   constructor indices before checking new borrowed functions. A request-local
   boundary object could retain indices from original verification, while still
   independently checking every added function and its imports. This has a
   wider interface surface than the first two changes. `p113e_originals`
   structural signatures are not interchangeable with `p111q_ids` emission IDs;
   they must not be conflated to save a scan. No timing evidence yet justifies a
   cache or a new framework.

## Work that is already shared or genuinely new

The integrated `p118e_workers` loop computes one `no_observer_plan` per candidate
and immediately passes that same plan to admission and worker lowering. It does
not run the old diagnostic plan/discovery path twice. `p118e_prepare` reuses the
existing scalar certificate rather than re-running `ns_definitions`.

The integrated entry runs the original complete `p113a_verify` once before
derived transformations. Borrowed worker verification is additional required
work, not a duplicate full-program verification. Likewise, `p118z_eligible`
certifies final functions and original segments for the new transport capability;
the certificate cannot be discarded merely because some earlier verification
accepted the program. Cold-constructor analysis and observer eligibility also
establish new facts absent from the Phase117 entry.

## Decision

Test staged admission first, keeping the running native qualification source
unchanged. An exact output bridge plus paired hosted cost decides whether it is
worth retaining. Prepared-book bang sharing is the next minimal deterministic
reuse experiment. The measurements do not yet show that any one of these scans
explains the entire 18.7% entry increase; avoid attributing the remaining delta
without an ablation or measured stage boundary.

Candidate `eligible-staged.bend` SHA256:
`dfa67afade68ac26c183f9858881fd4448b7b8a935195315ba55c2088fd74e62`.
