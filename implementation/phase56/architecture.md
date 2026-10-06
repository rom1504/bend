# Phase56 source and architecture accounting

The selected compiler has **26,246 physical lines, 21,585 code lines and
3,012 function definitions** across 107 Bend modules. Relative to the frozen
installed Phase55 host02 compiler, this removes 40 physical lines, 32 code lines
and seven definitions. The datatype and module counts remain unchanged.

| Frozen manifest source | Phase55 host02 | Phase56 string01 | Change |
|---|---:|---:|---:|
| Physical lines | 26,286 | 26,246 | −40 |
| Code lines | 21,617 | 21,585 | −32 |
| Function definitions | 3,019 | 3,012 | −7 |
| Laws | 629 | 629 | 0 |
| Types | 100 | 100 | 0 |
| Bend modules | 107 | 107 | 0 |
| UTF-8 source bytes | 1,182,759 | 1,180,940 | −1,819 |

The [data-only receipt](../../selfhost/tools/performance/phase56/evidence/source-accounting.json)
uses the unchanged [Phase47 counting functions](../../selfhost/tools/performance/phase47/measure-size.py)
and verifies the Phase55 totals against its
[published source census](../../selfhost/tools/performance/phase55/evidence/source-size-host02.json).
Only each checked snapshot's manifest-listed Bend files enter these totals.
Physical lines include comments and blank lines; code lines exclude blank and
comment-only lines. `def`, `law` and `type` declarations are counted at the start
of lines. Generated API images, JavaScript support, tests and experiment tools
are not compiler-source line reductions. These are size measures, not an
independent count of architectural concepts.

## What changed

| Module | Physical lines | Code lines | Definitions | Purpose |
|---|---:|---:|---:|---|
| `back/js/array-view.bend` | −4 | −3 | −1 | Remove the unused `j_array_view_native` wrapper. |
| `back/js/jpure.bend` | −38 | −31 | −6 | Remove unused quantity, view, clone and capture helpers. |
| `back/js/direct/primitive.bend` | +2 | +2 | 0 | Add the native `String.eq` definition template and exclude it from call-site intrinsic expansion. |
| `back/js/direct/core.bend` | 0 | 0 | 0 | Admit native definition bodies directly through the existing checked primitive facts. |

The removed `jpure` functions are `j_pure_sigma_kind`,
`j_instance_view_context`, `j_instance_clones_ready`, `j_instance_capture`,
`j_map_sigma_quantity` and `j_map_closed_field_quantity`. The declaration
template emits primitive String equality as JavaScript strict equality. Calls
remain ordinary named calls, preserving their deferred operands and existing
evaluation order. This is a narrow use of the current native representation;
it introduces no new IR, pass, cache, descriptor format or calling convention.

**103 of 107 Bend modules are byte-identical**, including all 17 native-backend
modules. The complete snapshot inventory under `src/runtime/`, the assembled
legacy runtime, and the ordinary typed driver are also byte-identical: the
receipt lists all 101 matched runtime/support/driver paths. The checked B1 API
changes because its compiler source changes; its bytes are accounted separately
from source lines. The manifest's module set is unchanged.

## Binding and limits

Baseline checked attempt:
[`checked-host02/attempt.json`](../../selfhost/build/phase55/checked-host02/attempt.json),
API `cfde1ebf44d958e593331cfd9af77f7b6ee657441dbd582db8d27f3928815a62`.
Selected attempt:
[`checked-string01/attempt.json`](../../selfhost/build/phase56/checked-string01/attempt.json),
API `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`.
Every counted source is rehashed against its checked snapshot manifest, and
all consumed inputs are rehashed before writing the receipt.

Receipt SHA-256:
`ded36a1b78de18afb8625d0a535d4a52607a3c33c065c78c88e6d938d4a6abbc`.
The [reproducible producer](../../selfhost/tools/performance/phase56/qualification/source-accounting.py)
executes no compiler or generated program and disables Python bytecode writes
before importing the historical counting helper. Closed evidence is read-only.
Its fixed destination must be absent when reproduced.

The [qualification report](conformance.md) records the separate behavioral
evidence. Source accounting itself establishes neither semantic correctness
nor speed. The seven removed functions and narrow equality template simplify
this implementation modestly; the measured line reduction is about 0.15%.
