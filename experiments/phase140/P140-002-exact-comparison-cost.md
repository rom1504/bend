# P140-002: remove callback execution from exact reuse comparisons

2026-10-25, registered before candidate18 target execution.

## Observation

Candidate17 still uses the generic `p134v_list` comparator in successful-verifier,
registry and rendered-unit cache admission. Inspection of its actual generated
QBE finds curried comparator application and continuation frames for list
elements. Exact comparison is required, but callback allocation/application is
not required by that semantic contract. High cache hit counts do not measure
the cost of obtaining those hits.

## Hypothesis and bounded change

Private first-order Bend comparisons for known argument, value, statement,
binding and header lists can remove callback work while preserving every field,
constructor, comparison order and mismatch result. Candidate18 replaces only
the Phase140 adapters. Original comparisons remain available as the independent
reference; original final verifiers and optimizer policies remain unchanged.

This is not a physical-pointer equality shortcut, a probabilistic digest cache,
or permission to force native recursion. Existing stack-safe lowering applies.
The implementation remains Bend. Generic comparator specialization in the main
compiler is a possible later generalization, not part of this experiment.

## Gates and stopping rule

1. Check the composed source and run all existing finite controls plus the new
   differential constructor/nested-list controls. Preserve the rejected first
   control namespace collision and its correction.
2. Compare complete fresh and cached products for Lexer and Map, including
   malformed edit refusal and subsequent successful recovery.
3. Only after those gates, acquire one native image with qualified Phase137 N3.
   Inspect the generated typed comparison to see whether callback work actually
   disappeared. Run the existing four-revision small native batch.
4. Measure the same independently referenced full product-policy A→B edit.
   Count native stages, transport, acquisition and machine cost separately.
   If runtime barely changes, retain the negative result and profile the
   remaining work instead of adding more comparator variants.

No installed compiler change or full native qualification is authorized by a
speed observation alone. This final bounded experiment fits the existing
three-hour campaign; it does not restart the clock.
