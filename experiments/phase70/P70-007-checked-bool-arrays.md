# P70-007: checked Bool arrays retain scalar representation

Registered before the Bool-admission audit/prototype. Source-only proposal;
root schedules any target execution after observer integration.

Hypothesis: trusted checked Base Bool values are already represented as 0/1,
so admitting Bool alongside U32/F32/Char in the existing whole-program array
certificate can recover packed arrays and typed private scalar parameters for
programs such as U32→Bool→U32 Array.map, without changing runtime representation
or accepting user enums, arbitrary foreign values or raw books.

Evidence motivating the test: Phase69 Array-map calibration observes 861 ms
versus upstream 250 ms (3.44×, one sample), while emitted B1 C disables all scalar
array/typed-parameter flags. Bool is a concrete rejected element type. The source
also contains separate per-element Tuple traffic; packing cannot be assumed to
remove that cost. [Source comparison](../../implementation/phase70/native-array-map-opportunity.md).

First falsifier: source audit finds a checked, certificate-admitted Bool producer
or transport that can store a noncanonical or wider value. Then reject the
one-line proposal and document the required normalization/boundary instead.
If source evidence supports it, require checked source admission, independent
Bool array/clone/share/mixed-layout outputs, raw/foreign refusal and actual
packed emitted C before timing unchanged common work.

Exploratory gain hypothesis: **1.2–2.0× faster Array-map execution**, which would
move the preliminary 3.44× ratio to about 2.87–1.72× if the baseline reproduced.
This is unmeasured planning uncertainty, not an empirical bound or promised
gain. Zero gain remains possible if another certificate refusal persists or
Tuple/list costs dominate. No broad-suite estimate is made.

Source audit: supports the change under the existing checked-entry contract;
this is not a formal compiler proof. [Audit, one-line patch and seven independent
controls](../../selfhost/tools/performance/phase70/coverage/bool-admission-v1/README.md).
Correctness targets: not run. Measurement: not run. Decision: proposal ready
for independent source review and the cheap baseline gate; no production edit.
