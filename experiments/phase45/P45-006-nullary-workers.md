# P45-006: demanded nullary private calls

Status: design and implementation in progress; no activation or timing result yet.

Closed computations are currently excluded before the existing worker proof runs:
root admission requires positive arity and an erased call, the collector requires
a contextual specialization row, and Ref expressions only admit literal globals.
The public backend already represents computed globals with delayed `fn(0)`
descriptors. Runtime `get` calls those descriptors on every access. The proposed
change preserves that behavior; it does not precompute or memoize results.

The first slice admits arity-zero roots only when their normalized result is an
existing scalar or exact native String. Positive-arity roots retain their current
erased-call prefilter and requirement for contextual rows. A zero-argument root
may instead use a complete graph of exact source aliases. Existing source identity,
purity, type/layout, graph-size, literal-provenance and host proofs remain required.

Collection follows a runtime Ref to a known source definition with arity zero,
including its body in the same bounded graph. Rewriting renames the Ref through
the exact source-alias row. Purity treats that Ref as a demanded call with no
arguments, proving the target's complete body and exact result type. Worker
lowering emits the existing `JWDirectCall` with an empty argument list; it is an
instruction at the original demand point, not a reusable value or global load.
Zero-argument function bodies and component wrappers already support this shape.

Public zero-argument descriptors receive the same immutable snapshot treatment as
other source helpers. The wrapper remains `fn(0, exactCode(...))`; exact entry,
dependency guards and host guards are checked on every call. A direct invocation
of `.code` receives no entry permission, and overapplication keeps the generic
path. The original delayed generic body remains the fallback. The separate
all-erased specialization restriction is unchanged in this slice.

Required falsifiers include:

- A monomorphic nullary root with no erased calls, and a String-returning analogue.
- A helper referenced twice, retaining both demands and their left-to-right order;
  mutate its public code to expose demand count and force guard refusal.
- Repeated public root calls with a mutable helper: no import-time execution,
  caching or stale captured result.
- Public global/code/env/bound/arity getters or replacement, Function `.call`,
  String hooks, direct `.code`, overapplication, thrown errors and reentry.
- A nullary constructor result used only inside the private graph, while record,
  array, function and IO results remain excluded at the public root boundary.
- Positive-arity alias-only roots remain unselected; foreign, missing, malformed,
  unsupported-type or oversized graphs retain the generic backend.

The existing RLE library test is a plausible coverage target: its nullary scalar
root calls a monomorphic list/tuple graph. Nullary admission alone cannot promise
the other three library tests activate. Morning uses function-valued recursive
arguments; evening uses `Array<F32>`; Map/Set uses `Map<Unit>`, while the current
Map proof requires scalar payloads. Those separate proof gaps remain refused.
Qualification must distinguish a passing generic fallback from executed worker
entry, using a separate counter derivative whose timings are never benchmark data.
