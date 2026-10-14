# Consume native match products once

`candidate.patch` changes only ordinary match composition in
`src/back/native/bridge.bend`, adding 14 physical lines. Its baseline/candidate
copies and hashes are in `source.json`. It is an isolated source candidate;
production, upstream and installed images remain untouched by this lane.

Both root-run component gates now pass: the 19 join cases have identical raw
JS/native output, and all nine actual lowering products agree across old JS,
new JS and new native. See `selfhost/build/phase89/composition-control01-products.json`
and `lowering-products01.json`. Full-image speed remains unmeasured here.

The original code retains both complete child `NC_Code` values and repeatedly
projects body, segments, freshness, error and calls. The candidate consumes hit
once before lowering miss with hit's fresh counter, then consumes miss once.
Body/segment/call fields are affine inputs to the final constructor. Both arms
are still lowered, including miss after a hit error. First-error priority,
miss freshness, segment/call order, formatting and guard placement are retained.

Root runs all target commands serially under existing guards. Cheap gate:

1. `phase88/component.mjs composition/controls.bend NEW_BUILD` checks/emits the
   9.8 KB standalone fixture. It extracts the actual old expression, candidate
   final helper and real unchanged formatting functions; no stub formatting.
2. Run raw JS, build pinned O2 C and run `--threads 1 --gpu off`.
3. `python3 -B composition/compare-output.py composition/controls.json JS_STDOUT NATIVE_STDOUT NEW_REPORT.json`.

The 19 complete-product cases cover error priority, every special constructor
condition family, effect guards, segments/calls, empty/non-newline output and
nested child bodies. All original/candidate fields must agree; the checker also
independently asserts state, order, guard and marker presence. This fixture does
not run recursive child lowering. `make-controls.py NEW_CONTROL.bend` reproduces
the standalone source plus provenance; it is offline transport only.

The next, stronger component gate uses actual child lowering:

1. `assemble-controls.mjs baseline NEW_OLD.bend` and
   `assemble-controls.mjs candidate NEW_NEW.bend` assemble the manifest with the
   respective frozen bridge and `lowering-controls.bend`. This is source assembly
   only; each receipt freezes all participating modules.
2. Fully check both assemblies. Emit/run old raw JS and new raw JS/native. These
   small synthetic requests do not need the compiler IO entry or prepared Base.
3. `python3 -B composition/compare-lowering.py OLD_JS NEW_JS NEW_NATIVE NEW_REPORT.json`.

Nine actual-lowering cases require exact complete products, independent success
and refusal messages, field-count freshness, and advancing fresh counters/segments
across hit and miss closures. Synthetic core is a component boundary, not a new
user-language conformance claim. Full Map and a non-Map branch-heavy program must
then retain exact C before timing. Preserve current native equality/prepared-Base
adaptations identically in baseline and candidate; otherwise attribution changes.

Inspect generated native code before a full compiler build: the final helper
should consume body fields without retaining whole hit/miss records through
String.append and later projection. If the same ownership operations survive,
reject this source rearrangement early. The measured 11.58% body-drop bucket is
only a direct-site ceiling, not a promised speedup; append still copies left
strings at nested levels. A chunk representation remains a separate experiment.

`inspect-generated.py OLD_C NEW_C NEW_REPORT.json` records static continuation
site counts, source lines and exact hashes. The retained `generated-ownership.json`
shows the repeated child projection path is gone in the actual-lowering component:
SLOW_TO keep sites 63→36, sinks 5→1, field projections 8→0, append jumps 12→12.
These are not runtime counts or predicted gains.

`freeze-native.py NEW_NATIVE_COMPILER.bend` derives from the checked Phase88
native02 source by matching and replacing the exact slow-match definition and
inserting the two helpers. Existing equality adaptation is applied within those
definitions. Reversing the edit recovers every original parent byte. The frozen
`compiler-native-owned01.bend` and adjacent derivation receipt are ready for a
whole-source checked acquisition; no compiler ran in this offline step.
