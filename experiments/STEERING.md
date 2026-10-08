# Current frontier: Phase66 upstream migration

The user authorized updating to upstream while protecting five metrics:
compiled-program execution speed, B1 compilation speed, B2 compilation speed,
conformance and simplicity. [Design](../design/phase66/upstream-and-five-metrics.md) ·
[Report](../implementation/phase66/README.md) ·
[Experiment](phase66/P66-001-upstream-migration.md).

## Frozen endpoints

Start: `ef7c657` on 2026-10-08 at 05:02:20 UTC. The installed Phase65 State10
remains the admitted release until a new candidate qualifies. Old upstream is
`018751270e800bc222a93dad7f257083ee53a5f7`; new target is
`059266225b77c8ca256ac6b25ee5c21449bab151` (95 intervening commits).
The target has its own `.bootstrap/upstream-phase66` checkout. Historical
references and Phase65-and-earlier raw evidence stay unchanged.

Old checked B1 is `3a7fedb77003aecc797cd9a9ac4c6d1bd15bd21dd1230806b6719565eca10f72`;
old genuine B2 is `239f79702c13339d1044e7fe497c4946299d36ce2d7b5eb7850d0d43514a8fae`.
Phase65's 1.28945× compilation and 0.969256× import-inclusive ratios apply only
to that B2 and its old TypeScript reference. They are not measurements against
new upstream. [Previous results](../implementation/phase65/state10-results.md).

## Ordered work

1. Preserve installed/source identities and 110 inherited files. Compare
   unchanged B1/B2, old TypeScript and new TypeScript on a common suite before
   attributing any migration speed change. Keep Base versions and clocks explicit.
2. Migrate namespace key/display separation, parser/correctness fixes, Base and
   effect contracts, host conversion and guarded bootstrap/equality adaptation.
   Keep semantic compiler algorithms in Bend. Do not hand-edit upstream bend.ts.
3. Use a short checked-B1 compatibility loop. New upstream tests supplement the
   retained corpus; failures/unsupported observations remain visible.
4. Qualify actual B2, own-source checking and B2/B3 reproduction. Measure B1 and
   B2 independently against both the preserved release and new TypeScript.
5. Measure generated-program runtime on the established 45 points, with new
   targeted semantic cases. Retain separate code/host/tooling size accounts.
6. Install only after final correctness, performance and release checks; archive
   evidence, document all five outcomes, commit and push. No PR comments.

## Gates and resource policy

No performance success compensates for a semantic mismatch. Do not treat changed
expected output as a regression when upstream deliberately changes a contract;
identify and test that change explicitly. Cache invalidation must retain ordinary
fallback. Requalify optional Base products before permitting new Base content.

One root-owned CPU3 compiler target at a time, with one guard: 1 GiB Node heap,
4 MiB stack, 2 GiB process-tree RSS and 4 GiB available-memory floor. Agents own
separate source/data/review lanes on CPU0. New raw files only under Phase66.
Use frozen snapshots, fresh output paths, focused screens before broad gates,
and separate time accounting. Preserve failures and rejected attempts.
