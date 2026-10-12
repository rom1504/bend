# Phase70: observers, independent native coverage and compilation speed

Work starts from Phase69 installed typed10 at `32d159b`.
[Design](../../design/phase70/observers-and-compilation.md).
The phase is in progress; the installed compiler remains Phase69. All new raw
evidence uses `selfhost/build/phase70`; earlier evidence stays sealed.

The [baseline profiles](compilation-baseline.md) identify native planning/emission
as 56–61% of the sampled B2 C requests. Two small independent changes were tested
while the larger observer analysis was developed: lazy product-demand checks and
reuse of already compacted bodies. Their [combined B1 screen](compiler01-screen.md)
shows 3.58% less request time across three sources, with all12 complete C outputs
unchanged. The checked build/frontend gate and155 exact helper queries per image
pass. B2 performance and final release qualification remain pending.

The15 observer fixtures pass source acceptance with both the installed B1 and
pinned upstream. Two effect/parallel boundary sources also pass B1 checking.
Six additional benchmark sources pass B1 checking; four development families
have correct native acquisitions from both compilers. These are input/correctness
gates, not a measured expansion of the six-family performance score. The two
remaining benchmark families retain their heldout timing status.

The observer's pure-data reference analysis proves the motivating Map shape.
Its Bend analysis and emitter are still proposals; no generated-program speedup
or observer production qualification is claimed. Initial fixture/harness failures
and their corrected successors are retained. [Repeated-work audit](compiler-work-audit.md).
