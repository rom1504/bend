# P78-006: share one tag discriminator instead of a closure chain

Compiler11 profiling still shows substantial generic B1 trampoline work. The
central lowering entry distinguishes roughly thirty short string tags by nested
higher-order conditionals. Prototype an exact String-pattern discriminator to a
U32 kind, then one direct numeric match. This preserves unknown-tag fallback and
all branch-local demand. It is a small typed dispatch boundary, not 160 helpers.

Require a checked bootstrap and exact C from executed compiler11, then measure.
If useful, shared discriminants can serve erasure/layout/use passes; do not expand
before the first screen. No kernel term ABI or prepared-cache format changes.
