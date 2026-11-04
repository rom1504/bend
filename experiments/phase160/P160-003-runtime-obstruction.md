# P160-003 — distinguish runtime obstruction from compiler-work complexity

Current56ed bendc reproduces its own4.628MB C in16.974s unchecked/39.728s checked.
The same executable cannot finish our1.563MB request closure in180s checked or
120s unchecked. Its emitter-parser AST route finishes in1.014s; checker parse-only
is a different path and takes10.7s. Source shape/remaining transforms and runtime
costs, not just source bytes or source checking, therefore need investigation.

Phase159's exact GC search bound is already an audited one-change diagnostic.
Apply it to the unchanged current seed C, same-O2 flags, and require exact self-C
before rerunning our closure. This is an enabling experiment, not a claim of
improving our compiler. If it does not unlock the comparison, do not repeatedly
extend timeouts; use a complete smaller stage or diagnose an explicit optimizer
policy with retained output and separate correctness gates.
