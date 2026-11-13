# Phase192 larger register/control frontier

The strongest general extension is **versioned pure-expression numbering with
branch facts**, followed by selection of predicates as control rather than
materialized integers. Its first causal witnesses are measured-hot Map traversal
and the repeated generic-Boolean tests in tree/BST workers. Keeping F32 loop state
in XMM is worthwhile, but float-only coverage limits its suite-wide ceiling.

No compiler or target program ran for this investigation. The measurements below
come from the retained Phase191 profiles. Fresh work is source and ELF inspection.
Current Phase191 products are `selfhost/build/phase191/native45-02/CASE/machine/program`;
C identities come from `selfhost/build/phase191/references01/manifest.json`.

## Measured hotness and the actual obstruction

Final numeric-1024 profile: 64.49% of weighted samples in `$direct.p37.numeric`,
35.37% in `p111_rt_op`; normalized clean CPU 9.848 microseconds/repetition versus
C 3.237. Final Map-32: borrowed `Map.bit.go` 10.958%, insertion 5.752%, seek 5.257%,
work loop 6.964%, ctor2 5.001%, take2 4.677%, take3 4.455%. There is no dominant
Map leaf analogous to numeric. These are physical leaves, not source-inclusive
owners or removable-time estimates. Map has 1.843% unknown samples and relatively
few samples per secondary function. See `research/phase191/final-profile-assessment.md`.

Map's exact hot borrowed bit worker has a loop at `0x406ffa..0x407371`.
On its string-constructor path:

1. `0x40705f..0x407080` decodes `(s >> 40) & 65535`, compares with tag25,
   and enters the successful arm.
2. `0x407080..0x4070d6` is 20 instructions: compute arity==2, recompute that
   identical tag25 predicate, materialize both results, combine and branch.
3. `s` has not changed. The second tag predicate is exactly true by the incoming
   branch. Its temporary names and intervening assignments are irrelevant.

The current local pass clears its state at the branch, while expression reuse
only compares shallow operands and invalidates names on writes. A value-ID key
for the complete pure expression preserves its meaning through the branch.
This does not justify deleting the arity/layout test: only the repeated tag
conjunct is implied. The existing C worker's actual loop is `0x166e0..0x1672c`;
it directly tests the loop-edge tag and keeps necessary heap-layout work.

Tree-bitonic `$direct.warp_leaf.go` first decodes a generic Boolean in
`0x408971..0x4089c8` (19 instructions, two setcc). One arm reaches
`0x408ae6..0x408b37`, repeating the same composite decode without the complement
(18 instructions, two setcc). The earlier condition is a Boolean expression of
immediate-value and tagged-value comparisons. Its false branch implies the
uncomplemented expression is true. Recomputing it can collapse to a constant
without assuming that a generic Boolean always uses the immediate encoding.
BST-32 `$product.bst.pick` repeats the same shape at
`0x408751..0x4087a2` and `0x40885d..0x4088b4` (18 and 19 instructions).
C uses a direct Boolean compare/branch at `0xded5/0xded8` and
`0xbef1/0xbef5`, respectively, but its private representation contract is
stronger. Our transformation must preserve both valid encodings and arbitrary
bit patterns accepted by the original machine code.

There is no final-product tree profile. These are actual emitted worker shapes,
not a demonstrated tree-wide removable share. A tree profile is needed before
claiming that this dominates its roughly 4.75x C gap.

## Why XMM lifetime extension alone is insufficient

`float-registers.bend:x186_x_homes` explicitly forbids parameters and setup
values. `x186_x_plain` cuts the region at every ordinary integer operation;
branches and Again also cut. The recurrence F32 parameter cannot occupy an XMM
home across its backedge, even after inline conversion removes the runtime call.
This is a concrete representation boundary, not insufficient register count:
14 XMM homes exist but only closed straight-line regions can use them.

The numeric loop's frozen Phase191 product has 12 movd transfers for four F32
arithmetic operations. Its complete positive iteration has 85 instructions,
one generic conversion call and repeated private staging. Root's conversion and
staging work addresses the first barrier; a distinct next step would assign
canonical F32 loop-carried values XMM homes, initialize at entry, perform parallel
XMM backedge moves, and publish only at a real non-F32 consumer or ABI boundary.
Real calls must spill/reload or refuse those live ranges. Integer instructions
that neither read nor overwrite the floating value need not cut its lifetime.
F32 rounding order, NaN payload/canonical-word handling and full-word bit uses
must remain unchanged; this is not reassociation or SIMD vectorization.

The float emitter also calls `x181_stmt`/`x186_x_emit_if` rather than the newer
`x190_stmts` selection path. Numeric thus still emits n==0 and n!=0 as separate
cmp/setcc/movzx/test chains. This is a composition failure: adding one F32 node
selects a path which loses general adjacent/complement branch selection.
A shared typed late control representation should avoid this split.

Crucially, only five of the 44 eligible catalog points are the explicit F32
families: two numeric recurrence and three raytrace. Mandelbrot uses integer
fixed point; symreg is an integer tree interpreter. Halving all five F32 cases
would improve the suite geometric mean only 7.57%; a 30% reduction yields 3.97%.
Additional benefits to other workloads require an actual general mechanism,
not describing integer benchmark names as floating-point coverage.

Raytrace has larger exposed F32 regions: current `$product.nearest` is 853 static
instructions with 40 arithmetic SSE operations and 68 movd transfers;
`$product.trace` is 2,153 instructions with 103 arithmetic SSE operations and 359
movd transfers. These counts include alternatives/calls and lack a physical
profile; they motivate a bounded witness, not a whole-workload speed forecast.

## Bounded path-fact prototype design

Root authorized an experimental module separately from production integration.
The intended invariant is value identity, not identity of a mutable local name.

* Maintain local-name -> value-ID bindings. Every definition replaces that
  binding; unknown loads get fresh opaque IDs. Preserve old expression facts
  because they denote old values, not the new local contents.
* Intern bounded exact keys for U32/U64 pure expressions: operation, input width,
  operand value IDs. Constants use exact low/high words. U32 truncation is an
  explicit key unless its operand is already proved canonical. No memory reads,
  division, effects or floating arithmetic enter the expression table.
* A branch forks the environment. A comparison or exact Boolean expression
  gets a 0/1 fact on each edge; propagate through Boolean xor1 and the sound
  directions of Boolean and/or. Generic word conditions retain low32 truth
  semantics and must not be assumed to equal1 on the true edge.
* A later equal expression receives the same ID, so its condition can become
  a literal and the dead arm can disappear. Preserve termination: never append
  continuation statements after a chosen Return/Again.
* Initially reset all facts at unresolved joins, calls, results and backedges.
  A branch-local optimization does not need general CFG phi nodes, a global
  fixpoint, memory alias analysis or a register allocator rewrite.
* Bound the function and intern table, with an off switch and complete fallback.
  Table saturation may lose reuse, but must assign a fresh opaque ID instead of
  conflating unknown values. All mutations and emitted rows remain ordered.

This is broader than the initial exact0/1 copy-diamond slice: it recognizes
recomputed expressions whose intermediate names differ, including constructor
bits and composite Boolean decoding. It still cannot remove ownership work
merely because a constructor tag matches.

## Larger next payoff: predicate-aware selects before allocation

The current local-pair `$product.row` iteration is 93 instructions. Three
14-instruction windows (`0x40ce84..0x40cec4`, `0x40cf16..0x40cf49`,
`0x40cf63..0x40cf9f`) materialize a comparison, move its Boolean through scratch,
re-test and cmov; the windows include seven frame references altogether.
The older Both profile places 98.94% of samples in this row worker, and its C
counterpart's measured inner loop has 26 instructions. The final row has not
been reprofiled, so transfer of exact sample share is an assumption.

The first Boolean slice can improve one constant-select window. A typed select
node carrying the comparison operands directly, introduced before liveness,
can remove materialized predicate live ranges for arbitrary-value minima too.
This allows true cmp/cmov selection and gives the allocator the shorter actual
live ranges, instead of preserving the obsolete Boolean destination and all
copy-transport names through placement. This is a general transformation with
integer loops, lexical classification and tree predicates as natural consumers.
It should be a separate follow-up to path facts, not hidden in their timing.

Mandelbrot `$direct.mit` has seven setcc and seven cmov in the inspected
`0x409549..0x409824` region (includes exit code). Several comparisons of unchanged
escape state repeat and three arithmetic-shift constructions pass through
Boolean selection. Do not add a Mandelbrot-specific signed-shift rule; shared
predicate identity and direct selects are the general obstruction to address.

## Falsifiers and realistic complete-workload ceilings

First inspect the diagnostic IR for Map bit traversal and tree warp_leaf.go.
The value-numbered expression keys must actually match across the branch.
A dry structural control should demonstrate removal of the exact redundant
check while preserving arity/layout and malformed-value branches. Reject the
prototype if the desired checks survive or if reuse requires assuming stable
memory, a canonical incoming Boolean, or unchanged mutable names.

After finite adversarial controls, use a balanced Map/tree/BST/lexer/local-pair/
Mandelbrot/numeric screen. Each case must have an emitted-loop witness and its
own output oracle; static removed checks do not justify promotion. If small
cases improve but real Map remains flat, profile the changed product before
expanding the algorithm. No target or compiler job was run by this task.

Saving 15% of the observed Map bit leaf saves only about 1.64% of total Map CPU
under unchanged attribution. Entire zero-cost elimination of bit+ins+seek is
an impossible 21.97% time ceiling; real expression simplification saves much
less, while other callers could add coverage. A major Map gain needs broad
producer/consumer and ownership/layout work beyond these checks.

For suite context, reducing 10 of 44 points by25% gives a 6.33% geometric mean
reduction; doing so in20 points gives12.26%. Reducing20 points by40% gives20.72%.
These are transparent scenarios, not forecasts. The path-fact prototype alone
has no evidence for the latter scenario. A complete predicate/select/lifetime
pipeline could plausibly pursue 10–20% suite improvement if it wins across the
identified families; its combination with float/runtime work must be measured.
Neither a register-only step nor one hot Map leaf currently supports promising
parity from2.7366x C.

## Experimental artifact and actual IR confirmation

The prototype is now authored in
`selfhost/tests/phase192/path-facts-experimental.bend` (246 lines), not registered
as a production module. `x192_path_facts_body` has a 1,024-statement admission
bound, a 96-entry expression table, eight-level Boolean fact propagation and
an explicit enable switch. Constructor/function IDs are interned symbolically;
no numeric constructor-ID assumption is embedded. U32 copies have explicit
truncation identities unless the operand is already exact0/1.

The authenticated diagnostic at
`selfhost/build/phase192/diagnostic01/coverage-map-churn-32/preselection.json`
shows both outer `tag` and inner `p114t_6_borrow_aux` as the same two U64
shift/mask operations over unchanged `v_4294967295`, compared against
`N111CtorId{SCon}`. The tree diagnostic shows the exact same U32 OR of raw and
boxed Boolean tests, first followed by xor1, then reconstructed in its false
arm. This confirms feasibility at the compiler's actual representation boundary,
not only a hypothetical machine peephole.

`path-facts-controls.bend` supplies seventeen structural modes; its independent C
observer checks2,873 input/mode combinations per route. Cases include changed
locals, fresh loads, store/load aliases, calls, U32/U64 mismatch, composite
Boolean negation, unresolved joins, snapshot copies, table saturation, U32 copy truncation, generic low32 truth,
and positive/negative AND/OR decomposition.
`controls-path.mjs` uses the existing authenticated direct/assembly comparison
workflow. C syntax and delimiter checks passed; checked-source acceptance and
actual machine observations are pending root's serial lane. The separate
`path-facts-integration.patch` targets the current pipeline and is unapplied.
No runtime improvement is established by these authored artifacts.
