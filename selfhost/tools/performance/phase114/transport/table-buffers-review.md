# Bounded table-buffer transport coverage

This optional overlay closes a missed transport case. A resumed H case can
push another internal continuation frame, but its renamed scratch buffer was
not recognized by `p114t_buffer`. That retained the original frame helper even
though H's structured frame statements otherwise have the accepted call shape.
No performance or architectural-parity result is claimed here.

The new recognizer accepts only
`p112f_name(p114h_prefix(i),"scratch")` for `i` in 0..7: exactly
`p114h_case_0_local_scratch` through `p114h_case_7_local_scratch`. It reuses both
authenticated name factories. A prefix test only avoids unnecessary work;
it is insufficient for admission. Other indices, suffixes and spellings fall
through. Existing ordinary/fusion/inlining buffers retain their old predicates.

The second override reserves these same eight names in `p114t_local_name`.
The unchanged original verifier establishes definite assignment, and the final
namespace walk checks definitions and direct parameters in both original
segments and complete functions. Consequently an original graph cannot supply
one of the newly admitted names. This matters because a name alone is not an
allocation/alias certificate. The emitted names arise after that verification
boundary, from the pinned H rewrite; externally supplied H plans are not an
authority accepted by the source pipeline.

H's planner separately rejects original `p114h_`/`p114r_` local collisions,
closes at most eight cases, and obtains each continuation from `p112f_cont`.
That parser requires the original 2048-byte, alignment-eight scratch allocation.
`p114h_buffers` allocates a distinct 2048-byte buffer for every emitted case;
`p114h_rename` uses the same case prefix for the frame's stores and call. The
state pointer keeps its original name. Captured owners are stored as full U64
words, and scratch does not alias state, the continuation stack or another case.

The existing `p114t_expand` still requires the exact frame helper signature,
state argument, known FID and constant count below 256. H additionally bounds
its captures to eight. The existing template performs each source load followed
by its destination stack store in original order, then writes the FID and
advances the stack pointer. The overlay changes no offset, ownership operation,
depth counter, case dispatch, pop/get expansion or fallback helper.

The source-only review found no concrete correspondence defect under these
checked-source-factory premises. This is coverage of a previously missed
authenticated buffer, not a proof for arbitrary pointer-named raw IR. The only
stricter admission is refusal of the eight reserved names in original graphs.
Frozen transport/Table01 methods and the selected source remain unchanged.
No compiler, API, native program or benchmark was executed by the source author.

The independent IR reviewer also found no concrete defect in the frozen source
`ff7ed9341bb6a7ce250a58067cb0604266260ac3fc3ed1241c715b53a3d045de`,
confirming exact case indices/names, original-graph exclusion, 2048-byte scratch
provenance, distinct case buffers and the unchanged ordered frame expansion.
That reviewer likewise ran no targets.

Ordinary qualification can compare exact outputs for the two-child expression
and owned-tree fixtures, then inspect resumed frame-helper calls and screen the
existing expression/tree workloads. The recognizer's finite name boundary can
be checked through the existing API lane. Results belong in separate receipts.
