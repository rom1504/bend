# Phase151 — test the cost of literal dispatch

Start: `b020b57`, qualified producer Phase147 N2. Production source and installed
selection remain unchanged until evidence supports a separate integration gate.

Phase150 found that character patterns inflated intermediate terms and added
about 22 seconds to a parser component's acquisition. Scalar comparisons removed
that penalty. The next question is whether existing numeric dispatches have the
same avoidable cost, without trading away execution speed.

## Hypothesis and experiment

Start with `p88_roles`: twelve U32 cases returning exact role lists. Transfer to
`p112fp_binary`: ten U32 cases returning QBE operation strings. Both have fixed
result types and explicit fallbacks. Do not rewrite dependent matches, protected
proof helpers, or the already optimized Phase147 string classifiers.

1. Freeze the actual maintained declarations, a scalar-predicate alternative,
   and a Bend probe. Compare all small inputs, high-bit and wrap boundaries, all
   list fields/string bytes, and independent expected tables. Source-check using
   the pinned independent upstream checker.
2. Build matched native programs through qualified Phase147 N2. Measure fresh
   compiler emission and machine construction separately, retaining every build.
   Compare alternating execution runs with identical observable work. Reject a
   candidate that merely moves material cost from acquisition into execution.
3. If the local effect is credible, compare a complete real consumer: prepared
   Base decoding for roles, or float instruction emission for binary names.
   Include input conversion, output observation and destruction in the clock.
4. Use existing authenticated profiler assets or a checked term census only
   when needed to distinguish expansion from optimizer or layout effects.
   Counts alone do not establish dynamic hotness or a whole-build gain.
5. Integrate a small surviving source change only with relevant exact consumer
   outputs and independent checking. A full compiler build/self-reproduction
   campaign needs evidence that the gain justifies its cost. Do not treat a
   component result as a measured whole-compiler speedup.

The normal ambition is an economical, semantics-preserving source change. The
larger ambition is evidence for compact U32 discrimination through elaboration,
retaining the same refinements, quantities, evaluation order and diagnostics.
The far-reaching possibility is reusable compact semantic facts across frontend
walks. Neither larger direction licenses a speculative IR rewrite in this phase.

## Budget and gates

Root owns one CPU3 measurement lane; two bounded agents implement controls and
independently audit the opportunity. All target commands use the maintained disk
guard, 5 GiB reserve, 16 GiB available-memory floor, 2 GiB tree RSS and fresh roots.
Prefer seconds-long component gates; no concurrent target timing. New probe and
compiler logic is Bend; reuse existing host acquisition and supervision tools.

Keep exact source, producer, Base, runtime and tool identities; record cold fresh
processes versus reused OS caches. Two alternating pairs screen effects, not a
statistical confidence claim. Separate compiler speed, complete acquisition,
generated-code speed and total investigation cost. Preserve negatives and close
all guards with verified retention. Commit the design and completed evidence.

Stop or redirect after a decisive negative result. A source inventory is not a
forecast that the remaining 258-second cold build can reach 100 seconds.

## Evidence-driven extension

The compact scalar spelling halved local emission time but regressed execution.
Machine inspection identified repeated immediate Unit construction/sink calls
introduced by chooser expansion. A balanced no-thunk spelling restored execution
but grew source and QBE substantially. Before a generic compiler change, run a
frozen-artifact counterfactual in Bend: authenticate two consumed selector bodies,
replace only their known Unit call pairs, retain all other QBE bytes, rebuild,
run exact controls and alternate original/patched executions. This is a causal
experiment, not an admitted compiler transformation or production qualification.

The complete decoder gate is deferred when neither source spelling gives a
sufficient overall tradeoff; building it cannot establish a missing general rule.
Preserve the prepared decoder driver as unexecuted evidence. The final report
must distinguish the source-compilation win from the separate generated-code
counterfactual, including the still-unmeasured cost of an automatic transformation.
