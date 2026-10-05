# Phase53 compact publication recipe

Prepared without compression, target execution or raw-output changes. Root must
select the final checked image and authorize each execution. Phase52 artifacts
remain immutable. Publication preserves evidence; it does not turn a failed
semantic gate into a pass.

## Reuse and output shape

Use these existing algorithms unchanged through the small
[pinned adapter](publication-wrapper.py):

| Mode | Existing method | What it establishes |
| --- | --- | --- |
| `candidate` | [Phase52 freezer](../phase52/freeze-candidate.py) | Complete actual checked acquisition, 45 points/23 source identities, exact generic-row observer, bounded archive and reopened hashes |
| `verify` | [Phase52 portable verifier](../phase52/verify-portable.py) | All 135 point/role mappings equal the measured acquisitions through the maintained bundle reader |
| `archive` | [Closed campaign archiver](../phase42/validation/archive-campaign-v1.py) | One streamed archive of all closed raw files, including failed attempts; independent reopen, source rehash and inventory stability |

No functional source substitution is needed in these methods. Their historical
receipt kinds and the candidate's historical display label stay unchanged.
The adapter pins methods/dependencies, runs their original CLIs, rechecks those
pins, and adds a separate `phase53-publication-adapter` receipt. It never copies
or dynamically patches their implementation. Final user-facing Phase53 labels
belong in the publication index/README, not rewritten historical receipts.

Publish only:

```text
phase53/bundles/current/{manifest.json,provenance.json,programs.tar.gz}
phase53/bundles/baseline/{manifest.json,provenance.json,baseline-binding.json,programs.tar.gz}
phase53/artifacts/raw/{archive.json,raw-campaign.tar.gz}
phase53/publication-*.json
```

A small final index may point to a few selected qualification/runtime/accounting
summaries. All detailed compiler images, source snapshots, process directories,
failed attempts and repeated acquisitions live in the single raw archive.
**Do not repeat Phase52's 13,930-file review packet**, recursively copy a raw
directory into a second evidence tree, or include an old campaign archive inside
this one. The runnable bundles are deliberate small replay artifacts; the raw
archive owns complete history.

## Original direct06 and TypeScript reference

The already-created `selfhost/build/phase53/reference-direct06/` is the correct
baseline: original selected direct06 API
`472da578ff9066413f0a2b8e5c0053b5bc26eae8c3cb343b5b0cbb2a62c03a3a`
plus unchanged pinned TypeScript output. It contains 45 points, **48 distinct
modules** (24 per role, including the additional complete-row observer), and a
217,186-byte archive. Its four files total 272,147 bytes. Copy those four files
byte-for-byte to the fresh `bundles/baseline/`; do not repack or substitute the
later corrected01 baseline used for some isolated experiments.

Manifest SHA-256:
`37be3740c46d98c16342448e5082313a49fdc32da806e10a75ce694934faa3d0`.
Archive SHA-256:
`92e36a185c6ab3471b4ee8a38efcac78c26c3bd0365874c8aacc3cc6c1e71995`.
The [existing reference freezer](freeze-reference.py) created this compact
role remapping; rerunning it is unnecessary. Its `baseline-binding.json` binds
the compiler and manifest hash; original absolute paths are provenance, not
runtime module dependencies.

## Freeze and verify before closing raw writers

Root supplies `P53_ATTEMPT` and `P53_PREPARED` from the final selected release
decision. Do not select the newest directory by timestamp. The acquisition must
contain all 45 points and all 23 source receipts from that exact checked image.

```sh
P53_METHOD=selfhost/tools/performance/phase53/publication-wrapper.py
P53_CURRENT=selfhost/tools/performance/phase53/bundles/current
P53_BASELINE=selfhost/tools/performance/phase53/bundles/baseline
P53_CATALOG=selfhost/tools/performance/phase37/catalog.json

python3 -B "$P53_METHOD" candidate \
  --phase53-receipt selfhost/tools/performance/phase53/publication-current.json -- \
  --from "$P53_PREPARED/manifest.json" --attempt "$P53_ATTEMPT" \
  --catalog "$P53_CATALOG" --out "$P53_CURRENT"

python3 -B "$P53_METHOD" verify \
  --phase53-receipt selfhost/tools/performance/phase53/publication-verification.json -- \
  --candidate "$P53_CURRENT/manifest.json" --baseline "$P53_BASELINE/manifest.json" \
  --prepared "$P53_PREPARED/manifest.json" \
  --reference selfhost/build/phase53/reference-direct06/manifest.json \
  --catalog "$P53_CATALOG" \
  --out selfhost/build/phase53/portable-verification.json
```

The freezer rechecks consumed preparation/emission tools, including their
recorded verifier files. Freeze before changing those files. If a consumed live
path has drifted, preserve the refusal and use the exact recorded bytes through
a reviewed successor; never replace old receipt hashes. Frozen snapshot source
copies, rather than mutable original provenance paths, bind the selected compiler.

The freezer streams archives with limits of 64 MiB/member, 512 MiB total and
4,096 members. It independently reopens every member and rehashes every input.
Its archive intentionally includes the final acquisition's receipts/logs as
well as deduplicated executable modules. Those compressed copies are already
part of this method; no additional loose evidence packet is needed.

After the data-only 135-mapping verification, root may schedule a fresh portable
smoke through [compare-v2.py](compare-v2.py). This is target execution and must
wait for the target slot; do not place an outer ExecutionGuard around the runner.

```sh
python3 selfhost/tools/performance/phase53/compare-v2.py \
  --baseline-binding "$P53_BASELINE/baseline-binding.json" \
  --baseline "$P53_BASELINE/manifest.json" --candidate "$P53_CURRENT/manifest.json" \
  --catalog "$P53_CATALOG" --budget 20 \
  --cases test-rle-roundtrip,test-morning-program,coverage-numeric-recurrence-1024 \
  --node /home/ai/.nvm/versions/node/v24.18.0/bin/node --cpu 3 \
  --rss-mib 2048 --available-mib 4096 \
  --out selfhost/build/phase53/portable-smoke01
```

Expected successful scope: three cases × three roles × three rounds = 27
samples, every call's exact result checked. This is portable replay, not a new
45-point result. Retain its report before closing the raw campaign.

## Close once, then create the sole raw archive

Finish all runtime/semantic/install/accounting/replay jobs first. Root obtains a
fresh 103-file audit with the unchanged `phase51/check-protected.py`, waits for
all raw writers to stop, and writes `selfhost/build/phase53/writers-closed.json`
as its final raw event. Its required fields are `complete:true`,
`writersClosed:true`, the exact absolute `rawRoot`, and selected `attempt`/`api`
file+SHA identities. Record closure time and qualification limitations too.
The final protected receipt requires `checked:103`, empty `changed` and
`protectedStaged` arrays, and the original protected-start identity.

```sh
python3 -B "$P53_METHOD" archive \
  --phase53-receipt selfhost/tools/performance/phase53/publication-raw.json -- \
  --raw selfhost/build/phase53 \
  --writers-closed selfhost/build/phase53/writers-closed.json \
  --protected-final selfhost/build/phase53/protected-final.json \
  --out selfhost/tools/performance/phase53/artifacts/raw
```

Both archive and adapter outputs are outside the now-closed raw root. The
archiver refuses symlinks, uses bounded streamed reads, verifies every archived
member independently, then confirms the original inventory and hashes have not
changed. It publishes through a fresh staging directory. Its limits are 2 GiB
per raw file, 64 GiB total and 500,000 members. Compression runs separately from
timing; no correctness or speed denominator is measured during it.

Finally, publish a small Phase53 index binding the selected release, qualification
limits, portable manifests/archives, replay report, raw archive/index and adapter
receipts. Reference archive member paths for detailed evidence. No additional
raw writes, copied snapshot forests, or retroactive “all semantics pass” label
belong in that step.
