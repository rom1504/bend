# Phase200 storage and native-image acquisition

The existing disk guard admits declared output roots under `selfhost/build` on the workspace filesystem and retains its 5 GiB reserve. `/tmp` shares that mount and `/dev/shm` is read-only in this environment. The CPU 3 guard also enforces RSS, available host memory, deadline and per-file limits. [Guard implementation](../../../selfhost/tools/build-retention/guard.py)

## Two expressly authorized cold members

The user authorized archiving exactly the Phase199 core and integrated N1 `program.s` files. Both directories had previously been marked hot. Each original object, compiler executable, source, native build receipt and guard remains at its original path. The two canonical gzip archives and recovery receipts live under `selfhost/build-retention/phase200/authorized-assembly01/`.

| Former loose member | Original bytes | Archive bytes | Original SHA-256 |
| --- | ---: | ---: | --- |
| `p199-core-native-image01/program.s` | 86,612,765 | 7,376,930 | `0d0164bf2114af51d31cd0689d233c3427a9943231a8b0dad057438a3ec9bb96` |
| `p199-integrated-native-image01/program.s` | 87,046,134 | 7,422,137 | `d47f262d0c3529e95161d3688843eb6647f0a2301c2fa7bc5898ba7cac0277f9` |

At lock acquisition, external writers had taken free space 2,060,288 bytes below the reserve. The method compressed and verified an entire member in memory, then wrote independent 64 KiB gzip members into already allocated blocks of that same inode. The first 64 KiB of each original have a byte-exact durable copy in the retained progress N1 assembly. Each subsequent write covered only source bytes verifiably recoverable from that prefix or previously fsynced archive members. The method verified the full original digest before truncating surplus extents, linked the canonical archive name, independently decoded it again, fsynced its receipt, then removed the authorized loose name. This freed 158,855,168 allocated bytes. At release, free space exceeded the reserve by 152,424,448 bytes. The archives are local to this filesystem. [Acquisition receipt](evidence/assembly-archive.json)

To recover either original when needed, use a fresh destination with room for its uncompressed size above the reserve. The helper checks the entire digest and restores recorded permissions and modification time. This example restores the original path in an authorized maintenance window.

```sh
python3 -B research/phase200/storage/reclaim_assembly.py \
  --restore p199-integrated-native-image01 \
  --destination selfhost/build/phase198/p199-integrated-native-image01/program.s
```

The metadata audit found 2,056 sealed closures, including 267 archive-only roots with 643,706,880 currently allocated bytes matching their recorded exclusive file digests. All 267 have `pruneRequested=false`; the original reviewed Phase42–65 allowlist covers none of them. Historical hardlink maintenance required an approved concrete plan, exact live byte and metadata equality, single-link destinations and a discipline preventing future in-place writes. The read-only duplicate scan found 65 exact generated-intermediate groups with 25,612,288 allocated bytes in duplicate inodes. Its largest pair consists of the identical 18,177,776-byte Phase169 quality N1/N2 objects. The campaign applied only the two independently authorized archive operations. [Duplicate audit](evidence/dedup-audit.json) [Inventory](retention-inventory.json) [Retention policy](../../../docs/self_hosted/build-retention.md)

## Image-only N1 acquisition

`stream_image.py` uses the established native source request planner and authenticates the actual release QBE N2, source, Base, assets, assembler, linker and runtime. The compiler's full QBE IR passes through a 64 KiB relay and is hashed. The QBE assembly and ELF object use bounded anonymous RAM files. Each becomes write-sealed and is hashed. GNU ld records the object input pathname in `STT_FILE`. A short-lived internal `program.o` alias preserves the canonical spelling `/absolute/output/program.o` while the actual object remains in RAM. The native build report binds the actual emitting N2, source identity, N1 executable, target protocol and runtime. Selection and semantic qualification are independent.

From the prepared checkout, run with an independently checked compiler source and a fresh run name. `--artifact raw` retains the conventional native ELF and image binding. `--retain-object` additionally retains `program.o` and requires a larger disk budget. `--artifact gzip` retains a verified lossless compressed ELF and digest for deferred materialization. It records no on-disk executable binding.

```sh
python3 -B research/phase200/measure/job.py p200-candidate-native-image01 300 21 \
  python3 -B research/phase200/storage/stream_image.py \
  --assets selfhost/build/phase194/assets.json \
  --image selfhost/build/phase186/release-qbe-chain01/n2/program \
  --image-receipt selfhost/build/phase186/release-qbe-chain01/n2/report.json \
  --host native --stage N2 --target qbe --mode cache \
  --source selfhost/build/phase200/p200-candidate-source01/compiler.bend \
  --out selfhost/build/phase200/p200-candidate-native-image01 --seconds 270 --artifact raw
```

The initial machine replay recovered the exact 87,046,134-byte Phase199 assembly and reproduced its exact 25,042,504-byte object. Giving ld the anonymous descriptor's literal pathname changed the raw ELF by 80 bytes. The corrective four-route control reproduced the historical 19,068,032-byte executable exactly with the original object pathname. For an independently fresh canonical pathname, linking a disk-backed object and linking the identical anonymous object produced byte-identical 19,068,024-byte executables. The literal anonymous descriptor changed only the GNU build ID among allocated sections, and program header bytes matched. [Initial replay](evidence/storage-parity01.json.gz) [Corrected link control](evidence/storage-link-parity01.json.gz)

The actual Phase200 candidate completed in 178.91 guarded seconds. Its source digest `c8b1b8a30d08e15e37d92cd6ed65ccc33b9bff484957e21ebeb903069ef106d7` matches the independently checked zero-hole source. The resulting 19,130,712-byte N1 ELF has SHA-256 `be33a613b00c93b7d02762742a49f7fa23d4dedf409dac9ce197cadc7f1defd5`. Peak declared-root allocation was 19,185,664 bytes, peak shared-filesystem decrease was 21,393,408 bytes and peak process-tree RSS was 1,125,142,528 bytes. The assembler retained the two previously observed `72618344968093696 shortened to 0` diagnostics. Compiler, QBE and linker diagnostics were empty. [Acquired image and sealed guard](evidence/candidate-image01.json.gz)
