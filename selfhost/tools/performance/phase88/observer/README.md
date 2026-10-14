# Observer continuation controls

The current source replaces shared host closures with eight Data continuation
constructors. `controls.bend` exercises all eight shapes and returns 17 complete
`NO_Analysis` records, including every body node, fresh counter, fuel and error.
Synthetic compiler-owned terms isolate the mechanism; they do not replace checks
on actual source programs or confer a production ownership permission.

The cases cover literal/application/let/constructor evaluation, virtual and
symbolic matches, primitive statement prefixes, running both symbolic branches
with the correct allocation order, first-error short-circuiting, exhausted fuel,
fresh limits, Efq bypass, and accepting a tail recurrence while rejecting work
after its result. `compare-output.py` requires exact full output identity and
independently checks intended body tags, refusals and selected counter boundaries.
Equality between uniformly failing cases is insufficient.

The Phase88 [retained comparison](../../../../build/phase88/observer-controls.json)
passes all 17 cases: old raw JS, new raw JS and new native output match exactly
(3,638 bytes, SHA256 `6f83df8ea27f22276803811b5ce9c2a1edfb812a536abb01dd630bc7b072eb27`).
The independent counter/error/tail assertions pass as well. These are component
correctness controls; full-compiler native admission remains a separate gate.

Root runs all compilers/builds/targets serially under the resource guard:

1. Generate an old-interface entry with
   `python3 -B selfhost/tools/performance/phase88/observer/baseline-entry.py FRESH.bend`.
   The script changes exactly three representation adapters to old lambdas and
   records both hashes. Assemble it with the frozen old observer module at
   `selfhost/build/phase88/baseline/observer-analysis.bend`; fully check and emit
   **JS only**. The old observer's unsupported native closure sharing is already
   established by Phase87 and is not repaired in that control.
2. Assemble current `controls.bend` with the current manifest; fully check and emit
   raw JS plus C with the Phase88 acquisition helper. Run raw JS unchanged, then
   build C with pinned Clang22/O2 and run `--threads 1 --gpu off`.
3. Preserve each stdout/stderr/guard receipt, then run
   `python3 -B selfhost/tools/performance/phase88/observer/compare-output.py OLD_JS_STDOUT NEW_JS_STDOUT NEW_NATIVE_STDOUT NEW_REPORT.json`.
   This final command only reads output; it does not execute compiler code.

Keep other source bytes equal between old/new component assemblies to attribute
the comparison to this observer repair. Existing native text-builder edits may be
present in both. Do not claim the whole native compiler is fixed from these
products: next verify full Map compilation, complete C identity against ordinary
B2 and selected existing observer refusal fixtures. No installed image is changed
by these controls. Performance and conformance outcomes belong in the phase report.
