# Phase129: Bend2's capabilities, proof boundary, and optimization implications

Source and primary-literature audit, 2026-10-23. This investigation ran no
compiler, target program, Lean build, or benchmark. Statements marked
**observation** describe inspected source or retained evidence; **inference**
describes a consequence we should test; **proposal** is unimplemented work.
The aim is to exploit the language we have, without mistaking its metatheory
for a proof of our compiler or for a performance guarantee.

## Identity and what changed upstream

| Item | Identity used here |
| --- | --- |
| Fork at investigation | `a4ecad0e2e33944814fbad0b53705c2460e60f8a`, `selfhost/bootstrap` |
| Active language/conformance pin | `059266225b77c8ca256ac6b25ee5c21449bab151` |
| Upstream head independently queried by coordinator | `5150fe296f70a918026de20b808d24d2a521a7d7`, 2026-10-23 16:55:02 UTC |
| Local `bend2/bendtt.lean` | SHA256 `83cdd36e66dcd2cabcc3d10556c9c874f8d823956feab88f8bb5a81473d51be3`; Git blob `a0ee6d31138ed5c0866980b1d945c80c07296276` |
| Latest upstream Lean file, fetched at immutable head | Git blob `b533fbd209a601443b069f476baf4e388b49dc54` |
| Local `bend2/bend.ts` | SHA256 `1d133151652b597a1a035c77c172475e6de096da37f3b9e3adc23c2f75bdfe49` |
| Local `bend2/safe.ts` | SHA256 `bf495d64c03caa7a2558aaae5e172cd7743b9aa5470c4d33ad86634e23d81ffc` |

The local Lean kernel and TypeScript checker match the retained upstream pin.
They must not be described as the October23 upstream kernel. Fresh GitHub
reads found three later kernel changes:

- [October14 descent extension](https://github.com/bendlang/bend/commit/1b68fd881a372e7dff9fc27e5423405d87ffb8ab): the kernel checks descent against the column pattern, accepting a constructor rebuilt around a smaller input part, as the TypeScript checker already does.
- [October14 proof simplification](https://github.com/bendlang/bend/commit/edce2cd98d6f0ceec0e1a4bf682b31d202f515e5): proof simplification with the same claims.
- [October22 adequacy theorem](https://github.com/bendlang/bend/commit/b8664b0a7ff36858b353fdbee77e41a3dd3548db): a closed live proof of an equality in a checked book implies convertible endpoints. The commit adds 35 Lean lines and a paper theorem.

The last change matters: the latest source states and proves a direct semantic
consequence for equality laws, beyond the existing no-`Empty` consistency
result. Its [statement at lines1743–1748](https://github.com/bendlang/bend/blob/5150fe296f70a918026de20b808d24d2a521a7d7/bend2/bendtt.lean#L1743)
and [proof at line4009](https://github.com/bendlang/bend/blob/5150fe296f70a918026de20b808d24d2a521a7d7/bend2/bendtt.lean#L4009)
retain explicit checked-book, closedness, liveness and typing premises.
Conversion is in the declarative theory, where opaque definitions unfold to
their models. This does **not** prove equality of arbitrary foreign machine
implementations. No latest-kernel build or migration was attempted here.

## The important ideas in the language

### 1. Restrict duplicable computation, rather than the universe hierarchy

**Observation.** Bend2 has dependent types, `Type : Type`, impredicative
function types, and negative recursive datatypes. Its safety argument divides
terms into live and dead positions and disallows copying live function values.
`Data` can be reused; function types are `Type`, not `Data`. A reusable
datatype cannot contain a live function field. This is explicit in the
[checker theory comment, lines163–216](https://github.com/bendlang/bend/blob/059266225b77c8ca256ac6b25ee5c21449bab151/bend2/bend.ts#L163)
and [paper abstract and introduction](../../bend2/docs/BendTT/main.typ#L138).

This is a substantial design tradeoff, not an unrestricted replacement for
Lean. A runtime closure remains affine even when all its captures are data.
Many familiar higher-order interfaces therefore require specialization,
explicit state, or a different API. Negative datatypes do not license an
arbitrarily duplicable self-application combinator.

**Inference for optimization.** Closed, known computation is especially
valuable in this language. Preserve the distinction between reusable data,
affine closures, and known static callees through lowering. A representation
that turns all three into an undifferentiated tagged word loses facts the
language has already established. This supports existing QBE helper and
closure-fusion work; it does not by itself justify a new general IR.

### 2. Termination is about live evaluation, not every type computation

**Observation.** The pinned kernel proves live evaluation terminates from
`Book.Live`, closedness and `Term.Live`, without a typing premise
([Claim.halts, lines1686–1689](https://github.com/bendlang/bend/blob/059266225b77c8ca256ac6b25ee5c21449bab151/bend2/bendtt.lean#L1686)).
The proof combines affine evaluation with well-founded recursive calls.
Types, equality endpoints and erased arguments are checked dead; they need
not normalize. Recursive live calls follow a lexicographic descent check,
skipping erased columns. `@unsafe` opts out, permitting unrestricted recursion
and later definitions. See [guide, lines87–126](../../guide/GUIDE.md#L87) and
[term_descend, line3235](../../bend2/bend.ts#L3235).

The kernel's executable conversion check is fuelled (`FUEL`, line157;
`Term.conv`, line982). Sound acceptance is proved; completeness is not.
Failure can mean insufficient fuel or unsupported elaboration, not a proof
that the proposed mathematical law is false.

Termination supplies **no useful general time bound**. The paper explicitly
notes that Ackermann is admitted ([related work, line1110](../../bend2/docs/BendTT/main.typ#L1110)).
It also supplies no bound on generated native stack use: stack safety is an
implementation obligation, even for mathematically terminating recursion.

**Inference.** It is reasonable to move a hot, pure helper into the checked
fragment and prove it equivalent to a simple specification. It is not
reasonable to assume the entire unsafe compiler is covered, or that a checked
optimization search will finish within a research budget without a separate
budget argument.

### 3. Quantity checking is more subtle than ownership or reference counting

**Observation.** Quantities are erased, affine, and reusable. Sequential usage
adds with saturation; alternatives combine with maximum. The concrete
operations are `quant_add`, `quant_join`, and `quant_dem` at
[bend.ts595–619](../../bend2/bend.ts#L595). `Kind(&1)` is `Type` and
`Kind(&2)` is `Data`; quantity-polymorphic containers preserve the restriction
of their contents. Base's `List`, `Sigma`, and `Map` declarations demonstrate
this ([base.bend21–95](../../bend2/base.bend#L21)).

The less obvious rule is **certify once**: a plain data value may be passed to
a reusable binder, whose body may copy it. The argument's usage is counted
once, rather than scaled by unrestricted usage. The source comment expressly
identifies strict evaluation and compiler invariants needed for this design:
do not duplicate an unevaluated term; ownership-bearing resources are not
`Data`; the compiler may remove source copies but must not invent them
([bend.ts176–195](../../bend2/bend.ts#L176)).

Consequently, affine source use is not a proof that a heap node has reference
count one. `Data` can still be aliased. Nor does affine weakening make physical
destruction free: the language permits dropping a value, but reclaiming its
heap graph can cost time. A backend optimization needs the actual lifetime,
escape, child ownership, and sharing conditions. Eliminating a retain/release
pair and transferring an owned child are different operations.

**Inference.** Phase128's borrowed observations fit the language well: inspect
already-live data without manufacturing temporary ownership. Extend the
existing proven/admitted observer interface where profiling warrants it.
Do not infer all-heap uniqueness from a missing `+`, delete RC globally, or
duplicate arbitrary RHS expressions while inlining. Evaluation-once and
field escape controls should be part of the legality summary.

### 4. Templates make static computation reusable without copying closures

**Observation.** `~` arguments are closed syntax, specialized at compilation
time. Each distinct argument set gets an instance; runtime closure calls are
avoided. Open caller-local captures are rejected. Templates call only earlier
templates. Base uses this in `List.map` at line888 and folds at line1041.
See [guide257–277](../../guide/GUIDE.md#L257) and the
[checker explanation at3228](../../bend2/bend.ts#L3228).

**Inference.** There is a principled route to general producer/consumer and
known-call specialization already in the language. But specialization can
increase image size, checking work and backend work. More template instances
are not automatically an optimization. Preserve and reuse an existing
instance's checked facts, and measure the number of newly generated functions
as well as runtime. Any cache must identify the source, arguments, semantic
environment and relevant compiler policy, not merely the printed function name.

### 5. Laws can make local optimizations checkable, but specifications matter

**Observation.** Laws are types and proofs are ordinary definitions; equality
is intensional and rewriting uses explicit equality evidence. There is no
general tactic language in the guide. `--verdict` elaborates the checked
program into a separate Lean-implemented BendTT checker. Upstream's intended
workflow keeps human-owned statements in `LAWS.bend` and agent-written proofs
in `PROOF.bend` ([guide279–348](../../guide/GUIDE.md#L279)).

The strongest directly reusable pattern is already in the pinned kernel:
`subk_sub` and `@[csimp] sub_subz` prove the optimized executable substitution
equals its simple specification ([Lean435–441](../../bend2/bendtt.lean#L435)).
Similarly, `Book.ok` connects the actual index with its list, and `get_find`
proves full first-match payload equivalence, not merely membership
([Lean117](../../bend2/bendtt.lean#L117), [2391–2404](../../bend2/bendtt.lean#L2391)).
These are compiler optimization proofs, not just example outputs.

Our repository already has this direction: source-connected laws, finite
production contracts and deliberately failing mutations are catalogued in
[COMPILER_LAWS.md](../../docs/self_hosted/COMPILER_LAWS.md) and the
[Phase96 upstream proof audit](../phase96/upstream-proof-method.md).
Recommending that we simply “add laws” would overlook substantial existing work.
The missing work is usually a precise bridge from a new backend transformation
or unsafe production adapter to the property already proved.

## The guarantee boundary we must keep visible

| Layer | Established or checked | Not established by that fact |
| --- | --- | --- |
| Ordinary `bend.ts` checking | Executable type, quantity and descent checks | A verified implementation of that checker; no bugs in its parser/elaborator |
| BendTT `Book.check` | Acceptance implies declarative well-typedness and liveness; formal confluence, preservation, progress, live termination, consistency | Faithfulness of arbitrary source translation; native execution equivalence |
| Latest upstream adequacy | A closed live typed equality proof in an accepted book has convertible endpoints | Equality of opaque/foreign machine implementations with their models |
| `safe.ts` / `--verdict` | Independent second check of the emitted kernel book, with an empty out-of-scope list required | A proved translation from `.bend`; proving omitted bodies or the host FFI |
| Our helper laws | The stated source/model property, under its explicit assumptions and production bridge | Unstated memory safety, aliasing, diagnostics, errors, or whole-program preservation |
| Native qualification | Retained concrete correctness, self-reproduction, law/control and benchmark evidence | A universal theorem of compiler/runtime correctness |

The important concrete boundaries are in `safe.ts`: `item_emit` rejects unsafe
definitions (line351); `def_emit` emits a real body or an opaque model of a
bodyless declaration (line371); `model` constructs a typed witness (line464).
`safe_emit` can output the surviving subset while reporting exclusions;
`safe_check` requires **both** no excluded roots and kernel success
([lines1556–1567](../../bend2/safe.ts#L1556)). A successful subset is insufficient.
Inspect that the intended helper's actual body, not a model, is present.

Base contains bodyless native declarations such as `F32.add` with a function
type but no equation specifying IEEE behavior ([base.bend1636](../../bend2/base.bend#L1636)).
A type-correct model does not certify native rounding, NaNs or conversions.
The compiler's F32 optimizations therefore still need machine-semantic laws
and independent execution tests. Similar care applies to IO handles and host
implementations. “All proofs check” does not mean every desired property was
stated, nor that the complete executable chain is verified.

The earlier lexical audit found no local `sorry` or explicit `axiom`
declarations in the pinned Lean file, with partial definitions confined to
the parser. That is retained source evidence, not a new Lean run or an audit
of every imported axiom and toolchain component. The parser and `safe.ts`
translation remain outside the formal development's theorem boundary.

## What is distinctive, and what is established prior art

| Comparison | Distinction relevant to this project |
| --- | --- |
| Lean | Lean uses a hierarchy of universes and strict positivity for inductive definitions. Bend's live-affinity restriction permits a different combination of `Type : Type` and negative datatypes. Dependent types, proof erasure, checked kernels and theorem-guided optimization are not new by themselves. [Official universes reference](https://lean-lang.org/doc/reference/latest/The-Type-System/Universes/), [positivity reference](https://lean-lang.org/doc/reference/latest/The-Type-System/Inductive-Types/#strict-positivity). |
| Idris2/QTT | Idris2 has erased `0`, exactly-once `1`, and unrestricted multiplicities; its default unannotated argument is unrestricted. Bend uses at-most-once affinity, restricts reusable values to `Data`, and uses the certify-once promotion rule above. Do not conflate these quantity systems. [Official Idris2 tutorial source](https://github.com/idris-lang/Idris2/blob/main/docs/source/tutorial/multiplicities.rst). |
| Rust | Rust closure call traits and copying depend on captures and body behavior; closures can implement `Fn`, `FnMut`, `Copy`, or `Clone` when the corresponding conditions hold. Bend's live-function restriction is more global and supports its termination argument. Borrowing and ownership optimization themselves are established techniques. [Official closure reference](https://doc.rust-lang.org/reference/types/closure.html). |
| Bend1/HVM | This checkout's Bend2 is a new language/compiler with tagged terms, reference counts and a structured task runtime. Old interaction-net claims cannot be used as evidence for its current codegen or scaling. The maintainer explicitly identifies the rewrite and separate Bend1 history in [issue434](https://github.com/bendlang/bend/issues/434). |

The BendTT paper itself connects the design to contraction restrictions in
logic, QTT, graded types, Trellys, Cedille and structural termination
([related work1092–1145](../../bend2/docs/BendTT/main.typ#L1092)). This audit
does not establish a priority claim over that literature. The interesting
local combination is a small affine dependent language, a proved independent
kernel, and a self-hosted compiler whose transformations can be constrained
by source-level laws. The compiled implementation is still the hard bridge.

## Consequences for the next optimization cycle

1. **Preserve a small executable legality summary, not a proof-shaped label.**
   For the next hot observer or private computation, record which arguments
   are borrowed, which returned fields escape, which expressions evaluate
   once, and where ownership resumes. Reuse existing helper facts. Independent
   final verification and real aliases must remain part of the gate.
2. **Use law/specification bridges to remove algorithmic work.** An immutable
   name index should preserve the precise first-event/full-payload semantics
   of its lookup site. Repeated membership and resolution are different
   contracts. The Lean `Book.ok` construction is a concrete model; generic
   interning or an unqualified last-wins map is not an equivalent replacement.
3. **Separate information retention from profitability.** Quantity and
   known-call information can authorize transformations. They do not establish
   faster QBE output. Preserve fallback, run a bounded machine-code experiment,
   and include compilation cost and unrelated transfer workloads.
4. **Do not use termination or GPU availability as a cost argument.** The
   current language exposes balanced independent parallel calls; JavaScript
   executes them sequentially ([guide128–170](../../guide/GUIDE.md#L128)).
   Highly shared pointer walks still require analysis of ownership traffic,
   granularity and imbalance. CPU and GPU runtime behavior needs its own
   evidence. A compiler written in Bend is not automatically a good GPU job.

**Small falsifiable proposal, not performed here:** choose one measured hot
read-only walk which the present borrowed-helper interface refuses. Before
changing QBE emission, write its observation/lifetime contract and one
counterexample where a returned child survives the parent. Compare an exact
accepted summary against the current independently computed summary on a
frozen small corpus. Then promote only if the new case removes dynamic
ownership work, improves a second workload, and does not add comparable
analysis cost. This tests whether preserving semantic information is the
bottleneck, instead of assuming another optimization pass is necessary.

**Alternative low-cost proposal:** formalize the full first-match payload
property for one existing prepared lookup/index boundary, including duplicate
names with different definitions. Require byte-identical generated QBE for
the cleanup. This is closer to an already demonstrated upstream proof pattern
and may be cheaper than new representation machinery if refreshed profiles
show repeated lookup remains important.

No result here demonstrates recursive acceleration or a new speedup. The
research value is a sharper boundary: Bend provides unusually useful semantic
inputs and a credible proof path for small transformations, while native
correctness and profitability must still be connected to those inputs.
