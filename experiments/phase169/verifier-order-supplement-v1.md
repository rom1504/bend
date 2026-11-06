# Supplemental verifier error precedence

Preparation only; no target execution in this lane. The already checked/acquired
candidate and its 116 controls are untouched. This adds six pure finite controls
from the exact frozen `bb75f86c…` API source plus
`selfhost/tests/phase169/verifier-order-controls-v1.bend`.

Each observation returns the original generic/static/adapter error, original
full private error, full public-view error, actual candidate refusal, and an
empty-output marker. Both Bend controls and a separate host harness compare
these with literal expected messages. The real maintained projectors/verifiers
produce all errors; no invalid machine body is executed.

| Case | Distinguishing expected result |
| --- | --- |
| Earlier public ABI error, later original body error | View reports ABI; cold fallback returns the original body error/prefix. |
| Earlier body error, later borrowed-projection error | Complete projection precedes body verification; projection error wins in both forms. |
| Earlier public ABI error, later borrowed-projection error | Projection error still wins before either per-function ABI/body traversal. |
| Private valid, view ABI invalid | Original succeeds; candidate returns the existing view-error prefix. |
| Original worker already public | Original private predicate refuses before a flag-only view can reset it. |
| Forward call to later public callee | Same unknown/cyclic-call refusal; changing the callee flag does not grant dependency readiness. |

The incompatible public views are deliberately injected at the private checked
handoff to exercise cold fallback. Normal authenticated adapter production cannot
produce those ABI mismatches. These cases test the handoff's error behavior,
not permission to bypass its generic/adapter preconditions. All original generic
gates are separately observed to return the expected empty error on these fixtures.

Prepared snapshot: `selfhost/build/phase169/verifier-order-source01/compiler.bend`,
1,519,667 bytes / SHA256
`6af126bb452947bce452001e36e5e1f26f2bc08fa0f86d2e4ca39bd2c8fdd46b`.
The source extractor preserves parent declaration bytes, introduces no overrides,
and exports only `p169svo_rows` and `p169svo_controls`. The renderer dependency
closure remains present because the actual candidate success/failure handoff is
tested; it is not replaced by a smaller surrogate implementation.

Root acquires that source with the normal checked API builder, then executes
this payload under its existing CPU3/resource guard:

```sh
selfhost/.assets/bin/bun experiments/phase169/tools/verifier-order-controls-v1.mjs CHECKED_API_REPORT selfhost/build/phase169/verifier-order-source01/manifest.json FRESH_OUT
```

Native-entry compatibility remains unchanged: `native-entry.bend` receives six
strings `[label, absoluteSource, absoluteBase, live|cache, carrier, stamp]`, exactly
the existing `qbe-source-v1` request command after runtime flags and `--`.
The label is consumed but does not select an algorithm, so the builder's existing
`phase111` label remains compatible. The cache/live preparers, one-File streaming
writer, stdout/error contract and runtime flags are unchanged by single
verification. Bind the new image to its own recorded source and output-stage
receipt; do not relabel it as the installed qualified N2. This private CLI still
excludes session/batch commands, and these finite controls do not qualify them.
