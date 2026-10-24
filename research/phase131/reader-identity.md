# Exact String identity: law, reachable reader, and a negative first discriminator

The selected compiler has a provable positive identity shortcut: for valid,
immutable Strings, `p88_string_eq_go(x,x,same) = same`. The Phase131 checked
proof uses the exact selected source bodies and proves Word/U32/Char comparison
reflexivity; it does not assume an opaque comparator. See
`selfhost/build/phase131/laws-string-reflexivity01/report.json`,
`laws-string-bridge01`, and `selfhost/tools/performance/phase131/laws/`.

The implementation hypothesis is deliberately narrower: at the private
borrowed reader's loop header, equal **complete 64-bit Term words** and pending
True return True. Unequal words always retain ordinary content comparison.
Checking only heap locations would be wrong. The existing outer owner must
remain held; the public alias/profitability guard and owning fallback are not
changed. The law covers recursive shared suffixes as well as initial roots.
Malformed raw runtime values are outside the typed source theorem: skipping a
malformed tail could change its later fail-stop behavior even if the current
constructor discriminator is retained. This is not a general Term equality
law, and in particular says nothing about floating-point or user equality.

## Actual self-hosted code composition

`self-composition-qbe01/report.json` compares Q1 (emitted by the qualified parent)
with Q2 (emitted by final N1) for identical final compiler source. Q2 adds private
borrowed `String.order`, `String.eq`, and `p98_tag_eq` readers. Order and equality
call the already scalar `String.cmp` reader directly, avoiding its public owned
product reconstruction. The tag reader calls the private `p88_string_eq_go` in
its ordinary KTerm branch; other branches contain specialized comparisons.

The unchanged 250-line `p88_string_eq_go` reader is actually reachable from ten
direct caller sites, including `f_eq`, `kp_eq`, `has_name`, `norm_exact_names`,
and both tag readers. The Q2 image has 1,072 direct public tag-equality callsites
and 426 direct public String-equality callsites. These include real compiler
analysis, context and native-lowering callers. Counts include wrapper and
continuation functions and exclude generic scheduler edges; they are static
reachability evidence, not dynamic frequencies or an allocation census.

Receipts: `selfhost/build/phase131/self-composition-qbe01/report.json`,
`self-composition-machine01/report.json`, and the direct-call inventory in
`reader-identity-probe01/report.json`. Q1 and Q2 have respectively 62,809/63,239
functions and 104,373,390/107,059,385 QBE bytes; both have 45,977 static words.
The increased image size is a real cost of the integrated backend capabilities.

## First cheap experiment: compiler-derived index queries

The existing checked native index-read proxy contains **byte-identical** private
reader code to Q2: SHA256
`7857ba734e82351b4b08d1907853fe2eb795537f553b2beb0b5d10f587af7d6a`.
`reader-identity-probe.py` verifies that identity, then prepares two isolated
QBE-only diagnostic products. One counts reader calls, loop steps, and full-word
identity with pending True. The other is a clean branch-only shortcut ceiling.
Neither patch is production compiler output or independently verifier-qualified.
The original checked source, ordinary oracle, qualified compiler and runtime
remain unchanged.

Both products build against the existing runtime and pass the independent
index-version/checksum oracle, ordinary five-line output and parameterized
query output. Diagnostic counters run with one CPU thread and GPU off. Their
execution times are not performance evidence.

| Probe | Reader calls | Reader steps | Identical + True steps | Fraction |
|---|---:|---:|---:|---:|
| Ordinary five sizes | 674 | 1,368 | 24 | 1.75% |
| Initialization + 8 repeated 256-name queries +2 warmups | 512 | 1,029 | 6 | 0.58% |

This is **negative prioritization evidence** for this particular private reader
on this index proxy. The low coverage does not justify a timing campaign or full
compiler rebuild. A likely reason is the existing public adapter's deliberate
refusal of aliased RFC roots; those comparisons use the owning fallback instead.
That mechanism is source-grounded, but the counters do not prove the fraction
of all comparisons using each path.

Evidence: `selfhost/build/phase131/reader-identity-check01/report.json` and
`reader-identity-check01-guard`. The full guarded build/output/count experiment
took 1.44 seconds and peaked at 123MB. A better next discriminator is a real tag
query whose borrowed string inputs are held by an outer product, allowing the
private reader to be reached without the public two-root alias refusal.

## Positive transfer discriminator: actual occurrence counting

The existing `compiler-uses` proxy copies the real `nq_uses` algorithm and the
new composable tag reader. Its private String reader again matches N2 exactly.
On its ordinary ten-line oracle, identity+True covers 201/558 reader steps
(36.0%). On ten repeated queries over a shared 255-node source tree, it covers
8,448/28,028 steps (30.14%). Original, diagnostic and clean ceiling all pass the
independent output oracles. The guarded build/count screen took 1.36 seconds.

This is a useful difference from the first proxy: borrowing under the held
KTerm ancestor makes the private equality optimization reachable. It is still
coverage, not a measured runtime gain. The root-owned CPU3 timing plan is
`reader-identity-uses-timing01/jobs.json`: five paired clean observations at the
previously calibrated 2,047 repetitions. Neither counter binary is timed.

Evidence: `selfhost/build/phase131/reader-identity-uses-check01/report.json`.

## A different ownership boundary: consume both roots, skip comparison

The public owning adapters offer a separate legal opportunity. On equal full
Term words (and pending True for `_go`), they can return True **after both
original root sinks**, in original order. They do not borrow aliased roots or
weaken the existing guard. The false branch retains the entire original guard,
reader, fallback and sink sequence. For same RFC count 2, the first sink reduces
the count 2→1 and the second 1→0 frees the object. Extra retained aliases remain
live; trivial String values need no reclamation. The runtime reviewer checked
this against the actual `term_drop` implementation. Typed finite immutable
String provenance remains necessary; arbitrary corrupted runtime inputs are
not covered by the source law.

The exact-N2 public adapters occur unchanged in the index proxy. Frequency-only
instrumentation sees 1,011 identity-True calls among 1,685 adapter entries (60%) in
ordinary controls, and 3,328/3,840 (86.67%) in the repeated-read batch including
initialization. Both the frequency product and the clean branch/two-sink ceiling
pass the independent five-line and repeated-checksum controls. The experiment
took 1.38 guarded seconds; it does not yet establish a speedup.

Evidence: `selfhost/build/phase131/owning-identity-check01/report.json`.
The separate clean timing plan is `owning-identity-timing01/jobs.json`, with
five paired observations at 1,600 repeated 256-name queries. The old private-reader
negative result remains relevant and is not relabeled a success.

## Clean timings and next discriminator

Both root-owned five-pair blocks passed all output checks. The private-reader
ceiling on `nq_uses` changed median process time from 0.480943 to 0.479595 seconds:
only 0.28% lower. Pair ratios varied 0.925–0.999 and the median of pair ratios was
0.982; the different summaries illustrate noise at this effect size. Internal
millisecond medians were478→477. Despite substantial identity-step coverage,
this is not a compelling new optimization to select on its own.

The **owning-adapter** ceiling is much stronger on real index operations:
median process time 0.429128→0.343274 seconds, **20.01% less**. All five pair
ratios are 0.799–0.817; median internal query time 425→339ms, 20.24% less. The
important work removed is the aliased-root owning comparison and its traversal,
while both root consumptions remain. These are extracted compiler-workload
gains, not whole-compiler throughput or general generated-program gains.

The next falsifier preserves the final N2 compiler image's exact generated QBE
except for the two public adapters. `owning-identity-full-probe01/ceiling.ssa`
has 107,060,260 bytes, just 875 more than the frozen source QBE, SHA256
`cba4ca646bb27fa5e139eb71453d8c4b3f1a4ed6778b32b232b9c3889ec329f6`.
The private-reader change is deliberately excluded. Whole-request correctness
and controlled timing must decide whether a checked Bend implementation is
worth acquiring; the QBE patch itself is unqualified and never promoted.

The whole-compiler ceiling then passed all18 exact-output requests in three
rotating paired rounds. Geometric compiler request time fell **2.93%**: lexer
6.584% less, closures2.209% less, and Map0.118% more. The20% index-proxy win
therefore transfers, but its compiler-wide impact is much smaller. Do not call
it a20% compiler improvement or infer a newly measured upstream ratio. Evidence:
`selfhost/build/phase131/owning-full-timing01/timing/report.json` and
`owning-full-timing01/summary02/report.json`.

The first summary tool attempt expected a top-level `manifest` field absent
from the generic profiler report and failed with `KeyError('manifest')`.
This affected reporting only: the18 timing/output observations had completed
successfully. The root retained that failure and used a separate summary-v02
which authenticates the actual manifest input pin. Neither the measurement
runner nor the results were changed to repair the summary.
