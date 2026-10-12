# Independent source review, first observer proposal

This is a source-only review. No compiler, Node, Clang or native target was
executed by this lane. Phase69 artifacts were read without changes.

## Controls and parser lessons

The fifteen original controls remain in place as version 1. Root's checked
source gate `observer-source-check01` rejected all fifteen: shared Strand used
a computed tuple scrutinee, prohibited by the language's parameter/field-only
match rule. Version 2 moved computed matches into parameter helpers.

`observer-source-check02` then accepted one and rejected fourteen. The shared
library referred to unfilled forward definitions, and branch-origin-refusal
matched a parameter after local statements. Version 3 orders filled acyclic
helpers before callers; its recursive compare helper cycle follows Base's
explicit law/filled definition pattern. The branch-origin witness passes its
computed values to a matching helper. These are fixture corrections, not
compiler changes; all semantic goldens and admission intents are unchanged.

Current selection is `selection-v3.json`; `selection-boundary-v3.json` adds a
reachable unknown-foreign refusal and real shared-root pool execution. Version
3 still requires the parent's checked source and native validation. Exact
source hashes and the failed predecessor are in `v3-derivation.json`.

Three raw cases in `raw-observer-cases-v1.mjs` establish inert forged context
and refusal of source-supplied internal return/loop nodes. `capability-and-error-
oracles.md` records separate deterministic shared-error diagnostics; these have
not yet been implemented or run and are not claimed by ordinary pool success.

## Emission review

The first residual emitter does not pass borrowed `NC_Binding` values into
ordinary keep/sink/destructure/owned lowering. Boxed reads use `term_peek` and
explicit fields; successor and Char reads follow their immediate runtime
representations. Its scalar catalog excludes allocating string read/show and
arrays. Nat failures remain ordered statements with the existing nonsequential
error join. Returns also check shared errors. Loop updates use simultaneous
saved arguments and the existing worker loop envelope.

A separate owned adapter worker is preferable to lowering wrappers directly
inside scheduler switch cases: it isolates generated labels and reuses ordinary
constructor/ownership lowering. Stable owning root slots remain distinct from
borrowed cursor parameters. Scheduler hooks must use captured parameter locals
after `ne_take`, because `WL_OPEN` shadows register names.

The emitter's current structural checks are not a semantic plan validator.
An untyped name environment by itself permits returning a cursor as a scalar,
passing it to an arithmetic operation, attaching a different ADT's descriptor,
or moving incompatible values into loop slots. Four descriptor fields also do
not prove field kinds or instantiated owner. Analysis must prove these facts
and validate the residual before emission; the richer typed construction
invariant is part of the integration gate. Canonical NWord syntax similarly
must derive from analyzed core rather than arbitrary plan text. This gap was
reported to both analysis and emitter owners before integration.

## Checked permission

An explicit permission Bool threaded from `nc_compile_checked` through native
assembly is preferable to inferring authority from a BookCache marker, function
name or generated C text. Public raw `nc_compile` must supply False. The host
must pin the actual Base and permitted effect implementations; the Bend side
must independently inspect the relevant definition/effect closure and Base
provenance. Unknown foreign behavior and rewrites cannot grant permission.

The current native catalog has arithmetic/conversions, array operations and
Nat division; no primitive returns a root address, reference count or physical
identity. Audited args/print/now do not expose immutable-root identity. Borrowed
root descriptors must recursively exclude mutable arrays and foreign handles,
and reject unsupported native Word/unary packed layouts. No ordinary scalar
certificate alone proves the observer's ownership contract.

Entry `WL_OPEN`, loop `err_spun`, scalar joins, immediate-return checks and the
post-observer adapter check jointly retain shared-error behavior. The optional
optimization must preserve the exact existing raw/device fallback, and failed
analysis/emission must preserve ordinary worker and segment lists.

## Independent coverage review

The expanded corpus's Array-map oracle matches the imported full 1024-element
map/convert/sum semantics and threshold greater than 1000. Tape uses the same
specified modulo-32-bit LCG, multiply-then-XOR hash and sum. String-order uses
Unicode code-point order with equal/prefix/high-character cases and observes
both returned roots. A computed Tape result match was identified and corrected
by the coverage owner into a parameter helper. These are source/oracle findings;
execution qualification remains owned by the parent.
