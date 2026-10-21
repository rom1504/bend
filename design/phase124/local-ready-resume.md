# Phase124: ready calls can return to an explicit local continuation

Start from the qualified experimental Phase123 source04 and its explicit amd64
assembler policy; keep native Phase118 and installed selections unchanged. The
user's reviewer ideas reinforce small measured transformations, mature C as an
oracle, positive log-slowdown, independent falsification and compiler-hot proxies.
This is one bounded capability experiment, not a universal IR or proxy framework.

## Hypothesis and measurable work

Actual RLE expansion saves a capture, calls an already complete list helper,
resumes a continuation, recursively descends and resumes again to concatenate.
The current local recursive planner only admits same-owner descent through saved
frames; a ready helper is allowed terminally. In addition, its P112 ready registry
does not describe those verified P113D complete helpers. Both barriers must be
addressed for this witness to become one stack-safe local computation.

The proposed extension keeps the exact original explicit frame/captures and call
arguments, directly calls an authenticated single-Term helper, then dispatches its
result to the existing local unwind table. It can remove scheduler round trips
and register-bank reloads; it does not claim to eliminate the output list or all
allocation. Use machine inspection and output checks to establish actual selection
and work removal. Historical terminal bridging alone gave only1.51% on four other
programs, so do not confuse that result with this capability.

## Small implementation boundary

- Build an immutable view over existing P112 readiness and verified public P113D
  signatures, preserving distinct callable symbols and exact arity/result contracts.
  No global catalogue cache, rescan or broadened interpretation of ready metadata.
- Add an explicit local call/resume terminal variant, with original frame statements,
  verified argument snapshots/direct call and result. Update rename/emitter cases
  and fail closed in unrelated legacy renderers. No fake marker or overloaded node.
- Preserve existing successful H/R/G choices. Try the extension only after the
  current choices fail and keep unknown/dynamic/cyclic/private-result fallbacks.
- Native call depth must stay independent of source recursion depth. Helpers cannot
  consume caller frames or reenter the unadmitted recursive owner. Existing local
  continuation capture/layout/table bounds and original verifier remain authoritative.
- Check compiler cost early: an additional admission attempt can be costly even if
  the new region is fast. Stage cheap gates; do not repeat broad analysis blindly.

## Falsification sequence

1. Prepare two independent ordinary-source controls with pure expected outputs:
   list/tree walkers calling heap-owning helpers before descent, retained external
   aliases, and ordinary bounded deep inputs. Check them on the existing parent
   first; parse failures are not evidence about the transformation.
2. Check the prototype Bend module. Pure plan controls test known ready/complete
   admission and wrong arity/result, private/unknown targets and nonlocal resume
   refusals. Inspect actual RLE selection and first failure before building it.
3. Run original RLE and controls on the candidate. Require semantic agreement,
   explicit stack structure and fewer generic transitions in selected machine code.
   An emitted worker or lower instruction count alone is insufficient.
4. Measure original RLE plus one unrelated relevant family and a compiler-hot
   extracted analogue if a faithful cheap witness exists. Reuse frozen upstream
   and mature-C products; do not fabricate a new upstream oracle for a changed
   computation. Separate source ceilings from automatic compiler gains.
5. Measure complete hosted request cost for affected and unaffected programs.
   Only an enabled, useful and affordable candidate merits another original45
   gate. Reuse Phase123 deficit metric: historical geomean, mean positive log
   slowdown, frozen families, fixed-batch sums, counts above1.1/2 and regressions.
   No native image acquisition until a separately justified integration checkpoint.

Root owns integration and one serial CPU3 guarded lane:2GiB RSS,16GiB available
floor, file/deadline limits and fresh outputs. Two existing agents perform disjoint
bounded source/control/audit work; no competing large implementations. Start with
~30min offline prototype/control work and a fast selection/output gate. If a
semantic obligation cannot be established or runtime/cost evidence is weak, retain
the negative result and stop rather than expand scope to make the benchmark pass.

## What to preserve

Legality comes from authenticated callee summaries, explicit ownership transfer,
frame/capture identity and closed call graphs. The new node should state those
semantics independently of final QBE spelling. The emitter and machine profitability
remain separate. This is a potential future shared abstraction only if it proves
useful now. No claim of recursive self-improvement follows from another commit;
compiler/optimizer cost and total experiment cost are separate measured outcomes.
