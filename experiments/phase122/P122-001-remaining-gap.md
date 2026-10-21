# P122-001: profile the remaining native runtime deficit

Status: diagnostic complete; no optimizer change or promotion. See
[design](../../design/phase122/remaining-gap-profiles.md) and
[report](../../implementation/phase122/README.md).

Hypothesis: the40 still-slow timed points share representation, ownership or
control-boundary costs that larger semantic transformations can eliminate.
Competing explanation: numerical code mainly needs optimizations absent from
QBE, while structural programs need separate mechanisms. Existing C products
help distinguish these explanations but do not isolate backend vintage.

Use authenticated unchanged programs, fresh clean timings, physical-PC profiles,
generated-code inspection and original full-output oracles. No optimizer changes
in this investigation. Record weak/negative evidence and avoid treating helper
sample percentages as achievable speedups.

Result:90 clean observations and60 usable zero-loss physical-PC captures pass
150 full-output/count checks;33,274 samples. Fresh QBE/upstream ranges2.12–8.47×
on these ten difficult cases. Mature C approaches upstream on lexer/BST/scalar/
editdist, and beats it on map/records. Compiler vintages differ, so this does not
isolate QBE's machine optimizer. It does demonstrate useful representation/code
quality available to our existing source implementations.

Three concrete opportunities survive: composable local continuations for ready
helper calls, virtual nested/shared products and owned reconstruction, and compact
typed scalar regions. Editdist has65 hot-loop instructions/9 stack operands versus
26/0 in both C products despite no hot helper calls. BST spends51.3% in take/ctor
helpers but only0.5% in scheduler/control; no single dispatch fix explains both.
Numeric ray remains3.41× upstream even in mature C and needs more than porting it.

Next: predicate normalization and RLE state-lane ceilings before general changes.
Previous generic-cell reuse, numeric analysis cost and neutral map fusion remain
negative evidence. Gain ranges are hypotheses, not new speedups. Two guards cost
380.42s; no new compiler/program builds or failed target runs. Independent oracle,
sources, hashes, physical PCs and output receipts are retained in the capsule.
