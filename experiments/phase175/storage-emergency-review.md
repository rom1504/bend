# Emergency recovery after external disk consumption

The earlier 261.64 MiB existing-archive tranche was already applied and is not
counted again. A bounded deeper inventory found no existing archive coverage for
the large remaining Phase111 objects. Fresh, exact archival of old transport and
rendered-output evidence offers better recovery without retiring compiler images.
The coordinator selected and approved these two bounded tranches.

| Proposal | Exact selection | Raw MiB | Conditional recovery at archive caps |
| --- | --- | ---: | ---: |
| [Phase140](storage-emergency-phase140.json) | 35 frame/payload files in nine closed transport experiments | 2,594.574 | 2,018.574 MiB |
| [Phase102](storage-emergency-phase102.json) | 609 rendered-output `child.json` logs in 19 completed benchmark roots | 810.410 | 506.410 MiB |

Archive caps are 64 MiB per Phase140 root and 16 MiB per Phase102 root. These are
scratch limits, not compression measurements. The combined cap-based recovery is
2,524.984 MiB; actual compressed archives may recover more. At roughly 2,618 MiB
free when the first proposal froze, the conservative bound only narrowly crosses
the 5 GiB reserve and does not guarantee room for another compiler job. Measure
actual free space after recovery and require the full next-job disk allowance.

Phase140 member digests come directly from completed original experiment reports;
capture must independently check the current bytes and exact inode metadata.
All roots were explicitly reviewed by the coordinator as retired operational
inputs. Historical comparison documentation is provenance. `profile01/000.frames`
is excluded. Top-level and transport reports, source, runtime and binaries stay hot.

For Phase102, the [current operational audit](storage-emergency-phase102-audit.json)
examined 1,301 files / 109.84 MB in maintained tools/manifests/installed metadata
and current Phase174/175 metadata. It found no selected-root references. All
609 exact child-file hashes were freshly measured; they are **not claimed to be
digests originally recorded by the aggregate report**. Completed aggregate
reports, job manifests, sources, images and runtime inputs remain hot. Exact
archives preserve the raw historical observations for future reanalysis.

The proposals pin the unchanged maintained `close.capsule` and `archive-v02`
methods. The coordinator owns capture and application under the shared lock,
with current byte checks, complete archive reopen/hash verification, source
stability checks, and an independent exact-set/hash/metadata/allocated-byte gate
before pruning. Every archive, receipt, plan and application journal is retained.
No directory deletion or implicit widening is authorized.

The explicitly scoped **2 GiB maintenance floor** permits recovery while already
below the normal reserve. It does not alter compiler guards or the **5 GiB
compiler reserve**. Stop maintenance safely if external consumption resumes or a
cap fails; originals must remain until their exact archive and independent plan
are verified. Compiler targets remain paused until the normal reserve plus their
declared additional storage is available.

Phase174 installation, rollback, N1/N2/Q3, benchmark/profile inputs and all current
Phase175 dependencies are protected. The storage agent prepared the proposals,
audits and hashes; it ran no capture, prune or compiler target. Execution results
belong in the coordinator's recovery receipt rather than being inferred from the
proposed raw byte counts.
