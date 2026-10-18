# Phase110 evidence and replay

The sealed capsule is [observations.tar.gz](observations.tar.gz), with adjacent
[manifest.json](manifest.json). Its 11,396 verified members occupy 228,699,592
uncompressed bytes; the archive is 28,197,853 bytes. Its SHA-256 is
`49544bec712e6b4008f8c0a23f2153b18f0f1bfffbf655c070a54a713a423319`.
Require `complete: true`, `allMembersVerified: true`, and an archive hash matching
the actual bytes before restoration. The manifest supplies every member's byte
count and SHA-256 hash. The [phase report](../README.md),
[experimental selection](../selection.json) and
[native instructions](../../../selfhost/tools/performance/phase110/native/README.md)
describe the supported behavior and qualification limits.

The capsule includes current `selfhost/build/phase110` observations, prepared
controls, sources, products, runtime objects and executables; Phase110 native
acquisitions under `selfhost/build/phase108/p110-*`; its Phase109 preservation
run; Phase110 law runs under Phase98; Phase110 tool sources; machine analyses;
and selection/accounting records. All five retired checked captures are present
at their original paths: two had already been restored and three were merged
from the retired archive. All were authenticated against
`selfhost/build/phase110/cleanup06.json`. Historical failures and later
diagnostics remain evidence; their presence does not add them to the frozen
selection.

The two external data assets used by the selected image are also included.
Their current bytes independently match the
[native-source05 manifest](../../../selfhost/build/phase110/native-source05/manifest.json):

| Repository-relative asset | Bytes | SHA-256 |
| --- | ---: | --- |
| `selfhost/.bootstrap/upstream-phase66/bend2/base.bend` | 75,064 | `99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf` |
| `selfhost/tools/performance/phase88/base/carrier01/base.p88` | 1,100,924 | `07af8cddb84820d861fc9f5d9475907754a64a9319de7d597c925149d8b186a7` |

Existing-image replay uses
`selfhost/build/phase108/p110-native-source05/image/program`, pinned by
`selection.json`, with the `compact-general` profile and
`runtime-ir-single` policy in one active CPU context. General live requests read
Base; the original fixed cached route reads the cache carrier. The image embeds
absolute asset paths beneath `/home/ai/bend2/build/publish/bend/`. Moving the
executable or extracting into a different checkout does not rewrite those
paths. Preserve the recorded locations, or prepare and acquire a new image with
the new paths and qualify it separately. The installed production compiler was
not replaced.

Reusing the saved worker products requires their recorded ABI, harness and
runtime object. For native semantic qualification, that object is
`selfhost/build/phase110/general-build01/runtime.o`; use the individual receipt
pins for other workers rather than substituting a similarly named object.
The current capsule contains these Phase110 products. Ordinary native compiler
requests do not invoke JavaScript, Python, Clang or cproc; compiling and linking
their emitted worker products remains a separate step.

Reacquiring the native image or rerunning the full qualification chain has
additional dependencies outside this capsule:

- The committed earlier-phase source modules and launch/guard/build tools,
  plus the selected mature seed at
  `selfhost/build/phase102/native-chain04/b2/compiler` and its pinned admission
  and source records.
- The Phase108 portable image runtime at
  `selfhost/build/phase108/portable-source04/runtime.c` and its five part files,
  the earlier effect-runtime sources, and earlier checked captures such as
  `selfhost/build/phase109/capture02`. Their original manifests and evidence
  capsules remain the authority for bytes removed by authenticated cleanup.
- The original pinned QBE/cproc acquisition, host assembler/linker/GCC and
  Python environment. Hosted emission checks additionally use their recorded
  Bun/typed-API tools; proof replay uses its recorded proof toolchain. Clang is
  needed for the optional matched C controls. No complete external toolchain
  is copied into this capsule.

Follow `native-source05/manifest.json` and the acquisition/qualification
receipts for exact dependency hashes and commands. Their paths are often
absolute. Full receipt validation can require historical inputs that the
already acquired image does not read during an ordinary request. Recover
missing historical bytes from the corresponding Phase107/108/109 evidence
capsule only after checking its archive and member hashes; do not weaken a
validator to bypass a missing input.

For restoration, first inspect and authenticate the manifest and archive.
Validate every selected member's name, length and SHA-256; reject absolute
names, traversal, links and duplicate members. Restore only absent
repository-relative build files and, when needed, the two exact asset paths
listed above. Preserve executable modes for saved binaries. Leave existing
source/tools untouched; an existing destination must match its recorded pin
before reuse. Do not extract the entire archive over a live working tree.
The capsule's tool-source copies support inspection and comparison; restore
the repository's source revision through the normal source-control workflow.
