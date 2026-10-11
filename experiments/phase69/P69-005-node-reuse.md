# P69-005: cold constructor reconstruction with compatible storage reuse

Registered 2026-10-11 before preparation or target execution. This lane performs
source/data work only; root owns all native builds and measurements.

Hypothesis: the combination of constructor-level cold ownership, direct field
transport and reuse of consumed compatible allocations removes materially more
native tree work than P68-015's lexical spare-only (~3% tree gain) or P68-018's
runtime seal predicate (~8% tree gain). Neither earlier experiment is erased or
relabeled. The intended general mechanism is an owned constructor layout fact,
not detection of the benchmark name.

First test: exact saved compiler23 C, with separately recorded arms for reuse
only, cold Node stores only, and their combination. Cold-store emission removes
sealing at construction sites of a constructor proved unshared by the checked
entry certificate; unlike P68-018 it does not insert a per-value runtime test.
The two-node zipper retains storage returned by the unchanged `ctr_take`, reads
all fields before overwriting, and reuses only locations at least `HEAP_OFF`.
Shared take returns zero and static storage stays below `HEAP_OFF`, so both
allocate on reconstruction. A miss branch frees each retained spare once.

A direct-load arm, if prepared, must either retain the RFC fallback or carry a
stronger whole-flow proof that every input is unwrapped. Merely declaring source
syntax affine is insufficient: captures, arrays, foreign calls and opaque raw
inputs can hide aliases. Raw compiler emission must retain its existing path.
All polling/error checks, evaluation order, field keeps/drops and scheduler
boundaries remain unchanged. No unbounded C recursion is introduced.

The initial closed tree flow uses Tree fields only in its own Node constructor,
which the checked no-sharing certificate admits: no reachable user-valued
variable, capture or array element is duplicated. Do not generalize the test to
shared user constructors. Independent shared/static/raw controls must exercise
the fallback before any production promotion; shared parent fields must stay
sealed when the parent can be retained. Bounded lexical spares cannot survive
arbitrary recursive calls or become a new source of unbounded live storage.

Pins: preserve original C bytes and checked emission receipt; record each exact
before/after replacement and verify reverse reconstruction of the original.
Run oracle controls before alternating balanced timings. Fewer allocation calls
alone is not a speedup; require clean time and peak-memory evidence. A failed
or flat result is a stop signal for this slice, not permission to weaken
ownership or demand checks. Separate measurement, correctness and promotion.
