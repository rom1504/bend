# P78-003: consume annotation facts in checked layout validation

Hypothesis: the checked request reconstructs lambda/matcher goals and constructor
field telescopes after annotation has already computed those results. Retain each
constructor field's quantity on its private Ann wrapper and walk the annotated
children directly. Keep the public raw layout checker unchanged. Only an owned,
checked driver request that has just produced these annotations selects the new
entry. Constructor order, erased argument demand, Array element checks, intrinsic
references and runtime reachability remain unchanged.

Prototype acceptance: checked B1, exact C on the short screen, then differential
old/new layout outcomes on native and JS fixtures including open arrays, erased
fields, dependent constructors, aliases, incomplete raw terms and custom Base.
Measure fresh B1 separately; a ~5–9% request gain is the budget, not parity alone.
Do not promote without own-source/B2 and broader semantic qualification.
