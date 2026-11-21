# Checked-Bend private-spine specialization

This experimental compiler overlay changes an erased producer and consumer.
The measured Phase200 source transformation saved 22.4% and 25.1% in two
BST64 native timing sessions. Phase205 requires its own compiler activation,
machine verification and product measurements.

## Install and exercise

From the repository root, `wire.py INPUT_COMPILER OUTPUT_COMPILER` installs
the pass in a staged compiler. Its `apply(source)` function returns the same
text for a caller maintaining a portfolio builder. It inserts
`match.bend`, `schema.bend` and `pass.bend` after the generic
`p168_catalogued` definition and immediately before `p168_request_mode`.
It requires the expected call to occur exactly once.

For hosted controls, append `probe.bend` to the staged compiler and export
`p205t_probe`, `p86_plan` and `p88_cache_prepare` with the ordinary
checked API acquisition. Run the following through the assigned guard.

```sh
selfhost/.assets/bin/bun research/phase205/tree/controls.mjs CHECKED_API.mjs CHECKS.json
```

`capture.mjs` reads the authenticated Phase199 hosted compiler and observes
the actual unmodified internal `nc_definition_plain` via a diagnostic export.
It produced compact JSON for the BST, compact witness, text and lexer under
`selfhost/build/phase200/p205-shapes01`. `schema.py` deterministically
regenerates the input equations and residual templates from that capture.
Fixture function names are used to freeze the equations. There are no
benchmark, source-file, tree-type or user-function names in the installed
admission predicates. The rule checks fixed Base operations and discovers
the other call/constructor identities by structural roles.

## Admission and representation

An admitted checked source must have the exact alpha-equivalent erased
equations for a public insertion entry, descent, step, producer, finish
and consumer. The producer branch pushes a three-field record containing a
word, untouched sibling and literal direction, then a list cell pointing
to that record and the existing tail. The consumer matches the list cell,
record and direction, then reconstructs precisely one original tree node.
The step/finish equations keep the accumulator and private path distinct.
The matcher checks binder identity, quantity, exact arity, constructor field
mask and complete branch bodies, including the terminal absurd branches.
Roles bind injectively to the names supplied by the checked program.

For a private path, define its representation inductively. Empty is the
ordinary empty list. A nonempty cell maps to a fresh left/right constructor
holding the pivot, sibling and recursively represented tail. The new
producer constructs exactly that value; each consumer arm performs the
original corresponding reconstruct-and-recur step. Descent, result,
comparison, fuel (including zero on leaf and interior), branch order and
public result all retain the same values. The synthetic constructors have
three fields and the two layouts use the captured independent elaborator's
field mask of 1. Other code can still create and inspect ordinary lists and
frames.

Every reachable erased body is searched for references to the five private
helpers, including partial applications and references under closures.
Every outside use must have the exact public boundary expression, which
starts the private path at a literal Nil and returns only the new tree.
The region contains no callbacks, effects, refcount observations or foreign
calls carrying the trail. The predicate call receives only the scalar key
and pivot and is executed in its original code. Every internal definition
must be a normal checked Def with the expected erased-body cache entry;
unsafe or foreign regional definitions refuse. Unrecognized sharing or
an externally observed intermediate path refuses. The pass presently
considers one positive group per request and at most 512 reachable names.

## Cache, constructor and verifier audit

* The new names are absent from the complete physical constructor catalog,
  which is also bounded below its 16-bit ID limit. The pass appends two
  arity-three entries and preserves all original IDs and ordering. There
  is no reuse of an ordinary tree or frame CID. Both descriptors enter as
  `hot=True`, matching the behavior of `p144o_specs` for ordinary source
  constructors. Any optimization of publication or reference counting is
  owned by the normal downstream pass.
* Only the push/pop `NativeErasedBody` values are replaced in the existing
  request's private static-fact index. The public type/source index, all
  other facts, trailing cached metadata, function membership and public
  arities stay intact. This is an intentional private representation
  change between erasure and physical lowering. Every synthetic binder
  is allocated above the independently recorded checked source bound,
  in disjoint ranges below the compiler temporary range.
* `p112s_defs` uses `nc_definition` on those updated facts and preserves
  them as the prior facts behind `NativeStaticBody`. The separately passed
  augmented constructor catalog reaches static indexing and
  `p140or_finish`. The original checked source remains available to
  type/signature analyses. In particular, `p121f_plan` reads original
  checked KDef bodies for a different nested producer/fold schema; neither
  changed body matches its application premise. The push returns a pair
  and the pop returns a tree. They are not scalar leaf observer results.
* The already admitted request still passes through `p169s_lowered`,
  `p167v_original` and `p169a_original` after lowering. These independent
  stages verify the resulting segments, constructor IDs and adapters
  against the original public request. They are machine-structure and
  ownership gates; they do not prove that the representation relation
  above is a semantic theorem. The rule separately needs physical evidence
  that both new tags reach the producer and consumer and the complete
  native public observations agree. Rewrites of this region by a future
  source-only specialized lowering must be checked against this boundary.
* An implementation that merely observes two changed cached bodies has
  demonstrated pass activation. Actual final code, complete independent
  output and timing remain distinct measurements.

The original capture and the frozen RHS were separately interpreted by a
small call-by-value evaluator, with full trees compared to an independent
insertion algorithm. All 980 combinations passed, including duplicate
keys, shared-child values, unsorted input trees, zero fuel and maximal U32
keys. This checks the semantic equations without running emitted code.
See [raw counts](equations.json) and [the independent interpreter](equations.py).

### Expected publication difference

The authenticated BST incumbent's actual `p111_cid_hot` bytes for Con and
the old frame are both zero. The Phase200 checked source transformation's
left and right trail bytes are also zero. P118's cold-candidate discovery
iterates original source ADT definitions. Synthetic erased-only tags can
therefore stay hot in this implementation. A gain observed in Phase200
cannot be assigned to this pass in advance. Extending cold publication
would require an independent proof for the private path and the original
component fields, paired with real shared/static ownership controls.

### Hosted checks

The combined03 compiler passed the upstream source check and checked
hosted API acquisition. Its actual pass changed both cache bodies on the
original BST and on an independently alpha-renamed source. It refused a
separate caller observing the shared helper, inverted comparison, wrong
reconstruction and wrong direction tag. The unrelated lexer was unchanged.
[Seven observations](hosted-controls03.json) · [Compiler and API pins](hosted-receipt03.json)

The optional [ordinary machine fixture](shape.bend) begins with original
Bend helpers. Its 44 full tree-pair outputs and final line are available in
[the independent expected output](shape.stdout), reproduced by
`shape-fixture.py` from the Phase200 persistent-root oracle.

### Native result and selection

The combined03 native compiler emitted and linked both ordinary BST programs.
Each object's constructor table contains the two fresh three-field tags at
IDs 167 and 168 with hot publication enabled. Both ID immediates occur in
the direct and product producers, product step and descent, and direct
consumer. The independent candidate, baseline and mature C outputs agreed
on 1,802,825,775 for BST32 and 861,157,620 for BST64.
[BST32 machine witness](machine32.json) · [BST64 machine witness](machine64.json)

| Program | Candidate / baseline elapsed | Candidate / mature C | Dispersion flagged |
|---|---:|---:|---|
| BST32 | 1.00292 | 3.42316 | No |
| BST64 | 1.08186 | 2.62036 | Yes |

The integrated pass is **excluded from the selected Phase205 policy**.
The conservative representation failed to reproduce the earlier source-level
speedup on either native input. Hot sealing is a concrete difference from
the earlier cold output; these observations alone do not isolate its cost.
No synthetic cold-publication override was installed. The 44-observation
shape fixture is available as an additional machine control and was outside
this native timing run. [Per-role evidence and ordinary outputs](native-result03.json)
