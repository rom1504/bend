# P43-005 — Entry guard evidence

Checked06's actual emitted total-U32 list fusion passes the 82-case semantic
oracle. A fresh short screen improves list128 by1.206× and list512 by1.049× over
Phase42. These are two-point screen results, not final throughput qualification.
Checked07 remains pending; its selected API/runtime must rerun the bound gate.

## Selected mechanism

The survivor uses `regionHostGuard(u32Fusion=false)` with a private precomputed
15-hook dependency subset. Every descriptor is read anew on each public entry;
no mutable host facts survive calls. Full successful `j_fusion_root_prefix` proves
all inputs/result U32 and the entire producer/filter/map/fold scalar whitelist.
The exact successful body selects the narrow guard and is emitted under the
original proof try/finally. Empty proof retains full host validation and existing
flat/generic selection. Other worker/region guards retain the full default.

The narrow domain skips25 floating numeric-hook descriptor checks, four own
floatView method descriptors and one floatView prototype query. Global Object,
Reflect, WeakSet, Math, Number, BigInt and Array identities, Object/Array/iterator
protocol/key inventories, Number.isInteger, Math.imul and every callable dependency
identity/metadata/bound check remain. ScalarGuard is unchanged, including the new
String-family gate. Runtime grows12 net lines rather than duplicating the guard.

## Actual checked06 identities and semantic evidence

[Derivation](../../selfhost/build/phase43/guards-actual06/derivation.json) binds the
actual checked module receipt, all compiler/tool/source pointers and immutable
source snapshot. Clean candidate and control are byte-identical copies; only
paired diagnostic copies add counters/exports. No guard flag or body is rewritten.

| Identity | SHA256 |
| --- | --- |
| API | `37877ddcb1b9e7d1bc6020c328217e02050b8d1a857188ccb4c6537a3e94c16f` |
| Runtime | `21969475eff26c16725c18e2c3d151d610fee02148bb5dbb494a94ba207d519f` |
| Actual list module | `ebc078b638b0d219b2501d4d2b5783be78f52a77df858e9c22e83b763e5b01ed` |
| Unmodified Phase42 list control | `661f268bef195c0fecb034697f09818229e1bcbe953caf97a481769084b38d1c` |

[Actual controls](../../selfhost/build/phase43/run-guard-actual-controls06/stdout.log)
pass82 cases in10.67s. Canonical entry activates actual full fusion. Controls cover
G binding/code/arity/env/bound mutations and getters, own call/io markers, every
captured numeric/protocol descriptor, Array/Object/primitive marker/iterator/every
hooks, F32 view methods, Error observation reentry, noncanonical input refusal,
raw code entry refusal, partial saturation and argument getter reentry. Complete
value/error/demand traces match control; omitted floating mutations may activate
fusion only while preserving all observable results/traces. Proof cleanup passes.

The canonical grid includes24 combinations of sizes0,1,2,8,128,512 and seeds
0,17,123,U32max, compared to an independent BigInt recurrence. Complete stages at
8,17 are producer `[1,12,11,14,5,0,15,2]`, filter `[12,11,14,5,15,2]`, map
`[24,22,28,10,30,4]`, sum118; producer root is fresh and source stays unchanged.
This is the named semantic scope, not universal compiler correctness.

## Short measurement

[Checked06 screen](../../selfhost/build/phase43/checked06-screen01/report.json):

| Point | Phase42 | Checked06 | TypeScript | Gain | Checked06/TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| list128,17 | .0158975 | .0131847 | .00660089 | 1.206× | 1.997× |
| list512,123 | .0176413 | .0168155 | .0302283 | 1.049× | .556× |

Root owns all timing. Point512's small gain needs final balanced qualification;
there is no general1.2–2× claim. The initial hypothetical target was not uniformly
reached. Final selected-image results belong to the root report.

## Preserved attempts and failures

Exact AfterHost duplication passed76 semantic cases
([receipt](../../selfhost/build/phase43/run-guards-oracle04/stdout.log)), but its
3–4% short-screen gain did not justify a duplicated scalar guard; root rejects or
defers it. Standalone scalarGuard optimization was rejected before execution
because it could remove observable Array.every/iterator hooks without a dominating
host guard. Source scalarGuard remains unchanged.

U32 whole-guard clone v1 passed its saved-output oracle; short-screen gains were
1.134×/1.106×. Minimal parameter v2 passed78 cases including grid/stages
([receipt](../../selfhost/build/phase43/run-guards-u32-oracle02/stdout.log)).
All versioned tools and patches remain in the owned guard directory.

Initial oracle empty stdout/JSON failure and diagnosed child-spawn EPERM receipts
are preserved under `run-guards-oracle01` and `run-guards-oracle03`; outside-sandbox
successor retained the same caps. Checked05 exposed an assembled-runtime omission:
the emitted true flag had the old runtime guard. Root regenerated runtime.mjs and
built checked06; the actual controller explicitly rejects that missing parameter/
subset implementation. Checked05 is not successful domain activation evidence.

## Reproduction and remaining gate

```sh
python3 selfhost/tools/performance/phase43/guards/derive-actual-v1.py --candidate ACTUAL_LIST.mjs --baseline selfhost/build/phase43/guards03/control.mjs --out OUT
/home/ai/.nvm/versions/node/v24.18.0/bin/node selfhost/tools/performance/phase43/guards/oracle-actual-v1.mjs OUT
```

Candidate receipt defaults to module path plus `.json`. Explicit candidate/
baseline receipts are supported. Without a baseline receipt its exact Phase42
manifest identity/source is mandatory. The controller binds proof to the receipt's
immutable snapshot and verifies the real true guard and full emitted U32 kernel.
Run again on checked07 or the final selected image; checked06 success does not
qualify a later API/runtime. Root schedules all semantic and performance execution.
