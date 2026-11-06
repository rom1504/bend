# Private event history without a redundant declaration list

Experimental candidate only. No compiler execution, correctness pass or speedup
is claimed by this source audit. Maintained modules and the installed image are
unchanged. The overlay is
[`publication-history.bend`](../../selfhost/tests/phase171/publication-history.bend),
with finite observation controls in
[`publication-controls.bend`](../../selfhost/tests/phase171/publication-controls.bend).

## Observation and cost ceiling

Current Phase171 disjoint diagnostic clocks put checking/publication at
21.239301 CPU seconds. `index_remove` accounts for56/662 active-owner samples
in that interval, but active owners are conditional/incomplete and this is not
an inclusive allocation attribution. Earlier6.533M remove visits and2.010M
constructor-existence visits are historical counts, not current measurements.
Neither21.239s nor all global reclamation cost is removable by this candidate.
Its plausible whole-build gain is only a few seconds until measured; it is a
bounded supporting experiment, not the primary100s architecture.

The current checker carries two declaration worlds. Its real `KWorld.book`
supports checking and eventually becomes the published ordered result. Separately,
`p156cp_walk` carries `seen` solely to preserve declaration-order/law/constructor
diagnostics. `p156cp_continue` updates this second book through `book_put`.
That updates an authoritative persistent index **and** removes an older row from
the whole raw declaration list. Constructor collision checks subsequently scan
that same list, including thousands of definitions with no constructors.

This is distinct from Phase156's selected dirty-publication policy. That policy
changes when the real world is canonicalized; this experiment leaves it alone.

## Proposed representation and equivalence boundary

Only the private `seen` view changes. Preserve its exact BookCache sentinel,
authoritative definition index and binder bound, but retain raw rows only when
`dc(row)` is nonempty. It remains a list-shaped private view for the existing
consumers; it is **not** a generally interchangeable public declaration book.
Do not pass it to future consumers that enumerate all definitions.

The observation invariant is:

1. `lookup(seen,name)` returns the exact same definition for every name, because
   the first real cache and every index update are unchanged.
2. `norm_book_bound(seen)` returns the same stamped bound.
3. `constructor_exists(seen,name)` returns the same Boolean: removed rows have
   empty constructor lists, so their contribution is false. Retained row order
   is unchanged. BookCache rows keep their original exclusion semantics.
4. `compare(seen,a,b,le)` is unchanged: its book observations are the bound and
   indexed lookup during graph normalization/conversion, not raw enumeration.
5. Hence `event_error` returns the same first error for each event. The existing
   actual definition checker, checked-body publication and final KWorld book are
   untouched.

The initial filter runs once, inside `p156cp_start` only for the selected logged
path and only when a real cache heads the book. Raw books retain the old path.
Each `p171s_put` performs the original index update and sentinel field reset.
It uses the existing `index_put_rest` on constructor-bearing rows, including its
empty-name and cache-miss policy; an update with constructors is prepended, one
without constructors is not. Thus even replacing a constructor-bearing row with
a childless row removes the old constructor observations. No assumption that
all source definitions are well-formed is needed for this row-filter identity.

The two overridden definitions are `p156cp_start` and `p156cp_continue`; neither
is a protected verifier/proof declaration. No final verifier, source checker,
proof law, optimization admission or production selector is changed.

## Falsification and integration gates

The additive `p171s_controls` compares exact lookup results, binder bounds,
constructor existence and event errors throughout update streams. Cases cover
law/fill, duplicate declarations, constructor removal/restoration, raw uncached
fallback and empty names. These are finite controls, not a mathematical proof.

Use the shared metadata-only assembler:

```sh
python3 -B selfhost/tests/phase171/prepare-api.py \
  --prelude selfhost/tests/phase171/publication-laws.bend \
  --module selfhost/tests/phase171/publication-history.bend \
  --module selfhost/tests/phase171/publication-controls.bend \
  --replace p156cp_start --replace p156cp_continue \
  --export p171s_controls --out selfhost/build/phase171/publication-api-source01
```

After independent source checking, run the controls and existing complete
frontend success/error fixtures, then require exact complete QBE on a real
checker source and Map. Compare native complete request time before paying for
a full-image gate. Any output change rejects the candidate until explained.
Check source/law/fill/template failure paths as well as successful compilation.

If measured savings do not justify another private book-view convention, reject
this overlay. If they do, give the event-history type its own explicit carrier
when integrating; the experiment should not become an undocumented alternative
meaning of public `List<KDef>`.

## Larger remaining barrier

This does not remove the real world's need for source order, constructor lookup,
checked bodies, specialization snapshots or final publication. Eliminating those
duplicate representations requires an end-to-end semantic declaration store and
explicit materialization boundary, as described in the frontend audit. The
current21.24s stage ceiling still cannot independently deliver the89s saving
required by the100s full-build goal.
