# Bounded product-difference summary

The first metadata scan preserved in `owned-generation-diff08` exceeded its
12MiB job-output allowance after13.9s because many symbol bodies differed. Its
method and failed output remain unchanged. Explanatory metadata does not require
copying every declaration-comparison row into retained artifacts.

Use the separate `selfhost/tests/phase173/qbe-generation-diff-v2.py` with the same
arguments as [the original recipe](qbe-generation-diff.md), but a fresh output
directory such as `selfhost/build/phase173/owned-generation-diff09`. Run after
storage recovery and outside controlled target timings. The author prepared and
syntax-parsed this revision without scanning products or executing targets.

All archive/member/report/source/runtime/toolchain checks, bounded QBE streaming,
and independent N2/N3 ELF64 `PT_LOAD` comparisons are retained. The full input
products are still consumed and every symbol comparison is accounted for.

The sole output, `report.json`, is streamed through a hard2MiB total limit:

- Complete identical/changed/added/removed declaration counts.
- Complete old/new declaration bytes and status counts by compiler-symbol family.
  More than512 distinct families are counted in an explicit overflow category.
- An SHA256 and encoded-byte count covering **every** comparison record, including
  identical records, in sorted `(kind,symbol)` order. Each canonical record is
  compact ASCII JSON `[kind,symbol,status,old,new]` plus LF; an old/new item is
  null or `[bytes,sha256,newlines]`. The record stream is hashed, never written.
- At most100 differences, ranked by absolute byte delta, then larger body size.
  Names and decoded FID identities are limited to256 characters with explicit
  truncation flags, full symbol length and SHA256. Old/new hashes remain exact.
  The number of unlisted differences is explicit.
- Exact product identities, byte partitions, loaded-image comparisons and timing
  for this metadata scan.

No full SSA copy, per-symbol dump, giant JSON collection, compiler execution or
IR transformation is introduced. Counts and byte totals are cross-checked
against the complete declaration indexes before publishing the result. Small
output is not evidence that few functions changed, nor that all textual changes
represent distinct optimization admissions.
