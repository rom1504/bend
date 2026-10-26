# Can a parser hit avoid completed-prefix materialization?

2026-10-26. Bounded source-only audit of Phase141 integrated-source02
(`f5bfca6d1fe9b378955d6c89ba5ec2428ec1627d7d008eb0c15eac1b51c8a06a`).
No implementation, execution, performance estimate or theorem in this note.

**Yes, there is a plausible producer-owned boundary:** with the actual retained
raw parser prefix, fixed completion dependencies and a successful full parse,
the completed prefix is independent of later user definitions. I found no
suffix-dependent transformation of its data. This does **not** make its cached
acceptance, name indexes or checker state unconditional.

## Exact completion dependencies

The path from raw declaration events to completed events is:

| Operation | Inputs affecting prefix data | Later user events consulted? |
|---|---|---|
| `f_context_defs`11903 | Each raw definition/type/children; full parse success Boolean | Only whether parsing succeeded; `f_context_lower`13875 is term-local |
| `f_graph_fill_defs`14895 | Each contextual definition; exact imported `prior` and ordered alias list | No; fills consult fixed imported scope, not the final user book |
| `f_context_modules`11915 | Filled definition, children, namespace | No |
| `f_path_defs`14209 | Module-qualified definition; source directory; whether source name is Base | No |

Each maps one complete top-level event to one top-level event. Imported fills
can alter their own child list, so this is not a claim about flattened counts.
Local later law fills are separate events; `p140p_context_publish`58443 prepends
a new event, without changing the earlier law. Name qualification preserves an
imported fill's canonical law name by its temporary `ImportFill` kind.

`f_graph_finish_indexed`14671 computes `filled` and `fragment` independently of
the later name-validation result. It then combines them with the current graph,
source list and diagnostics. `f_graph_finish_module`14689 appends prior+fragment;
it does not retroactively resolve or rewrite earlier user bodies.

A successful parser hit certifies the retained **raw** prefix only through the
existing private cache producer: exact initial scope, source origin, text prefix,
checkpoint/lookbehind and first resumed token. A new capability must additionally
bind the exact imported prior, aliases, namespace, logical source directory,
Base/native marker and producer. Do not accept those as unauthenticated host
assertions. Logical-path changes remain the concrete counterexample documented
in [freshening-prefix-audit.md](freshening-prefix-audit.md).

## What remains global

`f_graph_fresh_names`14732 scans ordered raw declarations against an incoming
name index. A suffix can introduce a duplicate or a legal/illegal law fill.
For example, after retaining `def first() -> U32: 0`, appending another filled
`first` parses but fails freshness. Reusing old overall success would lose this
error even though the old prefix data is unchanged.

There are two relevant name phases: raw pre-qualification names in
`f_graph_finish_indexed`, and completed names checked against `baseNames` in
`f_prefix_ready_validated`15554. Their indexes are not interchangeable.
`f_prefix_names_extend`15500 replaces entries in order;
`f_prefix_ctors_extend`15506 retains the first constructor name and descends
children. Any prefix reuse of those operations must retain the exact actual
after-prefix index, including overwrite/first-match behavior.

`f_validate_result`13497/`fpe_defs` select existing term errors; graph freshness
errors can take priority over them. `f_graph_module_error`14695 renders against
current source text/ranges. Keep current whole-request validation and error
selection initially. An invalid parse also changes `f_context_defs`' complete
flag; use the ordinary fallback rather than splice a successful completed prefix.

Rebuild current `Loaded` count/path/namespace/aliases, import metadata, source
list/ranges and suffix from the new request. Never return an old complete
`FIndexedCompletion`, carrier or `FPrefixLoad` merely because its prefix matched.

## Larger compositional step

A private checkpoint could carry the actual raw parser cut together with its
contextual/completed prefix, freshened prefix and exact ending fresh counter.
Once the current parser finishes successfully under the same bound context,
complete only its new suffix and join the retained completed prefix; freshen
the entire new suffix at the retained counter. The current strong completed-
prefix comparison remains a useful diagnostic oracle while proving this
construction bridge. Removing it requires tying both products to the same real
parser checkpoint, not independently pairing equal-length caches.

This removes repeated contextual lowering, imported-fill mapping, module/path
reconstruction and freshening of a warm unchanged prefix. It does not remove
cold acquisition, parsing the changed tail, prefix text comparison, list joins,
validation, checker admission or suffix checking. Measure each rather than
adding unrelated stage-level gains.

Checker prefix reuse remains a separate premise. Existing `p140cp_admit`59108
requires the producer epoch, actual freshened prefix, ordered suffix declaration
views (Foreign bodies retained) and complete fresh-ID bound. `signature_mode`
and `dg_event_publish` observe later declarations; a changed suffix type,
Foreign body, declaration order or binder numbering can invalidate old checking
even when the completed prefix data is identical. Carry the actual checkpoint
world/seen only after those current gates succeed. Parser evidence alone cannot
replace them.

The next economical discriminator is therefore **warm completion+freshening
prefix reuse while all global validation and checker gates remain original**.
Only after a real gain should validation adopt separately captured raw-name,
completed-name and constructor-index states. Required negatives remain changed
path/context, duplicate suffix, law-fill validity change, invalid parse followed
by recovery, and binder-count changes. No concrete falsifier was found for the
data-reuse premise with all the stated successful-parse/context conditions.

## Current conservative prototype bridge review

Read `freshening/{core,loader,session}-v01.bend` after this investigation. No
source-semantic blocker found: the loader still runs the original completion and
validation, applies exact `p140p_defs` only to successfully completed definitions,
and retains original error/freshening fallback. Its top-level cut comes from the
actual parser accumulator. The session binds the seed to the caches and rolls
back the complete prior session on an emission error; planned-emission commit
matches the existing `p140s_finished` policy. Direct helper calls remain private
trusted-construction interfaces, not authentication of arbitrary host cache
objects. Full loader differential/error-recovery tests are still required; this
review supplies no execution evidence and does not implement the broader skip.
