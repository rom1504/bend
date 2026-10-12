# P75-001: select native host routes before lowering fallbacks

Hypothesis: some generic scheduler bodies are lowered only to be replaced by
admitted host workers and retained as device fallbacks. Preparing admission
first can avoid this work when a checked program has no device roots (no bangs).
Positive-arity workers keep their curried adapters. Raw and bang-containing
programs retain full generic lowering. Validate source-level permission and
generated differences, then native smoke, latency, broader runtime/conformance.
Fresh output paths only; no installed-image change before qualification.
