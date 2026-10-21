# P115-002: frozen policy selection and independent execution

Before native-policy timing, use the existing Phase11245 evaluator, unmodified
sources, output oracles, 50ms profile, toolchain and cached Phase114 runtime.
Phase115 adds an explicit source/product authentication adapter for its new
replay producer; it does not pretend these receipts came from the older emitter.
Every distinct QBE product per case is built by unchanged Phase111 build.py.
Identical products share that actual build with a recorded alias. Bind all four
policy roles to the original measurement runner; three rotated rounds, six cases,
upstream comparator. Do not alter thresholds or tune repetition counts.

Two deterministic selection rules, training cases only:

- Compilation-first: eligible policies must emit byte-identical complete QBE to
  policy0 on all three training inputs. Choose minimum sum of median legacy
  emission seconds, accepting only >=10% less time than policy0. Evaluate the
  selected policy's exact-output and cost conditions on the three other inputs.
- Program-first: choose minimum training geometric-mean runtime relative to
  policy0, accepting only >=3% reduction and no training case >3% slower.
  Otherwise retain policy0. Inspect evaluation outcomes without reselection.

Policy choices can be deduplicated by exact product identity. Repeated rounds
are observations, not new discoveries; four configurations need not yield four
different programs. These simple rules test bounded policy selection, not a
learned optimizer. Charge alternative preparation and validation/build costs
when reporting research capacity. No actual wall-budgeted search or sustained
recursive acceleration is claimed from replay timing.

A first adapter version used the historical array renderer instead of the
qualified source 02 renderer; local-pair's policy0 comparison rejected it before
machine execution. The correction calls exact p113ah_private_chunks. Source03,
API03 and a new manifest/replay version preserve the original source, policy and
oracle definitions. Failed and earlier matched runs remain separate evidence.
