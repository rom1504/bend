# Independent width and scalar-query audit

This lane reviews source and evidence only; the root owns all target execution.
The qualified parent is Phase134 source
`a00019246b5181b288ab4d3e09e616bd41415fe6381e89a96185c05efa19fb57`.
This audit does not confer native qualification or change the installed compiler.

The first eight actual QBE products reveal an early-inlining barrier:
[generated-calls.md](generated-calls.md) records the timed call paths, unchanged
owning work, and why only one new query reader remains reachable. The isolated
profitability experiment has a separate
[byte-preservation audit](retain-source02.json); checked execution and timing are
owned by the root campaign.

## Four-bound width integration

Candidate `wide-source01/compiler.bend` is
`863e28f8bba8a285332875ce99bf82a20d2ea3052c6f4b6aed3606b0d67485b5`.
The [independent receipt](width-source01.json) verifies every original source
line: exactly four `8 → 16` substitutions and no other parent-byte changes;
only the exact isolated, noncolliding controls are appended. This uses a direct
line comparison rather than trusting the composer's changed-declaration list.
[The replay tool](../../../selfhost/tools/performance/phase137/audit/width-source-v01.py)
runs metadata checks only.

No new physical ABI or buffer limit is crossed. The 2,048-byte private scratch
fits 128 bytes for sixteen fields; unchanged `p111v_buffer` still checks actual
capacity and count. The runtime's `p118_rt_borrow_fields` verifies actual
constructor/arity/tag and writes field views without transferring ownership.
The late inline read template still admits only eight fields; nine-to-sixteen
field reads use the existing runtime helper. Packed one-field constructors,
constructor-count limits, helper argument limits and continuation limits are
separate and unchanged. The selected source locations and runtime contract are
documented in [the Phase136 mechanism audit](../../phase136/profiling/query-mechanics.md).

The four changed bounds are admission policy. Their expansion is not a proof of
root lifetime, noescape, arbitrary recursive traversal or profitable codegen.
The old malformed/dependent layout restrictions and final verifier remain.

One historical finite expectation changes intentionally: the selected
`p131rg_controls` contains `region-wide-refused = not p131rg_width(9)`. Width16
invalidates that old policy assertion. The new seventeen width controls test
nine as admitted and seventeen as refused; do not describe all historical
finite controls as passing unchanged. This does not change a protected verifier.

## Integrated source03

[The independent integration audit](integrated-source03.json) checks candidate
`2620d59a3a20fa5d5d27bbf3b12ceb7304439b27093fff1c0f383da03e4ecf38`
against the qualified source. Exactly nine existing declarations differ:
four width bounds, one inline-eligibility call, three query bodies and the one
explicit historical width-policy control. Each change is checked against the
exact expected text substitutions. All other original declarations, protected
verifiers, request entry points and the eleven listed proof declarations are
unchanged after ignoring whitespace and comments.

The five new scalar predicates and three rewritten query bodies match the
actually measured v02 fixtures. The integration does not import the fixture
workload, its `main`, or the discarded parameterized kind predicate. The runtime
object remains the qualified Phase128 object. This source audit is separate
from checking, native bootstrap qualification and any performance decision.

## Scalar predicate proposal

The bounded proposed rewrite introduces complete Bool observations of a record's
name or kind and substitutes them at the existing comparison sites. It leaves
the list traversal, first-match return, child lookup, `db`/`dc`, and index
algorithms intact. Returning an owned String or KDef from a borrowed reader is
outside this proposal: only Bool crosses the private observation boundary.

Required exact variant meanings are:

| Record constructor | `dn` | `dk` |
|---|---|---|
| `KDef` | stored name | stored kind |
| `KIndexLeaf` | empty string | `IndexLeaf` |
| `KIndexNode` | empty string | `IndexNode` |

`f_find` compares `f_eq(name, dn(d))`, with the requested name first; `lookup`
compares `p88_string_eq(dn(d), name)`, with the stored name first. Use separate
small predicate orientations or explicitly justify symmetry on valid pure
Strings; do not call these expressions syntactically identical. `f_eq` delegates
to the existing equality. No source expression that creates an input may be
skipped or moved before its original evaluation point.

`f_find` returns its first matching original row and produces a `Missing`
record carrying the requested name on exhaustion. `lookup` instead returns
`missing()` with empty name/`Absent` kind, and must inspect `BookCache` before
the ordinary name predicate. A preceding matching row still wins over a later
cache. `nc_ctor_owned` only searches `dc(d)` after the existing ADT test, and
returns the original `db(d)` only after the existing child-kind test. All these
branch/ordering distinctions must survive the rewrite.

The source may use a linear record parameter when it is matched only once,
as in the prior wider-reader fixture. `+` permits repeated source use; it is not
a borrowed ABI annotation. Actual borrowing is authorized by the generated
adapter/private-reader contracts, not a naming convention or quantity change.

## Root lifetime and noescape obligations

The unchanged public scalar adapter first calls
`p118_rt_borrow_scalar_safe`. For nontrivial roots it requires an RFC with count
greater than one, and it refuses two identical nontrivial RFC roots. The false
branch calls the unchanged owning fallback. The true branch observes first,
then sinks each owned root exactly once. A private borrowed reader must never
sink these roots or return an opaque field as an owned result.

In private composition, `p128br_arguments` requires exact types and a held-root
origin; `p128br_held` accepts descendants only beneath certified roots. The
helper result must remain scalar and its reader must be in the actual emitted
worker bundle. Runtime reads do not retain scratch pointers. Opaque terms,
lists and children in KDef remain unread unless their separate layout and use
are admitted. Widening a record does not authorize following an opaque tree.

Ordinary controls should include empty/nonempty/Unicode names; separately built
equal strings; a query key also held as the record's name; retained aliases
observed after the call; all three constructors, including empty-name index
variants; early/late duplicate hits and misses; actual BookCache dispatch;
absent children and repeated constructor names in different ADTs. Keep unique
or insufficiently shared roots on their valid owning fallback. Use ordinary
well-typed values, not malformed heaps or raw runtime-failure probes.

## Small 2×2 experiment, using the current pipeline

| Cell | Compiler | Query source |
|---|---|---|
| A | Qualified Phase134 | Original |
| B | Width16 only | Original |
| C | Qualified Phase134 | Scalar predicates |
| D | Width16 only | Scalar predicates |

All cells must use `p86_plan → p111_runtime_admission → p111_emit_admitted`.
The existing qualified API is
`selfhost/build/phase111/p134-verify-selected-api01/report.json`. Do not substitute
an older separate lowering/observer entry that bypasses the selected pipeline.
The root's thin driver owns emission; this audit introduces no second compiler.

Use the existing Phase123 aligned builder with the identical Phase128 runtime,
QBE/toolchain/flags, and independent ordinary output file for all four cells.
Then use the generic profiler manifest/run machinery for five rotating clean
rounds on the root's CPU3 lane. Each variant uses the same calibrated repetition
count, scalar digest and strict trailing elapsed-integer rule. Aim for at least
100ms per child; preserve a shorter initial pilot as calibration, not the final
speed result. Report B/A (width), C/A (source shape), D/C (width after composition),
and D/A (combined). Ratios overlap and must not be multiplied as independent gains.

Before timing, inspect the **actual timed caller**, adapter and private reader:

1. A new reader symbol alone is insufficient. Show the loop calls its adapter
   or a verified private read call; early inlining may retain old owning code.
2. Verify the true reader path removes the owning take9/sink sequence for the
   observed field, while original public fallback remains reachable.
3. Preserve operand/branch order and stack-safe loop structure. Count static
   calls per selected branch, not all mutually exclusive blocks as dynamic work.
4. Inspect one relevant machine-code block or exact call target. Fewer QBE
   instructions alone did not predict runtime in Phase131's field-mask negative.

If a runtime mechanism is still uncertain, relink the same tiny `program.o`
against the already pinned diagnostic runtime and run separate event-only or
32ms sampled observations with the existing generic profiler. Event hooks can
miss emitted inline operations; do not call static takes dynamic allocations.
No full compiler image or new profiling framework is needed to reject a miss.

## Cheap alternative if width alone does not apply

Do not widen more thresholds. First expose a complete scalar kind/name predicate
at an actual `nc_ctor_owned`/`f_find` comparison, retaining the original row in
the caller. This is the proposed C/D factor, a small reuse of the existing
observer capability. If the private reader is emitted but the caller bypasses
it, preserve that negative evidence and fix only the proven composition boundary.

An early constructor-ownership summary is a separate fallback hypothesis: build
it from the same immutable checked book **before its actual early callers**, and
preserve first ADT/child-match, native flag, absent and BookCache meanings.
Phase135's late attached summary did not establish a whole-request gain; merely
moving that table earlier without measuring construction and query counts is
not a result. Price it only after the scalar-query ceiling and the existing
Phase136 query census, not as a second parallel implementation campaign.
