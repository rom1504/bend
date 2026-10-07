# Phase61 compiler-source footprint

State08 contains **27,753 physical lines / 22,799 code lines / 3,192 definitions**
across 114 manifest-listed Bend modules. Relative to installed Phase58 last01,
that is **+1,193 physical lines, +976 code lines and +137 definitions**. These
are source-size counts, not a complexity, simplification or speed claim. State08
correctness controls pass; its performance and final release remain separate.

The [data-only receipt](../../selfhost/tools/performance/phase61/evidence/source-footprint-state08.json)
uses each checked attempt's frozen `src/compiler.json` and verifies every listed
module against the snapshot's hash records. Both use the same unchanged Phase47
counting functions also used by the [Phase58 account](../phase58/source-complexity-last.md).
The baseline manifest has 108 modules; state08 has 114. No live-tree contents or
generated assembly headers are substituted for those frozen inputs.

| Metric | Installed Phase58 last01 | State08 | Change |
|---|---:|---:|---:|
| Physical lines | 26,560 | 27,753 | +1,193 |
| Blank lines | 3,663 | 3,818 | +155 |
| Comment-only lines | 1,074 | 1,136 | +62 |
| Code lines | 21,823 | 22,799 | +976 |
| `def` declarations | 3,055 | 3,192 | +137 |
| `law` declarations | 629 | 642 | +13 |
| `type` declarations | 101 | 112 | +11 |
| Manifest modules | 108 | 114 | +6 |
| UTF-8 bytes | 1,197,433 | 1,260,521 | +63,088 |

Physical lines use Python `splitlines()`. Blank lines have no non-whitespace
characters; comment-only lines begin with `#` after optional whitespace. Code
is the remainder, including inline comments on code lines. Declarations count
line-start `def`, `law` and `type`; they do not estimate algorithmic complexity.

Of the old modules, **97 retain exact bytes and 11 change**; six are added:
`check/env-telescope`, `check/env-substitution`, `check/prefix-state`,
`load/prefix`, `back/js/direct/host-native` and `back/js/direct/transport`
(all under `selfhost/src/`, with `.bend` suffix). All 17 native-emitter modules
retain exact bytes. The receipt contains every module's counts and change delta,
including the already applied removal of 47 unused JDText wrappers.

Runtime and host support are separate from these Bend totals. All **100 files**
in the frozen runtime inventory retain exact bytes; that inventory includes its
own support tests/docs and assembled `src/runtime.mjs`, so it is not an additional
source-line total. The direct runtime and ordinary runtime are unchanged. Two
maintained host helpers change separately:

| Host helper | Physical lines: before → after | Bytes: before → after |
|---|---:|---:|
| `tools/typed-driver.mjs` | 761 → 908 | 53,800 → 65,640 |
| `tools/development/workflow.mjs` | 195 → 200 | 18,124 → 18,531 |

Fixtures, validation/performance tools, tests outside that runtime inventory,
research/design documents and retained artifacts are **excluded** from compiler
source totals. This report is not a whole-repository growth census. Derived B1
API bytes are separately 1,852,132 → 1,936,485; generated-image bytes are not Bend
source lines, and this is not a state08 B2 size claim.

Reproduce with the [reviewed producer](../../selfhost/tools/performance/phase61/validation/source-footprint.py)
and a fresh output path; it reads and hashes data only, never importing or running
a compiler. The frozen attempt directories and pinned Phase47 helper must exist.

```sh
taskset -c 0 python3 selfhost/tools/performance/phase61/validation/source-footprint.py \
  --baseline selfhost/build/phase58/checked-last01 \
  --candidate selfhost/build/phase61/checked-state08 \
  --out selfhost/tools/performance/phase61/evidence/source-footprint-state08-replay.json
```

The producer refuses overwrites and rehashes consumed inputs before publication.
Receipt SHA256: `e2e2f2687a4e2eecb6291d90ea931dacf8313f174ea5661ce284d8151fa4ab36`.
No compiler, benchmark or historical archive was executed or rewritten.
