# Known partial application factory removal

`direct-v1.patch` is a source proposal against the hash in `patch-v1.json`.
`direct-v1.bend` is its complete derived module. No production source was changed
by the producing lane and no compiler/native target was executed there.
The owner registered [P69-003](../../../../../experiments/phase69/P69-003-closure-factory.md)
before writing the patch.

The general transformation is:

```text
def f = lambda a. lambda b. lambda c. body
f(expr_a, expr_b)

  -> let a = expr_a; let b = expr_b;
     lambda c. direct_f(a, b, c)
```

The definition must have a complete actual leading lambda telescope; a function
type alone does not satisfy admission. Captures are evaluated exactly once in
left-to-right source order. Existing let/lambda lowering owns retention, disposal,
the closure ABI, and missing-argument telescopes. Remaining code uses the existing
full direct entry, so this adds no copy of the function's body and no runtime ABI.
The rewrite removes a factory call and supplied-argument generic applies; it
does not claim to remove the final dynamic call to the produced closure.

Admission is limited to scheduler lowering. Worker candidates that would return
closures remain refused by the established worker planner. Primitive/foreign
definitions, explicit bang references, dynamic heads, bare names, exact and
overapplication retain their old paths. Ordinary references to a definition that
also has bang uses are legal candidates, as for existing saturated direct calls;
the threaded fixture covers this mixed metadata case. No GPU coverage is claimed.

`selection-v1.json` uses the existing checked workflow selection schema and pins
ten native controls through `controls-v1.json`. Four new fixture goldens are
derived independently: decimal argument positions give123, shared prefix
application gives `abac`, an erased polymorphic first function gives `kept`, and
mixed ordinary/bang calls give33. Existing fixtures exercise partial/erased/over
applications, intrinsic bang fallback, and the competing matcher/overflow order.
They are **unexecuted proposals** until root records actual checked and native
observations. The shared capture case should additionally run at threads1/4.
Retain inherited raw primitive/diagnostic controls; a type annotation cannot
authorize removing an actual prefix match or effect.

The candidate adds27 physical Bend lines in one existing module. Estimated
integration is a short checked-B1 loop plus controls and a closure-family sample.
The Phase68 measured closure apply/allocation excess predicts a clear reduction,
but no speed claim is justified until new exact emissions execute. A second-stage
known-lambda capture specialization could surpass upstream; it is separate from
this deliberately small first patch.

## V2: lazy factory admission

`direct-v2.patch` supersedes v1 and adds32 lines against the same original source.
The root review correctly identified eager Boolean admission as an unnecessary
compiler cost. V2 queries arity once behind cheap ordinary/nonempty gates; only
an underapplied scheduler call checks user provenance, and only then scans the
actual leading lambda telescope. `direct-v1-to-v2.patch` is also preserved.
The independent source reviewer found no new semantic blocker in v2. Execution
observations belong to the root's integration receipts, not this source proposal.

## P69-006: small known combinators

`direct-v2-to-v4.patch` is a separate67-line extension, with full module and hash
manifest. It specializes only partial calls already admitted by v2, with at least
one literal lambda argument and at most eight parameters. The erased callee's
body must be closed App/Var syntax and each distinct parameter must occur exactly
once: at most15 residual body nodes. Repeated/dropped parameters fall back to v2.
No references in the copied body means no recursive inlining expansion.

Every telescope binder is alpha-renamed. Admission rejects fresh-ID collisions
with the caller environment, original body and supplied argument syntax. Literal
lambda arguments are substituted once; every other argument becomes an ordinary
ordered let. The resulting closure captures the lambda's free values, permitting
existing native beta lowering to eliminate known applications. This can remove
the scalar-add closure still allocated/applied by upstream's closure benchmark,
without a global points-to analysis or a new runtime representation.

**V3 was rejected during independent source review, before execution.** Ordinary
`subst` invokes `core_rebuild` and eagerly beta-reduces applications. In the valid
linear combinator `after(f,g,x)=f(g(x))`, substituting literal `f=y=>0` would erase
`g(x)` and its error. The V3 source, patch and manifest remain preserved. V4 uses
the existing syntax-only `nq_layout_subst`, leaving CBV beta sequencing to native
lowering. Source review also exposed the same prerequisite in existing `nd_beta`
when replacing a binder by a variable inside a nested literal application.
`beta-sequencing-prerequisite.patch` isolates this one-line correctness change;
`direct-prerequisite-to-v4.patch` isolates specialization after that prerequisite.

`selection-v4.json` and `controls-v4.json` contain six new typed proposals.
`raw-combinator-cases-v4.mjs` exports six data-only raw cases for the methods
lane's controller. They require preserving demanded arguments even when the
literal parameter is unused, preserving nested demand, avoiding capture when
callee IDs equal caller IDs, rejecting unbound variables, and retaining repeated
and dropped combinator fallbacks. Shared String captures also survive storage and
an independent outside use. Both one- and four-thread controls remain necessary.
These are unexecuted here. V4 requires the root's independent review, checked B1,
raw/error gates and separate clean timing before any promotion.

## Reviewed integration and affine corrections

[Independent V4 review](independent-review-v4.md) found no further source-level
semantic blocker and approved proceeding to tests. Root integrated it, but the
first checked build (`combined-build06`) rejected `nd_comb_linear`: `rest` was
used by both the membership query and recursive branch. Root added `+rest`.
`direct-v5.bend`, `direct-v4-to-v5.patch` and `patch-v5.json` preserve that exact
successor without editing production from this lane.

A follow-up source audit found the same affine issue in `nd_comb_fill`: both
`nt_choose` branch closures capture `rest`, requiring `+rest` there too.
`direct-v6.bend`, `direct-v5-to-v6.patch` and `patch-v6.json` preserve that second
zero-line-count correction. All other repeated inputs/locals in the added
helpers are already explicitly shared; `nd_comb_literal` and `nd_partial_term`
each consume their unshared tail only once. This audit is not a checked-build
claim. Root owns the build07 receipt and subsequent qualification.

The original v1 fixture selection also hit an inventory-ID collision before
semantic cases ran. `selection-v2.json` changes exactly four inherited `compile/`
IDs to unique `phase69/closure-factory/existing/compile/` IDs, preserving all file
bytes and goldens; `selection-v2-derivation.json` records the correction. All
superseded sources, selections, rejected review drafts and failed builds remain
preserved rather than overwritten.
