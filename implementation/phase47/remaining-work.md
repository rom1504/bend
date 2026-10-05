# What this phase does not solve

Phase47 applies a private representation contract to a proved closed Array<U32>
region. It does not make arbitrary arrays unboxed, accept external backing stores,
remove public mutation behavior, or admit every higher-order graph. Results and
release status belong to the main phase report.

The next array question is **boxing once at a proved fresh result boundary**.
Generic row returns a composite public result and is deliberately refused today.
If every array originates inside a closed region and no callback can observe it,
a future implementation could keep raw storage internally and reconstruct public
handles at return. This needs an explicit result-layout and alias-preservation
proof: repeated references to the same array must share the correct public
identity, and conversion must preserve demand, errors, tags and storage shape.
It is a research proposal, not a validated optimization or a speed estimate.
Start with saved-output ablations and renamed result/alias counterexamples.

Shared private component emission is the other immediate size opportunity.
This first implementation retains old and raw helper closures together, preserving
the exact fallback. Removing duplicated helpers requires a representation-aware
call graph and proof that a helper is only emitted in the context which can
reach it. Do not replace this with mutable global emission state or weaken the
fallback to save lines. Measure startup and compile cost as well as runtime.

The worker cleanup study exposed small helpers but did not remove their aggregate
shells on the actual Map/record graphs. Before reintroducing an inliner, demonstrate
one real producer/projection chain which the existing passes and V8 fail to
eliminate, then test a bounded immutable value/use fact at that consumer. The
405-line experimental implementation remains available; preserving it does not
justify shipping it.

The compiler proof census supports studying request-local facts, but the exact
raw-identity memo counterfactual only saved 6.64% on one lexer request despite
roughly 51% repeated queries. A Bend implementation must pay for keys, misses,
lifetime and retained memory. It should beat the measured diagnostic cost before
it is combined with further backend work. Full self-emission is still a slow
integration gate, not the routine optimization loop.
