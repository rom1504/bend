# Phase144 evidence and native recovery artifacts

`evidence.tar.gz` contains11,344 files /332,016,860 uncompressed bytes.
Compressed size46,116,414 bytes; SHA-256:
`59c89f0f41432c030cb1a2757bb89f528f2d62eb97577e7032c6e833f4666419`.

The [inventory](inventory.json) authenticates each member and the method.
Archival reopened every member, checked content/mode/order, and rehashed the
original inputs. Final04 source, native N2 object/executable and runtime are
included, alongside the immutable qualified final03 fallback, full profiling
artifacts and failed experiments. Existing Phase144 checkpoint/serial capsules
and the Phase143 archive remain separately authenticated dependencies.

This is a research recovery capsule, not a portable release installer. Receipts
retain original absolute paths and platform/tool identities. For replay, use a
fresh checkout or isolated recovery directory; inspect the inventory before
extracting and revalidate relocated inputs. Large regenerable QBE/assembly and
ordinary program binaries are deliberately excluded, with reasons recorded.
Source and execution recipes remain in the repository.

The selected production/default compiler is unchanged. Follow the
[qualified candidate](../final04/candidate.json),
[report](../README.md) and [cold native guide](../../../docs/self_hosted/cold-native-development.md)
for the explicit runtime and correctness scope.
