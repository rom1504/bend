# Exact combined-source admission

`admit.py` checks composition provenance before the independent semantic and
native gates. It runs no compiler, target, synthetic source mutation, or
benchmark. Its declaration parser and comparison reuse the authenticated
`packing/admit.py` helpers. As in that method, comparison ignores blank lines,
comment-only lines and trailing whitespace; executable declaration contents and
the complete declaration set must match.

Two frozen recipes are available:

| Recipe | Selected components | Expected declarations / replacements |
| --- | --- | --- |
| `recipe-01.json` | Verification session, indexed product catalogue, guarded unary packing, general recursion G02 with the v5 scanner | 6,281 / 5 |
| `recipe-transport01.json` | Same components plus final-emission frame/pop/get transport | 6,308 / 7 |

Each recipe lists inventory pins, module extraction fields and permitted
replacement names in composition order. These must also match the tool's
explicit frozen policy; editing a recipe cannot grant an additional override.
Inventories include all their source modules, including scaling controls.
G02 retains the original G code and selects the separately reviewed faster
narrow scanner. G01 and earlier source snapshots remain unchanged.

The check authenticates candidate31, its existing admission and pinned inputs,
the selected inventories and their referenced files, and the unchanged runtime
source/object. It constructs the expected complete declaration map, rejects
undeclared or repeated replacements, checks the scaling replacement texts, and
requires exact renamed original fallback declarations for packing and optional
transport. The checked API receipt must bind the actual candidate bytes and
export the ordinary lowering, final verifier and admitted renderer. Its API
file is authenticated. No compiler image or target qualification is inferred.

Without transport, all original public verifier declarations remain exact.
With transport, its wrapper calls the exact old verifier before the extra
namespace gate. Verification-session records remain internal derived values;
the original final verification is mandatory. Source provenance remains the
basis for ownership and scratch separation; this receipt does not turn a
reflected graph or scratch name into a certificate.

From the repository root, after the candidate API has passed checking:

```sh
python3 selfhost/tools/performance/phase114/integration/admit.py \
  --recipe selfhost/tools/performance/phase114/integration/recipe-01.json \
  --compiler CANDIDATE_COMPILER \
  --api-report CHECKED_API_REPORT \
  --runtime-source selfhost/build/phase113/runtime-products01/runtime.c \
  --runtime-object selfhost/build/phase113/runtime-products-build01/runtime.o \
  --out FRESH_PHASE114_ADMISSION_DIRECTORY
```

Use `recipe-transport01.json` for the transport composition. Success writes
`manifest.json` with the candidate/API/runtime pins, every authenticated input,
module list, exact replacement digests, and source-only scope. Output must be a
new directory under `selfhost/build/phase114`; failure writes no success receipt.

Future components, including a recursive continuation table, need their frozen
inventory, an explicit allowed-override policy in a new method revision, and a
new recipe. A component that replaces an earlier hook must preserve the required
earlier behavior through a separately reviewed combined declaration; arbitrary
last-writer replacement is not authorized by these recipes.

Preparation validation was limited to Python syntax and constructing both
expected maps from the authenticated real inventories. No candidate admission,
generated IR, compiler/API, or native target was executed during preparation.
