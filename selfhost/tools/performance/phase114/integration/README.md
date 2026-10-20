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

Replay source composition with the small preparation wrapper:

```sh
python3 selfhost/tools/performance/phase114/integration/prepare.py \
  --recipe selfhost/tools/performance/phase114/integration/recipe-transport01.json \
  --out FRESH_PHASE114_SOURCE_DIRECTORY
```

It authenticates the same inventories, reuses the pinned Phase113 declaration
parser and exact replacement/append operation, then rejects any difference
between the reconstructed full declaration map and admission's expected map.
It snapshots modules, recipe and preparation method and records their pins.
This is source-file transport only; it contains no Bend lowering or optimizer
algorithm. Its resulting compiler still requires the normal checked API and
admission before target qualification. Existing source snapshots are untouched.

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

## Optional bounded continuation table

`admit-v2.py` and `prepare-v2.py` preserve the original tools and additionally
accept the frozen `recursive-table/modules01.json` inventory. That inventory
contains the exact R/G dependencies and replaces the public hook with the
reviewed complete-function → narrow → G → table → generic selection order.
It occupies the recipe's recursive-component position, so no helper is added
twice and no repeated replacement permission is introduced.

| Version 2 recipe | Expected declarations / replacements |
| --- | --- |
| `recipe-table01.json` | 6,345 / 5 |
| `recipe-table-transport01.json` | 6,372 / 7 |

Use the same commands above with the `-v2.py` tools and the selected table
recipe. Version 2 admission also accepts the original G recipes. Its table pin
is `aaeb0f545f4e5cc758173d540023ab6f7ce7388c38e8c9b0152fcf3498f2152a`.
The original `admit.py`, `prepare.py` and recipe files remain byte-identical.
These recipes establish composition only; table semantic/native qualification
is a separate obligation. Bridge integration requires a later frozen recipe.
