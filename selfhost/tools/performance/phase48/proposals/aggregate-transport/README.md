# Deferred private aggregate transport proposals

Neither variant is selected for production. Semantic controls and executed
constructor witnesses are useful, but the measured speed/complexity tradeoff is
negative. See the [report](../../../../../../implementation/phase48/aggregate-transport.md)
and [design](../../../../../../design/phase48/aggregate-transport.md).

This directory preserves source outside ignored build evidence. It contains
seven complete scalar03 overlay files and the vector01 emitter replacement,
plus six standard unified patches. `manifest.json` hashes every payload, patch
and preservation/materialization producer. Its SHA-256 is
`7047e651f72844a69636a832095231fdf9ce5bd53da9259271c65035eb7b8913`.
Absolute historical input paths are provenance; materializing either final
variant needs only this directory.

The baseline is repository commit
`ee54723f87db81cce64b9f762fdd116805068c8a`, pinned upstream
`018751270e800bc222a93dad7f257083ee53a5f7`. The baseline checked API is
`28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f` and runtime
`880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.
The captured files come from its frozen `source-array06`, not the live tree.

| Patch | Purpose | SHA-256 |
|---|---|---|
| `baseline-to-scalar01-failed.patch` | Original failed nonterminal-Case implementation; historical only | `e21267a6033d8c2ff53c8928e891e28c4db87efdc1f66b344813e138b46afc2e` |
| `scalar01-to-scalar02-terminal-case.patch` | Refuse nonterminal Cases before transforming | `81b658950341e1c3d7938180437f44e099b93e5d2be40dd2b5e18406ee981ff7` |
| `scalar02-to-scalar03-clear.patch` | Clear lexical result registers after complete caller capture | `ec00bbb3aaef876972698c6ecdf68cfced22a2ef84df5ff4b751f3185d59c1ee` |
| `scalar03-to-vector01.patch` | Replace register transport with one fresh private result vector | `cf1b1151715980d57a19a65250f4f767e04b0f8c7877b6bf594c6b91e7033f11` |
| `baseline-to-scalar03.patch` | Complete corrected scalar implementation | `a5a97cb990237372d9c11033c9ba977a905565f133f71b74e32b687a84ba8138` |
| `baseline-to-vector01.patch` | Complete vector implementation | `0d85df69e87852a71f96f0c251d6d2ca773e94d343648e9cdd0cb1df027542f8` |

`preserve.py` captures original frozen inputs and independently applies every
unified hunk to verify exact reconstruction. The two full patches have also
passed `git apply --numstat` parsing. Materialization of both payload variants
was verified data-only into fresh Phase48 build directories, with every file
rehash checked. No compiler or generated program is executed by these tools.

From the repository root:

```bash
python3 selfhost/tools/performance/phase48/proposals/aggregate-transport/materialize.py --variant scalar03 --out /tmp/p48-scalar03-overlay
python3 selfhost/tools/performance/phase48/proposals/aggregate-transport/materialize.py --variant vector01 --out /tmp/p48-vector01-overlay
```

The output is an **overlay**, not a complete compiler project. For a checked
reproduction, use `phase48/snapshot-candidate.py` with the frozen baseline
attempt directory and the seven explicit overlay mappings:

```text
src/compiler.json
src/back/js/jpure.bend
src/back/js/ir/worker-model.bend
src/back/js/ir/worker-values.bend
src/back/js/ir/worker-emit.bend
src/back/js/ir/worker-graph.bend
src/back/js/ir/worker-nat.bend
```

The snapshot helper's `--baseline-attempt` and the maintained preparation
runner's `--attempt` take a **directory**, not its `attempt.json` file. Keep
build, semantic and timing jobs serial under the existing resource limits.
Alternatively, apply either complete patch in a separate checkout of the
baseline commit; never apply this deferred proposal to the selected live tree.

The scalar variant adds **565 physical Bend lines / 477 nonblank, noncomment
lines / 69 definitions / two types**. The vector variant adds **537 / 451 /
65 / two**, respectively; both add one module entry in JSON. Counts compare
only changed `.bend` files plus the new module against the frozen baseline,
using physical lines, lines excluding blank or leading `#`, and lines starting
`def ` or `type `. The two new JW instruction alternatives are additions to an
existing type, not counted as new types. No line-reduction claim follows.

Original and alternative controls remain distinct under `phase48/controls`.
The scalar source/RLE witnesses require `2*n+2` removed shells and RLE15→3;
the vector witnesses require `n+2` and RLE15→8. They preserve all value/error,
reentry and public alias checks. Do not change either expectation to fit the
other physical representation. The six scaled diagnostic points never alter
the primary full45 catalog or its weights.
