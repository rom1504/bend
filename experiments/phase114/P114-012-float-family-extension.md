# P114-012: check local float lanes on other historical numeric programs

Recorded after the positive P114-011 screen and before these target executions.
The compiler is frozen float-lanes-source01; no optimizer changes are proposed.
The initial ray improves423→369ms versus the selected source, while local-pair
QBE is unchanged. This does not establish a broad result.

Use three additional original45 cases: `raytrace`, `symreg`, and `mandelbrot`.
They test another ray workload, recursive numerical evaluation, and a numerical
loop family. These are historical programs selected deliberately, not blind
holdouts. Keep the original complete outputs, repetition profile, three rotated
rounds and upstream/selected-source01 comparators. Do not change source algorithms
or counts to make the float pass apply. Lack of admission is a useful result.

Reuse the existing staged checked-source emission, machine build, product binder
and original45 measurement implementation. A source-only adapter narrows the
original planner's case list and changes output paths; it records the exact
original manifest and derived plans. No direct-native compiler or whole-corpus
claim follows. Stop on output failure; preserve all samples, including regressions.
