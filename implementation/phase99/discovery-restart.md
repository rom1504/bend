# Phase99 discovery restart

The user asked us to stop spending so much time qualifying a modest improvement
and find stronger optimizations. We stopped source04's repeated full-self release
comparison, retained its completed results, and tested two larger changes using
small generated native programs. The installed Phase98 release is unchanged.

## Result

On the **identical complete compiler source**, the Phase98 native B2 takes
**146.487 seconds**, while the combined experimental native compiler takes
**105.184 seconds**: **28.2% less request time, or 1.39× faster**. Both use CPU3,
one worker, the same cached Base, native runtime and effect providers. Request
time excludes preparation and output writing; process times are 147.388 and
105.971 seconds. This is one candidate run followed by one baseline run, not a
repeated or randomized estimate.

The experimental compiler reproduces **all 36,906,655 bytes** of its own C from
the checked JavaScript-hosted Bend implementation. Full diagnostics agree across
those paths and the Phase98 baseline. Baseline C differs, as expected from a
changed backend. The earlier source04 observation was 130.940 seconds on its
slightly smaller source; that comparison is contextual, not the matched result.

## What changed

1. **Borrow fields under a retained aggregate.** Bounded plain ADT schemas allow
   an observer to inspect a String field of a KTerm and call a certified scalar
   observer without retaining/disposing every field. Applied field types remain
   opaque; escaping children, mutation and effects retain ordinary ownership.
   The owning adapter retains cleanup responsibility. The three-layout tag
   probe falls from 0.32784 to 0.10439 seconds. Its short duration limits timing
   precision, but complete fields, nested aliases and Unicode outputs agree.
2. **Eliminate branch closures before lowering.** A bounded shape rule expands
   small closed saturated selectors with literal lambda actuals. Nonliteral
   actuals are evaluated once in order. Unsupported cases use the old call path.
   The name-key probe removes two closure allocations, an extra retain and the
   selector jump. Its short screen falls from 0.11421 to 0.06338 seconds. Eight
   native behavior executions include both branches, captures, returned closures,
   selected/unselected effects and an unused strict argument that must overflow.
3. **Avoid making the optimizer itself expensive.** A single interval scan
   replaces 64 repeated AST freshness traversals. Forty-four comparisons against
   the actual old helper agree, including interval endpoints, nested variables,
   malformed Var leaves and duplicate environment bindings. This is a finite
   differential check, not a general equivalence theorem.

These rules are based on checked types and code shape, not helper names. Across
each version's own C image, borrowed observer owners increase **11→49**, dispatch
segments fall **39,470→32,831**, and C size falls **4.6%**. Static allocation sites
fall 11,126→7,492; disposal sites rise 11,303→24,716 because branches contain
explicit cleanup. These text counts are not dynamic execution counts.

## Faster experiment loop and costs

The separate scalar-width and dispatch probes did not justify integration.
The dispatch-pointer screen saved only 2.94% on its affected synthetic workload.
No native compiler image was built for either rejected direction.

For the combined winner, a checked stage0 API executes the same prepared native
request in a JavaScript host, authenticating the existing Base/runtime/effects.
Clang then builds its C into one experimental native compiler. Native compilation
requests execute that binary; JavaScript is only this experiment's bootstrap
host. This skips constructing a fresh upstream-produced native B1 for every
prototype. It does **not** establish a qualified B1/B2 chain.

The acquisition took 185.43 seconds: Base preparation 3.84, request preparation
79.35, emission 100.78 seconds. Clang O2 took **311.67 seconds**, versus 266.90
seconds for source04's image, and peaked at 3.62 GiB. This build-time regression
is real even though native request time improves. API acquisition, small code
shape checks and behavior probes remain the default iteration loop. A full
image is reserved for a promising combination.

## Five metrics and limits

| Metric | Evidence for this combined candidate |
| --- | --- |
| Compiled-program speed | Two focused native mechanism screens improve; the representative 45-program campaign has not been rerun. |
| Native B1 compilation | No new upstream-produced native B1 was built. |
| Native B2 compilation | Experimental native image improves the same-source request by 28.2% versus qualified Phase98 B2; native-chain qualification is pending. |
| Conformance | Full self-C/diagnostics agree, focused branch and ownership controls pass; no new full-suite result is claimed. |
| Simplicity | 39,097 physical Bend lines / 1,772,435 bytes: +307 lines / +18,339 bytes over Phase98. Canonical modules and installed JS are unchanged. |

Combined source SHA256 is
`274b65b5921d883f0e5c70fa246ffd70c9aedf897c387e35aa23686a28412682`.
The source04 argument/guard helper laws remain local contracts; they do not prove
the new aggregate or selector transformations. Full native-chain qualification,
broad conformance and changed-program timing are deferred to final promotion.
No installed pointer or PR comment was changed.

Commands and recipes are under `selfhost/tools/performance/phase99/`, especially
`borrowed-projections/`, `branch-closures/`, `discovery-compile-v2.mjs` and
`discovery-native.py`. Raw results are under `selfhost/build/phase99/`:
`projection-native01`, `branch-native01`, `interval-cases01.json`,
`combined-discovery02`, `combined-native01`, `combined-native-self01`,
`combined-baseline-self01` and `combined-controls01`.
The [evidence bundle](discovery-evidence/README.md) preserves the selected source,
native image, generated C and raw results in Git with a file/hash manifest.
