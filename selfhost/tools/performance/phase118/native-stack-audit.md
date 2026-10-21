# Full-catalogue stack repair

Root reported the first `float-source01` native acquisition failed with a hosted
`RangeError: Maximum call stack size exceeded` after roughly254s frontend and
332s integrated entry. That receipt retained only the error string, not its
stack. **The failing function has not been identified dynamically.** This audit
finds concrete source-level stack hazards and supplies a bounded repair/control
candidate, not a claim that native self-hosting now succeeds.

Audited source: `selfhost/build/phase118/float-source01/compiler.bend`, SHA-256
`b16a71925e94585b5d66a010a8377a1f6500376de217d90fee7eb2e8fcb26c08`.

## Findings and exact scope

The qualified Phase114 `p114ts_*` repairs at source50529–50574 move the accumulated
Boolean into a direct self-tail-call. The source compiler can lower that shape
to a loop; a recursion nested inside `&&`, a constructor, a join, or a thunk is
not equivalent for hosted stack consumption.

| Traversal | Original depth risk | Isolated repair |
| --- | --- | --- |
| `p118i_permission` → `no_effect_definitions`,51834/35087 | New invocation of the mature permission scan over~3225names; recursive call is inside `nt_choose` closure. It can precede transport entirely. | New `p118ns_effect_definitions` loop using the exact mature per-definition predicate. Explicitly return on first refusal before another lookup. |
| `p118z_segments`,51912 | Post-recursive conjunction over~21000segments. | Direct-tail Boolean accumulator. |
| `p118z_functions`,51929 | Post-recursive conjunction over thousands of workers. | Direct-tail Boolean accumulator. |
| `p118z_scalars/direct`,51899/51920 | Linear statement lists retain frames. | Direct-tail list scans; tree nesting still follows existing branch recursion. |
| `p118b_project_functions`,51515 | Join after recursive result creates catalogue-depth frames. | Reversed output accumulator, preserving every function and first diagnostic. |
| `p118b_project`,51491 | Same issue on long linear bodies. | Direct-tail spine with unchanged recursive branch projection. |
| `p118b_without`,51557 | Cons after recursive result when retaining workers. | Reversed retained-function accumulator. |
| `p118e_workers`,51749 | Accepted candidates call `p118e_worker_result`, then recurse mutually through a thunk. | Inline result handling into a direct-self-tail loop; stop at first error as before. |
| `p118c_ctor_names/candidates/ctors`,51619/51628/51674 | New list reconstruction through constructor and source-definition catalogues. | Reversed accumulators with exact original order/filtering. |
| `p118c_zero_byte`,51706 | Post-recursive OR across the constructor metadata byte table. | Direct-tail found accumulator. |

`native-stack-safe.bend` contains these overrides plus private helpers. It does
not alter the mature `no_effect_definitions`, C/JS policy, runtime, optimizer
admission conditions, verification, produced ABI, or production selection.

Other Phase118 traversals were reviewed: `p118b_candidates/rederive` belong to the
separate diagnostic plan route; the integrated production-shaped entry uses the
repaired `p118e_workers`. `p118z_tables`, `p118c_cap_tables/has_cold` walk the small
fixed metadata-table list, and cap-item maps walk the fixed program descriptor,
not the per-segment function-pointer payload. They remain unchanged. Per-node
constructor field/argument lists are already bounded. Recursive source/IR tree
depth remains a separate risk; no broad tree rewrite is justified without a
stack identifying one.

## Semantic preservation

- The effect predicate preserves authenticated native definitions; trusted AND
  filled foreign-provider permission through `no_effect_foreign_allowed`; exact
  Def classification; and `no_effect_terms` rejection of any Rwt. It neither adds
  provider names nor grants permission based on a name alone. An explicit Bool
  match stops before the next lookup after refusal. The helper's Bool binder is
  first to preserve Bend's structural match ordering.
- Transport's original Boolean conditions and special immediate
  Call-transition/Return rule remain exact. All node predicates are unchanged.
  The loop accumulator changes grouping of pure Boolean calculations, not their
  admission result. It is not a new transport certificate.
- Projection retains depth-first, left-to-right order. Every current projector
  leaf has `fresh=0` and `calls=[]`; those fields remain exact. Accumulating
  `p111_first(previous,next)` preserves the first diagnostic, including branch
  yes-before-no and body-prefix-before-suffix precedence. The projector still
  processes every original node; it does not silently omit a failed suffix.
- Reversing each output prefix into the accumulator and reversing once at the
  end yields the original concatenation. Borrowed reader-before-adapter order,
  dependency order, cold constructor order, and retained original worker order
  therefore remain unchanged.
- Accepted observer workers retain the old first-error stop. No later observer
  analysis runs after failure. The old continuation helper can remain defined
  for compatibility, but this loop does not call it.

Independent source review by `p110_laws` checked the projector invariants and
caught the early-refusal and structural-binder hazards before freezing. No target
execution was performed by this audit author.

## Cheap gates before another acquisition

`native-stack-controls.bend` exports:

- `p118ns_controls()`: small permission equivalence with the exact mature
  implementation (ordinary, Rwt, trusted, untrusted, unfilled and unknown foreign
  cases), nested projection exact text, existing transport finite controls, and
  an eight-element scale case.
- `p118ns_scale(32768)`: positive analysis-only catalogues of32768segments,
  scalar Sets, direct workers, projected workers and filtered workers, plus a
  permission scan of32768names. It checks admission and exact output count/order;
  duplicate lookup names isolate traversal depth using a single ordinary Def.
  Input is capped at65536 to bound this diagnostic's resource use.

These values are never emitted or executed as target programs. They are not a
claim of whole-program verification or a runtime-failure probe. The old recursive
large implementation need not be run just to reproduce a stack exception.

Root should first check the composed Bend API, confirm new helpers actually
compile into hosted loops, and run the finite/large controls. Then compare exact
QBE output on the existing ordinary broad fixtures before repeating native
acquisition. The next full attempt should retain exception stack and split stage
timing. If another stage fails, use that stack rather than adding further
speculative recursion repairs. No success measurements were available when this
audit was written.
