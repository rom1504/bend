# Same-request raw/static judgment reuse

This experiment is separate from the Phase142 cross-revision witness. Its parent
is Phase141 `integrated-source02`, SHA256
`f5bfca6d1fe9b378955d6c89ba5ec2428ec1627d7d008eb0c15eac1b51c8a06a`.
The original first verifier remains unchanged. Nothing is selected or qualified
by this source-only implementation.

## Actual invariant and boundary

`p140b_open` passes this request's program to original `p140v_open`. Its nonempty
cache is published only after generic metadata/bodies, the static image and
direct functions pass. `p140b_opened` passes that exact cache alongside the
boundary through `p134u_optimize`. That optimizer changes only direct functions;
both `p134v_commit` and its fallback `p114s_commit` retain the boundary's original
static program and IDs. `p114s_close` and `p113a_finish` only wrap those fields.

The sole override is `p140b_lowered`. It constructs the successor using the held
first-judgment original and the optimizer's functions/current certificate. That
same successor reaches both verification and late emission. No Boolean, caller
fingerprint or caller-supplied original grants authority. This is a private
internal callgraph invariant, not an unforgeable Bend data constructor or a proof
about arbitrary externally fabricated cache values. These helpers are not IO or
public compiler API entries.

If the first cache is empty, the original second verifier runs unchanged. A
lowering error follows the original error branch. Successful-session publication
and failure recovery remain the original `p140s_*` implementation.

## Work removed, and deliberately retained

The second boundary does not traverse generic bodies or rerun static-image
validation, and it uses the current first judgment's already validated metadata
and direct-verifier IDs. This applies on cold as well as warm requests.

The previous **array** cache still supplies direct-function reuse under the
original `p140v_reuse` gate. Its complete ordered raw-header/constructor and
direct-header comparisons remain; this prototype does not claim to remove
context discovery. Using first/pre-optimization functions instead would discard
potentially valuable warm optimized-body hits. Existing direct body comparison,
changed-body verification and ordered ready-signature publication are unchanged.

Original `p140v_array_done` still checks array and transport namespaces. The
original late observer/closure path and independent `p126bp_complete` remain
unchanged. The latter checks projected direct workers, not every generic body;
therefore this optimization relies specifically on the successful original first
judgment and actual unchanged-bundle construction.

The second raw counters report the first successful metadata scan's segment
count as retained and zero raw misses. They now mean same-request judgment reuse,
not cross-revision comparator hits. Direct counters retain their old meaning.

## Diagnostics and cheap qualification

`p142sr_original` compares all raw bodies/headers, ordered constructors, show
data, names, effects, purity and every static node/word. Effects matter because
the static-image validator consults them. `p134v_boundary_same` is insufficient:
it compares only validity and functions and omits original/IDs.

`p142sr_diagnose` explicitly rejects a mismatched successor original before using
the fast branch. `p142sr_optimize_diagnostic` runs the actual original first check,
optimizer and close path before that complete comparison. These roots are for
tests, not production admission. Deliberately invalid IR is only verified.

Compose `core-v01.bend`, `diagnostic-v01.bend` and the independent controls on
the Phase141 parent with only `p140b_lowered` allowed to change. Export the
ordinary `p140s_empty`/`p140s_named` entries for the same complete-request screen;
the witness's `p142w_*` entries must not be composed. Required checks are finite
negative controls, actual optimizer conservation, cold/warm edited complete QBE
identity on unrelated families, exact failure/recovery, then paired cost.

The historical 40.079-second optimization/verification stage includes substantial
other work and is not a saving estimate for this change. Measure this boundary
and the complete request before considering another native acquisition.
