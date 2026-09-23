# Phase 6 opening experiments: semantics and residual performance

The Phase 5 compiler is consolidated and usable through the ordinary CLI. These
opening Phase 6 experiments ran in the remaining part of the authorized six-hour
campaign, after source freeze, using isolated candidates. **No Phase 6 source
patch is installed in the default.** The current full-source measurement remains
**363.39 seconds versus 60.25 seconds for pinned TypeScript: 6.03× slower**.
See the [release report](../phase5/consolidated-release.md),
[controlled comparison](../phase5/full-source-comparison.md) and
[compiler guide](../../docs/BEND-IN-BEND.md).

## Results and decisions

| Investigation | Observed result | Decision |
| --- | --- | --- |
| [Optimized residual profile](optimized-residual-profile.md) | Trampoline 18.80%, GC 9.67%, String.eq 5.75%, non-Var substitution closure 3.36%, `kc` 3.35% of time-weighted exclusive samples on the core workload. | Use as a direction for experiments, not an additive gain forecast or timing comparison. |
| [Explicit Boolean workers](boolean-branches.md) | Two opposite-order pairs reduce request time 6.72% / 6.18% and process wall 6.30% / 5.79%; all four core-library outputs match exactly. | Small-workload pilot passes. Source promotion, H performance and whole-source gains remain unproven. |
| [Erased-name guard](semantic-gap-analysis.md) | In 28 focused observations, classification agreement rises 16→28 and exact agreement 6→20; no previously exact observation is lost. | Promising isolated parser repair; eight diagnostic residuals and broader gates remain. |
| [Marked-name temporary node](marked-name-analysis.md) | Selected phase repairs work, but `+f(1)` changes from correct parse rejection to check rejection. | Reject promotion. Repair prefix precedence before revisiting the fresh-variable representation. |
| [Missing-import boundary](import-phase-analysis.md) | Five pinned fixtures account for ten phase differences: declared import ENOENT becomes load instead of parse. | Read-only design; narrow tagging plus parser source spans and error-order controls are needed. No patch tested. |
| [Native record expansion](native-arity-wall.md) | The sole positive native timeout emits 3.7 MB C versus 81 KB from TS; scalar-field continuation bodies occupy 93.8% of Bend C. | Separate code-generation bottleneck. Probe scaling before an ownership-preserving scalar fast path. |

The positive Boolean result is deliberately narrow: two samples per variant,
one 60,909-byte core workload, a frozen checked control/candidate and matching
Base books. It does not change the 6.03× released-compiler ratio. The candidate
adds helper calls, and public H already has a different Boolean lowering path;
B1's gain cannot simply be assumed for H. Both the first failed source formulation
and the successful v2, all controls, preflight and timed outputs are preserved.

The erased-name and marked-name candidates start separately from final05. Their
results cannot be combined as if a merged source passed the same controls.
The marked-name counterexample also found that `+U32` already falsely passes
checking in the released source while pinned TS rejects it during parsing. That
witness is outside the pinned conformance inventory. “All check statuses agree”
is therefore a statement about that inventory, not a language-wide soundness
claim. The original mistaken `+value()` oracle and the retracted fresh-ID causal
explanation remain in the record with explicit corrections.

## Next work, with fast stopping criteria

1. Repair the prefix operand boundary with `+f(1)`, `(+f)(1)`, datatype, qualified,
   local and unbound-name controls before rebuilding a broad parser candidate.
   Keep the demonstrated erased-name repair separate until each passes its own
   valid-neighbor and first-error gates. Then run combined frontend comparison.
2. Address the five missing-import fixtures through a tagged declared-import
   failure, retaining file/span provenance. Root-file/API/Base I/O failures must
   remain load/infrastructure failures. Add the missing-import-plus-malformed-body
   witness before claiming the chosen first error matches TS.
3. Evaluate the successful Boolean candidate through the actual H path, then
   matched H timing and a larger checked workload. Promote only after independent
   controls, broad frontend/backend gates and final integration proof. Stop if
   direct helpers erase their own gain through call/argument overhead.
4. For a substantial reduction of the remaining compiler gap, measure repeated
   work across checking and annotation. Prototype reuse of exact typed facts
   behind an explicit validity contract; compare against the unchanged full
   checker on malformed and dependent terms. This is a conceptual change with
   more potential than another isolated equality helper, and a larger proof and
   regression burden. The [performance design](../../design/phase6/residual-performance.md)
   also describes identifier indexing and typed worker lowering.
5. For native output, first remove avoidable scalar-field continuation expansion
   while retaining evaluation order, affine ownership and error behavior. The
   [native design](../../design/phase6/native-code-size.md) defines emitted-size,
   compile-and-run and counterexample gates. Do not attribute this separate
   backend problem to the JS full-source compiler deficit.

The maintained rebuild/selected workflow is already short enough for focused
semantic work. Full self-reproduction remains an integration gate. Prefer one
bounded falsifier with exact output and recorded failures before a long benchmark;
use isolated source snapshots, fresh processes, opposite-order comparisons and
explicit resource deadlines. A sixfold speedup requires removing about 83.4% of
the current workload time, so the measured small-predicate improvement alone is
far from sufficient. Planning ranges in the design remain hypotheses.

## Evidence boundaries

Each linked report records actual source/API/host/runtime identities, failed
attempts, gate scope and durable evidence. The broad Phase 5 backend report
retains the native timeout and its C output. The optional public-H user-program
backend sweep was prepared but not launched; H's full frontend inventory and
checked self-reproduction do not substitute for that coverage. GPU execution was
not measured. Compiler speed, emitted code size, native toolchain time and
user-program runtime remain separate metrics.
