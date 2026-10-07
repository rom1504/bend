# P63-005: retain arity already computed by call analysis

Registered before the production candidate is measured.

The genuine State06 B2 identity-memo diagnostic finds523 repeated queries among
756 Map arity calls, across three immutable contexts. Avoiding those queries
removes8,075 weak-head-normalization entries. A single prepared-cache Map worker
falls1443→1331ms; this is a diagnostic opportunity estimate, not selected speed.
General WNF memoization saves less and adds no clear benefit in combination.
Numeric's first original baseline accidentally performs cache preparation and is
excluded from timing comparisons. The V2 controller requires and pins a preferred
preexisting frame and blocks cache writes during the measured request.

The proposed Bend implementation reuses existing call-analysis work: retain
arity where ordinary definition rows already evaluate it, then carry an explicit
private fact through SCC grouping to the final per-name table. Do not eagerly
normalize new definitions, create a global mutable cache, or overload a source
KDef's semantic arity. Public jd_arity stays unchanged. Internal emission can use
a fact only in its freshly built owned context; absent/native/foreign/uncertain
cases retain the original query. Context rebuilding must replace old facts.

Fast falsifier: checked36 plus exact whole modules and context/SCC/bound tests;
compare a short ordinary owned-API screen. Reject if table lookup overhead erases
request gain. Only an improving candidate earns genuine-B2 and broad release
qualification. Retain exact fields/order/refusal behavior, zero arity, partial and
oversaturated applications, native and foreign cases, and raw alias contexts.
