# Wide-return failure: product facts disappear before the helper call

Read-only source/QBE audit. No targets or compiler transformations were run.
The exact selected compiler is `dispatch-source02` / `dispatch-api02`; the
workload result is `store-wide8-emission02/program.ssa`, SHA256
`2eeaad042340e8127afa60ac2a1dd2b259ca2d8980d194291d03021e37986ebe`.
The existing [shape gate](wide-return-qbe-gate.json) is accurate: eight-word
getters are present and locally avoid Store boxes, but whole consumers do not.

## Concrete boundary

In `$p173scc.6`, arm10 receives the Store's seven separate fields, then:

- line244195 constructs Store7 (`p111_rt_ctor`, constructor165, width7);
- line244341 calls `$direct.p173s_edge` with that boxed Store and scalar index;
- line244349 takes the returned boxed Return8 before continuing locally.

Arm33 repeats the same sequence at249035,249210 and249218. These are actual
emitted instructions, not source constructor counts. The product getter
`$product.p173s_edge` is also emitted with seven Store argument words plus index
and eight result words. Therefore neither the getter's availability nor the
eight-result ABI is the missing capability.

The corresponding source computations are the Boolean branches in
`store-compact-wide8.bend:p173branch_42` and `p173branch_51`: each selects a
producer, then passes its Return to an immediate local consumer. The Store
box appears **before** the Boolean branch, rather than being required by the
source's immediate Return consumer.

## Source explanation

1. `nq_entry` supplies the Store as an `NQBundle`. `nd_beta` inserts a let for
   every non-Var argument, including that already evaluated bundle.
2. `p113px_known` retains a virtual let-bound product only when
   `p113p_bindable` proves both maximum and minimum use counts equal one.
   Otherwise `p113px_boxed` materializes it. The QBE demonstrates this
   materialization at the branch owner's entry.
3. Once the helper receives an opaque Var, `nq_args_known` refuses the Store
   parameter shape: it accepts NQBundle/Ctr/NCtr, not Var. Consequently
   `nq_call_shape` does not expose the helper's known Return8 result to the
   surrounding let. The let receives an opaque one-word result target.
4. The selected `product-arguments-v3.bend:p173ab_call` intentionally bridges
   only when the wanted result is already a known product matching the
   callee's result. For an opaque local result, it keeps the successful boxed
   call. This was deliberate to preserve old ready/dependency behavior; its
   control suite explicitly tests the opaque-target fallback.

Thus the bridge repairs product-result *failures*, but cannot repair the case
where earlier shape loss made the boxed call look successful. Broadening its
last condition alone would still unbox an already constructed Store and might
rebox Return8 for the opaque target, without eliminating the main work.

The precise entry refusal needs one retained-term diagnostic. A likely cause is
`nq_min_uses` counting the implicit impossible/default tail of an exhaustive
Boolean matcher as zero: it takes a minimum over Mat branches and has no
checked exhaustiveness fact. Both ordinary source branches consume Store once.
This is a source-grounded hypothesis, **not a measured minimum-use result**;
capture the actual predicate values before attributing every box to it.

## Smallest useful next change

First diagnose the two actual entry bindings: record shape, maximum/minimum
uses and branch form before product lowering. If the hypothesis holds, preserve
the bundle through checked branch structure, with explicit correct field drops
on any genuinely unused/error exit. Do not globally disregard minimum uses or
assume all matcher fallbacks are impossible. Retain sharing/escape refusal and
the independent ownership verifier.

This keeps Store fields live across a whole branch→helper→return computation;
it addresses the earliest loss rather than adding another getter adapter. Test
exactly-once branches, a real zero-use branch, error exits, aliases, effects and
unknown callees. The immediate structural gate is removal of the Store7 ctor
and corresponding Return8 take at the two cited boundaries, followed by full
native output equality. If the bundle remains boxed, do not build the machine
program merely because a flat getter still exists.

The alternative is a readiness-aware owned-argument/result plan for opaque
calls, but it must propagate the result shape into the binding decision before
emission and retain a sound fallback when the flat callee is not ready. That is
larger than relaxing the current adapter. No runtime benefit or cold-build
speedup is established by this audit.
