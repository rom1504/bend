# Controlled whole-source B1 equality comparison

Status: running; no complete comparison result is claimed yet.

[P4-026](../../experiments/phase4/P4-026-b1-full-source-comparison.md) tests the exact checked B1 `0653f21e…` against its guarded String.eq derivative `e95e1198…` on the final compiler source `34c6ef63…`. The earlier [single complete-source gate](b1-native-equality-full.md) established exact H output but was not a paired performance comparison. Its timing is excluded from these four observations.

The fresh process order is control/candidate, then candidate/control, all on physical CPU2 with Node 24.18.0, a 4 MiB stack and 12 GiB heap limit. Both variants reuse their separately validated Base caches; the comparator verifies equal decoded payloads and unchanged cache bytes. Source, runtime, host, worker, public H target and comparison input identities are frozen. OS caches are not flushed. No other intentional compiler workload is scheduled during the comparison; documentation and archival activity are not operating-system isolation.

Each successful row must preserve the complete result fields and actual emitted H bytes `b33b38e3…`. Process wall, inner request wall and maximum child RSS are separate measurements. Both opposite-order pairs must exceed 5% reduction in both wall measures to pass the preregistered performance hypothesis. A null performance result is still a completed comparison; missing or deadline-killed rows leave the comparison incomplete. Each child has a 900-second limit capped by the campaign deadline of 20:09 UTC.

The independent auditor is `selfhost/tools/performance/phase4/derived-b1-full-compare-audit.mjs`. It checks completed report structure, all actual outputs, command/config consistency, cache payload equality and paired arithmetic, and archives raw inputs and observations as verified gzip objects. It distinguishes a completed archive/audit from a completed four-row experiment. Eight focused tests cover missing and malformed reports, active writers, duplicate or wrong-image observations, false success, invalid metrics and honest deadline retention.

Results will be added only after the immutable finished report is independently audited. This experiment does not create a new checked bootstrap, change the normal development API or distributed compiler, or imply faster execution of user programs.
