# Expanded frozen-artifact deduplication

Root authorized an expanded exact-byte hardlink pass over frozen build phases111,
118 and120–125. Any path component containing `p126` was excluded, as were
Phase126 and symlinks. The prior helper and receipts were not modified.

Planning hashed801 distinct inodes and verified every selected duplicate pair
byte-for-byte. The immutable plan contains487 path replacements. Application
rechecked metadata, hashes and bytes before each atomic hardlink replacement,
then checked the surviving path hash and shared inode. Every original path and
its contents remain. Inodes/mtimes may change; frozen hardlinked files must never
be edited in place. No compression, relocation, compiler or target execution.

Recovered403,947,520 allocated bytes (385.23MiB). Plan13.14s; application20.62s.
Recorded free space afterward795,410,432 bytes (758.56MiB); concurrent outputs
may subsequently change free space. Recovered-byte accounting uses the last
reference to each old inode, independently of volume free-space movement.

- Helper: `selfhost/tools/performance/phase126/tooling/dedup-frozen-v2.py`.
- Plan: `selfhost/build/phase126/tooling-dedup-expanded-plan01/report.json`, SHA256 `af324799ec5ba2d2b9519dcf92dc52d853861f9c88270070ce3c187edd0f076f`.
- Applied: `selfhost/build/phase126/tooling-dedup-expanded-apply01/report.json`, SHA256 `273460f833f6a417749ab05546207cd523783c2b07a02c6ca9911aa8084e9d41`.

The original Phase125-scoped pass recovered12.8MiB separately; that earlier
receipt is unchanged and is not included in the385.23MiB above.
