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

## Version 3 table overlays

`admit-v3.py` and `prepare-v3.py` wrap the pinned v2 methods without modifying
them. The core is always table01 plus transport01. The optional overlays are
applied in this order: structured unwind, table-first routing, packed Take1.
Each has a fixed inventory digest, extraction rule and replacement allowlist;
a recipe cannot authorize another module or hook. Bridge is not included.

The layer authenticates each overlay's exact unoverlaid table parent and its
checked API or composition admission. The parent's entire declaration map must
equal the reconstructed v2 table-plus-transport map. Table and transport source
lists must match their inventories. Packed Take1 must retain the exact renamed
table verifier, unchanged runtime, and its five checked helper exports. The
delegated v2 admission still requires an exact final candidate declaration map,
successful API receipt bound to those candidate bytes, and the original runtime
source/object. Earlier verifier and namespace gates remain required.

| Recipe under `recipes-v3/` | Declarations / replacements |
| --- | --- |
| `table.json` | 6,372 / 7 |
| `table-unwind.json` | 6,376 / 9 |
| `table-first.json` | 6,373 / 8 |
| `table-packed.json` | 6,396 / 9 |
| `table-unwind-first.json` | 6,377 / 10 |
| `table-unwind-packed.json` | 6,400 / 11 |
| `table-first-packed.json` | 6,397 / 10 |
| `table-unwind-first-packed.json` | 6,401 / 12 |

For example, prepare the selected source with:

```sh
python3 selfhost/tools/performance/phase114/integration/prepare-v3.py \
  --recipe selfhost/tools/performance/phase114/integration/recipes-v3/table-unwind.json \
  --out selfhost/build/phase114/FRESH_SOURCE_DIRECTORY
```

After the normal checked API has succeeded for that exact compiler source:

```sh
python3 selfhost/tools/performance/phase114/integration/admit-v3.py \
  --recipe selfhost/tools/performance/phase114/integration/recipes-v3/table-unwind.json \
  --compiler CANDIDATE_COMPILER \
  --api-report CHECKED_API_REPORT \
  --runtime-source selfhost/build/phase113/runtime-products01/runtime.c \
  --runtime-object selfhost/build/phase113/runtime-products-build01/runtime.o \
  --out selfhost/build/phase114/FRESH_ADMISSION_DIRECTORY
```

Packed recipes require `p114pk_shape`, `p114pk_buffer`, `p114pk_stmt`,
`p114pk_namespace` and `p111q_ids` in addition to the three normal exports.
The replay wrapper reuses the exact v2 source transporter and Phase113 parser;
only its authenticated declaration-map callback is extended. Both receipts
pin the wrapper and delegated methods. `methods-v3.json` freezes those methods,
all eight recipes and their expected counts.

Preparation checks were Python syntax, authenticated map construction for all
eight combinations, and one full-combination replay in memory. That replay
had 2,313,893 bytes and SHA256
`5e59e79ae622a076e3280831e9be77119fd4ac0bebfc21a30a0f8398db1ede48`.
No compiler, API or native target was executed. A different declaration order
in a manually composed source is accepted only when its complete normalized
map matches; its own exact byte pin still needs a successful checked API.

## Version 4 namespace traversal

`recipe-table-unwind-first-namespace01.json`, `prepare-v4.py` and `admit-v4.py`
retain the exact selected v3 recipe and append only the frozen
`transport/namespace-tail-modules01.json` overlay. It replaces six flat-list
namespace wrappers and adds six direct self-tail accumulator helpers. The
parent source, successful API and composition admission are authenticated; its
full declaration map must equal the selected v3 map. The original verifier,
namespace predicate and error wrapper remain exact. Packed Take1 and bridge
are excluded.

Use the same commands above with `-v4.py` and the namespace recipe. The three
normal checked exports remain sufficient: `p113a_lower_request`,
`p113a_verify`, `p113a_admitted_chunks`. Expected counts are 6,383 declarations
and 16 replacements. `methods-v4.json` pins the methods, recipe and overlay.
In-memory source replay produced 2,306,979 bytes, SHA256
`500211d484785778e75d5d4388b0d5ebc7282effd233c6b8f3d0e0269ac777f8`.

Source review establishes `go(xs, valid) = valid && old(xs)` for each finite
flat list. Recursive calls are the outermost helper return, with conjunctions
used only to compute the next accumulator. Nested branch traversal is
unchanged and remains recursive. Actual generated-JS loop inspection and the
full compiler retry are separate checks; no compiler target was run while
preparing this integration. The earlier qualified final-source01 and all v3
method hashes remain unchanged.

The subsequent successful `p114-final-api02` was inspected without execution.
All six actual JS helpers contain one `for (;;)` loop, rest/accumulator updates
and `continue`, with zero direct self calls. The body walker has four such
branches; each other helper has one. Exact function excerpts and API/source
pins are recorded in `implementation/phase114/namespace-js-review01.json`
and its companion `.txt`. This establishes the flat traversal shape, not the
outcome of the full compiler retry.

## Optional version 5: P114-010 table buffers

`recipe-table-buffers01.json`, `prepare-v5.py` and `admit-v5.py` append only
`transport/table-buffers-modules01.json` to the exact source02/v4 recipe.
This is an optional experiment, not a change to selected source02. The design
is `experiments/phase114/P114-010-table-buffer-transport-coverage.md`.

The two permitted replacements are `p114t_buffer` and `p114t_local_name`;
only `p114t_table_buffer_at` and `p114t_table_buffer` may be added. Admission
authenticates the complete source02 declaration map, parent API/admission,
runtime, transport/table/namespace inventories and the frozen allocation,
renaming and frame-template declarations. The original final verifier is
unchanged. Checked exports must include the three normal gate exports plus
`p114t_table_buffer`, `p114t_buffer` and `p114t_local_name`.

Use the same CLI with `-v5.py` and the table-buffer recipe. The prepared optional
snapshot is `selfhost/build/phase114/table-buffers-source01/compiler.bend`,
2,307,628 bytes, SHA256
`0ef15ba8db16fae9147d00c54e442ec62fff1ed74fef612d0db4d39526759f1e`.
Expected counts are 6,385 declarations and 18 total replacements. Its preparation
receipt records the full module transport and pins; `methods-v5.json` freezes
the method, recipe and pre-target design. Compiler/API, ordinary semantic,
runtime and selection gates remain pending and separate. Earlier methods and
selected sources remain byte-identical.
