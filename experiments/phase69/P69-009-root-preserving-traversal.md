# P69-009: retain an unchanged root while traversing through borrowed fields

Status: saved-C arms prepared; no target results yet. The hypothesis below was
registered before construction. Only root owns target execution.

`Map.bit.go` returns the same String contents that it receives, paired with a
computed bit. Both current compilers consume and reconstruct the traversed String
prefix. P69-007's product island yielded only a modest runtime effect, so the
next discriminator removes that reconstruction work rather than merely changing
the temporary pair representation.

Hypothesis: preserving the owned String root while following borrowed cursors,
computing the scalar result with the existing admitted worker, and returning
that root at the unchanged boxed boundary removes enough allocation, reference
counting and reconstruction continuations for a material Map improvement.

This is a typed-value diagnostic, not a production Base-name rewrite. A future
compiler feature would prove a recursive return-identity summary and root lifetime
across reconstruction helpers. The diagnostic checks immediate Nat bounds, String
constructor tags and visited character representation; an unsupported shape
declines to the intact original scheduler body without changing ownership. The
root stays owned throughout, so RFC and static nodes use normal `term_peek` reads.
No foreign calls, mutation or capture escape occur while the root is borrowed.

The source-only producer records every edit and input identity, keeps original
matching/error code as fallback, and changes no runtime helpers or scheduler ABI.
Polling remains but its frequency differs from a scheduler-per-character walk;
raw/async error equivalence and all foreign-created heap shapes are not claimed.
Only root executes one/four-thread output controls, allocation counters and clean
balanced timing against unchanged/compiler/upstream sources.

A win justifies a general proof/analysis experiment, not automatic promotion.
An unrelated reconstructing traversal, shared/static input, malformed tags,
multiple aliases, escaping results and demand/error controls are prerequisites
for a production feature. The String-comparison analogue can be a separate arm.

Source artifacts:

- [`root-preserve.py`](../../selfhost/tools/performance/phase69/product-transport/root-preserve.py)
  prepares the Map-bit-only arm in
  `selfhost/build/phase69/map-root-preserve23-prep01/`.
- [`root-preserve-strings.py`](../../selfhost/tools/performance/phase69/product-transport/root-preserve-strings.py)
  prepares String comparison in
  `selfhost/build/phase69/map-root-strings23-prep01/`, and the independent
  combined arm in `selfhost/build/phase69/map-root-both23-prep01/`.
- [`return-identity.md`](../../selfhost/tools/performance/phase69/product-transport/return-identity.md)
  describes the general origin-summary proof and ownership integration, plus
  evidence explaining the weak return of the preceding product-only island.

Independent review found no source blocker in the declared typed immutable
String domain. Shared roots and tails stay owned; `term_peek` handles RFC/static
nodes; unsupported shapes decline after reads only. This is not raw-equivalence
qualification. In particular, the diagnostic insertion precedes the original
shared-error check, and short loops may not poll. Production must preserve
entry/error policy as well as prove identity on every returning branch.
