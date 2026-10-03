# Phase41: faster generated programs and shorter validation

Authorized 2026-10-03. Campaign starts 16:39:33 UTC, from commit
`8582de71687b95f7a87c4c17f74e04b76bd7582c` and installed Phase40 checked06.
The upstream pin remains `018751270e800bc222a93dad7f257083ee53a5f7`.
The user explicitly prioritizes elapsed time and authorizes the proposed mixed
agent workflow, bounded optimization experiments, design/report and publication.
No persistent Goal is created; the obsolete September23 goal has been deleted.

## Objective and baseline

Improve execution of compiler-produced JavaScript while preserving complete
values, demand/error order, aliases, host mutation/reentry and stack behavior.
Keep compiler cost and source complexity explicit. Phase40's direct-unfused
lists and recursive tree workers are the baseline, with the pinned TypeScript
outputs as a separate reference. The catalog stays 45 points / 23 sources.
Baseline artifacts are checked before any experiment; old timing medians never
serve as a new experiment's denominator.

Phase40 consumed about 133 minutes through its final commit, including about
70 minutes of recovered process intervals. Those intervals are not idle time.
This campaign targets 2–4 minute edit-to-screen iterations and approximately
75–100 minutes for comparable completed work, not a guarantee or permission to
waive validation. Review the schedule after 20 minutes and every decisive result.

## Team and ownership

Root owns production integration, the resource queue, promotion and publication.
Three Sol6.1/medium owners investigate tree, lexer and lists in isolated files;
a Sol6.1/medium owner improves validation and a separate reviewer challenges
survivors. Luna owners extract existing profiles/research and maintain accounting.
Eight concurrent subagents are available, but slots are used only for concrete
independent deliverables; completed mechanical owners are reassigned or stopped.
Each receives compact source/evidence pointers and a bounded task.

Agents do not simultaneously edit the production backend. They submit isolated
patches or saved-output prototypes, with static checks. Root runs compiler jobs
and all measurements. A manual JavaScript prototype is evidence of a mechanism,
not an installed compiler optimization.

## Prospective experiments

1. **Private transfer tuples.** Structural workers construct a nonescaping
   `$next` array, then copy its constant-index fields to state slots. Test scalar
   temporaries evaluated left-to-right before any state assignment. Retain all
   frame arrays and tagged intermediate data. Falsifiers include slot swaps,
   duplicate old-state reads, nested calls, throws, and variable capture. Stop
   if V8 already removes the cost or complete results/boundaries differ.
2. **Acyclic tree wrappers.** Investigate the self-reference gate that excludes
   a wrapper around an already proved recursive component. Reuse the existing
   full typed graph and dependency guard; do not globally admit arbitrary
   wrappers. Check host mutations, fallback entry, aliases, order and deep trees.
3. **Lexer feasibility.** Reconcile the prior manual ~2x prototype with actual
   String/Char/Sigma admission and native hook obligations. Integrate only if a
   narrow existing proof boundary suffices; otherwise retain the precise failed
   or deferred hypothesis instead of building broad infrastructure this round.
4. **Validation latency.** Derive a reviewed two-worker frontend gate preserving
   all 3,026 + 196 comparisons, observation semantics and health checks. Candidate
   worker-count assertions deliberately change to two; reference stays frozen.
   Add early actual-output compatibility checks from current reviewed owners.

The separate owner designs record concrete patches and falsifiers. Fusion is
not assumed necessary: allocation reductions are tested against the existing
direct-unfused pipeline first. Compiler-analysis cost is measured for survivors;
an emitted-program improvement does not imply a faster compiler.

## Experiment and resource policy

Start with static opportunity checks and small semantic falsifiers, then an
approximately20-second screen and60-second confirmation. Use complete outputs,
fresh matched roles, fixed input/warmup policy and retained unsuccessful samples.
Profiles and operation counts run separately from clean timings. Exact-byte
identity may justify retaining earlier evidence within the same frozen campaign;
changed programs need fresh comparison and unchanged controls remain visible.

Normal jobs use Node24.18, a1GiB heap, CPU3 and a2GiB process-tree RSS ceiling.
Correctness may use two workers on CPU3,4 only under an outer aggregate3GiB RSS
ceiling and2GiB free-memory floor; require at least5GiB available before starting.
No timing overlaps compiler/hash/archive/correctness jobs. Existing lock owners
are never nested. Every machine job records enclosing start/end timestamps and
its command, completion and resource receipt. Stage windows record observed wall
boundaries, not model compute or causal model-speed claims.

## Promotion and deliverables

Freeze a surviving source before broad timing and release validation. Verify
actual checked emission, affected semantic owners, expanded applications, exact
frontend/backend observations and ordinary/relocated CLI behavior. Reuse the
existing integration recipe and reviewed Phase40 successors; preserve original
failed reports. A performance regression triggers rejection or an explicit
corrective experiment, never a changed oracle. Full self-reproduction is not a
routine edit gate, and a checked B1 derivative is labeled accurately.

Commit/push this design before source integration. Preserve the103 unrelated
starting files and all closed Phase40 evidence. Reports go in
`implementation/phase41/`, hypotheses in `experiments/phase41/`, and new raw
attempts in `selfhost/build/phase41/`. Publish concise reusable run instructions,
update compiler documentation and README links, retain failures and one canonical
results table. Final reporting separates generated-program speed, compiler cost,
source complexity and elapsed campaign time. No PR comment is authorized.
