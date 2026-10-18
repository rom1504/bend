# Phase108 — full compiler through QBE (work in progress)

[Design](../../design/phase108/full-native-qbe.md) ·
[Lowering audit](lowering-audit.md) · [Runtime audit](runtime-audit.md) ·
[Toolchain audit](cproc-audit.md) · [Frozen coverage](coverage-audit.md).

The implementation adds an explicit portable CPU segment trampoline and four
register-state macros emitted by Bend. The compatibility route is
**Bend → existing Bend C lowering → cproc → QBE → GNU assembler/linker**.
It reuses the existing ownership, closures, arrays and IO decisions. This is
separate from Phase107's direct Bend → Nx → QBE scalar path.

Initial observed gates (2026-10-18, work continuing):

- GCC and QBE portable runtime execute a100,000-step recursive scalar control with
  exact independent result705082704.
- QBE-produced real list reversal (retained aliases), held-out Unicode String
  reversal, captured higher-order function and non-tail list recursion all pass
  their frozen expected outputs. `selfhost/build/phase108/coverage-qbe01` retains
  this incomplete screen and an array fixture source-syntax failure.
- The toolchain smoke checks actual constructor registration before main,
 128-byte alignment, two-thread32/64-bit atomics, compare/exchange and aggregate
  ABI. Six invalid constructor annotations reject. These are boundary checks,
  not full compiler correctness evidence.
- Trusted native B2 emitted the modified full compiler source in144.389s through
  the portable runtime; guarded process-tree peak RSS1.31GiB. The29MiB full C image
  is now undergoing cproc/QBE acquisition. No full QBE compiler claim yet.

Clang-specific tail calls are replaced by ordinary segment calls returning to an
invocation-local dispatcher. No generated program bodies are rewritten. A temporary
bootstrap bridge adds exactly the four register-bank macros missing from the old
trusted producer; the newly compiled Bend source emits those macros itself.

cproc required a small explicit constructor-registration extension and QBE needed
an alignment-field fix to represent128. A small GCC-built atomic/CLZ boundary
retains real synchronization. GNU preprocessing/assembly/linking and C remain
parts of this path. No claim of toolchain independence or native x86 code emission
from Bend is made.

Installed compiler selection is unchanged. Behavioral, bootstrap, timing and
promotion decisions will be recorded separately as the remaining gates finish.
