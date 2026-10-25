# Proofs that enable less compilation

Primary-source review,2026-10-25. This is research, not a new checked theorem or
a change to the compiler's trust boundary. The selected compiler remains Phase137.

## What the announcements establish

Anthropic's [October22 announcement](https://www.anthropic.com/research/formal-verification)
reports239 entrypoints across123 libraries, with180million lines of Rocq proofs.
The claims concern specified behavior of compiled binaries under bounded inputs
and modeled single-threaded RISC-V/Linux execution. This is not complete library
correctness. Proof production can consume hundreds of millions of tokens; a
smaller study found17% token savings from sharing proofs. The useful lesson for
us is reusable lemmas plus an independent checker, not cheap automatic proof of
our entire compiler.

The [public artifacts](https://github.com/theorem-labs/oss-verify-proofs) provide
proofs, pinned semantics and reproduction instructions. Their
[semantics document](https://github.com/theorem-labs/oss-verify-proofs/blob/main/docs/semantics.md)
describes a partial Linux model with explicit assumptions. Our native x86/QBE
chain is outside that model. We inspected the publications; we did not reproduce
these proofs or install their environment.

We could not verify a matching OpenAI software-proof announcement during
October18–25 in official research/engineering indexes and targeted searches.
The [October19 publication](https://openai.com/index/low-resource-programming-languages/)
concerns coding in low-resource languages and behavior-preserving migration,
evaluated with tests. The [October6 mathematics release](https://openai.com/index/sharing-ai-progress-in-mathematics/)
includes Lean formalizations of many results. These are different claims; neither
should silently stand in for the announcement the user may have meant.

The established complementary approach is translation validation: check a
particular transformation's result, rather than prove an entire optimizer.
[Alive2](https://github.com/AliveToolkit/alive2) implements LLVM refinement checking
and explicitly does not support interprocedural transformations. Its methodology
is relevant, but it is not a verifier for Bend's ownership, continuations or QBE.
Changing backend just to use it is not justified by this investigation.

## Our most valuable proof target is permission to skip unchanged work

Proposal: a retained compilation result may be reused only if all inputs that
determine it are unchanged. The general statement is simple; establishing the
complete dependency set is the hard part. It includes reducible bodies, negative
lookups, shadowing/order, ownership/layout, specialization, fresh identities,
helper admission and compiler/runtime policy—not just exported type strings.

A precise first experiment is a checker checkpoint, not a universal query engine.
For one same-header body edit, retain the exact checker world and seen-event
state before the edited event. The unchanged prefix must have identical semantic
inputs, including global declaration headers and later-fill metadata. Replay the
suffix and compare the complete result and diagnostic order with a fresh run.

The smallest useful law is a source-connected sequential replay/composition law:

```text
run(initial, prefix ++ suffix)
  = resume(checkpoint(initial, prefix), suffix)
```

Here errors, publication, specialization memo, fresh state and diagnostics are
part of the state/result. The theorem must use the real transition wrapper or
have an explicit checked bridge. A generic fold lemma alone does not prove that
the production checkpoint captured all state. Equality of header environments
and prefix inputs is a precondition; accepting it from an incomplete cache key
would remain a bug. Exact identity comparisons or authenticated immutable data
must establish those conditions; a hash receipt is not itself a mathematical proof.

This does not require proving that the original checker is semantically correct:
the narrow claim is that reuse preserves its fresh behavior. It also does not
prove backend correctness, memory ownership or native execution. Existing
independent source, ownership, output and integration checks remain separate.

Next prove exact first-match lookup/index equivalence, including misses and
shadowing. This enables an immediate cold-speed experiment and supplies a useful
semantic summary for future incremental queries. Only later expand to a
dependency-frame theorem: changing facts that a closed unit cannot observe does
not change its result. Prove dependency completeness for one query family at a
time; unknown dependencies force recomputation.

## How this could save time

Proof search belongs to implementation/qualification and is amortized across
builds. Routine builds evaluate cheap admission conditions and reuse authenticated
unchanged results. Reusing a previously checked proof is useful only when its
statement, dependencies and checker/kernel identity are valid in the new build.
Do not launch expensive proof search on every edit.

We should measure four separate costs: developing the theorem; independently
checking it; deciding whether its premises hold on an edit; and avoided compiler
work. The project has already demonstrated that many cache hits can save no
complete-request time. The same warning applies to many proved lemmas.

Tests should deliberately change a reducible body without changing its type,
introduce a formerly absent name, change declaration precedence, alter a law fill,
change a constructor's ownership, and change producer/runtime identities. Also
test valid edits, failure recovery and repeated edits. A stale artifact must be
rejected even if its structural IR verifier still accepts it.

Freeze the specification, oracles and checker while an agent proposes a faster
implementation. Do not let an agent make the theorem easier by weakening the
required compiler behavior. Preserve rejected attempts and charge their cost.

## Recommendation

Combine a narrow Bend/BendTT-checked reuse law with a measured early checkpoint
experiment. Keep full compiler correctness as a long-term objective, not the next
build-speed task. The hypothesis is that proofs let us avoid work confidently;
proofs do not make the current repeated computations execute17times faster.
