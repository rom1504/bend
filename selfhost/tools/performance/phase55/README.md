# Phase55 compiler-image performance methods

See the [design](../../../../design/phase55/direct-compiler-image-throughput.md),
[report](../../../../implementation/phase55/README.md) and
[compiler-image guide](../../../../docs/self_hosted/compiler-image-generation.md).
This directory contains reproducible experiment methods; production changes are
in `src/back/js/direct/model.bend` and `host.bend` only.

| Method | Purpose |
|---|---|
| `semantic-arity-controls-v3.mjs BEFORE AFTER NEW_OUT` | Real checked/completed/annotated sources, signed matcher residuals, old fallback and source refusals. V1/V2 preserve failed harness assumptions. |
| `semantic-host-controls-v1.mjs BEFORE AFTER NEW_OUT` | Eight exact-wrapper/runtime controls, including Nat callbacks/arrays and aggregate-budget fallback. Synthetic type cases are private-helper policy controls. |
| `bootstrap/emit-split.mjs CONFIG GENERATOR NEW_OUT [TINY_REPORT]` | Fixed subject versus independently pinned generator; same emission stages and export policy. Full run requires tiny split/unsplit equality. |
| `bootstrap/driver-probe.mjs CONFIG EMISSION source\|direct NEW_OUT` | Ordinary loader/driver route using isolated caches and exact source-oracle binding. |
| `bootstrap/compare-driver.mjs SOURCE_REPORT DIRECT_REPORT NEW_JSON` | Exact join of eight observations and JS/C output bytes. |
| `semantic-launch-plan-v1.py` and `run-retention-plan.py` | Bind and serially execute the existing 18 retention gates; individual commands own their guards. |

Use the bounded supervisor and exact Node/CPU options in the adjacent plans.
Do not nest resource guards. Native validation needs the recorded Clang
variables and must precede installation because its oracle binds the installed
Phase54 release. `retention-plan.md` documents all scopes and command fields.

Frozen fixed-source plans live in raw `bootstrap-plan01/`; the independent
own-source plans live in `bootstrap-own-host02-plan01/`. The raw archive also
contains checked attempts, configurations, successes and failures. Plans are
not execution receipts. The publication index identifies completed results.
Rebind historical absolute paths to a new checked attempt for a new checkout;
keep original consumed producers and outputs immutable.

The per-export v2 diagnostic was prepared but not executed. Phase-level timing
identified the host-signature opportunity, and complete-module equality gave a
stronger retention check without another full diagnostic run. It remains a
conditional investigative method, not evidence of measured per-export costs.
