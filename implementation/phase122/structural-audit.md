# Phase122: remaining container and control boundaries

Offline audit at `920d691`, using Phase121 source04
`3edd22028a2c2601caa715d2dbbc3694b3fc0a402ad7eda588c438ce64d615d2`.
No compiler changes, builds or target executions were performed by this audit.
The generated products are pinned by
`selfhost/build/phase118/p121-broad-emit04/report.json`; original fixtures and
upstream C by `selfhost/tools/performance/phase112/benchmark45/manifest01.json`.
All QBE line references below refer to that emission directory.

The existing Phase121 three-round medians are RLE1532/201ms, evening1432/204ms,
and tree966/200ms: respectively7.62×,7.02×,4.83×upstream. These are fixed batch
medians, not per-request compile times. Parent is effectively unchanged for
all three. Fresh Phase122 timing/profiling belongs to the root survey; static
counts below do not attribute runtime or establish a speedup.

## 1. Product layouts stop before the useful state boundary

**Observed:** RLE's loop state is the finite nested product
`U32 & U32 & List<P2>`, represented as two nested Sigma/Tuple shells. In
`test-rle-roundtrip.ssa:1089`, the direct `rle` loop takes both state Tuple
cells. Its inlined `rle.step` then constructs two fresh state Tuple cells in
both branches before its backedge (`:1252` onward). On a run transition it
also creates the actual output pair/list node; those are separate allocations.
Inlining has already happened and has not removed the state representation.

The pinned upstream C, at
`selfhost/build/phase93/broad01/test-rle-roundtrip/upstream.1.c:1397`, returns
`cur,count,acc` as three lanes from `spin_6`; `spin_10` at`:1465` carries those
lanes as loop arguments. Its equal-run branch allocates no state shell. This
is a concrete code-quality difference, not an inference from helper hotness.

**Exact current restriction:**
`selfhost/src/back/native/product-layout.bend:47` rejects a field whose ADT
**name** equals the outer owner's name. The selected assembled compiler retains
this condition at`fusion-source04/compiler.bend:33745`. Consequently a finite
nested Sigma instance is rejected like a recursive outer shell. Existing
`NQShape` stores only a constructor name and one-level width; fields remain
ordinary one-word Terms (`selfhost/src/back/native/product.bend:1`).

Argument flattening and tail recursion already exist:
`phase113/products/plan.bend:18` constructs flat entries;
`phase113/products/lower-helpers.bend:77` produces a `P113DAgain` for an exact
tail self-call with matching result shape. There is no reason here to increase
inlining budgets. Distinguishing finite nested instances from recursive layouts
could admit the **outer** shell with the existing representation. Eliminating
both shells requires a compositional layout/bundle representation, not just
relaxing a guard. Confirm admission with a structured diagnostic before changing
the proof boundary: the source condition is exact, but no refusal trace was run.

**Related observed restriction:** evening's active boxed `keep2` worker
(`test-evening-program.ssa:2091`, called at`:36079`) keeps a Tuple and takes it
twice for `pa`/`pb`. Even its emitted flat alternative at`:2158` reboxes the
two scalar arguments before sharing; this alternative is not the active call
and must not be counted as extra dynamic work. The reason is the one-use
virtual-shell rule in`phase113/products/layout.bend:32`: both maximum and minimum
uses must equal one. Upstream's current `bend2/comp.ts:1793` documents and
implements unboxing a fresh shared flat value before sharing its field words.

**Small falsification:** separately test source-level RLE workers with explicit
`cur,count,acc` arguments, then a source variant that removes only the outer
state shell. Keep the wrapper and full output oracle unchanged. Vary run lengths,
empty/singleton inputs and U32 wrapping in independent controls. For shared
products, test a renamed two-field projection computation with a genuinely owned
list field as well as scalar fields, including conditional drops and escape.
If native runtime barely changes after state allocations disappear, do not
expand the layout system on the strength of this witness alone.

Required general contract: finite bounded layouts, exact constructor identity,
field-level retain/drop accounting, preserved evaluation order, and boxing only
at real escape/opaque boundaries. A same-name ADT guard cannot simply be removed
globally without deciding what recursive and dependent instances mean.

## 2. A ready callee cannot be resumed inside the private recursive region

**Observed:** `lrepeat`, `lconcat`, `digest.go` and `rle` have direct workers;
`lconcat` already has the Phase118 constructor-tail transform
(`test-rle-roundtrip.ssa:742`). `expand` and `go` remain public scheduler
segments (`:9415`,`:10564`). The `expand` nonempty branch pushes a continuation,
calls `lrepeat`, resumes to recursively call `expand`, then tails to `lconcat`.
Its conversion also still calls `p111_rt_op` rather than the direct scalar
lowering. The source is ordinary nested calls, not an effectful algorithm.

The direct-worker closure rule requires every non-self callee to be admitted
(`phase113/direct/plan.bend:29`,`:49`), and direct lowering rejects non-tail
self-calls (`phase113/products/lower-helpers.bend:77`). The later recursive table
can call an existing ready worker **terminally**
(`phase114/recursive-table/plan.bend:46`), or push a frame then descend to the
**same recursive owner** (`:52`). The initial push-and-call-to-`lrepeat` is
neither. This supplies a concrete structural reason for `expand`'s refusal;
the exact complete refusal trace is still unmeasured. Its absent direct worker
also obstructs direct closure of callers such as `go`.

**Proposed capability:** a checked `CallReady(result,callee,args)` followed by
local continuation resume inside the existing explicit-stack region. Require a
callee from the immutable verified direct registry, exact arity/result ownership,
preserved captures, and no new call-graph cycle. Recursive depth remains in the
explicit table stack. Unknown calls and effects retain their fallback. This is
more general than raising a node budget and can transfer to parsers, map updates
and tree visitors that call helpers before recurring.

**Small falsification:** inspect the emitted structured refusal for `expand`
first. Then compare two diagnostic versions of the same recursive list walk,
one with an outlined ready helper before descent and one with that helper
lexically inlined. Include a heap-valued helper result and deep input. If the
boundary disappears without changing allocation counts, measure whether control
transport actually falls. Do not replace stack-safe recursion with machine
recursion to obtain a misleading ceiling.

## 3. Tree reconstruction loses reusable cells and known scalar representation

**Observed:** `warp_zip` consumes two Node shells and builds three Nodes. QBE
`tree-bitonic.ssa:678` calls `take2` twice and `ctor2` three times on its normal
Node/Node branch. Upstream `spin_5` in
`selfhost/build/phase93/broad01/tree-bitonic/upstream.1.c:1384` loads the four
children, rewrites the two input cells in place and allocates only the enclosing
Node. This reduces whole heap operations, not just instructions inside helpers.
The QBE sized helper explicitly frees the consumed shell after `ctr_take`
(`phase118/runtime-sized.c:10`), losing that cell as an IR value.

The same tree's scalar Leaf is already packed; it is incorrect to claim all
leaves allocate. However, its construction retains a payload-fit branch
(`tree-bitonic.ssa:793`) and its recursive worker takes each packed U32 Leaf via
an out-of-line helper (`:11083`). Upstream extracts packed leaf payloads directly.
Typed representation facts could eliminate the runtime transition on these
already-known packed values while preserving fallback at unknown boundaries.

**Limits and falsification:** generic consumed-cell reuse was already tried
and was neutral/slower in Phase118; see`phase118/trmc-reuse-audit.md:118`.
Do not resurrect its credit ABI unchanged. A narrower proof-carrying private
`TakeOwned`/`Rebuild` operation should first establish unique, non-static,
non-packed ownership, exact storage class, preserved children, and no alias
visible across the rewrite. Compare an isolated `warp_zip`-shaped local rebuild
with unknown/shared/static refusals before a whole compiler campaign. The
required ownership evidence is stronger than having matched the Node tag.

## Priority and limits

1. Diagnose and ceiling-test **nested state layouts plus field-level product
   ownership**. This has exact upstream evidence and an unusually cheap source
   control. It can remove allocation entirely; the outer-shell and full-layout
   changes should be measured separately.
2. Diagnose **non-tail ready calls inside stack-safe private recursive regions**.
   This explains why existing direct helpers fail to compose and is the strongest
   control-flow opportunity in this audit. Its potential reach is wider than RLE.
3. Try **proven-private tree reconstruction reuse/packed-field access** only with
   an isolated mechanism that avoids the previously rejected generic protocol.
4. A later ceiling can fuse `digest(expand(code))` while retaining `code` for
   `llenp`. `code` has two consumers, so Phase121's single-consumer list proof
   cannot erase it wholesale. Preserve repeat order and U32 wrapping. Replacing
   this fixed-input smoke test with its known constant output proves nothing
   about general optimization.

Evening already receives direct F32 arithmetic and flattened Array.swap results
(`test-evening-program.ssa:1866`); it still has two `p113_rt_array_pair` calls,
array construction and a final sink. Do not assign its whole7×gap to floating
point or the tiny `keep2` witness. Its mixed map/set/text work needs the fresh
dynamic attribution. Likewise, the RLE layout fix removes only some constructor
work and cannot by itself explain or promise recovery of7.6×. The earlier neutral
map-to-list/tree-fold ceiling remains relevant negative evidence against assuming
every allocation-removal rewrite is profitable. Whole-suite gain requires
measured coverage and an Amdahl calculation, not multiplying local ceilings.
