# P151-002 — retain an immediate value through selector expansion

Status: demonstrated fixed-artifact opportunity; no generic compiler promotion.

Phase151's scalar tables halve local compiler emission cost, but lazy chooser
expansion leaves constructor/sink calls for ignored Unit arguments. The generated
terms are immediate packed words, not heap allocations. Phase131 already noted
the same lost preparation fact; this experiment supplies causal machine evidence.

A checked Bend tool authenticates two exact consumed selector bodies, replaces
42 zero-arity constructor calls and their 42 matching sinks, and preserves every
other QBE byte. Fixed source, input, runtime and toolchain remain unchanged.
514 exact input-pair controls, independent expected tables/comparator controls,
loop observations and three artifact-refusal controls pass.

Two alternating pairs per mode on 20 million queries: scalar roles1.3135→0.685s;
scalar opcode names2.195→1.560s. Original table paths remain near0.69/1.56s.
The counterfactual recovers parity locally; it does not implement an automatic
optimization, prove general equivalence, or establish a whole-compiler gain.

Next: preserve an authenticated prepared nullary value through bounded inlining,
including ownership/nonowning facts, then test its transfer and compiler cost.
Do not copy the frozen-text patcher into production or add benchmark recognizers.

[Report](../../implementation/phase151/README.md) ·
[Machine audit](../../research/phase151/runtime-regression.md).
