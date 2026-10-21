# Optional scoped table-frame template ablation

This is separate from the frozen ready-call prototype. Compose `model.bend` after
ready-call/model.bend; the only replaced definition is `p114h_stmt`. It adds
p124f_case_buffer/expand/render/stmts. `controls.bend` exports p124fc_controls,
twelve pure literal PASS/FAIL rows. No compiler or target was run by the author.

A global extension of `p114t_buffer` is deliberately avoided. Its whole-program
namespace verifier reserves p114t_, whereas p114h_ reservation is established only
for the selected H plan. Accepting arbitrary original locals with a matching
case-name spelling globally would conflate spelling with provenance.

Instead only frame lists inside P114RDescend and P114RResumeReady visit the new
hook. These lists come from the exact original p112f_frame parser: scratch capture
stores followed by p111_rt_frame, with matching capture count. The selected owner
and all closed continuation bodies passed p114h_clean_segment, which prohibits
original p114h_/p114r_ names. Original safe bodies cannot assign/alias arbitrary
pointer names; scratch comes from the verified fixed prelude allocation.

Inside an emitted case, p114h_cases renames all original scratch references with
p112f_name(p114h_prefix(index),"scratch"); p114h_buffers allocates that exact name
as alloc8 2048. Case closure is bounded to eight cases. The new guard requires:

- The actual buffer equals the active case buffer argument supplied by H emission.
- It is exactly one of p114h_case_0..7_local_scratch, not a prefix match.
- The unchanged exact runtime signature/state, zero high word, count0..8 and known
  continuation FID are present.

Owner-entry scratch and any unknown shape delegate unchanged to p111q_stmt. The
global buffer recognizer, original graph verifier, private-body verifier and
namespace gates are untouched. No additional callsites outside authenticated H
frame lists can reach this expansion through production emission.

The emitted replacement is the *existing* p114t_frame template. It preserves the
ordered capture-load/stack-store pairs, writes the same FID, advances SP by the
same amount, and returns the same zero destination value. p114t_expanded retains
fresh-site allocation and the p114t_ reserved namespace. No ownership operations,
control transfer, frame depth accounting or unwind logic change.

This is a falsifiable category-removal experiment, not a measured gain. Require
all pure controls, exact ordinary alias/deep outputs, absence of the one/three
retained frame callsites in list/tree private owners, and paired runtime/compiler
cost. Reject if the added context-specific helper complexity has no material
benefit.
