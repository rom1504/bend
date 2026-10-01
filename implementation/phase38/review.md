# Independent research review

Three parallel research streams produced nine chapters; root studied the pinned
Bend TS backend, Koka and Chez, integrated the collection and mined proposals.
Agents then reviewed source claims, local evidence and synthesis read-only.
No target execution or optimization was part of this review.

## Corrections incorporated

| Finding | Why it matters | Resolution |
| --- | --- | --- |
| Fusion's denominator differs from most rows | A future direct-unfused baseline is not installed Phase37 | Method and ranking explicitly permit the named comparator; estimates cannot be multiplied |
| Purity does not preserve eager map/filter error order | A late map error and early predicate error can swap | E04 requires total non-hooking bounded operations or an unchanged demand schedule |
| Shape, ownership and demand were too closely grouped | Known tag does not authorize reuse; private origin does not force fields | Architecture table separates shape from escape/lifetime permission and demand |
| Near-48-bit countdown tests could be impractical | Boundary testing must not require 2^48 iterations | E01 requires bounded-step/early-exit or isolated boundary fixtures with a trip cap |
| Numeric loop already has one outer guard | Its sampled guard cost does not imply repeated nested guards | Scope-only I02 targets ray; numeric guard requirements become a separate, smaller, low-confidence hypothesis |
| Callback effort depends on scope | One known callback is much smaller than general higher-order admission | Ranking distinguishes 2–5-day narrow subset from 1–3-week general work |
| Historical full-tree gain used Phase36 | Reusing it as a current incremental result would overstate progress | Historical denominator and same-run component/finite comparison remain explicit |

## Source-level cautions retained

- MLton closure conversion creates finite lambda-set dispatch; that alone does
  not imply closure allocation disappears. Flattening has deliberate limits.
- GHC SpecConstr's discussion of arbitrary lambda-parameter specialization is
  exploratory, not proof that the pass implements it. Usage facts can need
  invalidation, and recursive specialization needs size/count bounds.
- Vector's apparent stream module is a re-export in the inspected version;
  the chapter cites the actual `vector-stream` implementation.
- Original Flambda and OxCaml Flambda2 are distinguished. Known aliases do not
  prove nonaliasing or unique ownership.
- Lean/Koka borrowing and uniqueness depend on their runtimes. Bend's affine
  source does not expose JavaScript's reference count.
- JS VM watchpoints/dependencies are unavailable as an ordinary generated-JS
  API; a public-call epoch cache is not a sound replacement for our guards.
- Cranelift's concrete bounded optimizer and unsuccessful more elaborate
  strategies are more relevant than importing equality saturation wholesale.
- Alive2/CompCert/Souper results apply to their semantic models and trusted
  boundaries; they do not prove our host ABI or convert unknown into pass.

## Review limits

This is a literature/source review, not a formal audit of other compilers.
Source snapshots were read selectively. Some references use dated development
branches rather than exact hashes, identified in their chapters. Documentation
checks resolve local files and JSON and rehash selected inputs; they do not
prove every remote link will remain accessible or every proposed optimization.
No gain estimate becomes measured evidence merely because reviewers accept its
scope. The reports preserve uncertainty and stopping conditions.
