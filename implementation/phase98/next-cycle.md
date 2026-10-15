# Phase98: operating the next laws/compiler cycle

Use laws to make a proposed compiler change easier to check, maintain and reject
when wrong. Add them at a concrete transformation boundary, together with its
source bridge, independent counterexamples and native observations. A theorem
count is neither a compiler-speed result nor a qualification result.

Phase98 demonstrates useful safe value contracts and maintenance. The actual
minimal-origin source has thirteen distinct accepted law names: eight public
contracts and five supports, covering comparison/tag and permission/membership
closures. The same contracts survived real implementation changes; one valid
codepoint refactor needed a support-proof repair, while the no-carrier comparator
retained its public equality statement. Repeated implementation checks add no
new contract names. See the [proof account](proofs.md) and
[source-specific receipts](../../selfhost/build/phase98/origin-proof-account01.json).

The evidence for usefulness must keep contract scope fixed. Independently selected
bad helpers were admitted without laws before unchanged laws rejected them. The
unchanged finite suites detected five of eight original bad changes; a separately
reported targeted follow-up detected all eight. Comparison faults caught by both
methods are shared detections. The repeated-left observation fault was caught by
a stronger internal-result law while its public Bool could remain correct; this
does not establish a public compiler regression missed by the finite suite.
Phase98 has not demonstrated that latter result. Preserve the
[detection matrix](review.md), including valid refactors that initially broke a
proof, instead of treating every proof failure as a semantic bug.

More laws are worthwhile when they close an observed gap or constrain a planned
optimization. The origin failure supplies such a gap: the accepted comparison
and permission laws did not prevent an eager `&&` from recursively evaluating a
nonfield refusal path forever. The minimal fix changes that operational behavior;
unconditional equality to the old executable would be the wrong specification.
The cache/redirect candidate had passing value controls and an accepted worker-list
law but addressed a different cause, so it remains unpromoted. See
[the origin investigation](../../experiments/phase98/P98-007-observer-ancestry-termination.md)
and [the retained cost hypothesis](../../experiments/phase98/P98-006-observer-planning-cost.md).

Whole-compiler correctness remains a separate, much larger objective. These laws
do not prove parsing/checking correctness, unsafe traversal termination, native
evaluation order, reference counting, foreign effects, or backend preservation.
An eventual compiler theorem needs explicit semantics and connected obligations
through each of those boundaries. Start with the boundary needed by the next
change; an unconnected model is useful exploratory work but cannot discharge a
production obligation.

Run the next cycle in this order:

1. **Choose a measured mechanism.** Record the actual source, profile quality,
   relevant generated C and a reversible patch before building an image. A hot
   sample owner is a lead, not a removable-time estimate. Keep candidate scope
   small enough to explain its observed effect.
2. **Freeze the contract and comparisons.** State full results, diagnostics,
   ordering, aliases and premises. Extract actual helper bodies and authenticate
   dependencies against the candidate. Independently choose bad implementations
   and a legitimate refactor before inspecting the law/test outcomes. Admit each
   bad helper alone before crediting law rejection; distinguish frontend rejection
   from independent kernel checking.
3. **Use cheap gates first.** Check source replay, safe helper admission, unchanged
   laws, complete-value controls and actual generated-code shape. Consume all
   relevant values, including retained roots and surviving aliases. Tag v3 passed
   its value proof while generated C still consumed the term; the desired native
   mechanism appeared only in the later inspected implementation.
4. **Measure the actual affected stage.** Use the same frozen inputs/assets,
   balanced order and complete outputs. Keep acquisition/build time, request time,
   process wall and generated-program runtime separate. Phase98's six-source
   request ratios were about 0.811 for upstream-built B1 and 0.939 for native B2;
   the two-pair same-input B2 self ratio was 0.937. These are different scopes,
   not interchangeable speedups. The
   [B1 screen](../../selfhost/build/phase98/origin-b1-screen01/report.json),
   [B2 screen](../../selfhost/build/phase98/origin-b2-screen01/report.json) and
   [B2 self comparison](../../selfhost/build/phase98/origin-b2-self-pairs01/report.json)
   retain the observations. Fresh TS/Bun context includes ordinary Base work
   inside its request; native cached preparation occurs outside that clock.
5. **Qualify the exact composition before promotion.** Require independently
   admitted B1, B1-produced B2, complete self-C/diagnostic consistency, original
   live/cache controls and exact rejections, 45 original program outputs, 69 golden
   executions per stage with 31 explicit exclusions, and all five final observer
   programs. A self fixed point can share a defect. Changed program C requires
   actual behavior checks and representative matched runtime evidence; exact C
   continuity can reuse the prior product evidence. Public CLI, source-profile
   reproduction and capsule restoration are separate gates.

Keep the qualification loop efficient without removing checks. Phase98's first
native 69 B1 attempt hit the 300-second suite deadline after 60 observations because
each isolated case repeatedly hashed 411.5 MiB of provenance. Snapshot 17 retains
the full closure before/after each suite and at collection/admission, while each
case checks the selected compiler and actual runtime/source/method inputs.
The next B1 suite recorded 69 passes in 68.63 guarded seconds. This is observed
harness overhead reduction, not a compiler speedup or a forecast for another
suite. Preserve failed attempts and verify process-status conventions: expected
exit one is a valid rejection only with the exact original diagnostic, no C,
empty stdout and no guard stop. The
[partition review](../../selfhost/build/phase98/conformance-partition-review01/report.json)
and [qualification methods](../../selfhost/tools/performance/phase98/qualification/README.md)
record those boundaries.

Prioritize these next obligations:

- **Origin termination and refusal.** Specify finite origin ancestry, exact root
  identity and strict structural progress on every recursive field step. Prove
  nonmatching nonfields return false without evaluating descent. Connect the
  specification to actual `noa_below` and `kid` behavior, including absent children;
  if a safe origin model is necessary, its production conversion needs an explicit
  bridge. Retain the valid root-swapping program as an owning fallback control.
- **Lazy branch behavior.** Use a trace or operational contract that distinguishes
  invoking a branch from merely returning the same Bool. Constrain selected-branch
  evaluation, errors and already-demanded arguments before optimizing branch
  closure construction. Pure Boolean identities cannot express the origin bug.
- **Held-root native adapter.** Connect the proved comparison value to the actual
  lowering: retain both roots until traversal finishes, permit only valid child
  observations, preserve live aliases, and release each ownership obligation
  exactly once. State sharing/static-node and foreign-provider premises. This
  needs a production-linked reference-count/heap invariant plus concrete native
  controls; the existing safe comparator theorem alone cannot establish it.

Promote a law because it constrains an actual boundary and survives an independent
bad-change/maintenance exercise. Promote a compiler change only after its own
stage-specific correctness, resource and performance gates pass. Report the
remaining trust boundary alongside each result.
