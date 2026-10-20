# Candidate31: three remaining machine-work categories

Read-only audit of the frozen `p113-wide31-*-emit/program.ssa` and matching
`*-build/program.s`. No new compiler, program or performance execution.
Exact artifact pins and static counts are in `remaining31-counts.json`.
Counts include cold fallback paths; they are not dynamic counters or a runtime
attribution. The parent's qualified timing results remain authoritative.

**1. Scalar idiom and Boolean cleanup remains after calls disappear.**
`$direct.mit` has121 assembly instruction lines, four branches, no machine
calls and no negative-rbp spill references. Its two positive-rbp references are
incoming arguments, not spills. The emitted QBE retains one syntactic fail
call that QBE removes; there are no runtime continuation or ownership calls in
the executed machine loop.

The assembly still builds arithmetic sign-fill through shift31, compare,
setcc, zero-extension, compare-to-one and conditional move; the same pattern
occurs for the three arithmetic right-shift helpers. Boolean consumers also
repeat compare/setcc/compare-to-one sequences, and there are repeated same-
register32-bit moves around wrapped arithmetic. Existing upstream C
`scalar-region-8192/upstream.1.c:1443` keeps the loop's arithmetic values as
u32 and marks those helpers inline. The next scalar opportunity is generic
recognition/propagation of signed-shift and Boolean identities, not more
ordinary-call inlining or ownership removal from `mit`. No proposed rule may
discard its defined raw-word/shift semantics. The previous rough317-line
baseline is no longer the current loop.

**2. The array row still calls a large cell; guarded memory operations remain.**
For both local-pair and editdist, `$product.row` calls `$product.cell` once in
its loop. It does **not** call `cell.f3` separately. Cell's stages are already
inlined into its52,273-byte QBE body, while row remains separate. Row has58
assembly instruction lines; cell has392, including129 negative-rbp memory
references and a2408-byte explicit stack allocation before saved registers.
These memory references include result/scratch areas as well as spills.

Cell contains eight static `p113_rt_array_pair` fallback call sites and two
`p111_rt_op` fallback sites. Those remain in assembly but are conditional;
their presence does not imply ten calls per cell on admitted raw arrays. Each
fast access checks raw ARR tag and dynamic location, extracts class/location,
masks the index, and checks the loaded old word is scalar. The private heap
base is already loaded once per function. Flat result buffers and surviving
fallbacks keep values live across joins.

The upstream local-pair C's `spin_8`/`spin_10` at1452/1490 uses inline cell
stages and direct `blk_loc`/`blk_at`/`blk_read`, with a four-word row result.
The next general opportunity is preserving certified array descriptor facts
and immutable handle identities across the whole row, then hoisting/reusing
guards/address components and simplifying result-buffer joins. Increasing the
inline cutoff alone moves a large guarded body into row; it does not prove
those guards redundant or remove their live ranges.

**3. Tagged state objects and non-tail reconstruction remain outside flat products.**
Lexer `$product.lex` calls `$product.step.at`; it still has three constructor
take sites and one special take. Step.at contains six constructor sites and
two takes, with266 assembly instruction lines and26 negative-rbp memory
references. These are the tagged `Mode` transitions: the product pass removes
the outer tuple, but does not flatten a multi-constructor state union.

The same candidate retains generic non-tail String generation: the original
`ident` and `num` bodies each contain four frame sites, and `gen` contains
eight. These are static generic-body counts, not proof that every frame site
executes. The unchanged source still constructs String nodes after recursive
return. The separate `tmc-feasibility.md` describes a narrow stack-safe
destination-passing boundary for such constructor spines; it deliberately
does not admit arbitrary native recursion. Lists/trees/String broad45 results
have not yet been remeasured for candidate31 in this audit.

These categories suggest separate qualified experiments: scalar algebraic
identities; cross-iteration array descriptor/guard facts; and explicit tagged
state or constructor-spine representations. They do not establish a further
speedup or justify removing any current fallback.
