# Boolean path facts versus selection exposure

Source-only audit during the root's native qualification. No compiler, target,
benchmark, or runtime-error probe was executed. No selected module was changed.

## Main finding

**Do not start another Boolean path-fact pass for Mandelbrot. The selected range
pass already removes its impossible Boolean fallback branches.** The remaining
obstacle to a small selection recognizer is dead scalar definitions and copy
chains left by inlining and constant propagation.

This corrects the initial hypothesis, rather than demonstrating a new speedup.
The prior [scalar selection audit](scalar-select-audit.md) gives the machine-level
comparison: 97 static instructions and three conditional jumps in the candidate
loop, versus 38 and one upstream. Instruction counts are not dynamic cycle shares.

## Exact evidence and structural provenance

`float-emit01/mandelbrot.ssa` contains `$direct.mit` at lines1990–2607: 618lines,
nine `jnz`, and one `p111_rt_fail`. Two branches are the Nat loop case and its
complementary nonzero case. The sole failure call is their terminal default at
line2605. **None of the seven scalar selections retains a Boolean failure call.**

The selection branches occur at lines2098,2195,2257,2377,2450,2506,2562:
three sign masks, two Bool-to-U32 conversions, and two new/retained coordinate
choices. For the first sign mask, the two arms are:

```
yes: result_tmp = 0; result = 0
no:  nine dead scalar definitions; result_tmp = 4278190080; result = 4278190080
```

The coordinate selections have the same dead prefix, then
`result_tmp = available_payload; result = result_tmp`. Both payloads have already
been evaluated before the outer branch. Their source arithmetic must not be
speculated or reordered merely because this particular source evaluates it early.

The exact source machinery in `float-source01/compiler.bend` explains these
shapes without interpreting generated text:

| Interface / location | Relevant behavior |
| --- | --- |
| `P113DStmt`,44373 | Structured scalar, If, Call, Result, Again nodes. |
| `p112_special_bool`,41710 | True predicate is raw word1 OR packed True; False is its complement. It is not arbitrary nonzero. |
| `p113i_expand`,46904; `p113i_bind`,46896 | Rename all callee locals and replace results with assignments to the caller's destination. |
| `p113j_*` inliner helpers | Preserve multi-result assignment/return structure; do not assume every inlined result is already a single Set. |
| `p113k_scalar_bin`,48180; `p113l_record`,48784 | Track ranges, exact values, and versioned Boolean relations through copies. |
| `p113k_scalar_if`,48192; `p113k_body_if`,48238 | Fold known branches, otherwise propagate branch facts. |
| `p113l_assume`,48798 | Learn raw0/1 subjects through a still-valid relation; deliberately not an untyped truth assumption. |
| `p114s_ranges`,48876 | Commit transformed functions through the existing direct verifier. |
| `p113bq_scalar/direct`,48624/48634 | Recognize only one U64 Set per arm, exactly0/1 or1/0. |

The range pass replaces dead definitions by constants but does not delete them.
In particular, `p113k_scalar_bin` always returns a one-statement body even when its
answer is exact. The range output therefore blocks the exact one-Set matcher.
This is distinct from Phase117's near-neutral removal of an adjacent comparison
normalization: that experiment did not expose these inlined Bool conversions or
arbitrary-payload choices.

There is no persisted post-range P113D object known at audit time. The description
above combines actual emitted structured branches with their exact producer and
optimizer definitions; it is **not** falsely presented as a new serialized IR
dump. The diagnostic module below enables that final confirmation cheaply.

## Transfer evidence and limitations

`broad-emit01/lexer.ssa` has the same folded boxed-Bool machinery in unrelated
functions: `$direct.gen.at` lines2696–2702, `$product.lex`5745–5752, and
`$direct.lex`6267–6274. These are real sites for cleanup, not measured runtime
shares. Unlike the seven Mandelbrot choices, many lexer branches contain calls,
allocation, constructor matching, and ownership operations. Preserve those
branches; deletion of dead scalar definitions does not authorize if-conversion.

Standalone `$direct.b2u` and `$direct.sel.go` still have both raw/packed tests and
a complementary fallback. Their formals have no raw0/1 range certificate. A
general predicate-congruence pass could prove repeated opposite tests redundant
while preserving the raw/packed semantics, but it would require versioned copy
origins or value numbering. It is a larger, separate opportunity and is not
necessary to expose the measured `mit` choices.

## Smallest credible experiment

1. Confirm the exact post-range body using `boolean-path-inspect.bend`. Its
   `p118bp_program(program,names)` reuses a prepared P113AProgram, runs its current
   verifier, and returns only the requested exact P113DFunction data. Alternatively
   `p118bp_request(request,names)` lowers normally. Export only these diagnostics;
   host JSON serialization is transport, with no host compiler transformation.
   Caller names could include `$direct.mit`, `$direct.sel`, `$direct.b2u`, and
   `$product.lex`; the module itself contains no workload names.
   `inspect-boolean-path.mjs API_REPORT SOURCE_MANIFEST FRESH_OUT CASE FUNCTION...`
   authenticates the checked API, source, fixture and prepared Base, calls
   `p88_cache_prepare`, `p86_plan`, then the Bend diagnostic, and pins its exact
   JSON result. It performs no semantic host transformation. Both new files are
   source-reviewed drafts until the root checks the API and runs the harness.
2. Add bounded **backward scalar dead-definition cleanup** after ranges, before
   private emission. Initially delete only unused `N111Set` and total integer
   `N111Bin` operations; retain every Call/Load/Store/Alloca/Offset and every
   ownership/runtime operation. Reuse the existing4096-statement range budget.
   Pass the resulting functions through `p114s_commit`; retain the old body on
   refusal. No new runtime or ownership ABI is required.
3. Measure cleanup alone first. It should expose the two raw0/1 conversion
   diamonds to the **existing** `p113bq` recognizer. QBE already removes dead
   assignments, so reduced `.ssa` size alone is insufficient evidence of benefit.
   This is a possible two-diamond projection benefit, not a predicted direct
   DCE speedup. The other five choices require the next step; three already
   become conditional moves in QBE, further limiting the likely runtime gain.
4. Only then add a narrow branch-arm copy coalescer and payload selector.
   After dead cleanup, collapse `tmp=available; out=tmp` to `out=available` only
   when `tmp` is not live after the arm and widths agree. For two one-Set arms
   writing the same U64 destination, both operands must be constants or already
   available values. Snapshot condition and operands before an overlapping write.
   Compare leaving the clean diamond for QBE with explicit full-width bit-select;
   the latter can regress predictable branches or increase register pressure.

A 20–30minute diagnostic plus bounded cleanup screen is credible, excluding
checked-API queue time. A complete general copy/value-numbering framework is not
credible in that window. Do not weaken verification to fit a timebox.

## Mutation and semantic obligations

- Locals in P113D/N111 are mutable; a name is not an SSA value. Backward liveness
  uses `live_before = (live_after - destination) union operand_uses` for a retained
  assignment. A deleted pure definition adds no operand uses. Self-assignments
  and assignment to a branch condition require the ordinary kill/gen order.
- Recurse into both N111If and P113DIf. Scan the suffix first, give both arms the
  same live-out set, then union their live-in sets and add the condition. Terminal
  Result/Again use their actual vectors. The existing verifier initializes each
  loop iteration from formals, and Again performs parallel formal transfer;
  do not use one iteration's exact facts as the next iteration's entry facts.
- Keep all Alloca declarations initially, since their emission is hoisted and
  buffer verification uses the declaration. Keep all imports even if their
  result is dead; a call can consume, allocate, seal, store, or fail.
- `N_W32` is an ownership category, not a proof of raw Boolean0/1 or zero upper
  bits for every Term. Packed True and RFC/location bits must survive. An
  arbitrary condition is normalized with the same low-word truth semantics as
  existing emission; arbitrary U64 payloads retain all64 bits.
- Versioned relations use both subject and predicate epochs. A new definition,
  load, call result, or join can invalidate a relation; do not transplant old
  facts to a copy-renamed or redefined subject without a proof.
- If a newly exposed selection includes branch-local arithmetic, FP conversion,
  divide/modulo, memory access, or a call, refuse it. This experiment needs no
  speculation and no relaxed effect/failure ordering.

Use existing independent scalar-fact controls (78groups, native Bool/Nat fixture)
and ordinary full-output controls. Add analysis cases for a live overwritten
temporary, source/destination overlap, branch-only definitions, terminal-arm
joins, high64-bit payloads, mutable predicate redefinition, and an effectful arm
that must remain unchanged. Native tests must be ordinary valid source, never
synthetic malformed IR. Compare the original mit plus unrelated lexer and scalar
selection controls; proceed broadly only if hot machine work actually changes.

## Recommendation and identity

**Inspect, then try dead-definition cleanup; defer new Boolean facts and global
if-conversion.** The main value is opening composable structured optimizations and
reducing intermediate work. No runtime gain or aggregate speedup is claimed.

SHA-256 identities:

- float-source01/compiler.bend:
  `b16a71925e94585b5d66a010a8377a1f6500376de217d90fee7eb2e8fcb26c08`.
- float-emit01/mandelbrot.ssa:
  `5611743852ca588fcdeaf09371f3e2e14f62b76ef3ee9f785685fbcdb7266401`.
- broad-emit01/lexer.ssa:
  `e87b4871860c2253f85e854503dcf9b79c30a5e1af0ad5097fbc834069444bc7`.
- Diagnostic module at creation:
  `34c0f1520721f2b29c0efe9049f07285450aea0bd77504d09c55726f10ec3235`.
