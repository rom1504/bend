# Stack repair V2 syntax correction

The root's `p118-safe-api01` check rejected V1 before target execution: Bend
requires match scrutinees to be parameters/pattern binders, whereas V1 matched
locally computed `projected`, `workers`, and `ok` values. The failed source and
receipt remain unchanged.

`native-stack-safe-v2.bend` uses existing `p113d_body/error` accessors plus two
ordinary parameter-matching worker accessors. The worker loop carries validity
and error explicitly, matches its validity parameter first, and directly
self-tail-calls with the next state. No compiler policy or runtime behavior is
intentionally changed. The first-error state returns before evaluating another
observer plan. The unchanged controls apply to V2.

Root must still check the revised source, confirm hosted loops, run finite and
large-catalogue controls, compare exact ordinary fixture output, and qualify
native acquisition. No success is claimed by this source-only correction.
