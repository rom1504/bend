# Phase42: faster generated programs — final qualification in progress

The selected compiler is **checked16**, API
`63ddb2dd35554aafafc26dbdff4aba86b5d3774cd0d99a9509ccf237d210ba54`.
Phase41 remains installed until the fresh final semantic, performance, compiler
cost and installation gates pass. The upstream pin remains
`018751270e800bc222a93dad7f257083ee53a5f7`. No PR comment has been posted.

The [comprehensive roadmap](../../design/phase42/README.md) was committed before
implementation. Seven agents investigate and review independent mechanisms;
root serializes compilation, timing and profiling under explicit memory limits.
[Iteration efficiency](iteration-efficiency.md) records what helped and what
slowed the campaign. Source checkpoints are pushed throughout.

Selected changes remove repeated private dispatch, flatten completely owned tree
graphs, use bounded native recursion with iterative deep fallback, fuse total list
pipelines, admit proven native List/tuple components, simplify owned constructors,
and reuse exact request-local planning facts. [Mechanisms and decisions](mechanisms-and-decisions.md)
explains the proof domains, causal experiments and rejected alternatives.

Short screens show tree execution approaching TypeScript on larger inputs and
larger fused-list pipelines running faster than TypeScript. BST execution improves
substantially, but still has a material gap. These are scoped screens with explicit
adjacent-image denominators, not final 45-point results or universal parity.
[Checkpoint06](checkpoint06.md) contains the last BST comparison and
[checkpoint05](checkpoint05.md) the bounded-tree experiment.

The inherited counter preflight caught a real quantity-2 vector admission
regression. The five-line checked16 repair restores the established comparison
policy while preserving strict native-container proofs. The unchanged counter
controller passes 35 value oracles, five mutation boundaries and all activation/
refusal requirements; native proof passes all 43 observations.
[Checkpoint07](checkpoint07.md) and [integration corrections](integration-corrections.md)
retain the failure and repair. Fresh checked16 tree output is byte-identical to
checked15, and its inherited full-value and deep controls pass.

[Complexity](complexity.md): 20,056 compiler lines across 70 modules, an increase
of 1,158 lines and 141 definitions. Types and laws are unchanged. The runtime adds
three lines. This is not source simplification. Final four-case compilation cost
and full45 runtime measurements remain pending and will be reported separately.

Use the [portable performance guide](../../selfhost/tools/performance/phase42/README.md)
for 20/60/300-second selections and three serial 600-second full-catalog batches.
Profiling and generated-JavaScript comparison run separately from clean timings.
The current-bundle publication and installed release remain pending.
