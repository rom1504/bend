# Phase124 ready helper → local resume prototype

Status: source-only prototype; no checked API, compiler, generated target, or
benchmark was executed by the author. Root owns execution and qualification.
`manifest.json` records the immutable parent, overrides, and module hashes.

## What changes and why

The actual Phase123 RLE `expand` graph captures the remaining input, calls
`$direct.lrepeat`, then resumes into own recursion and a terminal
`$direct.lconcat`. The existing H table planner permits a frame only immediately
before descent into the owner. Both helpers exist as complete P113D workers, not
as the P112 worker symbols accepted by the old planner. Merely accepting the
non-self call without distinguishing those registries would reference missing
symbols and would still fail at the terminal concat.

The new internal `P124Callable` resolves one exact U64-Term result ABI from an
immutable view of the *existing* P112 ready and verified P113 signature indices.
P113 requires public=true, result=1, and at most eight arguments; otherwise an
independently present P112 worker may qualify. Actual argument count and exact
scratch-store/jump/return shape are independently checked by the old tail parser.
The two registries retain their distinct emitted symbols. No new full catalogue
scan, merge, analysis cache, or source-name selection is added.

`P114RResumeReady{frame,call,result}` is an explicit derived operation. Its
construction preserves the original capture stores and frame push, then preserves
every argument-prefix operation/store in order, snapshots all arguments, calls
the verified private worker, and resumes through the existing table unwind. The
new terminal-call support is only active inside this extended H attempt; it does
not globally enable the historical complete-bridge path.

## Soundness boundaries

* Original P111 graph and complete P113 function verification are unchanged.
  `p113e_function` verifies public signatures against original arity/result/flags;
  `p113e_functions` admits calls only to earlier verified functions. Own recursion
  is `Again`. `p113e_base_stmt` rejects scheduler/state/terminal operations inside
  private bodies. P112 ready membership is likewise the existing closed worker
  certificate. A new helper therefore cannot call back into an unadmitted owner
  or read the generic register bank to recover arguments.
* The callable view is pass context, not a new independently verifiable proof.
  It must be built from the exact catalogues already checked for the program
  being emitted. Fabricated registry rows in finite controls are pure predicate
  inputs only. They must not be used to bypass production verification.
* Capture stores and `p111_rt_frame` execute first, exactly once. Depth increases
  once. Argument preparation follows in its original order. Full-width snapshots
  precede the helper call, and scratch words are transport copies, not extra
  owning roots. The helper's private scratch is a distinct stack allocation.
* The result is one owned Term, placed in `%p114r_value`; unchanged unwind pops
  the frame/FID/captures and dispatches the original continuation. No release,
  seal, copy, ownership-count operation, or runtime ABI is added/removed.
* Generic register-bank writes of the replaced jump/return are omitted under the
  existing worker/continuation non-observation contract. Other effects remain in
  order. Unknown calls, mismatched arity, unavailable workers, unsupported state
  access, unclosed continuations and namespaces still refuse to the old path.
* Own recursive descent remains the existing explicit stack loop. A helper has a
  closed, acyclic inter-function call graph with own tail loops, so input depth
  does not create owner→helper→owner native-stack recursion. Mutual/unresolved
  recursive helper graphs remain unsupported.
* Exact old continuation closure limits remain: at most eight cases, matching
  capture counts, the original clean-name/body gates, and original case parsing.
  Owner gate remains 1–8 arguments, one result, no incoming continuation or flags,
  and at most 512 original statements. No new unbounded whole-catalogue recursion
  is introduced: emission uses a direct-tail list accumulator.

## Complete consumer / fallback audit

The source contains three exhaustive consumers of `P114RStmt`:

1. `p114h_rename_stmt` now renames frame, call, and result with the existing
   per-case renamer. `state` remains special; scratch and all generated locals
   use the case namespace. Generated call names already use the reserved
   `p114h_` prefix rejected in original bodies.
2. `p114h_stmt` emits the new operation using unchanged frame/unwind machinery.
3. Old `p114r_stmt` explicitly rejects the new operation outside a table region.
   It is never quietly emitted by older R/G machinery.

The Boolean diamond recognizer has a wildcard refusal and cannot mistake this
node for a scalar diamond. List traversals and case wrappers delegate through the
three consumers above. New call-node rendering uses the existing N111 renderer;
there is no generated source-string parsing.

Public selection preserves original direct → H → R → G successes and their
exact plans. Only after they fail does it attempt extended H. Its failure uses
the same legacy fusion/public fallback. The old sequence redundantly retried
identical H after G; this prototype substitutes extended H at that last attempt.
Thus there is not a new unconditional whole-program analysis pass, though
additional per-site callable lookup/scan cost must be measured.

## Controls and decisive qualification

`controls.bend` exports `p124c_controls`, seventeen literal PASS/FAIL rows:
complete/legacy admission, old-registry refusal, missing/private/multi-result/
wrong/over-limit arity, exact distinct symbols and precedence, original self
recursion, unknown-call refusal, scalar prefix, scratch refusal, and renaming of
all new fields. These are pure model checks, not fabricated native executions.
The independent ordinary list/tree controls are in Phase124 `controls/` and keep
externally observed aliases. Root should additionally require:

1. Checked Bend export and all original graph/private verifier gates.
2. Actual RLE owner selection with correct private helper symbols, plus changed
   instructions/frame flow inspected in emitted QBE. Static selection alone is
   not a speed or correctness claim.
3. Parent/upstream differential ordinary RLE/list/tree outputs, retained aliases,
   and safe deep recursion; observe fallback on unrelated unsupported programs.
4. Paired compiler cost early, then selected generated-runtime samples and only
   after a useful gain the broad frozen correctness/performance set.

No performance prediction is claimed. The expected removed category is scheduler
round-trips for known helper calls inside an already explicit recursive region;
allocation, ownership work and semantic helper execution remain.
