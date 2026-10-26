# Phase144 reproducibility guide

Start with the [report](../../../../implementation/phase144/README.md),
[design](../../../../design/phase144/README.md) and exact candidate/qualification
receipts linked there. Commands refer to this repository root; generated source
and image paths are authenticated inputs, not interchangeable compiler versions.

## Useful methods

- `prepare.py` and the source manifests construct the first
  exact-output composition; `native/prepare-final04-v01.py` derives the final
  source while retaining protected verifier and proof declarations.
- `native/workflow-v04.py` describes native acquisition and independent gates.
  It is a recipe, not permission to reuse an old success receipt for new inputs.
- `programs/` keeps the frozen45-program corpus, complete output oracles,
  balanced timing, rejected experiments and final changed-product checks.
  Object and runtime equality are required before inheriting execution evidence.
- The [generic profiler](../../profiler/README.md) and its
  [stage contract](../../profiler/STAGES.md) measure real native entries.
  `profile/final-summary-v1.py` derives the final03 profile; it does not describe
  final04's later policy changes.
- `emission/string-append/profile/` adds optional outcome counters to a derived
  diagnostic runtime. Counts, sampled time and clean execution time are distinct.
- `existence/`, `verifier/` and `emission/` retain bounded attempts, including
  neutral and rejected variants. Their presence does not mean production adoption.
- `archive-v05.py` preserves scoped evidence and recovery artifacts. Use its
  inventory mode before archival; large generated IR is intentionally regenerated
  from authenticated inputs rather than copied into Git.

Root owns one CPU3 target lane. Use the frozen guarded commands with a3GiB tree
RSS cap,16GiB available-memory floor and explicit time/file bounds. Avoid nested
guards. Metadata reviews may run separately. Never edit a consumed method or
receipt in place: prepare a successor with fresh output paths and retain failures.

Qualification, performance measurement, incremental-session behavior and default
selection are separate decisions. The serial reference-count runtime requires
one Bend heap mutator and rejects incompatible parallel compute modes. It does
not establish a safe arbitrary concurrent foreign embedding.
