# SCC fixture correction

The first campaign accepted five real source fixtures, with 33 exact runtime
observations. `scc-alias.bend` failed source checking because it used an unfilled
ordinary law in live code. This was an invalid fixture, not a JDPlan mismatch;
its original source, catalog, runner and failed receipt remain unchanged.

`scc-alias-v2.bend` uses the established `@unsafe` mutual-definition convention
from Phase58's `shared-scc-v1.bend`, retaining the same dependent alias, unequal
live arities and four independent expected values. As usual, type acceptance is
not a kernel proof of unsafe recursive definitions.

Root runs the same guarded command with `run-v2.mjs` and a new output directory.
Its one-case catalog requires four values under each of old pruned context,
fresh canonical context and saved plan, for 12 executions. It retains all alias
removal, lookup-difference, call-fact, SCC, bounce and full-byte comparisons.
`v2-derivation.json` binds the original and corrected inputs and records the
mechanical runner changes. No result is claimed before execution.
