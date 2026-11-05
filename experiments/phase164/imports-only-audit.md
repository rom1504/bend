# Imports-only source audit

This is a bounded source review of `hybrid-imports-only.bend`. No compiler,
generated program or benchmark was executed by the reviewer. It is an ablation
of renderer registry construction after the original lowering and verification
pipeline, not another mixed-original admission boundary.

No concrete legality blocker was found under that private pipeline contract.
`verify-direct.bend:p113e_function` already requires a public direct worker to
match a real original header's arity, one-result ABI, zero incoming captures and
zero flags. `p164j_eligible` repeats those conditions on the actual final worker
signature and actual original segment, and adds the P112 arity limit of 32.
Private product/borrowed entries are not imported merely because their names or
arity resemble a boxed owner. The final public boxed entry is the authority.

The bridge is an existing ABI, not a new representation: maintained
`p113e_old_private` already emits a `p112w_*` ordinary forwarder to `p113d_*` when
generic region analysis has independently admitted that owner. Both interfaces
take `state` and consuming boxed words and return one boxed word. The new path
removes the redundant generic admission prerequisite. Its rank-zero registry
entries have actual emitted forwarders; they do not fabricate a valid generic
worker plan. Selected owners are excluded from generic candidates to prevent
duplicate symbols. The full original fusion index, headers, bodies and static
image remain intact.

Ordinary direct dependencies are verified in order; recursive direct work uses
the existing explicit loop/tail machinery. Direct scalar imports cannot perform
a scheduler jump/apply/frame transition. A closure's retained function ID is
data for later application, not an ordinary direct call back into a generic
region. Consequently this bridge does not itself introduce a new ordinary-call
cycle across the generic/direct boundary. This conclusion relies on retaining
the actual final direct/borrowed-projection and namespace checks, not merely
calling `p113e_signatures`. Existing ownership/cold/transport decisions remain
authoritative and unchanged. Metadata selectors alone are not an admission API.

Construction savings are limited to registry candidates and subsequent region
analysis now bypassed or simplified. Generic lowering, original verification,
the full fusion index and original tables are still built. Runtime gains are
plausible where the old bounded registry could not discover a safe ordinary
call to a worker already verified by the direct pipeline. Neither benefit is
established by source inspection; this does not claim recovery of all mixed
lowering savings or a whole-compiler speedup.

`selfhost/tests/phase164/hybrid-imports-controls.bend:p164jc_controls` contains
18 standalone metadata/ABI controls. They cover the exact 32/33 boundary,
missing/mismatched/private signatures, nonordinary headers, rank-zero registry
records without fake plans, selected-only candidate removal, independently
written zero- and two-argument forwarder strings, and omission of forwarders for
unregistered/rank-one workers. Empty-body fixtures test selection only; they
must not be interpreted as verified executable programs. A source-only delimiter
and unique-label check passed. Source acquisition and execution remain separate
root-owned gates.
