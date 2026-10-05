# Phase53: correct direct JavaScript, make it the default, then optimize

## Objective and starting point

Keep the compiler implemented in Bend. Fix the remaining Phase52 NaN source
oracle mismatch, make the direct JavaScript backend the ordinary compilation
default, and reduce the remaining generated-program execution gap. Preserve
explicit access to the legacy backend and the existing native targets.

Start from commit `860c68b85aaf36806775457b1842a3bf3dc7b992`, installed direct06 API
`472da578ff9066413f0a2b8e5c0053b5bc26eae8c3cb343b5b0cbb2a62c03a3a` and upstream
`018751270e800bc222a93dad7f257083ee53a5f7`. Phase52 measured 1.123799 times
TypeScript execution time on 45 points / 23 sources. That historical number is
context, not the denominator for a new paired campaign.

## 1. Diagnose and correct the NaN mismatch

The unchanged `f32_table_nan_bits.bend` oracle is 40. Pinned TypeScript returns
1 and direct06 returns 39 on the selected Node host. Matching the erroneous
reference value is not a fix. Keep source correctness and differential agreement
as separate results, including the reference failure.

First isolate cold and repeated per-index bit transport using the exact emitted
functions. The earliest diagnostic implicates the intermediate JavaScript array
in `new Float32Array([x])`. Test direct typed-array assignment as a general
replacement, with fresh per-call storage to avoid reentrancy hazards. Exercise
positive and negative NaN payloads, quiet/signaling inputs, zeros, infinities,
subnormals, finite values, evaluation count and cold/repeated calls. This initial
observation is a hypothesis until checked compiler output passes those controls.

Build one checked candidate containing only the correction and default routing.
Do not conflate its correctness evidence with subsequent optimization results.

## 2. Make direct output the ordinary interface

Unspecified JavaScript library/program compilation selects direct output. Keep
`--direct-js` as an explicit alias and add `--legacy-js` for the old contract.
Explicit API `backend: 'js'` and the bootstrap compiler host remain legacy;
explicit native targets remain native. Report the actual selected backend and
refuse unsupported input rather than falling back silently.

Audit the CLI, imported API, maintained test helpers, release smoke, relocation
and documentation for implicit default assumptions. Validate ordinary default
invocation, both explicit flags, option conflicts, library exports, program
execution and FFI without an upstream checkout. Preserve runtime integrity
verification and tamper rejection. Default promotion changes the emitted ABI;
document native callable/data layouts and the retained compatibility selector.

## 3. Test ordered expression lowering

Phase52 expanded intrinsics only for exact inert operands. Its attempted
parameter-IIFE generalization was 25.75% slower and remains rejected. Instead,
prototype statement prefixes plus one resulting expression. The expanded controls
exposed the pinned emitter's two-stage policy: emit child prefixes first, then
evaluate pending intrinsic actuals once. Follow that policy when expanding
primitive operations without allocating an extra function boundary. The
[evaluation-order refinement](ordered-prefix-evaluation-order.md) records the
counterexample and superseded unexecuted left-to-right prototype.

Start with intrinsic applications in contexts that already emit statements,
and propagate prefixes through unknown calls, constructors and expression lets.
Keep computation within its original branch, closure, lazy view and partial-call
scope. Preserve erased argument behavior, coercion/getter/throw order, loop
capture, demand metadata and emitted dependency discovery. Do not reorder effectful
operands or duplicate evaluation. Reuse existing leaf lowering only where its
semantics remain valid; never fall back where that would restore the exposed
ordering mismatch. Unsupported forms must refuse explicitly. No benchmark-name
rules.

An independent reviewer checks the transformation and dedicated witnesses before
building. The first numerical screen compares the corrected/default baseline
against the new checked compiler and the same pinned TypeScript artifacts. A
useful result is a measurable broad gain without a new source-oracle failure or
an unexplained material regression. A failed experiment remains recorded and is
reverted; correctness/default promotion does not depend on optimization success.

## 4. Qualification and measurement

Reuse maintained Phase52 methods and exact catalog/observer bytes where valid,
with new Phase53 adapters and fresh output directories. Never rewrite historical
evidence. Run the 96 independent semantic scenarios plus new discriminating
controls, maintained compatibility suites, the direct JS census and release
interface checks. Keep overlapping counts distinct.

Use the existing eight-point screen for quick rejection and the numeric screen
for attribution. Run the final 45-point / 669-sample rotated comparison only for
a surviving selected compiler. Compare against the archived Phase52 direct image
and unchanged pinned TypeScript; report equal-point and equal-source ratios,
every regression and timing flag. Keep module import/first call, compilation and
program execution separate. Preserve original source oracles when the reference
itself fails. Passing this corpus does not establish universal conformance.

## Work allocation and resource discipline

Independent agents own NaN diagnosis/runtime, semantic controls, default routing,
ordered lowering, measurement adapters and review. Root coordinates builds,
integration, documentation and publication. Source ownership is explicit; the
optimization stays in a proposed patch until the correction/default baseline
has been frozen. Use additional agents only for independent bounded questions.

Serialize heavyweight builds and benchmarks on CPU 3, with a 1 GiB Node heap,
2 GiB process-tree RSS ceiling and 4 GiB available-memory floor. Tiny diagnostic
jobs may use CPU 0 with tight time/heap bounds, outside clean timing. Do not run
compression during timed comparisons. Reuse checked source acquisitions when
identities are unchanged, and review whether each long validation resolves a
new uncertainty before launching it.

Record elapsed time separately from measured process occupancy. Checkpoint and
push meaningful milestones without waiting for the final campaign. Preserve all
103 inherited unrelated files and make no PR comments. Publish a concise report,
portable benchmark artifacts and one complete raw evidence archive rather than
duplicating every raw log into thousands of additional tracked files.
