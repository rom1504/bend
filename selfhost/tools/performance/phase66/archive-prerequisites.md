# Known external prerequisites for the Phase66 evidence archive

This is a metadata inventory, not a self-contained compiler distribution or a
proof that every dependency has been restored. [archive-prerequisites.json](archive-prerequisites.json)
pins the exact existing metadata and normalizes known external raw references.
Only metadata files were read and hashed. No archive bytes, historical raw tree,
compiler target, executable or shared library was revalidated here.

The selected frozen compiler state is now **attempt07** (`f9667c2`): selected
B1 `bb6c6e2a…`, assembled source `1b29d5c4…`, and actual B2 `0067736c…`.
Its exact source/census/own-source/reproduction/emission/frontend metadata are
pinned separately in `selectedCampaignState`. Earlier04 toolchain identities
remain historical provenance, not a selection of attempt04 or05. Final07 compiler
and generated-program timing, frontend/JS comparison, Base/native admission,
compiler qualification and installed-release verification are all closed. Final
time accounting and prior-evidence preservation also pass; their actual receipts
are pinned in the selected-state metadata. Failed06, every prior
04/05 result and all Bun evidence stay in the complete raw inventory.

## Capsule mappings

| Required historical inputs | Published metadata | Transport and member names |
| --- | --- | --- |
| Phase65 checked State10, actual B2 bootstrap, exports, final qualification/program modules and latency methods | [manifest](../phase65/artifacts/manifest.json) | Two ordered parts of one gzip tar stream; members have repository-relative paths. |
| Phase63 checked State09 inputs | [manifest](../phase63/artifacts/manifest.json) | One gzip tar; members have repository-relative paths. |
| Phase58 final-last01 and final-performance-last01 | [archive](../phase58/artifacts/raw/archive.json), [transport](../phase58/artifacts/raw/transport.json) | Three ordered parts of one gzip stream; member names are relative to `selfhost/build/phase58`. The logical joined filename need not exist. |
| Phase55 bootstrap source/driver plans and checked-host02 core source | [archive](../phase55/artifacts/raw/archive.json) | One gzip tar; member names are relative to `selfhost/build/phase55`. |
| Phase45 qualification23/backend/pilot.json | [archive](../phase45/evidence/raw/archive.json), [parts](../phase45/evidence/raw/parts.json) | Five ordered parts of one gzip stream; member names are relative to `selfhost/build/phase45`. Do not rely on an ignored local joined file. |
| Phase22 context-build-16/api.mjs for historical profile replay | [manifest](../../../../implementation/phase22/context-evidence/capsule-01/manifest.json), [inventory](../../../../implementation/phase22/context-evidence/capsule-01/inventory.json) | Thirty-six independent XZ tar archives, not concatenated transport pieces. The required API is in `experiments-08.tar.xz`; paths are repository-relative. |

The JSON records exact required members, matching prefix counts and digests of
the corresponding manifest rows. Those prefixes describe known restore groups;
they do not assert that every member was consumed by Phase66. Their counts come
from manifests, without scanning historical raw directories.

Phase22 retains the original capture's `recoveryPending:true`. Its separate
[preservation](../../../../implementation/phase22/context-evidence/preservation.json)
and [successful recovery](../../../../implementation/phase22/context-evidence/recovery-final-01.json)
close that state. The materialized API member can satisfy this narrow known
input. Full Phase22 source reconstruction additionally uses its original
[recoverer](../phase22/context-recover-v3.py), baseline commit/patch and declared
Phase16–21 prerequisite chain, copied into the JSON with metadata identities.
This inventory does not qualify that entire transitive replay anew.

## External tools and source checkouts

- Node `v24.18.0` is recorded by checked-b1-04 with SHA256
  `41a74efb34cbde5c7632cdac0cf8bd1a14d0b8d73dc1e82755014d9a9ce70f5c`.
  Keep each recipe's flags, CPU affinity and resource settings; the Node binary
  and its system dependencies remain external.
- Old upstream `018751270e800bc222a93dad7f257083ee53a5f7` and new upstream
  `059266225b77c8ca256ac6b25ee5c21449bab151` are separate denominators.
  The JSON retains their recorded checkout paths and six core file identities
  from `upstream-delta.json`. Checkouts also need their tests, adjacent foreign
  assets, provider sources and native headers; consult each recipe's full closure.
- Native controls bind Clang16 and its two shared libraries plus the exact
  `CC`, `CPATH`, `LIBRARY_PATH` and `LD_LIBRARY_PATH` overlays in the actual04
  Clang recipe. The JSON retains those original pins and small download-log
  identities. The Debian package versions are `1:16.0.6-15~deb11u2` for the LLVM
  toolchain and `1.2.4-1.1` for ALSA. No published Phase1 toolchain capsule was
  identified; the binaries, include/lib trees and system dependencies are explicit
  external prerequisites. Three binary hashes do not enumerate the whole sysroot.
## Bun captured inside this campaign

Bun `1.4.2` is preserved under `selfhost/build/phase66/bun-toolchain01/`:
its official release JSON, acquisition receipt, **36,646,985-byte** verified zip
and **79,500,640-byte** executable (mode `0755`) all belong to the Phase66 raw
inventory. The JSON records the published zip digest and acquired binary hash.
Bun is therefore not an external binary prerequisite for this capsule. This
metadata update does not rehash those binary bytes or establish FFI execution;
root's focused replay of emitted artifacts is a separate gate from both
acquisition and the full Node inventory. System/FFI dependencies still need
their recorded host facilities.

## Verification boundary

Verify metadata pins, then every transport part's bytes/hash and each complete
logical gzip stream before opening it. For Phase22, open the independent XZ
archives separately and retain its typed member, mode and link rules. Verify
required members against the original inventories and restore only into absent,
properly scoped paths. Historical absolute paths need explicit fresh bindings.
No archive transport was hashed or extracted while producing this inventory.

The Phase66 archive must retain every raw file, including malformed JSON,
failed/interrupted receipts, complete stdout/stderr and generated output. Parsing
or success filtering is not an admissible archive selector. Writer closure,
archive integrity, dependency availability and compiler qualification are distinct
claims. Any unmet external prerequisite must remain explicit.
