# Accepted medium frontend profile and next discriminator

Offline analysis only. Existing `attribute.py` produced
`selfhost/build/phase177/profile-medium02/attribution/report.json` and ordered
`events.jsonl`; no target was executed. The authoritative stage receipt is
`selfhost/build/phase177/profile-medium02/stages.json`. Input is the656,302-byte
Phase175 frontend compiler source, not the frozen3.15MB full compiler source.

The8000us capture has2103 delivered samples, zero drops/overruns,99.9925% main
thread CPU coverage, valid ELF bindings, all eleven markers exactly once in
order, exact prior stdout and the anchored timing-stderr grammar. The process
lasts16.8565s diagnostically. The measured frontend marker interval is13.9934s;
Base preparation is0.2352s and digest/output/exit-hook work is2.5749s. These are
diagnostic clocks, not a new clean performance score.

| Disjoint frontend stage | Diagnostic seconds | Frontend clock share | Interior samples |
| --- | ---: | ---: | ---: |
| Parse/load |5.4460|38.92%|679|
| Check/publication |3.5497|25.37%|441|
| Dependency report |0.0502|0.36%|5|
| Ownership check |0.0371|0.27%|2|
| Entry check |0.0015|0.01%|0|
| Context |0.1591|1.14%|18|
| Reach/annotation |1.9869|14.20%|247|
| Layout |1.0196|7.29%|125|
| Erasure/request/wrapping |1.7433|12.46%|216|

Only parse/load exceeds the observer's500-sample threshold. The other stage
distributions are descriptive even though their boundary clocks are valid.
The three post-context semantic stages together take4.7499s,33.94% of this
frontend. Setup/report/ownership/entry together are small on this input; their
old mixed full-compiler profile costs cannot be transplanted onto this run.

## Physical work and attribution limits

The complete frontend interior, sample ordinals33 through1779 inclusive, has
1747 samples. It excludes the two outer boundary samples; unlike individual
stage summaries, it retains samples adjacent to internal markers.

| Distinct physical leaf | Frontend samples | Fraction of all1747 |
| --- | ---: | ---: |
| Borrowed `p88_string_eq_go` |176|10.07%|
| `term_drop` |166|9.50%|
| `span_fade` |135|7.73%|
| `work_loop.constprop.0` |96|5.50%|
| `p111_rt_sink` |84|4.81%|
| `p111_rt_special_ctor` |60|3.43%|
| `p111_set_regs` |49|2.80%|
| Borrowed `p98_tag_eq` |39|2.23%|

These physical leaves are distinct buckets. They overlap active-owner views
and do not identify allocation origins or removable work. The borrowed equality
worker appears throughout the pipeline:63 parse,42 check,23 annotation,29 layout,
19 erasure interior samples. This supports a shared execution mechanism rather
than another single traversal clone. It does not establish identity-hit rates.

756/1747 samples(43.27%) have unknown lexical lowered owner;85(4.87%) have an
unresolved physical leaf. Do not conflate these numbers. Some unknown lexical
groups still have unconditional exact dispatcher identities: `$direct.lookup`
107 samples, `$direct.f_eq`70, `$direct.p88_string_eq`41. Their lexical groups
were invalidated by multiple/mismatched direct entries; leave them unknown in
owner totals. The exact names separately identify actual active dispatcher
segments, not logical callers or inclusive costs.

The largest known lexical buckets are `f_decl_local`53,
`f_context_material_children`51, `subst_node`51, `f_pattern_sub`36,
`subst_terms`34, and `subst`28. No one of these is an inclusive cost ceiling.
The libc-only CFI table recovers118 physical callers in the whole capture;
1985 callers remain unknown. It cannot supply the missing source ancestry of
the equality worker or reclamation leaves.

## Why local rewrites produce small whole-frontend gains

The profile shows several substantial stages, each doing representation,
comparison, scheduling and ownership work. The current substitutions, material
walk and declaration changes reduce only parts of that work while preserving
the complete parse/check/annotation/layout/erasure pipeline. They therefore have
no demonstrated mechanism to remove a large complete stage. Their measured
few-percent gains are consistent with the distribution; the sample counts do
not prove a maximum attainable gain for those functions.

Do not respond by retaining every checker type or producing another paired
annotated/erased graph. Phase80 made annotation cheaper but enlarged prepared
Base from1.18MB to2.16MB and regressed held-outs. Phase84's278-line paired
annotation/erasure producer retained annotated source for layout/scalar/sharing
consumers and was neutral at1.0043x on genuine B2. Current
`annotate.bend:268,282,284,302,312`, `back/js/validate.bend:426`, and
`back/native/erase.bend:67–96` still exhibit type-head normalization and
substitution across those consumers. A larger redesign must replace their
shared representation/consumer obligations, with public request source and
failure order preserved; merely joining two traversals repeats the negative.

## Pointer identity: absent, already investigated, useful placement differs

The actual Phase177 retained QBE confirms no complete-Term identity shortcut:

- `program.ssa:3995`: borrowed `p88_string_eq_go` enters tag decoding and field
  extraction, compares character values, and loops over tails. It never first
  compares the full two String words. Assembly begins at `program.s:6738`.
- `program.ssa:4246` and `:50921`: owning `_go` and plain equality adapters first
  call `p118_rt_borrow_scalar_safe`; success calls the reader and preserves both
  sinks, refusal uses the owning fallback. Neither has an identity arm.
- `runtime.c:4794`: the alias guard deliberately refuses identical nontrivial
  RFC roots. A reader-only shortcut misses this owning path.
- `back/qbe/borrowed-regions.bend:50` emits that guard/reader/drops/fallback
  structure; no identity admission is present.

Phase164/165 did not establish a new identity shortcut. The exact prior is
`experiments/phase169/equality-identity-audit.md`, pointing to Phase131:

| Prior treatment | Result | Relevance |
| --- | --- | --- |
| Private reader identity on index queries |0.58–1.75% identical+True steps|Weak first coverage|
| Private reader identity on real use queries |30–36% step coverage;0.28% lower process time|Coverage alone misleading|
| Owning adapters before alias guard, both sinks retained |20.01% lower index-query proxy|Different and stronger boundary|
| Same owning change in full compiler image, three small requests |2.93% geometric reduction; Map slightly worse|Useful unqualified prior, not full-source gain|

The next decisive bounded experiment, if reopened, is the **owning adapter
boundary on this exact frontend image**, not a duplicate reader-only patch or
a new String representation. Count nonempty equal full-word roots with pending
True before the guard, and the traversal actually avoided; keep root and shared
suffix hits separate. Count-only products are diagnostics, never timing evidence.
Then compare a clean branch-only derivative with original runtime, exact stdout,
ordinary unequal-content comparison and both root sinks unchanged. The retained
SSA/assembly already makes this possible without a new Bend image acquisition.

Required controls: unequal words/equal content, early/late mismatch, Unicode,
pending False, retained aliases, exactly-two-owned-alias destruction, and empty
Strings. Complete64-bit Term equality is required; equal heap locations alone
are insufficient. A production pass needs the existing source/dependency-bound
reflexivity admission proposed in `research/phase131/identity-hook.md`; a name
match is unsound. The rule is for valid immutable Strings, not general equality.

This is the strongest cheap shared-mechanism discriminator supported here. Its
historical prior is a few-percent whole request effect. The profile does not
establish a20% frontend opportunity or justify a broad typed-IR/numbered-name
rewrite. A larger next investment needs causal evidence that it removes one of
the complete measured semantic stages, including its consumers and conversion
cost, or changes execution across several of them.
