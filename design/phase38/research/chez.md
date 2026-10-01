# Chez Scheme: direct calls and explicit pass invariants

Inspected 2026-10-01 at **v10.2.0**, commit
`fdf6b3f5d069bf53082bb827f46714f2de8f11f5`.
Chez is useful both as an optimizing compiler for first-class functions and
as a counterexample to equating fewer passes with lower conceptual complexity.

## Primary evidence

- [Implementation overview](https://github.com/cisco/ChezScheme/blob/fdf6b3f5d069bf53082bb827f46714f2de8f11f5/IMPLEMENTATION.md).
- [cpnanopass.ss](https://github.com/cisco/ChezScheme/blob/fdf6b3f5d069bf53082bb827f46714f2de8f11f5/s/cpnanopass.ss):
  `np-convert-closures` (1326), `np-optimize-direct-call` (1406),
  `np-identify-scc` (1465), `np-expand/optimize-closures` (2000).
- [np-languages.ss](https://github.com/cisco/ChezScheme/blob/fdf6b3f5d069bf53082bb827f46714f2de8f11f5/s/np-languages.ss)
  defines successive language forms.
- Keep, [A Nanopass Framework for Commercial Compiler Development](https://andykeep.com/pubs/dissertation.pdf),
  2013; [author's publication page](https://www.andykeep.com/).
  The old Indiana paper link now redirects to a department page; use the
  author's dissertation and current implementation, not that failed link.

Raw versioned sources were inspected; their hashes are in the
[external source manifest](../../../implementation/phase38/external-source-identities.json).
No Chez executable was built or timed.

The implementation uses successive IR contracts, generated traversal machinery
and explicit passes for closure conversion, direct-call optimization and SCC
identification. A pass can retain the same grammar while strengthening an
invariant: `np-identify-scc` makes recursive binding groups strongly connected.
The direct-call pass checks known procedure information and matching arity,
retaining generic calls when it cannot prove the target. Its variable-arity
case explicitly stages fixed arguments before constructing the rest list.

The dissertation motivates small passes whose input/output languages expose
what changed, with infrastructure handling unchanged syntax. That does not
mean porting a nanopass macro system into Bend will make our compiler smaller.
Infrastructure, generated code, debugging tools and pass boundaries all count.

## Connection to current Bend

We already have generic descriptors, private workers, Lam/Mat structure, proof
graphs and bounded analysis. Much of the complexity is the interaction among
those mechanisms. A new emitter must understand both ordinary source behavior
and a collection of local eligibility rules. Chez suggests making those rules
visible as contracts consumed by the next step.

A minimal component contract might establish:

```text
every edge is classified: known saturated / tail transfer / boundary
every live argument has an explicit representation and demand point
every private dependency belongs to the entry proof
every unsupported case has a named refusal, before emission
```

That is a proposal for our compiler, not a description of Chez's exact IR.
It can initially be a bounded analysis result over existing terms, rather than
a new AST and serializer. Unknown facts remain unknown; no default optimistic
classification is allowed.

## What direct-call recognition teaches

Known function identity is not enough. Arity, captured environment and how
arguments are evaluated matter. Our public under- and oversaturated calls
must retain their original semantics. A private saturated edge can bypass
wrappers only after those obligations are discharged by the component proof.

Preserving tail loops is also separate from discovering a recursive SCC.
An SCC can contain non-tail recursion. A loop of labels suffices for tail
edges; other edges need a stack strategy. Fresh capture bindings per iteration
must remain fresh. These distinctions should be reflected in data and checks,
not inferred repeatedly from emitted strings.

The direct tagged worker experiment is therefore more valuable than a new
general closure representation at this point. It keeps data identical while
testing whether calls and control flow explain the current gap.

## A simplification experiment without a rewrite

1. Inventory actual duplicate questions in `region`, `local`, `finite`, `tree`,
   `worker` and `jpure`: dependency discovery, live arity, purity, demand and
   constructor layout. Distinguish intentionally different questions.
2. Add temporary analysis counters in a successor experiment, not production.
   Compare visits/normalizations on tree and an unrelated small library.
3. Factor one repeatedly identical question behind one contract. Require
   identical emitted bytes and every owner control before changing admission.
4. Record deleted and added production lines, types, runtime protocols, analysis
   walks and refusal categories. Readability is not demonstrated by minification.
5. Only then let the summary admit a new direct component, in a separate change.

**Stop** if the proposed abstraction merely wraps different analyses in one
large record, increases traversals, or requires a new IR without deleting old
logic. The point is fewer independent proofs, not maximizing pass count.

## Estimates and risks

| Idea | Expected benefit | Cost and risk |
| --- | --- | --- |
| Shared component summary | No runtime gain from refactoring alone; target 0–6% recovery of selected compile-request cost | 1–3 days after counters; medium invalidation/admission risk |
| Delete duplicate admission/shape walks | Exploratory target 5–15% of the 4,345-line JS backend, only if actual redundancy is found | Roughly 217–652 lines; low confidence, not whole-compiler reduction |
| Direct saturated edges and tail components | Same 1.5–2.5× tree hypothesis as TS/MLton/GHC | Several-day implementation; medium/high correctness risk |
| Adopt a full nanopass framework | No quantified gain justified now | High context and infrastructure cost; defer |

The line target is a hypothesis to test by inventory, not evidence of removable
code. A 5–15% backend reduction is only about 1.2–3.6% of all production Bend
source. It does not support earlier aspirations for 50–75% overall reduction.
The speed estimates overlap other chapters' identical proposals.

## Conformance and review value

Pass contracts allow cheap checks such as “every private call is saturated,”
“every dependency is captured,” and “every loop transfer uses fresh old-value
temporaries.” These checks can shorten debugging and catch broad categories of
wrong code. They complement full-value, host mutation, alias and reentry tests.
They do not substitute for them or establish independent proof-kernel validity.

Retain the current fallback until all former admission owners have a clear
mapping to the replacement. Only after two independent components benefit
should a broader consolidation be promoted. Chez supplies a design discipline,
not an argument to discard a working compiler and start over.
