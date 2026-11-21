# Native checked-term static-spine unfolding

The sections below describe successive design and validation steps. The selected native variant uses stage 1 with typed residual lets and the zero-repeat guard. Exact source, real admission decisions, held-out results and full-catalog timings are recorded in the [Phase205 report](../../../implementation/phase205/README.md).

`unfold.bend` contains the compiler transformation. Python only transports source
and audits an independent captured AST; it does not transform user programs.
`p205u_attempt(book,input)` returns a residual KTerm or Absent. `prepare.py` installs
it as an optional fallback after the existing text law, preserving the parent
verdict and recheck paths. Both text02 and text03 parents apply offline. `--off`
returns the parent source byte-for-byte.

The accepted worker is an ordinary safe checked definition with at most5 supplied
parameters, optionally leading dynamic lambdas, followed by exhaustive SNil/SCon
matching (optionally unpacking Chr). The cons branch contains exactly one self
reference, called at full arity with the original tail in the String position.
The tail occurs exactly once; the empty branch contains no self-reference. The
known argument must be a String literal or a nullary safe definition whose whole
body is that literal. No source function names or template contents are selected.
Builtin String/Char/U32 identities must have native declarations in the context.
Erased/bang applications and unsafe/foreign worker declarations remain untouched.

Residual semantics: literal pattern selection and literal beta substitution are
performed; unknown calls, arithmetic, branch helpers and dynamic values are never
evaluated. Dynamic arguments retain their original argument position and become
ordered lets. The repaired binder requests reusable quantity2, subject to the
ordinary checker proving its inferred/annotated domain is Data; the expression
is still evaluated once. A let wraps the corresponding
residual body rather than being floated out of another call's arguments. Thus
seed evaluation, repeated updates, division/traps, nontermination and IO-producing
computations remain where the original evaluation requires them. Nothing proves
unknown calls total or discards them. Each worker copy uses f_fresh_term, from the
cached full-context binder bound;65536 IDs are reserved, exceeding65×512 possible
copy binders. Final kernel rechecking is mandatory and declines the whole edit
on failure. This is not a generic compiler correctness proof.

The original semantic input is capped at2048 nodes before cleaning. Var shadows
and checked annotation types are excluded from that semantic walk. A cheap literal
existence scan precedes cleaning/evaluation. Nullary references are inspected only
for an exact literal body. Worker bodies are capped at512 nodes before copying;
only potentially static calls inspect their shape. The evaluator has a256-depth
limit,64-character string bound,65 selected-step bound and8192 residual-node cap.
Bound failure produces Absent. The unaffected-path cost is bounded by these
limits, but has not been timed. Book-bound fallback may scan a context without
its ordinary cached stamp; production checked contexts should retain the stamp.

## Existing evidence and immediate gates

`shape-audit.json` binds the original independent checked AST capture. Its
`line` calls a three-argument String worker with a nullary literal definition.
The worker has one tail call and one tail use; the literal has39 characters,
predicting40 constructor selections including the terminator. This is a shape
witness, not proof that the Bend evaluator has executed or that native machine
code improved. Packet/counter transfer should exercise a leading dynamic state
parameter and a Unicode literal; the existing source is
`research/phase205/unfold/packet.bend`. No packet checked capture was used here.

Prepare a fresh source:

```
python3 -B research/phase205/native-unfold/prepare.py \
  --source selfhost/build/phase205/text03/compiler.bend --out FRESH
```

Acquire the normal checked API with `p205u_attempt`, `p205u_shape`, and existing
production roots exported. First inspect the actual line/packet.apply edits via
the production p205_update path and require successful live kernel recheck.
Require no remaining recursive producer call in the edited line and unchanged
unknown gen.at/salt/seed calls. Then emit unchanged original lexer and packet
sources, compare complete outputs on alternate inputs, and inspect real machine
activation before timing. Negative controls: nonliteral spine; recursive argument
not the original tail; two recursive references; tail used elsewhere; wrong
constructors or missing fallback; effectful nullary producer; unsafe/bang worker;
65+ characters; fresh-ID near overflow. Each refusal must return Absent and leave
the original definition untouched.

Stage2 (not implemented): folding pure helper branches on static character codes
may remove slot/classifier work. Keeping it separate makes stage1 a meaningful
ablation. Stage1 intentionally retains all such calls and does not claim the
source prototype's larger work-elimination ceiling.

No compiler, API acquisition, target execution or benchmark was run here. No
maintained compiler or parent hook files were modified; no commit was made.

## Subsequent ownership and request-scope fixes

All PE helper parameters are explicitly shareable; an initial combined source
check diagnosed p205u_clean's repeated plain parameter. The fixed stage1 source
subsequently passed the coordinator's checked API gate (coordinator owns receipt).
The latest hook uses request.bend and a Bool alongside the edit map/list: only
one successful rechecked unfolding may occur per request. Failed attempts keep
the slot available, and text-law edits do not consume it. This prevents two
independent owners allocating the same fresh ID region. `two-owners.bend` has
independent complete result1372 and requires exactly one of first/second to change
under the actual request traversal; the other stays original. Inspection exports
are p205u_pick/p205u_decls (new edit-map parent) or p205u_list (old list parent).
The original p205_update/p205_tail now stay unchanged.

## Optional stage2

`prepare.py --scalar` composes scalar.bend after stage1. It first optimizes children
in their original argument positions. It can inline a safe ordinary nonrecursive
helper only with a static argument, ≤5 full arguments, ≤128 semantic body nodes,
a monomorphic ADT result, and a restricted first-order syntax. Foreign, bang,
erased, unsafe, effect/type/control syntax and recursive helpers are not executed.
Unknown values remain ordered lets; static lets can be substituted. A selected
constructor match transfers fields in order into its original binder telescope;
unknown matches remain residual applications.

Constant folding recognizes only the existing authenticated native-call mapping
and the qualified U32/Bool builtin-book contract. Its whitelist is total U32
add/sub/mul/and/or/xor and six comparisons, all with two literal operands. No
native division, shifts, floating arithmetic, host calls or IO are evaluated.
An arbitrary function spelling cannot acquire primitive semantics. This is a
structural helper specialization, not a classifier-name or template whitelist.

Stage2 has192 depth,512 inline/fold steps,128 nodes per helper and16384 final
nodes. A131072-or-larger fresh-ID reserve covers512×128 binders above both context
and stage1 residual bounds. Any failed bound restores the complete stage1 term.
Stage2 runs only within the one fresh-owning edit selected by the request hook.
It is separately selectable and was not checked or run by this agent.

## Actual checker failure and repaired binder

The first real lexer product was byte-identical because the live checker refused
the proposal. `selfhost/build/phase201/p205decisions01/results.json` records
line: "let binder consumed more than allowed", packet.apply: "cannot infer:
annotation required". The earlier closure-factory instrumentation was not an
admission result. Saved lexer AST has79 generated bindings, with seed/index
quantity1 bindings used twice.18 packet binding RHS values are nested Lets whose
final applications return U32 (add/xor).

The coordinator ran repair-probe.mjs against the unchanged real Bend checker:
quantity2 alone admitted lexer; typed RHS alone admitted packet; the combination
admitted both. The native repair embeds typed-bind.bend helpers in unfold.bend.
It annotates only closed monomorphic ADT result domains recoverable from actual
callee types/literals, including nested-Let terminal expressions. Unknown,
dependent and function domains are not guessed. Every generated reusable binder
still requires the live Data-kind and use check. No existing binder is widened,
no checker is patched, and no dynamic callee argument is duplicated or dropped.
`qdem(2,d)=d` in the existing checker confirms the RHS is evaluated once.
The scalar caller uses the same repaired binder. Alias forwarding is deferred.

Actual decision05 admitted packet but refused the scalar lexer proposal with
"cannot infer: annotation required". Its saved residual has 28 unannotated
`rest` binding RHS Lets. A deeper walk shows these Lets terminate in SCon/SNil: the original recovery
incorrectly used the definition lookup for constructors, which live in ADT
child tables. The repair uses the existing cached j_find_ctor lookup and
preserves an authenticated closed callee result domain around an inlined Let.
This is provisional until the next real checker gate.

Mandatory fallback now computes stage one once, checks the scalar proposal, and
on rejection checks the retained stage-one proposal. Only an accepted proposal
consumes the request's one-unfold slot. Both checks use the unchanged checker.
Offline assembly of both text parents in both stage modes is pinned in
repair05-preparation.json; it is not a source-check or execution result.
