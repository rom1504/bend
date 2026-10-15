# Frozen fork-candidate qualification methods

These copies admit only source `d8a94ce9…`, assembly `21a6140d…`, and its 13
explicit replacements against the frozen Phase89 ancestor. The original methods
for source `74b390d3…` remain unchanged. `derivation.json` records exact line
edits with byte offsets, original/output identities and the candidate assembly;
the existing `phase90/replay-native-methods.py` can reconstruct them offline.

Changes are limited to source/assembly pins, the expected replacement count,
relocated root/support paths and help text. The binder itself is byte-identical
and imports the adjacent fork-bound support module. All eight actual controls,
source inverse checks, nine effects, trusted cache identity, complete-C oracles,
before/after input checks and producer lineage requirements are preserved.

- `native-gates.py IMAGE FRESH_OUT [--self-source]` requires an actual checked
  upstream acquisition and guarded build. It emits a distinct immutable
  eight-control gate receipt before optional self-emission.
- `bind-own-native.py EMISSION BUILD_GUARD IMAGE` binds actual own-backend C
  emission and a completed Clang build without executing a target. It accepts
  only the original honest native-self or qualified JS-B2 producer chains.
- `own-native-gates.py IMAGE FRESH_OUT [--self-source]` executes the same eight
  controls for that honestly bound image. Cache/public admission and broader
  conformance remain separate.

Add `--check-only` to a gate command for input validation without target
execution. Preparation checked syntax, exact method replay and module root/pins;
new image/emission-dependent gates await the actual artifacts. No target was
executed by this preparation lane.

The existing `phase90/js-sibling/run.py` needs no change for this candidate.
Its source replay is generic, and the new source retains exactly the admitted
IO entry and carrier-decoder definitions. It will still require the actual
completed acquisition; an in-progress `emit-c` receipt is not admitted.
