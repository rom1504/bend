# Phase98 observer permission: independent caller and lifetime review

The later native prefix profile exposed a concrete **analysis-refusal
nontermination bug**, described immediately below. The earlier source audit
found no permission/ownership counterexample, but missed this eager recursive
Boolean guard. That distinction matters: broader permission exposed an existing
analysis defect, and promotion must wait for its correction and qualification.
This is a source audit, not a proof of observer analysis, native ownership or
arbitrary FFI, and cannot qualify an unfinished compiler image.

The reviewed isolated permission source is `9f4e516a…` (source02), with its
exact declaration bridge into combined `59b36a1c…`. Source, provider and runtime
pins are in [the permission report](observer-permission.md) and its linked
`source-audit.json`. No compiler/program/proof targets were run by this reviewer.
The following reasoning concerns arbitrary admitted callers, rather than only
the finite string corpus.

## Concrete refusal failure found after the initial audit

The pipeline review attributed the late native prefix to `norm_exact`, KTerm
projections and the `NOA_BELOW` continuation. The actual parent source has:

```bend
nt_choose(Bool, norm_exact(origin, want), u => True{}, u =>
  p98_tag_eq(origin, "OField") && noa_below(kid(origin, 0), want))
```

Ordinary Bool conjunction is eager. For a nonmatching OArg, the recursive call
still executes, then repeats forever through `kid(Absent,0)`. This helper has
no symbolic fuel parameter. My earlier observation that both analysis branches
share4096 fuel did **not** bound this separate helper recursion. Cache and
redirect planning optimizations do not repair it.

A valid typed two-root function that recursively calls itself with `(b,tail(a))`
decreases the total string length, but swaps root identities. The borrowed
analysis must decline this transformation and retain owning code. Its incorrect
ancestor check can instead fail to terminate. The new isolated
`origin-swap01.bend` exercises exactly this case with real IO.print_err.

The minimal proposed source is `origin-guard-source01/compiler.bend`, SHA256
`2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051`.
It changes only `noa_below` on parent59b36: a nested lazy Bool selector recurses
only for OField and returns False otherwise. It adds one line/38bytes. This is
a fix for prior divergent inputs, **not** an equivalence proof with the old
helper on all values. It contains neither cache nor redirect cost changes.
The root-owned
[`origin-controls01`](../../selfhost/build/phase98/origin-controls01/report.json)
now records the bounded old failure and the fixed outcomes. The old matching
root returns True; mismatched roots raise a stack failure in 0.125 s, inside the
3 s/512 MiB guard. All eleven candidate origin cases pass. Three existing complete
C products remain byte-identical to their parent controls. The valid owning
root-swap program emits no borrowed observer entry, compiles and executes with
stdout `1\n` and stderr `observer-origin\n`. Input pins remain unchanged.
These are finite executable controls, separate from the thirteen comparison/
permission laws freshly checked on this exact source and bound by the
[source-specific proof account](../../selfhost/build/phase98/origin-proof-account01.json).
Neither proves the complete unsafe analysis terminates or establishes native
ownership for arbitrary programs.

## Authority is a precondition, not a name check

`no_effect_foreign_allowed` requires both trusted-origin and filled-Foreign
flags plus one of nine exact API names. The unsafe surrounding classifier
obtains those flags from the checked book. The host must separately authenticate
the actual Base/runtime/provider bytes and their origin paths. A same-named
replacement C provider is not authorized by this predicate.

The native entry's `p86_effect_file` restricts the Base-relative request path to
the nine admitted filenames. `p86_effect_read` reads from the supplied provider
directory, and `p86_compile` supplies `effects_safe=True`. The native ELF does
**not** cryptographically authenticate that directory itself: the maintained
launcher/qualification boundary does. A person invoking that ELF with a
modified provider directory bypasses this contract. This was already a trust
boundary for the old scalar-array certificate; the new observer permission
makes preserving and documenting it particularly important.

The checked APIs likewise are not hostile-input security APIs. Directly forging
`db`, a private prepared `NR_Request`, a cached erased body, or the Boolean
permission can violate their documented preconditions. Raw `nc_compile` does
not grant the permission. Fresh checked preparation clears caller-supplied
prepared facts; source-bound validation and authenticated frontend preparation
must remain in front of the checked entry. None of the new code turns a raw
user marker into permission.

I inspected all nine actual C providers. They consume owned arguments through
the existing runtime, produce immediate values/fresh values, or hold independent
C buffers and file handles. In particular, File.write copies its input String
before the asynchronous write, and File.read constructs a fresh String after
reading. No admitted callback receives an unowned pointer into an observer's
String. Extra functions in the same C file, such as File.read_bytes/read_at,
are not admitted by the nine-name classifier. Source hashes alone do not
enlarge the API allowlist.

## Every admitted root excludes mutable substructure

[`observer-layout.bend`](../../selfhost/src/back/native/observer-layout.bend:83)
admits closed, zero-parameter, nonindexed recursive datatypes. A root has exactly
two constructors: one empty and one containing exactly one same-type recursive
field plus scalar fields. The boxed constructor has two to eight fields. The
only admitted native recursive root is String; similarly shaped user datatypes
remain possible.

Scalar fields/parameters are trusted native Nat, Char, U32 and F32, or a closed
nullary enum with at most32 constructors. Generic Array, a File handle, a closure,
an indexed datatype or a nested mutable container cannot qualify through this
route. Alias normalization uses the existing bounded type resolver; an alias
to Array retains Array's unsupported structure rather than acquiring String's
layout. Constructor result/field dependencies are rejected. U32/F32 structural
Word views are deliberately absent from scalar readers.

An entry has at most four live parameters and one or two roots. Its result is
either a scalar observation, or at most two fixed constructor shells containing
each original root exactly once and one scalar. The analysis checks exact root
origins and successful-branch constructor facts; merely returning equal-looking
replacement data is insufficient. Scalar-only mode intentionally drops the
original roots after the observation instead of reconstructing them.

## Borrowed reads keep the owning roots alive

[`no_adapter_lower`](../../selfhost/src/back/native/observer-adapter.bend:70)
saves the owned incoming root words in C locals, invokes the borrowed worker,
then uses ordinary owned lowering to return/drop those roots. The borrowed
worker has no allocating or destructive operation: boxed reads use `term_peek`
and `e.mem[loc+i]` after the matching constructor condition. Character reads
remain full U32 values; scalar narrowing stays disabled when old `packed` is
false.

Two incoming roots may alias, share tails, or one may be a suffix of the other.
The caller must already provide the corresponding owned references under the
existing affine/RC ABI. Saving those references keeps the complete reachable
immutable cells alive during the observation; there is no early release merely
because a cursor advances. Final ordinary drops account for both references.
The scalar route redirects when any root is shared. The other root can remain
unique because its separate owned local also stays alive. All-unique inputs keep
the original owning path. Product observers route through their scheduler entry;
an existing private product worker may bypass that optimization without losing
correctness.

`Array<String>` does not weaken this reasoning: native array get retains the
selected element, and a subsequent array update releases its slot's ownership,
not another retained String's reference. The root schema excludes Array itself.
Atomic array operations retain their existing scalar type constraints. This is
conditional on the existing runtime's RC, publication and copy-on-write
invariants; I have not proved `rfc_view` or concurrent heap reclamation. An
unsafe foreign pointer escape or a runtime bug can violate those invariants.

Recursive observer calls must advance at least one root and preserve each
root's own origin; swapped/replaced roots fail admission. C temporaries make
cursor updates simultaneous. Only a tail recurrence with the exact returned
scalar marker is residualized; pending work or a discarded recursive result is
refused. Fresh binder identities and scoped successful-branch facts prevent a
helper's local names or a failed match from authorizing unrelated reads.

## Demand and effects remain explicit

[`noa_reference`](../../selfhost/src/back/native/observer-analysis.bend:293)
rejects foreign helpers, unknown dynamic applications, cyclic helper expansion
and unsupported primitives. The symbolic evaluator preserves function/argument
and let-value evaluation order, emits scalar operations as statements even when
their result is discarded, and retains native error checks. It rejects demanded
zero-arity references and bang calls. The new whole-book certificate rejects
Rwt syntax; source-level structural Word operations and demanding scalar
constructors remain outside the observer residual.

Surrounding IO can occur before or after the traversal, but no provider call
executes inside an admitted borrowed worker. Efq remains the native error path.
The finite/proved pure equations do not establish precise allocation traces,
out-of-memory timing, arbitrary C floating-environment observations or error
cleanup under a corrupted runtime. Those are not claimed semantics of this
optimization. Ordinary scalar arithmetic errors are retained.

The permission split preserves all three previously coupled authorities:
constructor sharing/cold macros, planned host selection, and checked product
admission remain gated by original `packed`. `NATIVE_TYPED_SCALARS`, scalar/
unshared arrays and cold-user flags also retain old values. New observer
permission selects only candidate analysis/routing after ordinary lowering
succeeds. Raw/false-permission failure ordering remains on the ordinary path.

## Remaining trust and promotion boundary

Residual trusted components are the checked frontend and binder/layout
annotation, native representation tables, source-to-residual observer analysis,
ordinary owned adapter lowering, runtime reference counting/publication, and
the authenticated FFI host boundary. The new pure provider-membership and
comparison laws constrain their exact source predicates; they do not prove
these other components. Finite negative controls and the complete1,444-pair
corpus add evidence without covering all user recursive datatypes or all
concurrent executions.

The most concrete counterexample outside the contract is replacing an admitted
provider file with code that retains a raw String-cell pointer, then invoking the
native ELF directly while supplying `effects_safe=True` implicitly. The wrapper
must reject those bytes. Do not describe the naked ELF or public low-level
checked API as safe for arbitrary forged inputs.

## Planning cost discovered during this review

New observer permission exposes repeated work formerly skipped for the compiler
itself. `nol_finish` scans the whole book through `nol_scalar_specs(book, book)`
for every accepted schema. `no_scalar_redirect` also constructs the redirect
string before checking the worker name, for every worker in every successful
scalar route. Per-owner symbolic fuel is4096 and is shared across both match
branches, so this is not evidence of unbounded exponential branch expansion.
There is no global candidate budget; accepted C fragments accumulate.

Three unqualified exact-replay candidates are frozen in
`selfhost/build/phase98/observer-cost-sources01/manifest.json`:

- `redirect`: move construction into the matching branch and reuse the entire
  original worker on a miss; still visit duplicate matching names. +3 lines,
  26 fewer bytes. This is the smallest first experiment.
- `scalar-specs`: compute one descriptor list inside the permitted route, then
  thread it through copied schema helpers. All original public helpers remain
  exact. +56 lines; no book metadata or cache-trust extension.
- `both`: the two orthogonal changes together, +59 lines.

These preparations initially ran no targets. Required gates are source admission,
full-value helper controls and complete parent-vs-candidate emitted C/diagnostic
identity on identical input. A candidate's own changed source is not the same
input as its parent's source. There is no measured compiler speed/memory gain yet.
The first three data-only producer attempts are retained: two rejected historical
nonunique/empty recipe spans before creating output, and one had an indentation
error. V4 authenticates sequential source offsets and inverse replay; it does
not weaken source authentication to arbitrary replacement.

Root's `observer-cost-controls02/report.json` now passes105 complete worker-list
cases,60 complete schema cases and complete C/diagnostic identity for three
existing small sources. I independently rehashed337 unique pinned files. Both
full-source narrow APIs passed source admission; the control process took3.764s
and peaked at298.4MiB. This is validation cost, not a candidate speed benchmark.
The original `cost-controls01` attempt failed because its manually constructed
NC_Code fixture supplied a String where actual D04 requires NC_Text. V2 retains
that failed attempt, uses proper Empty/Leaf/Join text trees, preserves whole-value
equality and all-field/surviving-input checks, and reuses exact admitted APIs.
No native image or native program execution was required by this control method.

The redirect refactor separately passed an independently checked exact complete
NF_Worker-list equivalence law plus two support laws, with no opaque definitions
(`redirect-proof-check01`). The proof lane rebound the exact extracted closure
to candidatea025 and normalized all nine cached helper copies back to their
original bodies. The cache correspondence remains a source audit plus finite
full-value checks; it is not a formal proof of the entire unsafe resolver or of
the eager descriptor computation's totality on arbitrary forged books.

## Strongest subsequent program-speed direction

After measuring the equality/observer work, the strongest independent direction
is **avoiding allocation and disposal of unselected branch closures**. The
accepted Phase95 Map profile attributes11.12% of request samples to cleanup in
`nt_choose` and2.39% to `kc`; the exploratory full-self capture attributes7.87%
to `kc` cleanup. These are physical cleanup owners, not guaranteed removable
time, and the full-self capture failed its strict sampling-quality rule.

The useful compiler transformation is to lower a saturated known Boolean
eliminator with literal branch lambdas into direct control flow before building
both closure environments. It should be justified from the callee body/typed
call shape, preserve already-demanded arguments and branch captures, and retain
the generic fallback for escaping/dynamic closures. That general mechanism
targets ordinary programs, unlike recognizing individual benchmark names.

Phase98's selector-only source dispatch experiment was neutral; it is not
evidence that another enum dispatcher will help. The next fast loop should
require actual generated allocation/drop reductions and exact full branch
outputs, including unused dangerous branch bodies, captured shared roots and
later consumption. Only then pay for an image and balanced request timings.
The profile supports a material investigation, not a promise to remove all
13.51% Map cleanup or to reach parity in one pass.
