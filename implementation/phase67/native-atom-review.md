# Independent atom-let source review

Scope: source-only review of `atoms-v1.patch`, its `atoms-v2.patch` and
`atoms-v3.patch` successors, and `scalars-v2.patch`
under `selfhost/tools/performance/phase67/native`. No compiler/native targets
were run by this reviewer. A pure atom-value theorem does not cover the native
ownership, cancellation, C-scoping or code-generation obligations below.

## Findings before execution

1. **V1 changes malformed-input error precedence.** Original `nc_let` returns
   `nc_first_error(rest, val)`, so an unsupported body precedes an unbound-value
   diagnostic. V1 instead immediately returns the unbound-variable failure and
   resets freshness to `n`. **V2 fixes this** by routing the unbound sentinel
   through unchanged `nc_let_cut`. V1 must remain a rejected predecessor.
2. **V2 removes a non-sequential error checkpoint.** The original `!seq` path
   creates a continuation and returns through `FID_EXIT`, which checks
   `err_seen(e.mem)` before entering the body. This observation is active in
   the **device** runtime: on the host, `err_post` terminates synchronously and
   `err_seen` is constant false. `nc_share_env` can call
   `term_keep`, whose reference-count overflow posts `ERR_RFCS`; other tasks
   can also post errors. Direct inline entry must retain the corresponding
   `if (!seq && err_seen(e.mem)) { return 0; }` before body work, or deliberately
   state and justify a changed cancellation contract. The sequential old path
   has no corresponding `FID_EXIT` check. **V3 fixes this** with the explicit
   non-sequential guard after sharing/local binding and before the body. V2 is
   retained as an unexecuted predecessor. The scalar V2 candidate includes V3.

## Ownership and freshness argument

For a value variable used only through the new binder, the local assignment
transfers its owned word. If the original variable is also live in the body,
the unchanged `nc_share_env` first obtains the second ownership with
`term_keep`, before copying its possibly wrapped word. The unchanged body
`nc_lower` drops an unused new binding. `NWord` is an immediate word and adds
no heap ownership. Other environment bindings are filtered by the same body
liveness calculation. Calls, allocation, array operations and effects are not
eligible atom values.

The removed continuation alone owned counter slot `n`; the body can reuse that
slot. `nc_sequence`, `nc_app_slow`, `nd_match` and matcher field setup reserve
their synthetic binder IDs before calling the let lowerer. `nc_compile` also
rejects source binder IDs at or above 4,000,000,000. Under the existing checked
fresh-binder invariant, local C names remain distinct and branch/segment braces
retain scope. This is not a proof for arbitrary forged raw terms with duplicate
binder IDs or arbitrary externally supplied binding-word strings.

## Focused controls still needed

- Shared heap/Array aliases where both old and new binders remain live.
- Unused heap-valued aliases and chained atom lets.
- Saturated arguments and match bodies requiring synthetic temporary IDs.
- Sequential and non-sequential behavior; cancellation before an effectful body.
- Malformed unbound value plus independently failing body, preserving the old
  first diagnostic through fallback.

The source argument supports atom V3 on this restricted domain. It does not
establish measured speed, full native
conformance, asynchronous failure trace equality, or a compiler correctness
proof. Runtime allocation-failure removal and exact concurrent scheduling are
separate from preservation of successful language results.

## Scalar V2 follow-up

No additional source-level blocker was found. Eligibility uses the same actual
`nc_native_def` provenance as existing native dispatch, excludes foreign and
bang references, and requires exact saturation. `nd_bind_scalar` binds arguments
left-to-right with reserved synthetic IDs before invoking the unchanged intrinsic
expression. Partial applications and excluded primitives retain old lowering.
The allowed template set excludes allocating/consuming F32 read/show and arrays.
U32/Nat comparison packing repeats only pure comparisons over already bound
words; no argument expression is executed twice. Nat overflow can still post
an error, and the retained non-sequential guard precedes subsequent body work.

Recommended boundary controls include U32 overflow/division by zero/shift32;
F32 NaN, negative zero, bits and conversions; Nat overflow; all three comparison
results; nonnative and foreign fallback; partial/bang calls; and effectful
argument-order witnesses. The proof pilot remains a sequential already-computed
word-transport model, as its owner explicitly confirmed; it does not prove this
larger scalar-lowering implementation. No target was executed for this review.
