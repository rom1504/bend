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

## Optional lexer follow-up, separate from guard release

Static inspection of actual checked09 finds repeated resume work:
`ident`/`num` recompute the already-total PRNG prefix once again at phase2 although
SCon head comes entirely from saved before[0]; `gen` reprojects SCon/Chr although
resume uses only saved head/salt and child result. Public G bindings and all
fresh String/Char/Mode/Tuple construction must remain. Original typed String host
proof is mandatory before removing these projections.

Frozen saved `derive-resume-v1.py` is restored byte-for-byte to the actual consumed
root snapshot (SHAf1c46e7869dcbfcd652846bc476305e10a3e7970272c7a0788ea5d709b3a3509).
Its combined ablation passes root's439oracle/113boundary/3activation groups.
A short screen gives lexer8 14.3443→11.7604 versusTS1.7417 (1.2197× gain), but
lexer6 3.25455→3.25574 versusTS.42605 (no gain). No production resume patch is
selected. The modified handed-off v1 was corrected by restoring the consumed copy;
strengthened `derive-resume-v2.py` is a distinct frozen version with prefix-only
and projection-only modes. `resume-unicode-controls-v1.mjs` adds
48 fenced private Unicode/host-hook cases; ordinary source entry remains checked
by the unchanged full String owner controller. Source-only prefix proposal v2
adds about12 lines under exact native SCon-final-child and existing total-prefix
proof; general ADT/projection liveness is deferred.

A second residual boundary is gen's phase2
`callOwned(get(G,"gen.at"),[savedHead,savedSalt,childValue])`, executed39 times per
line. `gen.at` passes U32-first/String-result typing but the component selector
requires a direct recursive anchor; it calls acyclic `expand`, which alone calls
recursive `ident`/`num`. The linear combiner independently admits finite matches
only, so it also falls back. Frozen `derive-wrapper-v1.py` clones the exact checked
U32/U32/String wrapper body privately, with complete9-name dependency proof and
identical generic fallback arguments. It is a saved-output ablation, not checked
compiler emission. Root completed full controls, Unicode controls and screen.
`wrapper-hop-proposal-v1.patch` (21net lines, unbuilt) permits exactly one extra
acyclic hop using the existing whole typed graph and positive-self anchors, then
uses the admitted component/full-proof combiner route. It never recursively plans
arbitrary zero-self wrapper chains. Expected emission adds roughly2KiB; extra
wrapper graph scans can cost quadratic graph work and need compiler-cost checks.
All optional lexer source proposals are deferred; no further experiments are scheduled.

Wrapper v1 passes root's439oracle/113boundary/3activation groups and48 Unicode
controls, but its screen is negative: lexer8 13.91665→14.1166ms and lexer6
3.38926→3.46221ms (about1–2% slower). This rejects promotion of that per-edge
9-name proof check. The frozen `derive-wrapper-v2.py` instead changes only the
already-admitted private gen continuation to invoke the cloned wrapper directly.
Its SHA is cdb1f13419bc6387ef7f0dd8a60acc5e84fb6b30572a6b64e5e2963c21b3ebc5.
It asserts the actual transitive caller graph and ordinary root guard contain
gen.at; the original public wrapper and nested slot/expand checks remain. This
is a saved-output ablation, not compiler emission. Root's controls pass439/113/3
plus48 Unicode cases, including mutated gen.at refusal. The fresh screen gives
lexer8 14.0942→13.1775ms (1.0696× gain) and lexer6 3.30329→3.40436ms (3.06%
regression). Evidence is in `selfhost/build/phase43/lexer-wrapper-screen02/report.md`,
`run-lexer-wrapper02-controls/stdout.log`, and `run-lexer-wrapper02-unicode/stdout.log`.

A source implementation must prove caller graph inclusion at compile time.
`selfhost/src/back/js/tree.bend:537` already provides `j_covered_defs`, checking
exact definitions against both context and book; `j_covered_component` at590
uses that proof to emit an unconditional private JCall. Pass owner d from
`j_linear_split` at503 to the combiner, require admitted caller/target component
plans plus exact target-graph inclusion, and otherwise retain the exact generic
call. A nonnull runtime proof alone is insufficient authority. No such source
change has been integrated by this owner.

The completed resume attribution screen is retained at
`selfhost/build/phase43/lexer-resume-attribution-screen01/report.md`: lexer8
original/prefix/projections/both medians14.03/13.8789/12.0611/11.5488ms;
lexer6 medians3.69813/3.24402/3.17258/3.33614ms, with broad sample ranges.
Root defers all wrapper-hop, prefix and projection source work because the mixed
small gains do not justify additional emitter/proof complexity and possible
quadratic compiler work. Frozen tools, proposals and negative evidence remain for
future profiling. This follow-up does not change the U32 guard release decision.

## Fold preflight controller successor

Integration01's unchanged Phase40 fold controller fails its whole-module
single structural-owner assertion after27 value/depth oracle rows pass. Actual
Phase43 emits exactly `fold.make`, `fold.share`, `fold.order.make`, `benchRecord`
structural workers. The three additional workers are nonrecursive wrappers;
ordinary record deferred construction and public shared-child construction remain.
`fold-controls-v4.mjs` with companion derivation replaces only that brittle count
with the exact owner inventory, per-owner hashes and additional private shared
alias/order/record residual audits. All previous value/deep/public/mutation/host/
demand/admission checks remain. Source syntax and static actual inventory/alias
checks pass; root owns target qualification. The integration01 failure remains
at `selfhost/build/phase43/integration01/preflight-fold/fold-controls/report.json`.
No production change is proposed for this controller correction.
