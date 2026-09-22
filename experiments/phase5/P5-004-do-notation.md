# P5-004 — Empty do parameters and statement validation

- Owner: root; independent reviewer: assigned after focused candidate gate.
- Started: 2026-09-22 21:47 UTC; initial timebox: 30 minutes.
- Correctness: investigation; no candidate result yet.
- Measurement: none; correctness work runs on CPU0 alongside independent jobs.
- Decision: investigate.

The current frontend inventory's `check/do_missing_bind.bend` fails parsing in
Bend but reaches the missing `Box.bind` checker error in pinned TypeScript.
Inspection finds two related mechanisms: the lexer emits adjacent `<>` as one
token while `f_do_start` assumes a separate `<`; and `f_do_tail` always inserts
the last monad type even when the parameter list is empty. Upstream explicitly
omits that result argument for `do M<>:`. The annotation path also consumes a
token without first requiring `=` or `<-`, which may accept malformed syntax.

Hypothesis: respecting the empty/nonempty type-list distinction, validating the
statement separator, and preserving the originating statement position repairs
this grammar path without changing nonempty do behavior or checking rules.

First falsifier: live pinned TypeScript versus the genuine unmodified Phase4
development API on empty adjacent/spaced arguments, nonempty arguments, pure
bindings, return/final values, malformed separators and missing bind/pure.
Keep reference disagreements with proposed oracles explicit. Use an isolated
checked source candidate and retain exact observations, including diagnostics.
Then run applicable positive upstream do fixtures and small JS execution probes.

The broad mismatch inventory is unchanged by triage alone. No fixture oracle is
rewritten and no generic rejection is labeled a successful checker test.
Evidence will be retained under `implementation/phase5/` with actual artifact
and source identities. Initial local attempts use `selfhost/build/phase5/do/`.
