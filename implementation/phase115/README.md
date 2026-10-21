# Phase115: reusable optimizer plans and bounded policy search

The experiment makes four-policy emission **30.3% shorter geometrically** across
six existing workloads, including fresh plan preparation. It does **not** find
faster generated programs or establish recursive research acceleration. A smaller
follow-up preserves the default policy and removes a repeated negative query:
**4.15% shorter full warm emission**, with 17 added source lines and exact QBE.
Neither experiment changes the installed compiler or qualified native images.

[Design](../../design/phase115/reusable-plans-and-policy-search.md) ·
[Exact results and samples](results.json) ·
[Reproduction](../../selfhost/tools/performance/phase115/README.md) ·
[Evidence](evidence/README.md).

## What was implemented

All compiler logic remains Bend. A checked experimental API appends immutable
`P115Context`, `P115Menu` and `P115Prepared` representations to exact Phase114
source 02. Existing planners establish legality; a numeric policy selects an
existing renderer. The host transports source/results and scores measurements.
No host code changes IR, proves ownership or emits QBE instructions.

Complete direct workers precede all four policies:

| Policy | Remaining route preference |
|---|---|
| 0 | H, R, G, generic; current behavior retries a rejected H |
| 1 | R, G, H, generic |
| 2 | H, generic |
| 3 | Generic/fused |

H is the bounded multi-continuation recursive region; R/G are its earlier narrow
recursive alternatives. Generic/fused emission remains the supported fallback.
The baseline engine computes plans during each policy evaluation. The new engine
computes all legal alternatives once and retains them in a request-local value.
The plan is bound to its original immutable context, never a caller certificate.

Both engines share frontend, lowering, original final verification, indexes and
common private/data rendering. After one disclosed warmup, three rotated rounds
compare identical policies. All 144 measured complete-QBE comparisons pass
(6 cases × 4 policies × 2 engines × 3 rounds); warmups also match. Policy0 agrees
with the untouched Phase114 API. Thirty-two independent truth-table controls
cover every Boolean legality/policy combination. Their route function remains
[byte-exact in the final source](comparator-review.json).

## Measured planning and search cost

Seconds below are medians of a complete four-policy emission sweep. Cached cost
includes new alternative preparation each sweep. Output materialization and
checking, common setup, builds and runtime evaluation are separate costs.

| Input | Partition | Original planning | Retained plans | Less time |
|---|---|---:|---:|---:|
| tree-bitonic | Training |1.304|0.922|29.3%|
| list-pipeline128 | Training |1.033|0.718|30.5%|
| expression128 | Training |1.099|0.700|36.3%|
| lexer | Evaluation |1.484|0.944|36.4%|
| local-pair | Evaluation |1.240|0.966|22.1%|
| active-ray256 | Evaluation |1.990|1.469|26.2%|

Training geometric reduction is 32.1%; evaluation 28.5%; combined 30.3%, equivalent
to 1.435× throughput for this emission component. Evaluation inputs were excluded
from the selection rule but are previously seen programs, not blind research
holdouts. Three rounds and one machine do not establish a broad speed guarantee.

Across all six, the sum of sweep medians falls 8.150→5.718 s, saving 2.431 s.
But common preparation measured about 64.68 s, machine acquisition took 8.73 s, and
the independent execution campaign 37.66 s. A first search therefore pays costs
far larger than this saving. Adding those observed common costs to the sweep
medians gives an illustrative saving of roughly 2%, not 30%. This accounting is
not a measured pair of end-to-end research campaigns; imports, warmup, reference
comparisons, report IO and agent work also matter.

## What the policy search found

Two selection rules were recorded before native timing in
[P115-002](../../experiments/phase115/P115-002-policy-quality-and-cost.md).
Compilation-first selection admits only policies with exact policy0 QBE on all
training inputs, then requires at least 10% less legacy emission time. Policies 0
and 2 qualify; policy2 wins with 37.2% less training emission work and 37.7% less on
evaluation inputs. Its complete QBE is identical on every one of the six cases.
This is a scoped planning result, not authorization to remove R/G everywhere.

Program-first selection requires at least 3% better training runtime and no case
more than 3% worse. It retains policy0. Training runtime ratios versus policy0:

| Policy | Runtime ratio | Interpretation |
|---|---:|---|
| 0 |1.000|Current policy retained|
| 1 |1.040|Worse on list and expression|
| 2 |1.006|Same QBE/binary as 0; timing variation|
| 3 |2.178|Cheap to compile, much slower generated programs|

The unchanged Phase111 builder builds 18 distinct products, sharing exact
policy0/policy2 products instead of building 24. The unchanged Phase112 evaluator
checks all 90 observations (six cases × five roles including upstream × three rounds)
using the original sources, oracles, 50ms profile, flags and counters. All pass.
The new authentication adapter explicitly identifies the new producer; it does
not claim these receipts passed the older producer-specific binder. Build flags,
source/API/runtime identity, policy0 reference and exact per-policy engine outputs
are checked before binding. No benchmark definition or correctness oracle changes. Final matrix03 also
requires every product to equal its matrix02 predecessor, allowing reuse of the
existing machine measurements without another identical build/run campaign.

## A smaller useful compiler change

Caching every alternative is unnecessary for ordinary one-policy compilation.
The original H-first path can retry H after R and G also refuse. Its inputs are
unchanged and the query is pure. The follow-up keeps the first negative decision
in control flow: try the original R and G, then the original generic fallback.
R/G legality, precedence, ownership and stack behavior remain unchanged.

The optional overlay replaces one definition and adds two helpers: source grows
50,590→50,607 lines (+17), 2,306,979→2,307,826 bytes (+847). It introduces no cache
or type. Candidate source SHA256:
`7279b8d133b9cb03f9f34fe5dd547e3616e4790e647ef73ff0963bd2da7b448a`.

Five paired rounds after warmup time the **complete emitter**, including common
index/private/data work, on the same checked IR. All 60 measured outputs remain
byte-exact to policy0's already built and executed QBE. Thus existing machine
execution evidence applies to these exact products under the same runtime and
toolchain; no duplicate build is needed.

| Input | Original emission s | Candidate s | Less time |
|---|---:|---:|---:|
| tree-bitonic |1.055|1.046|0.9%|
| list-pipeline128 |0.628|0.550|12.4%|
| expression128 |0.587|0.567|3.4%|
| lexer |0.842|0.847|−0.6%|
| local-pair |0.736|0.688|6.5%|
| active-ray256 |1.312|1.291|1.6%|

Geometric reduction is 4.15%; summed medians fall5.160→4.988 s (3.33%). Small
individual differences may be noise. This is hosted warm emission, not total
compilation latency, native N1/N2 throughput or a new self-host qualification.
Keep the overlay as a small candidate for the next justified integration; do not
spend a full native campaign merely to relabel this limited result.

## Strategic assessment

1. **Current missed opportunity:** decision work is repeated, but it is a small
   fraction of first-experiment cost. Common lowering/emission and independent
   evaluation dominate. The program-runtime gap also reflects missing useful
   representations, not simply choosing the wrong existing policy.
2. **Priority:** retain a narrow policy interface for experiments, use exact
   product identities to avoid duplicate builds/validation, and investigate the
   expensive common work before introducing a general search engine. The earlier
   9,040 unused-private-definition census remains a separate falsifiable candidate;
   this experiment does not remove those definitions or establish their cost.
3. **Distance to self-optimization:** a single compiled Bend optimizer can now
   evaluate several legal policies as data. It cannot invent new passes, learn a
   policy from a history, or automatically rebuild/adopt a better native compiler.
   Both experimental engines were acquired through the checked upstream-hosted API.
4. **Smallest convincing feedback test:** after a materially faster optimizer
   exists, run identical candidate generators and seeds with and without adopting
   it, counting full setup/build/validation costs. Compare equal-work outcomes and
   actual equal-wall-budget outcomes on independent evaluation. Here the finite
   four-policy space is exhausted and program quality does not improve; cheaper
   replay alone is not recursive acceleration.
5. **Architecture:** separate immutable legality facts, policy decisions and
   rendering; use request-local lifetime and explicit source/IR/runtime identities.
   Retain rejected plans as facts where useful. An exact-output archive can reuse
   results only at the authenticated artifact boundary, not treat an old success
   as a proof for changed code. Typed ownership/value facts still need to survive
   lowering before policy search can exploit them.
6. **Stop/defer:** no autonomous research platform, new backend, broad policy grid,
   default global deletion of R/G or full rebuild per candidate. Do not promote
   policy3 for its cheaper compilation while ignoring runtime. Do not install
   the larger retained-plan machinery for a single decision without amortization.

## Failures, resources and status

One agent, no subagents. Started 03:37:51 UTC. Recorded guards total 593.31 s
(9.89 min), including 78.75 s in failed guards; source work, analysis and report
work outside guards are not measured token/agent cost. The final six-case matrix
uses 148.11 s; full-emitter comparison 105.44 s. Peak replay RSS 746 MiB; checked API
acquisition peaks about 1.44 GiB, under the 2 GiB guard. All targets use CPU3,
16 GiB minimum available memory and 64 MiB file limits.

The first API check rejects an invalid nested match after 2.65 s; a helper fixes
binder ordering. The first replay adapter uses a historical array renderer;
local-pair's exact-reference check rejects it before machine execution. A new
source/API/manifest/replay version calls the actual qualified renderer; all six
are rerun. Failed receipts and source snapshots remain. Final source review also found an
extra direct-signature lookup in the legacy
policy0 wrapper. Source04/API04/manifest03 remove it and rerun all six inputs;
matrix03 supplies the final timing denominator. The prior matrix and unsealed
evidence plan remain historical. The separate full-emitter comparison never
uses that wrapper and is unaffected. An initial derived summary's setup-field
grouping was corrected; raw measurements are unchanged.

Disk reclamation hard-links three byte-identical immutable N1/N2 QBE/assembly/
object pairs after checking SHA256 and sizes, retaining both paths and all bytes.
It reclaims 145,639,837 bytes. Source, executables and runtime are untouched; these
frozen linked products must never be modified in place.

The qualified Phase114 native chain, installed production, broad 5.386× program
runtime score and native compilation metrics remain unchanged. No PR comment
was posted. This phase establishes a useful experimental interface and a small
exact-output candidate, not upstream parity or recursive self-improvement.
