# P132-002 — Can a real compiler edit reuse native objects?

Status: bounded prototype and reference build; results in the linked report.

Hypothesis: a local edit under a fixed qualified producer leaves enough emitted
units unchanged to make machine-object reuse worthwhile. A stronger future
hypothesis is skipping unchanged checking/analysis/lowering. This experiment
only tests the first, and must not count an object hit after full emission as a
10-second source-to-executable rebuild.

Witness: change only the two emitted `%result` locals to `%answer` inside
`p111q_main`. Source remains2,667,581 bytes; independent full-book checking and
one-helper JS API emission pass. The qualified Phase131 N2 emits the changed
full compiler once, with resource/output-size observations and empty stderr.

Method: derive contiguous units from each full QBE product, preserve all source
instruction/data bytes, explicitly export cross-unit private references, and
cache objects by full IR, binding, toolchain/runtime/policy identity. Compare a
cache-assisted changed build to an independent cold build of the same current
units, including allocated machine sections. Separately run compiler requests
against independent frozen expected products. Preserve all preparation and
acquisition costs.

Evidence and results: [incremental report](../../implementation/phase132/incremental.md).
No generic dependency cache, production compiler change, or new native
qualification is implied. Later source checking/proof/semantic gates remain
independent of N1/N2 agreement.

Failure condition: broad identity/pool churn, tiny machine-build savings compared
with the unchanged frontend, or preparation cost exceeding avoided work. Report
these even if a warm object lookup looks fast.
