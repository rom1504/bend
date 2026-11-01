# Candidate N1 profiler preparation

Offline preparation is complete. No compiler workload, sampler, runtime compiler
or linker ran during preparation. Root owns the guarded build/pilot/full sequence
and will run it after clean performance measurements.

`experiments/phase147/tools/profile-candidate.py` is a successor controller with
explicit image receipt, ELF, object, QBE, source, assembly map, semantic stage
specification and libc unwind-range inputs. The consumed baseline controller
remains byte-identical (`a577650f…0c3`); its additional exact snapshot is under
`selfhost/build/phase147/profile-candidate-method01/`.

Preparation authenticates the completed N1 build in
`integrated-plan04/image/report.json` and rejects incomplete builds, changed
inputs, incompatible runtime bindings, source/image mismatches or retained QBE
that differs from the emitted stream. Candidate image SHA256 is
`4a925b352c8d747600bd62aa5691e7b0b52dfd372b2a9f796dcc6344382c3042`.
Its compiler source is the integrated source (`15e24090…ec80`), distinct from the
frozen input that this compiler will compile during measurement.

Fresh QBE analysis and ELF binding validate **56,049 FID pointers and 73,128
function symbols**. The integrated assembly map validates all 8,162 declaration
spans and supplies exact source locations for 4,133 of 4,262 lexical owner groups.
Unknown Base/composite owners remain unmapped. These are lexical locations under
the emitter contract, not source-level call stacks or original inline origins.

The baseline's 23 required markers plus one optional marker, their multiplicities,
required order and interval descriptions are unchanged. Every numeric FID comes
from the candidate's own table. For example, `p128raw_br_scanned` changes
43,995→44,962 and `p134e_registered` changes45,439→46,406. No old program addresses
or FIDs are transferred. The same explicit libc ranges are freshly checked
against the exact libc ELF CFI; that library is unchanged. Sampling stays32ms.

The ready receipt is
`selfhost/build/phase147/profile-candidate-prep01/ready.json`. Root execution jobs
are in `selfhost/build/phase147/profile-candidate-jobs01.json`:

| Job | Whole-run limit | RSS limit | Disk budget |
|---|---:|---:|---:|
| Diagnostic runtime/sampler build |120s|2GiB|128MiB|
| Exact-output pilot |90s|3GiB|256MiB|
| Full capture after pilot passes |540s|6GiB|768MiB|

All target jobs use the existing guarded CPU3 lane. The full capture uses exactly
the baseline request source (`00940ed5…fb5e`) and its complete independent QBE
oracle. Preparation used CPU0 and approximately200MiB of retained data/metadata;
12GiB was free before preparation. This document records preparation, not a
successful diagnostic capture or a measured compiler speedup. Compare exclusive
stage clocks separately from nested final verification, and never add physical
sample and source-owner distributions together.
