# Phase140 research-cost review

Snapshot: **2026-10-25 18:12:15–20:34:33 UTC**, 2h22m18.3s of campaign elapsed
wall time. This is a bounded accounting snapshot, not a final Phase140 report.
`full-product02` has now completed and is included. Candidate18 has completed
API/finite checks but no completed native image or full loop at this snapshot;
those pending costs/results must be added separately.

[Machine-readable inventory](cost-review-data.json) records93 finished guards,
with no unfinished guard in the bounded scan at the cutoff, exact receipt identities, candidate source/module
sizes, and the completed loop observations. The scan was limited to
`selfhost/build/phase111/p140-*/process.json` and
`selfhost/build/phase140/*/process.json`; it did not sweep other phases or replay
any target. All93 finished guards started inside this campaign. Earlier Phase137
qualification/profile work, historical baseline acquisition and old tool/cache
construction are **not** charged to Phase140 here. Earlier Phase140 candidates
are charged, including rejected source attempts.

## What the recorded time supports

| Completed work category | Runs | Successful / failed | Sum of enclosing guard wall time |
|---|---:|---:|---:|
| Checked API acquisition |44|22 /22|419.56s /6.99min|
| Native compiler acquisition: qualified builder emits candidate QBE |3|3 /0|1,099.58s /18.33min|
| Native compiler machine builds |3|3 /0|49.24s /0.82min|
| Complete native compiler-edit loops |3|3 /0|1,791.36s /29.86min|
| Independent full edited-product oracle |1|1 /0|334.54s /5.58min|
| Hosted finite/semantic/product checks |32|25 /7|412.18s /6.87min|
| Native smoke/request checks |6|6 /0|21.60s /0.36min|
| Generated-product machine build |1|1 /0|14.75s /0.25min|
| **Total completed supervised workflows** |**93**|**64 /29**|**4,142.82s /69.05min**|

The union of these completed guard intervals is **4,077.53s /67.96min**.
Their summed wall time is65.29s larger because some independent jobs overlapped.
This union is the correct campaign-wall view; the sum is a useful workflow-cost
view. Neither measures aggregate CPU consumption or agent effort.

The remaining **4,460.78s /74.35min** of campaign wall lies outside those
completed guard intervals. That includes implementation, source inspection,
coordination, receipt preparation, orchestration gaps, unguarded metadata work,
and any work not represented by a completed guard. It is **not measured idle time** and
cannot be divided honestly into agent thinking versus waiting with these logs.
There is no token, model-compute or quota telemetry in this inventory.

Each guard already encloses its command and child work. Native `totalMs`,
`nativeSeconds`, QBE build time, transport time and hosted stage timers below
are explanations of those workflows, **not extra costs to add to the table**.
We do not add phase130 request timers or build subprocess timers again. The
complete-loop entries include their wrapper's output reconstruction/checking.

## Acquisition cost and experimental source growth

Each image was built by the same qualified Phase137 builder. These are candidate
image acquisition measurements, not the candidates' own compiler throughput.
The machine-build column is the inner aligned build receipt; its small wrapper
cost is already included in the enclosing guard total above.

| Candidate | Source SHA prefix | Physical lines | Nonblank, noncomment lines | Source bytes | Added declarations | Native emission guard | Machine build | ELF bytes |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| Qualified Phase137 source |2620d59a|58,569|42,433|2,701,952|—|historical, excluded|historical, excluded|—|
| Initial source03 / `p140-n1` |c0a45049|62,012|45,009|2,859,986|413|358.81s|15.12s|18,640,760|
| Source15 / `p140-n1b` |9d6ac8d5|63,587|46,202|2,939,395|599|367.62s|15.32s|19,067,424|
| Source17 / `p140-n1c` |fcef9aa6|63,993|46,506|2,961,899|650|373.15s|15.52s|19,124,800|

Source17 is9.26% larger in physical lines and9.60% larger in approximate code
lines than the selected parent. Its source-byte increase is9.62%. This includes
experimental adapters and embedded controls, not only production optimization
code. Candidate source manifests are composition receipts (`checked:false`);
separate completed checked-API receipts establish checking. None of these
numbers establishes native self-reproduction qualification or promotion.

| Candidate | Selected module files | Module physical lines | Control/reference filename subset | Other module lines |
|---|---:|---:|---:|---:|
| Source03 |22|3,104|40|3,064|
| Source15 |40|4,524|659|3,865|
| Source17 |44|4,886|919|3,967|

The subset classification is explicitly a filename heuristic (`control` or
`reference`), not a reachability or complexity proof. Generated compiler totals
also include composition scaffolding; module sums are not a source-line delta.
Per-module pins and sizes are in the inventory. The initial source uses the pair
adapter; later sources add batch IO, stronger admission/controls, static prefix
state, catalogue reuse and subsequent cost recovery. The newest source adds the
private indexed report adapter. Avoid presenting all experimental support code
as permanent compiler complexity.

Receipt sets:

- [Source03 manifest](../../selfhost/build/phase140/native-source03/manifest.json), [checked API03](../../selfhost/build/phase111/p140-native-api03/report.json), [acquisition01](../../selfhost/build/phase111/p140-acquire01-guard/process.json), [N1 build](../../selfhost/build/phase111/p140-n1/report.json).
- [Source15 manifest](../../selfhost/build/phase140/native-source15/manifest.json), [checked API15](../../selfhost/build/phase111/p140-native-api15/report.json), [acquisition02](../../selfhost/build/phase111/p140-acquire02-guard/process.json), [N1b build](../../selfhost/build/phase111/p140-n1b/report.json).
- [Source17 manifest](../../selfhost/build/phase140/native-source17/manifest.json), [checked API17](../../selfhost/build/phase111/p140-native-api17/report.json), [acquisition03](../../selfhost/build/phase111/p140-acquire03-guard/process.json), [N1c build](../../selfhost/build/phase111/p140-n1c/report.json).

## Completed native observations, without double counting

The stage timers measure compilation inside the native session. They exclude
some source IO, startup, final process destruction and external frame
reconstruction. These are single exploratory observations, not repeated
controlled performance estimates.

| Image / completed workload | Frontend | Raw | Backend | Registry | Render / close | Native stage total |
|---|---:|---:|---:|---:|---:|---:|
| Source03, cold full source |137.091s|56.493s|74.256s|15.423s|51.023s|334.286s|
| Source03, warm product-policy edit |51.394s|44.820s|35.266s|12.805s|9.266s|153.551s|
| Source15, cold full source |134.031s|70.679s|93.104s|15.390s|49.689s|362.893s|
| Source15, warm inline-policy edit |53.058s|15.497s|45.100s|11.948s|8.044s|133.647s|
| Source15, warm continuation-policy revision |58.181s|15.828s|42.966s|11.622s|7.814s|136.411s|
| Source15, warm product-policy revision |59.385s|15.751s|44.409s|11.967s|7.853s|139.365s|
| Source17, cold full source |129.648s|74.884s|93.643s|15.339s|50.615s|364.129s|
| Source17, warm product-policy edit |31.319s|14.161s|40.652s|11.389s|7.707s|105.228s|

[Source03 pair receipt](../../selfhost/build/phase140/full-product01/report.json)
records490.786s native process and505.593s enclosing runner. Its immutable
`independentProductsExact` flag is false: later external reference work is not
silently retroactively relabeled here.
[Source15 batch receipt](../../selfhost/build/phase140/full-batch01/report.json)
records776.487s native process and797.556s runner. Its seed and final product edit
have exact supplied oracles, while inline/continuation products do not have
independent exact oracles in that receipt; consequently its overall exact flag
is false. Completion means the experiment finished, not universal qualification.

The source03 pair and source15 batch differ in checkpoint location, prior revision
sequence and warm admission state. Their stage differences are diagnostic, not a
clean ablation of any single optimization. In particular, source15's cold total
is28.607s higher in these observations; that needs explaining rather than hiding
behind its faster warm raw stage.

Both later images completed the same small Lexer batch:
[source15 smoke](../../selfhost/build/phase140/batch-smoke01/report.json),
[source17 smoke](../../selfhost/build/phase140/batch-smoke02/report.json).
Cold Lexer was1.550/1.553s and the first warm edit0.915/0.921s respectively.
The completed [source17 full-product receipt](../../selfhost/build/phase140/full-product02/report.json)
now records **473.125s native process**, **483.949s enclosing runner** and
**485.531s guard**. Both products match independent supplied oracles. Frame
transport costs4.969s cold and5.293s warm, already contained in the runner.
Source03 and source17 use the same actual A/B bytes, logical path, product owner
and UTF16 checkpoint hint; pair versus batch adapters differ, and each is only
one observation. Warm compilation fell153.551→105.228s (31.47% less), while cold
rose334.286→364.129s (8.93% more). This observed cold increase exceeds the design's
5% target and needs follow-up. It must not be hidden by the warm improvement.
Source17's warm stage is3.46× faster than its cold stage, but still5.26× above a
20s target. The native output equality is stronger evidence than a cache-hit
count; it is still not complete compiler qualification or a repeated timing study.

## Failure and efficiency lessons

The29 failed guards consumed132.41s of supervised execution:22 checked-API
failures121.03s, seven other checks11.38s. Preserve these failures; they are part
of the acquisition cost. Most checked-API errors were concrete integration
mistakes—affine captures, binder match order, missing fixture declarations,
unknown result constructors or unannotated fixture literals. For example,
API04 rejected `tail` capture, API08 rejected `logical` capture, API09 rejected
nested result matching, and API11 found a missing test-only helper. They were
not generated-program performance regressions. The actual fix/review wall cost
is larger than the132s target cost and is not separately metered.

Practical changes for the next cycle:

1. **Check the composed boundary before image acquisition.** Keep controls
   self-contained, verify constructor/result shapes, and audit affine captures
   and binder order once before launching a sequence of full API checks. The
   repeated integration failures were cheap in CPU seconds but fragmented the
   research loop and consumed unmetered agent effort.
2. **Require a useful-cost signal before each six-minute image build.** Three
   native acquisitions cost18.33min; machine builds cost less than a minute.
   The major acquisition floor is generating the candidate compiler's QBE,
   so optimizing the final linker alone would miss this campaign's cost.
3. **Amortize one full seed across several real edits.** The source15 batch
   paid362.893s once, then roughly134–139s per revision. Repeating that seed for
   each of three edits would add about725.8s under the same observations. This
   is a workflow saving, not an additional measured speedup or correctness gate.
4. **Measure work removed, not hit counts.** Source03 warm ownership/raw hits
   were high while raw still took44.820s. Static preparation, reference scans,
   segment-header reconstruction, whole-program metadata and final verification
   remained outside the hit. Keep stage clocks and exact product checks; avoid
   interpreting98% owner hits as98% time eliminated.
5. **Keep cheap correctness and expensive qualification distinct.** Hosted
   checking/testing totals13.86min here, but the three complete native loops plus
   independent full oracle cost35.43min. Reuse authenticated unchanged results,
   run a narrow independent edit oracle first, and reserve complete campaigns
   for candidates whose measured payoff can repay acquisition.
6. **Compare matching revisions and checkpoint policies.** The next clean
   comparison should hold source A/B, logical path, checkpoint hint, builder,
   output identity and resource lane fixed. Batch sequencing is valuable for
   throughput but must not substitute for a controlled same-edit ablation.
7. **Consolidate after evidence.** Retain necessary admission/negative controls
   and the qualified compiler. Once a candidate is selected, move test-only
   exports out of its normal image where the checking workflow permits, remove
   superseded orchestration from active composition, and track production
   reachability separately from archived experiment size.

There is no evidence here that more concurrent performance campaigns would
improve efficiency. Independent small checks already overlapped; full timing
used one resource lane. The next major return should come from less repeated
work and fewer avoidable integration cycles, with independent evidence retained.
