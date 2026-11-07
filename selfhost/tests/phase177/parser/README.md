# Phase177 parser candidate: one owner for freshening

This is an unexecuted source overlay, not a selected compiler change. Only
`f_fresh_stack` changes. `p177ff_entry`, `p177ff_tag`, and `p177ff_loop` are new.
The existing `FFFrame` representation, reconstruction functions, declaration
freshening order and old mutually recursive implementations remain unchanged.

Freshening walks the complete newly parsed suffix after pattern elaboration.
The maintained implementation already has explicit heap frames, but its work
passes through `ffw_walk`, `ffw_walk_existing`, `ffw_done`, `ffw_frame`,
`ffw_kids`, `ffw_let`, and `ffw_let_tail`. Phase176's pattern experiment showed
that a single recursive owner can cross an admission boundary that equivalent
mutually recursive frames fail to cross. This candidate tests that execution
boundary on freshening, not another deferred pattern substitution.

A read-only census of Phase175 `full-native-n1/program.ssa` finds no `p113d`
worker for those seven functions or `f_fresh_stack`. The dependencies
`f_rename_var`, `p98_tag_eq`, `ffw_reverse_onto`, and `k_with_children` already
have private workers. Candidate admission must still be inspected: the richer
`FFFrame` sum could fail where Phase176's single constructor frame succeeded.
Do not infer admission from source-level tail calls.

The retained Phase171 capture summarized by `experiments/phase175/profile.json`
has 15 `ffw_walk_existing` contexts among 921 parse/load samples, versus 39 for
`f_grow_base`; 493 contexts are unknown. The parse/load interval is 29.545
diagnostic CPU seconds. Earlier Phase162 evidence had 23/920 freshener contexts.
These observations select executed work but do not measure inclusive freshening
cost, and do not establish a larger ceiling than the already selected lookahead
improvement. Current Phase176 full parse/load is approximately 22.6 seconds:
even elimination of all parsing would not by itself achieve the full-build
100-second ambition.

## Semantics and controls

The state machine retains exact preorder binder allocation, including U32
wrapping; domains use the outside environment; dependent bodies use the newly
bound variable. Let values all use the outside environment, while the body uses
the accumulated binding environment. `FName` resets the selected child's span;
`FGlobal` creates the same `Ref`; `FUnboundVar` returns untouched. Variable map
selection remains first-hit and retains the existing reference/span rules.
All/Lambda/Bind rebuilding deliberately drops their old removed-name lists,
whereas generic children rebuilding retains them. Lambda quantity-presence and
all literal fields survive. Malformed terms keep the same default child and
empty-let behavior. These are preservation arguments, not proof results.

`fresh-controls.bend` has 17 complete terms, six environments and four initial
IDs. `fresh-controls.mjs` performs 419 complete observations, including a literal
expectation for dependent binders and simultaneous let scope, nested declaration
allocation, input aliases, empty/malformed nodes, first-hit map order and ID
overflow. It checks every returned field; no digest supplies the complete-value
oracle. No passing result is claimed until root executes it.

Use the same independently checked exports for baseline and candidate:

```text
f_fresh_term
f_fresh_defs
p177fc_cases
p177fc_envs
p177fc_book
p177fc_actual
p177fc_expected
```

Prepare through `selfhost/tests/phase176/prepare.py`, which pins the current
Phase175 maintained source. Baseline includes only `fresh-controls.bend`.
Candidate additionally supplies `--prelude fresh-single-prelude.bend`,
`--module fresh-single.bend`, and `--replace f_fresh_stack`; paths here are
relative to this directory. Acquire checked hosted APIs using the normal
`selfhost/tools/build/hosted.mjs acquire` contract. Then invoke this directory's
`fresh-controls.mjs --baseline BASELINE_REPORT --candidate CANDIDATE_REPORT
--out FRESH_BUILD_OUTPUT` under the root-owned guard.

`fresh-native.bend` supplies a separate full-workload test, using
`phase175/frontend-digest.bend`. Prepare hosted exports with `p177fn_run`, or
native source with `--native-main`. Its `main` prints the same U32 result.
Independently checked baseline/candidate `p177fn_run()` must agree before native
measurement. It constructs mixed binders, parallel lets, generic constructors
and literals; consumes all fields of both freshened output and retained input;
and includes normal destruction. No expected hash is invented here.

Stop before native acquisition if the checked controls fail. Stop before a
real frontend acquisition if the loop does not obtain a private worker, or the
complete workload is neutral. A survivor needs the existing complete real
parse/load comparison, including full frozen input and exact parser values.
Do not obtain a full compiler image solely from this small workload. No native
stack-safety claim follows from a hosted complete-value comparison.
