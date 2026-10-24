# Full-source active contexts: the next target is concrete

**`nc_ctor_owned` is the strongest bounded next experiment for native self-build
speed.** It is the largest active owner in the full compiler-source request and
performs a whole-book scan for each constructor-ownership query. Investigate a
borrowed-observer version and a once-per-checked-book constructor-ownership table
before considering a global tag/IR rewrite.

The separate diagnostic N2 run retains 11,852 samples at 32ms, with zero
loss/overrun and adequate CPU coverage. Its entire 107MB QBE output matches the
pre-existing oracle. Runtime counters were disabled. This is not a clean timing
run and supplies no new speed or overhead ratio.

| Active lowered owner | Fraction of all samples |
|---|---:|
| `nc_ctor_owned` | 7.48% |
| `lookup` | 5.43% |
| `f_find` | 5.20% |
| `p111v_get` | 4.43% |
| `String.append` | 4.17% |
| `index_remove` | 3.52% |
| `nb_contains` | 2.98% |
| `has_name` | 2.92% |
| `p88_string_eq` | 2.72% |
| Unknown | 2.56% |
| `nc_occurs` | 2.16% |

These are active dispatcher contexts, including private callees, not inclusive
source stacks. `nc_ctor_owned` accounts for 13.72% of sampled `term_drop`/`span_fade`
work (3.97% of **all** samples), and 7.71% of the borrowed equality worker's samples
(0.73% of all). That connects its repeated queries to both reference-management
and comparison cost; it does not establish where the dropped objects were created.

The selected compiler source implements `nc_ctor_owned` as a recursive book scan:
for each definition it checks the `ADT` tag, searches its constructor children,
and either returns that ADT's ownership flag or continues. It is not merely
reading a precomputed Boolean. Its observed 7.48% is a useful local ceiling:
removing half this context's work would suggest about 3.7% full-request saving,
not a promised 7.5% or an unexplained 30% gain.

A minimal experiment should retain the actual full compiler book and query names,
compare the existing function against a borrowed observer and a keyed summary,
and verify identical answers on valid and adversarial small books. Preserve
first-match behavior, duplicate names, absent constructors, raw/malformed fallback
and scope identity. Build the summary once from the immutable checked book, not
once per lookup. Then measure whether comparisons and reference transitions
actually disappear before rebuilding the complete compiler.

Two adjacent opportunities are also concrete. `f_find` is a linear name search;
`lookup` switches to an index only for a `BookCache`-headed book. Borrowed equality
samples are distributed across `has_name` (23.05% of equality samples),
`p88_string_eq` (14.63%), `f_find` (9.57%), `nb_contains` (8.60%), `nc_ctor_owned`
(7.71%) and `lookup` (6.12%). This favors eliminating repeated searches before
optimizing one character-comparison instruction or rewriting all symbolic tags.
The sample does not measure identical query-key recurrence; obtain that from a
small retained query trace or a source-level proxy.

The verifier remains relevant: `p111v_get` owns 39.32% of sampled hash-worker work,
though that is only 0.78% of all samples. Distinguish this full-source workload
from the short lexer request, where verifier/hash work has a larger share.

[Exact source and executable identities, context/leaf tables and quality gates](full-context-results.json)
are retained separately from [the original physical capture](full-profile-results.md).
Full local evidence is in `selfhost/build/phase131/final-full-context-analysis01/`.
