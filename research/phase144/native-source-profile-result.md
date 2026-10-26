# Native source packaging saves11.62% in one same-producer comparison

The final03 native-only source profile compiled in221.206s versus250.296s for
the full final03 source, a29.089s reduction (candidate/full0.88378). Both requests
used the identical final03 N2 executable, prepared Base/carrier and CPU3
affinity, with the same linked serial runtime. This is one retained baseline
and one later candidate observation, with OS caches unflushed; it is not a
randomized repeated timing campaign.

The source input changes:2,990,803→1,650,634 bytes (−44.81%) and64,587→38,444
physical lines. The profile retains all native main/ordinary/session/batch
entry definitions, protected verifiers and explicit proof roots, preserving
the original ordered law/definition pairs for retained names. It removes no
files from the maintained full source or the full JS/C/research/test API.
This is therefore a **packaging/workflow saving**, not a same-source compiler
algorithm gain or a claimed reduction in maintained compiler complexity.

Machine generation for the profile takes16.771s. Sequential compiler-child plus
QBE/as/link time is237.977s; adding the emit supervisor instead of just its
child gives238.862s. The two complete outer guards sum to240.329s. These are
different timing boundaries, and exclude earlier source/hosted checks and
later smoke gates. The optional fresh aligned machine build of the retained
full-source Q3 has not run at this checkpoint, so there is **no like-for-like
full-build ratio yet**. Do not compare profile's sequential total to the old
overlapping compiler→QBE pipe wall time.

Generated QBE barely changes:117,151,119→117,105,243 bytes (−0.039%). This supports
the interpretation that lowering already omitted most code unreachable from
the native CLI; source packaging mainly avoids work before or around that
selection. Frontend and global-book operations are plausible beneficiaries,
but this experiment did not isolate their stage timings. The source-byte
reduction should not be extrapolated into a44.81% build gain.

Independent source checking passed. All three complete hosted products and all
three products emitted by the newly built native profile match the actual
current final03 API: Lexer, closure coverage and Map churn. They are the current
oracles, including the current Map product, rather than an older frozen Map
lowering. Source identities and the same-producer comparison are authenticated
by `source-profile/summarize-v01.py`.

This is **not a qualified shipping profile**. It has three ordinary native
smokes, not a profile bootstrap fixed point, full language qualification, or
fresh execution of every incremental/provider mode. The source retains those
CLI branches, but source retention alone does not establish their complete
runtime qualification. Installed/default selection and the full canonical
maintained source remain unchanged. The source-profile03 package is based on
final03; it does not silently incorporate the subsequent final04 consolidation.

The disjointness experiment is independent of this packaging result. Its event
batch variant was slower and is excluded; final04 selects only the successful
prefix-disjoint adapter. Do not attribute that future change to this measured
final03 profile result or multiply the hosted disjoint speedup into it.

Exact component summary:
`implementation/phase144/native-source-profile.json`.
Native requests: `phase130/p144-final03-q3/report.json` and
`phase130/p144-native-profile03-emit01/report.json`.
Aligned build: `phase111/p144-native-profile03-n1/report.json`.
Authenticated summary: `phase144/native-profile-summary01/report.json`.
All paths are under `selfhost/build/` unless otherwise stated. No new target
execution was performed while preparing this report.
