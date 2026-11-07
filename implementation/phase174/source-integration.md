# Exact integration of the measured Phase171 candidate

Maintained QBE assembly now reproduces the measured Phase171 source byte for
byte: **3,161,409 bytes**, SHA256
`74cd7de3e5076490e20ba0218d4c9254853be72562946b9ef66fed6c10c7a53a`.
This is source integration, not a new qualification or performance result.

[Declaration manifest](source-integration.json) ·
[Metadata/refusal audit](integration-metadata-audit.json) ·
[Exact metadata integration method](../../experiments/phase174/integrate-phase171.py)

| Maintained owner | Replaced definitions | Added declarations |
| --- | ---: | ---: |
| `back/qbe/direct-lower.bend` |4|2|
| `back/qbe/flat-products.bend` |5|2|
| `back/qbe/closed-regions.bend` |1|0|
| `back/qbe/local-continuations.bend` |3|0|
| `back/qbe/borrowed-regions.bend` |1|18|
| `check/publication-reuse.bend` |2|6|

Paths are relative to `selfhost/src`. Forward laws and their implementations
share one maintained owner. The recipe retains the measured declaration order
and all six measured forward-law positions. Normal assembly uses only the
existing maintained module list and Base preamble; historical experiment files
are evidence inputs to the integration method, never build dependencies.

The metadata audit compared all8,398 unchanged declaration blocks exactly,
preserved the16 original replacement signatures, retained the native main and
all112 protected declarations, and recovered every Phase170 source byte through
the measured inverse. The final inventory is8,442 declarations, with28 additions
and none removed. The manifest lists exact original/final identities and owners
for every changed declaration and the ordered digest of unchanged declarations.

Only `order` and `inventoryChange` change in `compiler.json`. The latter describes
the latest inventory transaction: replacing its149-entry Phase169 additions list
with the28-entry Phase171 list explains the large metadata line reduction. All
8,414 prior order entries remain in their original relative order. The old
transaction remains in the pinned reference commit `c1af28f5`; module/profile,
upstream, target-version, frozen-source and protection provenance fields are
unchanged. A repeated integration invocation refuses before mutation, and the
metadata audit verified every tracked source/recipe/receipt byte stayed intact.

Only the four measured changes were integrated: definite-failure short circuiting,
lazy planner admission, request-local scalar-catalogue reuse, and the private
publication-history representation. No Phase172/173 transformation, runtime
change or additional optimization is included. Existing measured bodies and
their provenance comments are preserved rather than rewritten during promotion.

The publication-history change reaches shared checking, so JS and C source
profiles also change identity. Their emitted-source identities are recorded in
the manifest; those profiles do not inherit qualification merely because QBE
source matches the measured candidate. Root-owned source checking, correctness,
self-reproduction, performance and release gates remain separate. This work ran
no compiler targets and changed no assets, distribution files or installed
selector.
