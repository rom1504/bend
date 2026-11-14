# Independent joint/regional overlay review

Reviewed `selfhost/tests/phase195/hybrid/overlay-v1.bend` against the maintained
`loop-liveness.bend`, `transient.bend`, `call-arguments.bend`,
`parallel-moves.bend` and inline-F32 contract. This is read-only source review;
no target, source check or new execution was performed by the reviewer.
No semantic blocker was found in v1. Compiler acceptance and controls remain
separate requirements; this review is not a formal proof.

## What makes this composition safe

The sole override runs only after the original joint-color validator succeeds.
Existing joint assignments remain unchanged. The overlay reconstructs the same
at-most32 candidate IDs, recomputes the existing33-step loop fixed point, and
uses the existing backward transfer functions with graph collection disabled.
Failure to solve returns the already validated joint frame.

Every positional event reserves candidate bits in live-in, live-out, and
explicit writes. The write term is necessary even for dead definitions:
their machine stores still clobber an assigned register. Again additionally
reserves the loop header and parameter vector. Inline-F32 writes use the
canonical contract's destination. A local interval rejects any caller color
whose existing joint group intersects these reservations anywhere between its
inclusive first and last endpoints.

This handles the chief trap: a global value can be live across a branch arm
without appearing in any statement inside that arm. The suffix liveness sees
it; a scan of names mentioned in the arm would not. Live sets alone would also
miss an otherwise dead global write in the middle of a regional local's life.

The overlay's branch positions match `x185_t_if`: the condition occupies the
preceding endpoint, then the yes arm, a blank cut, the no arm, and a final cut.
Each arm gets the common continuation live-out. Both conditional IR forms use
this rule. A final position-count mismatch refuses overlay placement. Count
equality alone would not prove correspondence, but the inspected event cases
and branch ordering agree with the existing scanner.

Eligibility is still defined independently by `x185_t_body`: first occurrence
must be a write, all reads and writes must stay within one region, setup
definitions and parameters are excluded, and ordinary call arguments/results
are forbidden. The installer additionally requires an original Stack slot and
absence from the joint candidate-ID map. Inclusive endpoints and the existing
five local end positions prevent overlapping overlay locals from sharing a
color. It only uses caller colors4..8; saved-register homes are disjoint.

Consequently no new import, call-save or parallel-copy protocol is introduced.
The existing call planner recognizes transient homes and snapshots arguments
when needed; the existing Again planner schedules by actual homes or falls
back to snapshots. The overlay does not change parameter homes. Reserved
scratch registers remain outside the five-color pool, and the original safe
operation gate remains authoritative for implicit machine clobbers.

Float placement and selected ordinary placement remain trust boundaries:
their analysis rows must include every actual relevant read/write and respect
the existing scratch contract. The overlay does not repair a mismatch in
those views. Reusing the same transfer functions and scanner avoids introducing
a separate interpretation of hidden F32 operands.

## Smallest useful falsifiers

1. **Silent live-through:** assign a joint caller-home value before an If;
   inside one arm define and use a regional Stack local without mentioning
   that global; return the global after the join. Force an attempted same-color
   overlay and assert that color is rejected. Also exercise the opposite arm.
2. **Dead write:** keep an overlay local live across a write to a joint name
   whose new value is dead on that path. Other paths can make the name a joint
   candidate. Omitting explicitWrites must break the control.
3. **Backedge:** keep a setup/global value live only through the next loop
   iteration; place a regional local just before Again. Include a parameter
   rotation to exercise actual-home parallel scheduling and snapshot refusal.
4. **Cuts and hidden operands:** include nested scalar/private conditionals,
   a real call, a multi-result call, and inline F32 buffer/destination events.
   Check the unchanged exclusion rules and positional agreement.

Each control needs an actual installed-home assertion plus an independent
result/effect oracle. Correct values under a refused or empty overlay do not
test the new allocation path. A pressure case where every color is blocked
must retain Stack and preserve the joint frame.

## Profitability and bounded cost

The implementation can recover regional homes for names outside the joint32
without widening bit masks or weakening graph validation. This has broader
potential coverage than the row-budget experiment: the dominant nearest and
editdist owners already pass joint allocation but have many noncandidate
locals. Actual installed homes and emitted hot instruction changes must show
whether that potential is reached. Float XMM placement may supersede GPR homes.

Repeated suffix liveness and interval-mask scans make the added analysis
quadratic in the bounded row count. V1 inherits the unchanged256-row joint
gate. Composing it with the separate1024-row experiment changes that cost
bound and needs explicit compiler-cost evidence. Successful checking and
finite control equivalence do not establish either runtime profitability or
acceptable self-compilation cost.

## V2 controls handoff

The v1→v2 implementation diff only moves the computed inline-operation match
into a parameter helper to satisfy source syntax. Its reviewed behavior is
unchanged. `controls-v2.bend` supplies18 checks:13 analysis/eligibility checks
and5 installed-home assertions. The expected values were independently read
against the implementation, including color1 refusal/reuse around the forced
color0 global. The pinned transport and complete existing-machine-control argv
are in `selfhost/tests/phase195/hybrid/controls-README-v2.md`. They were authored
without running targets. A passing label count must not be described as18
machine-admission observations or as generated-program equivalence.

Root's v2 source check refused a match following local bindings in
`x195_h_stmt`. V3 factors that match and the same pattern in control helpers
`p195h_points`/`p195h_counts` into parameter-matching helpers. No allocation,
mask, point-order or expected-result rule changed. The new overlay/control
pins and driver are versioned separately; previous files remain frozen.
Metadata-only block inspection and parser-only driver validation completed;
the reviewer did not execute the checked compiler or any targets.
