# P77-004: library string kernels in the direct JS backend

The new profiles show String.starts_with's recursive SCC in hot paths. Direct
JS supports fewer native String operations than the legacy emitter, so B2 still
executes these Base routines character by character. Prototype exact private
B2 replacements first; measure clean exact-C requests before changing production.
This image derivative is an experiment, not a self-emitted compiler release.

Native JS startsWith/indexOf must respect Unicode code-point boundaries: a lone
surrogate needle must not match half an astral character. Compare all short
strings over ASCII, high/low surrogates and non-BMP characters with an independent
code-point oracle and the original compiled Base functions. Same-named user
functions and arbitrary/custom Base definitions must retain their bodies.

If the gain survives a fresh-request comparison, implement selection/templates
in Bend's direct backend and helpers in its ordinary primitive runtime. Preserve
B1, regenerate genuine B2/B3, validate the complete C artifacts, and run public
JS semantic controls. Reuse the native-source qualification if the native
closure and every timed C artifact remain exact; do not rerun unrelated slow
native tests just because JS string kernels changed.

## Decision

Defer. Four derived-image replacements pass128,524 independent controls and9 exact C requests but improve cold requests only2–3%. This is not a self-emitted compiler image; no JS backend intrinsic change was shipped. See the [completed report](../../implementation/phase77/README.md).
