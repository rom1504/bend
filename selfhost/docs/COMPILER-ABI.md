# Compiler host ABI

The upstream bootstrap API returns JavaScript objects with named ADT fields.
The self-emitted API uses positional fields (`{$: tag, a: fields}`). The host
adapter in `tools/compiler-abi.mjs` exposes named fields without copying entire
compiler graphs at each phase boundary.

`createCompilerAbi({fields, ctor}).wrap(module.default)` creates the adapter.
`decode` creates a lazy, read-only view of a positional value. Reading a child
creates its view on demand; shared children retain identity. `encode` unwraps
these views to the exact original objects in constant time. New host-created
inputs are converted iteratively, preserving cycles and sharing. They are
converted afresh on each call so host changes remain visible. Array reads,
iteration, named-field enumeration, object spread, and `JSON.stringify` are
supported. Compiler views cannot be mutated.

Optional `onPhase({name, phase, stats})` observes `encode`, `invoke`, `decode`,
and `return` boundaries. `stats()` reports view allocations, host input objects
encoded, views unwrapped, and API calls. This instrumentation distinguishes
compiler work from host conversion without changing Bend semantics.

Run the focused tests from the project directory:

```sh
npm run test:abi
```

For the integration gate, point to an existing **self-emitted** compiler module
(one exporting `G`), not the upstream bootstrap API:

```sh
BEND_COMPILER_ABI_MODULE=/absolute/path/to/stage2.mjs npm run test:abi
```

This additionally parses, loads, checks, specializes, selects, annotates,
validates layouts, and emits a small source module. All ten API results are
compared against the former eager converter on the same compiler. No upstream
compiler or full self-rebuild is invoked. The test prints the compiler hash,
emitted code hash, and allocation counters.

`tests/conformance/compiler-abi-lazy.json` records the initial gate against
compiler `68585dc`. A 100,000-node handoff requires one view and zero copied
nodes. The real annotation call copies only its argument vector. This addresses
the confirmed `JSWeakCollection::Set` failure in the former eager conversion;
it does not by itself establish a completed self-hosting fixed point or bound
the memory required by the compiler's own annotation algorithm.
