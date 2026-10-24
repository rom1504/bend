# Phase135 compact evidence

[Archive](evidence.tar.xz) · [Integrity receipt](receipt.json) ·
[Report](../README.md) · [Metrics](../metrics.json).

The804,236-byte archive contains1,751 exact members totaling26,156,272 original
bytes. Every member and inventory was reopened and hash-checked. Archive SHA256:
`51e9374447b3d5f165476add4d954a3a333088406c279d10d32fad870148b880`.

It preserves checked machine source01/source02, the isolated ownership source,
methods, complete/failed receipts, guard logs, stage bridges, native FIFO session,
A-only cache membership, independent cold comparison, monolithic machine
reference and all18 compiler-request/six ordinary checks. Generated QBE, assembly,
objects, executables and hosted APIs are excluded; their identities remain in
receipts. They are reproducible products, not supplied in this compact capsule.

The original semantic session and ordinary baseline have separate
[receipt trees](../validation/README.md). The current report gives the final
interpretation; archived documents may retain earlier planning status. Provenance
copies preserve original bytes and links relative to their original locations.

Inspect without changing the working tree:

```sh
tar -tJf implementation/phase135/machine-evidence/evidence.tar.xz
```

Members have repository-relative paths. Restore into a fresh inspection directory
and verify `INVENTORY.json` before deliberately restoring individual artifacts.
Do not overwrite active methods or qualified selections merely to inspect old
evidence. Runtime, toolchain and reference artifacts retain their prior pins.

Reproduction uses `machine/prepare-v02.py`, the existing Phase134 supervised pipe,
`machine/session-build-v01.py`, `snapshot-v01.py`, `cold-replay-v01.py` and
`compare-v01.py`; the validation directory provides machine gates, analysis,
cost inventory and archival methods. See the
[machine tool guide](../../../selfhost/tools/performance/phase135/machine/README.md)
for complete commands and resource guards. This is not an installed compiler or
a general persistent incremental frontend.
