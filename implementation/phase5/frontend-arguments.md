# Generic argument boundaries

P5-008 repairs13 fresh invalid acceptances: semicolons at call, constructor,
family and typed-do argument boundaries now reject during parsing, matching the
pinned reference's acceptance/phase outcome. The final V3 checked compiler passes
28 focused checks and16 exact interpreter/JavaScript observations. The preceding
V2 grammar artifact also passes124 combined checks; V3 corrects only its new
message literal. No full-conformance or performance claim follows.

The patch changes only `f_args_base`. It uses the existing newline-only helper
and rejects semicolons before invoking `f_expr`, which otherwise skips them.
The existing list-specific diagnostic stays unchanged. Calls with optional
commas/newlines/trailing commas, nested family arguments, legal statement
semicolons (including a body inside a call argument), typed-array count/depth
syntax, constructors and parallel values retain their selected behavior.
Root reviewed and approved V3; its exact parser was promoted after checking that
production still matched the reviewed P5-006 baseline. Root owns the subsequent
shared whitespace-helper rename and combined-source gate.

## Distinct attempts and limits

The first candidate moved whitespace normalization before `f_args`' special
`>>` split. A fresh falsifier exposed an overacceptance: a newline before the
combined close is rejected by upstream as ambiguous operator syntax, but that
candidate accepted it. V1 is rejected and retained. V2 normalizes only inside
`f_args_base`, leaving the split's old boundary unchanged.

A local preparation-script replacement accidentally changed the new word
`arguments` to `argumenspaced`. Root and owner caught it in the source diff;
V2 remains frozen, while V3 has a fresh bootstrap and selected checks for the
corrected literal. The audit proves that this is the only module-byte difference
between those two snapshots, without claiming their API or diagnostics identical.

Nine call/constructor/do cases retain the specific semicolon diagnostic. Four
family-angle errors are overwritten downstream by a generic line0:0 error.
Their acceptance/phase is repaired, but exact diagnostics and intended first-error
rendering remain unfinished. The audit's first overstrong assumption that all13
specific messages survived is retained as a failed audit, then corrected against
the raw observations. Upstream's middle-family case itself takes its operator
namespace error route, so generic rejection is not proof of identical rule order.

A separate live probe confirms the previous typed list operator-RHS witness
`[(7 + ;16 : U32)]` remains incorrectly accepted. It is retained as a failing
residual, excluded from the passing selected gates, and requires expression
context handling beyond this boundary patch. The global semicolon skipper was
not rewritten.

## Artifact evidence

Baseline: P5-006 genuine checked API `f58a8281…`, source `221eea4b…`.
Final V3 API:
`c09599e842e67a16385f7fb9b52e1314bc8ee9bd3ec1394edf2975967d25ab31`.
Final source:
`3a66c69773100e8f9df22458c9a931b1035ac5a5e99f14a063ab7a6e9ec566a7`.
The maintained workflow built isolated copied projects with genuine normal
bootstrap reports. Canonical Base, runtime and pinned upstream remain identified
in those reports. CPU1, Node24,4MiB stack and4GiB heap were used for correctness
alongside other work; elapsed times do not establish a speed change.

| Frozen gate | Observations | Outcome |
| --- | ---: | --- |
| V2 grammar regression |124 checks|All declared acceptance/phase oracles pass;61 exact diagnostic differences remain|
| Final V3 focused |28 checks|All declared oracles pass;15 exact diagnostic differences remain|
| Final V3 execution |16|Eight programs each interpreted and compiled/executed as JS; all outputs exact|
| Final V3 retained residual |1 check|Candidate still accepts where upstream parse-rejects|

[Selected audit](frontend-arguments-evidence/final-audit.json) and
[archive manifest](frontend-arguments-evidence/manifest.json) retain actual
source/API/module/input identities, reports, worker histories, failed V1,
wrong initial newline oracle, V2 typo, failed audit and the unresolved residual.
This is frozen-artifact preservation, not a new bootstrap or automatic relocation
of historical paths.

The confirmed selection is
`selfhost/tests/frontend/phase5-arguments/cases-v2.json`. Recorded commands, from
`selfhost/`, used new output directories:

```sh
node tools/development/workflow.mjs run \
  build/phase5/arguments/candidate-v3.config.json \
  build/phase5/arguments/candidate-v3
node tools/development/workflow.mjs validate \
  build/phase5/arguments/candidate-v3 \
  build/phase5/arguments/execution-cases.json \
  build/phase5/arguments/execution-v3
python3 tests/frontend/phase5-arguments-audit.py \
  build/phase5/arguments build/phase5/arguments/final-audit.json
```
