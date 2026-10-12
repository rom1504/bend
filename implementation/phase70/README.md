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

The [checked Bend observer analysis](observer-analysis.md) recognizes Map,
String comparison and two independent Strand traversals. Its
[first emitted-C checkpoint](observer-emission.md) reduces Map execution from
681 ms to 351 ms versus 391 ms upstream in a balanced three-round comparison.
The candidate passes 20 focused native controls; five upstream error-demand
differences also exist in the pre-observer compiler and remain explicit failures
of the paired gate. Broader qualification and installation remain pending.
Initial fixture/harness failures and their corrected successors are retained.
[Repeated-work audit](compiler-work-audit.md).
