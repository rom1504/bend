# P131-002 — close index and catalogue computations

Status: combined FAST native-qualified; same algorithms retained in successor.

Hypothesis: preserve an index traversal's state and comparison rather than
split it across separately scheduled helpers or repeatedly rediscover a prefix.
Keep complete first-match definition payloads and malformed-tree fallbacks.

Finite evidence compares336 complete trees,11,088 lookup results,840 malformed
read cases and2,656 catalogue outcomes. Three complete compiler outputs match
frozen QBE oracles. The closed read proxy improves24.38%; insertion V01 improves
3.80%. Selected insertion V02 avoids an extra helper cycle and redundant prefix
work, but has no separately isolated native timing. Do not assign V01's precise
gain to V02 or to the whole compiler.

Machine evidence matters: the read helper family removes scheduler jumps while
total instructions rise1003→1018. A smaller instruction count is not the observed
mechanism. Retained-root traversal and local control are.

Evidence: `selfhost/build/phase131/identity-resume01`, `read-lookup01`,
`combined-fast-identity02`, `combined-fast-read02`, `combined-fast-lookup02`;
[research](../../research/phase131/identity.md),
[read-side inspection](../../research/phase131/read-side-identity.md).
