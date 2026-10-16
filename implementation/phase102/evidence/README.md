# Frozen Phase102 evidence

`phase102.tar.xz` preserves34,940 files at their original repository-relative
paths:2,962,996,748 uncompressed bytes,82,830,600 compressed bytes. SHA256:

```
89b32e313e371eadd3bed772a7bcf3ac593f8b1c5c990af2c923327a37d6ad02
```

The [receipt](receipt.json) and [manifest](manifest.json) record every file's
identity and mode. The archive method read back and hashed every member, checked
the inventory, and verified the explicit request-receipt bindings. This is a
verified preservation archive, not a claim of executing a clean restoration.
Failed and stopped experiments are retained, including the420s Clang timeout,
early rejected sources and the superseded projection activation snapshot.

Included roots are all Phase102 build evidence, Phase99's Phase102 acquisitions/
comparisons/releases, the exact unchanged Phase99 runtime method snapshot, and
the nine public CLI request directories named by the completed CLI report.
Unrelated native requests and unrelated working-tree edits are excluded.

The final time account is at
`selfhost/build/phase102/time-account-final.json` inside the archive. Final03
native admission is at `selfhost/build/phase102/native-chain03/admission.json`.
Candidate04 source/API/emission experiments remain explicitly unqualified as
native images. The [machine-readable summary](../results.json) binds the key
receipts and distinguishes all timing scopes.

For inspection, extract into a fresh directory rather than overwriting a live
checkout:

```sh
mkdir /tmp/phase102-evidence
tar -xJf implementation/phase102/evidence/phase102.tar.xz -C /tmp/phase102-evidence
```

Historical methods use the recorded canonical root
`/home/ai/bend2/build/publish/bend`. Re-executing the gates additionally requires
their pinned toolchain and earlier Phase98/Phase100/Phase101 fixtures/capsules;
this archive does not duplicate every prior dependency or make paths relocatable.
Resolve existing-file conflicts by comparing the manifest, not by overwriting
local work. For ordinary candidate03 compilation, the much smaller
[request capsule and guide](../../../docs/self_hosted/NATIVE_PHASE102.md) suffice;
its restore command verifies existing assets and restores missing ones.
