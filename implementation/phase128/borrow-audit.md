# Phase128 borrowed scalar observers and complete computations

Offline audit against Phase127 HEAD `00f9e0ea777bd0b01ee1e361112371353891ca19`.
No target execution, build, performance measurement, production edit or installed
selection change was performed by this audit. The Phase118 controls/results below
are historical evidence, not new qualification. The parent campaign owns execution.

The immediate scalar-result experiment is justified. The larger capability that
upstream already has is **interprocedural borrowing tied to a retained root**.
That removes ownership traffic across a search, its equality helper and its nested
field reads. It is more general than making an owning observer drop its roots
cheaply at the end, and does not require another backend.

## Exact evidence and limits

- Phase127 parent source: `selfhost/build/phase127/live-bank-source01/compiler.bend`,
  SHA256 `f4eb3c6b8aca8cdfc72c8eb308db83af50c6bee888a93b69415a77aa5101318d`.
- Archived scalar observer V2:
  `selfhost/tools/performance/phase118/scalar-observer-v2.bend`, SHA256
  `7a370d21d53ed09d7edce30f1c2a836c33c0e6d31a9ccac5a4cf0605e1d399a5`.
- Its runtime guard: `selfhost/tools/performance/phase118/runtime-scalar-borrow.c`,
  SHA256 `85d7f3a6a99f3864bdb7b6fd822d854061c87b59f1d83d9b0fb4650283f29ce3`.
- Upstream compiler actually used by the frozen name-search comparison:
  `selfhost/.bootstrap/upstream-phase66/bend2/comp.ts`, SHA256
  `2b13224ba09a9e39e37cccf06e449c1bdafe5e03a81641654f7d0e455507629c`.
  The working-tree `bend2/comp.ts` is byte-identical at audit time.
- Generated upstream C:
  `selfhost/build/phase127/name-search-upstream01/source.1.c`;
  acquisition and toolchain identities are in that directory's `report.json`.
- Generated baseline QBE:
  `selfhost/build/phase118/p127-name-search-emit03/compiler-name-search.ssa`.

The [Phase127 profile analysis](../phase127/full-scale-opportunities.md) establishes
expensive ownership work in actual compiler computations. Its active dispatch
contexts are not inclusive call stacks. The 14.65× name-search proxy gap is not a
whole-compiler ratio and cannot be converted into a whole-compiler gain estimate.

## The scalar observer's legality argument

The source of truth is the checked `NO_Plan`, not the fact that a machine result
occupies one `U64`. `observer-layout.bend:65` restricts `nol_scalar` to supported
native scalar types and bounded all-nullary enums. `nol_wrap` and `nol_finish`
allow a scalar-only wrapper only when its variable is the unique observation
slot. `observer-analysis.bend:388` checks both observation type and successful
scalar extraction on every return. A returned String, borrowed tail, closure or
arbitrary one-word Term is not thereby admitted.

The NO analysis also requires checked permission, excludes foreign/native owners
and reachable bang owners, evaluates only its supported pure vocabulary, tracks
field origins and constructor facts, and rejects unsupported effects, dynamic
application, helper cycles and exhausted analysis budgets. `noa_loop_valid`
requires same-root descendant cursors, at least one strict descent, and compatible
scalar arguments. `noa_recur_done` requires the recursive result to be returned
unchanged. The reader becomes `P113DAgain`, not native recursion per list element.

The adapter holds every original owning root until the readonly reader returns.
Borrowed field views never become ordinary owning values; the scalar observation
cannot contain them. The adapter then sinks each root exactly once. The fallback
receives the unchanged arguments when the guard declines. The shape-checked
`p118_rt_borrow_fields` reads `state->e.mem` through `term_peek`, copies fields into
a verified local scratch buffer, and never transfers their ownership.

These obligations must remain separate from structural IR verification. The
projection of the guard to a typed OR validates its interface and input use; OR
does not implement the runtime guard. Constructor/count projection similarly is
not an ownership proof. Re-derived checked plans, source-bound worker creation,
runtime identity and independent final verification jointly justify the code.

## What the guard actually guarantees

`p118_rt_borrow_scalar_safe` accepts one or two roots. Every root must be trivial
(including static values), or be RFC-backed with count greater than one. It rejects
two nontrivial RFC roots with the same RFC location.

This is stronger than a lifetime check: the adapter already holds the roots.
It ensures that the adapter's final sinks do not walk/destroy the retained data
under the sequential runtime. In particular, two adapter-owned aliases with
count two would pass two independent `count > 1` tests, but their second sink
would destroy the object. Rejecting equal RFC locations avoids that case. A future
extension could compare count against adapter-owned alias multiplicity, but this
is not needed to test the main hypothesis.

Unique/raw and mixed unique/shared inputs deliberately use the original path.
This is a profitability restriction, not a claim that readonly access to a unique
root is inherently unsafe. Nor does it avoid recursive destructor stack growth:
the actual `term_drop` at `runtime-divmod01/runtime.c:929` uses an iterative
pointer-reversal traversal. Keeping the conservative guard avoids adding a second
full read plus destructive traversal to unique-input work before measuring it.

The constant-time-drop argument assumes no concurrent owner changes between the
guard and final sinks. Lifetime remains protected by the adapter's ownership,
but parallel profitability is a separate claim. Reachable bang exclusions and
the sequential target must remain explicit.

The guard reads only `state->e`/heap metadata and does not access registers or
schedule. Its explicit admission must be added to `p118z_runtime` **without losing
Phase127's `p126_rt_nat_divmod` admission**. Otherwise one new helper can disable
the whole-program live-bank capability and erase the gain.

## Actual admission boundaries

| Computation | Current boundary | Safe next move |
|---|---|---|
| `p88_string_eq_go(String,String,Bool)` | Selected `p118b_eligible` explicitly excludes scalar `Var` wrappers. Its schema otherwise matches two String roots and Bool; actual complete NO and fallback admission must be counted. | Restore the separate scalar-result path and record both plan success and selected workers. |
| `p88_string_eq` wrapper | An owning wrapper has a real direct call to `go`. The NO evaluator treats `go` as an inlined helper; recursive helper re-entry can hit the cycle restriction because it is not this plan's owner. | First optimize `go`; do not silently widen recursion semantics to accept the wrapper. |
| `has_name(List<String>,String)` | `nol_plain` excludes parameterized roots. `nol_root_fields` admits exactly one same-owner recursive field plus scalar fields, so a String-valued list head also fails. Its recursive equality helper would require composition rather than unrestricted inlining. | A later borrowed helper/root summary, not simply relaxing `nol_plain`. |
| `f_find(List<KDef>,String)` | Nested owned fields, and an owning KDef result rather than a scalar. | A borrow-to-own escape with an explicit keep/transfer obligation; outside the scalar experiment. |

The current schema stores field type **names**, not full specialized type
identities. Removing the plain-type restriction alone would collapse different
instantiations and is not a valid implementation of generic borrowed roots.

The archived scalar implementation also rejects every `P113DCall` in its copied
owning fallback. This addresses real dependency ordering: additions are prepended;
`p118b_verify_functions` starts with an empty ready catalogue; `p113e_functions`
adds a signature only after checking its body. Calls to absent or cyclic helpers
are rejected. A structural direct-call signature says nothing about whether its
arguments are borrowed, so it also cannot justify calls from the borrowed reader.

The final name-search QBE `go` block contains an **inlined** character comparison
(`p113p_call_50` is a copy, not a call). This does not prove the pre-emission
fallback is call-free: final inlining may occur after scalar selection. The
diagnostic must inspect that exact preparation stage. The equality wrapper still
has an actual direct call to `go`.

If leaf fallback admission is the remaining blocker, a bounded extension is to
replace each selected public worker **at its original topological position** with
private original fallback, private reader and public adapter. Retain all earlier
helper bodies and signatures; project/check the complete final function sequence
from an empty ready set. Original `Again` remains a loop in the renamed fallback.
Do not seed the verifier with all future signatures, which would admit call
cycles. Preserve the existing cold metadata and Phase126 flat-worker closure.

The first 163-line Phase128 candidate was also read at SHA256
`4a469bd697d157007b5e8842aea8ecd9b4c7273d9543b2c9e4366c118a14e8aa`.
Its result-type strengthening, conservative leaf fallback, guard projection and
preservation of the Phase126 closure/divmod transport path are consistent with
this argument. This is a source review, not compilation or qualification.

## What upstream does beyond root equality

The pinned compiler makes borrowedness a property of live function parameters
and carries root provenance through fields and calls:

1. `brw_of` at `comp.ts:1192` tentatively borrows eligible boxed parameters;
   foreign/non-live functions and arrays do not receive this default.
2. `emit_open:2176` records each borrowed word's root parameter. `node_fields:1584`
   uses `term_peek` and propagates that root to boxed children.
3. `val_own:1641` either records an owned requirement or propagates a lend edge.
   `val_owned` filters borrowed words out of keep/sink handling. `val_arms` only
   retains a borrowed destination when all branches agree on its root.
4. `emit_args:2091` distinguishes owned arguments from borrowed ones, retained
   callers from dead/tail uses, and aliases. Owned arguments are handled before
   borrowed reads; lending requirements propagate across calls.
5. `compile_book:2768` emits to a monotone fixed point of ownership/layout facts,
   closes lend edges, and forces parameters owned when no valid lend exists.

This is observable without trusting Clang to recover high-level semantics:
generated `spin_3` at C line1351 reads string heads/tails without ownership calls;
`spin_4:1400` ignores retained roots without sinks; `spin_7:1435` composes them
without keeps; `FID_HAS_NAME:1855` peeks the list spine while owning/sinking its
query separately. The equivalent QBE wrapper at line1650 keeps both roots and
later sinks them; its owning walker at1452 takes each inspected constructor.

The general capability to preserve is a small **checked borrowed-call contract**:
formal borrow mask, root/field provenance, owning-result or nonescaping-scalar
result, effect/escape restrictions, and required retained-owner lifetime across
local resumes. It could let List<String> traversal lend each head into equality
without materializing an owned field or altering reference counts. It could later
apply to declaration/search/optimizer traversals. Typed direct-call ABI and
readiness alone are insufficient; an owned result needs explicit materialization.

This is a follow-on hypothesis, not demonstrated Phase128 performance. Copying
upstream's whole repeated-emission fixed point may increase compiler cost. First
test the scalar observer, measure remaining list ownership events, and use one
borrowed field/helper boundary as the next falsifiable experiment. The semantic
summary could be computed before lowering without copying the entire upstream
emitter architecture.

## Required controls and decisions

- Record accepted plans, refused reasons and actual emitted reader/adapter names.
  Correct output with no selected worker only validates fallback.
- Keep archived ordinary renamed equality, static, Unicode, unique, mixed,
  exact-alias count-two and retained-alias cases. Add shared suffixes, unequal
  lengths and early mismatch; print retained roots after the call.
- Keep deep traversal bounded in native stack; test non-tail/discarded recursive
  results, helper cycles/effects and escaping tails as refusals, not optimized
  executable cases. Test forged guard counts/types/constructor widths only in
  finite verifier controls.
- Compare dynamic takes/keeps/sinks/destruction and runtime independently. A
  borrowed helper per character may leave substantial call/check overhead even
  after ownership work disappears. Count reduction is not a runtime claim.
- Verify live-bank capability remains enabled, original semantic outputs agree,
  and unmatched unique paths do not regress materially before a compiler build.
- Test an unrelated scalar traversal and the exact compiler proxy first. Rebuild
  the compiler only after the proxy demonstrates actual useful admission and
  improvement. New native-image qualification remains a separate gate.

The most useful next step is the parent campaign's selected-scalar census and
name-search measurement. If it works, the likely next architectural opportunity
is lending nested fields through verified helper calls; if it does not, retain
the exact refusal/cost evidence before expanding the analysis.
