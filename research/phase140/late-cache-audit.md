# Late observer memo: independent source audit

This is a bounded source audit of `selfhost/tools/performance/phase140/late/core-v01.bend` and its catalogue fix in `core-v02.bend`. No target execution or performance measurement was performed for this audit. The producer being studied is the qualified Phase137 source `2620d59a3a20fa5d5d27bbf3b12ceb7304439b27093fff1c0f383da03e4ecf38`.

## Finding and correction

The first version omitted a global input. `nol_finish` appends `nol_scalar_specs(book, book)` to every successful schema. This catalogue visits all ADTs; `nol_ctor_fields` calls `nq_layout_type`, which can unfold definition bodies through `nq_layout_ref`. Consequently, identical constructor headers alone do not establish identical catalogue contents when an alias body changes. An unrelated observer need not have a source dependency on that ADT.

Version 2 computes the current scalar catalogue once, retains the previous one, and requires exact ordered equality of every `NO_Spec`/`NO_Layout` field before reuse. This establishes the missing catalogue equality, including entries not consumed by a particular reader. It is stronger than assuming that unused entries cannot affect admission. The extra computation and retained catalogue must be charged to the experiment.

This is a source-level dependency counterexample, not an observed miscompilation of a checked user program. A useful negative control is an unchanged observer and unchanged ADT header whose result-type alias changes the bounded layout query's outcome; the complete fresh plan must be the oracle.

## Other inspected boundaries

| Input or behavior | Required condition and observed implementation |
| --- | --- |
| Definition lookup and negative lookup | Ordered complete headers are compared, including names, children, flags and Foreign bodies. This pins first-match order and generated-reader-name absence under genuine book-cache provenance. |
| Body and alias dependencies | Every source term name, not only `Ref`, contributes to the dependency graph. Changed owners and changed erased-body facts propagate through the previous graph. Unchanged owners retain their previous outgoing dependencies. |
| Source versus prepared book | The cache uses the original `NR_Request.book`, matching `p128br_scan`; it must not substitute the post-static book. |
| Optimized owning fallback | Scalar mode stores and compares the first matching `P113DFunction` in full, including body and all parameter fields. An ineligible first occurrence is not silently replaced by a later eligible duplicate. |
| Product worker | `p118b_functions` also derives `nq_signature_def` and the public name. Their owner/type/arity dependencies must remain covered by the source and erased-fact contract. |
| Candidate order | The exact ordered candidate-name list is a global reuse condition. Accumulation preserves the original function/helper/retry order. |
| Error priority | A worker error stops the scan and returns empty function/helper/retry lists as before. Failed scans retain the previous cache. |
| Retry and closure | Only the initial scan is memoized. Current helper closure, retries, cold processing and final `p126bp_complete` verification remain unchanged. |

## Trust premise and hardening option

The result is restricted to private state from one fixed compiler producer, originating in the genuine frontend/erasure pipeline and published after complete request success. It is not a verifier for caller-supplied cache objects.

In particular, `p140o_edge` reads source `KDef` terms while `nc_source_body` can read a `NativeErasedBody` inside `ns_body`. Exact comparison of that fact detects changes to the fact itself, but does not by itself record the dependencies of an unchanged fact. A forged fact can introduce a reference absent from the source graph; changing that referenced definition would then evade source-only propagation. For the real path, the additional premise is that erasure introduces no unrecorded named dependencies beyond the fixed implicit native names.

An explicit hardening option is to include all term/child names of each owner's `ns_body` fact in its dependency edge, refreshing the edge whenever either source or fact changes. This avoids relying on a separate reference-preservation argument for metadata. Merely adding another equality check of the same fact would not address that issue.

## Recommendation

Do not integrate version 1. Version 2 addresses the identified global catalogue omission; finish its independent controls and make the metadata provenance/dependency premise explicit. The smallest integration point is to replace only the `p128br_scan(...)` argument passed to the unchanged `p128raw_br_scanned`, threading private memo state beside the ordinary result. Retain current retries and the independent final verifier, and publish the new state only after the complete request succeeds.

Useful adversarial controls include a changed scalar catalogue with otherwise clean owner; a changed erased fact; a transitive alias edit; missing-to-present generated reader name; changed first fallback with an unchanged later duplicate; candidate reordering; worker failure before a later reusable item; and a retryable refusal becoming admissible. These complement exact fresh-versus-cached full output comparisons; they do not constitute a proof or a native speed claim.

## Version 3 follow-up

Reviewed `core-v03.bend`, SHA `8f8871b911b65faa8d2dea8e02be1007bc204c1673541aff2c29f23bdbb44285`. It implements the explicit metadata-edge option: `p140l_edge` scans both the complete source definition and its complete `ns_body` fact, including children. `p140l_delta` compares both inputs and refreshes the edge when either changes. Closure uses the previous reverse graph; afterward `p140oq_refresh` updates the current graph. This is conservative because a changed owner is itself dirty, while only unchanged owners rely on their previous outgoing dependencies.

The source/erasure-reference-subset assumption above is therefore removed in v3. The private genuine-cache/fixed-producer premise remains. The exact scalar-catalogue gate remains necessary and is retained. No additional source blocker was found in this bounded review; actual controls and whole-output tests are separate evidence.

The integration in `late/emit-v01.bend` calls the original `p128raw_br_scanned` with the cached scan, retaining its current closure/retry/final-verification path. It publishes the replacement late cache only on successful emission; `session/backend-v02.bend` retains the entire previous session cache on a failed request. Native frontend errors currently terminate the batch, so this does not establish native daemon failure recovery.
