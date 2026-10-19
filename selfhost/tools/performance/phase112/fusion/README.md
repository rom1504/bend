# Optional one-level continuation fusion

This is a prototype, with no target result claimed by its source preparation.
The hypothesis is that an ordinary non-tail call into an already admitted
private worker can avoid its temporary continuation frame and two dispatcher
transfers while retaining all original owning operations.

The matcher accepts only ordered capture stores, one exact `p111_rt_frame`,
ordered argument stores, and a complete jump/return suffix to a private target.
The continuation must have result one, incoming one, flags zero, and the exact
scratch/stack-pop/capture-get/result-get prefix emitted by `p111_segment`.
Captures and arguments are snapshotted in their original order before the private
call. The original zero return value of frame/pop operations is retained as a
plain assignment. The returned Term and capture snapshots then bind the known
continuation locals, followed by its renamed body.

Every inlined local and scratch allocation receives a fresh per-site namespace.
An original `p112f_` local refuses fusion. A separate scratch buffer preserves
the original fresh-allocation boundary. The suffix gate refuses extra register
or stack reads, raw state access, extra allocations, unknown external calls and
nonstandard control transfers. The existing state/scratch-safe runtime helper
gate is required. Frame, jump, return, apply and fail operations in the copied
continuation retain their original order. The removed transport register bank
contains no independently scanned owner credits.

Private eligibility, target indexes and private bodies all use the original
graph. No fused public function becomes a new private candidate. Consequently
private non-self calls retain the existing three-rank DAG, and self loops remain
local jumps; input depth cannot introduce an unbounded machine-call cycle.
Inlining is one level only, with at most eight callee arguments, eight captures,
eight sites per public segment and 128 statements in each copied continuation.
Each site adds 2 KiB of scratch allocation to the public machine frame.

Continuation lookup uses a typed Patricia index built once per emission or count
request. It stores original `N111Segment` values directly and reuses the mature
32-bit hash and differing-bit rule. Hash collisions compare full names; duplicate
names retain the former first-match selection (the program verifier separately
rejects duplicates). With S segments and F candidate sites, lookup work changes
from up to F*S name comparisons to O(32*S + 32*F), plus name hashing and exact
collision-bucket comparisons. The live compressed tree has at most 2*S-1 nodes
plus buckets, rather than a full 32-level path for every segment. This is a
source-level complexity argument, not a measured speed or memory result.

## Composition and coordinator gates

Append `model.bend`, `index.bend`, `rename.bend`, `plan.bend`, `build.bend`, `emit.bend` after the
existing loop/direct worker modules, `side-exit.bend`, `runtime-safe.bend` and
their existing overrides. Use `entry.bend` as the optional final
`p111q_segment_chunks` override. No workers file is modified. A zero-fusion segment
uses the existing direct-worker emitter exactly.

The optional private fail-stop profile needs a conjunctive admission receipt
pinning this final hook and all `p112f_` declarations in addition to its original
worker/runtime requirements. Its existing receipt intentionally refuses this
different hook; do not reuse that receipt silently. Pinned CPU
`err_post -> _exit(1)` remains essential for that separate extension.

Export `p112f_plan`, `p112f_count`, `p112f_program_counts` and
`p112f_segment_chunks`, alongside the normal verifier, IDs, chunks and
`p112w_segment_chunks` exports. `controls.mjs API FRESH_OUTPUT` prepares six paired
native witnesses and refusal controls. It checks the actual Bend planner,
snapshot ordering, private call mechanism, exact fallback, name hygiene and
retained pending outer frame. The witnesses cover positional captures/arguments,
zero captures, observable zero frame return, a pending outer continuation, and
two release orders for a shared Unicode String through a long private self loop.
Run both variants against the same pinned runtime and compare full output.

The public plan/chunks/count interfaces are unchanged. The normal loops call
their indexed internal helpers; compatibility helpers receiving a segment list
build one index for that call. `index-controls.mjs API FRESH_OUTPUT` compares
complete segment results with a separate linear oracle across three insertion
orders, Unicode names, misses and duplicates, and checks forced collision
buckets. Export `p112f_index`, `p112f_index_get`, `p112f_index_find` and
`p112f_index_insert` for these additional finite helper controls.

`source-owners.bend` is a separate actual-source ownership witness. Run frozen
source controls and count actual admitted sites with `p112f_program_counts`
before timing. The returned `changed-segments/sites` is a measured structural
count only after execution on the authenticated graph. Original verification is
mandatory; the post-verification emission transformation has its own narrow
admission and is not a proof of ownership or of arbitrary native callers.
