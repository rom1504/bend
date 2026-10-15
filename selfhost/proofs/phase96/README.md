# Compiler laws and production constraints

Phase96 has **31 public universal laws and 7 supporting lemmas** accepted by
source checking, safe elaboration and the independent, unchanged BendTT kernel.
These are 38 proof bodies, not 38 public compiler contracts. Production helpers
are extracted or imported explicitly; the remaining adapter boundaries are
documented rather than assumed.

| Package | Public laws | Supporting lemmas | Status |
| --- | ---: | ---: | --- |
| [Representation](representation/README.md) | 17 | 0 | Exact compiler term helper bodies; independent proof acceptance; eight well-formed helper mutants rejected by frozen laws. |
| [Algebra](algebra/README.md) | 14 | 7 | Actual Base list operations and exact unpromoted Phase94 environment helper; independent proof acceptance; eight negative cases rejected. |
| [Production controls](production/README.md) | Not universal proofs | Not counted | 226 finite full-value JS cases pass; 32 generated-C witnesses pass; all ten semantic mutants detected. |

The representation laws cover updates, metadata, constructor-specific
observations and source spans. The algebra laws preserve ordered lists,
arbitrary accumulators, filtering and comparator-defined membership. Singleton
and one-step semantic anchors exclude constant observers that could satisfy
weaker algebraic laws. Neither package replaces full compiler behavior with a
parallel illustrative implementation.

Accepted proof evidence is retained in
[representation-check03](../../build/phase96/representation-check03/report.json)
and [algebra-all03](../../build/phase96/algebra-all03/report.json). Each includes
a frozen source closure, safe elaboration, nonopaque law inventory, independent
kernel acceptance and rejection of the retained false-equality kernel control.
Generic template parameters may be opaque; actual helper and theorem bodies
are checked, not introduced as axioms.

Mutation evidence is separate. The
[representation campaign](../../build/phase96/representation-negative-check01/report.json)
admits all eight altered helpers alone and then rejects their frozen laws.
The [algebra campaign](../../build/phase96/algebra-negative-check01/report.json)
rejects four false statements, two altered environment helpers and two constant
observers; its three law-free helper checks pass first. These sixteen negative
cases are frontend rejection controls. They are not counted as successful laws
or independent kernel mutation checks.

The proof method follows the upstream practice of connecting exact optimized
operations to complete reference results, including arbitrary payloads and
accumulators. See the [upstream proof-method study](../../../research/phase96/upstream-proof-method.md)
and [Phase94's original boundary](../phase94/README.md). The Phase94 environment
optimization remains unpromoted. This catalog makes no compiler-speed claim,
whole-compiler correctness claim, or new production promotion.

The production suite has an independent finite-value oracle and exercises the
maintained unsafe compiler helpers through the actual B2 path. It can find
counterexamples across the documented adapter boundary; it cannot turn finite
agreement into a universal theorem. Its results and runner instructions belong
in the [implementation report](../../../implementation/phase96/README.md) and
[replay guide](../../../docs/self_hosted/COMPILER_LAWS.md). The integrated
`audit01` run repeats all positive and negative checks in about91 seconds.
