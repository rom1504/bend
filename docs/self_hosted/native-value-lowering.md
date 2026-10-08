# Native value lowering and the short optimization loop

The native backend remains implemented in Bend. Phase67 changes two files:
`selfhost/src/back/native/bridge.bend` and `direct.bend`. It keeps the existing
word representation, runtime, ownership protocol and scheduler ABI.

Previously every let binding created a continuation, even when its value was
already a variable or numeric word. The new rule binds such a value directly
to a C local and lowers the body in the same ordered live environment. Sharing
and dropping still use the existing ownership operations. An unbound variable
retains the original diagnostic path. The shared device path retains its error
checkpoint; the CPU diagnostic test simulates that observation and does not
claim physical GPU validation.

Exactly saturated scalar primitives from the actual native Base definitions
also use their existing C intrinsic expressions directly. Arguments are bound
left to right before the operation. User overrides, foreign definitions,
partial applications, bang calls, array operations and allocating F32 read/show
keep their existing paths. Numeric comparison results retain constructor tags.
There are no benchmark-name recognizers or host implementations of compiler
algorithms in this change.

## Measure separate costs

The [native loop](../../selfhost/tools/performance/phase67/benchmark/README.md)
retains six families: numeric recurrence, mutable arrays, closures, recursive
trees, Map operations and lexing. They are diagnostic coverage, not a universal
workload distribution. Independent Python oracles check output digests.

Acquisition emits checked C and builds it once with the same pinned Clang and
flags for both compiler roles. Emission, C build and executable runtime are
separate clocks. Runtime iteration reuses those executables; it does not rebuild
the compiler or C on every observation. A new compiler-source candidate still
needs a checked image and new native acquisition before its runtime can be
compared.

Use the Bend-only short plan for routine candidate comparison. It targets about
200 milliseconds per family, with a separate short warmup and two rounds.
Keep the identical work counts and output expectations for baseline and
candidate. Use the longer TypeScript-resolved plans periodically to anchor the
remaining gap: an array interval long enough to resolve upstream's clock can
take many seconds in the selfhosted output. That cost is unnecessary for every
Bend-versus-Bend edit. The report records actual loop duration and clock gates.

Freeze an explicit immutable checked API for experiments. A recipe that verifies
the installed release is appropriate before source edits; its verification
correctly fails after those source files change. Switching to a frozen old
image requires a new recipe and byte-identity receipt, not relabelling a failed
release check as a pass. Prior raw outputs remain immutable.

## Correctness and remaining scope

Focused native controls cover sharing, reclamation, numeric boundaries, partial
and overridden primitives, first diagnostics, and one/four-thread execution.
The unchanged frontend/JavaScript executable closure permits scoped reuse of
their prior finite conformance results. Genuine B2 own-source checking and
self-reproduction remain separate integration gates.

The [Bend proof pilot](../../selfhost/proofs/phase67/README.md) models immediate
word transport and its finite composition. Both Bend checkers accept it, but
the independent kernel attempt is blocked by the available Lean version. It
does not prove the production emitter, reference counting, generated C or the
whole compiler.

Read the [Phase67 report](../../implementation/phase67/README.md) for measured
gains, image identities, qualification and release status. General boxed
constructors, closure traffic, flat layouts and borrowing remain major native
performance opportunities. JavaScript program speed and B1/B2 compilation
latency have separate evidence; native speedups do not update those ratios.
