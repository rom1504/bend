# Constructor existence: reuse a fact-building pattern, not ownership answers

The current source has two nonrecursive callers of `constructor_exists`:
`constructor_names` at line8943 and `base_prefix_ctor_disjoint` at line10230
of final03 (`31e1b13a…`). The Phase144 integrated diagnostic attributes142
samples/4.544 sampled-period CPU-equivalent seconds to this helper during the
37.672-second checking/publication interval, and81/2.592 during the3.921-second
checked-context interval. These account for all223 observed samples. The first
interval includes both checker and prepared-prefix admission work, so this does
not independently separate the two consumers. Sampling is not a measured
removable latency, and the helper cannot explain the whole checking budget.

The existing `P144OFacts` ownership answers cannot be reused as existence
answers:

- `nc_ctor_owned` selects ADT parents and Ctr children, then returns the first
  qualifying parent's ownership bit. Unowned constructors produceFalse.
- `constructor_exists` inspects children of **every non-BookCache parent**, even
  Def or Absent parents, and accepts the first visible **non-Absent** child,
  even a Def or concrete index node. It ORs results across parents.
- Child lookup is first-match per parent. An Absent child masks a later Ctr of
  the same name in that parent; another parent can still witness the name.
  A child BookCache is authoritative even on a miss and masks subsequent
  children, so blindly collecting descendant names is incorrect.
- Checking uses the **previously accepted event prefix** (`seen`), not the
  checker's world containing all declared headers. Current ownership facts are
  attached after checking/annotation to the full checked source. Using that
  full catalogue at the event guard would falsely report the current ADT's own
  constructors as duplicates. This is a provenance difference, not a missing
  API parameter to paper over.

A bounded candidate reuses the existing exact string-key Patricia membership
helpers while keeping those meanings separate. It builds a private
`P144CEFacts{members,valid}` once for each immutable consumer batch. Each parent
gets its own first-seen index. Every first non-Absent child enters a global
membership union. Top-level BookCache parents are skipped. Encountering a child
BookCache or invalid scalar name/kind refuses the fact result; queries retain
the unchanged original implementation. Unicode validation uses the existing
nonthrowing name guard, before name hashing or eager new comparisons. Invalid
query strings also retain the original comparison path.

`p144ce_names` applies this only to batches with at least two constructors;
zero/one-constructor batches use the trivial/original route. `p144ce_disjoint`
builds once for its entire recursive traversal. The public original functions,
KWorld, event publication, source/proof checks, final verifiers, runtime and all
existing cache representations remain unchanged. There is no cross-request
reuse or authority inferred from arbitrary caller-supplied facts.

This is83 physical lines of isolated fact/batch logic, with separate controls and consumer
workload helpers. It may still lose on small or early-rejecting batches: index
construction scans all prior child names, allocates two index families, and
needs destruction. A complete consumer comparison must charge that cost. The
single-constructor fallback avoids an obvious low-payoff case but is not a
measured profitability model.

Prepared root-only gates are
`selfhost/build/phase144/existence-source01/jobs.json`. The appended source is
`51f985019b2534b836bc01028625aef73184dc0227d16ae79808231038ef0689`;
all original final03 bytes are its exact prefix. There are no overrides.
The27 controls cover explicit expected answers plus the independent originals:
first-Absent masks, per-parent OR, owned/unowned/non-ADT/non-Ctr cases, empty
names, FNV collision names, Unicode, nested descendants, child-cache misses,
concrete index variants, duplicate diagnostics and recursive disjointness.
They have been prepared, **not executed by this audit**.

The proposed first performance screen uses the exact first256 and1,024 ordered
declarations of the actual compiler (159 real ADTs in each), parsed by checked
Bend with its prepared Base scope. Parsing is outside timing. It then compares
complete event-error/book-put replay and the full recursive prefix-disjoint
consumer on identical parsed values, including candidate fact construction and
host GC. These are compiler-derived consumer replays, **not captured checker
invocations or native timings**. No individual string-lookup microbenchmark is
substituted for the complete consumer.

If this screen is neutral or loses, stop before native integration. If the
prefix-disjoint consumer wins while event batches lose, retain only that
adapter; it naturally amortizes one index over thousands of names. If both win,
a later small native replay and exact complete DResult/request output gate can
justify separately overriding the two consumers. A persistent per-checker-prefix
fact would require update/removal invariants for law fills and unusual childful
definitions; that larger state change is deliberately deferred.

Evidence: `research/phase144/integrated-profile-v2.json`, final03 source, and
`selfhost/tools/performance/phase144/existence/`. No compiler target, benchmark,
production mutation, or new proof was run for this audit.
