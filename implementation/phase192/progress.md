# Phase192 integration decision, in progress

The current experiment has found a broader capability gap than the initial
machine peepholes: x86 ignored the existing checked P114H recursive-region
plans consumed by QBE. A 206-line structured consumer reuses those plans,
canonical renaming, runtime frames and existing local-loop machine lowering.
It adds no new recursive-region recognizer and no recursive native call.

Development evidence before held-out selection: numeric conversions remove a
generic runtime call and scratch staging (numeric256 runtime0.5143 ofPhase191).
H regions reduce tree-bitonic/expression32/lexer runtime to0.6769/0.4302/0.5240
ofPhase191 in the first four-role balanced screen. Lexer dispersion is retained.
These are three development cases, not a full-suite result.

Six ordinary-source controls now pass both direct ELF and assembly execution,
including actual H refusals at an indirect-call boundary. Independent C state
controls cover84 cases per route through recursion depth100001, zero-depth
caller protection, registers, stack state and external continuation guards.
These are finite tests and structural admission, not an equivalence theorem.

An additional scoped-frame experiment reuses canonical frame expansion inside
renamed continuation cases. The empty-scope/default-off traversal reproduces
all three original H objects byte-identically. Independent review found that
exact allocation-size checks alone did not reject an additional same-name
allocation; newv2 requires exactly one definition across parameters and nested
setup/body. Original experimental files and failures remain immutable.

Deferred unless independently profitable: broad SSA rewrite, path-fact table,
and floating-region widening. The latter still encounters mixed integer/F32
definitions of the same local. Introducing these now would add complexity
without measured broad benefit. The smallest missing abstraction demonstrated
so far is a shared consumer of an already verified continuation region.

Resource findings: first multi-case source harness retained compiler IR while
running child binaries and reached the2GiB guard. A scoped lifetime plus explicit
host collection reduced subsequent peak tree RSS to383MiB without raising that
limit. A premature second target job was refused by the shared execution lock;
no overlapping target job ran. Preserve that pre-admission log separately:
no process/retention receipt was created, so it cannot be closed as a normal run.

Production qualification is pending. Installed Phase189 and qualified Phase191
remain intact. Final report will supersede this progress note with exact source,
full-suite results, native self-reproduction and compilation-cost measurements.
