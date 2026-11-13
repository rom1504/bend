Recursive source transport, revision 3
=====================================

The v2 memory change allowed `one`, `two`, `tree` and `ready` to finish both
routes under the existing guard. The next `sharing` input failed parsing:
the ordinary `+shared` local binding had been placed inside the `do IO` block.
That is a fixture-source error, not an emitted-program mismatch. The original
driver, metadata and invalid source remain retained as evidence.

`recursive-controls-sharing-v2.bend` moves that binding immediately before
the `do IO` block. The recursion, input values, sharing behavior and all four
independent output lines are unchanged. `recursive-controls-v2.json` pins
the corrected sharing source and retains all five other source identities
and the original independent oracle identity.

`recursive-source-controls-v3.mjs` retains the v2 garbage-collection lifetime
boundary and host-RSS observations. It adds:

- `--metadata PATH`, defaulting to `recursive-controls-v2.json`.
- `--cases all` (default) or a unique comma-separated subset of known IDs.

For the short remaining gate, use `--cases sharing,fallback`. The report lists
the entire six-case catalog separately from `selectedCases`, records whether
the full catalog was selected, and marks completion for that selection only.
All catalog source pins are verified even when a subset executes. No previous
completed case is silently reused or relabeled as part of the new execution.

The corrected source had not been executed when authored. Static inspection
of the other five fixtures found no ordinary local binding inside a `do` block;
the fallback fixture contains only IO binding actions and its final IO action.
