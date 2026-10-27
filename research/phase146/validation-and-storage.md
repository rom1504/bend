# Phase146 fast validation and reversible storage

This is metadata/source investigation. No candidate compiler or native benchmark
was executed by this investigation. The coordinating agent owns measurements,
cleanup execution and qualification.

## Cheapest trustworthy loop

Use `selfhost/tools/performance/phase111/check-api.py` on the new checked Bend
source, exporting the ordinary cursor API and the new finite controls. The
same-sized final04 source checked in **14.21 s**. Run under the existing
Phase111 guard on the one assigned CPU, with a 3 GiB process limit, 16 GiB
available-memory floor and 64 MiB per-file cap. API output must remain below
`selfhost/build/phase111/`; do not infer successful Bend checking from a host
JavaScript edit.

Then run finite refusal/context controls and emit Lexer, Map and closures through
the actual ordinary route:

`p88_cache_prepare → p86_plan → p134e_plan → p134e_begin/p134e_next`.

The existing transport-only driver is
`selfhost/tools/performance/phase144/emission/string-append/emit-v01.mjs`.
Its output-path restriction is Phase144, so either use a fresh `p146-*` output
there or make a versioned path-only derivative. Frozen current reference products
are `selfhost/build/phase144/final04-small-products01/{lexer,coverage-map-churn-128,coverage-closures-256}.ssa`;
their report records **17.82 s** for the three requests. The source fixtures are
the corresponding ordinary files in `selfhost/build/phase88/broad-fixtures03/`.
Pure verification/context reuse should produce **complete byte-identical QBE**.
Do not normalize it or weaken the independent final verifier. Approximately
40 seconds of acquisition, controls and three products is a useful initial
rejection loop; hosted timing is not a native compiler speed claim.

Cache controls must cover changed function bodies, header/order/constructor
facts, source/runtime identity, previous failure, and changed outer context.
Only a previous successful judgment under its exact required context is reusable.
The Phase145 verified-input instrumentation establishes matching inputs; by
itself it is not a production cache or a proof that a check can be omitted.

## Native slice versus whole request

The existing Phase144 verifier slice methods are in
`selfhost/tools/performance/phase144/verifier/` and documented in
`research/phase144/verifier.md`. They capture actual branch-rich IR, retain the
complete required headers/constructor context, and package a dependency-closed
Bend workload. The historical Lexer slice was roughly 126 KiB with eight selected
functions; its complete native loop was about 2.7 seconds. Dependency extraction
must retain associated forward laws (`blocks(..., combine=True)`). These methods
hard-code historical source/candidate boundaries: rebind them and independently
bridge the current source before use. Their historical gain does not predict
Phase146 gains.

Repeated-verification elimination is better evaluated first on a complete request:
a single-verifier kernel can omit precisely the duplicated work being removed.
If representation or native admission is uncertain, use the extracted slice to
falsify it before another full image acquisition.

The retained qualified producer is
`selfhost/build/phase134/p144-final04-n2/program` (SHA256
`e2f6317bd078fcca0d0bb0e94d861a5b77f3b36650cf274f63dab0f5c28e5d13`).
Keep its `program.o`, the exact serial runtime
`selfhost/build/phase144/serial-rfc01/serial-rfc.o`, the carrier
`selfhost/build/phase130/base-carrier01/receipt.json`, Base, APIs and source
untouched. `implementation/phase144/final04/candidate.json` binds these identities.

Acquire a promising candidate with the existing bounded pipe builder
`selfhost/tools/performance/phase134/pipe/build-v02.py`; its output must be below
Phase134. It streams compiler output into QBE and retains assembly/object/image.
Keeping full QBE adds about 117 MB: one retained image consumes about 248 MB,
one without retained IR about 131 MB. The coordinator's feasible narrow chain
is retained N1 QBE, unretained N2 with exact expected-QBE comparison, then the
separate reproduction/ordinary gates. New source-specific qualification metadata
must be versioned; do not reuse Phase144 source contracts unchanged.

Only pay the full frozen compiler request when small native requests make the
candidate worthwhile. The current baseline is
`selfhost/build/phase130/p144-final04-fixed-cold01/report.json`: **231.682 s**
for the fixed Phase142 input, plus about **15.318 s** machine build. Retain exact
source/runtime/output identity. Adoption still requires self-reproduction,
focused checks and the ordinary corpus. A three-case byte bridge alone does not
establish whole-language conformance.

## Exact recoverable cleanup tranche

The following **six diagnostic files only** are already stored byte for byte in
committed evidence capsules. `storage-v01.py verify` re-read every chosen member,
hashed each entire archive and current file, and confirmed one hardlink per file.
It removed nothing. The complete pins are in
`selfhost/build/phase146/storage-verify01.json`.

| File under `selfhost/build/` | Bytes | Capsule |
|---|---:|---|
| `phase144/final03-stages01/owners.json` | 34,740,066 | Phase144 |
| `phase144/profile01/owners.json` | 34,583,410 | Phase144 |
| `phase144/final03-stages01/runtime/program` | 19,155,832 | Phase144 |
| `phase144/stages02/runtime/program` | 19,043,600 | Phase144 |
| `phase144/profile01/runtime/program` | 18,993,544 | Phase144 |
| `phase145/native-stages01/owners.json` | 15,302,529 | Phase145 |

Total logical size: **141,818,981 bytes / 135.249 MiB**. These are old diagnostic
ELFs and owner maps, not qualified production/fallback images. Current parent
objects, runtime, carrier, source and active output oracles are excluded. Open
descriptors or concurrent disk activity can affect observed free-space change;
logical size is not a filesystem-wide space guarantee.

Capsules (both are retained):

- `implementation/phase144/evidence01/evidence.tar.gz`, 46,116,414 bytes,
  SHA256 `59c89f0f41432c030cb1a2757bb89f528f2d62eb97577e7032c6e833f4666419`.
- `implementation/phase145/evidence01/evidence.tar.gz`, 5,941,368 bytes,
  SHA256 `f1bf7f5141fa1cd82d52f192342be735112cf0fb2ac944f1d662aed5d8e796ad`.

Coordinator-only cleanup, after the completed read-only verification:

```sh
python3 -B selfhost/tools/performance/phase146/storage-v01.py apply \
  --verified selfhost/build/phase146/storage-verify01.json \
  --out selfhost/build/phase146/storage-cleanup01.json
```

Apply revalidates the entire six-file/capsule set against the verification receipt,
writes an intent receipt before deletion, rechecks each exact inode/content,
journals each unlink, checks path absence and rehashes retained capsules. No
directory wildcard or general deletion option exists.

Restore all missing members (also recovers an interrupted partial cleanup):

```sh
python3 -B selfhost/tools/performance/phase146/storage-v01.py restore \
  --out selfhost/build/phase146/storage-restore01.json
```

Restore streams only the six named members into temporary files, checks bytes/hash,
restores original mode, publishes without overwriting, and checks the restored
file. Already-exact members are skipped; differing existing files cause refusal.
It needs enough free space to restore the removed members. No untrusted archive
path is extracted. These checks authenticate storage recovery, not compiler
correctness or a new performance measurement.

Do not remove the large historical SSA/stdout aliases: some share inodes with
up to ten paths, so removing two apparent 117 MB files may free zero bytes and
would disturb additional pinned evidence. That broader cleanup is deferred.

## Additional four-file tranche (verification deferred to coordinator)

After the coordinator successfully applied the six-file cleanup, a further
**106,398,586 bytes / 101.47 MiB** was found in four historical diagnostic files:

| File under `selfhost/build/` | Bytes | Existing capsule |
|---|---:|---|
| `phase142/native-context-plan01/owners.json` | 34,295,924 | Phase142 evidence02 |
| `phase142/native-context-plan01/runtime/program` | 18,864,368 | Phase142 evidence02 |
| `phase143/profile01/owners.json` | 34,350,614 | Phase143 evidence01 |
| `phase143/profile01/runtime/program` | 18,887,680 | Phase143 evidence01 |

These files currently have one hardlink each. Their paths are absent from the
current Phase146 preparation methods and final04 candidate identity; they are
historical profiling products, not current lineage inputs. The ordinary qualified
Phase142/143 compiler images and sources remain untouched. Their exact archived
content still requires the coordinator's verification below before removal.

`storage-v02.py` is a versioned narrow derivative: different four-file allowlist,
Phase142/143 capsule pins, and original modes authenticated from tar members
because these older inventories omit modes. The restoration and journaled deletion
checks are otherwise unchanged. Only static Python parsing was performed while
native acquisition occupied the measurement lane. No archive decompression or
deletion was run for this tranche by the audit agent.

Capsules retained:

- `implementation/phase142/evidence02/evidence.tar.gz`, 14,024,521 bytes,
  SHA256 `17c9d8e6b5cde81ec644a1a86b1f908236090091c9ec4afd5f9121d53deaaf37`.
- `implementation/phase143/evidence01/evidence.tar.gz`, 24,957,949 bytes,
  SHA256 `cb0c8d6b398dbdd3b351c8e0fc897eb5b3512ebd92318e1347811ddfe89e2181`.

After the coordinating agent releases the measurement lane:

```sh
python3 -B selfhost/tools/performance/phase146/storage-v02.py verify \
  --out selfhost/build/phase146/storage-verify02.json
python3 -B selfhost/tools/performance/phase146/storage-v02.py apply \
  --verified selfhost/build/phase146/storage-verify02.json \
  --out selfhost/build/phase146/storage-cleanup02.json
```

Exact restore uses this version's four-file allowlist:

```sh
python3 -B selfhost/tools/performance/phase146/storage-v02.py restore \
  --out selfhost/build/phase146/storage-restore02.json
```

Phase144 `integrated-stages01/owners.json` and `runtime/program` were examined but
excluded from this proposal: the Phase144 inventory explicitly lists them as
**not archived**. Their apparent recoverability must not be inferred from the
existence of other stage profiles in that capsule. No further storage search or
full-SSA alias removal is proposed here.

## Exact duplicate N1/N2 machine artifacts

The completed N1 build retained 117,232,528 bytes of QBE, 86,620,520 bytes of
assembly and a 25,437,152-byte object. If N2's assembly/object match literally,
their two duplicate allocations can be removed without changing either recorded
path, file contents, permissions, compiler receipt or compiler executable.

`selfhost/tools/performance/phase146/dedup-native-v01.py` admits only
`selfhost/build/phase134/p146-context01-{n1,n2}/{program.s,program.o}`. It requires
both completed build receipts, successful compiler/QBE/assembler/link exits,
exact source/runtime/IR agreement, and the N1→N2 lineage/reference bridge. Each
pair must have matching modes, owner/device, SHA256 and streaming literal bytes.
It refuses unexpected aliases. ELF images are excluded: the actual N1/N2 full
ELFs differ, and no identical-machine-code claim follows from storage dedup.

After root releases the build lane:

```sh
python3 -B selfhost/tools/performance/phase146/dedup-native-v01.py verify \
  --out selfhost/build/phase146/dedup-verify01.json
python3 -B selfhost/tools/performance/phase146/dedup-native-v01.py apply \
  --verified selfhost/build/phase146/dedup-verify01.json \
  --out selfhost/build/phase146/dedup-apply01.json
```

Apply journals atomic replacement of each N2 path by a hardlink to the matching
N1 artifact and repeats the report/content/literal checks afterward. The expected
allocation saving is **112,057,672 bytes / 106.87 MiB**. Inodes and timestamps may
change; content-based historical pins do not. Both frozen build directories must
remain immutable because writing either hardlink would alter both artifacts.
This is storage sharing after two independently completed builds, not skipping
N2 compilation. No compiler target is executed by the tool.

If separate writable copies are ever required, use `split --out` with a fresh
Phase146 receipt path before writing. It streams an independently allocated copy,
checks bytes/mode, and atomically replaces only the N2 path. It requires enough
free disk for the duplicate. An interrupted apply can be inspected with a fresh
verify receipt; already-linked pairs are explicitly recognized.

## Remaining ordinary qualification footprint

Metadata-only inventory of final04's retained successful runs is recorded in
`implementation/phase146/audit/qualification-footprint.json`:

| Historical suite | All retained bytes |
|---|---:|
| N1 focused19 | 7,457,657 |
| N2 focused19 | 7,457,650 |
| N2 ordinary45 | 59,904,034 |
| Total | 74,819,341 (71.35 MiB) |

These totals include emitted QBE, assembly, objects, executable programs, logs
and receipts; actual Phase146 size may differ. The ordinary45 QBE products alone
occupy 24,574,124 bytes. Parent receipts are
`selfhost/build/phase111/p144-final04-{n1-focused19,n2-focused19,n2-full45}/report.json`.
Each successful row pins `product`, `emission`, the independent expected stdout
and execution observation. Match rows by name and join the exact source/arguments
through `emission` before claiming old/new QBE equality. Expected refusals have
no successful QBE product. The frozen semantic manifests remain
`selfhost/tools/performance/phase111/coverage/{manifest.json,full45/manifest.json}`.

The dedup saving plus the reported ~249 MiB free before dedup should accommodate
one ~112 MiB Q3 capture and these ~71 MiB suites, with space for one additional
~112 MiB frozen-input **request capture**. That last estimate excludes another
full assembly/object/image build. No broad gate or oracle is weakened to fit.
