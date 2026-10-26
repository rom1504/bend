# Final03 native source packaging comparison

Profile03 is derived from the exact full final03 source `31e1b13a…` by the
unchanged `prepare-v02.py`. Its source hash is `a92f9634…`; it contains1,650,634
bytes and38,444 physical lines, versus2,990,803 bytes and64,587 lines in the
full composition. It retains4,917 declarations, including553 laws, and excludes
3,131 declarations. All declarations for retained names remain in their original
order, including separate law/definition pairs. Main, ordinary compilation,
session/batch entries, protected verifiers and the explicit proof roots remain.
Full JS/C/research/test API composition is retained separately.

The previous profile02 acquisition used an earlier producer and an overlapping
compiler→QBE pipe. Its approximately268-second build did not establish a
same-producer packaging gain. This plan uses final03 N2
`22380e6ab9a2d565…` for both inputs. That exact executable already produced the
full final03 Q3 in250.2956065 native seconds with complete117,151,119-byte output
equal to Q2. Its actual linked runtime is the pinned serial-RFC object; the
native-request tool's legacy `runtime` field describes a future build context
and must not be mistaken for the runtime linked into the supplied executable.

Prepared root-only plans are in
`selfhost/build/phase144/native-profile-plan02/`:

1. `check-jobs.json`: independently check profile03, then compare its three
   complete hosted products with the **actual final03 API** products in
   `predicate-byte-candidate01`. The Map product differs from an older frozen
   reference, so the current oracle is explicitly bound rather than assumed.
2. `acquire-jobs.json`: run the same final03 N2 ordinary native request on
   profile03, retaining complete QBE, then build it with the existing aligned
   QBE/as/link tool and the same serial runtime. The sequential emission is
   intentional: its `nativeSeconds` directly matches the retained Q3 method.
3. `baseline-machine-job.json`: optionally build the already-retained Q3 using
   the same aligned tool/runtime to obtain comparable isolated machine cost.
   No full baseline request is repeated. The original overlapping N2 pipe
   cannot supply this isolated machine timing.
4. `native-smoke-jobs.json`: the new profile binary emits the same three complete
   programs against the current final03 hosted oracles. This is ordinary-native
   smoke coverage, not a new all-language or incremental qualification.

`summarize-v01.py --plan …/report.json --out FRESH_PHASE144_DIRECTORY` reads only
completed receipts. It distinguishes native compiler execution from machine
build time and labels their sum as an assembled sequential workflow estimate.
It never launches a target. A single retained baseline followed by one profile
run is a discriminator, not a randomized timing campaign.

This experiment tests a smaller shipping **source package** for the same native
CLI. It does not measure a same-source compiler algorithm improvement. Source
size reduction alone does not predict time reduction: the previous profile
still emitted approximately117MB of QBE because native-reachable code was
already selected during lowering. Frontend work and global-book operations
are the plausible savings; most native code generation remains.

The unchanged source dependency closure preserves all CLI branches, but this
plan executes only the ordinary three-case path. Provider and incremental modes
have prior full-source qualification/smoke evidence; the new profile does not
inherit a blanket runtime qualification merely by retaining their source. No
profile self-reproduction, installed selection or complete conformance claim is
made. No target jobs were run while preparing this plan.
