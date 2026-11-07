# Durable space for Phase171 publication

[storage-proposal01.json](storage-proposal01.json) freezes **14 exact files in
11 retired roots**, totaling **1,214.914 MiB allocated**. A provisional 14%
compression estimate gives **1,044.826 MiB recovered**. The 20 MiB cap on every
root gives a more conservative conditional recovery of **994.914 MiB**; thus
1 GiB net is plausible, not guaranteed. Measure actual free space after each
stage. No targets, captures, archive verification or pruning ran in this review.

Phase171–173 contained roughly 1.73 GiB of files larger than 1 MiB, but much of
that is protected compiler/profile/validation state, executables or failures.
Retiring many small source/API snapshots would require more ownership work and
offer less capacity. The selected older bulk has clear producer and consumer
evidence. No source/API or executable is selected anywhere.

| Stage | Selected generated bulk | Roots / files | Allocated MiB |
| --- | --- | --- | ---: |
| 1 | Four old Phase147 profile preparations: copied `inputs/program.ssa` only | 4 / 4 | 451.199 |
| 2 | Phase146 N1 SSA, Phase147 successor Q3 SSA, successor N2 assembly/object | 3 / 4 | 334.977 |
| 3 | Three old profile stdout QBE streams and three Phase144 graph dumps | 4 / 6 | 428.738 |

Stage1 alone recovers **at least 371.199 MiB**, conditional on successful
20 MiB capped captures and excluding small receipts/concurrent writers. This
is the first tranche for the imminent native chain. Process each root fully
before the next; no simultaneous archive scratch is needed. Every selected member
is smaller than 128 MiB. The original four profile preparation receipts explicitly
authenticate their copied SSA. Their listed guards are completed downstream build
consumers, **not invented guards around the original metadata-copy operation**.
The proposal records this distinction and pins both ready and copied build reports.

The [single active-reference audit](storage-reference-audit01.json) covered
5,114 files / 401.41 MB in 3.52 seconds: maintained host tooling, manifests and
installed metadata, and Phase170–174 build/test/experiment/implementation metadata.
No candidate root appears in current profiling, selectors or publication inputs.
Two maintained references to `p146-context01-n1` require its **executable**, which
remains hot. The graph census appears only in an earlier storage review. This is
a scoped operational audit, not a theorem about arbitrary future dynamic paths.
Newly introduced consumers must still be checked before capture.

The three selected profile stdout files are complete generated QBE, byte-identical
to the old independently pinned compiler output. They are **not raw profiling
samples**. Keep historical diagnostic executables, objects, owner maps, unwind
metadata, samples, callers, contexts, analysis and reports. Reconstructing those
retired profiling builds or replaying a method that authenticates its old SSA or
stdout requires exact restoration first. Current Phase171 profiles remain untouched.

Keep the entire Phase170 installed/rollback/qualified chain, including its N2
fixed-point SSA oracle; keep Phase171 `native-candidate01` and its SSA, binary,
source, receipts and 77-control references. All Base/carrier/runtime/toolchain
inputs, source/APIs, current validation products, failures and shared lock remain
hot. Old native executables and their sources/runtimes also stay available.

Six selected SSA digests already occur in three Phase169 archive receipts.
Those are useful recovery candidates, but this review did **not** independently
reopen their streams. The maintained verifier checks `rawRoot`, so an old receipt
must not be silently rebased to another copy. Fresh bounded capture is the
immediately executable route; byte-exact archive reuse would need a separately
verified mapping. Existing archive receipts are preserved.

## First seven roots

Their proposal rows contain exact capture/apply/restore command arrays. For example:

```sh
python3 -B experiments/phase169/archive-selected-v02.py \
  --proposal experiments/phase174/storage-proposal01.json \
  --name p174-retired-p147-profile-prep01-ir \
  --out selfhost/build-retention/phase169/p174-retired-p147-profile-prep01-ir
```

Inspect the verified exact plan, then separately apply:

```sh
python3 -B selfhost/tools/build-retention/archive-v02.py apply \
  --plan selfhost/build-retention/phase169/p174-retired-p147-profile-prep01-ir/verified/plan.json \
  --out selfhost/build-retention/phase169/p174-retired-p147-profile-prep01-ir/applied
```

Root must enforce **5 GiB + 20 MiB**, with extra room for receipts, before each
call: the frozen Phase169 helper internally checks only 4 GiB. All maintenance
shares the existing nonblocking Phase32 execution lock. Wait until targets finish.

## Last four roots

[capture-storage01.py](capture-storage01.py) is a narrow adapter for the four
explicit nonstandard filename roots. It pins the frozen proposal and existing
Phase169 helper, whose bounded output wrapper it reuses. It uses the unchanged
maintained archive verifier, applicator and restore format. `close.capsule` lacks
the required hard 20 MiB compressed-stream cap, so it is not called. Existing
sealed lifecycle records are not reopened or modified.

The adapter checks exact report/guard identities, completed writer status,
allowlisted paths, current hashes/inodes/modes, exclusive ownership, a 128 MiB
member bound and **5 GiB + 20 MiB + 2 MiB** initial reserve. It streams a capped
archive, checks reserve while writing, reopens and hashes every member and gzip
footer, checks metadata stability, and asks the maintained verifier for the exact
plan. It never runs a target, deletes a file, changes selectors or rescans the
dependency graph. Failure retains all original files. Syntax was checked with
`ast.parse`; neither preflight nor capture was executed by the storage agent.

Exact adapter names:

- `p174-retired-p147-profile-full02-stdout`
- `p174-retired-p147-profile-final-full01-stdout`
- `p174-retired-p147-profile-candidate-full01-stdout`
- `p174-retired-p144-product-graphs`

Example capture after root review:

```sh
python3 -B experiments/phase174/capture-storage01.py \
  --name p174-retired-p147-profile-full02-stdout \
  --out selfhost/build-retention/phase174/capture01-p174-retired-p147-profile-full02-stdout
```

Use the unchanged applicator separately with that output's `verified/plan.json`
and a fresh `applied` directory. Keep every capsule, plan and application journal.
No directory deletion, protection override or automatic cap increase is authorized.
If final recovery falls below 1 GiB, report the measured result before expanding
the selection. The build guard/asset selectors are unchanged by this work.
