# Phase114 reachability boundary

Source-only audit of selected `final-source02/compiler.bend` (SHA256
`500211d484785778e75d5d4388b0d5ebc7282effd233c6b8f3d0e0269ac777f8`).
No compiler or program was executed for this audit.

**Definition reachability is already applied.** Another closure from source
`main` before native lowering would repeat existing work; it would not remove
the old emitter and diagnostic definitions responsible for the question,
because those definitions are already absent from the emitted executable.

## Existing boundaries and actual output

1. `p86_plan_context` in the selected source at line 38504 calls
   `annotate_selected(context, reach_book(context,["main"],stops),stops)`.
   `selfhost/src/core/reach.bend:70` computes this conservative closure after
   checking/specialization. Its dependencies include types, constructor
   telescopes and constructor parents; intrinsic stops retain declarations and
   types while excluding bodies the backend replaces.
2. `nr_prepare_annotated` at selected line 36364 merges the checked annotations,
   then runs `nr_walk(source,["main"],[],[])`. `nr_visit` at line 36311 follows
   `nc_refs(nc_definition_plain(...))`: runtime references after erasure, with
   native primitive replacement taking precedence over foreign lowering.
   `NR_Request.names` is this closure; the full source book remains available
   for checking, type/layout lookup and authenticated source facts.
3. Both paths use those names. `p111_compile_defs` at line 40096 iterates only
   `names`. The selected `p113pl_prepared`/`p113pl_plan` at lines 46090/46083
   compile the same generic fallback and plan direct/product candidates from
   the same names. The selected entry at line 40967 calls this pipeline via
   `p113a_lower_request`; it does not invoke the retired C emitter.

The completed existing receipt
`selfhost/build/phase111/p114-native-final02-full-emit/report.json` records
6,186 source-book entries, **2,885 reachable names**, 35,767 generic segments,
827 direct functions, 531 constructors and 74,220,801 QBE bytes. The count of
segments is not a count of unfiltered source definitions: `p111_entry` and
`p111_extend` (selected lines 40064/40058) create closure factories and direct
entries, while lowered lambdas and calls add continuation segments.

A read-only scan of the existing QBE function declarations, decoding the
emitter's `FID_<decimal codepoints>` names, found no `nc_compile`,
`nr_compile`, `nr_compile_prepared`, `ns_compile_named`, `nc_compile_defs`,
`j_compile`, `p113pl_inspect_request`, `p114h_inspect_request`, or any function
ending `_control_report` or `_inspect_request`. It did find `main`,
`p111_native_args`, `p113a_lower_request` and `p111q_stmt`. This is a limited
concrete census, not a whole-program semantic proof or a timing result.

## A distinct boundary remains after lowering

The pinned upstream compiler does more than source closure.
`selfhost/.bootstrap/upstream-phase66/bend2/comp.ts:2768` first calls
`file_book(["main", ...RUNTIME_ADTS, ...showFamilies])`. After its emission
fixed point, lines 2807–2815 collect segment reference edges, close them from
the segment for `main`, and filter both `FL.segs` and `FL.spins`.

The selected direct-QBE path has no equivalent final segment filter in the
inspected assembly route. `p113e_public_chunks` (line 45283) walks every
original segment, choosing its public implementation; `p113e_registered`
(45315) also emits the selected direct functions and legacy private workers.
`p113e_bundle_chunks` (45338) supplies the complete original segment list to
the descriptor tables. `p111q_segment_table` (40804) retains every such
function pointer. The array-enabled alternate renderer has the same table
boundary (47884–47908); this full compiler's array certificate is disabled.
Thus inlined continuations and replaced generic routes may remain in the
image. Their actual removable count has not been measured. The function
pointer table also means ordinary linker dead-code removal cannot simply
discard them.

This is a possible **generated-segment reachability** opportunity, not a
missing source-definition pass. It needs the chosen public/direct/R/G/H
implementation's edges, closure creation targets, stored continuation FIDs,
runtime entry/IO/closure-dispatch roots and any retained public ABI roots.
Following only direct QBE call instructions would miss scheduler edges.
Following all original fallback edges would be conservative but might retain
most of the duplication. Removing or renumbering segments must preserve all
descriptor references and runtime-reserved IDs.

Constructor metadata is another separate boundary: `p111_finish` (40121)
builds its catalogue from the full original source. Replacing that with the
runtime definition list would lose constructor/type/show information and
change IDs. No metadata-pruning change is proposed here.

## Narrow next gate

Before implementing pruning, add an ordinary diagnostic census to an existing
checked small program with a replaced continuation: count retained segment
and private-worker edges after implementation selection, including explicit
closure/frame/runtime roots. Compare the census with the existing upstream
segment closure and report potential removed bodies/bytes. If that shows a
material gap, qualify a separate Bend pass with complete output and native
self-compilation checks before using it on the compiler image. Keep final
verification and descriptor consistency checks intact.

This would target emission size, machine build cost and possibly later
verification cost. It would not recover time already spent lowering the
generic fallback. Likewise, dropping unreachable declarations from the input
text could reduce frontend checking work, but changes whole-source diagnostic
and proof reporting; it is a separate production-source slicing decision,
not a free consequence of runtime reachability. No gain estimate is justified
by the present census alone.
