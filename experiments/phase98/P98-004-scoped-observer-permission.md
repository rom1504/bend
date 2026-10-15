# P98-004: separate observer permission from array representation

Status: permission02 plus the lazy ancestry correction passed final native B1/B2 qualification. The original hypothesis below is retained; see the [final report](../../implementation/phase98/README.md).

The actual file-IO comparison control establishes that native B2's emitter
disables borrowed observers together with scalar arrays. Upstream-built B1 can
therefore benefit from held string roots while B2 still consumes the strings.
The two stages need separate evidence.

Hypothesis: admit existing observer analysis under an independent certificate for
the native host's nine authenticated providers. Retain the old array narrowing,
unshared-array and constructor-sharing permissions. This may remove shared-root
ownership traffic in B2; it also adds analysis to compilation and enables existing
planned-worker routing, so attribution must inspect both effects.

The isolated first candidate adds37 lines. The exact replay is
`selfhost/build/phase98/observer-permission-source01/changes.json`;
[source review](../../implementation/phase98/observer-permission.md) documents
the scalar ABI, provider behavior and residual/schema exclusions. This is not
a claim that names alone authenticate providers or that observer C is verified.

First qualify18 finite certificate inputs and real IO, generic-array and rejected
schema controls. Use a checked upstream JS acquisition of the exact candidate
emitter for this small loop; avoid rebuilding a full native compiler until actual
emitted routes and outputs support it. Preserve original negative outcomes.
Any checked-entry change must retain raw-entry refusal and provider-byte checks.

Then measure actual B1 and B2 separately, including self-emission, conformance and
generated-program execution. Intentional emitted C changes need semantic and
runtime gates; historical C identity is not their acceptance criterion. A B1
speedup from a source wrapper is not evidence of a B2 speedup from permission.

Laws should constrain real extracted helpers and complete values. A safe helper
for the exact allowlist and its trust/fill guards can have universal obligations;
those cannot establish external byte authenticity, native lifetime, or soundness
of every unsafe analysis caller. Record this boundary explicitly.
