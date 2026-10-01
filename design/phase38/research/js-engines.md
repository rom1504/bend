# JavaScript engines: expose useful facts without assuming VM privileges

Research date: 2026-10-01. Primary documentation and implementation inspection
only; no target program, V8 diagnostic command or alternate engine was run.
All gain estimates are speculative additions to installed Phase37.

## Version and primary-source boundary

Phase37 ran Node **24.18.0**. The installed `include/node/v8-version.h` identifies
V8 **13.6.233.17**. The Node release's bundled V8 sources are the implementation
reference here; latest V8 development behavior is not substituted for that image.
JavaScriptCore is a comparative implementation, not the measured engine.

- V8's [hidden-class guide](https://v8.dev/docs/hidden-classes) and
  [fast properties](https://v8.dev/blog/fast-properties) (2017 background).
- [Elements kinds](https://v8.dev/blog/elements-kinds), 2017 with a 2025 update;
  old universal claims about one-way transitions have documented exceptions.
- Node v24.18.0's [native-context specialization](https://github.com/nodejs/node/blob/v24.18.0/deps/v8/src/compiler/js-native-context-specialization.cc)
  and [escape analysis](https://github.com/nodejs/node/blob/v24.18.0/deps/v8/src/compiler/escape-analysis.cc).
- WebKit's [Speculation in JavaScriptCore](https://webkit.org/blog/10308/speculation-in-javascriptcore/)
  (2020 explanation, not a current performance ranking).
- JSC source pinned to [`2917d6c16d9c986306a567222dda3ef72e2a1ddb`](https://github.com/WebKit/WebKit/commit/2917d6c16d9c986306a567222dda3ef72e2a1ddb):
  [Watchpoint.h](https://github.com/WebKit/WebKit/blob/2917d6c16d9c986306a567222dda3ef72e2a1ddb/Source/JavaScriptCore/bytecode/Watchpoint.h)
  and [object-allocation sinking](https://github.com/WebKit/WebKit/blob/2917d6c16d9c986306a567222dda3ef72e2a1ddb/Source/JavaScriptCore/dfg/DFGObjectAllocationSinkingPhase.cpp).

Sources were read selectively around the named mechanisms. Published engine
benchmark ratios are not predictions for Bend. See also the
[Phase35 review](../../phase35/literature.md) and
[final Phase37 profiles](../../../implementation/phase37/profile-findings.md).

## What the engine supplies

V8 associates objects with hidden classes/maps and property layouts; repeated
accesses with stable shapes can use optimized access paths. Arrays have a
separate elements-kind system, with numeric/general and packed/holey distinctions.
These describe optimization opportunities, not JavaScript-visible ownership or
immutability. Normalizing away signed zero/NaN to preserve a fast kind would
change Bend numeric semantics and is not an acceptable application of this advice.
[Properties](https://v8.dev/blog/fast-properties),
[elements](https://v8.dev/blog/elements-kinds).

The inspected native-context specialization can fold certain prototype accesses
when it registers a stable-map dependency. Its array-store handling also checks
prototype behavior and records dependencies before taking a fast path. The VM
owns those dependency/invalidation mechanisms; the generated program does not.
[Pinned V8 implementation](https://github.com/nodejs/node/blob/v24.18.0/deps/v8/src/compiler/js-native-context-specialization.cc).

JSC distinguishes a fast/slow-path diamond from speculation that exits to a
less optimized tier with reconstructed state. The latter can remove repeated
checks because the VM controls profiling, invalidation and deoptimization.
Its watchpoint implementation maintains watched/invalidated states and fires
registered VM callbacks. A JavaScript library cannot register equivalent
watchpoints for arbitrary external writes to its mutable ABI.
[Architecture](https://webkit.org/blog/10308/speculation-in-javascriptcore/),
[watchpoints](https://github.com/WebKit/WebKit/blob/2917d6c16d9c986306a567222dda3ef72e2a1ddb/Source/JavaScriptCore/bytecode/Watchpoint.h).

V8 escape analysis represents eligible allocations as virtual objects and tracks
their fields along the effect chain. Unsupported stores/loads or materialization
constraints force escape. JSC allocation sinking couples local points-to and
escape information, keeping allocation identity separate from aliases and
materializing where required. Neither mechanism guarantees that a recursive
constructor passed through opaque dispatch will disappear automatically.
[V8 implementation](https://github.com/nodejs/node/blob/v24.18.0/deps/v8/src/compiler/escape-analysis.cc),
[JSC implementation](https://github.com/WebKit/WebKit/blob/2917d6c16d9c986306a567222dda3ef72e2a1ddb/Source/JavaScriptCore/dfg/DFGObjectAllocationSinkingPhase.cpp).

An illustrative private computation `p={x:a,y:b}; return p.x+p.y` exposes a
small allocation and fixed fields to the engine. Passing `p` through generic
callbacks before reading it may hide the necessary facts. Bend can improve
that visibility, or eliminate the pair itself when its own proof is stronger.
It cannot demand a particular register allocation, hidden-class ID or OSR exit.

## Bend's current boundary and measured targets

The public runtime deliberately supports mutable function descriptors, `G`
replacement, bound arguments, prototype hooks and getter reentry. Private
workers enter only through checked wrappers. Phase37's DataView counterexample
demonstrated why correct scalar results alone are insufficient: callbacks could
disappear when the native operation was bypassed without a complete guard.

[`core.mjs`](../../../selfhost/src/runtime/js/core.mjs) already creates `fn`
objects with a consistent property order. Blanket advice to standardize those
objects is therefore not a new optimization. The same `apply` machinery handles
many arities, closures and special values; whether a specific site becomes
megamorphic or fails inlining remains a hypothesis until VM traces show it.

At numeric 1024, `regionHostGuard` is 25.13% of candidate CPU self samples.
At active-ray 256 it is 27.38%, with `scalarGuard` another 14.64%.
Descriptor/name inspection accounts for about 49% of ray sampled allocation.
List 512 instead has similar generic dispatch shares before/after Phase37 and
no new region-entry calls. Its +4.65% timing regression cannot be attributed
to direct new guard execution. These are different optimization problems.

## Candidate probes, gains and complexity

| Proposal | Scoped incremental gain hypothesis | Complexity / risk | First discriminator |
| --- | --- | --- | --- |
| J1: compile a minimal sufficient guard requirement set | 1.03–1.2× on guard-heavy numeric/ray calls | Medium–high; 3–7 days | Same worker, exact narrower guard proof, existing mutation controls |
| J2: known fixed-arity private calls visible to JIT | 1.1–2× on dispatch-heavy selected cases | Medium–high; 4–10 days | One direct worker with dynamic arguments, separate inlining trace |
| J3: bounded output/layout and allocation-shape ablations | 0.95–1.1× on affected small regressions | Low–medium; 1–3 days | Remove only unreachable generated fast branches; preserve live bodies |
| J4: VM-style cached guards or global JS object pools | No justified positive estimate | Very high semantic risk | Reject absent a complete write/lifetime interception design |

Ranges are low-confidence hypotheses for whole selected calls, not percentages
of sampled frames. They include possible null/regressing outcomes. J1/J2 overlap
the Flambda/worker proposals; do not multiply their benefits. Fast-path code
growth or slower compilation can outweigh runtime savings in the iteration loop.

J1 would derive requirements from admitted operations plus implicit runtime
behavior. An F32-free region may need fewer numeric hooks, but generic forcing
can still observe primitive prototypes. Native read/write dependencies, error
construction and callbacks must be represented too. Removing a check merely
because its name is absent from emitted arithmetic is unsound.

A one-time cached successful guard is not J1. Between calls, host code may replace
`G`, descriptor fields, prototypes, Math/Number hooks, or methods on the leaked
shared DataView. Bend has no VM invalidation hook for these writes. Wrapping
objects in proxies or freezing public objects changes observable behavior and
would need an independent ABI design, not a performance-only patch.

J2 first emits a direct private function with explicit scalar environment and
fixed arguments inside an existing proved region. Keep small helper boundaries
where profitable; blindly inlining whole recursive components can exceed JIT
budgets and increase parse/compile cost. The goal is to expose facts, not write
JavaScript syntax that is presumed always faster.

J3 isolates generated-code layout from semantics. Phase37 list's six reachable
bodies are identical, while its module grew 2.91% in bytes. That makes unused
branch removal a useful negative/control experiment. A timing change alone
would not prove which JIT heuristic caused it; preserve paired samples and
separate trace evidence. Do not reorder effects or change public export contents.

## Falsifiable workflow and correctness obligations

The first diagnostic is a bounded VM trace of optimization, deoptimization and
inlining for one numeric, list or ray module, using options supported by the
pinned Node build. Save logs separately from clean timings; tracing may perturb
behavior and produce large files. A 20-second screen and 60-second paired
confirmation are sufficient initial decisions, with serialized memory-bounded
runs. A second engine is a later transfer check, not a prerequisite for a probe.

J1 must show fewer inspections with identical event traces for prototype/own
DataView mutations, restoration then instance mutation, same-vector getter
reentry, native replacement, first errors and proof cleanup. Stop at the first
missing callback even if checksums match. Reuse the final Phase37 owner controls
and add a witness that each supposedly unnecessary check is actually excluded
by the new proof, not just absent from a small fixture.

J2 requires full and partial application, dynamic captures, overapplication and
shared/frozen data controls. Preserve `build`/`force` demand order and alias
observations. Deep recursion must remain a loop, trampoline or explicit stack;
the JS engine's optimizer is not a portable tail-call guarantee. Any allocation
sink must remain per invocation and restore state across exceptions/reentry.

Stop if the proposed JIT site is already optimized as intended, allocation or
dispatch does not decrease, guard replacement needs global invalidation machinery,
or the timing gain disappears across fresh-process rounds. Measure checked
compilation and module size before promotion. Profile percentages alone never
admit a change. Freeze a surviving compiler before fresh holdout measurements.

## Simplicity and conformance impact

Specializing existing guard requirements or known calls can consolidate repeated
logic if represented once in the existing plan. Adding engine-specific runtime
epochs, shape registries and manual deoptimization would create several new
concepts and duplicate the host VM. Prefer stable ordinary JavaScript and use VM
traces diagnostically. These proposals do not extend language conformance;
they must preserve its current evidence and improve an actual measured path.
