# Public entry profitability and guard allocation

Status: bounded **GO for an allocation-free raw-array dependency-guard
prototype**, not a measured speedup or a production approval. No compiler build,
target run, or shared source edit was performed by this owner. **NO-GO** for
cached admission, skipping prototype/source dependencies, or workload/input
thresholds. Root owns runtime/region integration and all execution.

## Starting evidence

Read the final array06 runtime, `array-view.bend`, region entry emitter, generated
local-fold module, pinned upstream emitter/runtime, and Phase47 guard study.
[Phase47 guard cost](../../implementation/phase47/array-guard-cost.md) reports
array04's short fold at 7.705 us Worker23 versus 16.362 us candidate in a separate
corpus run (2.124x slower). Its guard-only ablation measured original 15.879 us,
integer-only 14.075 us, and unsafe host bypass 6.235 us at `(128,0)`.
Those observations expose fixed-entry cost; they are not array06 timings and
must not be subtracted across campaigns as paired exclusive costs.

Array06 already supplies the complete no-F32 proof and retains Math.floor plus
allocation hooks in its integer host guard. Repeating the old unsafe
integer-only ablation is not a new source optimization. The Phase47 complete
host bypass lacks the mutation/ownership contract and cannot ship.

## Actual call and proof boundary

The generated public root remains an ordinary `fn`/`exactCode` closure. It reads
its existing argument slots, then, only for `$entered`, evaluates:

1. Fresh `arrayViewHostGuard(true)` for the completely proved integer graph.
2. Canonical scalar input checks, preserving slot demand and order.
3. Full `localGuard($guards)` source/function identity checks.
4. The raw helper closure, otherwise the complete old private/generic path.

The short local-fold raw graph has eight required source dependencies: bench,
Array.new, fold.loop, fold.cell, Array.get, fold.step, Array.set, fold.finish.
It allocates a local power-of-two backing array and works on that raw array;
every public call nevertheless repeats host and source admission. The raw
helper graph already shares one entry proof and never calls the public guard
per loop iteration. The binary-tree route similarly shares its proved helper
representation across leaves. Additional compositional proof within those
graphs is not a missing repeated-check optimization.

Host checks include current intrinsic descriptors, prototype chains, full
Array/Object string-key inventories, iteration/species descriptors, floor,
fill and isSafeInteger. Source checks include current G binding, code, arity,
env and bound identity, zero bound length, original function/code prototypes,
own call and forcing/type markers. These are observable contract obligations;
no successful check may be cached across public calls or mutated G/host state.

## Concrete allocation-free proposal

The raw-entry-only fragment
[array-local-guard-v1.js.frag](../../selfhost/tools/performance/phase48/entry-profitability/array-local-guard-v1.js.frag)
retains the original `localGuard` plus `scalarGuard` predicate and descriptor
order under a fresh array host proof. It removes temporary guard containers:

- Per-call prototype spread array and its iteration.
- Repeated literal marker-key arrays around prototype/function checks.
- Per-dependency `[arity,code,env,bound].every(...)` arrays and method calls.

Use indexed loops with the original private prototype list and fixed marker
strings; use four ordered short-circuit own-value checks. Keep every descriptor
lookup, native/source comparison, string-family guard and fallback. No root name,
trip-count threshold, check deletion, global success cache, or representation
change is introduced. The current descriptor records still allocate; this
proposal does not claim to eliminate them or the full fixed cost.

Only raw-root/tree branches whose preceding host proof succeeds may call
`arrayViewLocalGuard($guards)`. The specialization refuses non-null regionProof.
Canonical input checks between host and source admission are pure native scalar
checks under that proof, so no callback or mutation can invalidate it there.
The remaining old branches continue to call the original localGuard.

Do not replace scalarGuard globally. Its other callers can run without a fresh
array host proof; removing their Array iteration/every observations would need
another proof. Here the fresh guard checks those exact protocols first, making
the removed temporary-container protocols inert on the admitted route.

Expected implementation: one optional runtime fragment containing only this
function and a raw-root/tree emitter substitution from localGuard to
arrayViewLocalGuard. Function declarations introduce no new top-level host
captures. Preserve all existing host captures at their current early runtime
location, before embedded foreign initializer execution. An optional late
fragment that captures Math/Number/Array or reflection after such initializers
would redefine the standard-host snapshot and is unacceptable.

## Other directions and limits

Root-specific hook masks are plausible only after a complete executable
operation inventory covers public input validation, both planned arms,
every helper, allocation, and all runtime helpers they call. U32.div needs
Math.floor; multiplication needs Math.imul; Nat conversion uses BigInt/Number;
allocation needs Array, fill and isSafeInteger. F32 absence alone does not prove
those unused. Required checks of the guard implementation itself belong in the
mask as well. No additional mask is proved or proposed for production here.
Even a sound numeric mask leaves prototype/protocol and source descriptor work,
so it should not be credited with the unsafe bypass's roughly 9-us opportunity.

Pinned TypeScript directly lowers native arithmetic and Array operations and
does not establish this self-hosted compiler's mutable-G/private-entry contract.
Its shorter ordinary call path is relevant structural evidence, not permission
to delete guard or wrapper semantics. The TS and checked compiler have different
public/runtime APIs; a shared primitive result does not prove equal host demand.

A policy derived only from static graph shape could refuse an unprofitable
optimization everywhere, but that sacrifices the same root's long-run gain.
A dynamic crossover based on input count needs a general work model and must
read inputs only at the already legal point. No measured constant, program
recognizer, or magic input cutoff is justified now. The initial workstream tests
removable entry allocations rather than inventing such a policy.

## Qualification before timing or source promotion

The diagnostic producer prepares original, allocation-free, and explicitly
unsafe full-admission-bypass saved modules. Counter/audit modules are separate
from clean timing modules. All transformations are exact and invertible;
parent module/receipt/API/runtime/source identities are bound in the manifest.
No diagnostic is a checked compiler artifact.

Require an ordinary public-root positive entry witness and values at zero,
short and long counts with multiple seeds. Independently compare old and new
source-guard verdicts under binding/code/arity/env/bound/prototype/call/marker
mutations, checking accessors are not invoked during guard admission. Check
source throw plus nested reentry on the unchanged fallback. Apply the existing
Phase47 array-view/layout/integer/tree semantic controllers to any actual
source-derived candidate; include foreign initializer mutation, host/Number/fill
replacement, late mutation, numeric prototype setters, non-F32 and F32 refusal,
partial/raw ABI, demand/order and alias controls. Keep deep roots and tree-zero
behavior intact. Predicate tests alone do not qualify source promotion.

Root should first run the bounded independent audit and maintained short/long
public-call screen. If the safe variant does not improve short entry materially,
retain the negative result and stop this prototype; unsafe bypass is an upper
bound, never a candidate. The user-visible regression is not claimed fixed
until an actual checked candidate passes semantics and fresh ordinary timing.

## Prepared handoff

The isolated [emitter patch](../../selfhost/tools/performance/phase48/entry-profitability/entry-emitter-v1.patch)
changes exactly the two proved raw-entry guard call sites. Its sidecar binds the
current parent source and patch hashes. Root must add the optional function
fragment before applying either call site; the fragment is staged only here,
and no runtime/region source has been modified by this owner.

The [data-only producer](../../selfhost/tools/performance/phase48/entry-profitability/derive-v1.py)
accepts the exact final array06 API/runtime and historical local-fold source
identity, not arbitrary modules with a coincidental export name. It emits six
independent local-fold point configs, three clean variants, and two separately
counted audit modules. The [audit controller](../../selfhost/tools/performance/phase48/entry-profitability/audit-v1.mjs)
requires 12 ordinary-root value/entry rows, 192 dependency-predicate mutation
rows for the frozen eight-name graph, and four original-error/reentry fallback
rows. These saved-output controls remain distinct from checked-source proof.

Python AST, both JavaScript syntax checks, and exact two-site patch generation
passed. The producer and controller have not been executed. Root may schedule:

```sh
python3 selfhost/tools/performance/phase48/entry-profitability/derive-v1.py \
  selfhost/build/phase47/array06-full/modules/local-fold.mjs \
  selfhost/build/phase48/entry-profitability01

# Run only through the existing bounded execution supervisor/serial lock.
/home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --stack-size=4096 --max-old-space-size=1024 \
  selfhost/build/phase48/entry-profitability01/audit-v1.mjs \
  selfhost/build/phase48/entry-profitability01 \
  selfhost/build/phase48/entry-profitability01/audit-report.json
```

For timing, use clean `original/program.mjs`,
`allocation-free/program.mjs`, and `unsafe-admission-bypass/program.mjs` with the
maintained ordinary execute driver and balanced fresh-process protocol. The
unsafe variant omits this entry's host and dependency guards, keeps canonical
input checks/body/fallback, and is labeled unsafe in the manifest; it is a cost
upper bound only. Counter/audit modules are ineligible for timing. The Phase47
guard timing wrapper assumes exactly three points; do not reuse it blindly for
the six prepared point configs. Root can select short/medium/long configs for a
bounded initial screen or use its normal serial measurement controller.
