# P69-010: keep checked result layout facts across native calls

Registered 2026-10-12 before preparing or executing a target derivative. The
source lane prepares saved C; root owns native execution and selection.

Typed10 narrows trusted scalar input parameters, but native calls still return
all values through opaque `Term` arrays. Lexer `step` returns a two-word
`(Mode,U32)` product, and its caller seals the accumulator as an unknown value
when reboxing the loop state. Packed user constructors also retain generic
field-extraction paths because their incoming representation is opaque.

Hypothesis: retaining checked scalar result fields and canonical packed-value
facts at private boundaries removes surviving generic ownership and packing
work, beyond typed input parameters. A small generic metadata extension may
close a measurable part of the remaining lexer gap. This is separate from
eliminating loop-state boxing itself.

The first discriminator starts from actual checked typed10 lexer C, preserves
its original bytes as an explicit timing role, and changes only result read
facts (u32 casts for proven U32/Char/Bool fields) or private input facts proven
to be canonical packed constructors in this finite source. No constructor IDs
are truncated. Original compiler23 and upstream remain method controls, not
the attribution baseline. Each derivative must have exact before/after spans,
input receipts and reverse replay. Keep arms bounded and distinguish scalar
result facts from stronger packed-argument assumptions.

Admission to a compiler implementation requires checked types and actual
emission representation, with raw fallback and foreign-value refusal. A
nullary user enum is a full tagged Term, not a U32. A one-U32-field user type
is packed only under packing permission, and static image construction must
meet the same contract. Recursive sums, Nat payloads, unknown foreign values,
erased/dependent telescope mismatches and general heap products are excluded
unless separately proved. F32 facts concern raw bits, never numeric casts.

Require correct independent outputs, threads 1/4 controls and balanced
qualified kernel clocks. Reject a no-op or negligible result instead of
integrating broad metadata complexity. Any product-loop admission repair is a
separate mechanism and must not be credited to this result-fact experiment.
