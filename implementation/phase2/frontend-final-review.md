# Final frontend review

A bounded read-only review checked the phase 2 grammar changes against the pinned
TypeScript parser. The [paired evidence](evidence/frontend-final-review.json)
preserves the frozen compiler identity, live reference results, consumed harness
hashes and all witness sources. These were short correctness probes on shared
CPU2, not performance measurements. No compiler source changed during this review.

The initial concern was that the new local-pattern validation might reject a
legal binder whose name becomes a constructor in a later declaration. Live
testing **falsified that concern on the actual compiler path**. Both compilers
accept this source:

```bend
import Base
def main() -> U32:
  Later = {42 : U32}
  Later
type Box is Data:
  Later{}
```

Moving the constructor before the binding makes both compilers reject the bare
constructor pattern; renaming the binder is accepted in both declaration orders.
All four acceptance/phase oracles agree. The expected rejection retains a
diagnostic-wording difference. Although standalone `f_elaborate` uses a complete
declaration book, the real graph path calls `f_module_defs`, which adds each
declaration incrementally to the pattern context. `f_parse` itself is raw parsing;
the legacy `f_parse_at` helper composes full-book elaboration, but that separate
helper was not tested or used to justify a compiler change.

Three adjacent residual grammar gaps were confirmed and retained for future work:

| Witness | Pinned TypeScript | Frozen v2 |
| --- | --- | --- |
| `@unsafe` immediately before a law | Parse rejection: requires `def` | Accepts |
| Existing constructor `On` used as a bare parallel binder in `On x = {1 : U32} {42 : U32}` | Parse rejection: constructor requires braces | Accepts |
| `[(7 + ;16 : U32)]` | Parse rejection at `;` | Accepts |

The decorator flag is checked on the new import branch but remains ignored on
law/type branches. Parallel locals use a separate scope path that does not run
the new single-local pattern validator. The list delimiter guard rejects
semicolon separators, but an operator RHS still enters the general `f_expr`
path, whose `f_skip` consumes semicolons. An unannotated `[7 + ;16]` control also
passes parsing in v2 but fails later because `.add` lacks a numeric namespace;
the annotated witness isolates the syntax acceptance difference.

These paths predate the reviewed restrictions or remain outside their coverage.
They are explicit conformance gaps, not evidence that the targeted 21- and
25-case matrices established complete grammar agreement. The proposed
declaration-order regression was disproved, so this review did not trigger a new
compiler revision or invalidate the frozen proof workload.

The [tracked replay cases](../../selfhost/tests/frontend/phase2-review/README.md)
preserve all eight inputs and the paired-run command. For the next repair batch,
prioritize parallel binder validation and decorator placement, then separate
expression whitespace from legal statement semicolons. The frozen v2 revision
remains unchanged; these known failing witnesses are a future repair queue, not
an added release gate for the current proof.
