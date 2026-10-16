# Phase102 backend qualification bridge

The private candidate is not qualified merely because its checked JavaScript API
or application screen succeeds. The final image still needs the unchanged
Phase98 native-chain gates, plus evidence for the new lowering rules. The
[coordinator plan](native-qualification-plan.md) retains those gates and their
original resource bounds.

This bridge uses the old collector's schema so the collector can remain frozen.
It does not rename old source evidence as new evidence. Its final receipt can
become complete only after the real final native stages reproduce the new
controls. That receipt also remains `imageQualified: false`: the independent
image collector makes the later qualification decision.

## Exact source correspondence

The offline [source audit](../../selfhost/tools/performance/phase102/qualification/audit-source.py)
compares the pinned installed Phase98 source `2a72bbdc…` with the final candidate
`8b895aec…`, replays every recipe edit and reverses them. The completed raw receipt
is `selfhost/build/phase102/authority-source-audit01/report.json`, SHA
`c1e7316d4e4434f1af368ce46c6c0b427efc6c3d0763a5f4875d7a0efb607345`.

- Fourteen of the sixteen authority declarations remain byte-exact.
- `nf_plan_scoped` now routes its existing plan through `nfo_plan`.
- `ns_compile_named_scoped` adds the local-worker route only with observer
  permission and no reachable bang calls. Its original fallback remains.
- The audit enumerates sixteen changed and sixty-three added function
  declarations, with all 159 type declarations unchanged.
- All five definitions in the old permission-proof package and all eight in
  the old tag/comparison package remain exact. Their thirteen already checked
  safe laws retain their original source and proof identities; no new kernel
  execution or native ownership theorem is claimed.
- The reachable helper/type closures of `no_effect_definitions`,
  `no_effect_terms`, `ns_source` and `noa_below` remain exact, together with their
  pinned Base dependency. This supports narrow inheritance of eighteen finite
  permission-helper Booleans and eleven origin decisions.

The closure scanner is a conservative lexical correspondence check, not a Bend
semantic proof. Independent review also checked this frozen source's unchanged
law declarations. Changing an audited body, authority route, type or supporting
dependency requires a fresh audit; the old source hash is never replaced inside
a historical receipt.

## Fresh permission and raw-input checks

`authority-controls02` used the existing final checked API from `reuse-api02`.
No further compiler API build was needed. Its execution method preserves the
original Phase98 authority assertions, changing only the permitted output
directory and explanatory comments. The plan pins both imported API files
before execution; the historical comparison is explicitly the original
permission experiment API, not the installed native compiler.

The target completed in 6.639 seconds. The independently reviewed offline
[consumer](../../selfhost/tools/performance/phase102/qualification/consume-authority.py)
reread source/API identities, raw commands, outputs and provenance. It closed
seven cases in `selfhost/build/phase102/authority-consumed01.json`, SHA
`5eaf287bc89b68751c9cb8a71517de1902895b137fa2ec977abfaa58930d50a5`:

- The original real-IO, generic-array and schema-refusal cases preserve both
  checked entry paths, explicit-false entry behavior and raw flags-off behavior.
- Both cases that use providers reject changed provider bytes. The schema-only
  case has no provider and makes no provider-mutation claim.
- An unknown provider keeps optimization permissions off.
- A forged observer context remains inert; internal observer-return and
  observer-loop nodes remain rejected as raw source.

Only the forged-context C is reused as behavioral evidence: its complete C is
byte-identical to the original unpatched native product, whose complete `7n`
stdout and empty stderr were independently reread. The three positive user
programs still require the separate final native five-source gate.

## New mechanism controls and final native stages

The required new control set contains the twenty-four frozen Phase102 cases
covering TRMC construction, aliasing, late failure, refusals, local calls,
observers, String boundaries and active bang calls. It also includes three
unchanged Phase99 branch controls: captures/selected effects, constructor
composition, and strict evaluation of an unused overflowing argument. Their
complete stdout/stderr/exit oracles are pinned before the new runs.

The [backend consumer](../../selfhost/tools/performance/phase102/qualification/backend-bridge.py)
requires all twenty-seven IDs, all specified worker counts, all three checked
product roles, and each final native B1/B2 emission. It checks exact native
stage C and diagnostics, then authenticates either an identical-C reuse of
complete executions or every fresh execution. Completed results must match
the unique obligation set; a duplicate result cannot conceal a missing case.

The original final-image selections remain unchanged: real IO, generic array,
schema refusals, all 1,444 String corpus pairs with fourteen observations each,
and the owning origin-swap refusal. Their original plans and expectations are
preserved verbatim. They complement the new mechanism controls and do not
replace live/cache controls, 45 broad semantic programs, 69 native conformance
fixtures per stage, the independent self-source reference or the B1/B2 fixed
point.

At this checkpoint, the source correspondence and fresh authority checks are
closed. Final native mechanism inheritance and the remaining image gates are
pending. No installed selection change or full compiler qualification is
claimed by this report.
