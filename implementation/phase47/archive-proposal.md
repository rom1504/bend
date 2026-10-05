# Phase47 evidence selection and archive proposal

Recorded 2026-10-04. **Selection proposal only: no archive capture, copying of
changing raw files, writer closure or durable Phase47 executable retention claimed.**
Root must close the active campaign before producing a definitive inventory.

## Existing convention to retain

[Phase45 preservation](../../selfhost/tools/performance/phase45/evidence/README.md)
separates portable program bundles from the complete historical raw campaign.
Its archive preserves failures, stopped jobs and uninstalled candidates, verifies
every reopened member, and publishes ordered parts at most 40 MiB each.
Original absolute paths remain in receipts; archive members are relative.
The [writer closure](../../selfhost/tools/performance/phase45/evidence/writers-closed.json)
and [archive metadata](../../selfhost/tools/performance/phase45/evidence/raw/archive.json)
bind the immutable cutoff. Publication receipts live outside the closed raw root.

The existing [streamed archive producer](../../selfhost/tools/performance/phase42/validation/archive-campaign-v1.py)
captures every regular file in its supplied root and rejects symlinks; it does
not support selection or content deduplication. Reuse its reopening and stability
checks after materializing a reviewed frozen selection. Do not silently add ignore
patterns and still describe the result as a complete raw-campaign archive.
The Phase45 split publisher has hardcoded Phase45 paths; do not run it on Phase47
without a versioned derivation binding the new destination and original producer.

## Selection contract

The data-only [selection proposal](evidence/archive-selection-proposal.json)
names required roots and retention classes. It is deliberately not a final
member manifest: there are no guessed file counts, hashes or terminal statuses.
At closure, inventory **all** regular Phase47 raw files before classifying any
duplicate or regeneration-only payload. Every original path must resolve to one
of the following recorded states:

| State | Required evidence | Honest retention claim |
| --- | --- | --- |
| Stored member | Relative capsule path, size and reopened hash | These exact bytes are retained. |
| Exact alias | Original size/hash and a retained content object with the same verified bytes | The bytes are retained once and reconstruction can restore the recorded path. |
| Prior capsule member | Exact Phase45 capsule/member/hash plus recoverable repository parts | External durable dependency; retained there, not copied into Phase47. |
| Regeneration only | Input/source/tool identities, commands, prerequisites and expected output digest | Recipe retained; executable bytes are **not** retained. |
| Missing | Explicit original path and reason | No retention or replay credit. |

An output digest plus source recipe does not establish retained executable bytes,
nor guarantee byte-identical regeneration across compiler or host changes.
Only verified alias reconstruction or reopening a stored artifact earns that claim.
No artifact receives release qualification merely because it is archived.

## What to keep

Keep all small receipts, run manifests, observations, commands, source fixtures,
consumed tool versions, patches, reviewed proposals and failure logs. Preserve
the first Array producer failure, failed checked-worker01 build, corrected
successors, all canary/fast outputs, refused proofs and stopped/incomplete
measurements with their original statuses. Later success must not replace them.
Successful controls for an unselected proposal remain successful controls, not
failed observations. Current named paths are examples; final inventory must
include later attempts too.

For the memo study, retain the full 17-job plan, priming/check/library reports,
all ten clean samples, counted request, producer, runner and `derive.json`.
Preserve exact source and host snapshots or map them to exact retained content.
Do not discard a duplicate-looking report: its timestamps, commands or error
position may be different even when the output digest agrees.

Avoid repeated full API payloads by retaining **one copy per distinct digest**
and recording aliases for every omitted path. Prefer retaining distinct measured
counterfactual APIs once: they are small enough to make replay independent of a
fresh selfhost build. Selected worker23 can refer to its already published Phase45
capsule member, provided recovery is verified at the final cutoff.

Likewise retain unique executed emitted program modules once, with explicit
baseline/candidate/control aliases and acquisition provenance. A digest-only
record for such a module must instead say regeneration-only. Never say that
portable controls or a runnable benchmark bundle exists until the required
module/runtime/source dependencies have been reopened together.

Unused repeated build products or identical compiler/source snapshots can be
exact aliases. Large CPU/heap profiles can be separately compressed members;
retain their metadata and commands, and mark any intentional omission. The
archive is for reproducibility, not for constructing another favorable score.

## Root publication sequence

1. Finish target and receipt writers; record closure outside raw with exact cutoff,
   all processes stopped, ledger/job-plan identities and protected-file audit.
2. Inventory the closed raw root with bounded stat/hash passes. Classify every
   original path; freeze a final content/alias/member manifest. Report missing
   dependencies before archive creation, and retain later corrections separately.
3. Materialize one content object per retained digest in a fresh staging root.
   Include the logical-path alias manifest, restoration instructions and exact
   dependency map to Phase45. Write by copy, not hardlink, so later source writes
   cannot mutate captured bytes. This step requires a small reviewed materializer;
   none is implemented or executed by this proposal.
4. Adapt the existing archive producer's closure declaration to this immutable
   staging root, retaining the original campaign closure as an additional input.
   Preserve its all-member reopen and input-stability checks. The resulting
   capsule is a selected-content archive with a complete logical inventory.
5. Reconstruct all retained logical paths into another fresh directory and verify
   their original sizes/hashes. Resolve prior Phase45 members by exact archive
   identity, not old absolute path. Record regeneration-only and missing paths
   separately; do not pretend those were reopened executable artifacts.
6. Publish bounded ordered parts and a relative replay guide outside raw. Verify
   part concatenation against the reopened archive. Commit small outcome/receipt
   indexes and required source/tool bytes; avoid committing duplicated API files.

If this selection/alias materializer is not justified for Phase47's final size,
the simpler safe option is the existing full raw capsule: compression preserves
all failures and avoids a new reconstruction mechanism. Measure final volume
before deciding. This proposal establishes neither final volume nor completion.

## Root selection decision — 2026-10-05

Root's provisional stat inventory is 4,883 files / approximately 131.6 MB logical
bytes. **Choose the simpler complete full-raw gzip capsule**, using the existing
Phase42 streamed archive producer. The deduplication/materializer design above
remains an unimplemented alternative and is not the selected preservation plan.
No API/module payload is excluded on the strength of a digest and recipe.

The [Phase47 preservation guide](../../selfhost/tools/performance/phase47/evidence/README.md)
contains pending-publication closure/audit/capture/recovery commands. The adapted
parts publisher is used only if the final verified gzip exceeds 40 MiB; otherwise
retain the single compressed file. The authoritative 103-file protection inventory
is Phase45's `protected-start.json`, retained through Phase46, not Phase47's
59-file starting status record. The authorized prepublication read-only audit
finds all 103 unchanged and unstaged; terminal audit still needs renewal.

This decision does not close writers, freeze the changing campaign, copy files,
establish a final member count or claim archive durability. Root executes final
capture only after every target and receipt writer has stopped.
