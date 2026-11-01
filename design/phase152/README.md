# Phase152 — preserve prepared constants across composition

Starting point: `0bdc7f0`, qualified serial native compiler Phase147. Phase151
demonstrated a causal local performance loss: bounded selector expansion
recreates nullary Unit constructor/sink calls after static preparation. Removing
those calls in two frozen workers recovers execution speed. That diagnostic
patcher is not a compiler optimization.

## Experiment and decision

Implement one general, checked capability in Bend: retain authenticated prepared
nullary constants through bounded selector expansion and propagate their
nonowning representation. Preserve original source admission, bounded expansion,
constructor identity/arity, ordinary versus special representation, foreign/effect
refusals, freshness, ordered actual evaluation and the independent final verifier.
Unknown or mismatched facts fall back. Do not globally replace the original-body
view used by other analyses. No function-name or benchmark-name recognizers.

First use an experimental declaration overlay and a checked hosted compiler API.
Source assembly/IO and machine construction reuse maintained tooling. No new
host-language compiler algorithm. One coordinator owns the serial CPU3 target
lane; bounded agents implement, audit semantics and identify the cheapest valid
workflow independently.

1. **Admission gate:** independent source check, existing selector controls and
   new image/constructor/refusal/ownership controls. These are finite controls,
   not a theorem of compiler correctness. Protected proof/verifier declarations
   remain unchanged.
2. **Causal gate:** compile the unchanged Phase151 witness with baseline and
   candidate; inspect the consumed workers and execute independent outputs.
   Require actual constructor and sink removal, not merely a changed plan.
   Measure clean paired runtime and compiler-request cost.
3. **Transfer gate:** unchanged safe compiler usage-summary workload and unrelated
   valid selector/owned-value workloads. Test scalar lexer integration if the
   constant capability removes its established barrier. Preserve negative results
   and distinguish component speed from full compiler throughput.
4. **Integration gate:** only after useful transfer, integrate in the one module
   tree, refresh explicit inventory and independently check. Run relevant focused
   JS/C/QBE gates. Budget native acquisition/self-reproduction separately; do not
   change installed or qualified selection on small-program evidence alone.

## Ambition levels

- **1× scope:** recover prepared nullary facts without broadening selector legality;
  establish runtime and compilation cost on real consumers.
- **10× scope:** compose this with the measured compact scalar dispatch/lexer
  candidates, enabling cheaper compiler code generation without making the
  resulting compiler slower. Use actual compiler workloads to select integration.
- **100× scope:** identify a reusable boundary for authenticated immutable facts
  across calls and continuations, eliminating repeated representation work. Only
  implement a broader change if the narrow experiment identifies a measured
  general opportunity. These labels describe scope, not promised speedups.

## Cost and evidence

Use fresh artifact paths and maintained guards with explicit disk budgets,
ordinary 2GiB RSS, 16GiB available memory floor and 5GiB disk reserve. A larger
checked compiler API may require an explicitly measured modest RSS increase;
record that before execution. Avoid giant embedded fixture strings and repeated
full-image builds. Keep original independent output oracles, source/runtime/image
identities, complete request clocks, machine-build clocks and runtime clocks
separate. Close completed and rejected jobs through retention.

Report what work disappeared, transfer/nontransfer, source growth, compiler cost,
qualification status and the strongest next experiment. Do not infer whole-build
speedups or recursive acceleration from microbenchmarks. Commit/push design and
validated results; no PR comments.
