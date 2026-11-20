# Register-aware compare/select experiment

The experimental selector reuses allocated operand/result registers inside an
already certified integer compare/select corridor. It is intended to realize the
Phase196 unsigned-minimum discovery through normal direct-object emission.
Live compiler files are unchanged. The `qualify` owner performs checking,
controls, ordinary emissions and timings; this lane runs no compiler or target.

## Integration

`recipe.json` lists exact modules, exports and driver. Append `select.bend` and
`hook.bend`, replacing only `x194_ps_emit`. `x197ms_enabled=false` uses the exact
original emitter, retained as `x197ms_previous`; the text identity audit is in
`source-audit.json`. Default true selects the candidate. Both typed assembly and
direct objects use the same `X188Seq`; no assembly rewriting is introduced.

The original `X194Select` recognizer, complete-use counts for removed Boolean
locals, copy-arm admission, allocation graph and physical homes remain intact.
This rule also applies to other integer comparisons/selects with the same proof,
including signed order, equality, inversion and mixed comparison/result widths.

## Safety argument

The new path requires physical register homes for both comparison operands and
both selected values. Missing, constant or stack operands retain the original
emitter. CMP executes first, reading the original values and their original
comparison width. The first output's allocated register becomes the result home;
a stack output instead uses the existing reserved R11 scratch.

If the result aliases the yes value, the conditional move selects the no value
under the complementary predicate. If it aliases no, only the original predicate
conditional move is needed. Otherwise a width-correct MOV copies no into the
result before conditional selection. This preserves both selected inputs until
the last one is consumed. Predicate inversion in the original plan swaps yes/no
before this register choice. For U32 results, explicit MOVL normalization clears
high bits even when the conditional move is not taken. Normalization follows CMP
and preserves its flags. U64 results retain full input words, even when their
comparison used low32 bits.

Every original output publication remains, in its original order. A same-home
MOV can be omitted because that home already contains the selected value; all
stack stores remain. Publications use ordinary stores/moves, which do not change
the result register or flags. No extra scratch register, memory access, new local,
new allocator assignment, instruction motion or liveness assumption is added.

## Expected activation

The retained current editdist/local-pair first minimum should shrink from seven
instructions to `cmpq` plus `cmovaeq` in the operand/result home. Its second
minimum should use `cmpq`, one MOV to R11 and one CMOV, followed by the original
frame publication. This removes eight of the eleven instructions removed by the
Phase196 handwritten transfer experiment. Increment folding is a separate rule.
The actual emitted ELF audit confirms this eight-instruction reduction in all
three edit-distance cases: 64 to 56 instructions, or 55 for combined. See
[machine-audit.md](machine-audit.md) for pinned objects, exact decoded sequences
and reproduction. Paired ordinary-program results remain separately owned by
the qualification lane.

## Controls and current status

The existing Phase194 predicate fixture supplies68 structural corridor controls
and7,260 independent C observations. The additional fixture supplies eight
activation/refusal checks and320 fixed-home machine functions: ten predicates,
both comparison widths, both result widths, inversion, and four destination
placements (left, right, third register, stack). Its unchanged inputs and two
output publications are checked against independent C predicates on121 full-word
edge pairs, yielding38,720 observations per object/assembly route. High-word-only
differences and signed boundary values exercise mixed-width behavior.

These fixed-home fixtures directly test the actual hooked emitter on valid
plans; the existing corridor tests and ordinary programs exercise recognition,
complete-use admission and allocation. The routes share instruction selection
and are not independent compilers. No backend theorem or benchmark gain is
claimed from these finite tests.

The minimum-api01 checked acquisition passed on its first attempt. The
minimum-controls01 receipt passes all76 structural rows and45,980 independent C
observations on each object/assembly route. Exact receipt hashes are in
control-evidence.json. These jobs were executed by the qualification owner;
this lane performed only source work and read-only receipt review. Ordinary
emission has completed; actual machine activation is confirmed in
[machine-audit.md](machine-audit.md). Timing remains owned by that lane. No commit or maintained-file edit
was made by this lane.
