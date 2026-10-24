# What the experiment changes about the next step

The full compiler contains the same improved query paths as the small proxies.
Its cold self-request improves6.94% in one same-source pair and the complete
fixed-input build improves7.26%, while the rotated three-small-request screen
is neutral. The remaining problem is profitability
and workload coverage, not failure to emit the demonstrated readers.

## Narrow preservation to complete consumers

The broad policy creates148 additional calls to still-owning `dn`/`dk`/`dc`.
That is a static observation, not measured dynamic overhead. An unchanged
compiler source built by the new generator was about1% faster on small requests,
so the extra calls have not themselves been demonstrated to cause a slowdown. Preserve the useful
query boundaries while allowing plain owned projections to inline again. A small
structural policy experiment should precede a new semantic representation: the
same existing return-shape walk could distinguish a consuming helper computation
from a bare field-return body. Keep legality and final verification unchanged.

Estimated information cost:30–90 minutes for a source-checked ablation, the frozen
query pair and small native requests; full acquisition/qualification remains extra.
Estimated whole-request gain:0–5%, uncertain until dynamic measurement. The proxy
must retain the current improvements and test original, unfused source too.

## Diagnose the surviving BookCache predicate

`p137q_is_cache` remains owning while `is_adt`/`is_ctr` borrow. There is no established
"eight-character String limit." The audit instead found a concrete hypothesis:
virtual ready-helper specialization allows depth16, but an ordinary helper path
permits depth<8; recursive equality over the nine-character literal can encounter
that smaller boundary through `Char.is_eq`. Capture the actual rejection reason
before changing a limit. This is a source-grounded hypothesis, not a demonstrated
refusal. Existing stack, fuel and final verification obligations stay in force.

A diagnostic should take under20 minutes using the existing checked plan API.
The complete gain is unmeasured and bounded by the affected lookup work; do not
promise the31% proxy gain again or sum overlapping profile contexts.

## Remove ownership queries rather than accelerate every visit

The current constructor index is not an exact substitute for `nc_ctor_owned`.
It loses parent ownership and has different nested, cache and shadowing semantics.
The next useful ceiling is an exact ownership summary built before erasure,
where Phase136 found real calls. Preserve first-match false entries before
projecting a possible set of true-owned names. Include construction/invalidation
cost and the raw `nc_constructors(source,source)` path.

[Bounded source audit and stopping rules](../../selfhost/tools/performance/phase137/wide/ownership-alternative.md).
Phase135's late summary did not establish an end-to-end win. Moving it earlier
without pricing it is not a result. Rough opportunity: part of the measured7.9%
active-context share, not an additional independent7.9% on top of query gains.

## The larger speed target still needs structural experiments

This phase does not establish a path from roughly six-minute cold builds to60s.
It makes a small piece of the existing representation cheaper. The compact/indexed
IR and stable semantic-unit direction remains relevant, particularly eliminating
repeated name scans and preserving immutable facts across stages. Test one real
parser/index workload and one lowering owner unit before changing the whole IR.

The experimentation lesson is also concrete: retain actual source workloads,
independent answers, call-path evidence and fast calibrated timings; then test
whole native requests. A large kernel win need not improve small compilation
requests. Native policy experimentation could eventually avoid rebuilding a
complete compiler merely to change a legality-preserving profitability choice,
but a new search/cache framework has not yet earned its cost here.
