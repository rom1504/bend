# P71-001: eliminate temporary product transport in saved C

Prospective hypothesis: Array.map's per-element array/value Tuple allocation,
sealing and take are a material part of its2.45×runtime gap. A diagnostic
private-loop ABI carrying fields separately should remove this traffic while
retaining array effects, scalar arithmetic, order and ownership. First inspect
exact bodies; decline edits whose correctness boundary cannot be isolated.

Compare original, intervention and upstream with shared inputs/work and rotated
order, at least3samples/arm and100ms intervals. Validate independent digests.
No unshared permission broadening, error removal, benchmark-answer replacement
or source-name-based production optimizer. Retain originals and failed attempts.
If a second case does not support the mechanism, do not claim generality.

Result: product01 passes9/9qualified intervals;735→567ms vs302msupstream,
22.86%less time. One algorithm family only. Related BST call-boundary box/unbox
identified but not timed. No production promotion or second intervention.
See implementation/phase71/README.md and retained source patch.
