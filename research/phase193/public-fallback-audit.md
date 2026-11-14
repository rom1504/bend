# Independent public fallback adapter audit

Final source review inspected maintained
`selfhost/src/back/x86/public-composition.bend`, original `p112c_plan_index`
and `p112w_public`, their QBE consumers, x86 availability/forwarding, the
integration hook in `program.bend`, and runtime frame/return functions. No
semantic mismatch was found within this review. The root-owned finite gate
now passes: 13 data controls in each of four roles and 1,024 independent C
observations across eight generated-code routes. This is not a general
compiler proof. The reviewer ran no compiler or target jobs.

The maintained module SHA256 is
`83327571c810d7ad2220a82c1043c734a0207bba17eb6ac55b55c4a69d4cc895`.
All 24 `x193f_` function headers and bodies are exactly equal in the maintained
module, `candidate-source01/compiler.bend`, `controls-parent03/compiler.bend`,
and `controls-api-source03/compiler.bend`. Comparison omits only blank
separators between functions; it does not normalize tokens or annotations.
Their sorted concatenation SHA256 is
`f0188b8798e8368d773b5590757d4a7fe6bba41a2559f91814dfb7f9262e6ac7`.
In particular, all consumed sources use `P112WorkerCall{target,count}`.
The standalone experimental file's later `+count` spelling is not the source
consumed by the passing control API.

## Preserved contracts

`p112c_plan_index` in `closed-regions.bend` only rewrites one-result, zero-flag
segments with clean names. It has an eight-site expansion bound and consults
the original immutable ready registry. It checks exact frame captures,
continuation shape, helper arity, ordered argument stores and terminal jump.
Its continuation recognizer excludes observation of raw state, the runtime
register bank, and popped stack slots after its recognized prelude.

`p112f_fused` snapshots captures, assigns the removed frame's zero result,
then snapshots arguments and calls the helper. `p112g_splice` puts admitted
preparation after the capture/frame-result prefix and before argument
snapshots. The adapter retains this generated scalar sequence intact. This
ordering matters when preparation modifies a captured local. Continuation
capture/result bindings use the existing renamed local scratch and assign
the removed pop's zero status explicitly.

`p112w_public` itself has no one-result/flags gate. That gate belongs to
`p112w_public_segment`, together with its original direct-tail-plan precedence.
The adapter mirrors both, and retains the original self-target refusal.
Its `x193f_call` loads all scratch arguments into separate temporaries before
calling the private helper, then writes the one-word result to scratch,
invokes `p111_rt_return`, and returns that status.

The final runtime return is necessary. `runtime.c:4153` copies results into
the register bank, sets `rn`, and pops the caller's next FID from the runtime
stack. A machine return of the child value would leave all three wrong when
the public segment has a pending outer continuation. The original ready
worker returns a value privately; the adapter remains a public scheduler
segment.

The one-line integration hook remains beneath the existing mode/direct-worker
selection gates. H gets first refusal, and a valid H plan retains its existing
emission/fallback behavior. Original public-body availability preflight is
unchanged. Candidate body availability/hygiene errors and selector refusals
return the complete original segment. No unavailable legacy symbol is assumed
to exist merely because the QBE ready registry names it.

The reviewer identified a namespace obligation early: QBE's raw `%p112_arg_*`
temporaries differ from its `%v_*` locals, while N111 uses one local namespace.
The adapter now checks all definitions and local uses, including nested arms
and argument expressions, against its `p193f_` prefix. Existing x181 hygiene
alone would only protect `__x181` and would not establish this condition.

## New independent runtime observer

`selfhost/tests/phase193/ready-fusion-controls-v2.bend`,
`ready-fusion-controls-v2.c`, and `ready-fusion-controls-v3.mjs` extend the
original source-verifier/planner controls without manufacturing a valid
fusion plan. The helper ready set comes from `p112w_index`, and
`p193rf_validate` checks both all original segments and original helper
admission. Its exact typed private provider is emitted with the same
two-argument, one-result arithmetic as the public helper.

The fixture captures input x, then admitted preparation changes x by six.
The helper computes `2*a+b`; the continuation adds the earlier captured x.
Expected owner output is therefore `3*x+12+y`, with unsigned 64-bit wrapping.
The frame and pop status words also enter calculations and must remain zero.
The separate public-tail fixture passes swapped arguments, expecting `2*y+x`.

Four isolated roles cover plain, fusion only, tail only and their composition.
The C observer activates the pinned runtime through the same complete CPS-IO
descriptor method as Phase192, then manually drives the original public
scheduler to a valid preexisting outer FID. It checks every P111State byte,
all 16 runtime-stack words, register result and clearing, SP, rn, next, machine
status and the expected number of public dispatcher entries.

The retired local-frame slots legitimately differ: original and tail-only
owner execution write capture/FID there, while fusion leaves their prior
guard values. The oracle specifies both, and requires all live outer-frame
words and unrelated guard slots to remain identical. Treating all retired
stack bytes as necessarily equal would incorrectly reject frame elimination.

Eight 64-bit boundary inputs in each argument position yield 128 observations
per role/route. The driver renders and directly encodes the same typed output,
then observes each independently linked route. Its 13 data controls include
missing-ready, wrong-ready-arity, malformed-frame original-verifier refusal,
unavailable-symbol refusal, and nested reserved-local use. The complete
[ready-controls03 report](../../selfhost/build/phase193/ready-controls03/report.json)
passes all four roles, each on direct ELF and rendered GNU assembly routes.
The reviewer independently authenticated all eight stdout hashes and exact
literal outputs: each reports 128 observations and zero failures. The 52
data-check executions repeat the same 13 controls across roles; they are not
52 distinct cases. Fixture and driver label lists agree exactly.

Two observer failures remain preserved. `ready-controls01` supplied numeric
emitter FIDs to the original verifier, which instead requires a metadata
registry carrying arity/incoming counts. V2 uses the unchanged
`p111v_functions` and `p111v_segments`, separately from emitter IDs, and exposes
the original diagnostic. No verifier condition was weakened. `ready-controls02`
passed the data checks but failed linking because emitted inline descriptor
loads referenced `p111_program`; observer V2 exports that exact immutable
descriptor and activates the runtime with its address. Neither correction
changes the arithmetic, full-state, stack, dispatcher-count or return-status
oracle. Original failed files and reports remain intact.

The driver retains the established checked-B1 authority, exact fixture
membership, pinned tools/runtime, fresh output root, CPU3 and whole-run
deadline checks. It exports no new public production compiler path. Its
required API exports are `p193rf_controls`, `p193rf_validate`, the four
`p193rf_emit_{plain,fusion,tail,both}` functions, and
`x188_many`, `x188_render`, `x188_assemble`.

## Scope and remaining limits

The adapter preserves the original planner eligibility and bounded fusion
contract; it introduces no new recursion recognizer, callable-registry
extension, ownership helper, or runtime frame representation. Its scalar
consumer preserves ordered effects and public return semantics. Legality
continues to depend on original verified input, coherent immutable ready and
availability registries, admitted helper ABIs, and the existing runtime's
fail-stop semantics. Availability validates the actual emitted provider
boundary; it is not inferred from a symbol's spelling.

The new machine controls exercise two arguments, one capture, one eliminated
frame, a mutable capture preparation gap, swapped arguments, full-width wrap,
and a pending outer continuation. They do not exhaust all arities, nested
fusion sites, branching continuation shapes, ownership-heavy payloads, deep
ready-helper graphs, or every selector refusal. Complete-direct/mode/H
precedence and whole-candidate fallback were source-audited; this particular
runtime fixture calls the planning/emission interfaces directly and does not
by itself cover every public selection branch. Existing qualified planner
contracts support the design but are not replaced by these finite tests.

At this audit cutoff, native N1 acquisition, standalone maintained-source
checking, broader conformance, self-reproduction and compiler-cost gates are
separate root-owned work. The finite gate establishes no runtime speedup,
cold-build improvement, general stack theorem, or promotion decision.
