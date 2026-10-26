# Immutable existence facts: retain the large-batch consumer only

The isolated source passed independent Bend checking and all27 finite controls.
Both actual compiler-prefix replays returned the exact expected successful
results. Root ran all target jobs; `existence-summary01/report.json` derives the
figures below from the frozen `existence-screen01/report.json`.

Four alternating original/indexed observations were made for each consumer,
with one complete consumer invocation per observation. Each prefix has159 actual
compiler ADTs. Candidate timing includes fact construction and use. Inclusive
timing additionally includes forced synchronous Bun GC; this is not a native
reference-count teardown measurement.

| Parsed prefix / consumer | Original median | Indexed median | Median paired ratio | Original/indexed including GC |
| --- | ---: | ---: | ---: | ---: |
| 256 declarations / event guards + publication | 142.80ms | 164.50ms | 1.1567 | 197.51 /218.65ms |
| 1,024 declarations / event guards + publication | 211.53ms | 230.33ms | 1.0958 | 279.49 /299.43ms |
| 256 declarations / complete prefix-disjoint traversal | 199.12ms | 3.964ms | 0.01993 | 254.73 /40.35ms |
| 1,024 declarations / complete prefix-disjoint traversal | 504.53ms | 11.856ms | 0.02263 | 573.64 /79.40ms |

The disjoint inclusive paired ratios are0.15858 and0.13416. Its candidate pure
times are short, and the first1,024-case candidate observation was36.74ms before
later10.61–12.92ms observations. Retain that warm-up/order evidence; do not turn
these few hosted measurements into confidence intervals or a native speed claim.
The more complete inclusive observations still strongly favor the large-batch
consumer. Per-ADT event facts lose because the same context is rebuilt too often.

The decision is therefore to prepare **only** the `base_prefix_ctor_disjoint`
override. `constructor_names`, `event_error` and `constructor_exists` remain
unchanged. The fact builder is used once for the entire recursive disjoint
traversal, rather than once for each constructor query or ADT. This is the
reusable structural opportunity shown by the experiment: expose the immutable
query batch and amortize one exact analysis over it.

The disjoint-only source candidate is
`selfhost/build/phase144/existence-disjoint-source01/compiler.bend`, hash
`98cc7220b26a95ee2791d928bcc17dfc68ffe5494899665fee671a8e46195797`.
It changes one existing declaration and adds16 helper/control declarations;
all other original declarations, protected verifiers and explicit proof roots
are preserved. The production entry calls the exact already-screened batch
helper. There is no KWorld update, global cache, runtime or backend change.

`disjoint-reference-v01.bend` retains the original traversal with only its
definition and recursive references renamed. Its body is mechanically compared
with final03 during composition. Updated controls use that independent original,
the private indexed implementation and the selected entry. This avoids the
otherwise-tautological test of the new implementation against its own override.
Prepared root-only gates in `existence-disjoint-source01/jobs.json` check the new
source, rerun27 controls and compare three complete emitted QBE products with
the actual current final03 hosted API. They have not been executed as part of
this preparation. No native image has been acquired for this change.

Correctness evidence is checked source, finite explicit oracles and a source
audit of first-match/per-parent masking, concrete index variants, empty keys,
valid Unicode names and child BookCache fallback. Malformed-Unicode fallback
has been source-reviewed but is not separately exercised by these27 controls.
It is not a new formal theorem or full
compiler conformance proof. Unchanged event/name implementations preserve the
negative result rather than hiding it behind the disjoint win.

The earlier profile attributes only223 samples (7.14 sampled CPU-equivalent
seconds) to **all** constructor-existence calls, including the event consumer we
have not optimized. Thus the dramatic hosted batch reduction does not imply a
dramatic whole-compiler reduction. Native complete-request measurement remains
the adoption gate; it should be combined with other validated changes rather
than trigger a separate expensive qualification campaign here.
