# Independent profile and release-document review

Reviewed 2026-09-23 after the02:53 host correction. File/source reads and small
arithmetic only; no compiler, profiler, oracle or regression run by this reviewer.

The seven displayed exclusive profile shares independently recompute from the
actual1,761 sample IDs and time deltas (19.88255seconds). They round to18.80%
run_loop,9.67%GC,5.75%String.eq,3.36%one core_subst_stable closure,3.35%kc,
2.77%kt and2.65%String.starts_with. The API bytes match e2b5463678a2… .
The raw profile SHA is
`840e956c1e106fcbd4ef7e3d61d24bab4fcf0e99fe14f5131dd5c8af14c28f4c`;
its report SHA is
`4a375a2be78a5f39364d4ebc48d83140fe9c4d0b74fa99d55c096fbe7bb29dba`.

Source associations are correct: generated line14943 is the non-Var continuation
inside core_subst_stable, not an anonymous closure guessed from its name. The
other displayed functions begin at lines114,667,651,2756 and3453 respectively.
The old worker constructs choice closures, and kc returns a tail bounce to the
selected one. This explains the proposed mechanism but does not allocate all
trampoline/GC samples to that one predicate. The implementation report correctly
avoids such an attribution or an additive/removable-cost ceiling.

The launcher’s24.012seconds, request19.776seconds and displayed top-level spans
match the records. Base preparation/pre-discovery, instrumentation, concurrent
correctness work and the small component scope are explicit. The recorded plan’s
mistaken02:50 timestamp is separately corrected against the02:39 launch while
retaining historical bytes. No same-source speed result follows from this one
profile. The next design correctly treats its numeric benefit ranges as planning
hypotheses; eliminating83.42%of current wall is the arithmetic needed to reach
1× from the measured6.031645×workflow ratio, not an optimization prediction.
The self-emitted H compiler remains a separate artifact/performance question.

The consolidated release docs distinguish ordinary no-TypeScript compilation
from explicit pinned-TypeScript bootstrap, retain authentic checked-parent and
derivation lineage, and document relocation verification without fabricating a
new bootstrap. The tested ordinary build,21declared controls and same optimized
API/source are separately recorded. Broad/proof results are linked with their
own artifacts rather than inferred from those21cases. No new release blocker was
found in this bounded wording review; it is not independent execution of release
commands or a full audit of the installer.

One stale sentence called the native zero-exit propagation bug a current
limitation after a dated fix had been added. At root’s request it now says
“limitation at this first test” and points to the follow-up. The original EPERM
exit0 observation/archive is preserved. The follow-up records five regression
groups, actual EPERM now exiting1, and a fresh release build with identical
compiler bytes; broad backend runs still use their frozen pre-fix host. That
historical/final distinction is now coherent. The current source-size and full
conformance claims were reviewed separately in the Phase5 document review.

Reviewed file identities (point-in-time, not promises that root-owned docs will
never receive later results):

| File | SHA-256 |
| --- | --- |
| `implementation/phase6/optimized-residual-profile.md` | `a6db47085664154d20680e4ebea7bed92010d60deb385163ab31067ff8dad567` |
| `design/phase6/residual-performance.md` | `9c93ed1a3c670c8a4a9eb4fc946b5efd47985cd264bbf1d2f9224ea29c74f4cc` |
| `implementation/phase5/consolidated-release.md` | `48ff972f148147aef48c2fc8cff0933198a192480586f14c202094dda942883c` |
| `docs/BEND-IN-BEND.md` | `b816fa2ca04e335a8c9c449c381cb064ba91f5eea11d28a545646478d88b5fe6` |
| `README.md` | `b333f06a5c2a89119c8ef042ec61b3a14e388db572a45a01ad15c7d1d64431de` |
| `selfhost/README.md` | `8937446e702f598288ecc2e7353698dc8069f8fde469b1b82d50e50dc13fba63` |
