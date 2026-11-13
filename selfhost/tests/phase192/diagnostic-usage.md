# Exact preselection IR diagnostic

`diagnostic.bend` replaces only `x185_function_copied`, with its original
signature. It captures the actual `params`, `setup` and `body` passed there by
the maintained Bend optimizer. It does not reproduce optimization in the host.
The snapshot is after scratch forwarding, scalar preparation, private-memory,
local-value, expression, copy and dead-assignment processing, but before
`x186_float_function` constructs/discharges private value nodes and selects
registers/instructions. Setup remains its actual separately supplied sequence.

Add these options to the existing guarded Phase190 API preparation command,
using the exact candidate source snapshot and a fresh output root:

```text
--module selfhost/tests/phase192/diagnostic.bend
--replace x185_function_copied
```

Keep the normal `x181_prepared` export and prepare/check/acquire the diagnostic
API normally. Feed the same prepared local-fold, lexer or numeric request to
`x181_prepared`. This captures every function that reaches the boundary, so
filter afterward by the **emitted symbol**. Do not infer a source function
from a substring without retaining the complete symbol in the evidence.

Each captured function returns exactly:

```text
X181Output{
  chunks = [X188One{item = PError{error = JSON_STRING}}],
  error = ""
}
```

The program collector also emits ordinary wrapper/data chunks. Traverse the
complete `output.chunks` list and `X188Join.left/right` trees, taking every
`X188One.item` whose constructor is `PError`. Parse `item.error` as JSON and
require `kind === "phase192-preselection-ir" && version === 1`. Reject any
other PError; retain the normal outer `output.error === ""` requirement.

The exact JSON schema is:

```json
{
  "kind": "phase192-preselection-ir",
  "version": 1,
  "symbol": "exact emitted symbol",
  "params": ["ordered", "parameter", "names"],
  "setup": ["P113 node arrays"],
  "body": ["P113 node arrays"]
}
```

Every node is `[constructorName, ...fieldsInOriginalDeclarationOrder]`.
Lists are JSON arrays, strings use the maintained `sk_quote` JSON escaping,
and U32 fields are unsigned decimal numbers. Type constructors are the strings
`N111U32`, `N111U64` and `N111Ptr`. In particular:

```json
["P113DScalar", ["N111Bin", "dest", "N111U64", "add",
  ["N111Local", "source"], ["N111Const", 1, 0]]]
```

`N111Const` retains both original `lo` and `hi` words. `N111FuncId` and
`N111CtorId` retain their original symbolic names rather than resolving them.
`N111If` retains scalar children; `P113DIf` retains P113 children. All branch
and statement ordering, call argument types and lists remain intact.

Do **not** invoke `x188_render`, `x188_assemble`, an assembler, linker or target
runner on this output. PError is only a typed diagnostic transport here; this
route deliberately produces no usable function machine code. Save each parsed
object as JSON or JSONL beside the exact request/source/API receipts.

`p113e_private`/`p113e_stmts` were inspected but deliberately not used as a
lossless printer: `p113e_stmts` invokes QBE window selection (`p113w_stmts`),
branch emission selects diamonds, and `p113e_private` adds ABI/frame scaffolding.
Using that output would conflate this boundary's actual P113 body with another
backend's subsequent selection.

No compiler or target job was executed when adding this fixture. Root must run
normal independent source checking and extraction in the guarded serial lane.

## Checked host transport

`diagnostic.mjs` uses the maintained native45 source catalog and frozen
development/heldout partition. In the root-owned guard, invoke the bound engine:

```text
<bound engine> selfhost/tests/phase192/diagnostic.mjs
  --api <checked-api-authority.json>
  --binding <diagnostic-source/base-binding.json>
  --source-manifest <diagnostic-source/manifest.json>
  --cases local-fold,lexer,coverage-numeric-recurrence-256
  --out <fresh selfhost/build/phase192 directory>
```

The default selection is `development`; `all`, `heldout` and explicit
comma-separated native45 ids are also accepted. The transport requires the
sole named replacement `x185_function_copied`, the exact current diagnostic
fixture pin in the preparation receipt, the preparation-owned Base binding,
and the ordinary checked API/engine/source/oracle identity gates.

Each `<out>/<case-id>/preselection.json` is a JSON object with `kind` equal to
`phase192-preselection-case`, `version: 1`, the case `id`, and a `functions`
array containing the exact payload objects described above. `report.json`
records input/output pins, the preparation receipt and replacement hashes,
complete case status, function counts and elapsed diagnostic work. Oracle
identity is checked; no runtime oracle is executed and no target product is
created. Any non-diagnostic PError fails extraction.
