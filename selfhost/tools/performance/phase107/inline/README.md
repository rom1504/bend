# Bounded scalar inlining in Bend

`nx_inline(program, budget)` transforms the unchanged Phase106 `NxProgram`.
The implementation and producer are Bend. Python here is independent evaluation
tooling; it is not loaded by emitted programs or the compiler.

Concatenate Phase106 `ir/{model,optimize,verify,json,c,workloads}.bend` and
`laws/bridge.bend`, then this directory's
`{model,admit,rename,expand,deep,tail,fixtures,main}.bend`, with one `import Base`.
Do not include Phase106 `main.bend` or this directory's `laws.bend`.
The optional standalone producer accepts:

```
inline-producer [deep-|tail-]json|c|stats WORKLOAD BUDGET
```

Root schedules checked producer acquisition and backend jobs under the common
resource guard. No production compiler/release files change.

The first subset admits direct U32/U64 helpers with scalar assignments and
return-free conditionals followed by a terminal return or terminal `if` tree.
This includes the checked frontend's branch-to-merge-local shape. Callee arguments are snapshotted once
in source order. Callee locals receive typed zero at every inlined invocation,
including calls inside caller loops. Names are fresh across caller parameters,
existing locals and previously expanded calls. Terminal returns assign a fresh
result, after which the original assignment/return continues. Original function
definitions remain. Direct nested helper graphs must be acyclic.

Memory, pointers, allocation, indirect calls, loops inside callees, early returns
followed by statements, invalid input and unresolved calls are refused. Unsupported
call sites remain unchanged; eligible sites elsewhere can still transform.
Recursion rejection is based on the original call graph, not guessed purity.

Bounds are 16 parameters, 32 locals, 256 body nodes and four direct-call sites per
callee; call graph/expansion depth four; 64 fresh-prefix attempts; global growth
budget clamped to4096. Zero budget returns the original program. Nodes count one
per program/function/parameter/local/statement/expression, excluding name/type
metadata and list cells. An expansion charges `3 + 2*p + 3*l + body_nodes`;
its exact growth before nested expansion is `1 + 2*p + 3*l + body_nodes`.
Nested expansions pay separately. The driver verifies the resulting IR and growth
bound before emitting. Huge ASTs overflowing U32 counters are outside this bounded
prototype's input contract.

`nx_inline_deep` separates original-graph analysis from expansion. It computes
shallow function facts once, then depth-first acyclic purity summaries with a gray
path and completed-result cache. At most256 functions and256 dependency depth are
admitted. Unknown references, cycles or limits refuse; the same four-level
expansion and4096 global growth limits remain. A certificate of eligible function
names feeds the common expander. The original `nx_inline` uses its original
four-level recursive admission instead. This does not guess purity from expanded
bodies, and does not duplicate the transformation engine. The128-function `many`
chain is a useful distinction between these analysis policies; it is not a promise
to eliminate all128 call boundaries under the fixed expansion/growth budget.

`nx_tail(program)` recognizes self-tail recurrence through terminal assignments
and merge-local conditionals. It snapshots every new argument, resets original
locals, updates parameters, and repeats a `while(1)` body. Ordinary returns still
exit the function; a typed-zero return after the infinite loop satisfies the
existing structural verifier and is unreachable. Pointer frames, existing loops,
non-tail self calls, mutual-only recursion and mixed early-return/dead-continuation
shapes remain unchanged. Bounds are256 functions,512 original body nodes,2048
normalized nodes,4096 rewritten body nodes, and4096 whole-program AST growth.
`tail-` CLI modes ignore the supplied numeric budget and use these fixed caps.

`tail-controls.json` includes finite differential inputs and separately labeled
million-iteration native-only checks. Do not run the recursive Python reference
at million depth. `audit_tail` compares small before/after results independently
and asserts exact refusal or actual self-call removal as applicable.

`controls.json` freezes input/results before execution. `controls.py` imports the
independent Phase106 interpreter and checks whole-function retention, fresh names,
exact growth, refusal identity and finite semantics. `audit_pair` is reusable by
the parent campaign. `negative_controls` applies three well-typed output mutants
to check sensitivity to local reset, argument binding and caller continuation.
This is emitted-IR mutation checking, not a claim that the Bend inliner passed a
source-mutation campaign. Never execute the intentionally recursive `cycle` case.

```
python3 -B controls.py pair reset baseline.json inlined.json 4096
python3 -B controls.py prepare-laws NEW_OUTPUT_DIRECTORY
```

The two laws constrain the exact safe continuation helper extracted verbatim from
`expand.bend`. They say nothing about whole-pass semantics, renaming, admission,
memory or backend correctness. Preparation binds the extraction and law bytes;
checking is a separately scheduled job. See the phase report for actual results.
