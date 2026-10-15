# Phase93 native runtime evidence

`raw.zip` preserves every file under `selfhost/build/phase93` at completion:
4,798 files, 45,074,590 uncompressed bytes. Archive SHA256:
`11eefc062e398ffe1003f9ad82d5a810e7a069b79837dc8f8a1093ed69a58bd1`.
Compressed size:11,033,700 bytes. [Manifest](manifest.json) · [Receipt](receipt.json).

Every member was read back, hashed and compared with the live original before
publication. This includes generated sources, successful acquisitions, C and
ELF products, all calibration/final/scaling observations, diagnostic disassembly,
the initial offline assertion failure and the zero-work calibration failure.
Historical compiler/input dependencies keep their prior committed archives.

Restore into a fresh directory, preserving member paths and ZIP file modes.
Verify each member's SHA256 and length against `manifest.json` before use. Python's
`zipfile` can read individual members; do not overwrite active experiment files.
Recorded absolute paths name the original repository root, so move recovered
members deliberately or restore matching repository-relative paths when absent.

Acquisition reports contain `cases[].deduplicated` mappings: each removed B1
C output equals its retained B2 output in full. Reconstruct the former path by
copying the latter and verifying the recorded length/hash. This deduplication
does not remove a distinct compiler product or observation. Native B1/B2 runtime
measurements intentionally share one binary after their C identity gate.

The two older Phase90 self-output duplicates reclaimed for disk headroom are
covered by the separate [reclamation receipt](../../../../../implementation/phase93/reclamation.json)
and its original committed Phase90 archive, not duplicated into this capsule.
