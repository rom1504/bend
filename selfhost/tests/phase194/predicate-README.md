# Experimental predicate-through-copy selection

Current experiment is **v2**: use `predicate-select-v2.bend`, the unchanged
`predicate-hook.bend`, `predicate-controls-v2.bend`, and
`predicate-driver-v2.mjs` / `predicate-controls-v2.c`. Original files below are
preserved as the first frozen proposal. V2 has 68 data labels and 60 machine
modes / 7,260 observations per route. It adds both mixed compare/select widths
and exact empty-If handling on the current predicate, in both IR forms. Every
removed empty branch's condition read enters the use certificate; unrelated
conditions remain refused.

The completed `phase194/diagnostic-ir01` shows that every targeted row comparison
has an intervening empty If. Offline structural inspection of the actual typed
rows finds three candidate corridors in each exact local-pair/editdist p113d
row function, with complete-use counts matching. This is metadata corroboration,
not execution of the checked Bend matcher; actual emission must confirm it.

Acquire `predicate-select.bend` as an added module, `predicate-hook.bend` as
replacements for `x190_branch_pair_record`, `x190_branch_pairs`, `x190_step`,
and `predicate-controls.bend` as the control fixture. Export `p194pc_controls`,
`p194pc_emit`, `x188_many`, `x188_render`, `x188_assemble` for the existing checked
control authority. `predicate-driver.mjs` follows the Phase192 checked API/assets
driver contract. Root owns all checks, emission and runtime jobs.

Status at author handoff: source authored and reviewed offline, **not source
checked or executed**. Expected controls: 47 exact data labels, 40 machine
functions, independent C oracle 4,840 observations on each direct/assembly route.
The three-definition integration patch is unapplied and does not register the
experimental module automatically. No maintained file was changed.

`x194_ps_enabled()` is the parameterless Boolean ablation switch. False returns
None before shape recognition; original adjacent-pair da counts are unchanged.

The first slice does not change placement metadata. It reuses the current
branch-pair tree walk and stores independent use counts in `dx`; existing
adjacent-branch counts remain in `da`. The matcher admits an integer comparison,
up to eight U32/U64 copies or exact Boolean xor1 operations, then the existing
pure-copy select-arm certificate. Every removed local read across the entire
function must be accounted for by such a corridor. Parameters/setup definitions
and reserved locals refuse. Repeated mutable names are safe only under that
complete-use certificate; this is not general dominance or value numbering.

No memory, call, allocation, control or unrelated assignment may occur in the
corridor. Its destinations cannot be comparison operands or select inputs;
select outputs cannot be removed predicate locals. Thus source overwrites
invalidate recognition, and original observable output assignments remain.
CMP occurs at the original comparison point before removed Boolean writes;
select inputs are read into reserved scratch registers before publication.
Only flag-preserving MOV/MOVL operations separate CMP and CMOV. Integer signed
and unsigned comparison width is independent of the select publication width.
The comparison flags are a private producer/consumer connection, not an IR
observable output. Original low32 truth is exact because the corridor starts
with canonical 0/1 and only preserves or complements that value.

Controls include signed/unsigned U32/U64 comparisons, high word differences,
sign boundaries, aliasing both selected destinations with source operands,
mixed-width Boolean copies, in-place Boolean writes and inversion. Data
refusals cover operand writes, alias writes to operands, calls, loads, stores,
extra predicate uses, and repeated predicate definitions. Extend controls for
selection-window saturation, protected setup/parameter names, non-pure arms
and arbitrary result widths before promotion; the original Phase190 branch and
Phase191 conditional-select observers remain regression controls.

First machine falsifier: inspect the real local-pair/editdist p113d `$product.row`
fast loop. Its two minima should reach CMP/CMOV without SETcc/Boolean TEST.
If the matcher refuses the actual preselection rows, retain its diagnostic and
do not widen admission without identifying the exact extra operation and use.
If original placement keeps the excessive stack transports, a future shared
selection metadata consumer is possible, but is not part of this initial slice.
