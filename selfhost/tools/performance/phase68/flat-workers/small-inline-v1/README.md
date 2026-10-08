# Small-worker inline hint, source proposal

Registered as P68-010. `small-inline-v1.patch` changes only worker declaration
formatting in native/flat.bend, adding one shared `nf_inline` decision. Baseline
and candidate are exact copies around the applied pure admission short-circuit
frontier. `git apply --check` passed; no compiler or generated target was run by
this lane.

The sole cutoff is `String.length(nc_body(code)) <= 4096n`. This is a local
generated-source cost heuristic, not a transitive or whole-program size bound.
The declaration name, function envelope, and prototype are not counted. The
same helper governs prototype and definition. `NF_INLINE` has the GNU/Clang
always_inline attribute only under those compiler macros, otherwise falls back
to ordinary INLINE. It is defined inside the host-only worker block and removed
after the worker declarations; runtime and device text are unchanged.

The 4096-character round budget selects 12/14 numeric workers and 15/17 array
workers in exact flat06 C. Array cell1513, step2039, loop2320, and bench1918 all
fit; numeric recurrence3664 fits. p46.loop4401/4407 and Nat.read.trim265696 stay
with the normal C inliner. These names explain the inventory and do not occur
in the policy. `inventory-and-object-audit.json` records all workers and confirms
that the prior broad-force-inline binaries contain no NF symbols or call targets.
The bounded policy itself remains unexecuted.

Use this directory's `check-workers.py` for emitted structure. Its only change
from the existing gate is recognizing both INLINE and NF_INLINE function
definitions. The prior checker would miss the explicitly hinted functions.
Product workers should use the same formatting helper, subject to their own
admission and result-layout proof.
