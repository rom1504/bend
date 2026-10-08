# Native value lowering and the short optimization loop

This guide describes the **Phase68 working09 development checkpoint**. The
installed default is still Phase67; these source changes do not themselves
promote a release. Use the [Phase68 report](../../implementation/phase68/README.md)
for qualification and the [Phase67 report](../../implementation/phase67/README.md)
for the installed compiler. The native compiler remains implemented in Bend.

## Shared call facts, separate backends

[Common arity queries](../../selfhost/src/back/common/arity.bend) determine how
many source arguments a definition can accept directly, including leading
lambdas shared by every matcher arm. The type telescope caps that number;
erased arguments then disappear from the runtime slot count. Both JavaScript
and native C query the original typed book, before native erasure can remove
constructor fields needed to interpret a matcher. The historical `jd_` names
remain, but this module emits neither JavaScript nor C.

[Native direct calls](../../selfhost/src/back/native/direct.bend) use these
facts for exact saturation and entry adapters. Partial, dynamic and bang calls
retain their general calling paths. Native ownership and representations stay
backend-local; sharing arity facts does not make the JavaScript IR a native IR.

## Values and destinations

[Value lowering](../../selfhost/src/back/native/bridge.bend) consumes
`N_Emitted { code, value, fresh }`: ordered C statements, a result expression
and the next fresh identifier. Variables and numeric words need no continuation
frame. Exactly saturated native Base primitives and constructors can produce
a local result in the same frame. Their arguments are staged left to right;
the existing `term_keep`/`term_sink` operations remain in environment order.
User overrides and malformed unbound variables keep the fallback behavior.

Allocating producers, including array operations, keep a scoped scratch block
so fixed C names such as `init`, `at` and `old` cannot collide. The producer
runs once even if its result is later dropped. The nonsequential error
checkpoint follows the result assignment. Numeric tags, boxed constructors,
array result pairs and the one-`Term`-word value ABI remain unchanged.

[Ordinary C workers](../../selfhost/src/back/native/flat.bend) reuse this
lowering through an explicit `NC_Target`:

| Destination | Generated control flow |
| --- | --- |
| `NC_Scheduler` | Existing continuation, task and return protocol. |
| Local `NC_Destination` | Assign a local result and jump to its join label. |
| Outer `NC_Destination` | Store a result through `Term* nf_out` and return success. |

An admitted worker calls another worker as an ordinary C function. Errors
propagate through the separate success result. Self-tail calls first stage
**all** argument words in temporaries, then update parameters and jump to the
worker's loop header; argument permutations therefore preserve their values.
The loop retains runtime error polling. A non-tail self call is ineligible.

## Admission and fallback

Worker admission is deliberately conservative. A candidate must lower without
an error or a generated scheduler segment. Every nonself dependency must be an
already admitted worker or an actual native Base intrinsic. Repeating this
monotone test admits an acyclic call graph, with self-tail loops handled locally.
Mutually recursive groups are not admitted as C recursion. Full-body dependency
collection can reject candidates that a more precise analysis would accept.

Foreign definitions, bang-reachable definitions, escaping closures or matchers,
parallel lets and unsupported applications keep the scheduler implementation.
Only admitted entry segments receive host adapters. The device branch retains
the original segment body, and the general scheduler and closure ABI remain
available. CPU tests of device-path checks do not establish GPU conformance.

Workers whose emitted body is at most **4,096 characters** request
`always_inline` from GCC/Clang. Larger bodies retain the ordinary inline macro.
This is a local source-size cutoff, **not a bound on transitive inlining or
generated machine-code growth**. C build time and output size must still be
measured.

## Compiler-side occurrence summaries

Native lowering also avoids repeatedly searching an entire term for each live
binding. `nc_uses` collects variable IDs into the existing 32-bit trie;
environment filtering, drops and sharing then query that summary. Keys preserve
the full `U32` ID. A variable remains a leaf, matching the previous traversal
even for malformed raw terms with children. Ordered environment traversal keeps
the original binding and ownership-operation order. This is a local lowering
analysis, not a new persistent whole-program cache or an ownership rewrite.

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
and overridden primitives, first diagnostics, argument permutations and
one/four-thread execution. New worker paths additionally need independent
outputs and fallback controls. Shared arity changes require frontend and
JavaScript coverage too; prior results cannot be reused merely because most
edits are native. Genuine B2 own-source checking and self-reproduction remain
separate integration gates.

The [Bend proof pilot](../../selfhost/proofs/phase67/README.md) models immediate
word transport and its finite composition. Both Bend checkers accept it, but
the independent kernel attempt is blocked by the available Lean version. It
does not prove the production emitter, reference counting, generated C or the
whole compiler.

Product flattening remains prospective for this checkpoint. The separate
product-v2 candidate requires its own qualification; ordinary C workers and
local prefixes alone do not remove boxed aggregate results. Closure traffic,
layouts and borrowing also remain opportunities. JavaScript program speed and
B1/B2 compilation latency have separate evidence; native runtime speedups do
not update those ratios.
