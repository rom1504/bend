# Phase51: V8-guided guard and application changes

Qualification is in progress. The integrated source combines a small IO helper
with reuse of an already-completed String check within a single contextual entry.
The checked B1 build and focused strict gate pass; installation and whole-corpus
performance selection remain pending. The installed release is still RNFA04.

The [design](../../design/phase51/v8-guided-runtime.md) was committed and pushed
before target execution. Independent agents prepared guard and dispatch
experiments, semantic review and qualification commands. Root alone executes
resource-limited targets; saved outputs avoid a compiler build for each idea.

| Experiment | Finding | Decision |
| --- | --- | --- |
| Batched String descriptors | Equivalent mutation behavior, but slower on RLE and Unicode. | Reject. |
| Four extracted application branches | `apply` inlines, but useful `force` inlining is displaced; timings are mixed. | Do not select. |
| Four branches plus exact-call split | Added structure does not consistently beat the smaller alternative. | Do not select. |
| Only extract the IO branch | 27 differential controls pass; fixed-work Evening improves 1.0477× after 32,768 warmup calls. | Integrated for qualification. |
| Same-entry String proof | 33 boundary observations pass; five of six screened points improve, with a small record-256 regression retained. | Integrated for qualification. |

The [guard report](guards.md), [dispatch report](dispatch.md) and
[static review](review.md) preserve the negative results, exact input identities,
protocols and caveats. The [runtime guide](../../docs/self_hosted/v8-guided-runtime.md)
explains the production proof boundary and maintenance obligations.

The largest apparent dispatch gain was warmup-sensitive: Evening's 1.55× result
under the one-second protocol became 1.0477× under fixed-work warmup. The latter
driver does not measure within-window drift. Neither number alone establishes
whole-corpus speed, a general steady-state gain or physical context elimination.

Final results, semantic qualification, source/release identity, time accounting
and durable raw evidence will be added here after the selected candidate runs.
No new frontend, self-hosted fixed-point, native/GPU or universal conformance
claim follows from this JavaScript runtime phase. No PR comment is authorized.
