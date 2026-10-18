# Source-connected field selection and reconstruction laws

The complete ten-law package passed safe Bend checking and independent
BendTT/Lean checking with 53 nonopaque definitions. Five welltyped helper/model
mutations were rejected by unchanged laws after separate safe admission. See
the [accepted audit](../../../../../implementation/phase110/laws-audit.md) for
source identities, receipts, failed attempts and scope limits.
The later [stored-field seal model](seal/README.md) adds four independently
checked laws and three rejected semantic mutants under a separate model-only
scope; its C writer correspondence remains an explicit obligation.
The separate [wrapper-spare model](spare/README.md) adds nine independently
checked laws. It compares complete ownership observations while allowing different
new wrapper addresses, and keeps the retained-field seal unchanged.
Across the packages there are **23 distinct independently checked laws** and
**14 admitted semantic mutants rejected by unchanged source laws** in 28 checks.
The selector laws imported by reconstruction are counted once. Two compiled
consumer mutants are separate native-test evidence described below.

The actual candidate lowering in [`../lower/policy.bend`](../lower/policy.bend)
calls `nxo_law_select(String,String.eq(keep,a),a,b)`. Its complete, safe,
polymorphic definition is in [helper.bend](helper.bend). The same definition
selects complete child ownership records in [model.bend](model.bend).
The preparer copies the helper verbatim, adding only `import Base`, and binds
both the helper and actual call site by SHA-256. No unsafe annotation is removed.

[selector.bend](selector.bend) gives five universal contracts: the complete
retained/remaining/index result for both choices, reuse permission for unique
dynamic storage, and refusal to overwrite shared or immortal static storage.
The runtime classifier is an explicit abstract input. Only field selection is
currently called directly by the Bend production candidate; the reuse helper
is used by the safe model, with its C counterpart tested separately.

[laws.bend](laws.bend) adds five contracts, including the complete result of
consume/build/transfer for every modeled parent. The right side is the separate
[reference](reference.bend), which never calls the candidate selection, reuse,
claim, take or fusion functions. The equality includes the constructed tag and
both fields, the exact remaining child, child ownership counts, all surviving
old-parent aliases and contents, the empty scratch state, and reuse permission.
It is not a checksum equality or a helper-equals-itself equation.

The model has a consumed parent and two separately accounted child cells.
Heap children contain an arbitrary immutable String observation and a Nat count
of additional owners; the principal owner moves from parent edge to escaped
handle and then, for the retained child, into the rebuilt parent. Shared-parent
consumption must claim one extra owner for each nontrivial child while retaining
the old parent for its other owners. A unique parent transfers children without
adding owners. An immortal parent admits only trivial children and never permits
reuse. The incoming `other` owner is transferred unchanged into the result.

These premises exclude dangling inputs, machine-count overflow, allocation
failure, mutation, cycles, concurrency, and conflating the two accounted child
cells or incoming `other` into one physical object. Arbitrary existing external
owners of each modeled child are included. They do not establish a concrete
heap invariant or authorize deleting `span_fade` retains. Physical addresses,
redirect validity, C memory operations and machine code remain outside the
proof. Static children are restricted to trivial values by the actual entry
contract as well as the model datatype.

## Root-owned serial checks

Preparation runs no compiler. Use fresh output paths:

```sh
selfhost/build/phase66/bun-toolchain01/bun \
  selfhost/tools/performance/phase110/laws/prepare.mjs \
  --out selfhost/build/phase110/reconstruction-source-new --scope reconstruction

python3 -B selfhost/tools/laws/phase98/check.py \
  --source selfhost/build/phase110/reconstruction-source-new/baseline/laws.bend \
  --out selfhost/build/phase98/phase110-reconstruction-check-new

selfhost/build/phase66/bun-toolchain01/bun \
  selfhost/tools/performance/phase110/laws/check-mutations.mjs \
  --prepared selfhost/build/phase110/reconstruction-source-new \
  --accepted selfhost/build/phase98/phase110-reconstruction-check-new/report.json \
  --out selfhost/build/phase98/phase110-reconstruction-mutants-new
```

The existing checker supplies its own CPU3 guards. Do not wrap it in a second
exclusive execution guard. It snapshots the complete import closure, safely
checks the Bend source, emits BendTT, runs the independent Lean kernel, requires
all named laws to have nonopaque bodies, and rejects an independent false kernel
equality. Its existing output restriction to `selfhost/build/phase98/` is retained.

For the shorter selector-only first gate, use `--scope selector`; the preparation
and checker entry remain otherwise the same. The mutation runner first safely
admits every changed law-free helper/model. It then requires the unchanged laws
to fail with an expected/observed proof mismatch naming the intended law.
Syntax errors, missing imports and resource failures do not count as semantic
rejections. Mutations change the retained/remaining order, runtime field index,
static reuse permission, shared reuse permission, or shared-child claim.
The mutation negatives are source-check evidence, distinct from the positive
package's independent kernel acceptance.

Execution results and the precise source/model/C boundary are recorded in
[`implementation/phase110/laws-audit.md`](../../../../../implementation/phase110/laws-audit.md).

## Actual compiled consumer mutations

[`run-actual-mutations.py`](run-actual-mutations.py) implements the separate
[candidate recipe](actual-candidate-mutations.json) against the accepted
`call-source04` / `call-api02` profile. Run it under one coordinator-owned CPU3
guard; it has subprocess timeouts but does not acquire a nested execution lock:

```sh
python3 -B selfhost/tools/performance/phase110/laws/run-actual-mutations.py \
  --out selfhost/build/phase110/actual-consumer-mutants-new
```

It reuses `private-build01/runtime.o` and `harness.o`, then first requires the
accepted tagged worker to pass frozen `train01` case `list-two-root-aliases`.
Each isolated mutant is acquired with `build-api.py --calls --runtime-ir`, keeps
all ten static control reports and both owned graphs identical, and must differ
in emitted Nx only at its intended field-index or remaining-local mapping.
Both build through QBE and link the same cached objects. An explicit ABI or
harness semantic error, or a complete valid observation differing from the
frozen oracle, is required; crashes, signals, timeouts and compilation failures
do not count. Every command, input identity, source inverse replay and output
is retained. The supervisor extracts historically hashed modules from the
accepted source, so later live-source development cannot alter its baseline.

The accepted `actual-consumer-mutants01` run passed the exact positive, both
checked mutant acquisitions and all 191 unchanged static assertions. The index
fault exited with an impossible-source-branch ABI error; the remaining-local
fault exited with a leaked-ownership assertion. No crash or resource stop was
counted as a rejection. These native results are separate from the five
safe-law mutation checks above.
