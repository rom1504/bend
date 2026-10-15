# P98-002: preserve string roots across comparison

Status: two implementations pass local correctness and native B1 timing gates;
native B2 qualification remains pending.

The D04 native host uses a consuming equality walker. Its generated C takes and
releases the two String constructors at every step. Upstream's existing borrowing
analysis can instead use reads when the inputs demonstrably remain alive across
the call. Preserve both roots explicitly, call the unchanged recursive walker,
then consume the roots once. This is safe Bend source; neither upstream nor the
runtime is patched.

The first full candidate is `selfhost/build/phase98/held-source01/compiler.bend`
(`81c017c8…`), ten lines larger than D04. Its preparation receipt replays the
single wrapper replacement exactly. A three-word observation carries the Bool
and both original strings. The control's actual upstream C flattens that result
without heap allocation; its walker has only reads, with no constructor take,
sink, spare release or retain. Full-compiler code shape still requires inspection.

The existing 38-string, 1,444-pair corpus passes in native execution with its
entire 85,349-byte output equal to the historical JS execution and independent
codepoint oracle. Shared and copied inputs are compared, then reused for length
and checksum observations. These finite tests do not prove arbitrary C lifetimes.

Five laws passed source checking, safe elaboration and independent BendTT:
two specify the original comparator and three connect the exact candidate walker,
full retained observation and public equality. All theorem bodies are nonopaque.
Independent bad implementations and a legitimate maintenance change remain to
be tested against the unchanged laws and finite cases.

The actual six-source compiler comparison used identical request assets and
Clang O2, four alternating rounds, exact complete C and diagnostics. The first
candidate takes0.85866× baseline request time and0.91831× process time. All48
outputs and diagnostics agree. This justifies broader qualification.

A smaller expression-order variant removes the observation datatype and passes
the roots to a finishing function after computing equality. It adds only3 lines,
passes the same1,444 native pairs and four independent laws, and measures
0.85619× request/0.91709× process time in its own48-request screen. The complete
observation datatype/law is retired with that helper; the public equality
statement remains byte-identical.

Stage boundary: a pure own-backend control enables borrowed observers and
passes1,444 pairs. A real IO.print_err control instead retains the full compiler's
conservative flags and still emits consuming traversal plus extra root keeps.
Its complete output is correct, but this rules out assuming the B1 gain transfers
to B2. A separately reviewed observer-permission split is being investigated;
there is no global flag override or new public native selection.
