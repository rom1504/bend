# Phase195 retained-root ownership: executable promotion frontier

The checked fixture and controls establish a working bounded mechanism experiment,
not an automatically admitted optimization. No target/compiler/timing execution was
performed for this note. The root-owned timing plan is
`selfhost/tests/phase195/ownership/timing-plan01.json`; its explicit argv uses
controls02, four alternating paired blocks for each of unique/shared roots,
20,000 iterations, depth 8, 100-second outer guard, 16 MiB disk budget, and a
90-second helper deadline. Only the hot direct-object product is timed by this
plan. Cold controls qualify the fallback's finite behavior, not its performance.

## Exact finite results

`selfhost/build/phase195/ownership-controls02/report.json` is complete. Each of
hot/direct, hot/assembly, cold/direct and cold/assembly reports exactly
`checks=360 failures=0`, status 0, empty stderr. Total: 1,440 machine observations,
720 baseline and 720 candidate. Each product covers two roles × nine depths ×
two sharing states × two empty states × five queries. Both publication-policy
rows also report `original-ir-verified=1`. These are finite semantic/alias/lifetime
controls and IR-shape checking; they do not prove arbitrary optimizer correctness.

The v1 cold shared-input failure is preserved in controls01 and correction-v2.md.
V2 publishes child ownership before sharing a cold parent, as required by
`span_fade`. The observer, Bend fixture, driver and products are frozen.

## What a 2× result would and would not establish

A large win would justify attempting actual-source admission. The fixture removes
path takes, reconstruction, and recursive return transport while retaining the
root and acquiring the selected owned payload once. It uses numeric branch
selection; actual Map search also performs String bit work (already borrowed in
the selected machine), wrapper transport, comparisons and later insertion. It
has a bounded baseline recursion depth of eight. Consequently it does not measure
actual Map speed, arbitrary-depth behavior, or compiler throughput.

If a real application spends fraction f in an equally accelerated region, a
2× regional speedup yields total time ratio 1-f/2. Ten percent less application
time requires f=20%; no current dynamic evidence establishes that fraction for
Map.seek. The old static whole-function call-site counts include duplicate/error
paths and must not be used as a dynamic fraction.

## Actual-source barriers, including existing extensions

These functions are present in the exact Phase194 selected-source02 compiler,
not just development files. The source SHA is recorded in frontier.md.

1. `observer-layout.bend:nol_wrap_shell` requires one fixed constructor;
   `nol_finish` requires preserved roots plus one scalar. `Maybe<String>` fails
   that contract. `observer-analysis.bend:noa_finish_value` also requires the
   observation to be scalar, and `noa_recur_done` recognizes exactly one returned
   recursive marker. Merely weakening the shape gate is unsound.
2. `nol_root_fields`/`nol_root_ctors` admit a two-constructor spine with exactly
   one recursive field. Phase128 `p128bl_recursive` has the same one-child
   restriction. **There is already a wider shallow fallback:** Phase131
   `representation-boundaries.bend:p131rg_node` admits bounded plain constructor
   sets, but `p131rg_visible` only exposes scalar or old root-spec types. A Map
   child which is not such a spine is opaque and cannot be recursively matched
   or promoted as a cursor. Map's parameter specialization must also be checked;
   the shallow fallback explicitly requires a plain type. Thus saying there is
   no broad constructor support would be wrong, but saying it already supports
   recursive Map traversal would also be wrong.
3. Actual `Map.seek.go(node, kb)` receives `kb=(key, branchBool)` and returns
   `(node,key,Maybe<storedKey>)`. It preserves the key field, not the entire kb
   tuple. `noa_loop_valid` currently expects each non-scalar parameter to recur
   as a descendant of the corresponding parameter. A freshly constructed kb
   tuple does not fit that contract. The cursor needs a bounded structural
   product decomposition into held key plus scalar branch state.
4. Owner recursion is special-cased in `noa_reference`; other calls use checked
   helper summaries or bounded expansion. Start with the recursive `.go` owner,
   then expose its summary to the public wrapper. Starting with `Map.seek` and
   expanding an unsummarized recursive helper is not a substitute for this.

The source witness is the pinned Base `Map.seek.go` at line3045: both leaf arms
return the stored key; both recursive arms use Map.lo/hi to rebuild identical
parents. Public Map.seek calls it after Map.bit. The existing origin algebra
(OArg/OField/constructor facts, `noa_equal`, `noa_below`) is the useful reusable
foundation: it can express preserved nodes and descendant projection provenance.
No benchmark or Map symbol should appear in admission rules.

## Smallest credible general slice

Implement a separate bounded observer plan, reusing existing origin evaluation,
with these explicit descriptors rather than broadening the scalar contract in
place:

- A finite constructor graph with a small node/field budget, exact constructor
  identities/widths, zero or multiple recursive cursor children, and opaque
  retained fields. Inspect only supported fields; arbitrary Map values remain
  opaque. Reject unsupported native/dependent/specialized layouts unless their
  resolved concrete representation is certified. Root equality must preserve
  every field, including opaque values and both unvisited branches.
- A bounded input product descriptor that decomposes a fixed tuple into held
  roots and scalar loop state, preserving the external ABI. Recursive arguments
  must retain the same scalar types and move at least one cursor strictly below
  its held root. It must not infer that a newly allocated tuple is the old root.
- One optional owned-field result descriptor: an empty constructor or a single
  field of known type originating below a still-held input root. Prove each
  returned root identical on every path; reject fresh/reordered/modified roots,
  foreign/effectful calls, unknown aliases and additional escapes. Carry the
  optional-result marker intact through recursive continuations; only identity
  reconstruction may disappear. A local Again loop remains stack safe.
- A borrowed worker returning a tag and raw selected word, plus an ABI adapter.
  The adapter retains original owned inputs throughout the read. On a hit it
  acquires exactly one owned reference only for an RFC or trivial word, then
  builds the original result shape. A raw nontrivial selected word takes the
  original whole-function fallback **before any ownership transfer**. No-hit
  can return original roots and None. Existing checked layout reads remain.
  Do not globally publish or mutate a borrowed raw child to avoid the fallback.

The last condition is essential: runtime.c:927 `term_keep(raw)` creates a new
RFC wrapper with count2; the old parent's raw field is unchanged. Calling it on
a borrowed raw field and returning the wrapper does not correctly establish the
parent's reference. `span_fade` at1062 also rejects raw nontrivial children under
a shared parent. The passing v2 controls explicitly respect that publication
boundary. The RFC/trivial escape guard is already exercised by the prototype.

This is a several-part bounded extension across layout, origin/recursion result
analysis, helper summaries and adapter lowering; it is not a small one-line
result-type relaxation. Existing P113D multi-result functions, borrow-fields
runtime interface and Again lowering cover the physical implementation. Public
entry/return wrappers and original fallback must retain their current ABI and
pending-frame behavior.

## Earliest executable stop/go gates

After root endorsement, first build a **diagnostic-only** general descriptor and
plan export over the checked actual Map source. Require exact per-owner outcomes
for Map.seek.go, Map.seek and the already-optimized Map.bit.go. Retain refusals for
changed roots, an escaping non-descendant field, result loss after recursion,
unknown effects, incompatible constructor specialization, and namespace collision.
The first gate is successful whole-owner proof plus bounded candidate size; do
not spend a full build if only the handwritten fixture is admitted.

Then lower the admitted plan with the existing exact whole-function fallback,
run the accepted independent lifetime/publication controls plus actual-source
semantic cases, and inspect the emitted **selected** path for no tree take/ctor
or recursive return work. A source-level rewritten Map function may help debug
but cannot count as generic compiler admission. Time the two ordinary Map/record
sizes with independent outputs before any full suite. Measure actual fast/fallback
coverage separately if publication policy makes the escape guard uncertain.
Only after that gate consider a compiler KDef projection family; current evidence
establishes no compiler transfer.
