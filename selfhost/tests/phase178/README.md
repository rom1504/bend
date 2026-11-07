# Phase178 frontend cleanup experiments

The maintained implementation lives only in `selfhost/src`. These files retain
the bounded experiments and independent audit methods, including rejected work.
See the [report](../../../implementation/phase178/README.md).

- `parser/`: deletion and all-profile closure audits, exact baseline fixture,
  rejected compatibility proposal and its unused direct-helper controls.
- `layout/`: checked erased-body/reference product, complete-value controls,
  neutral native result and bounded follow-up cleanup audit. Not production code.
- `prepare.py`: explicit snapshot adapter around the existing source extractor.
- `job.py`: phase-local outer resource guard/retention wrapper.
- `seal-evidence.py`: archive exact source/receipt/log evidence without pruning.

Reuse the maintained source assembler, checker, native builder and earlier exact
comparison methods. Do not import experimental overlays into normal builds or
treat any finite control as a compiler-correctness theorem.
