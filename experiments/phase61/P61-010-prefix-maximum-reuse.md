# P61-010 — Reuse the actual prefix maximum during resume

Registered 2026-10-07 before source application or outcomes. State07's checked
build and 14 leaf controls have passed; this separate experiment has no result.

**Hypothesis:** Resume currently walks the complete prefix/suffix for its bound,
then walks the prefix again for admission. Computing the actual prefix maximum
once and the suffix maximum separately removes one full Base term walk without
extra serialized state, a second validation contract, or trusted cached bounds.

**Invariant:** `norm_max_book(join(p,s)) = norm_max(norm_max_book(p),
norm_max_book(s))`. The existing fold visits every definition's type and value
and nested constructor definitions; `norm_max` is associative with zero identity
on U32. No terms are evaluated or resolved during this walk. The private helper
receives the freshly computed prefix maximum. Public
`base_prefix_admitted_final` keeps its signature and computes that maximum itself.
All other admission guards, raw fallbacks and resumed world fields stay unchanged.

**Cheapest disproof:** Immutable `carrier-controls-v3.mjs` retains v2's 29 full
world/fallback rows and five producer cases, and adds eight exact maximum cases:
empty, Base/empty both ways, split/reversed Base fragments, maximum U32 in a type,
maximum in a body, and nested constructor definitions. Joined and separate bounds
must equal independent goldens, with unchanged inputs. Its admission diagnostic
calls the new live helper with a freshly computed bound; it does not grant
permission from a caller-provided bound. Root owns targets and selection.

Patch: `selfhost/tools/performance/phase61/prefix-state/prefix-maximum-reuse-v1.patch`.
This is separate from prepared-position caches and adds no cache field. A combined
candidate's latency cannot be attributed solely to this change.
