# Phase194 — stable values and diagnostic experiments for x86 runtime

Start: 2026-11-14 00:09 UTC, baseline ad9b27d. User budget1–2hours.
Compiled-program runtime is the primary performance objective; source checking,
ownership/ABI correctness, compiler latency, code growth and bounded resources
remain constraints. Installed Phase189 and qualified Phase193 N2 remain intact.

## Evidence and ambition

Final Phase193 direct objects take2.117890×mature Bend C; fresh QBE1.349626×.
Matching QBE would reduce x86 time36%, but is not guaranteed or sufficient for C
parity. Large machine differences remain in editdist/local-pair and ray variants;
Map/tree also have shared semantic/representation costs. Prior profiles and
machine witnesses are leads, not final removable-time budgets.

1×: build six paired ordinary-Bend diagnostics and test one bounded missing value
or predicate capability; admit only a measured runtime improvement with transfer.
10×: share definition/use information across selection and F32 placement so
several existing optimizations compose and an old scan can eventually disappear.
100×: preserve whole private computations and virtual products through placement,
removing representation/allocation/scheduler work. This run tests prerequisites;
no global SSA rewrite, backend switch or promised multiplicative speedup.

## First competing experiments

- Definition-versioned closed F32 values: the current numeric worker still has
  three adjacent XMM→GPR→XMM transfers. Distinguish overwritten definitions within
  an explicitly bounded pure region before physical placement. Read operands
  before rebinding. Preserve every externally observed full-word value, calls,
  branches, backedges, NaNs and fallback. Reject if only syntax changes.
- Predicate-to-select composition: actual Phase193 local-pair/editdist workers
  retain compare→Boolean→test→conditional-move windows. Reuse existing pure-arm
  certification and preserve exact operand definitions, widths and overwrite
  semantics. Do not move effects or infer machine flags from a stale Boolean.
- Six paired diagnostic families: value identity, register pressure, mixed
  numeric representation, predicates, ownership/products and memory traversal.
  Independent expected values, useful complete computations, two sizes and an
  explicit statement of what each variation changes. Native45 stays immutable.

## Fast ladder and time allocation

First20minutes: source/machine falsifiers, diagnostic sources, independent
oracles, experimental Bend modules and exact resource/retention preparation.
Next25–35minutes: checked hosted APIs, finite machine/admission controls,
small ordinary-program and diagnostic off/on screens. Select based on actual
removed work and runtime, not instruction counts alone. Preserve failures.
Final25–45minutes: one selected integration, broad runtime/heldout gate,
independent source checks and justified native qualification. Reserve a final
report/commit/push window. Stop weak directions rather than fill the budget with
another framework. No full self-build merely to test an early candidate.

Use Astra High agents only for independent bounded implementation/audit and
fixture tasks; root owns integration and the single CPU3 target lane. Every job
uses the maintained guard/retention close,5GiB disk reserve and explicit budgets.
Do not edit immutable evidence, benchmark definitions or independent oracles.

## Admission and reporting

Preserve the original final verifier. Controls cover integer widths, old-value
snapshots, aliasing, mixed F32/raw-word use, branches/calls/loop state, overflow,
NaN boundaries and reserved-name/fallback behavior as applicable. Finite controls
are not mathematical proofs. No new whole-compiler theorem is claimed.

Freeze source and the10development/35heldout split before measurement. Diagnose
preselection and selected instructions on actual hot owners, compare fresh
baseline/candidate/C/QBE medians with balanced order, retain dispersion and every
regression. Report full geometric ratio, positive-log deficit, family weighting,
threshold counts and compiler/source costs. Diagnostic scores stay separate.

A successful small experiment earns the larger gate. A failed architectural
hypothesis still yields reproducible probes and a precise next decision, with
no unqualified production selection. Commit design and completed evidence;
never post to the upstream PR without explicit authorization.
