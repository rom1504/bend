# Local descent and constructor unwind

Source-only prototype. No compiler, API or program has been run by its author.
Parent qualification receipts, when available, determine admission and behavior.

The optional public-chunk hook derives an exact plan from the original verified
N111 graph. It does not inspect emitted C/QBE or change the runtime ABI. Existing
direct functions retain precedence; unsupported functions keep their old chunks.
Only one recursive frame site, one captured field, a one-result entry of arity
1–8, and an exact two-field constructor continuation are admitted. The recursive
result must be the second field. The continuation does no other work. Known
tail self-edges can coexist with the one constructor-spine site. Ordinary scalar
prefixes and ownership calls retain their source IR order.

This is an initial local continuation region, not forward destination passing:
result allocation still occurs on unwind, and the existing explicit stack still
holds two words per recursive level. It removes recursive dispatcher entries,
return-bank clears/copies and result-register reloads. It intentionally retains
the original frame helper and uses existing stack-pop/get helpers, so a speedup
is not established by static admission alone.

`p112t_prelude` supplies the original argument order. `p112f_frame` identifies
ordered capture stores and their exact FID. `p112f_cont` verifies the continuation
prelude. The local depth starts at zero and rises only after the retained frame
call. Every base return enters local unwind: when depth is nonzero, pop2 removes
the saved head and FID, get0 restores the head, the recursive result enters the
original incoming-result local, and the exact constructor stores/call execute.
Depth zero returns one owning Term to the public wrapper, which performs the
original `p111_rt_return` once. Thus the caller's pending frame is untouched.
The local invariant is `sp = entry_sp + 2 * depth`, with the same ordered head
owners and continuation FIDs in those slots as the original execution. The
recognized ordinary helpers cannot inspect the omitted register/next-FID updates.
This is a source argument for this exact template, not a machine-checked theorem.

The original constructor count/layout is still checked by the original verifier
and runtime. Both fields transfer exactly once, with original sealing and shared
input behavior. No input or output heap field is patched privately. Native stack
use is constant: one public wrapper and one worker, with fixed scratch buffers.
The original worklist capacity/resource domain is retained; no stronger unbounded
memory guarantee is claimed.

Private entry loops snapshot all argument slots before rebinding parameters.
Continuation names receive a private prefix and separate scratch. Source locals
with that prefix keep the generic fallback. Branches reuse selected source31's
exact Boolean-diamond normalization. The original whole-program verifier is
required before this hook, and reflected `P114RPlan.valid` is not an external
certificate. The private emitter is an authenticated transformation of that
checked graph, not a new arbitrary-IR ownership checker.

The first version retains exact original failure suffixes under the pinned
sequential CPU runtime's fail-stop contract. Those suffixes cannot return a
normal owned value. It does not qualify a recoverable-error, multithreaded or
GPU runtime. No new failure probes are needed: ordinary source controls and
complete outputs are the requested gate.

Inspection-only modules are pinned in `inspection-modules02.json`; they have no
overrides. The first root acquisition rejected an inline match's source-language
position; v2 moves it to a helper with identical eligibility. V1 remains in its
frozen acquisition and `plan-v1.bend`. No successful inspection is claimed here.
The driver is root-only:

```sh
bun selfhost/tools/performance/phase114/recursive/inspect.mjs \
  CHECKED_API FRESH_PHASE114_OUT \
  selfhost/build/phase93/fixtures01/coverage-list-pipeline-128.bend \
  selfhost/tools/performance/phase114/controls/fixtures/append-owned-suffix.bend
```

Required exports: `p88_cache_prepare`, `p86_plan`, `p111_runtime_admission`,
`p114r_inspect_request`. It authenticates all acquisition and source assets,
preserves frontend/runtime/inspection diagnostics and reports admitted names.
The inspection performs the ordinary lowerer/final verification internally;
its duration is not an isolated planner-cost measurement. An empty admitted
list is evidence of fallback, not a successful optimized witness.

For emission, append model, plan, namespace, emit and integration modules, then
apply the single declaration override in `entry.bend`. Ordinary controls are
owned separately by the Phase114 controls agent. Require actual called `dbl`
and String append admission, full output/alias survival, and refusal of the
post-call projection, non-final recursive field and two-child reconstructor
before any runtime comparison. Generic failure-continuation and metadata
segments remain emitted even when a spine worker is selected.
