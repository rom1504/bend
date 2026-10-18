# Wrapper-spare transfer model

All nine laws passed safe checking and the independent BendTT/Lean kernel in
[check01](../../../../../../selfhost/build/phase98/phase110-spare-check01/report.json),
from [source01](../../../../../../selfhost/build/phase110/spare-law-source01/manifest.json).
All six semantic mutants passed standalone safe admission and then failed their
intended unchanged law in
[mutants01](../../../../../../selfhost/build/phase98/phase110-spare-mutants01/report.json).
This is a separate safe
model from the accepted stored-field seal omission package. The proposed actual
wrapper-spare template keeps the retained field's seal operation unchanged.
No compiler, proof or runtime target was executed by the authoring agent.

An eligible parent is a last-owner reference to a dynamic constructor shell.
Consuming it releases one exclusive redirect resource. When the incoming other
word is a raw constructor, the proposed path uses that resource directly to
store a redirect with the incoming metadata and target, initial owner count 1,
and a cleared spare. The reference specification instead releases the old
wrapper and supplies an arbitrary replacement address chosen by allocation.

`SpareParent` exposes the relevant premises: raw dynamic parents have no wrapper;
shared dynamic parents have at least one other owner; static shells include
direct static parents and references to static shells. None may supply a spare.
Incoming immediate and existing reference words require no raw-to-reference
conversion. A raw incoming constructor may target static or dynamic storage;
its target storage class is deliberately unrestricted.

The complete observation preserves the incoming constructor tag and target,
its single owner, zero remaining owners of the consumed parent wrapper, exact
retained/remaining ownership records, an arbitrary external ownership frame,
and the residual spare token. **Only the new incoming wrapper's address is
erased.** The model does not assert equal heaps, free lists, allocation histories
or allocation counts. It states that one live parent-wrapper owner is replaced
by one live incoming-wrapper owner, with the external owner frame unchanged.
The old-parent credit denotes an outstanding handle to the old referent; it is
not a second physical counter simultaneously stored in the reused cell.

Nine laws cover the full reserve gate, an independent count-1 anchor, complete
transfer equivalence for arbitrary old and fresh wrapper addresses, and refusal
to spend the returned empty spare again. The latter constrains the returned
transition state; symbolic `Nat` names do not enforce physical linearity.
Six model mutations steal a shared/static wrapper, install count 2, change the
incoming target, preserve a dead parent credit, or leave the spare reusable.
Each must be admitted as a safe law-free program before unchanged laws reject
its semantic error. No mutant changes the reference specification or laws.

The accepted package has 44 definitions, none opaque. Its 11,651-byte BendTT
has SHA-256 `d1bf44ec8e86e731a6dcefbce36efdfb7221937866dbdde3bb4d9c1150f76d57`.
The independent kernel also rejected its unequal-label control. The first
submission required no model or proof repair.
The twelve mutant admission/rejection checks totaled 5.822 seconds of guarded
subprocess time. These negatives are source checker observations, not mutant
proof rejections by the independent kernel.

## Correspondence boundary

The abstract exclusive resource and separate ownership frame encode a
separation premise. They do not derive physical nonaliasing from numeric
addresses. A source/runtime refinement must establish that the count-1 dynamic
parent's redirect is exclusively owned and correctly sized, both old children
were loaded before overwrite, the incoming raw target does not depend on the
consumed wrapper, and the reserved cell cannot be exposed or spent twice.
The admitted acyclic owned-value contract is relevant to the target alias
premise; the model is not a general cyclic-heap theorem.

The actual implementation must preserve the original fallback for shared,
static and redirected-static parents; classify raw incoming constructors
including raw static targets correctly; release an unused old wrapper; retain
the original incoming seal when no spare is available; and pack metadata,
target and count without corrupting word bits. Those obligations are audited
and tested by the ABI agent's separate authenticated runtime package. They are
not compiler extraction, finite-word arithmetic, failure, concurrent-allocation
or whole-pass theorems here. The model treats retained/remaining field handling
as a frame, so its correctness relies on the separately audited field protocol.

## Coordinator-owned checks

```sh
selfhost/build/phase66/bun-toolchain01/bun \
  selfhost/tools/performance/phase110/laws/spare/prepare.mjs \
  --out selfhost/build/phase110/spare-law-source01

python3 -B selfhost/tools/laws/phase98/check.py \
  --source selfhost/build/phase110/spare-law-source01/baseline/laws.bend \
  --out selfhost/build/phase98/phase110-spare-check01

selfhost/build/phase66/bun-toolchain01/bun \
  selfhost/tools/performance/phase110/laws/check-mutations.mjs \
  --prepared selfhost/build/phase110/spare-law-source01 \
  --accepted selfhost/build/phase98/phase110-spare-check01/report.json \
  --out selfhost/build/phase98/phase110-spare-mutants01
```

Use fresh directories. The checker owns CPU3 guards; never add an outer guard.
Positive checking must include independent BendTT/Lean acceptance and the
kernel negative. Mutation negatives are separate frontend observations.
