# P114-010: complete transport coverage of authenticated table buffers

Status: optional source-only experiment prepared before target execution.
The selected source02 and its running native chain remain unchanged. Parent
source SHA256 is `500211d484785778e75d5d4388b0d5ebc7282effd233c6b8f3d0e0269ac777f8`.
The frozen overlay inventory is
`selfhost/tools/performance/phase114/transport/table-buffers-modules01.json`,
SHA256 `1109ddeac2f1f56c34b28aa9de3a3a38679cdc0af89dec47d0a4239b8d8f0513`.

Hypothesis: resumed H cases still call the generic frame helper because their
distinct scratch allocations are missing from the existing transport recognizer.
Accepting the exact eight factory names should expose those frame stores through
the already qualified template. This closes a coverage gap; it does not remove
needed captures, change recursive-region admission, or establish a broad speedup.
Existing selected expression/tree QBE provides the actual ordinary witness.

The 21-line overlay replaces only `p114t_buffer` and `p114t_local_name`, adding
two bounded name helpers. It admits only `p112f_name(p114h_prefix(i),"scratch")`
for `i=0..7`, and reserves those same names in original verified graphs. Prefix
matching alone never admits a buffer. All existing buffer cases remain accepted.

Independent source review follows the whole origin boundary: the unchanged
original verifier checks definite assignment, the final namespace pass checks
definitions and direct parameters, H rejects original reserved locals, and
`p112f_cont_body` requires a 2048-byte/alignment-eight original scratch allocation.
H closes at most eight cases, allocates a distinct 2048-byte buffer per case,
and uses the same injective factory when renaming its stores and frame call.
The state pointer remains unchanged. These are authenticated compiler-factory
premises, not an ownership certificate inferred from arbitrary local spelling.

No concrete source defect was found. The original frame signature, known-FID
check, count bound, ordered capture load/store pairs, FID store, SP update and
fallback remain exact. The new namespace refusal is necessary: without it,
another original graph could claim a newly accepted spelling without the H
allocation origin. The selected tail-accumulator namespace wrappers continue to
invoke the strengthened predicate and retain the original final verifier.

Root-run gates, after the native lane releases: checked API and exact source/
runtime composition; finite string recognizer observations for the eight names
and ordinary other spellings; unchanged complete outputs for two-child expression
and owned-tree source controls; inspection showing the resumed frame helper sites
disappear while other operations remain; then three rotated rounds on the same
frozen expression/tree workloads and counts. Any output failure stops the trial.
Require at least a 3% geometric elapsed-time reduction on that matched pair
before considering selection; smaller or noisy results remain optional. This
threshold does not qualify a full-corpus or native-compiler claim.

No malformed-program/custom failure campaign, new runtime object, C-text rewrite
or generated-QBE rewrite is proposed. All semantics remain in Bend and the
unchanged transport/runtime contract. Record correctness, measurement and
selection independently, preserving this parent and experiment if rejected.
