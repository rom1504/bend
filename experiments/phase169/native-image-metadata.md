# Native versus hosted product identity: keep the distinction exact

The six final native acquisitions reproduce the checked hosted compiler's
complete QBE, assembly and object bytes, with the same runtime and toolchain.
All six independent program outputs pass. `quality-native-transfer.json`
records those successful comparisons.

A stricter offline check in `tools/compare-programs.py` deliberately requires
every mapped ELF byte to match. It **fails** on all six products; its result is
retained in `quality-native-transfer02.json`. Do not report mapped image identity
for these hosted/native products or treat this diagnostic failure as a program
correctness failure.

Inspection of the four PT_LOAD segments shows identical headers and identical
bytes in the executable, remaining read-only and writable segments. Differences
in the first segment are offsets40 (also41 for raytrace) and724–743. The former
is the ELF section-header offset; the latter is the20-byte GNU build-ID digest
inside `.note.gnu.build-id` at0x2c4. The native object filename is longer and the
nonloaded file layout changes. Complete file sizes differ by8–16bytes.

Thus code identity is supported, but full mapped-byte identity is false. The
final broad benchmark will measure actual native-acquired executables directly
instead of relying on an inferred runtime result.

This is separate from the native compiler's own N1/N2 comparison: those paths
have equal lengths, and `quality-reproduction.json` confirms complete mapped
image identity as well as exact QBE, assembly and object bytes.
