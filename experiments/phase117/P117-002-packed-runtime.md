# P117-002 — recover the runtime's existing packed scalar arrays

2026-10-21; designed after P117-001 first pair measured1.38×/1.12× speedups.

New observation: the exact runtime already implements packed32-bit array creation,
clone, node/half, atomic access and shallow BUF destruction. The QBE factory has
an independently computed scalar/unshared certificate but currently selects only
uniform64 access. Reuse the mature representation rather than invent a new one.

Candidate: an additive descriptor capability selects packed arrays only from the
existing checked factory; a matching runtime accepts old and new descriptors.
Old descriptor behavior stays uniform. Old runtimes reject the new capability.
Change inline access to BUF tag4, location*8+wrappedIndex*4, zero-extended32-bit
loads/stores, retaining raw/dynamic guards and generic fallback. All runtime
producers/consumers must agree; static image already excludes array nodes.

Falsifiers: lawful scalar values not representable by the packed runtime; any
producer/consumer mismatch, differential output failure, incorrect sharing,
clone/half/atomics, or no useful complete-runtime gain. Use ordinary checked
functional controls and frozen benchmarks. No fault-injection campaigns.

This is an optional candidate, not installed promotion or native self-reproduction.

## Outcome

Packed capability is selected with GCC10-O2 runtime01. Complete selected45/ordinary controls pass. Scalar lifetime specialization transfers beyond the initial pair; old capability1 behavior and generic/shared fallbacks remain.

[Complete report](../../implementation/phase117/README.md) retains exact receipts and limits.
