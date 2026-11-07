# Phase173: specialize known local continuation destinations

This is a source/machine audit and experimental sketch, not an implemented or
measured speedup. It follows the successful product-argument ABI bridge.

The bridge exposed complete stack-safe loops in actual native code. However,
the generic SCC representation turns every known local transition into a
constant state tag, parallel parameter moves and a jump to a shared dispatcher.
That representation preserves stack safety while discarding a known branch
destination. QBE does not recover all those destinations.

## Observed work

The [static census](vertical-dispatch-abi03.json) pins the complete ABI03 QBE and
assembly. [Exact assembly bodies](vertical-dispatch-abi03-bodies.s) preserve the
four core workers; `vertical-dispatch.py` only reads retained artifacts.

| Worker | Members | Constant backedge sites | Dispatcher comparisons | Assembly instructions | Exchange instructions |
| --- | ---: | ---: | ---: | ---: | ---: |
| Import | 9 | 14 | 8 | 670 | 49 |
| Export | 11 | 14 | 10 | 764 | 90 |
| References | 6 | 7 | 5 | 292 | 24 |
| Compaction | 36 | 50 | 35 | 2,504 | 203 |

These are static counts, not dynamic frequencies. Complete fused workers are
larger than individual pre-fusion helpers; comparing those totals alone would
be misleading. The important observation is the retained dispatch at a boundary
where the compiler already knows the target.

For example, the compaction worker's `.Lbb3732` begins with register spills,
`cmpq $0, %rdi`, Boolean materialization, and a conditional branch, then continues
through other state comparisons. Some unrelated computations were moved between
comparisons. The original QBE contains 50 `%p113_again_0 =l copy <literal>` sites,
each eventually jumping to `@p113_loop`. These are not indirect calls requiring
runtime target discovery.

The root's ABI03 measurement is 93.690 ms for the indexed complete consumer
versus 78.649 ms for the original KTerm complete consumer. It is already about
40.6% faster than the earlier indexed implementation, so this proposed change
addresses remaining overhead after a real improvement. No measured fraction of
that remaining time has yet been attributed specifically to the dispatch.

## Smallest transformation

Keep `P113DFunction` and `P113DAgain` unchanged. Derive a bounded emission plan
from an independently verified function:

1. Recognize a top-level dispatcher whose selector is a function parameter.
   Permit only `N111Alloca` declarations before the dispatcher. Require an exact
   chain of pure equality definitions and matching `P113DIf` nodes, with unique
   constants and no extra statements on the dispatcher spine.
2. Establish that each comparison temporary is used only as its own condition.
   Skipping a test must not leave a value used by an arm undefined. The selector
   itself may be used in arms and must retain its ordinary parameter assignment.
3. Give each arm a fresh local label. Preserve the original dispatcher for the
   initial entry and for unsupported or dynamic backedges.
4. For an admitted literal-selector backedge, perform the existing complete
   snapshot, then all parameter assignments, then jump to the known arm label.
   Preserve each arm's ordinary lane-to-local binding prefix.
5. Keep all unknown shapes and values on the exact original emitter path.

No native recursion, extra heap state, new semantic IR variant or change to the
independent final verifier is required. This is specialized emission of already
verified control flow. A semantic proof obligation remains: the skipped tests
are pure, their results are unobserved, and the branch destination is exactly
the one those tests would select.

## Source constraints that matter

`scc-v2.bend:p173sc_cases` creates the comparison spine. `p173sc_case` supplies
each arm's lane binding prefix. `p173sc_scratch` adds only `N111Alloca` nodes;
`verify-direct.bend:p113e_allocas` hoists them before `@p113_loop`, and ordinary
scalar emission treats the remaining alloca nodes as no-ops. The proposed jump
must stay after function-entry allocation, not bypass the aggregate frame.

`verify-direct.bend:p113e_snapshot` and `p113e_moves` preserve parallel-move
semantics. The actual audited store workers use these `%p113_again_*` paths.
Other functions may use `product-composition.bend:p126i_other` or
`typed-regions.bend:p126l_other`, whose backedges use `%p126_next_*`. A broad
emitter change must account for those routes or explicitly retain their old
behavior. Changing only the common final jump without a function-specific
verified mapping would be unsound.

Use a structured plan or emitter context rather than scanning emitted strings
or recognizing a benchmark function name. The plan needs only the selector
position, exact literal-to-arm mapping, fresh labels and a conservative fallback.

## Cheap falsification and rejection controls

Start with exact existing final verification and a bounded native control that
swaps two lanes on a backedge, reads the selector in an arm, retains scratch
storage, and reaches the final default arm. Preserve the complete-output oracle.
Negative controls should retain exact original emission for a side-effecting
prefix, different selectors, observed comparison temporary, duplicate constants,
trailing dispatcher statements, dynamic selector, unsupported 64-bit constant,
wrong arity and namespace collision.

Then emit the actual 101-body consumer through the changed Bend emitter. Compare
machine code before timing: the known edges must bypass the long dispatch and
must not add compensating calls, boxing or spilling. Reuse the fixed complete
output oracle and balanced process timing. If there is no useful runtime gain,
reject this as the next performance lever rather than extrapolating from fewer
branches. Full self-build qualification is unnecessary for this falsifier.

The broader reusable lesson would be preserving known local control-flow edges
through stack-safe SCC lowering. It is not evidence that compact stores, or all
large SCCs, are automatically profitable.

## Independent review of the experimental implementation

The separate `dispatch-jumps.bend` implementation follows this bounded plan.
Its overlay intercepts `p113e_stmts` only when the current output begins at the
initial `@p113_loop` chunk. It requires a first-parameter U64 selector, at most
63 comparisons, unique tags/test names, unobserved test temporaries, terminal
arms and complete backedge arity. Literal tags absent from the tested set go to
the original default arm; nonzero high halves and dynamic values keep the
dispatcher. It preserves full snapshots and assignments, so swapped parameters
and selector reads remain meaningful.

Source review found no critical control-flow or ownership issue. The width-pair,
mask and Boolean-diamond paths remain selected in the new contextual renderer.
Other typed/P126 entry routes retain their previous emitter. The existing final
schema verifier already rejects a test temporary colliding with a hoisted alloca;
no duplicate expensive admission scan is needed for that malformed case.
This is an independent source audit of an experimental emitter, not a proof of
compiler correctness or a substitute for the root's finite and native gates.

## First replay: useful partial coverage, largest worker refused

The root's `dispatch-store-replay01` and native `dispatch-store-pair01` completed.
The [whole-product comparison](vertical-dispatch-replay01.json) checks every
function/data block: both products have 1,997 blocks, in identical order, with
no additions/removals. Exactly nine SCC worker bodies changed. Every data block
and every other function body is byte-identical. QBE grows by 2,050 bytes because
the renderer adds explicit arm labels; text shrinkage is not the objective.

Import's 14 constant backedges, export's 14 and reference collection's seven now
jump directly to their arms. Their only remaining `@p113_loop` jump is entry.
However, **compaction's 50 backedges are unchanged**. The Word decoder is also
unchanged. The largest intended optimization had not actually been selected.

| Worker | Instructions before → after | Exchange instructions | Instructions referencing stack |
| --- | ---: | ---: | ---: |
| Import | 670 → 641 | 49 → 34 | 154 → 159 |
| Export | 764 → 695 | 90 → 41 | 138 → 151 |
| References | 292 → 285 | 24 → 16 | 31 → 32 |
| Compaction | 2,504 → 2,504 | 203 → 203 | 763 → 763 |

Call counts are unchanged. Static stack-reference counts and stack frames
sometimes grow, despite fewer instructions. These are complete-worker counts,
not dynamic profiles. [Exact candidate assembly](vertical-dispatch-replay01-bodies.s)
is retained.

Four balanced pairs with exact full outputs measure **95.102 → 91.818 ms**, or
0.96547× (**3.45% lower elapsed time**). This campaign's baseline is the ABI-fixed
indexed implementation, not KTerm. It does not establish a new full compiler
speed ratio.

Source/metadata inspection identifies a conservative admission restriction:
`p173dj_terminal` accepts an `If` only as the final statement. Valid helpers in
both refused components contain a nonterminal `If` followed by a common result:

- Word: `$product.p173branch_37`, `body/9/no/8/yes/20`.
- Compaction: `$product.p173match_15`, `body/12/no/12/yes/21`.

Those paths refer to the full frozen
`abi-store-admission03/complete-candidates.json` artifact, not to synthesized
test IR. Both conditions are followed by scalar statements and a final
`P113DResult`. This explains a precise restriction to test next; it is not yet
proof that it is the only final-worker refusal. The proposed relaxation is to
recognize a terminal common suffix after a nonterminal conditional, while
retaining the unchanged independent flow verifier and a finite join control.
Reinspect the final emitted worker before interpreting the next runtime result.

## Revision 2: independent source audit

The revision-2 implementation adds only the non-final-conditional recognition
case described above. The renderer, snapshot/assignment order, labels, fallback
and comparison-temporary use guards are unchanged. Six added controls cover
common result/backedge continuations, an early return/backedge in one branch,
and preservation of Boolean-diamond and ordinary branch rendering. Independent
source review found no critical issue; no target execution was performed by the
reviewer.

The alternate typed-emitter hypothesis does not explain these two frozen
workers. In `dispatch-source01/compiler.bend`, both P126 emitter paths necessarily
use `%p126_next_*` for `Again`, whereas every audited compaction/Word backedge
uses `%p113_again_*`. The currently selected legacy paths enter the patched
`p113e_stmts`; the old `p114so_private` implementation has no selected callsites.
There is no evidence requiring a typed-emitter expansion before testing revision
2. Actual final QBE should demonstrate compaction's 36 arm labels and redirected
50 constant transitions before paying for another native machine build.

## Revision 2: complete intended coverage and native result

The root's second replay confirms the predicted boundary. The
[complete product comparison](vertical-dispatch-replay02.json) again retains all
1,997 blocks and every data block. Exactly **11 SCC workers** change, with no
added or removed functions. Compaction now has 36 arm labels and 50 redirected
constant transitions; Word has 11 arm labels and 11 redirected transitions.
Both retain only the initial jump to the dispatcher. This demonstrates that the
non-final conditional admission restriction was the remaining blocker for these
two workers. A typed-emitter expansion was unnecessary.

| Worker | Instructions before → after | Exchanges before → after | Stack-reference instructions | Frame bytes |
| --- | ---: | ---: | ---: | ---: |
| Compaction | 2,504 → 2,017 | 203 → 141 | 763 → 516 | 1,160 → 1,400 |
| Word decoder | 776 → 773 | 32 → 23 | 183 → 174 | 472 → 520 |

Compaction loses 19.4% of its static instructions, 30.5% of exchanges and 32.4%
of stack-reference instructions. Its 158 call sites are unchanged. Its frame
grows, so fewer stack accesses must not be described as less stack space. The
[exact revision-2 assembly](vertical-dispatch-replay02-bodies.s) is retained.
The other nine transformed workers have the same code as revision 1.

Four balanced process pairs produce the exact independent full output and
measure **95.012 → 87.429 ms**, or **0.920195× / 7.98% lower elapsed time**.
The baseline is the same ABI-fixed indexed implementation. This is the complete
intended dispatch result; the earlier 3.45% result represented partial coverage.
The two percentages are separate baseline-controlled campaigns, not additive
gains. The original KTerm consumer remains a distinct baseline, and no new
whole-compiler speed claim follows from this result.

QBE grows from 12,717,939 to 12,721,699 bytes; assembly shrinks from 6,061,415 to
6,051,615 bytes. The mechanism is bypassing a known-state dispatcher and exposing
known control-flow edges to QBE. The observed instruction/exchange reductions
are consistent with easier register allocation; they do not isolate its dynamic
contribution. Neither IR text compression nor call elimination explains the gain.

## Transfer to existing compiler computations

A [read-only census](vertical-dispatch-transfer.json) of the retained qualified
Phase170 N1 product finds **16 existing two-state SCC workers and 33 constant
backedge sites**. These include:

- `f_find` / `f_find_next`.
- `p111q_decimal_go` / `p111q_decimal_step`.
- `p113i_bucket` / `p113i_bucket_head` and
  `p113j_buffer_origin` / `p113j_buffer_peel`.
- `String.contains`, trimming, prefix tests, `U32.read`, `U32.show`, `Nat.show`
  and borrowed name membership.

All use the legacy snapshot path. The
[exact canonical lookup-worker assembly](vertical-dispatch-canonical-find.s)
retains a tag comparison and branch at `.Lbb16593`, including a constant-tag
backedge to it. These are plausible transfer sites in actual compiler code,
not newly synthesized workloads. However, each has only one dispatcher
comparison, so the 36-state compaction gain cannot be extrapolated to them.
Dynamic weights and complete compiler gains remain unmeasured.

The existing verifier probe contains only the two-state `U32.show` SCC, making
it a weak test of this transformation's potential effect on compiler lookup.
A more informative bounded transfer source already exists:
`phase166/lookup-source02/compiler.bend` (15,408 bytes), with an exact-value
variant at `phase171/descendant-full-values01/actual.bend` (15,417 bytes).
These can test the retained lookup path before another full native image build.
No new compiler dump or target execution was performed for this census.
