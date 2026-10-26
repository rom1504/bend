# Residual cold native profile after Phase143

The qualified Phase143 N2 compiles the unchanged Phase142 source to its exact
115,909,112-byte QBE oracle. This is the same compilation task used for the
374.677→296.541-second clean comparison, with a fresh process and the same Base
carrier. Only the retained compiler object was relinked against the authenticated
context runtime; source and generated compiler instructions were not rebuilt.
Exact inputs, counts and comparisons are in [residual-profile.json](residual-profile.json).

The capture contains **10,083 samples**, zero drops and zero overruns, with
**99.585% sampled-thread/process CPU coverage** and plausible timer delivery.
9,772 samples have a known active dispatch; all372 eligible libc leaves recover
a machine caller using the pinned unwind table. Unknowns remain in denominators.
Main-thread sampled CPU is322.679s, process CPU inside that window324.023s;
whole child wall time324.306s and peak RSS1,046,908KiB. This is diagnostic timing.

The296.541s clean reference belongs to N1; N1/N2 program objects are byte-identical,
but the ELF hashes differ. The diagnostic observation is9.36% above that historical
clean observation. This is neither a fresh N2 clean timing nor a precise profiler
overhead estimate. The previous diagnostic capture took386.466s; its larger
absolute time and changing proportions must not be confused with controlled
clean speedups.

## What disappeared and what remains

Both captures used a32ms period. The last columns below show count×period, an
**approximate diagnostic CPU amount**, not clean time or exact function cost.

| Active computation | Previous / current samples | Current share | Previous / current diagnostic seconds |
| --- | ---: | ---: | ---: |
| `nc_ctor_owned` | 556 /594 | 5.89% | 17.79 /19.01 |
| `String.append` | 552 /543 | 5.39% | 17.66 /17.38 |
| `p111v_get` | 490 /446 | 4.42% | 15.68 /14.27 |
| `f_find` | 464 /442 | 4.38% | 14.85 /14.14 |
| `p131i_insert` | 204 /376 | 3.73% | 6.53 /12.03 |
| `lookup` | 753 /274 | 2.72% | 24.10 /8.77 |
| `constructor_exists` | 182 /206 | 2.04% | 5.82 /6.59 |
| `index_remove` | 559 /69 | 0.68% | 17.89 /2.21 |
| `nc_occurs` + `nc_occurs_list` | 402 /3 | 0.03% | 12.86 /0.10 |
| `nb_contains` | 413 /30 | 0.30% | 13.22 /0.96 |

The old repeated occurrence scan is essentially gone in this observation.
Index removal, general lookup and linear visited-name work also fall sharply.
`dg_event_publish` has zero active samples; this does not prove publication has
zero cost, since the new publication route executes other functions.

Conversely, constructor ownership, parser-prior search, verifier lookup and text
construction retain roughly their old diagnostic amounts. Their increased
percentage mostly reflects other work disappearing. Patricia insertion grows
across several contexts; this is consistent with added indexed work, but it is
not solely attributable to the checker from an active-helper count.

All `p111v_*` active owners together occupy1,247 samples (12.37%, about39.90
sample-period seconds), versus1,283 previously. This syntactic group is neither
the complete independent-verifier cost nor an isolated final-verifier phase.
Other helpers perform work for the verifier and these names can appear at
multiple pipeline stages. The exact milestone probe is intended to resolve this.

Physical `term_drop` + `span_fade` account for2,594 samples (25.73%). The sampled
borrowed string-equality worker accounts for544 samples (5.40%). These overlap
the active computations above; summing them would invent extra headroom.
Direct register-bank copying has226 samples, plus372 libc samples whose caller
is `p111_set_regs`. This remains distributed runtime work, not one backend phase.

## Experiments this supports

1. **Exact parser-prior lookup and constructor validation indexes.** `f_find`
   remains concentrated in the first60 CPU seconds; `constructor_exists` in
   roughly30–90. Preserve first-match and ordering semantics, and measure
   index construction/destruction together with queries. `f_find` plus `f_eq`
   represents525 samples (5.21%); eliminating this alone cannot approach50s.
2. **A shared constructor-ownership view.** `nc_ctor_owned` is the largest
   named active computation, concentrated around90–180 CPU seconds but also
   present later. Its5.89% share justifies a fast actual-consumer experiment;
   it does not justify a promised large whole-build speedup by itself.
3. **Compact verifier values and shared exact context preparation.** The
   roughly unchanged verifier-helper mass is larger than one lookup. Determine
   initial versus final verification with exact markers before choosing which
   work can be represented once. Preserve the independent final gate.
4. **Representation and output construction.** The final~60 CPU seconds are
   dominated by String append and QBE text helpers. Allocation/reclamation is
   substantial throughout. Prefer removing an intermediate representation or
   reconstruction over another name-specific helper optimization, but establish
   actual complete-stage ceilings first.

The displayed CPU ranges are approximate sample-order windows, not measured
stage boundaries. The new retained-object stage probe records native clocks and
delivered-sample ordinals at actual dispatch boundaries, including raw lowering,
initial optimization, verification, observer composition, registry and rendering.
Its small exact-output marker gate must pass before a full run. No claim that
these independent percentages add up to the sixfold improvement needed for50s
is supported by the current evidence.
