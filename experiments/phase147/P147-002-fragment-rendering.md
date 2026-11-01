# P147-002: avoid materializing intermediate instruction strings

Status: integrated and ordinary serial native-qualified;
[final report](../../implementation/phase147/README.md).

The current full native profile assigns 47.469 seconds of thread CPU to rendering,
output and teardown (19.0%). String.append accounts for 16.3% of active owners
within that interval and p111q_memory for 9.1%. These are overlapping attribution
views, not additive gain estimates. The 262.496-second clean cold pipeline is the
acceptance baseline; diagnostic timing is not its replacement.

Hypothesis: append argument and instruction fragments directly to the existing
reversed P111QCode chunk list, then flatten once at the existing body boundary.
This removes argument-string and instruction-string construction without changing
QBE selection, temporary numbering, function boundaries or output bytes. The
existing chunk consumer accepts arbitrary string fragments rather than whole lines.

The first call-only native experiment passed complete-output comparisons. The
broader experiment adds memory, Set, Bin and Offset rendering. All 28 independent
controls and three complete captured current bodies agree with the original.
Six alternating native pairs per body give general/original ratios 0.634, 0.689
and 0.870 (Map, Lexer and a small compiler function). Compared with call-only
rendering, ratios are 0.770, 0.761 and 0.952. Each iteration includes rendering
the full function and writing it to /dev/null. These selected straight-line
bodies establish a mechanism, not a representative whole-compiler speedup.

Canonical integration replaces three existing definitions: p111q_args,
p111q_memory and p112a_original_stmt. No new emitter family is needed. Preserve
specialized dispatch and nested branch selection. All18 complete selected-body
comparisons, native requests and the exact117,232,528-byte frozen-source product
pass. The combined compact-admission/rendering cold build is246.745s; final
integration246.173s. Final render/output/teardown profile is38.864s. These
combined results do not isolate renderer-only end-to-end savings.

Evidence: `selfhost/build/phase147/render-fragments01/`,
`render-fragment-native-plan01-{original,calls}-pairs/report.json`, and
`render-integration01/report.json`. Final reporting must preserve consumed
sources/methods and separate native acquisition cost from timing cost.
