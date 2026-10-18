# Context-call diagnostic: source-only correctness review

The final source inspection is bound to
[context-source07](../../selfhost/build/phase110/context-source07/manifest.json),
SHA-256 `e5b84005fad7a10fb97d4fa42d6cc95d5134f7d5118087eb37bbf2e658c04eba`.
The source and every input pin matched at review. This restricted ABI
transformation revealed no concrete semantic defect. Source review alone does
not establish native qualification or a performance win. No compiler, proof or
runtime target was executed by this reviewer.

The `threaded` mode introduces private
`ctx110_name(ctx, ir_heap, ir_alc, owned_args...)` functions. The `context` mode
keeps only `ctx` and owned arguments, loading the two base pointers directly
from the validated context. Original exported names retain their original
signatures and obtain checked pointers once before calling a private entry.
Only calls to the authenticated closed worker catalogue are renamed; runtime
imports keep their original ABI. Self-tail loops retain their pointer bases.

## Lifetime and ownership premises

The [runtime adapter](../../selfhost/tools/performance/phase109/runtime/adapter.inc.c)
initializes `ctx->env` only at `nx_rt_open`. Its heap pointer remains stable:
[`corpus_grow`](../../selfhost/src/runtime/native/runtime.c) extends mapping at
the existing base plus its old size and refuses relocation. `ALC[0]` has static
storage. Allocation misses and free-list handoffs mutate contents, not those
base addresses. Passing the bases copies borrowed machine pointers; it creates
no additional owning Term credit.

These claims require the existing single active CPU context, no concurrent
mutation, and the exact admitted runtime layout. The closed source-call graph
cannot open/close a context or invoke arbitrary foreign callbacks. Thus neither
borrow escapes its exported call's lifetime. The context-load mode additionally
requires the exact layout assertions in
[`runtime-assert.inc.c`](../../selfhost/tools/performance/phase110/context-calls/runtime-assert.inc.c):
heap and allocator pointer offsets 0 and 8, with a 16-byte `Env`.

Each exported wrapper keeps both original getters, including their active-context
and clean-scratch checks. Removing internal getter calls removes repeated dynamic
checks of `pending == 0`; the invariant must instead follow from the authenticated
operation templates. Ordinary Take transfers both scratch children immediately;
reconstruction transfers its remaining child before the suffix; direct private
templates leave pending state unchanged. Therefore no owning call intervenes
while scratch is live. This is an inspected template invariant, not a theorem
of the numeric ownership-credit verifier alone.

## Concrete gates and limits

The [new verifier](../../selfhost/tools/performance/phase110/context-calls/verify.bend)
first checks the unchanged source ownership library, including closed callees
and the private-word namespace restriction. It now also checks every worker's
exact two-getter prefix: destinations `ir_heap`/`ir_alc`, called imports and sole
`ctx` arguments, in order. Only then may the transform remove those statements.
It requires exact canonical
equality with a regenerated machine library and shared Nx signature/type checks.
This protects callers from supplying arbitrary pointer-bearing machine graphs.
It does not independently prove the regeneration algorithm correct.

All three hidden/context values have type `NxPtr`; generic typing cannot detect
their permutation. The prepared controls deliberately show that a heap/allocator
swap typechecks while exact regeneration rejects it. Other controls cover a
missing pointer, unchecked wrapper, private export, rewritten runtime import,
wrong context offset, generated-name collision, invalid mode, public memory
refusal, and attempts to use a borrowed base as an owning word. Positive controls
cover ordinary recursion, tail loops, atomic view preservation and one getter
call per wrapper. Two independent expected-list controls check the complete
order of `ctx`, both borrowed bases and two distinct owning arguments in threaded
mode, and the unchanged argument list in context mode. A missing-prefix control
checks refusal. The coordinator's
[context-emit04](../../selfhost/build/phase110/context-emit04/report.json)
receipt records all 31 named controls passing, including six focused comparator
controls, and 54 actual-graph data mutation refusals.

The [C emitter](../../selfhost/tools/performance/phase110/context-calls/c.bend)
correctly distinguishes `struct NxRt *ctx` from `uintptr_t` borrowed base
parameters; the old library emitter treated every pointer parameter as a context.
It also emits pointer-member loads through `memcpy` into `uintptr_t`, avoiding
an integer-lvalue read of a C pointer member and its strict-aliasing problem.
The original Nx/QBE loads are unchanged. Interpretation of the copied pointer
representation still belongs to the pinned host ABI; this is not a portable
arbitrary-pointer-representation claim. The context layout assertions and
single-thread lifetime premises remain necessary.
The widest admitted source arity, eight, produces eleven integer/pointer
parameters in threaded mode. The later
[context-wide-machine02](../../selfhost/build/phase110/context-wide-machine02/report.json)
receipt supplies synthetic native coverage: all six mode/backend combinations
passed four independent ownership observations, totaling 24. Each worker consumes
eight owning string arguments, returns the eighth intact, and is checked with
unique/shared inputs, both release orders, surviving aliases, clean scratch and
zero live words. Clang disables inlining and sibling-call optimization so the
ordinary calls remain exercised. Three focused emission controls also passed.
Machine inspection confirms QBE's eleven private arguments, including five
stack slots. Clang removes the two unused borrowed pointers and hoists the
returned eighth owner, leaving eight private arguments despite the no-inline
flags. Thus both backends qualify the public nine-argument ABI, but only QBE
qualifies the exact private eleven-argument machine path. This is not an
actual-source or timing claim; the concrete source corpus mainly uses arities
one and two.

## Exact graph comparison and evidence boundary

The final comparator is `nx110ctx_exact_go(same, a, b)`, a consuming direct
self-tail traversal. It starts with `same = True`; a mismatch returns False,
two exhausted strings return True, unequal lengths return False, and paired
characters advance with equality of their full `Char.to_u32` values carried
into the next step's `same` flag.
This preserves complete code-point sequence equality. It compares neither a
checksum nor a prefix, and `Ā` versus `Ȁ` explicitly tests characters sharing
the same low byte. Imports, function bodies and exports remain in the complete
canonical machine serialization checked against regeneration.

The change addresses the hosted stack overflow in the former generic String
comparison on larger graphs. Source inspection establishes its intended exact
comparison behavior; it is not a new independently checked universal law or a
general guarantee of bounded serializer/compiler memory. Earlier acquisition
failures remain recorded in their original directories.

[context-admission07](../../selfhost/build/phase110/context-admission07/manifest.json)
records seven successful exact-source refusal controls, and
[context-api07](../../selfhost/build/phase110/context-api07/report.json) records
successful checked API acquisition. Those are separate from native semantic
execution, the 31 Bend controls, and actual-graph mutation probes.

[context-machine02](../../selfhost/build/phase110/context-machine02/report.json)
completes the native diagnostic: all 18 workers passed the unchanged frozen
oracles, totaling 234 observations (20 String.append, six non-tail append and
13 reverse cases, each across three modes and two backends). The assertion-only
runtime object was byte-identical to the original runtime object. The initial
[context-machine01](../../selfhost/build/phase110/context-machine01/report.json)
failed during threaded Clang compilation because `string.h` could not find
`stddef.h`. The successful repeat supplies the same pinned GCC 10 standard-header
search path to every Clang mode and changes no admitted source product.

Five paired rounds on each of the two frozen String.append timing cases also
completed. Median variant/baseline worker ratios range from 0.834 to 0.907 for
Clang and 0.850 to 0.904 for QBE. These bounded diagnostic results do not establish
universal speedup or compiler improvement throughput, and the selected native
image remains unchanged.
No new abstract law is claimed: the existing safe ownership models do not
describe context memory lifetime, and a detached pointer-list theorem would not
close that gap.
