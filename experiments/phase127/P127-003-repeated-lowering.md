# P127-003: observed repeated lowering preparation

Status: measured dynamic work; optimization not implemented.

Question: does Phase126's late flat-observer closure actually repeat candidate
preparation, or is its source-level repetition cold and irrelevant?

The generic profiler's per-FID counters, linked segment-table validation and
lowered-owner map distinguish direct-entry dispatches from continuation entries.
The [reproduction script](../../selfhost/tools/performance/phase127/repeated-work.py)
authenticates all six original counter captures before extracting these entries.
The resulting evidence is `selfhost/build/phase127/repeated-work01.json`.

| Map request direct entry | Phase125 | Phase126 |
|---|---:|---:|
| `p112s_prepare` | 1 | 2 |
| `p113pl_candidates` | 73 | 146 |
| `p113pl_inspect_request` | absent | 1 |
| `p126bp_close` | absent | 1 |
| `p113d_passes` | 2 | 6 |
| `p118t_original_done` | 3,696 | 7,394 |

Lexer and closures each retain one `p112s_prepare` entry and unchanged candidate
traversal/lowering counts. Neither executes `p126bp_close`'s direct entry.
This matches the actual source branch: `p126bp_workers` selects `p126bp_close`
only when flat observers are present, and `p126bp_close` calls
`p113pl_inspect_request` again before dependency closure.

This is preparation for native lowering, not the fixed `p88_*` Base-carrier
decoder. Entry counts are observed dispatches, not a claim about every source
invocation: private calls and inlining can bypass entries. The specific source
path and the different fixtures make this useful evidence despite that limit.

Map also adds3,248,550 `String.order` allocation calls and799,884 allocations
under `p118t_original_done`. Restoring the transport certificate removes all
clearing but leaves every other per-FID count unchanged and leaves Map19.6%
slower than the contemporaneous Phase125 request. The duplicated lowering is
therefore a stronger next candidate than another generic runtime-helper tweak.

The next falsifiable experiment should retain the already-established immutable
candidate/semantic preparation or avoid candidates known to be discarded before
lowering. Require byte-identical final QBE, preserve the final independent
verifier and admission conditions, and compare Map plus an unaffected request.
Do not predict the whole-pass CPU saving from the small direct-context sample
share: dispatched descendants own those samples. Full-size compiler profiling
is a separate scale check, not yet a measurement of this pass's inclusive cost.
