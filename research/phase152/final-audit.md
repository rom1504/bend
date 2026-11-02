# Phase152 independent final audit

Read-only review of integration commit `8b5abf2`, the draft
[implementation report](../../implementation/phase152/README.md), maintained
source transport, and retained qualification/generation receipts. No compiler,
program or benchmark target was executed for this audit. No production code was
changed. Earlier semantic and finite-control review is in the
[prepared-values contract](prepared-values-contract.md).

**Finding: no material semantic defect found in the reviewed integration.**
The original selector admission remains intact; prepared-body correspondence
admits only authenticated nullary leaves, and full-width nonownership follows
existing local alias rules. Source checking, the unchanged final verifier,
finite executions and native self-reproduction remain separate evidence. This
does not establish a new equivalence theorem or unrestricted backend support.

**Source bridge.** Independently reassembled the maintained default `qbe`
profile in memory using `selfhost/tools/build/source.py`, including its inventory
and protected-declaration checks. It exactly equals both
`selfhost/build/phase152/production-source01/compiler.bend` and
`composite01/compiler.bend`: 3,085,157 bytes, SHA256
`027e15041035522ed7e40ef971eff75f24a09ef6a00e3f8fe335839f94bcb8a8`.
The 8,265 mapped declaration slices also match current module bytes. Baseline
8,223 declarations/66,107 lines become 8,265/66,399: +42/+292. All 112 protected
hashes pass; the protection inventory equals the parent commit's inventory.

**Generation receipts.** `native-n1`, `native-n2` and `native-n3/report.json`
are complete, record no changed inputs, zero compiler/QBE exit codes and empty
compiler/QBE stderr. They bind the same source and runtime to the reported
259.302/254.613/249.222-second builds. N2 and N3 record identical QBE SHA256
`1032c6a6495ca86bb26ad2bcd7ae639ed49dc987765dfe567dce7ac6224bf7bb`, assembly
`88803353068a14f35a1430dea9c70477a2624bd321a52883183659f26b4f0792` and object
`896a04ccd67d0159871ec3b3d46907404b5fa73c2e5ae88b6a787463558e66eb`.
Their ELF hashes differ, as the draft discloses. This review checks the raw
receipt agreement; it does not independently rehash all large machine products.
The 3.89% cold-build screen is correctly limited to one observation per
generation, unflushed OS caches and concurrent read-only metadata/census work.
Neither self-reproduction nor static pair counts isolate the cause of that
entire timing delta.

**Finite qualification.** Raw reports confirm N1 focused19, N2 all64, hosted
JS8 and corrected hosted C6 passed, with empty `changedInputs`. The guarded
control execution has 66 unique `:pass` rows, `ok:true`, empty stderr and exit0.
The C failure is independently reproduced by the older hosted image with the
same `direct reachability tail-call analysis refused` diagnostic. The adapter
fix defaults C requests to `backend='js'` with `mode='native'`, matching the
typed driver's public native route; explicit direct-JS C requests are refused.
The corrected six-case receipt pins the changed adapter. This is a host-route
repair, not evidence of a Bend semantic regression. Preserve that adapter
revision with the phase evidence because it is additional to `8b5abf2`.

**Report closure items.** At review time, `compiler.json.scope` still says
isolated assembly, no production edits and unqualified, and its
`inventoryChange.scope` still says ordering proposal. Update those descriptive
strings; do not replace historical frozen-source identities merely to hide
their historical role. The contract's statement that the “Current” classifier
sends `NStatic` to opaque `N_W64` describes the pre-change implementation and
should be labeled accordingly. The integrated source also retains an
“experimental overlay” comment; that is only stale explanatory text.

The draft's final measurement paragraph is still a placeholder. The completed
`programs45-bench02/report.json` says `complete:true/status:measured`, while its
aggregate deliberately remains incomplete because of zero/low-resolution
cases. A resolved-subset ratio must retain that denominator and must not become
a 45-case aggregate claim. Compiler-request and retention conclusions should
likewise cite their final receipts. These are publication/reproducibility
closure items, not a request for another full compiler build.

## Coordinator closure after the independent review

The historical findings above are preserved. Descriptive source-recipe scope and
inventory metadata now record production integration and the complete 42-name
delta. A fresh transport assembly is still byte-identical to the independently
reviewed source. The contract now labels the old value classifier as pre-Phase152.
The qualified source's old overlay comment is retained to preserve exact bytes.

The final report and metrics bind the completed request and program runs, closed
retention receipts and explicit qualification. The runtime ratio combines 40
resolved scale1 points with four declared scale64 repeats; it does not replace
the deliberately incomplete original scale1 aggregate. No input point changed.
A subsequent exact comparison found all 45 QBE/assembly/object products identical,
which is disclosed as neutral preservation evidence, not a user-program speedup.
The corrected host adapter and benchmark method are included in the capsule.
These are coordinator closure notes, not additional independent conclusions.
