# Actual-source diagnostic prototype and stop gate

The root-owned ownership-timing01 campaign completes with all16 independent
checksum observations passing. At depth8/20,000 iterations, median baseline and
candidate times are353.601/143.037ns for unique roots (ratio0.404514), and
353.714/144.965ns for shared roots (ratio0.409837). Every candidate iteration uses
the fast route. This is a roughly2.45× bounded retained-root mechanism ceiling;
it does not measure actual Map or compiler throughput. Report:
`selfhost/build/phase195/ownership-timing01/report.json`.

The next artifact is `selfhost/tests/phase195/ownership/experimental-v2/`, an
isolated diagnostic-only general planner. V1 remains frozen, including its missing
opaque-prefix collision check. V2 adds that check and four reusable list-tail
annotations found during offline affine review. Both versions have manifests;
neither has been executed or source-accepted by this subagent. The root alone
owns source-acquisition and request execution. No maintained source was edited.

The diagnostic's admission rules contain no Map, BST or benchmark names. It
constructs exact typed field layouts with opaque unsupported fields; bounded
constructor graph traversal permits branching recursive roots and rejects visible
specialization conflicts. Fixed input products are decomposed into root and scalar
slots. A single optional result is recognized by its declared zero-field/one-field
constructor shape. The copied observer origin evaluator proves every retained root
identical and every returned field below a held root; scalar existing helpers come
from the original successfully lowered observer bundle. Reconstructed cursors are
rebased only when existing constructor facts prove exact identity. Recursive result
markers must survive unchanged. Verified diagnostic summaries can be used by the
next owner in a diagnostic list, which allows a recursive helper to establish the
public wrapper's result provenance.

These mechanisms are implemented as experimental compiler source, not a host
name-based recognizer or a hardcoded replacement. The exported checked-plan wrapper
uses original runtime admission and original P113 lowering before analysis. The
host driver only transports checked source and diagnostic strings. The symbolic
residual is intentionally not executable: owned-summary result pairs have no
physical lowering. Every row states `lowering_authorized=0` and
`fallback=original-unconditionally`. No interpreter or emitter consumes the new
residual nodes, and no production hook is replaced.

The precise stop gate is still outstanding: source acquisition must pass, actual
Map.seek.go and Map.seek must return legality1, the unrelated numeric-pivot tree
reader od_find must return1, and modified-root/fresh-result/discarded-recursion
variants must return0. Preparation/acquisition and both exact request commands are
in the v2 README. A completed diagnostic run may contain legitimate refusals and
must not be reported as successful admission. Freeze all consumed files and make
any fixes in a new version; preserve source-check and diagnostic failures.

Even successful finite diagnostic results would authorize only further review and
physical adapter work. Runtime representation guards, exact result wrapping,
owned acquisition only for RFC/trivial payloads, untouched whole-function raw-hit
fallback, pending caller-frame semantics, independent lifetime oracles and selected
machine witnesses remain mandatory before a real workload timing or promotion.
The existing controls02 fixture establishes those runtime ingredients for the
handwritten ceiling only, not for this general planner.
