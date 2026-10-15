# Independent Phase98 challenges

[manifest.json](manifest.json) freezes five source-reasoned semantic faults and
two equivalent changes at 20:13:56 UTC on 2026-10-15. Its SHA-256 is
`e833a5dacf7ff2f6a1cd0643199b052067f39d5ce81d795308ac487a641c8cef`.
No Phase98 law bodies, finite cases, oracles, candidate implementations or outcomes
were inspected before this freeze. Prior Phase96/97 work and the broad task were
known, so this is independent selection rather than rigorous blinding.

Each recipe records a unique exact source edit, original/full changed hashes,
its rationale and a typed witness containing complete expected values. Each of
the initial seven edits also occurs exactly once in authenticated D04. Apply recipes
individually to isolated source copies; never edit production to run them.
Witness files are fragments requiring the exact helper dependency closure.

The later [literal supplement](literal-manifest01.json) freezes one additional
fault selected from the new recognizer's helper-only source, before inspecting
its tests or laws. A [second supplement](candidate-manifest02.json) adds two
source-selected faults in the new dispatch and held-observation helpers. The
[aggregate manifest](all-manifest01.json), frozen at 20:19:28 UTC, contains eight
bad changes and two equivalent controls. Its SHA-256 is
`7c6d0d7195b6acce4cbc03ed0da6e1df5ca7c19aebbd989208d3fe491ee5385d`.
Only after this final freeze did the reviewer inspect the new laws and controls.
Admission remains to be established by root-owned targets.

Run frozen laws and existing finite tests unchanged first. Record proof-only,
finite-only, both, neither, admission failures and absent dependencies separately.
Only then use these source-derived witnesses for targeted follow-ups. A malformed
or unextracted helper is not a semantic detection; an amended recipe is a new
attempt. Do not report statistical mutation coverage from this small chosen set.

`freeze.py` stopped after five recipes because an equivalent control's short span
was not unique. [preparation01.json](preparation01.json) preserves that data-only
failure. `freeze-v2.py` scopes that control to its complete function, verifies the
five existing recipes/witnesses unchanged and creates the manifest. No compiler
or program target ran during either preparation. Do not rerun a frozen producer
over its outputs. The other two producers create only their separate supplements.
An unmatched parenthesis prevented the first candidate-supplement producer from
running; its exact failed bytes remain in `freeze-candidates02-invalid.py.txt`.

`../challenge-prepare.py` prepares existing production/string/held/literal suites
or a separately labeled targeted follow-up. `../challenge-run.py` reuses the
unchanged Phase97 JS executor and guarded checker. Its `--proof-plan` mode
distinguishes mandatory semantic rejection from proof maintenance on an equivalent
change and requires the repaired proof's full independent kernel check. Exact
derivation diffs and dependencies are in `../challenge-derivation.json`.

These challenges concern finite values and comparison behavior. They do not
establish native memory ownership, reference-count correctness, alias lifetime,
allocation counts or program speed. See the
[review](../../../../../implementation/phase98/review.md) for evidence boundaries.
