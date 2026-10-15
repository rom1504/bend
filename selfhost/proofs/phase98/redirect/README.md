# Exact complete-worker redirect preservation

[`proof.bend`](proof.bend) independently passed in
[`redirect-proof-check01`](../../../build/phase98/redirect-proof-check01/report.json):
one public law and two support lemmas, with no opaque definitions.
Its emitted closure contains 145 definitions. The four guarded targets occupied
9.73 seconds in total; this is checking cost, not proof-authoring effort.

`redirect_workers_preserves` equates the complete ordered `NF_Worker` list returned
by the actual old and new `no_scalar_redirect`. It covers every typed worker,
owner string and root-index list, including duplicate matching names. Worker
parameters, nested code/text trees, segment metadata, code errors, calls,
dependencies and shape terms are compared as full values. The two supports split
the actual worker choice on Bool and lift head/tail equality through the actual
list constructor. No abstract comparison or emitter callback is assumed.

The candidate delays redirect text construction until the name matches and
returns the whole existing worker on misses. The original recursive function is
the executable reference, with declaration and self-call renamed together.
[`prepare.py`](prepare.py) authenticates the full candidate replay and extracts
26 actual type/helper declarations. It removes leading unsafe annotations; the
independent checker therefore validates these bodies as safe. The separate
law-style String-returning signature of `nc_ctor_codes` is mechanically combined
with its definition header, with an explicit reversible bridge. Its unchanged
body is an ordinary function, not an additional theorem.

The same proof/helper closure is byte-identical in combined cost candidate
`a0254c27…`, as recorded by the
[source audit](../final-cost-data01/source-audit.json). That audit also verifies
that all nine scalar-cache clones normalize exactly to the retained original
helpers after undoing cache argument threading and restoring the old descriptor
expression. This latter result is source inspection, not a proof of the unsafe
layout/planning pipeline. Cache hoisting can evaluate descriptors on a permitted
route with empty names or no eligible/successful schemas, where the old route
would not. Descriptor totality and evaluation cost remain separate obligations.

The proof does not establish C ownership or resource use. In particular, safe
full-value equality does not prove that the whole compiler stays below its memory
guard. Full generated-C/diagnostic equality and native execution remain required.

Root-run preparation for a new actual candidate is:

```sh
python3 -B selfhost/proofs/phase98/redirect/prepare.py \
  --receipt selfhost/build/phase98/observer-cost-sources01/both/changes.json \
  --out selfhost/build/phase98/my-redirect-proof-source

python3 -B selfhost/tools/laws/phase98/check.py \
  --source selfhost/build/phase98/my-redirect-proof-source/proof.bend \
  --out selfhost/build/phase98/my-redirect-proof-check
```

The early-stop mutation returns the remaining list after the first match,
missing later duplicates. Its standalone helper was admitted and the unchanged
`redirect_workers_preserves` law then rejected it in
[`redirect-negative-check01`](../../../build/phase98/redirect-negative-check01/report.json).
This was a normal source-level expected/observed proof mismatch, not an
independent-kernel rejection. The proof author selected it after positive
acceptance at root request, so it is a late targeted control, separate from the
original independent eight-bad/two-good set. The first plan's missing runner
`classification` field is retained; `prepare-negative-v2.py` adds that metadata
while preserving the semantic edit and proof bytes.

The redirect and scalar-cache candidate remains unpromoted. Its accepted value
law does not explain the later full-compiler resource failure: that investigation
identified eager ancestor recursion in the separate `noa_below` helper. The
minimal origin-guard successor is based on the earlier combined tag/permission
source and does not include these redirect/cache edits. Therefore these three
laws remain candidate-specific catalog entries, outside the minimal successor's
thirteen-law comparison/permission closure.
