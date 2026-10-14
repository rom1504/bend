# P89-002: consume intermediate native compiler results once

Status: source audit. Map physical profile attributes11.58% of request samples
to destroying retained child code bodies after parent composition;30.68% is
append plus direct ownership. Hypothesis: destructuring NC_Code once reduces
retention/copy/drop work without changing any field/order. Full product controls
precede full C, cold/warm timings and broad gates. Budgets are not additive
promised gains. A chunk representation is a separate escalation only if this
small prototype leaves a demonstrated larger copy cost.
[Design](../../design/phase89/bun-and-native-output.md).
