# Phase109 independent controls and existing lowering evidence

Preparation starts from verified commit `caee74847c270bc00f3cf0751159d4ec72b1612e`.
This audit inspected source and existing machine code; it did not compile or run
compiler candidates. Root's separate experiment receipts own target results.

## Frozen controls

[Manifest](../../selfhost/tools/performance/phase109/controls/manifest.json) freezes
13 input/ownership cases before candidate execution at 2026-10-18 18:15:07 UTC.
The hand-selected inputs and independently computed sequence-reversal oracle cover:

- Compiler `nt_reverse<List<String>>`: empty, singleton, ordinary unique heap,
  independently held original root, held tail plus opaque held string head, static
  input nodes, and a 65,536-cell heap list with four distinct head values.
- Unchanged pinned Base `String.reverse.go`: empty, singleton, Unicode scalar
  reversal, combining-character reversal, held original root, and static input.

Each observation includes result count and FNV64, every retained alias's separate
count/hash, and allocator release. The deep pattern is `a`, `bc`, empty, `λ🙂`;
all list cases preserve heads as opaque owned String values. The intended harness
constructs real production Terms, invokes only the generated worker for reversal,
then independently observes and drops every owned root. A digest and release
accounting are finite checks, not an ownership proof. Physical shared/static paths
must be demonstrated by the actual runtime adapter; the descriptor alone does
not establish them.

The seven selected Phase108 source controls retain their original bytes and
independent stdout. The new direct slice admits worker bodies only; it does not
claim the IO wrappers, higher-order case or non-tail list. `non-tail-list` remains
a useful full-route continuation control and an explicit new-slice refusal.
Negative ownership, malformed lowering and ABI entries are planned gates; only
separate actual receipts may label them executed/passing. No negative count is
inferred from the number of manifest entries.

## Three source-to-machine traces

Exact existing source, binary and build-receipt hashes, focused disassembly and
commands are retained in
[inspection/manifest.json](../../selfhost/tools/performance/phase109/controls/inspection/manifest.json).
They come from the already-qualified Phase108 successor's generated programs.

| Witness | Existing generated representation | QBE machine evidence | Implication |
| --- | --- | --- | --- |
| Compiler `nt_reverse` | Ordinary `NF_FID_...` function; `nf_again` self loop; `ctr_take` transfers two children, `spare_free` releases shell, constructor allocation and sealing rebuild result. | 358-byte function. Normal nonempty loop has seven calls: `cls_fit(2)` twice, `ctr_take`, `spare_free`, `heap_alloc`, `rfc_seal` twice. Forty bytes of locals plus five saved general registers; Env repeatedly reloaded across calls. | This kernel already avoids per-cell continuation dispatch. Direct Nx would test ownership/runtime-call shape and preservation of semantic information, not newly invent tail loops. |
| Base `String.reverse.go` | Same ordinary self-tail structure with SCon/Char layout instead of List/String. | Also 358 bytes and the same seven normal-loop calls, including a generic seal for the immediate character head. | Scalar head role and known constructor arity could remove categories of generic work. A conservative initial ABI should first match semantics; specialization needs explicit type/layout evidence. |
| Non-tail `bump` | `WL_CASE` takes a list node, saves the head and return segment, recursively enters `bump`, then resumes a separate constructor-building continuation. | 560-byte first segment, WlState loads and spills, continuation-stack writes or `task_node` path, dispatcher state writes/return. | Continuation transport is real here. It is not interchangeable with the reverse kernels; the new slice must refuse it until non-tail/suspension semantics are implemented. |

The source reverse workers each contain eight `err_seen` sites and one `err_spun`
site. **These are not eight runtime CPU checks**: `err_seen(H)` expands to
`DEVICE && ...`, so CPU conditions disappear. QBE retains a dead polling-counter
increment, but that is distinct from checking memory on every intermediate value.
Do not predict gains from counting source-level error sites.

[production-workers.c](../../selfhost/tools/performance/phase109/controls/production-workers.c)
contains the two exact generated bodies, with extraction provenance in its JSON
sibling. Their input signature is `(Env, bool seq, Term *result, Term xs, Term acc)`;
the return is success status and `result[0]` receives the owned value. These can
be exposed through the same adapter entry signature as the Nx workers, allowing
identical runtime graphs, independent oracles and worker-only timings. The
original program's Nil/Con/SNil/SCon IDs are 17/18/24/25; rebinding macro names to
the adapter catalogue 0/1/2/3 must be explicit. Preserve hot constructor policy
and child sealing. This is a matched C reference, not a C-to-IR parser.

## Separate transport, helper adaptation and backend costs

The same complete Phase108 C files contain both `#if WL_PORTABLE` and original
`preserve_none`/`musttail` implementations. No fresh Bend emission is necessary.
[baseline-plan.json](../../selfhost/tools/performance/phase109/controls/baseline-plan.json)
provides four authenticated build profiles for the three frozen source fixtures:

1. Clang, original transport and native helper/atomic policy.
2. Clang, portable pointer-state transport, same native helper/atomic policy.
3. Clang, portable transport plus cproc's five accessor macros and exact external
   GCC atomic/CLZ shim ABI.
4. cproc/QBE, exactly the portable policy and shim ABI in profile 3.

The additional Clang profile matters: otherwise the QBE comparison conflates
machine backend quality with helper macros and external atomics. Profile 2/1
isolates transport; 3/2 isolates the support adaptation bundle; 4/3 compares
machine backends on matched support inputs. Constructor attribute adaptation in
the shared header is also a toolchain compatibility detail to preserve.

The small complete programs establish semantics, toolchain behavior and build
latency. Their process execution is startup dominated and **cannot justify a
runtime speed ratio**. Worker-only repeated timings on constructed ownership
inputs are the next discriminating measurement. Cache the same runtime object
when comparing Nx compilation; separately identify its acquisition compiler and
cost so a faster precompiled runtime is not credited to the IR itself.

## Recommended interpretation

The high-value experiment is a structured ownership boundary with actual checked
source, honest refusal and production-runtime semantics. The conventional C
backend already has some valuable direct-call/loop capabilities. A useful new
IR must preserve those while making constructor arity, head roles and ownership
transfer explicit enough to simplify generic runtime calls before machine
lowering. A successful reverse result would establish this boundary, not complete
Bend support or a whole-compiler performance gain.

## Separate Keep/Sink source extension

At 18:22:41 UTC, before candidate execution, `controls/derived/` freezes four
additional ordinary source functions: List/String discard and List/String
duplicate. The former drops each input head and returns the unchanged accumulator;
the latter retains each head twice while reversing node order. They reuse the
original 13 runtime inputs with separate discard/duplicate oracles and unchanged
alias expectations. This directly tests compiler-inserted Sink/Keep, which reverse
alone does not exercise. Scalar Char heads are included: their keep/drop must be
trivial rather than incorrectly requiring an ADT constructor ID.

Independent runtime/harness review identified and the runtime author corrected
both that scalar-Char admission restriction and missing consistency comparison
for benchmark repetitions after the first. Later repetitions now compare results
and retained aliases against the first observation, in addition to allocator
release per repetition. Root's actual execution receipts, rather than this
source review, determine whether those controls pass.
