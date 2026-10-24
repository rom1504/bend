# Reuse the inner range computation, not an assumed fixed point

This is a bounded, experimental source overlay. It is not a production change or
a performance result. The producer is the selected Phase131 source
`combined-literals-source01/compiler.bend`, SHA-256
`1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9`.
The root agent owns checked execution and timing.

## Source observations

1. `p113i_function_done` (source line 46946) already calls `p113k_function`
   after checking the inlined body's stack estimate against 16,384 bytes.
2. `p114s_ranges` (line 48806) subsequently applies `p113k_functions` to the
   committed inline result. The second range pass is real work; it must not be
   discarded merely because a first pass occurred.
3. `p113k_function` (line 48204) is a function-local transformation. Its inputs
   are the exact `P113DFunction` and the fixed compiler implementation. It starts
   facts with `missing()`; there are no book, constructor-ID, caller, ready-table,
   or other-function parameters. Calls only transform their argument values and
   kill local facts for destinations. They do not inspect callee bodies.
4. The original inline table is sequential. `p113i_functions_step` publishes the
   transformed result only if the **original** function satisfies
   `p113i_original_clean`; `p113i_table_function` retains its existing eligibility
   rules. Reusing one output must not skip or change this publication.

## Exact experiment

`range-reuse-v01.bend` clones only the orchestration needed to preserve a pair
`(input, p113k_function(input))` when the original inline pass invokes the inner
range pass. It does not replace the range analysis or inline scanner.

The outer range pass compares its actual current function with the pair's
**input**, using the already audited full structural `p134v_function` equality:

```
if current == recorded_input:
    use recorded_output
else:
    use p113k_function(current)
```

If the first range pass changed a function, its output is not accepted as an
input key. The second pass still runs. This experiment assumes neither
idempotence nor that one pass reaches a fixed point. The important likely hits
are functions for which the first range pass did no rewriting.

The following original conditions and ordering are copied exactly:

- Parameter and body cleanliness, inline size at most 2,048, scan site 0 and
  budget 1,024, and stack estimate at most 16,384.
- Original-function cleanliness before publishing a transformed callee, and the
  unmodified table-insertion eligibility.
- A separate verification commit after inline, then a separate commit after
  range. Both use the previously audited `p134v_commit`, including its original
  full-verifier fallback on header changes. Independent final verification is
  unchanged.
- Lowering-error strings and invalid-boundary handling.

An inline commit can reject its candidate and restore the prior functions. The
memos remain mathematically valid pairs, but are only used if that restored
current function equals the recorded input. Otherwise the ordinary range pass
runs. Thus rejection does not require discarding the memos for correctness.

## Trust and cost boundaries

The memo constructor is a data constructor, not an unforgeable proof type. The
optimization is justified only for pairs made by `p134rk_ranged` in this fixed
producer. Do not accept arbitrary external memo data or reuse pairs across a
compiler/policy change without an additional producer-identity contract.

This can lose on cost: it retains extra input/output roots, allocates small memo
records and a list, compares full IR, and later drops those records. Actual
whole-request time and peak memory must charge all of that. A hit count alone
does not demonstrate a speedup. The ordinary verifier-reuse gain must also be
separated from the incremental benefit of range reuse.

The 20 controls in `range-controls-v01.bend` compare against direct calls to
original `p114s_commit`, `p113i_functions`, and `p113k_functions`. They cover
forward/prior calls, repeated names, actual range rewriting, output-versus-input
keys, invalid-inline fallback, missing memos, prefix and stack rejection, and a
high-word key mismatch. The boundary comparison observes validity and complete
functions; unchanged original/ID retention is also established by the source
composition, not by that comparison alone.

The first checked-source attempt rejected computed `match` scrutinees in the
control helpers. The original fixture is preserved. `range-controls-v02.bend`
uses explicit typed continuation helpers for those five scrutinees; its 20
claims and the experimental core are unchanged. This was a fixture syntax
failure, not evidence that the optimization was accepted or rejected.

The second checked-source attempt passed, but its finite screen passed 19/20:
the supposed changing fixture used constant addition. Inspection shows
`p113l_base_binary` computes only a bit bound for addition, whereas it computes
an exact value for constant XOR. `range-controls-v03.bend` changes that one
fixture operation to XOR, retaining v02 and its negative evidence. The core and
all equivalence checks are unchanged; this makes the non-idempotence control
actually exercise a changed first-pass output.

## Larger cache seam, not implemented

A cross-revision range memo needs exact input IR plus fixed producer/policy
identity. It does not need the complete source book. Reuse must happen before
`p113k_function` starts. Reusing only after computing the range result saves
nothing.

Inlining additionally consumes a table of transformed prior callees. A safe
bounded dependency record is the exact input function plus the ordered results
of looking up every direct-call target present in that original body, including
missing lookups. A stored callee must be compared as a complete transformed
function, not merely by name or signature. Existing `p113i_scan` scans the
original remainder after appending an inserted body; it does not rescan that
inserted body. Earlier transformations already embedded in a stored callee are
therefore covered by its exact body. Preserve table publication on a memo hit.

This smaller dependency record could avoid a whole-prefix key, but it is only a
source-grounded proposal. Its collection, lookup and retention cost and all
actual call-query branches still need a dedicated implementation and falsifier.
