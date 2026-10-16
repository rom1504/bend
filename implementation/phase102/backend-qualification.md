# Phase102 backend qualification

The qualified candidate covered here is `depth-inline-source01/compiler.bend`, SHA
`535c1f8f8d19cdddebeb397e3ef461346488b92feae28fa363a110ff136286d9`.
Its standalone snapshot has **39,228 physical lines: 438 more than Phase98**.
It retains scoped local calls, bounded branch specialization, generic TRMC,
owning-observer composition and private cell reuse. Three immutable dependency
passes now bound forced-inline hints while retaining the 8 KiB local cutoff.

| Gate for this exact source | Current evidence |
|---|---|
| Source/authority correspondence | PASS: `authority-source-audit02/report.json` |
| Fresh permission/provider/raw-input controls | PASS: 7/7, `authority-consumed02.json` |
| Checked-API generated program controls | PASS: 153 executions, 27 cases, `depth-controls01/report.json` |
| Upstream-built native B1 | Complete: `native-b1-02/b1.json` |
| Independent reference and genuine B1 self emission | PASS with identical full diagnostics: `native-chain02/reference` and `b1-self` |
| Genuine native B2 build | PASS: 377.2 s, `native-chain02/b2.json` |
| B2 self fixed point | PASS: exact C and full diagnostics, `native-chain02/b2-self/report.json` |
| Native live/cache/refusal and broad controls | PASS: 22 requests and all 45 broad programs across both images |
| Native conformance | PASS: 138 observations, 69 eligible fixtures per image, plus 6 rejection observations |
| Final native new-mechanism correspondence | PASS: 34 emissions for 17 sources, all exact prior C; 130 complete output observations inherited |
| Backend evidence bridge | PASS: `backend-specific02/report.json`; does not itself admit an image |
| Original five final-image controls | PASS: 10 final-image emissions, 5 exact stage pairs and 5 complete native executions |
| Native image admission | Qualified: `native-chain02/admission.json`; default selection remains false |

All raw paths above are beneath `selfhost/build/phase102/`. The independent
reference emits 39,409,532 bytes of C for this source; genuine B1 emits
30,124,590 bytes. These are product sizes, not compiler-speed measurements.
The B2 Clang build finishes within the unchanged 420 s guard at 2.58 GB peak
process-tree RSS; its binary is `e5eb6b4e…`. This closes the predecessor's build
failure. Genuine B2 reproduces B1's complete C and diagnostics. Native admission
is closed with `qualified: true` and `defaultSelection: false` (receipt SHA
`2451ab2a…a1c391`). Performance comparison and selecting an installed release
remain separate. The later projection experiment has its own
[review and rejected attempts](projection-review.md); these qualifications do
not automatically carry to that changed source.
The [coordinator plan](native-qualification-plan.md) retains every original
qualification gate. A successful API screen or B1 self emission does not by
itself qualify a native compiler release.

## What carries forward, and what is checked again

The [source audit](../../selfhost/tools/performance/phase102/qualification/audit-source-v2.py)
replays and reverses the complete recipe from installed Phase98 source
`2a72bbdc…`. Its receipt SHA is `3bfd44cd…bed2b41`.

- Fourteen authority declarations remain byte-exact. Two routing changes are
  explicitly audited: `nf_plan_scoped` adds owning-adapter composition;
  `ns_compile_named_scoped` adds local-worker composition only with observer
  permission and no reachable bang calls.
- Relative to Phase98, seventeen functions change and sixty-five are added.
  All 159 type declarations and 658 law declarations remain unchanged.
- The original five permission-proof definitions and eight tag/comparison
  definitions remain exact. Their thirteen safe laws retain their original
  proof/source identities; no fresh kernel or native-lifetime proof is claimed.
- Exact helper/type closures, including their pinned Base dependency, support
  narrow inheritance of eighteen permission-helper Boolean observations and
  eleven origin decisions. The lexical closure audit establishes source
  correspondence; it is not a language-semantics proof.

The inline successor is separately reconstructed from its predecessor: exactly
six functions change hint/signature plumbing and two dependency helpers are
added. One computed set controls prototypes, ordinary workers and both TRMC
functions. This bounds forced NF dependency depth; it does not bound Clang's
final inlining or machine-code size.

Fresh authority execution takes 6.753 seconds. The unchanged reviewed
[consumer](../../selfhost/tools/performance/phase102/qualification/consume-authority.py)
closes `authority-consumed02.json`, SHA `87327750…56f315`, against the new API.
It checks the original three checked/prepared/explicit-false/raw entry cases,
changed-provider refusals where providers exist, unknown-provider refusal,
and three forged/internal observer inputs. Only the forged-context product
inherits an old runtime observation: its complete C is byte-identical to the
original executed product, whose complete `7n` output is reread. Changed
positive-program C receives no historical runtime credit.

## Do the focused checks catch relevant faults?

Three independent one-operation mutations of the final checked-API C all fail
the unchanged complete-output oracle (`fault-run01/report.json`, SHA
`9dff48a1…4a09f8`). All build and finish normally within their guards; none is
counted through a timeout, signal or build failure. Total run wall time is
5.68 seconds.

| Mutation | Observed rejection |
|---|---|
| Write a three-field TRMC constructor's pending child into the wrong field | Exit, stdout and stderr differ |
| Swap two recursive String arguments | Exit 0, but stdout differs |
| Replace the observer's comparison result with equality | Exit 0, but stdout differs |

This demonstrates useful sensitivity to these three faults. It is finite
mutation evidence, not a proof of the compiler or an additional positive
release gate. Original controls, expected bytes and production source remain
unchanged; the isolated mutated C and raw results are preserved.

## Backend collection and image gates

The frozen [backend consumer](../../selfhost/tools/performance/phase102/qualification/backend-bridge.py)
requires all 27 control IDs and every specified payload/worker count. It joins
final native B1/B2 C and diagnostics to complete prior executions or fresh
executions, matching unique outcomes, commands, C identities, exit codes and
full stdout/stderr against the unchanged oracles. It retains the old collector's
schema for compatibility; its own result remains `imageQualified: false`.

The coordinator has completed the following **data-only** collection against
`native-chain02/inheritance/report.json`; it passes without executing targets:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase102/qualification/backend-bridge.py \
  --source-audit selfhost/build/phase102/authority-source-audit02/report.json \
  --authority selfhost/build/phase102/authority-consumed02.json \
  --backend-policy selfhost/build/phase99/phase102-final-plan02/policy/policy.json \
  --controls selfhost/build/phase102/depth-controls01/report.json \
  --native-inheritance selfhost/build/phase102/native-chain02/inheritance/report.json \
  --out selfhost/build/phase102/backend-specific02
```

The original five native controls all pass unchanged: real IO, generic array,
schema refusals, all 1,444 String pairs with fourteen observations each, and
origin-swap refusal. They complement the new cases and do not replace live/cache
checks, 45 broad semantic programs, 69 native fixtures per stage, the independent
self-source reference or the B1/B2 fixed point. Final image admission and public
selection remain separate gates.

## Retained failed predecessor

The earlier `8b895aec…` candidate adds **425 lines**, not 438. Its API controls,
applications, B1 and self emission passed, but its B2 Clang build **hit the 420 s
deadline** in `native-chain01/b2-build`. It has no successful B2 qualification.
The source, failure, source audit01 and authority-consumed01 remain preserved.
The new depth policy addresses that build-cost failure; prior success is never
relabelled as an execution of the new compiler.
