# Rapid compiler performance experiments

The phase 1 self-emitted compiler remains 43–46 times slower than pinned
upstream on the measured uncached Base workloads. A checked self-emission takes
39 minutes. That proof is a milestone gate, not an appropriate experiment loop.

## Evidence and hypotheses

On tree/IO, the original TypeScript compiler takes 0.396 seconds, the Bend
compiler emitted by upstream 7.466 seconds, and the same Bend compiler emitted
by itself 17.873 seconds (seven-run compilation medians). The approximately
19-fold first gap includes implementation and representation differences; the
additional 2.4-fold gap isolates the choice of backend more closely. Neither is
an attribution of individual causes.

The final exploratory profile assigns 48% of CPU samples to generic application,
forcing, calls and global lookup, and 3.6% to GC. The name index traverses up to
32 binary levels through general compiler records; book updates also filter a
declaration list. The lexer repeatedly matches string heads/tails. These are
specific hypotheses to test, not promised independent speedup multipliers.

## Experiment loop

1. Freeze the existing compiler, runtime, host and inputs. Prototype in copies
   of emitted JavaScript under a separate build directory. Do not mutate an
   artifact used by an ongoing benchmark or conformance run.
2. Test direct calls to hot known functions and a compact name index separately,
   then together. An experimental JavaScript Map may estimate the value of an
   index redesign; it is not the proposed production implementation. Preserve
   first-match lookup, persistent old versions and source declaration order.
3. Use actual compiler operations with representative inputs and multiple sizes.
   Construct inputs outside timed regions. Compare complete outputs or stable
   structural digests against the frozen control, including missing names,
   duplicate definitions, updates, and retained old versions.
4. For promising experiments, compile one small representative program end to
   end, including checking and output execution. Alternate control/candidate in
   fresh processes on the same CPU; start with three repetitions. Record both
   cold invocation and warmed microbenchmark behavior rather than confusing them.
5. If necessary, separately prototype cursor-based scanning and prepared-Base
   reuse. Compare tokens including positions/errors; cache experiments must keep
   cache policies explicit and must not be reported as uncached speedups.

Target 2–5 minutes for a hypothesis iteration. This is a workflow budget, not a
guaranteed build time. Keep correctness failures and negative results. Use an
isolated CPU when available; if resource contention forces exploratory timings,
label them and rerun decisive comparisons under the controlled protocol.

## Implementing a winner

Move successful algorithm changes into Bend and build with the pinned upstream
compiler. Its measured compilation of the archived compiler source took about
49 seconds; a new bootstrap must be timed independently. Backend changes first
compile small programs covering known calls, partial/oversaturated application,
effects, closures, erased slots and tail recursion. Retain the generic ABI where
the optimizer cannot prove the direct path valid. Argument-vector ownership and
intermediate evaluation order remain semantic requirements.

Only after focused differential checks and an end-to-end improvement should a
candidate incur full self-emission. Complete fixed-point and corpus verification
remain required for promotion, but do not block independent hypothesis work on
disposable artifacts. A frozen older run provides evidence for that artifact
only. No checker stage or corpus deadline is weakened to improve a measurement.

## Reporting and versioning

Commit this design before experiments. Record each hypothesis, exact changes,
artifact hashes, commands, output equivalence, timings, limitations and decision
in a new [implementation report](../../implementation/phase1/rapid_performance_experiments.md).
Commit and push coherent experiment milestones to `selfhost/bootstrap`, keeping
raw compact results and reproducible experiment tools. Record prototype results
separately from supported compiler changes and full validation evidence.

Independent agents may investigate bounded experiments. They use separate files
and coordinate CPU measurements; only the primary agent commits and pushes.
