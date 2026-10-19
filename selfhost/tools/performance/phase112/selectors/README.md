# Optional general selector specialization

This source-only candidate connects an existing semantics-level rewrite to the
direct QBE path. It is not selected by production module lists and has no new
target qualification yet. It imports no C worker emitter or alternate runtime.

The checked `NR_Request` producer already stores erased native definitions.
`nbc_definition` obtains their original erased body through `nc_source_body`;
the latter also unwraps a `NativeStaticBody` fact to its original erased fact.
The mature Phase99 rule returns an ordinary `KTerm`. The original P111 call path
never invokes it: all exactly saturated references become `NCall`, including
small closed branch selectors with statically known lambda actuals.

The adapter asks that same rule before constructing the generic call. On success
it sends the rewritten term to the existing `p111_lower`; on refusal it calls an
exact renamed copy of the original `p111_ref_app`. No name-based specialization,
whole-book rewrite, source checker change, or ownership exception is added.
The ordinary beta and sharing rules now see the literal branch bodies directly.

## Preserved boundaries

- Bang references and non-saturated calls use the original fallback.
- The mature gate requires 1–4 actuals, a literal lambda actual, and enough room
  for the reserved 64 fresh identifiers (`n < 4294967231`).
- The callee is a closed, at most 32-node lambda/application/nullary-match shape.
  References, free variables, field destructors and other forms are refused.
- Literal arguments must satisfy the original use-count guard in every exclusive
  branch. Existing `nd_comb_fresh` checks body, arguments and live environment.
- Nonliteral actuals remain ordered strict lets, including unused arguments.
  Literal branch bodies remain delayed; selected branches can return closures.
- Successful lowering advances the fresh supply by exactly 64, as the C adapter
  does. Constructor calls, retains, disposal and continuation ownership remain
  the responsibility of the unchanged structured lowerer and runtime.

Reusing the syntax rule is not a proof that its QBE integration is correct.
Checked source, demand/error observations and native captures need separate
qualification. The structural segment verifier is not an ownership proof.

## Composition and fast checks

Add `original.bend` and `emit.bend` after the frozen Phase112 modules; apply
`entry.bend` as the final `p111_ref_app` override. The new prefix is `p112b_`.
The source-only `original.json` authenticates the exact renamed fallback.
Existing static/liveness/accessor/worker modules do not change this entrypoint.
Use the existing Phase112 source composer; do not edit frozen source in place.

Export `p112b_guard` and `nbc_select` for the bounded raw-term controls:

```sh
node selfhost/tools/performance/phase112/selectors/controls.mjs \
  CHECKED_API FRESH_REPORT.json
```

The harness independently interprets strict lambda/matcher terms to compare the
original and selected terms. It covers true/false choices, lazy unselected
failure, selected effects, captured values, returned closures, strict unused
arguments, evaluation order, nonliteral branch actuals, and explicit refusals.
Synthetic `Probe`/`Abort` appear only in actual expressions. These controls do
not claim native ownership correctness.

For source/native controls, reuse the checked baseline and candidate API on:

1. `fixtures/nt-choose.bend`: exact compiler `nt_choose` declaration.
2. `fixtures/branches.bend`: previous Phase99 behavior fixture, chooser renamed
   to `nt_choose`; captures, returned closures, both branches and effects.
3. `fixtures/strict-unused.bend`: required native Nat overflow, never success.
4. `fixtures/fallbacks.bend`: nonliteral actuals, callee reference and field match.
5. `fixtures/name-key-micro.bend`: original compiler `name_key` algorithm with
   its chooser renamed; preserved 200,000-iteration input-controlled workload.

Compare complete stdout/status/stderr, not just success. Inspect structured IR
closure/allocation/apply/segment counts before paying for a full compiler image.
Use the same frozen prepared request for both API variants. Only benchmark an
acquired native compiler after the small semantic and mechanism gates pass.

## Expected information and limitations

Historical Phase99 C evidence removed two closure allocations, an extra retain
and selector transfer from the `name_key` kernel (0.11421 to 0.06338 seconds in a
short screen). That is a mechanism precedent, not a prediction of QBE speed or
a whole-compiler speedup. Runtime profiles must establish how much of the present
compiler is affected. Source/lowering growth and compilation overhead can offset
the runtime benefit; count and time these separately.

Larger NF/NQ/HO workers mostly return C-specific representations, so importing
them wholesale is not this experiment. The next separate low-cost candidate is
`nd_comb_try` for bounded linear partial-application combinators; it does not
admit nullary matches and has different application-timing premises. Prove the
selector experiment before broadening the rule or building a new generic IR pass.

Evidence: `implementation/phase99/discovery-restart.md`,
`implementation/phase99/README.md`, and
`selfhost/tools/performance/phase99/branch-closures/helpers-v2.bend`.
