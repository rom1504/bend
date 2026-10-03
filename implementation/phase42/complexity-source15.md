# Phase42 source15 complexity comparison

Frozen checked15 compiler source adds **1,158 physical lines, 1,011 nonblank lines, 66,698bytes and141 definitions** over starting commit `5ec82b3a92d92f46547215eca274c5bfecf47796`. Modules, source types and laws remain70,71 and640. Effective runtime adds3 physical/nonblank lines and251bytes, with no added named JavaScript function declaration. This is a substantial compiler-size increase, not a source simplification.

The [machine summary](../../selfhost/tools/performance/phase42/facts/complexity-source15.json) binds the checked15 attempt, frozen per-file hashes and producer. Counts follow the maintained Phase32/40/41 convention: UTF8 bytes, splitlines physical count, stripped nonblank lines, and top-level `^def`, `^law`, `^type` declarations for the exact compiler.json module inventory. No target or compiler execution occurred. Frozen source files were verified against attempt snapshot identities; live canonical files and raw/build trees are not the count basis.

| Canonical compiler measure | Phase41 start | Frozen source15 | Delta |
| --- | ---: | ---: | ---: |
| physicalLines | 18,898 | 20,056 | +1,158 |
| nonblankLines | 16,187 | 17,198 | +1,011 |
| bytes | 777,508 | 844,206 | +66,698 |
| defs | 2,108 | 2,249 | +141 |
| laws | 640 | 640 | +0 |
| types | 71 | 71 | +0 |
| modules | 70 | 70 | +0 |

| Changed compiler module | Physical-line delta | Definition delta | Byte delta |
| --- | ---: | ---: | ---: |
| src/back/js/emit.bend | +31 | +2 | +2,219 |
| src/back/js/finite.bend | +184 | +21 | +9,984 |
| src/back/js/fold.bend | +0 | +0 | +34 |
| src/back/js/jpure.bend | +258 | +32 | +14,105 |
| src/back/js/region.bend | +242 | +27 | +12,584 |
| src/back/js/tree.bend | +443 | +59 | +27,772 |

The assembled runtime is663→666lines and53346→53597bytes. Its maintenance split core.mjs has the same3-line/251-byte delta; these are two representations of the same runtime change and must not be added together. The runtime change is the inert Nat.add descriptor snapshot and selection, preserving the original checkedNat arithmetic/range-error body and ordinary G dispatch. No runtime type/module or native arithmetic family was added.

## Conceptual cost and reuse boundaries

The141 new definitions are mechanically grouped by symbol prefix:33 `j_flat`,27 `j_fusion`,20 `j_direct`,18 `j_pure`,12 `j_plan`,8 `j_sequence`,7 `j_covered`,6 `j_owned`,4 `j_component`,3 `j_hybrid`,2 `j_finite`, and1 `j_native`. These family counts partition new names, not independent feature implementations or runtime workers; some existing functions also changed. No new general source IR type or law accompanies these helpers, but internal plan tags and cache payload conventions still add maintenance obligations.

Request-local facts preserve complete canonical original component/direct plans, including ordered graphs, fuel and refusals. They remove repeated execution of existing walkers; the walkers remain as cache construction and fallback logic. Public ownership, host/dependency guards, caller-context coverage and frame choice remain fresh decisions. Arbitrary KDef/context/fuel-sensitive producer requests cannot use an unrelated canonical fact, and graph supersets are not interchangeable. Cache payloads are scoped to one checked operation and retain graph objects temporarily; this is neither persistent memoization nor a guarantee of lower memory use. New closed-container proof uses shared aggregate type/equality budgets to keep alias expansion bounded.

Flat covered-call lowering and native field/constructor emission reduce repeated runtime descriptor dispatch while adding source graph audits, ownership/representation checks and fallback paths. Fusion adds a bounded producer/filter/map/fold recognizer and generated loop; sequential and hybrid workers add continuation/selection obligations. Exact source container proof alone does not permit public foreign data: existing scalar-root/fullgraph guards remain required under the published standard-intrinsics-at-initialization contract. The unsupported preimport BigInt observer counterexample is retained as a contract boundary, not suppressed or treated as a supported-domain pass.

The early checked13 compiler screen shows the tradeoff rather than proving cache benefit: tree request median2492.636→2242.556ms (−10.03%), list2000.799→2241.447ms (+12.03%). Those combined-image deltas cannot isolate caching or fusion. The selected source15 four-case cost gate is pending root; source size, runtime timing and compiler request cost must remain separate claims.

## Generated and supporting volume

Generated checked compiler API grows1233516→1333190bytes (+99674bytes). This is generated output, excluded from canonical compiler source. Its SHA changes from `9900abf49719575db7f7bbee32c6b16e10bcd554f9de22cde0799eb859cc6f0b` to `4a5bdf433610d5760a7296aa64d6c2afac5dfba720ea2ebb00a6706cde906d73`. Program-generated JavaScript is not aggregated across mixed checked versions; the final source15 acquisition/cost outputs must be reported separately.

The following descriptive inventory is limited to tools/performance/phase42 and design/implementation/experiments phase42 directories. None existed as tracked files in the starting commit. It includes retained candidates, patches and copied source; it is supporting campaign volume at accounting time, not the frozen compiler or a semantic count of tests. All selfhost/build/raw directories and these two generated complexity outputs are excluded.

| Supporting category | Files | Physical lines | Bytes |
| --- | ---: | ---: | ---: |
| documentation-and-review | 70 | 8,923 | 514,302 |
| tooling-and-config-evidence | 170 | 41,759 | 3,099,653 |
| archived-or-binary-artifacts | 1 | 0 | 8,073,553 |
| controls-oracles-and-probes | 80 | 7,267 | 655,469 |
| isolated-proposals-and-copied-source | 92 | 23,267 | 1,482,218 |
| fixtures-and-proposed-bend | 45 | 7,410 | 308,307 |

The machine summary lists every supporting path and category. Archive/binary bytes are retained evidence storage and have no source-line count. Isolated proposal/copy volume is never added to production modules. Supporting counts can change as final documentation and evidence arrive; the source15 compiler/runtime identities and their comparable deltas remain fixed.
