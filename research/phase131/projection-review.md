# Independent review of product projection, source06

Source06 has no source-level ownership blocker in the reviewed path. It now
installs the scalar consumers that the earlier source03/source05 experiments
could only recognize. The evidence supports continued experimental qualification;
it does not qualify a complete compiler image or establish a speedup.

This review read source and retained artifacts on CPU0. It executed no Bend,
JavaScript, native program, compiler, profiler, or benchmark. It is separate from
the Phase131 FAST algorithm candidate and its native acquisition admission.

## The actual installation path

The changed entry is `p128raw_br_scanned`, reached by the request-bound
`p111_emit_admitted` path with its already retained `P113DCandidate` list. When a
product helper and retry plans both exist, `p131p_close` verifies the added
workers, combines them with the existing functions, and runs the existing
`p113d_passes` closure with fuel 32. Retry then receives that closed function
catalogue. This supplies the ordinary public consumer body required by
`p128br_find`; earlier attempts could recognize the product observation without
finding an owning fallback to install.

The closure takes the retained candidates from this request. It does not lower
the source again, fabricate a worker, or substitute a different compiler image.
Existing name/dependency checks determine which candidates enter the catalogue.
The retry uses the unchanged eligibility and worker builders. `p126bp_complete`
still verifies the complete projected functions, original certificate, and final
program before emission. Unresolved candidates do not become unchecked workers.
The ordinary path remains in use when there is no product helper or no retry.

The actual helper summary is constructed in `p128br_scan_ready` from the same
successful worker bundle that is added to the module. `p131p_reader` requires its
named private, single-result reader with the expected arity. A speculative
schema alone is not used as authority for an emitted helper call.

## Held roots and virtual results

The new call executes the original private product reader eagerly, producing its
scalar observation, and represents the surrounding constructor shells only in
the observer analysis. It neither calls the owning product adapter nor performs
that adapter's reconstruction and release operations.

The unchanged `p128br_arguments` requires exact parameter types and held-origin
evidence for every borrowed root. `p131p_virtual` returns the original abstract
argument for a parameter leaf, preserving its origin and type. Only the scalar
result gets a fresh origin. It preserves constructor names and nesting rather
than flattening arbitrary products. The outer reader's held roots therefore
remain the lifetime authority for all projected descendants, including through
a nested helper call. Runtime field inspection copies words without consuming
their owners; local copies survive a later helper's scratch use.

The wrapper predicate alone is not an ownership proof: it permits references to
parameters and the fresh result inside at most two constructor levels. Its
authority also depends on the unchanged product eligibility checks requiring
each root exactly once, the result exactly once, valid constructor layout, and
successful original observer analysis/lowering. Calls with virtual owning
constructors, fresh/unheld roots, missing arguments, or mismatched types retain
the previous refusal. The final consumer still must return a scalar; this does
not create an escape route for a borrowed pointer or general product result.

Self-loop descent and root-position checks are unchanged. Composed consumers
are not recursively added as arbitrary new summaries during the retry. The
review does not extend these contracts to concurrency, GPU execution, malformed
runtime words, or externally fabricated helper summaries.

## Owning fallback and emitted evidence

`p128bs_functions` is byte-identical to Phase130. It stores the actual ordinary
consumer's parameters, result, and body under a private owning name. The public
adapter runs the unchanged `p118_rt_borrow_scalar_safe` guard. On success it
calls the reader and only then releases the roots; on failure it calls the
owning body with the original arguments. Identical nontrivial root locations
remain a guard refusal. The borrowed read does not release either root itself.

For both source06 fixtures, an independent comparison against the closure-only
control found the owning fallback **body bytes exactly equal** to the control's
ordinary public consumer body, excluding only the first declaration line which
contains the renamed symbol. The control runs the same late closure but filters
product summaries from retry; its existing scalar summaries remain enabled.

| Fixture | Product reader preserved exactly | Scalar consumer reader | Owning body SHA-256, declaration excluded |
| --- | --- | --- | --- |
| `projection-string` | `String.cmp`, 9,560 bytes | `String.order`, one eager original-reader call | `4ae190dabf1b3e3abd93ce397f636a9066320369a7bec1217098495eb1c1bdaf` |
| `projection-list` | `p131l_cmp`, 9,160 bytes | `p131l_query`, one eager original-reader call | `1d03de6c1dbc48ea7f1ad0e0624afd1c81fb1122315133dfe3679380f0d46f6b` |

The emitted public adapters visibly retain both guard branches, post-reader
root releases, and the owning calls. This establishes installation and fallback
body preservation for these two artifacts, not runtime branch frequencies.

## Completed controls and limits

The checked API completed successfully. Its finite receipt has 28 passing rows:
14 projection predicates, 10 inherited held-call predicates, and four inherited
integration-error predicates. These check wrapper binding/depth, result-ID
separation, origin preservation, missing-reader refusal, call refusal, and exact
error propagation. They are structural tests of constructed data, not 28 native
workloads or a proof over every program.

Both independently frontend-verified fixtures passed final emission checks.
Candidate and closure-only versions both built with the same QBE toolchain and
runtime, and all four ordinary executions matched the complete six-line
expected output with exit zero and empty stderr. Source cases include lengths
0/1/17/128, equality and ordering differences, independently owned roots,
same-root aliases, and distinct roots sharing a tail that remains in use after
the query. Strings also include NUL and non-ASCII code points.

These ordinary outputs are fixed observations/digests; they are not a full
heap-state oracle. The runs do not instrument whether each guard branch was
taken, count retains/releases, or exhaust all nested alias combinations. The
same-root and fresh-root cases exercise relevant source scenarios, while exact
dynamic branch coverage remains unmeasured. The independent structural review
and emitted fallback identity make the existing results useful without claiming
that missing coverage. No full native self-hosting or focused19/ordinary45
qualification belongs to source06 yet.

The broad closure activation can add ordinary functions even if no final retry
is admitted. Thus a performance comparison against Phase130 alone mixes closure
availability and projection. The closure-only control is needed to isolate the
projection effect. Static call-site presence also does not show that a measured
hot path reaches that call. Timing belongs to the separate paired campaign.

## Frozen identities

Paths below are relative to the repository. All 74 unique file pins in the six
source/API/finite/emission manifests below were rehashed in this review, as were
the input inventories of the four native build reports. Original declaration
text was independently compared for `p128bs_functions`, held-call admission,
both eligibility predicates, retry/find/apply, closure traversal, and all three
final verification layers; these remain equal to Phase130.

| Artifact | SHA-256 |
| --- | --- |
| `selfhost/build/phase131/projection-source06/compiler.bend` | `f5af5564993c03e121b96a90e3df70e35506717ee386acbc727e8aabcb505a06` |
| `selfhost/build/phase131/projection-source06/manifest.json` | `82610baa4aae154c2ef36e5a65fdfebad27d17ba1cf4bfb91ea287d3723d1cba` |
| `selfhost/build/phase131/projection-closure-source03/manifest.json` | `491b7080039c2a866dd4f22242b64d55bf6ff197ef2443deb67a34e85437910c` |
| `selfhost/tools/performance/phase131/projection/candidate-v02.bend` | `3a4fd8e5400f58256240582d62b306db2e8dfdbf531ba648010c2dee1871ae35` |
| `selfhost/tools/performance/phase131/projection/controls-v02.bend` | `3ae4da8c35b8d132844149c6b3ed1cdc002106ccf46d12cb18b79adc7436016d` |
| `selfhost/tools/performance/phase131/projection/late-workers-v03.bend` | `87cdd78afca777dc672be135a8a23677d0dc373141e78974087fbd279a9d9baf` |
| `selfhost/build/phase111/p131-projection-api06/report.json` | `624f3cb5eb3cbc2f1b64f37ef59f4bd85ccf00a33075742afdbea096cddb3d00` |
| `selfhost/build/phase131/projection-finite06/report.json` | `7eb4a7eeb8c68b9f59834062a1d8437fa0b7800ecad69153305c0de760013bbb` |
| `selfhost/build/phase118/p131-projection-emit06/report.json` | `534534de8e8dccf1021136e4e65279358cc7c37295bef106f43fe8d026c60e29` |
| `selfhost/build/phase118/p131-projection-closure-emit03/report.json` | `9856d0217833c2d7fd0037bef3783655f8d5ca497aaf1bdabdf8a23c3d3d4c6b` |
| `selfhost/build/phase131/projection-string-inspect06.json` | `f84e0e3a5f8e5458f91803b1d12e3abcc62ea56d5b3121d41ab30cf08d983959` |
| `selfhost/build/phase131/projection-list-inspect06.json` | `b0293d27f82db408aed19073381083322f5a49fd13d31d899556a54df03b1762` |
| `selfhost/build/phase111/p131-projection06-candidate-projection-string-build/report.json` | `fd30c80209fcd3db001e3b528de6cb40eb3baa5a3b2cf52f9821cf9fb2eb6742` |
| `selfhost/build/phase111/p131-projection06-candidate-projection-list-build/report.json` | `98215b8b7525af2b4d4ebbe9a273a8fc48afc1310f3f8a66b148d334f801c00f` |
| `selfhost/build/phase111/p131-projection06-closure-projection-string-build/report.json` | `8689ace6b33250c1ad0ba05c374689ce46affa8ded8eafc89c4a58d73e42dc6c` |
| `selfhost/build/phase111/p131-projection06-closure-projection-list-build/report.json` | `2f0117d41c16b2661021d15176c13d73a0839449a50e2103c5b000b9e4b20263` |

The runtime C remains `6eb24c8d4a5d6358a9b8b4107a75af777a8dbdd06fe5fdce18d73b9f85f4824a`
and its linked object remains `9b3f57afb46b4db8c63f6f3c5f1af1194e0854a7329de28f25d2e11aef887749`.
