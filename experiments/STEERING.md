# Current frontier — Phase151 literal dispatch and prepared constants

[Latest report](../implementation/phase151/README.md) ·
[Metrics](../implementation/phase151/metrics.json) ·
[Independent audit](../research/phase151/independent-audit.md) ·
[Experiment ledger](ledger.md).

This file is current steering, not a second historical ledger. Earlier detailed
frontiers remain in Git and their linked phase reports; the previous complete
steering snapshot is at `b020b57`.

## What Phase151 establishes

Two actual fixed-result U32 tables (`p88_roles`, `p112fp_binary`) emit in
1.1673→0.5702s when spelled as scalar predicates; complete component acquisition
1.4254→0.8201s. The source change alone regresses execution1.91×/1.41×.
Balanced no-thunk helpers recover runtime but expand to27 declarations and3.8×
reference QBE. Do not integrate either tradeoff blindly.

A checked Bend fixed-artifact counterfactual removes only42 immediate Unit ctor
calls and42 matching sinks from two consumed selector workers. Every other QBE
byte is unchanged. Candidate roles1.3135→0.685s; opcode names2.195→1.560s, near
original paths. Exact source/table controls, loop observations, artifact refusals
and independent machine/runtime audit pass within their explicit scope.

This is not a general optimizer, production promotion, whole cold-build gain,
new BendTT theorem or broad generated-program speed result. Source/installed
selection are unchanged.71 guarded jobs total122.03s; all closed, no OOM/pruning.
The2.05× component emission gain cannot be projected onto the258s compiler build.

## Highest-value next experiment

Revisit the [Phase131 prepared-value boundary](../research/phase131/safe-codegen.md).
`nbc_definition` retrieves erased source through `nc_source_body`; expansion can
recreate nullary constructors after static preparation. Preserve an authenticated
prepared value and its nonowning fact through bounded inlining. The prior V03
proposal is unqualified provenance, not a ready production change.

Keep original source admission, constructor identity/arity, special/foreign
refusals, ordered evaluation, ownership and final verification. Start with one
narrow nullary-immediate contract. Require actual emitted call removal, independent
outputs, compiler analysis cost and transfer to a safe compiler/usage-summary
workload before another full image build. The frozen text patcher is diagnostic;
never promote its function-name recognizers into compiler logic.

Do not expand many source dispatches into hand-written helper forests. A general
compact-literal frontend route is still a larger hypothesis: it needs typed
eligibility and dependent-refinement/quantity/diagnostic preservation, not merely
flat numeric syntax. No universal IR rewrite is justified by this experiment.

## Qualified and installed compiler identities

[Phase147](../implementation/phase147/README.md) remains the latest independently
qualified ordinary serial native compiler. It preserves exact compiler QBE,
assembly and objects across its cold representation changes; source checking,
protected declarations, parent→N1→N2→Q3, focused19 and N2 ordinary45 pass.
Its matched frozen-source cold build262.496→246.173s is a historical same-source
comparison, not a fresh ratio for today's differing source/policy experiments.
Use its explicit candidate/qualification receipts, not phase names alone.

Installed JS/C/QBE releases remain the [consolidated selection](../selfhost/manifests/current.json).
Use the one maintained module tree, explicit images/assets and
[workflow](../docs/self_hosted/workflow.md). The qualified serial compiler does
not imply parallel, GPU, incremental or every hosted/backend lane qualification.
Production identities and metric definitions are in
[the comparison guide](../docs/self_hosted/NATIVE_COMPILER_COMPARISON.md).

## Relevant recent negative and positive evidence

- [Phase150](../implementation/phase150/README.md): preferred scalar lexer is a
  component candidate,4.43× lexical/9.62% complete-parser improvement, no whole
  compiler promotion. Literal-pattern expansion caused the rejected acquisition
  penalty. Process-parallel validation saved40.78% on two fixed jobs only.
- [Phase149](../implementation/phase149/README.md): reduced policy11 saved53.59s
  staged acquisition but produced a compiler running1.831× slower;21–31 requests
  amortize the saving. Keep policy flags for ablation, not blanket promotion.
- [Phase148](../implementation/phase148/README.md): late compact-IR adapter was
  neutral on complete regions; pack/unpack added16.2%. Direct compact production
  across consumers remains a hypothesis. Do not repeat a late-conversion cache.
- [Phase129](../research/phase129/selected-compiler-audit.md): distinguish laws,
  source checking, finite admission checks and independent BendTT proofs. Tie new
  laws to an actual transformation invariant, not an abstract whole-compiler claim.
- [Phase150 upstream assessment](../research/phase150/upstream-assessment.md):
  migration needs runtime flag, representation and checker-contract gates. No
  upstream pin change was mixed into Phase150/151 measurements.

## Resource, evidence and communication rules

One root-owned serial CPU3 target lane. Ordinary jobs use maintained process-tree
and disk guards,2GiB RSS,16GiB available floor and5GiB disk reserve. Larger image
campaigns need an explicit measured budget; the prior6GiB gate is not a default.
Separate-process parallel correctness pilots require an explicit disjoint CPU
mask, aggregate accounting and no concurrent performance target. QBE's qualified
runtime remains one heap mutator, one CPU worker, GPU off.

No unsafe/failure-runtime probes; do not resume Phase113 custom failure
reproductions. Use ordinary valid programs, finite compiler/data refusals and
frozen independent oracles. Never overwrite frozen artifacts or hardlinked
products. Close each run through maintained retention; preserve negatives and
exact evidence before optional pruning. No full image build without measured
benefit and disk admission. No PR comments unless explicitly requested.

Use bounded agents for independent work; root owns target execution. Track
compiler work, machine builds, validation, failures, agent effort and billing
separately. Guard seconds are not total research cost; unavailable quota data
must not be invented. Keep commentary updates during sustained work.

Recursive research remains an open question. Follow the
[Phase104 design](../design/phase104/recursive-improvement.md) and
[research](../research/compilers_architecture_and_techniques/recursive-self-improvement.md).
Self-reproduction is not recursive acceleration.1×/10×/100× describe research
ambition, never established speedups.
