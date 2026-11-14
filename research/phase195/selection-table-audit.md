# Independent selection and table-call audit

Read-only inspection of `selection/select-placement*.bend`,
`float/table-calls.bend`, `float/table-hook.bend`, their controls, and the
maintained selectors/catalogue/emission consumers. Root owns execution and
immutable experimental files. No semantic blocker found in the inspected
paths. This is finite source reasoning and control review, not a formal proof
or native qualification.

## Selection analysis view

The projection invokes the existing exact predicate/select recognizer and
whole-function removed-name certificate. A synthetic comparison consumes the
original compare operands before a synthetic choice operation reads both
alternative values; chained copies then model each publication. This matches
the emitter's read-before-publication order, including aliases and repeated
destination copies. The OR row represents an interference event, not the
runtime selected value. Its temporary and all projected rows remain confined
to allocation analysis. Original rows/facts supply executable selection and
original frame construction preserves slots.

The comparison dummy is not an allocated local, and emitter scratch registers
are excluded from assigned homes. Flags are not IR values: these rows must not
be reused by a value optimizer or emitted as executable replacement IR.
Mixed32/64-bit comparisons and outputs remain governed by the original exact
selector and canonical full-word publication. No additional equality between
the two widths is assumed by the projection.

The controls exercise comparison/choice width differences, inversion,
destination aliases, pressure, multiple publications and external-use refusal.
Passing values alone would not prove use of the selected path; the separate
root-owned machine/admission comparisons remain necessary. A useful adversary
is a selected alternative whose old value is also needed after the corridor,
under caller-register pressure, plus a source local spelled like the dummy.
Reserved-name frame exclusion must continue to apply consistently.

## Certified table calls

`p126s_cells` certifies a total, effect-free, exact word-index equality chain:
one parameter, one result, constant upper halves zero, sequential indices,
and a constant final default. `p126i_catalogue` is constructed from the same
prepared function list consumed by the private emission cursor. The adapter
only rewrites one-result/one-argument calls present in that catalogue.

The unsigned64 comparison and clamp preserve all high input bits: indices
at or above the final index select the default, including UINT64_MAX. The
clamped index is at most63, so its eight-byte offset cannot overflow. Data
uses eight-byte `P111QLong` cells with zero high halves, and U64 loads preserve
the original full-word return, including raw F32/NaN bit patterns without
performing floating operations or changing MXCSR. Result/input aliasing is
safe because publication is last.

Prefix admission checks original parameters, definitions and reads recursively,
including both conditional forms, calls, results and loop arguments. Reusing
the four private temporaries across completed calls therefore does not alias
original state. Table symbols use the existing injective encoded function ID
under a distinct data prefix. The hook emits each certified function's data
while retaining its original entry and forwarder; mode2 is required.

The trust boundary is the canonical catalogue tied to the same function list.
`x195t_when` is not independently sound for an arbitrary forged lookup list.
The data path rechecks shape, result/parameter counts and exact length, and
reports mismatch. Existing unique-function/symbol invariants are still needed;
this audit does not establish behavior for malformed duplicate prepared IDs.

Controls include high-word indices, maximum index, wraparound input arithmetic,
aliased destinations, branches, surrounding effect barriers and raw word
patterns, with independent C expectations. They exercise adapter and data
helpers separately, not `x181_program_private` integration. The strongest
remaining integration adversary is several certified functions called across
multiple cursor pieces, with repeated nested calls and a prefix-collision
caller, checking one data definition per symbol, refusal where required and
unchanged effect ordering. Root's actual development programs are needed to
show that this hook is reached and links correctly.

The4096-row guard is checked before expansion; resulting bodies can be larger
and can cross downstream allocator limits. That is a performance/compiler-cost
risk, not a semantic failure in the inspected rewrite. Lookup call elimination
also changes register pressure and layout, so all measured gains cannot be
attributed solely to avoiding the helper's sampled time.
