# Checked scalar arrays and native parity

2026-10-11. Continues P68-016's measured 5.44× array opportunity. Work remains
in the compiler written in Bend. Raw `nc_compile` retains generic storage;
the checked driver may use a distinct checked entry after its existing checking,
specialization, annotation and layout guards. No release promotion is implied.

## Phase A: recover a safe representation fact

Implement a conservative whole-program packed32 certificate in Bend. Inspect
reachable executable definitions and representation-demanding occurrences,
not all nested generic type annotations. Every instantiated generic array
primitive and every array constructor/matcher must use U32/F32/Char. Refuse
unknown/open sites, uninstantiated generic array primitives and proof rewrites.
Unrelated generic type syntax does not itself demand array representation.
The compiler's known native templates have fixed semantics; skip their bodies.

Custom foreign code refuses the certificate. Initially permit only the audited
Base IO args/print/now interfaces, with their shipped effect bytes checked by the
host. This is an explicit trusted-input contract for the checked entry, not
authentication from a function name or an arbitrary boolean supplied to raw APIs.
Unknown effects retain the uniform representation. The raw entry never enables
the new macro by inference from unchecked annotations.

One module-wide representation permits no mixed-layout joins. Keep normal
sharing lookup: element layout and handle ownership are independent. Update
new/get/set/swap, ALeaf, leaf destructuring and atomics consistently; existing
copy/half/show/drop already inspect the array tag. Share access emitters between
ordinary and product-result lowering to avoid divergent implementations.

## Phase B: prove generated-code value, then broaden facts

First build a checked B1, compare actual emitted programs with independent
oracles, inspect active code, and use the saved-binary fast loop. Refuse a
selection if the certificate never fires or its overhead erases the gain.
Then investigate a separate safe location cache or no-sharing analysis, using
the prior combined diagnostic as a target, not a promise. Retain generic lookup
whenever a handle can change or an array-containing value can be shared.

Only expand to other scalar/product or closure facts after a cheap discriminating
experiment. Do not spend the phase implementing broad speculative frameworks.

## Phase C: integration and report

Controls include U32 boundaries, F32 bits, Char, get/set/swap/clone, leaf/node
construction and matching, atomics, retained aliases, opaque/generic arrays,
raw annotation lies, proof rewrites, foreign refusal and checked-driver routing.
Use existing paired native controls and one/four-thread checks. Measure six
native families and actual B1/B2 C emission; keep JS/frontend preservation and
source complexity explicit. Build B2 for selected integration, not each edit.

One root-owned CPU3 target tree, 2GiB tree RSS, 4GiB available-memory floor,
Node 1GiB heap/4MiB stack. Source work CPU0. Keep failed attempts. New raw stays
under Phase68; preserve installed Phase67 and inherited work. Commit design,
implementation milestones and a report; push the authorized bootstrap branch.

One fresh-context Ultra advisor reviewed the correctness seam; root implements
and validates. Track usage with the existing local tool, avoiding redundant
agent reviews and broad validation on every iteration.
