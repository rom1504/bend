# Phase84 binding-boundary refusal prototype

Agent handoff notes; see the [final Phase84 report](README.md) for root-run
measurements, completed controls and rejection/deferral decisions.

Status: source-only candidate; not built, run, or promoted by this lane.
Baseline `8c7a279`; [patch](../../experiments/phase84/prototypes/refusal-binding.patch)
adds 23 physical source lines in `flat.bend` and `product.bend`. It passes
`git apply --check`. Production files were not edited. Patch SHA-256:
`ddaa7de80145a3b22e2ea645eac3edf407f32a4b0c2826f5ab64c63c28ac77c0`.

## Scope

Before `nq_bind_choose` computes a value shape or lowers its continuation, detect
a bound value whose application spine is a saturated, non-bang reference to the
current ordinary worker owner. Require an ordinary, non-native, non-foreign
owner definition and **no NQSig for that exact source name**. Unrelated product
signatures may remain. A bare zero-arity reference is covered by the same rule.

The value will be evaluated at a local destination with `tail = False` in both
`nf_bind_boxed` and `nq_bind`. Under the stated guards its call must reach
`nf_call_local` with the original owner and must refuse. Return that refusal
before constructing either the continuation or argument lowering.

The original body of `nq_bind_choose` becomes `nq_bind_route`, unchanged. Every
unknown case takes that original path. There is no source-tree traversal, name
special case, matcher analysis, or assumption that all recursive syntax is
reachable. The hook runs only when the actual lowerer reaches a strict binding.
This is independent of the earlier post-failure `refusal.patch`; test separately
before combining them.

## Route-derived proof

1. `nd_head` returning `Ref` means the value is that reference or an App spine
   headed by it. The head must equal `NC_Destination.owner`, and `qt != 3`.
2. `nc_native_def` is false, so both `nd_native_call` and `nd_scalar_call` return
   empty. The intrinsic shortcut cannot intercept the application.
3. The exact number of supplied arguments equals `nd_arity`. A nonempty App
   therefore takes `nd_ref_app` / `nd_ref_arity` into ordered `nc_sequence`
   ending in `NFCall` of the same name. A bare zero-arity Ref takes `nf_ref`
   directly to the same `nq_call`. Partial, extra-argument, bang, and dynamic
   calls are deliberately outside this precheck.
4. `nq_info(target, name)` has no NQSig, so `nq_call` cannot select a distinct
   product owner. If arguments become virtual bundles, `nq_opaque_args` boxes
   them and eventually revisits the same NFCall/name. It cannot introduce a
   product signature or change the owner.
5. `nf_call` sees an ordinary non-native/non-foreign definition and delegates
   to `nf_call_local`. The bind lowers the value using `nq_local` (directly or
   via `nf_local`), which sets `tail = False`, preserving owner and signatures.
   The exact-owner call must return a nonempty error.
6. Any earlier argument-lowering failure already makes the worker fail. The
   precheck can replace that **private** first error with the non-tail error,
   but cannot turn a successful worker into a failing worker. This intentional
   private diagnostic change is not a claim of failed-NC_Code identity.

This differs from scanning every non-tail self reference: an ordinary `f` may
successfully call `$product.f` when an NQSig exists, and a product worker's owner
is `$product.f`, not `f`. Both situations bypass this precheck. Let substitution
and known-bundle match pruning have already selected the binding actually being
lowered; dead syntactic branches are not inspected.

## Failed-result consumer audit

Audited production sources at the baseline above, including every `NF_Worker`
constructor/destructor under `selfhost/src`:

| Consumer | Why shortened failure metadata is not emitted |
| --- | --- |
| `nf_candidate`, `nq_candidate_mode` | Preserve original worker name, parameters and shape; only code/dependencies change. |
| `nf_admit_pass` (`flat.bend`) | Requires an empty `nc_error` and no segments before dependency admission. Nonempty remains nonempty. |
| `nf_retry` | Only empty-error ordinary workers can retry. The original actual lowering necessarily failed here, so retry eligibility is unchanged. |
| `nf_plan_workers`, `nf_plan_retry` | Initial admission begins from an empty ready set; retry carries only already-admitted names. A newly shortened failed worker cannot already be ready. |
| `nf_prototypes`, `nf_bodies`, `nf_adapter_defs`, `nf_host_defs` | Select only ready names. Failed body, fresh index, dependencies and error text are not emitted. |
| `nf_finish_ready`, `nf_finish_plan` | Render ready workers; do not export optional worker error strings to `NC_Result`. |
| `no_worker_taken`, `no_private_free` | Inspect retained names, preserving observer collision reservations. |
| `no_route_pair` | Admits only its new observer pair against the old ready set; does not reconsider old failed workers. |
| `no_route_plan`, `no_route_schema`, `no_scalar_redirect` | A scalar redirect requires an already-ready ordinary owner; it cannot revive this failed worker. |
| `nc_append_book` (`book.bend`) | Public native errors come from scheduler code, which this predicate never intercepts, rather than optional NF_Worker failures. |

Raw callers of private `nq_bind_choose` / candidate functions can observe changed
failed code, dependency lists, fresh counters, or first internal error text.
Production errors and final C must remain exact. This proof is scoped to the
production plan/renderer, not arbitrary external construction of inconsistent
ready sets containing failed workers.

## Focused controls for the root runner

First check/build the candidate through the normal checked-B1 path. Compare
helper results and actual candidate error classes with a derived diagnostic API;
then compare full production C and public diagnostics byte-for-byte.

| Case | Required precheck/result |
| --- | --- |
| Bound saturated self call, ordinary owner, absent own signature | True; both candidate versions fail; final fallback C exact. |
| Same call in the final tail position | Binding hook is not reached for that call; normal tail loop remains admitted. |
| Own NQSig exists, including a matching product route | False even if the route would eventually refuse; original routing decides. |
| Only unrelated signatures remain after retry | True if all other guards hold; same final ready set. |
| Product candidate owner `$product.f`, source call `f` | False; preserve product/ordinary distinction. |
| Ref has bang quantity or wrong arity | False; original diagnostic path decides. |
| Native, foreign, absent, or non-Def owner | False; preserve intrinsic/foreign/provenance handling. |
| Scheduler destination | False; full NC_Code and public diagnostics exact. |
| Literal constructor, lambda-headed application, dynamic call, matcher application | False; no syntax-only reachability claim. |
| Bundle argument requiring reboxing | True only for same ordinary owner without own NQSig; eventual local self failure preserved. |
| Earlier argument failure plus non-tail self call | Both failed workers remain unready; changed private error allowed, public diagnostic exact. |
| Known-bundle match discards a branch containing recursion | Hook only runs on retained lowering; no false refusal of the surviving worker. |
| Observer name collision and scalar observer redirection | Same reserved names, ready set and final C. |

Fast performance screen: Map is a useful positive discriminator, but also run
Numeric plus a constructor/list/BST family and a small/function family to expose
precheck overhead. Measure the clean uninstrumented compiler serially. The
precheck adds an owner comparison to each reached private binding and performs
book/signature/arity lookups only for direct self calls. It saves continuation
construction at that binding; it does **not** avoid all earlier matcher work or
propagate failure across dependency-blocked workers. No large broad gain is
claimed before measurement.
