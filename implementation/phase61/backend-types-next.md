# Backend telescope reuse after State06

Proposal only. No compiler source was changed and no compiler or target was run
for this investigation. State06's native host facts already remove most of the
previous host-type graph cost; repeating that optimization is not the next step.

## Evidence and remaining budget

The completed [State06 profile analysis](../../selfhost/build/phase61/state06-analysis01/profiles.json)
binds genuine B2 `f73ef8a5596e99d45108b0d31b4e6c3f49e008db000a428e27acd27d79bd6d1a`
to checked source `14af4de4b67de746cfa1d59458a0e27c1e03e02516583c6d2a621352b11e449e`
and driver `569f17b1e0ccd87da33dd07c2b7a7837f4578cae7d592e646f10eb4c2d2a313b`.
Its Map first-window sampled allocation is **252.322 MB**, versus State04's
586.671 MB in a separate observation. Host ancestry falls from 328.756 to
27.819 MB. These are descriptive changed-image samples, not isolated-pass gains.

Current Map CPU ancestry includes reach 449,218 us (22.23%), library 345,794 us
(17.11%), checker 226,344 us (11.20%), and calls analysis 164,420 us (8.14%).
These overlap: the calls scan and definition emitter are invoked inside larger
stages. The window includes compiler import, ordinary API load, and exactly one
first request. It does not measure steady-state compiler throughput.

Substitution ancestry still accounts for **65.325 MB**, 25.89% of sampled Map
allocation; definition ancestry is 72.539 MB. They overlap and cannot be added.
The sampled substitution CPU union is 81,210 us, 4.02%. A cursor can also avoid
normalization and associated reconstruction, but those additional savings have
not been established. Allocation share is not a request-speed prediction.

## Concrete repeated work

| Source and symbol | Current behavior | Candidate reuse |
| --- | --- | --- |
| [common queries](../../selfhost/src/back/common/queries.bend), `j_app_type` | Substitutes one argument through the complete remaining codomain. | Keep a private raw telescope plus pending bindings; materialize only the requested domain/head. |
| Same file, `j_specialize` | Repeats `wnf` and whole-tail substitution for each datatype argument. | First bounded experiment: fuse a beta-stable specialization into one realization. |
| [calls](../../selfhost/src/back/js/direct/calls.bend), `jd_calls_saturated` | Advances types even when only formal quantity and remaining arity are needed. | A cursor can expose quantity without cloning the remaining codomain. |
| [ordered values](../../selfhost/src/back/js/direct/ordered-values.bend), `jd_ordered_fields` | Advances a constructor telescope for every erased/live field; emits live fields under their exact domains. | Realize a field domain when demanded and retain the pending tail. |
| [constructors](../../selfhost/src/back/js/direct/constructors.bend), `jd_ctor_checked` | Specializes the checked constructor before value/field emission. | Share the same cursor semantics with ordered constructor emission. |
| [patterns](../../selfhost/src/back/js/direct/pattern.bend), `jd_doc_match_ctor` | Specializes the constructor, builds an arm telescope, then opens its fields. | Eventually expose field/domain facts directly, keeping branch-specific result typing. |

This is not merely a missing cache around `wnf`. Every application currently
creates a new type tree; raw-object identity caching may miss precisely those
new trees, while serializing every tree into `term_key` can cost more than the
query. The existing [fused telescope](../../selfhost/src/check/env-telescope.bend)
and [environment substitution](../../selfhost/src/check/env-substitution.bend)
provide the starting proof and implementation, not a promise of backend gain.

The pinned TypeScript compiler memoizes `tele_unbind` in `TELES`, opened terms in
`OPENS`, and call spines in `SPINES`. Constructor domains use `ctr_tail` over that
shared telescope representation. Its `HTerm` includes higher-order bodies, so
opening a codomain does not require our repeated first-order whole-tree clone.
See the [pinned source survey](../../research/compilers_architecture_and_techniques/bend-typescript.md)
for commit `018751270e800bc222a93dad7f257083ee53a5f7`; this is not a claim about
upstream HEAD. Reusing facts is transferable; importing higher-order terms into
all public KTerm/serialization boundaries is a separate, much larger migration.

## First source experiment: private fused specialization

Add an emitter-private specialization helper with the existing `j_specialize`
result contract. For multiple arguments whose telescope and arguments satisfy
the existing beta-stability grammar, accumulate `KTelescopeBinding` rows and
realize the final remaining telescope once using `env_subst_apply`. Retain the
64-binding flush and original eager path when the raw head is not a known `All`,
a binding is unsafe, or the proof is unavailable. Use `kc` before recursion or
normalization; Bend Boolean conjunction does not provide lazy admission.

Do **not** replace `j_specialize` with `env_tele_fill` blindly. The former returns
`Absent` on a missing function telescope; the latter returns `Error` in its eager
failure path. A backend adapter must retain the original result, normalization
order, source spans, binder IDs, quantities and failure behavior. Shared common
queries serve legacy and native consumers too; start at direct-only call sites.

This bounded variant touches constructor parameter specialization without a new
public carrier or per-lookup conversion. It is the cheapest falsifier for whether
remaining argument substitution can actually be amortized. Admission scans also
cost time: one-argument and tiny telescopes should retain the original path.
No program names, fixture patterns, or measured-input thresholds belong in it.

## Next architecture if that experiment pays

A private `JDTypeCursor` carries raw tail, newest-first bindings and bounded
pending count. Opening it yields the current quantity/name/binder, a realized
domain when requested, and another cursor for the tail. Pushing an argument
records a binding instead of substituting the entire tail. Unknown head shapes
force accumulated bindings and resume the old normalized traversal. The cursor
is scoped to one immutable selected book and lexical typing environment.

Start with named-call argument traversal and ordered constructor fields. Calls
analysis needs most quantities but few domains; emission needs exact domains.
The same cursor implementation can support both without caching emitted code.
Preserve dependent domains and inserted-value substitution order: an earlier
replacement can itself reference a binder substituted by a later argument.
Unadmitted beta-producing application, annotations, dependent head changes,
repeated binder IDs and budget exhaustion must fall back at the same point.
No externally supplied KTerm acquires ownership or proof from this private type.

Cross-stage immutable type facts could follow, but their key must include the
exact book/world and lexical environment, not a definition name or printed type.
Avoid adding a broad side cache whose success survives book overlays, source
changes, failed requests, or differing native identities.

## Tiny falsifier before building the architecture

Root can run one instrumented saved State06 B2 per Numeric, MapSet and lexer,
using the existing fresh-process method and exact prepared-output oracle. Count
`j_specialize` argument widths, `j_app_type` calls, and eligible raw telescope
heads. Also count visited/rebuilt substitution nodes under calls, reach and final
emission. Use bounded identity-only tables for diagnostic repeats; do not force
pending computations or generate structural keys solely to count repeats.
Separate instrumentation from clean timing. Bind parent/producer/output hashes
and report counter truncation rather than silently dropping work.

A counterexample immediately rejects the shortcut if exact type/result/span
comparison differs, including `Absent`/`Error`, erased parameters, dependent
fields, later bindings acting inside earlier arguments, beta exposure, malformed
heads, or the 64-binding boundary. Real constructor/matcher fixtures must retain
quantity, demand, partial application, error/reentry and complete public values.

If eligible multi-argument specialization accounts for little remaining
substitution, stop this pass. If counts support it, root should first qualify the
small fused helper and compare clean Numeric/Map/lexer requests plus broad exact
outputs before introducing a cursor across all backend signatures. The isolated [34-line prototype and checked-B1 controller](../../selfhost/tools/performance/phase61/backend-telescope/README.md) are prepared for root qualification, with no live source application. No savings
are claimed until that experiment completes.

## Separate sharing opportunity and its risk

`jd_reach_selected` renders `jd_doc_definition` to recover emitter-owned runtime
dependencies. Final `jd_library_selected` reconstructs a calls context and emits
those definitions again. This repeats type walks, but caching the text across
these stages is not automatically sound: pruning changes selected definitions,
SCC membership and forcing facts, while reachability intentionally follows erased
arguments, dead-let demand and numeric row pruning from the actual emitter.
Prove relevant calls/SCC facts equal before sharing a rendered body, or share
only context-independent type facts. Never replace emitter-derived dependencies
with an approximate source scan to make this optimization easy.
