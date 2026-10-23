# Composing direct-QBE optimizations

Phase126 keeps useful scalar, product and control-flow facts across existing
optimization boundaries. The compiler remains written in Bend and emits QBE IL
directly. QBE and the assembler build machine code; the separately cached C
runtime has one additional arithmetic helper. There is no per-program C or cproc
stage. The [report](../../implementation/phase126/README.md) gives measured status,
artifact identities and the distinction between hosted and native qualification.

The selected composition has six parts:

- Keep exact F32 values in local machine temporaries across a proven buffer region.
  Calls retain the original full-Term ABI. Rounding, signed zero and observation
  boundaries remain explicit; there is no fast-math or reassociation.
  The raw-bit transport and guarded-conversion controls do not establish a
  general arithmetic NaN-payload or floating-environment equivalence claim.
- Evaluate small closed scalar selectors into readonly tables. The checked plan
  proves every row and the full-width default. Unknown, effectful, nonfinite or
  unsupported expressions retain the ordinary path.
- Inline those table reads and permit already-safe conditional preparation inside
  the existing explicit-stack recursive regions. Exact Nat predecessor projection
  removes one redundant helper boundary.
- Give an existing verified borrowed observer a flat result interface, so its
  callers can compose without entering the generic scheduler between helpers.
- Return Nat quotient/remainder in a local two-word buffer, eliminating an
  intermediate heap Tuple while preserving zero-divisor and full-width behavior.
- Join exact two-function tail cycles using the existing local-loop IR. Public
  wrappers preserve their interfaces, and arbitrary/non-tail cycles retain fallback.

Legality and verification stay separate from machine rendering. The original
source/request and IR gates still run. New runtime import authority is exact and
source-bound; unknown ownership, layout or control flow does not gain permission
from an observed benchmark pattern. The tree-shell reuse and typed-private-ABI
experiments are excluded because their measurements did not justify their cost.

Use [the reproduction recipes](../../selfhost/tools/performance/phase126/validation-recipes.md)
for the ordinary, finite, runtime and compiler-cost screens. The
[native guide](../../selfhost/tools/performance/phase126/native/README-staged.md)
describes the complete bootstrap and exact comparison before storage deduplication.
The [whole-campaign guide](../../selfhost/tools/performance/phase126/BROAD-WHOLE.md)
retains the original45 batch programs under one bounded serial measurement lane.
Native one-shot qualification programs have different entry points and cannot
substitute for these timed batch programs.

The installed compiler selection is unchanged. Consult the Phase126 report before
using its experimental image: checked hosted measurements do not by themselves
establish native self-hosting, a throughput improvement or upstream parity.
