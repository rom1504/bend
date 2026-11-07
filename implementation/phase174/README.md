# Phase174 — Phase171 published and installed

Phase171’s measured optimizations are integrated into the maintained compiler
and installed as native QBE N2, genuine JS B2, and the public native C compiler.
All release gates and installed smoke checks passed. The prior Phase170
installation remains available for rollback.

[Metrics](metrics.json) · [Reproduce](reproduce.md) ·
[Design](../../design/phase174/README.md) ·
[Current selector](../../selfhost/manifests/current.json).

## Compilation speed: keep the inputs separate

| Observation | Input | Baseline | Phase171 | Meaning |
| --- | --- | ---: | ---: | --- |
| Fresh controlled pair | Original 3,150,535-byte Phase170 source | 195.101s | **188.395s** | **3.44% less time**, identical QBE/assembly/object |
| Historical Phase171 pair | Same original source and path | 188.620s | 180.677s | Earlier observation; retained separately |
| Fresh N1 → N2 self-build | Current 3,161,409-byte integrated source | — | **188.002s** | Current-source build, including machine construction |
| Actual N2 → Q3 request | Current integrated source | — | 163.740s | Emission request only; excludes QBE/assembly/link |

Each pair has one observation per image, candidate first, with fresh processes,
prepared Base, CPU3, and unchanged runtime/toolchain. OS caches were not flushed.
The historical 180.7s result is not a wall-time guarantee; this session’s matched
pair confirms a smaller but still positive reduction. Neither pair measures
upstream parity. Source checking and prepared-Base acquisition are separate costs.

The later Phase173 timings used a different compiler and larger input; they
did not establish a regression of this Phase171 candidate. The fixed original
input is retained explicitly to prevent future baseline confusion.

## Exact integration

The maintained source is byte-identical to the measured Phase171 candidate:
3,161,409 bytes, SHA256
`74cd7de3e5076490e20ba0218d4c9254853be72562946b9ef66fed6c10c7a53a`.

Six existing modules receive 16 definition replacements and 28 declarations.
The four changes stop definitively rejected lowering early, skip ineligible
frame/fusion planning, reuse request-local scalar catalogues, and retain a
narrower private publication history while preserving the checking world.

All 8,398 unchanged original declarations, 112 protected declarations, and the
native entry are byte-identical. The inverse recovers Phase170 exactly. The
compiler grows by 212 physical Bend lines, from 67,929 to 68,141, and by 10,874
bytes. Historical overlays are evidence, not production source dependencies.
See the [integration audit](source-integration.json).

## Qualification and generated-program quality

- Independent source checking and all **77 finite optimization controls** pass.
- The actual preserved Phase171 N1 builds a fresh N2; N2 emits Q3. All complete
  98,023,231-byte QBE products agree; N1/N2 assembly and object bytes agree.
- **64 native** and **19 hosted QBE** cases pass. Both the 45 ordinary products
  and distinct 45 timed-wrapper products match qualified QBE references exactly.
- Fresh **JS B2/B3** reproduction includes B2 checking the complete current
  source. JS45, seven public controls, two refusal controls and five JS-hosted C
  controls pass.
- The newly built **public native C** image passes C45 and its CLI checks,
  including relocation and live/cache product agreement.
- All **45 JS and 45 C emitted products** match their Phase170 references
  exactly with unchanged execution policies. This preserves generated-code
  evidence; it is not a new runtime benchmark.
- Six positive native P140/2 jobs and eight hosted session jobs pass. All five
  installed smoke jobs pass, including native cache/live and default public
  JS/C commands. Native session error recovery or object-unit support is not
  inferred from the positive native gate.

These are finite gates and self-reproduction checks, not an end-to-end compiler
correctness theorem. The release auditor and protected semantic verifiers are
unchanged.

## Linker metadata, failures and rejected shortcuts

Raw ELF equality failed honestly. Exactly 21 mapped metadata bytes differ:
one section-table-offset byte and the 20-byte GNU build-id. Every program header,
executable code byte and runtime data byte agrees. Nonloaded differences are
fully explained by a shorter object pathname and its symbol offsets. The
[audit](../../experiments/phase174/elf-audit.md) and separate v2 reproduction gate
keep raw loaded-image equality **false** and state the narrow code/data
equivalence explicitly. No binary rewriting or arbitrary metadata mask is used.

The first JS B2 run stopped after 236.539s because its 16MiB disk budget counted
concurrent preparation files. It was not an OOM or compiler failure; the retry
used 64MiB. An old lazy-control receipt rejected its stale source-manifest
dependency; independently rechecking the same frozen baseline allowed the
unchanged 32-case runner to pass. Both failed attempts remain retained.

Fresh B1 was byte-identical to the older API, but actual B2 was not. Reusing old
JS behavior qualifications was therefore rejected, and fresh gates were run.

## Publication, rollback and resources

The unchanged release auditor accepted all three components. The installer
published the current selector last and retained its backup map and journal at
`selfhost/build/phase174/install/`. The three operational asset maps were updated
with their own backups at `selfhost/build/phase174/selector-install01/`.
Installed source and artifact verification passed. A source rollback also needs
the matching prior maintained-source revision; restoring only an old selector
is insufficient. The previous source head was `c1af28f`.

Exact verified archival of 14 retired generated files recovered **1,056.94MiB**
net payload capacity. Compiler sources, executable references, current profiles,
Base/runtime/toolchain inputs and rollback images remain hot. See
[storage evidence](storage.json).

The [cost account](costs.json) separates acquisition/reproduction, qualification,
fixed-input timing and failed guards. All 37 guards are closed, accounting for
54.1 minutes of measured execution:

| Category | Guard wall time |
| --- | ---: |
| Acquisition and reproduction | 1,731.3s |
| Qualification | 863.8s |
| Fixed-input performance pair | 387.3s |
| Failed attempts | 237.4s |
| Installed validation | 17.4s |
| Finite controls | 9.3s |

These totals exclude editing, analysis, archival and idle time; they are not
total research time, CPU time or agent billing. The bounded
[evidence archive](evidence/final01/index.json) retains exact
small receipts and methods, including failures; large binaries/IR are separately
pinned rather than duplicated in Git. No PR comment was posted.
