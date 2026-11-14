# Phase193 reproducibility

The selected compiler implementation is `selfhost/src/back/x86/public-composition.bend`
and its one-line call in `program.bend`. Assemble the canonical x86 profile using
`selfhost/tools/build/source.py`. Do not replay the experimental patch over the
maintained selection. The standalone prototype has a later affine annotation;
the frozen selected source and actual control API use the maintained definitions.

Host scripts transport requests, preserve evidence or perform independent
measurement. All new compiler transformations and admission adapters are Bend.

- `compiler-profile-plan.py`, `check-profile-output.py`, `profile-findings.py`:
  identical-request clean timing, two-period profiling and output authentication.
- `prepare-compiler-hot.py`, `compiler-hot-workload.bend`,
  `compiler-hot-oracle.py`, `emit-compiler-hot.mjs`, `compiler-hot-timing-plan.py`:
  exact compiler-routine extraction and the independent persistent-index kernel.
- `ready-fusion-controls-v3.mjs` consumes the v2 Bend/C fixtures. It is the final
  passing real-runtime control. Earlier drivers/fixtures retain diagnosed failures.
- `compiler-cost-plan-v2.py --stage N1|N2`: same-input requests, each producing its
  own independently qualified object. N1 isolates same-producer source cost; N2
  measures the combined source and generated-compiler change.
- `summarize.py`: unchanged native45 timing admission plus the frozen 10/35 split,
  family weighting and positive excess time. Partial coverage remains explicit.
- `compare-hosted-subset-v3.py`, `budget-core-equivalence-v2.py`,
  `profile-source-audit-v2.py`: offline product/closure and
  unrelated-backend identity gates; the original symlink audit attempt is negative.
- `run-steps.py`: serial transport of frozen argv with source identity checks.
  `job.py` supplies each target job's maintained resource guard and retention close.
- `pack-evidence.py`: bounded, member-verified metadata archive; no binary backup.
- Retention methods apply only their exact reviewed file lists after verified
  archiving. Historical assembly may require restoration before machine replay.

The final selected variant is the growth-budget adapter, frozen in
`selfhost/build/phase193/selected-source02/compiler.bend`; `selected-source01`
and unprefixed native/runtime runs retain the uncapped experiment. Final native
qualification uses `budget-qualification-plan02` and `budget-*` run directories.
The final full runtime run is `budget-runtime01`; the earlier `runtime-combined01`
is the authenticated uncapped result, not the selected compiler's measurement.
The numeric budget gate has seven finite cases; full runtime/admission controls
and source audits establish separate obligations.

`budget-compiler-profile-plan.py` prepares the optional before/after native
compiler profile. Its sources and generated objects differ explicitly, unlike
the initial same-source QBE/x86 profile. Each output is checked against its own
independent oracle. Do not apply the initial common-output comparison to it.
`capture-final-evidence.py`, `campaign-cost.py` and `pack-evidence.py` run offline
after target guards close; they record qualification, complete guarded costs
including failures, and verified bounded receipts respectively.

The loop-threading prototype and its offline state oracle are **not selected**;
no Bend/machine performance qualification is claimed for them. The original
public-fusion data fixture is retained as negative evidence, not the final gate.

Exact commands, source/asset identities, guard budgets, failures and outputs live
in the receipts referenced by `implementation/phase193/README.md`. Freeze fresh
output paths and use one CPU3 lane. Do not infer mathematical proof, installed
promotion or broad correctness from finite controls or reproduction.
