# P165-001 — native checker boundaries explain part of the source gap

Hypothesis: a substantial part of bendc's speed comes from source-selected native
memo/traversal primitives, beyond differences visible in its Bend algorithms.
Rename only the relevant checker calls/definitions to activate independently
audited portable implementations; keep acquisition and execution policy fixed.

Falsify a performance attribution if a knob changes no reached generated call,
semantic controls differ, checking runs out of fuel, the input/checked work differs,
or runtime policy changes. A failed no-memo comparison may demonstrate a necessary
algorithmic capability but cannot quantify a successful checker speed ratio.
Keep failures and acquire no broad successor compiler merely to chase a clock.

Follow the Phase165 design. Source replacement and portable/native lookup policy
must be orthogonal. The existing producer's intrinsics remain untouched while
compiling the experimental source; only the resulting checker is the subject.
