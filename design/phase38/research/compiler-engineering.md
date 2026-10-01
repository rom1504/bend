# Compiler engineering: cheap falsification and semantic boundaries

Research date: 2026-10-01. This is a research/design note, not a new experiment.
Sources include papers, project documentation and inspected implementation files.
Paper versions and implementation pins are distinguished below; mutable repository
links were read on this date and do not imply a reproducible commit snapshot.

The objective is to obtain faster correct programs with a short developer loop.
Compiler-request latency, generated execution, validation cost and source
complexity are separate measurements. The [Phase37 baseline](../../../implementation/phase37/README.md)
already demonstrates why: some programs improve substantially while compilation,
code size and several unrelated execution points become worse.

## Souper: search offline, then retain a small rule

*Souper: A Synthesizing Superoptimizer*, arXiv **1711.04422v2 (2018-04-06)**,
extracts integer dataflow and path facts, searches for cheaper replacements and
uses SMT reasoning to validate candidates. Correlated merge choices matter;
unsupported memory, calls and other operations bound what its model can prove.
These limits are part of the method, not an excuse to assume whole-program purity.
[Versioned paper](https://arxiv.org/abs/1711.04422v2).

The inspected [enumerative synthesizer](https://github.com/google/souper/blob/main/lib/Infer/EnumerativeSynthesis.cpp)
prunes candidates by operand width, operation suitability and cost before deeper
search. Its search is structured, not an invitation to enumerate every possible
program in our compiler's normal path. The repository is archived; the proposal
is to borrow a method, not depend on it as a maintained Bend optimization service.

For Bend, mine a small batch of repeated integer expressions from generated JS,
model their **Bend** U32 semantics, search offline, and retain only a simple typed
rule that removes work V8 actually leaves. The final compiler would use that
bounded rule without invoking an SMT solver or a synthesis service.

A concrete example is simplifying masked arithmetic under a proved range. First
bind source operands in their required order, then reason over inert numeric
values. Replacing `effectful() * 0` with zero may erase an effect even if the
numeric identity is valid. JS signed bitwise coercion also differs from the
unsigned result convention; the emitted boundary must restore the right value.

Expect modest returns from arithmetic peepholes unless profiling shows otherwise.
Our largest gaps involve descriptors, matching, forcing and allocations, and V8
already has an optimizing arithmetic backend. A clever bitvector identity is not
evidence that generic call overhead has been removed.

## Alive2: validate a transformation within an explicit model

*Alive2: Bounded Translation Validation for LLVM* (PLDI 2021) checks refinement
between LLVM functions while modeling LLVM undefined behavior. Loop bounds and
resource limits bound coverage; it does not prove arbitrary source-language or
backend equivalence. [Primary paper](https://users.cs.utah.edu/~regehr/alive2-pldi21.pdf).

The inspected [comparison implementation](https://github.com/AliveToolkit/alive2/blob/master/llvm_util/compare.cpp)
distinguishes correct, unsound, failed-to-prove, syntax and type/error outcomes.
The [function implementation](https://github.com/AliveToolkit/alive2/blob/master/ir/function.cpp)
explicitly clones bounded loop iterations and repairs control/dataflow edges.
Its [project documentation](https://github.com/AliveToolkit/alive2/blob/master/README.md)
also warns about unsupported interprocedural transformations. Unknown or out of
scope cannot be reported as a successful validation.

The transferable experiment is a tiny checker for our private emission plan,
not “run Alive2 on JavaScript.” Start with acyclic U32/Bool operations, typed
constructors and explicit demand/effect tokens. Compare old/new plans on bounded
inputs and, if useful, an SMT model for the numeric subset. Keep the JS lowering
and public wrapper covered by actual emitted-code tests.

There are two separate claims: the rewrite preserves the plan semantics, and
both emitters implement that semantics. Proving the first does not discharge
the second. A wrong abstraction that calls getter reads pure can validate a wrong
rewrite perfectly. Initially the checker should reject callbacks, mutation,
recursive calls and unsupported arithmetic rather than silently model them away.

## Observable results need more than a checksum

CompCert's documented preservation theorem relates checked/elaborated source
syntax to assembly syntax, with explicit observation and trusted-boundary scope.
Execution time and memory consumption are outside its observable behavior model.
This is a useful reminder that semantic evidence and performance evidence answer
different questions. [CompCert's specification](https://compcert.org/man/manual001.html).

Our JavaScript ABI needs its own observations: callback sequence, errors, demand,
alias identity, externally visible mutation and termination/stack behavior where
the interface promises it. We cannot import C or LLVM undefined-behavior freedom
to erase a Bend error callback or a mutable native descriptor read.

Phase37's initial cast experiment matched numerical output while failing **18
of 22** adversarial DataView observations. A shared private conversion needed
guards for the effective native behavior, not merely the same numeric formula.
This is direct local evidence that checksum-only testing can accept a wrong
optimization. [Cast investigation](../../../implementation/phase37/optimizer/native-cast-prototype.md),
[final owner evidence](../../../implementation/phase37/optimizer/final-scope-owner-report.md).

An optimization test should therefore have two products: a concise answer oracle
for frequent screening, and a small effect/alias/error trace oracle for admission.
Use TypeScript differential checks where independent answers are unavailable,
but label their shared assumptions. Agreement between two compilers is not an
independent proof of the language or of all host interactions.

## Negative lessons that should shape the next experiment

| Failure pattern | Local or researched evidence | Constraint on a Bend experiment |
| --- | --- | --- |
| More optimization machinery makes code slower | Phase37 opened 1,968 tiny scopes and slowed active ray 35.6% | Count dynamic guards and useful entries; retain unchanged and boundary-only variants |
| More sophisticated extraction need not help | Cranelift's maintainer reports unsuccessful cost-model refinements | Require a measured failure of the simple model before replacing it |
| A compact formula is not a complete semantic model | Initial cast checksums hid lost host callbacks | Model observations and validate the actual emitted entry |
| Solver success is only as broad as its translation | Alive2 and Souper have explicit modeled subsets | Unsupported/unknown outcomes remain distinct from pass |
| A cache can preserve old errors | Souper's documented external cache has no versioning | Bind semantic version, options and all input identities; reject stale results |

Sources for external rows: [Cranelift engineering account](https://cfallin.org/blog/2026/04/09/aegraph/),
[Souper cache documentation](https://github.com/google/souper/blob/main/README.md).
Local guard evidence is in the [ray report](../../../implementation/phase37/optimizer/ray-regression.md).
These sources motivate constraints; they supply no Bend speedup measurements.

## A short, falsifiable optimization loop

1. Name one hot mechanism and its measured evidence. Separate sampled CPU,
   sampled allocation, live heap, dynamic entry counts and source-size counts.
2. Capture a frozen baseline and derive exactly one saved-output change. Keep
   the unchanged copy, a boundary-only control and original input work.
3. Run semantic counterexamples first, then a 20-second execution selection.
   Use 60 seconds for another size, another shape and an unrelated canary.
4. If the mechanism survives, implement one general compiler rule, build checked
   B1, and acquire relevant sources once. Reuse those modules for execution.
5. Use 300/600-second selections for paired rounds and compiler cost separately.
   Freeze before new holdout measurements and full semantic/release gates.

These are prospective uses of the maintained
[benchmark interface](../../../selfhost/tools/performance/phase37/README.md).
Phase37's full 45-point execution inventory took **1,056.320 seconds across four
runs**; that is an acceptance cost, not the required duration of every edit.
Build, checked source emission, correctness controls and profiles remain outside
the execution timer. A 20-second limit does not turn cold code into steady state.

For a cost occupying fraction `p` of runtime, even completely removing it bounds
speedup by `1 / (1 - p)`: eliminating 70% gives at most 3.33×. Inclusive profile
ancestry and allocation shares are not automatically `p`, and overlapping savings
cannot be added. Use ablations to establish causation before making projections.

## Proposed experiments and estimates

These are planning ranges, not measured promises. They do not add together.

| Proposal | Potential value | Effort / first discriminator | Stop condition |
| --- | --- | --- | --- |
| Offline typed integer rule mining | 0–10% execution improvement on affected numeric paths; likely zero on dispatch-heavy paths | Medium, 1–3 days; one rule/model and real V8 comparison in about 4 hours | V8 already does it, semantic adapter exceeds the rule, or compile cost outweighs measured use |
| Small private-plan translation checker | No direct runtime gain; stronger localized failure evidence | Medium/high, 3–7 days for a narrow subset; first acyclic pair in one day | Unsupported cases are silently approximated, or modeling effort exceeds two concrete rewrite families |
| Reusable adversarial case generator | Earlier failures and wider semantic coverage; no defensible universal multiplier | Medium, 1–2 days; generate tiny typed cases and run a 60-second selected gate | Cases only mirror the emitter or never exercise intended private entries |
| Guard/branch cost ablation | Possibly recover 0–5% on affected regressions; larger benefit unestablished | Low/medium, half-day discriminator and 1–3 days integration | Improvement requires omitting correctness checks, shrunk work or discarded slower rounds |

A solver prototype should have a hard per-query deadline, node limit and explicit
unknown result; a proposed starting point is 1–5 seconds and small acyclic plans.
These are experiment settings to freeze, not validated production thresholds.
No SMT dependency should enter ordinary Bend compilation on this evidence alone.

## Simplicity and conformance accounting

Count production modules, definitions, proof concepts, mutable contracts and
fallback boundaries as well as physical lines. Keep research tooling separate.
A declarative rule language can shorten rules while adding a generator, runtime,
debugger and semantic adapter; include those costs in the review.

Prefer a shared admission contract that deletes repeated reasoning over another
independent special-case optimizer. Preserve both successful and failed examples
as reusable regression inputs. The former Phase37 holdouts are now exposed;
new tuning requires newly frozen holdouts, not another claim of unseen coverage.

Conformance improvement is not guaranteed by faster code. An observation generator
may expose more failures before fixes reduce them; report that honestly. The
success criterion is a general transformation with smaller measured cost and
unchanged relevant observations, followed by its scoped integration gates.
