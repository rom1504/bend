# P117-005 — optimize the unchanged cached runtime more strongly

Post-versioning samples put124/439 fold leaves in blk_new (28.2%); only8 remain
in term_drop (1.8%). Allocation/fill is now worth a cheap separate experiment.
The upstream frozen C programs use Clang-O3; the QBE cached runtime uses GCC10-O2.

Compile the exact capability-adapted runtime source with GCC10-O3, retaining
-ffp-contract=off and all ABI/source bytes. Link the exact already-verified QBE.
Start with eight array, ownership, closure, numeric and float programs using the
unchanged original oracle/counts. This changes one cached native-runtime product,
not Bend lowering or a per-program C compilation. Preserve the O2 candidate.

If it has meaningful transfer without material regressions, run the broader
runtime and ordinary controls. Otherwise retain the failure and defer it. Never
credit a runtime build-policy gain to a new Bend transformation.

## Outcome

Global O3 improves small fold but regresses tree/map cases. Allocator-only O3 retains the point gain and passes405 broad observations, but broad speedup changes only1.25185→1.25830, with new2–4%slowdowns. Both runtime policies remain unselected; no new ordinary/native qualification campaign is warranted for them.

[Complete report](../../implementation/phase117/README.md) retains exact receipts and limits.
