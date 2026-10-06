# P56-002: primitive native string equality at function definitions

Hypothesis: the direct compiler image spends enough time implementing equality
through general string comparison that native equality will improve self-hosting
without changing the native string ABI.

Design: [native equality and call-order boundary](../../design/phase56/native-string-equality.md).
Evidence: the original profiled self-check puts 17.6% of ticks in String.cmp and
its recursive helper. The accepted implementation adds two lines and no helper.
Definition-only lowering retains call boundaries; call-site expansion would
change an existing composed-callback order and was not adopted.

Correctness: 484 UTF-16 pairs, eight callback/order/partial/throw controls,
native-name/refusal checks and broader B2 semantics pass. B2 freshly type-checks
all source and emits a byte-identical B3 in 250.72 seconds; the previous image
exceeded 300 seconds. The profiled/unprofiled type-check times do not establish a
controlled speedup ratio. [Detailed result](../../implementation/phase56/string-equality.md).

Runtime retention: 44 of 45 points are byte-identical; changed map/set execution
takes 15.9% less time in five fresh paired rounds. All 45 B2 point modules match
selected B1 bytes. [Performance](../../implementation/phase56/performance.md).

Decision: retain after combined release qualification. Compiler-throughput parity
remains open; the [latency screen](../../implementation/phase56/latency.md) measures
the checked and direct images against the same pinned TypeScript compiler.
