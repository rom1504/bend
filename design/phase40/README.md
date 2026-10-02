# Phase40: more validated improvement per hour

Authorized 2026-10-02; campaign start **00:18:49 UTC**. Starting commit
`e95b1c9ed2542d34ede62f85a757e4f3adc0f1fc`, installed Phase39 checked05 API
`04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f`.
Upstream stays `018751270e800bc222a93dad7f257083ee53a5f7`.

The user requests the proposed efficiency changes and compiler experiments,
with design, implementation, report, commit and push. This plan freezes the
decision rules before new timing. Outcomes belong in the
[implementation report](../../implementation/phase40/README.md).

## Objective and measured boundaries

Improve execution of generated programs while retaining correctness and keeping
added compiler concepts and lines proportionate. Measure elapsed campaign time,
bounded job time, abandoned work and integration costs. Phase39 took about
150 minutes by the user's observation; its documented final measurements cover
at least 24.4 minutes, not a complete attribution of the other time to reasoning.
This campaign is not a controlled model comparison: different work, tooling and
prior knowledge prevent claiming a Sol/Astra speed multiplier from its duration.

The initial estimate is 90–110 minutes for comparable work, not a deadline that
permits incomplete validation or an optimization guarantee. Each prototype gets
30–45 minutes of investigation before a concrete stop/replan decision. A result
may be rejection with a reproducible counterexample or an informative timing.
No unconditional architectural rewrite is authorized by an untested forecast.

## Mixed team and compact context

- Root coordinates and reviews semantic boundaries; it alone runs heavy jobs.
- Two **Sol 6.1 / medium** agents investigate list and tree components in
  disjoint files. Each receives exact scope, invariants, baseline, output and
  stop condition instead of the full conversation history.
- One **Sol 6.1 / low** agent extracts evidence and reuses the measurement and
  reporting tools. Low effort is for bounded mechanical work, not a substitute
  for reasoning about demand, host mutation, aliasing or error order.
- Reassign an available implementer to lexer after a first proposal is ready.
  Agents submit small proposals; root and a different agent review survivors.
  No simultaneous edits to shared backend files.

Use one append-only campaign event log and derive status/timing summaries.
Separate wall clock spans from summed concurrent agent time. Tool durations
exclude time outside their recorded boundary. Unclassified time stays
unclassified; do not infer token cost or model latency from it.

## Experiments, in order

1. **Direct unfused lists.** Investigate producer/filter/map/fold over materialized
   tagged lists. Avoid generic calls inside a proved component while preserving
   all intermediate values. This benchmark is already first-order: do not retry
   the rejected callback specialization under a new name. Independent complete
   list and sharing checks precede claims based on scalar checksums. Estimated
   conditional benefit: 10–35% less list time; 1–2 hours including integration.
2. **Remaining tree work.** Reuse the existing worker framework for flow and
   leaf/constructor continuations. Separate leaf-only, helper-only and whole
   component changes where useful. Preserve full tags, irregular shapes,
   aliases, guard scope and deep-stack behavior. Estimated conditional benefit:
   5–20% less tree time; 1–2 hours including integration.
3. **Lexer component.** Study one complete step/continuation with compiler-owned
   forced fields and the original demand order. A guard per character/token is
   not an assumed win. Try small existing lexer inputs before the full historical
   point. Estimated conditional benefit: 10–40% less lexer time; 2–4 hours for a
   surviving implementation, with early rejection allowed on evidence.

These workload-specific forecasts are hypotheses, not additive suite gains.
Lists/trees have priority for implementation reuse; lexer receives a concrete
investigation even if earlier mechanisms are rejected. Numeric guard allocation
and Map/String kernels remain the subsequent frontier, not automatic extra
subsystems in this campaign. Fusion needs a successful unfused denominator.

## Controlled experiment loop

Repackage exact Phase39 checked output and pinned TS as the new portable
baseline; preserve acquisition receipts. Run comparison roles freshly together.
Use the unchanged Phase37 catalog of 45 points/23 sources and existing runners.
Historical medians are not denominators. New independent semantic source shapes
are named before timing; old holdout families are exposed, not unseen evidence.

Saved-output prototypes establish a mechanism cheaply but cannot be installed
or described as compiler-produced improvements. Every screen includes an
unchanged-module control. Use existing 20-second rejection screens, then
60-second confirmations for survivors; separate profiles from clean timing.
Do not repeat a null result indefinitely or select favorable reruns. Prototype
controls must cover values, demand/error order, aliasing and guard fallback.

Only a promising safe prototype earns compiler integration, checked B1 and
actual-emission controls. Reuse existing admission analyses, representations
and owner gates before adding a compiler type/module/runtime helper. An absent
declaration or failed admission is caught before broad execution. Record source
lines, definitions, types, modules, generated bytes and checked-request costs.

Root runs local CPU-intensive work serially with Node24.18, CPU3, Node heap
1024 MiB, process-tree RSS ceiling2048 MiB, available-memory floor2048 MiB and
explicit deadlines. Existing lock-owning tools are never wrapped in another
runner holding that lock. Avoid large recursive inventories and full API output.

## Acceptance and consolidation

Freeze the selected source before broad timing. Run all45 points in bounded
groups once, retain uncertainty and negative controls, and confirm only new
unresolved concerns. Run applicable inherited and new semantic owners, frontend
and backend integration, normal checked compilation costs, and installed plus
relocated CLI checks before release. Preserve known shared failures; agreement
does not establish universal correctness or full backend/GPU conformance.

Public partial/raw/overapplication, erased arities, host/dependency mutations,
reentry, error order, sharing, constructor field demand and deep tail behavior
remain obligations. A fast checksum result cannot override a failed boundary.
No unsafe benchmark-specific pattern, special treatment of function names, or
prototype patched into an installed artifact is acceptable.

Retain actual gains, reject regressions or unsafe extensions, and report costs
with benefits. A campaign with only rejected optimizations leaves the installed
compiler unchanged and honestly reports zero delivered runtime improvement.
Reuse report schemas and collectors rather than creating another custom audit
layer. Keep small experiment records and one authoritative result table.

## Preservation and publication

Preserve all103 unrelated starting files and closed raw Phase35/36/37/39 trees.
Only new Phase40 paths may hold new experiments. Track scripts, fixtures,
commands, small results, selected modules and failures; archive large evidence
once at closure with reopened verification. Link compiler documentation from
README, update the experiment ledger/frontier, commit and push within standing
authorization. Do not post a PR comment.
