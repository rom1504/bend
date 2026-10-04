# Phase45 release evidence

[The index](selected-release.json) binds the installed worker23 API AND runtime,
standard selected qualification, fresh mechanism/focused controls, runtime and
compiler-cost summaries, diagnostics, protected inputs and the
[closed raw archive](raw/archive.json). Worker22 shares the compiler API hash but
has a different runtime; API equality alone does not renew its observations.
The qualification receipt predates installation and retains its original
`installed: false`; [installed checks](installed-release.json) bind the later
normal install, verification and all 42 CLI checks.

The [portable publication](portable-publication.json) records the selected bundle
and the atomic exchange that retained the displaced 17b files. The
[rejected17b retention](rejected17b-retention.json) and index preserve historical
references by both recorded path and SHA256. Two old `current/manifest.json`
identities resolve to distinct preserved bytes. Never resolve them by path alone.
The [baseline](../baseline/manifest.json) and [current](../current/manifest.json)
bundles are portable artifacts, separate from their absolute acquisition history.

The streamed archive was reopened against every original member hash and checked
for input stability. It preserves every regular file below
`selfhost/build/phase45`, including failed, rejected, interrupted and uninstalled
experiments. Candidates24/25 or any later uninstalled experiment receives no release
credit merely because its files appear in this archive. The preserved
[failed strict Nat probe](number-nat-failed-probe.json) remains counter-evidence,
not a passing conformance gate. No writes to the closed raw root are authorized.

The capsule contains **55,014 files / 1,194,248,393 logical bytes**. Its verified
gzip stream is **173,957,843 bytes**. It is published as five parts, each at most
40 MiB, to fit ordinary Git hosting limits; the unsplit local file is ignored.
The [parts manifest](raw/parts.json) binds their ordered sizes and hashes to the
exact archive hash in [archive metadata](raw/archive.json). The split publisher
reopened all parts and verified their concatenated hash and byte count.

The portable benchmark bundle needs no raw-campaign extraction. To inspect the
full historical campaign, first reassemble the gzip file from the repository root.
This command refuses to overwrite an existing file; if already reassembled,
verify its hash instead.

```sh
(
  cd selfhost/tools/performance/phase45/evidence/raw
  set -euC
  cat raw-campaign.tar.gz.part-000 raw-campaign.tar.gz.part-001 \
      raw-campaign.tar.gz.part-002 raw-campaign.tar.gz.part-003 \
      raw-campaign.tar.gz.part-004 > raw-campaign.tar.gz
  printf '%s  %s\n' \
    3ab22dcd35b5b1158f35d518c46914185a5df6affb7cb8b83ff253541df3c703 \
    raw-campaign.tar.gz | sha256sum --check
)
```

Extract the full campaign only into a fresh directory:

```sh
mkdir -p selfhost/build/phase45-recovered-NEW
tar -xzf selfhost/tools/performance/phase45/evidence/raw/raw-campaign.tar.gz \
  -C selfhost/build/phase45-recovered-NEW
```

Archive members are relative to the raw root. Receipts retain their original
absolute execution paths; relocation does not authorize rewriting their bytes.
Use the [portable benchmark guide](../README.md) for new measurements. The
[phase report](../../../../../implementation/phase45/README.md) separates measured
execution gains, compiler costs, source growth and remaining conformance limits.
Fresh selected mechanism groups overlap and are not summed into a unique-test
total. Historical owner campaigns, GPU execution and a new self-emitted fixed
point are not claimed.
