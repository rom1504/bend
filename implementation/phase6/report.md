# Phase 6 opening experiments: semantics and residual performance

Status: all bounded compiler experiments closed; evidence and outcome review complete.

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
| [Native record expansion](native-arity-wall.md) | The sole positive native timeout emits 3.7 MB C versus 81 KB from TS; fresh checked 32/64/128-field emissions show near-quadratic continuation growth. | Mechanism corroborated; no optimization, Clang speedup or runtime improvement measured. |

The positive Boolean result is deliberately narrow: two samples per variant,
one 60,909-byte core workload, a frozen checked control/candidate and matching
Base books. It does not change the 6.03× released-compiler ratio. The candidate
adds helper calls, and public H already has a different Boolean lowering path;
B1's gain cannot simply be assumed for H. A disposable actual-H capsule subsequently
passed exact checked core emission. Its separate positional malformed-data graph
gate failed after 430 completed controls: H returns partial runtime functions
where the inherited B1 oracle expected a comparable error. Even baseline H versus
itself fails that identity comparison. The original failure and differing returned
function code remain preserved; malformed-data equivalence is unresolved. This
is not an H speed measurement or a new whole-compiler proof.

Both the first failed source formulation
and the successful v2, all controls, preflight and timed outputs are preserved.

The erased-name and marked-name candidates start separately from final05. Their
results cannot be combined as if a merged source passed the same controls.
The marked-name counterexample also found that `+U32` already falsely passes
checking in the released source while pinned TS rejects it during parsing. That
witness is outside the pinned conformance inventory. “All check statuses agree”
is therefore a statement about that inventory, not a language-wide soundness
claim. The original mistaken `+value()` oracle and the retracted fresh-ID causal
explanation remain in the record with explicit corrections.

The native emit-only probe completed all three checked cases at 03:21:14 UTC.
For 32/64/128 fields, total C size is 217,752 / 396,504 / 1,075,095 bytes; literal
continuation bodies are 62,299 / 230,651 / 888,091 bytes. The retained 255-field
anchor has 3,486,765 such bytes. That repeated-prefix region nearly quadruples
when fields double. No Clang or user-program execution ran in this probe, so it
corroborates the code-size mechanism without establishing a native speedup.

## Next work, with fast stopping criteria

1. Repair the prefix operand boundary with `+f(1)`, `(+f)(1)`, datatype, qualified,
   local and unbound-name controls before rebuilding a broad parser candidate.
   Keep the demonstrated erased-name repair separate until each passes its own
   valid-neighbor and first-error gates. Then run combined frontend comparison.
2. Address the five missing-import fixtures through a tagged declared-import
   failure, retaining file/span provenance. Root-file/API/Base I/O failures must
   remain load/infrastructure failures. Add the missing-import-plus-malformed-body
   witness before claiming the chosen first error matches TS.
3. Resolve the Boolean candidate's incomplete H graph contract using the actual
   positional ABI and typed/unsupported-data boundaries. Its actual-H checked
   core-emission subgate already passes. Then run matched H timing and a larger
   checked workload. Promote only after independent
   controls, broad frontend/backend gates and final integration proof. Stop if
   direct helpers erase their own gain through call/argument overhead.
4. For a substantial reduction of the remaining compiler gap, measure repeated
   work across checking and annotation. Prototype reuse of exact typed facts
   behind an explicit validity contract; compare against the unchanged full
   checker on malformed and dependent terms. This is a conceptual change with
   more potential than another isolated equality helper, and a larger proof and
   regression burden. The [performance design](../../design/phase6/residual-performance.md)
   also describes identifier indexing and typed worker lowering.
5. For native output, the completed scaling falsifier supports removing avoidable
   scalar-field continuation expansion
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
