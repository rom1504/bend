# Phase148 — physically compact compiler units

Start at `a26719c`, Phase147's qualified ordinary serial native candidate.
The user authorizes the architectural experiment and relevant larger extensions.
Keep one canonical compiler implementation and the installed JS/C/QBE release.
The current matched cold benchmark is246.17s; actual edited-source acquisition
is255.53s. Historical1.5–3×/3–8× estimates are hypotheses, not results.

## Ambition and decision points

**1×: one complete multi-consumer unit.** Encode a real private native function
once into contiguous scalar arrays with numeric identities. Run scalar-fact
optimization and direct admission against that representation, decode once for
the unchanged independent final verifier/emitter. Include construction, lookup,
branch handling, conversion and destruction in native timing. Preserve exact
transformed bodies, errors and generated code against the original pipeline.
First target at least2× on the complete affected computation; a smaller result
must justify its complexity and scale. Any result may reject the hypothesis.

**10×: produce and consume compact units across the backend.** Carry identities
from lowering, share immutable schema while refreshing facts after transformations,
and keep units compact through several analyses and rendering. Retire replaced
walkers where independence does not require an oracle. Bound function lifetimes
instead of retaining whole-program temporary graphs. Add a compiler-local packed
name pool only if ordinary String metadata materially dominates. This targets
large cold-build gains across multiple stages, not10× promised performance.

**100×: a compiler built from reusable checked units.** Extend the successful
unit contract to stable owner identities, fact-sensitive dependencies, warm
semantic reuse, independent bounded worker scheduling and direct production of
compact data. Measure the work/critical-path/memory ceiling before parallel
execution. Reuse and parallel speedups are separate from cold single-core gains.
No shared-memory runtime, universal IR, new backend or search framework follows
merely from the ambition label.

Pieces of larger plans are appropriate now when they reduce this experiment's
work: separate identity from declaration state, explicit unit lifetimes, numeric
side tables, and an interface usable by more than one consumer. Avoid another
lookup-only benchmark or a representation converted back after each pass.

## Initial architecture and safety obligations

The selected initial boundary is post-inline `p113k_function` followed by
changed-function direct admission. Their original implementations are independent
oracles. Existing scalar facts include epochs, relation assumptions and predicate
provenance; dropping these changes optimization quality. Final verification alone
does not prove that an arithmetic rewrite is semantically equivalent.

The function unit has an immutable name dictionary and scalar instruction/value
arrays. Exact names survive for diagnostics and decoding. Schema membership and
assigned state are separate from IDs: optimized-away declarations must not remain
admitted merely because their dictionary IDs exist. Retain namespace, ordered
ready-prefix and context identities; no cross-request cache is introduced.

Native `Array<U32>` is contiguous but four-byte packing depends on a whole-program
capability. Ordinary compiler arrays may use eight-byte scalar Term cells. Report
actual storage and generated operations; an `Array<ADT>` is not packed IR. A cold
String dictionary may initially use ordinary array slots and is accounted for.
Native array indexes wrap and updates mutate shared backing storage. Bound all
used lengths and arithmetic; thread mutable arrays affinely, clone branch states
explicitly, and freeze shared instruction data before read-only consumers.

Branch flow preserves assignment on both paths, with equal capacities retained
and unequal capacities reduced to zero. One continuing arm supplies its flow;
yes errors precede no errors. Schema errors precede flow errors. Scalar joins
are a different lattice with epoch invalidation. Preserve source/parameter/result
limits, terminal behavior, fallback, runtime imports and exact errors.

## Efficient execution and gates

One root-owned CPU3 resource-intensive lane; bounded agents own independent
representation, consumer, fixture and audit tasks. Every target uses the current
disk guard with fresh roots,5GiB reserve, explicit disk/time/RSS limits and16GiB
available-memory floor. No agent independently starts a compiler campaign.

1. Reuse authenticated real Map/compiler/Lexer captures and original consumers.
   Write checked encode/decode controls and a layout/array-operation probe first.
2. Small hosted APIs establish full semantic equality, including failures and
   mutated dependencies. Preserve rejected source/harness attempts.
3. One native executable contains old/new runtime-selected modes. Charge complete
   preparation→both consumers→decode/render→cleanup. Use alternating pairs,
   complete result/text oracles, actual memory/layout evidence and source IDs.
4. Use the maintained native profiler on a sufficiently long selected workload,
   with fresh symbol maps and strict loss/coverage gates. Compare physical runtime
   operations to active Bend owners; do not add overlapping shares.
5. Expand to an unrelated held-out function family only after the first useful
   result. Stop or redesign if array transport, branch copies, dictionary cost or
   lost direct-worker admission erase the gain.
6. Integrate only a justified coherent boundary. Independently check full source,
   run small complete requests and a same-source cold build. Exact generated QBE
   permits reusing program-speed evidence. Changed products require fresh relevant
   program runtime checks. Full N1/N2/Q3 and focused/broad gates are reserved for
   a candidate worth adopting, not each experiment.

Useful laws: exact encode/decode roundtrip; numeric identity distinctness; state
join membership/capacity; optimized decoding equals the original scalar pass;
and admission observations commute with encoding. Executable differential laws,
source checking and a BendTT theorem remain distinct. Prove a narrow pure rule
only if it supports the actual implementation; never call finite tests a proof.

Record predictions and actual costs in a per-hypothesis ledger. Keep completed
methods/evidence compact, classify guards at close, retain qualified images, and
archive/verify cold artifacts before optional pruning. Commit the design first,
then useful experiment/code milestones and an honest final report.
