# Active-ray regression attribution

The first actual checked candidate screen regresses the active-ray point
`coverage.active(256, 2240)`: baseline median 88.733 ms versus candidate
120.308 ms, a 35.6% increase. Observed baseline range is 88.447–93.491 ms;
candidate is 119.511–126.682 ms, so the ranges are disjoint. Candidate halves
still drift faster by 7.4–15.6%; this is a short screen, but drift does not
explain away the observed gap. Root's separate profile reports more guard
samples and allocation. Promotion is blocked pending attribution and correction.

The emitted module supplies a concrete explanation to test. The timed export
is **`coverage.active`**, which already takes the older private scalar-root
route. That body has a complete guard but no `regionProofOpen` scope. The new
finite root for `bench` is unused by this benchmark. Seven new small helper roots
can therefore pay the complete host/dependency checks repeatedly in residual
calls. The DataView guard fix also adds legitimate work to every unscoped host
check. The diagnostic must distinguish these effects before changing source.

`ray-ablate.mjs` binds the actual checked02 module SHA-256
`46a60f5fb0094dfeea09a222d803ce7a6ffb091f50b59c2fbf28e809154c24bd`.
It changes no arithmetic or tree computation. It creates clean and diagnostic
variants that disable exactly selected conditions:

| Variant | Attribution |
| --- | --- |
| candidate | Exact checked candidate |
| no-finite-roots | Cost/benefit of all eight new scope entries |
| no-helper-roots | Disable seven helper scopes; retain unused bench scope |
| no-finite-calls | Retain scopes, disable direct finite selector branches |
| no-finite-both | Retain cast and DataView correction, disable both finite routes |
| no-dataview-guard | Remove only the new guard-extension checks |
| no-finite-both-no-dataview | Attribute remaining cast/output differences |

The two DataView-removal variants are deliberately unsafe negative controls.
They cannot become production candidates. The clean original baseline and
TypeScript modules are separate timing roles. Diagnostic counters record actual
finite root attempts/entries, finite selector entries and total/unscoped host
checks. `ray-ablation-controls.mjs` checks the fixed exact output for every
diagnostic variant and verifies disabled-entry counts. It does not claim
adversarial correctness for removed guards. Root executes all tools serially;
these tool inputs were authored without running them.

A small potential profitability rule is to require a useful finite callee with
a **non-scalar signature** before adding a new root scope. It reuses the existing
`j_region_signature` predicate. Tree zip/leaf/stat selectors touch private sums;
ray min/max-like selectors are entirely scalar. Existing proofs can still use
scalar finite selectors, but tiny scalar selectors alone would not purchase a
new expensive scope. This is a proposal pending ablation, not a canonical edit.
Broadening the older scalar root's proof ownership is a different change with
additional scope controls and is not required to test this narrow rule.

## Root's ablation result and selected successor

`ray-ablation-controls01` passes all seven fixed-input diagnostic variants.
The candidate executes **1,968 successful new scopes**, exactly 984 in `fmax0`
and 984 in `shade`; there are 1,968 direct `fmax0.go` selector entries. Total
full host checks are 4,941. Disabling the new roots removes all those entries
and reduces full checks to 2,973, an exact reduction of 1,968. These are
successful tiny scopes, not unsuccessful guard attempts. The new outer `bench`
wrapper has zero attempts because it is not this benchmark's entry.

The separate three-round clean screen completes in 30.044 seconds:

| Variant | Median ms | Observed min–max ms |
| --- | ---: | ---: |
| baseline | 98.100 | 88.553–109.121 |
| candidate | 139.725 | 119.522–146.206 |
| no finite roots | 91.479 | 90.129–110.801 |
| no helper roots | 90.809 | 90.739–110.614 |
| no finite calls | 121.370 | 121.125–141.333 |
| no finite roots or calls | 109.535 | 93.965–119.363 |
| no DataView guard (unsafe control) | 118.614 | 117.343–134.712 |
| neither finite route nor DataView guard (unsafe control) | 98.802 | 89.722–107.233 |

This is a noisy short screen; do not infer precise additive costs by subtracting
its medians. The entry counts and disjoint candidate/no-helper-root ranges
establish the useful mechanism: 1,968 extra complete guard boundaries cost more
than the tiny direct selectors save. Removing the DataView correctness guard
is neither necessary nor acceptable as the fix.

The design was updated before changing the source. The checked03 proposal
changes only `j_finite_useful`: scalar signatures continue to the next proved
definition; a non-scalar signature then undergoes the original finite readiness
check. The existing signature predicate checks both arguments and result, so
tree-producing leaf selectors still qualify. The finite module is now 166 lines;
its new hash is
`8998f43394e465ab9d3add60ca2dd432b633faca57249dc0063d4222cb4a1cf6`.
Checked02 and all failed/regressing evidence remain unchanged. Root owns the
separate DataView guard refinement and fresh checked03 validation. Actual
successor gains and semantic gates are still pending at this report version.

Root's fresh `checked03` build passes in 42.175 seconds (reported peak process
tree memory 1.142 GB). That establishes a checked compiler artifact for the
profitability successor and guard refinement; it is not yet a performance or
actual finite-fixture result. Checked02's tiny-scope policy is rejected and its
above measurements remain part of the evidence.

The fresh `candidate-screen02` now reports active-ray baseline 90.033 ms versus
checked03 89.664 ms (1.004×). Ranges overlap: 88.645–100.305 ms baseline and
88.725–104.788 ms candidate. This preliminary screen resolves the large tiny-
scope failure but does not establish exact parity or a ray speed improvement.
The candidate remains about 71.7× slower than TypeScript at this point. The
following five-round result supersedes the screen's apparent parity.

## Final active-ray measurements: smaller cost remains

`variation-final01` completes five paired rounds at each active-ray point.
At 64 pixels/start 2440, median time changes from 25.9419 to 26.3763 ms (+1.67%).
Ranges overlap widely: 20.4046–27.2601 ms baseline and 20.5320–28.4591 ms
candidate. Many within-process halves speed up by 35–44%, so this small median
difference is weak evidence.

At 256 pixels/start 2240, medians change from 85.8160 to 88.8849 ms (**+3.58%**).
Ranges are disjoint: 85.4208–87.4211 ms baseline and 88.3489–98.9662 ms candidate.
All five paired rounds are slower by 2.95–13.21%. Candidate half-drift ranges
from +1.35% to +17.13% (mostly around +8%), versus +3.32% to +5.06% baseline.
This is a remaining regression signal, not a zero-cost result. The candidate is
71.59× slower than TypeScript at the 256-pixel point and 87.72× at 64 pixels.

The final module has **zero new finite roots** and four finite selector sites,
so the 1,968 extra tiny scopes are gone. The mandatory DataView correctness guard
still adds work to existing unscoped checks. It is a plausible source of the
remaining overhead, alongside changed generated-code shape; the final minimal
guard version has not been isolated by another ablation, so exact attribution
is unproved. Keep the correctness fix and report this tradeoff explicitly. The
phase result improves the finite tree workload but does not improve every
generated program or solve the larger active-ray performance gap.
