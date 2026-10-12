# P72-001: preserve flat products across private worker boundaries

Hypothesis: some native runtime deficit comes from materializing an already
known product between a producer and a consuming call/loop. Connecting existing
product mechanisms can remove it without another optimizer subsystem.

First falsifier: BST has a flat bst.down result reboxed before insert.fin.
Compare a saved-C direct-field call with the unchanged original and upstream,
using the same inputs, independent checksums, toolchain, affinity and warmups.
Small/no benefit disproves this boundary as a substantial BST cost, even when
the source allocation disappears. Phase71 independently establishes Array.map.

Production admission must preserve ownership, demand, errors, public ABI and
opaque fallback. Demonstrate on additional finite controls and independent
families before claiming general benefit. See [design](../../design/phase72/product-transport.md)
and eventual [report](../../implementation/phase72/README.md).
