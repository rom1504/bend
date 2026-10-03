# Phase41 interim results

**Interim, not final admission.** The checked Phase41 source patch passed and
actual emitted tree output passed focused controls. A supplemental three-point
screen favors the wrapper candidate against fresh Phase40 checked06 output.
Integration and broader admission gates remain pending. [Canonical data and
receipt identities](results.json); [experiment design](../../design/phase41/tree.md).

The clean emitted wrapper's median execution time was 1.40–1.45× lower than the
fresh Phase40 output on these points. It remained 11.2–15.4× slower than pinned
TypeScript. These are narrow generated-module observations, not a catalog-wide
result or final compiler admission.

| Point | Phase40 checked06 (ms) | Phase41 checked source wrapper (ms) | TypeScript (ms) | Phase40 / wrapper | Wrapper / TypeScript |
|---|---:|---:|---:|---:|---:|
| tree-bitonic | 4.8579 | 3.3718 | 0.2932 | 1.441× | 11.499× |
| variation-tree-bitonic-6-17 | 0.8154 | 0.5839 | 0.0379 | 1.396× | 15.422× |
| variation-tree-bitonic-9-123 | 12.4508 | 8.5905 | 0.7662 | 1.449× | 11.212× |

All three rounds and expected values passed. Focused actual-emission controls
record 124 oracles, 17 boundary checks, and the 60,002-node / 60,003-leaf deep
case (`sum=420021`). The exact reports and their hashes are in `results.json`.

## Checked edit-to-screen interval

From the `checked01` ledger start to the `tree-actual-screen01` ledger finish,
the observed wall span was **202.652 seconds (3m22.652s)**. The receipt durations
and the gaps between them are separate below; gaps are not attributed to agent
effort or model activity.

| Ledger stage | Start UTC | Finish UTC | Tool elapsed (s) | Receipt SHA-256 |
|---|---|---|---:|---|
| checked01 | 17:00:41.228 | 17:01:25.890 | 44.661 | `9d19fa107939e98671a81d8aed08818676cd10501c810528c0788e4a26170084` |
| tree-prepare01 | 17:01:51.491 | 17:01:59.144 | 7.653 | `dfe025311775ac1641617ec821a1c7996f19573422e45eb88184f974ed3f6e36` |
| tree-actual-derive01 | 17:02:27.418 | 17:02:30.013 | 2.595 | `5d0915e0f18f59753a8bf7209581babfde0d0458c4cf0eacb2aca24be9953f0e` |
| tree-actual-controls01 | 17:03:23.937 | 17:03:24.624 | 0.686 | `d6259c00e4804892b4288178af36882155590a40d64216b4bcb6d2770cc58ccc` |
| tree-actual-screen01 | 17:03:40.978 | 17:04:03.880 | 22.902 | `ec511b0cfaa9628831b1bcaea962ff75eacd17b8d5cfe0b202fa9d8383799570` |

The four intervening wall gaps were 25.601s, 28.273s, 53.924s, and 16.354s.
Two short integration-plan derivation receipts overlap the screen's enclosing
interval; both are disclosed in the canonical JSON. The root campaign window
from 16:39:33 UTC through this screen finish was 1,470.881 seconds (24m30.881s),
an interim observed bound only. The active campaign ledger was not changed for
this report.

The checked attempt API is `9900abf49719575db7f7bbee32c6b16e10bcd554f9de22cde0799eb859cc6f0b`;
the emitted wrapper module is `64bfc698048c2ebf92c123111a5ce3fd8ccdb47b2fd8a7488243adbd1c2f6e9d`.
Final source admission still depends on the pending focused and full integration
gates and review.
