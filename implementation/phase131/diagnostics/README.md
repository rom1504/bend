# Phase 131 selected diagnostic evidence

[diagnostics.tar.gz](diagnostics.tar.gz) preserves **562 files / 61,098,902 raw
bytes** in **4,868,371 compressed bytes**. The archive SHA-256 is
`d771f399fbb4877b611832387961422151a9d8e6fb0e11b2af6008ee61c9e903`.
Every member was reopened and checked against its exact size and SHA-256.
[receipt.json](receipt.json) authenticates the archive and readable summaries;
[inventory.json](inventory.json) lists included files, exclusions and external
identity dependencies. This is a selected evidence capsule, not the entire build
history or a standalone compiler/toolchain.

[Addendum 02](addendum02.md) preserves the later full-source context profile,
selector experiments and source laws. Both archives together contain 824 files
in 16,983,175 compressed bytes; the original capsule below remains unchanged.

## Readable results and preserved inputs

| Evidence | Readable exact summary | Raw archive roots |
| --- | --- | --- |
| Final N2 short physical/context profiles | [short-profiles.json](short-profiles.json) | `selfhost/build/phase131/final-profile01`, `final-context01`, `final-profile-analysis01` |
| Final N2 whole-source physical sample | [full-source.json](full-source.json) | `final-full-profile01`, `final-full-profile-analysis01` |
| Owning equality shortcut, 18 paired whole-compiler requests | [whole-identity.json](whole-identity.json) | `owning-full-timing01` including original reporting failure and successful `summary02` |
| Wider borrowed-record queries, 20 paired observations | [wide-records.json](wide-records.json) | `wide-timing01`, `wide-results01` |

The archive contains the raw sample, physical-caller and active-context logs,
per-capture analyses, event counters, exact owner mapping, manifests, guard
receipts, frozen method snapshots, and the interpretation tools. Small canonical
QBE oracles, request sources, wider-record fixtures and their output oracles are
included. The earlier short-profile aggregate is retained only as the reference
for the current counter comparison; its entire historical capture tree is not
copied.

The short profiles describe final **N2**, with pooled physical/context sampling
and separately measured instrumentation overhead. The full-source physical
capture is one sampled request, with 11,254 samples and zero loss/overrun; it has
no paired clean baseline and establishes no new speed ratio. Physical leaves,
recovered callers and active dispatch-owner contexts are different, overlapping
views. Their fractions must not be added.

The owning-equality experiment is an **unqualified two-adapter QBE ceiling**;
the wider-record experiment is an independently checked experimental source.
Neither changes the [qualified final candidate](../final/README.md). Their 18
and 20 observations are separate paired experiments, not additions to the
three-role native compiler comparison or the generated-program corpus.

## Deliberate omissions

Ninety-two selected artifacts are excluded with rechecked identities: generated
ELF/object files, large compiler QBE/assembly, and repeated large QBE stdout.
The full-source 107 MB output is pinned instead of copied. Its exact-output gate
and complete identity remain in the archived capture report. Canonical short
request oracles are included once rather than copying every matching output.

Another 122 historical/external dependency identities are preserved as
**declarations from the archived receipts**, without a fresh recursive rehash.
This distinction is explicit in the inventory. It avoids claiming a complete
historical snapshot or requalification of every ancestor. The archived final
source and compact Base carrier are useful interpretation inputs; the native
executables and external system toolchain remain separate pinned dependencies.

## Verify or unpack

The archive uses repository-relative regular-file names, zero timestamps and
normalized ownership. Inspect it without extraction:

```sh
sha256sum implementation/phase131/diagnostics/diagnostics.tar.gz
tar -tzf implementation/phase131/diagnostics/diagnostics.tar.gz
```

To unpack, choose a fresh directory and preserve the relative layout:

```sh
mkdir /tmp/phase131-diagnostics01
tar -xzf implementation/phase131/diagnostics/diagnostics.tar.gz -C /tmp/phase131-diagnostics01
```

The inventory maps every member to its original path, size and hash. JSON
receipts retain original absolute paths unchanged. Raw logs and resolved
analyses support offline inspection; fresh symbolization or target replay still
requires the excluded pinned binaries/toolchain and identity-aware paths. The
archive is not advertised as an independently runnable compiler distribution.

The data-only sealing method is
[archive-diagnostics.py](../../../selfhost/tools/performance/phase131/native/archive-diagnostics.py).
It checks closed gates, authenticates selected workload inputs, refuses archives
larger than 20 MiB, and reopens every member. No compiler, program, profiler or
benchmark target was executed while creating this capsule.
