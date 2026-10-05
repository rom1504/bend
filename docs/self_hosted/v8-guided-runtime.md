# V8-guided runtime changes (Phase51)

The [design](../../design/phase51/v8-guided-runtime.md) starts from profiles of
the existing 45-point generated-program benchmark. The
[phase report](../../implementation/phase51/README.md) records qualification and
release status; a saved-JavaScript experiment is not itself a compiler release.

## Keep the ordinary application path small

`apply` in `selfhost/src/runtime/js/core.mjs` retains its original branch tests,
property-read order, vector ownership, partial application and overapplication.
Only the IO branch body moves into `applyIO`. This is enough for pinned V8 to
inline some ordinary applications. The helper creates the same closure over the
same `f`; mutable IO properties are still read at the original invocation time.

Extracting four branch bodies also enabled inlining, but displaced useful
`force` inlining and did not reliably improve execution. A smaller bytecode
function is not automatically a faster program. Inlining decisions and clean
timings must both support a change. Neither trace proves that V8 physically
eliminates a particular allocation.

## Reuse a fresh check within one synchronous entry

The contextual root emitted by `j_instance_root_guarded_mode` reads all argument
slots first, then checks exact-entry permission, the host, String objects and
scalar input types. Its dependency check formerly scanned String objects again.

The private `stringHostChecked` identity permits `scalarGuard` to reuse this
first String check through `localGuard`. Other dependency, prototype and source
checks remain. Only primitive scalar predicates intervene between the fresh
check and its use. They operate on already-read slots; host intrinsics have just
been checked. Unknown input forms refuse admission. No user callback, getter or
suspension may be introduced into this interval without revisiting the proof.

This token is not exported, stored as persistent permission or passed to other
entries. An argument getter executes before the first check, so a mutation or
reentrant call cannot reuse stale permission. Each later public call checks
again. A failed check retains the ordinary path; restoration can admit the next
entry. Dedicated controls compare full results, error identity and event order.

## How to investigate the next change

Use the [bounded benchmark](../../selfhost/tools/performance/programs/README.md)
for clean timings and the [V8 tools](../../selfhost/tools/performance/phase49/README.md)
for separate CPU/allocation/inlining observations. Test exact derivatives of
saved output first; compile a checked candidate only after a useful mechanism
survives boundary controls. Preserve dropped prototypes and regressions.

Warmup matters: the IO experiment's large Evening gain under a one-second warmup
shrunk to about 4.8% with 32,768 warmup calls. Report the timing protocol alongside
the number. CPU profiles, instrumented counters and traces are diagnostic data,
not replacement speed measurements.
