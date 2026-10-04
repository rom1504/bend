# P45-019: derive primitive fences under the existing import contract

Status: isolated collector-only candidate over frozen worker18; independent static review, checked build, eight maintained suites and the fresh 40-observation controller pass; the first six-point timing screen is mixed and full qualification is pending. This does not admit nullary roots, reopen acyclic alias-only entries, change the runtime, or relax the supported host contract.

## Why reconsider P45-012?

The earlier [P45-012](P45-012-primitive-capabilities.md) experiment conservatively retained every one of 54 primitive descriptors at each private entry. Its proposed collector reduced that fence to operations present in the complete proved graph. A hostile **pre-import** `Array.prototype.every` replacement could observe the number of guard checks, so the earlier investigation withheld promotion under a deliberately broader host model.

The subsequent contract audit established that standard host intrinsics at module initialization were already required before this phase:

- `selfhost/docs/ARCHITECTURE.md:152`, introduced in commit `88619d9c` on 2026-10-01, states that initialization assumption while preserving exact entry, public layouts and the existing ABI.
- `docs/PHASE42_GENERATED_JS.md:123–129`, commit `f8e8ecc5` on 2026-10-03, explicitly preserves supported post-import mutation behavior and excludes arbitrary callbacks installed before import.

These are existing contract statements, not new conditions invented to admit the optimization. The pre-import counterexample and P45-012's rejected/held evidence remain valid for that broader model and remain preserved. This new experiment qualifies the collector against the documented supported domain. If arbitrary pre-import host shims become a future supported feature, it needs a separate compatibility design and tests.

## Exact isolated change

Worker18 is the causal predecessor. Change one call in `j_instance_root_guarded_mode` from the all-family primitive list to the existing bounded collector, reusing its prior helper bytes unchanged. The collector scans:

1. Every original source body referenced by the exact instance rows.
2. Every body in the complete successful `JPure` graph supplied to emission.

It visits all children and both taken and untaken branches. Name recognition is conservative even in erased or type-bearing subterms, so some unnecessary fences can remain. A missing/invalid proof or the aggregate 131,072-node budget being exhausted returns the original full 54-name list. There is no emitted-text recognition, benchmark selector, cache or cross-entry reuse.

The isolated patch changes only `jpure.bend` and adds 46 physical lines. Patch SHA-256: `6e4c770d7ad71ae28641b9e788550a33728ace82eda6b39d6df188e990add73f`. The reused helper SHA-256 is `2908cf1fcb353528c518cfca7b7ea9f34d9ca28adad08fbf1eabef347ce2d7ff`. The patch and before/after identities are acquired from `/tmp/phase45-used-primitives19/receipt.json`. No prior snapshot or helper is rewritten.

## Guard and representation audit

The exact source dependency list, native dependency list, `regionHostGuard`, `stringHostGuard`, scalar input checks and public descriptor checks retain their existing code and order. Under the documented standard-intrinsics initialization domain, the full host checks reject supported post-import protocol changes before the dependency scan. A removed unused primitive fence does not authorize a used primitive replacement or skip a source/native dependency.

The proof inputs precede private IR simplification and Number-Nat rewriting. Consequently, `U32.to_nat`, `U32.from_nat`, `U32.shln` and `U32.shrn` remain visible even when their emitted operations become `JWNumberOp`. `Nat.add`, `Nat.sub`, `Nat.is_lt` and `Nat.divmod` remain protected by the unchanged native list from the pre-rewrite graph, even when their execution is emitted directly.

Nat Zero/Succ, constructor projections, case tests, tuple/String/Char construction and private overflow helpers do not introduce new `G` primitive reads. They retain their existing nominal type/constructor proofs and captured host, Number/BigInt and error-observation protections. This audit does not assert that source purity alone makes host operations inert. The current successful graph, explicit native whitelist, full host guards and existing Error reentry protocol remain necessary.

## Fresh falsifiers and decision

The original P45-012 fixture used nullary entries, which worker18 deliberately excludes. Replaying its observations would not demonstrate activation. A fresh positive-arity successor uses renamed roots, exact values, a real recursive private Number-Nat path, both arithmetic branches and separate instrumented entry counts. It must retain the supported post-import controls for used primitive replacements/getters, dependencies in untaken branches, unused primitive changes, and restoration between observations. Full host/String guards must remain present and active.

The callback agent authored `fixtures/primitive-capabilities-positive-v1.bend`, `primitive-capabilities-positive-catalog-v1.json` and `primitive-capabilities-positive-controls-v1.mjs` under `selfhost/tools/performance/phase45`. The new 40-observation controller and isolated compiler patch both pass independent static review; target execution remains pending. Retain existing Number-Nat, source/public mutation, constructor, stack and Error reentry controls. First compare worker19 directly against worker18 on a cheap fresh screen, including the maintained fast five canaries and representative recursive gains. Treat declaration/guard counts as mechanism evidence and ordinary uninstrumented timings as performance evidence.

An optional subsequent experiment could re-enable the former acyclic alias admission while holding this reduced fence constant, using a separate candidate based on worker17b plus only this collector. That would test whether guard cost explains the observed acyclic-helper regression. It is not part of worker19, is not implemented here, and cannot be presumed faster: the full host checks and fixed public-entry overhead remain.

## Executed worker19 result

Worker19 built in about 52s and passed the eight maintained suites. The first positive-arity fixture selected a preexisting specialized backend, so its controller correctly failed the activation assertion before recording boundary observations. That attempt remains preserved as `primitive-positive-controls19/report.json`; it is not evidence against the new guard collector and is not counted as passing coverage.

The v2 fixture adds an independent erased conduit so the intended contextual worker actually executes. Its newly acquired controller passes all 40 supported post-import observations in `primitive-positive-controls19-v2/report.json`. This successor is separate from the original files and receipts.

The fresh six-point comparison against worker18 completes in 44.748s. Baseline/candidate ratios are 0.9092× Map, 1.0743× records, 0.9528× complete generic row, 1.0563× lexer, 1.0179× active ray and 1.0565× Unicode. The generic-row output is byte-identical, so its timing movement cannot be attributed to a generated-code change. The screen provides mixed, modest signals rather than a universal speed gain; do not pool it with earlier candidates or use it as a full-corpus result. Exact medians and drift observations remain in `runtime-worker19-vs18-six/report.json`.

[P45-020](P45-020-acyclic-reentry-ablation.md) then tested restoring acyclic public admission while retaining this collector. That separate candidate remained 5.1548× slower on the complete generic row and was rejected. Shortening primitive fences alone does not justify removing worker18's profitability gate.
