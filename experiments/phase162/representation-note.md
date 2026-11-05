# Phase162 — a concrete representation cost, not a whole-gap attribution

The accepted [operation census](../../implementation/phase162/operation-metrics.json)
finds 613,603,513 allocation requests / 4,320,218,635 requested words in our
C02 checking interval, versus 224,189,901 / 998,155,957 in bendc's checking
wrapper: **2.74× as many requests and 4.33× as many words**. Average request size
is approximately 7.04 versus 4.45 words. This establishes both more allocations
and a wider allocation mix at these observed boundaries. It does not identify
which term constructors caused them, nor establish identical semantic work:
our interval reuses a checked Base, while bendc checks its whole loaded book.
The intervals and the execution-thread counter scope are documented in the
[boundary audit](ours-frontend-boundaries.md).

## One application node through source and generated C

Our [`KTerm`](../../selfhost/src/core/term.bend#L5) carries eight fields:
semantic tag String, name String, binder ID, quantity, child list, removed-name
list and two origin positions. [`app`](../../selfhost/src/core/term.bend#L253)
represents a binary application as `kt("App", "", 0, 0, [f,x])`.

The actual C02 [`F_app`](../../selfhost/build/phase160/request-c02/program.c#L62917)
constructs:

```c
CN(0, 8, (V[]){S19800(), S19801(), 0u, 0u,
  C2(1, f, C2(1, x, IMM(0))), IMM(0), 0u, 0u})
```

The existing operands are references. `S19800/S19801` provide cached spellings;
they are **not freshly allocated Strings on every application**. Nevertheless,
this path makes one nine-word KTerm and two three-word child-list cells:
**three allocations, 15 requested words** for the new application structure.

bendc [`Tm.TApp`](../../selfhost/build/phase158/current/check.bend#L236) has direct
fields `f`, `x`, `s`. Its [`apps.go`](../../selfhost/build/phase158/current/check.bend#L1253)
loop constructs `TApp{f,x,s}`. The generated
[`F_Chk_dapps_dgo`](../../selfhost/build/phase157/vendor/seed/bendc.c#L73131)
uses `C3(13,f,x,s)`: **one allocation, four requested words**, when operands and
span already exist. The ordinal 13 encodes the semantic variant in the runtime
tag, eliminating a separate semantic-tag field and a child-list spine.

These sizes follow the shared runtime's
[`C2/C3/CN`](../../selfhost/build/phase159/refill-prepare01/bendrt.h#L2699)
definitions: `halloc(3)`, `halloc(4)` and `halloc(n+1)`. Sizes 2–16 use their exact
word-width class in [`gc_alloc_x`](../../selfhost/build/phase159/refill-prepare01/bendrt.h#L977).
Thus these are requested-word counts, including constructor header words, rather
than an inference from C text length. They are cumulative work, not resident RAM.

This is a real **3.75× local word difference**, not a compiler-speed ratio. Span
construction is outside this small comparison: bendc's `Sp` can itself cost four
words when freshly created, or be shared/`NoSp`; ours carries two positions inline
and recovers source ownership differently. Rebuilding an application many times
multiplies either representation's cost. We have not counted application nodes
alone or shown that they dominate the measured allocation mix.

## Book maintenance adds a second representation cost

Our nine-field `KDef` also represents cache/marker records. For a newly seen name,
[`L28302`](../../selfhost/build/phase160/request-c02/program.c#L78701) constructs
a ten-word `KDef` with kind `$final.seen`, default semantic fields and cached
Absent terms, then inserts it into the final-definition index. Most fields exist
to satisfy the generic definition representation; the operation needs membership
information. Do not charge the cached Absent constants as fresh allocations.

Even the logged-publication shortcut
[`p143cp_logged`](../../selfhost/src/check/compact-schedule.bend#L70) rebuilds a
cache KDef and list cells alongside its persistent index update. The generated
[`F_p143cp__logged`](../../selfhost/build/phase160/request-c02/program.c#L82957)
shows the `CN(0,9,...)` cache and three `C2` list cells, before accounting for the
index's own work. Repeated whole-book canonicalization can multiply marker,
index and list production further; root's separate publication ablation tests
that work amplification instead of guessing from these widths.

bendc's [`Book`](../../selfhost/build/phase158/current/check.bend#L273) is also a
wide, eight-field record. Its advantage is not that all state is tiny:
[`book_set`](../../selfhost/build/phase158/current/check.bend#L4765) updates a
dedicated declaration map while retaining the other fields. In its generated
[`U_Chk_dbook__set_x37u`](../../selfhost/build/phase157/vendor/seed/bendc.c#L64209),
those eight fields return through an output array; direct U callers avoid a new
outer Book box. The boxed F wrapper immediately below still allocates `CN(0,8)`.
Map nodes/reconstruction remain real costs. Its seven-field `TDef` may also need
a separate `Some{body}` object, so comparing only KDef-versus-TDef field counts
would exaggerate a universal saving.

## Interpretation and next discriminating observation

The C02 compiler uses the required `BEND_UNBOX=0` compatibility policy; the
current bendc seed has active U/flat-result paths. This comparison therefore
exposes both Bend data representation and generated-code representation. It is
not proof that our QBE compiler allocates these exact C objects or that unboxing
alone would fix the gap. Source checking, source locations, quantities, immutable
snapshots, template state and public compatibility remain required.

The strongest supported hypothesis is a combination of **repeated list/index
work and expensive per-node representation**. The two are not additive estimated
speedups. First use the publication ablation's actual row/allocation deltas to
isolate how much repetition is removable. Then count allocations by constructor
width and selected producer in a complete remaining frontend computation. A
typed application/term path is promising only if it avoids reconstructing the
generic record at each consumer and preserves diagnostics and checker behavior.
This note ran no targets and changed no compiler or generated C.
