# Phase54 cleanup evidence

[Phase report](../../../../implementation/phase54/README.md) ·
[Validation plan](validation-plan.md) · [Release recipe](release-plan.md).

The selected installed compiler is `checked-graph02`. It separates shared backend
facts and replaces repeated graph closure while retaining legacy compiler-image
compatibility and native C. Compiler image generation through direct JS remains
an experiment, not the installed bootstrap format.

Graph controls, checked source scaling, semantic/native qualification, full
45-point emitted-byte comparison and installed release checks are separate
scopes. The semantic launch plan executes the existing Phase52/53 methods with
new outputs; it does not rerun runtime timing if executable bytes are unchanged.
The complete Phase53 portable benchmark bundle remains at
[`../phase53/bundles/current/manifest.json`](../phase53/bundles/current/manifest.json).
A byte-equivalence receipt binds it to the new compiler; its old timing evidence
must keep the Phase53 date and scope.

The [publication index](publication.json) binds compact qualification summaries
and a single verified raw archive. The original development raw root was
`selfhost/build/phase54/`. After closure, detailed receipt paths in reports refer
to archive members under `artifacts/raw/raw-campaign.tar.gz`; extract into a
fresh directory to inspect them. Historical absolute paths document consumed
inputs, not a requirement that a checkout live at the same path.

Retained failures include comparator assumptions, two source-fixture defects,
the full compiler-image deadline and the bounded offline profiler heap failure.
A corrected successor uses a new file/output; consumed producers and original
failures stay intact. `bootstrap/` also contains prepared ordinary-driver probes
that were not executed because full image generation did not complete.

Reused archive and validation methods retain their historical receipt kinds.
The selected hashes, campaign paths and publication index identify Phase54.
