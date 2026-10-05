# RNFA04 explicit source reconciliation plan

Plan only. No live source, dist, tools, installed compiler or unrelated file was
modified. Selected frozen project is `selfhost/build/phase48/source-combined-rnfa04`;
checked snapshot is `selfhost/build/phase48/checked-combined-rnfa04/snapshot`.
Both must remain hash-bound to the final checked attempt before root acts.

The full read-only source inventory is
[evidence/source-reconciliation-plan.json](evidence/source-reconciliation-plan.json),
SHA256 `e58ec4f5e3a2fe77c0591a242fb6db8feaafacb3bc8c3e1e8c687a4242dc38b6`.
It finds13 differing existing files, zero missing selected files, and three live
extras. All other source bytes match04. No wildcard source-directory replacement,
git reset or git clean is required or proposed. Phase6 and the103 unrelated
starting files are outside this inventory.

## Durable preimage and deferred proposals

Every live byte in all16 affected files is preserved under
`selfhost/tools/performance/phase48/proposals/selected-reconciliation-v1/live-before/`.
Its manifest SHA256 is `57ee73a63cb20881127bfb292e973978ff0e6c86419e35a3c7e27ddd3d0bd734`.
This includes the mixed live emitter/manifest that does not match either isolated
H/V proposal exactly. All archived bytes were rehashed against the frozen live
inventory, with no target execution. A hash alone is not the archive: complete
files are present outside ignored build evidence.

H's durable `function-flow-integration/function-flow-isolated-h-v2.patch` was
applied in memory against checked array06 and reproduced all four source-flow02
files exactly. V's durable aggregate-transport manifest has16 archived files,
all rehashed successfully; it preserves full scalar03/vector payloads and six
recorded exact patch reconstruction edges. These are deferred research mechanisms,
not selected04 source. The live preimage archive additionally captures their
actual current combination with the other slices.

## Safe explicit action recipe for root

1. Rehash the selected attempt, manifest source rows, runtime, all16 live preimages
   and all archive files immediately before mutation. If any live hash differs,
   stop and produce a successor inventory/archive instead of overwriting it.
2. Copy only the13 replaceOnly paths in the inventory from frozen04 to the live
   matching path: array-effects, array-literals, array-view, emit, fold, local,
   region, tree, ir/worker-emit, ir/worker-graph, ir/worker-model, ir/worker-nat,
   and compiler.json. Verify each copied hash against selectedSha256.
3. Remove only the three archived extras: ir/function-flow.bend,
   ir/function-flow-root.bend and ir/worker-values.bend. Do this after verifying
   their live/archive hashes and the final compiler.json excludes those modules.
4. Compare the entire resulting source file set and bytes with frozen04. Check
   all92 module paths are present and unique, all helper definitions selected,
   and no unlisted H/V implementation remains. A source diff is not a build.
5. Rehash runtime/tools/tests and retained installed metadata before/after.
   Their identities must remain unchanged during source reconciliation. Root's
   maintained-eight/install jobs must use the frozen checked04 artifacts and
   their receipts; source copying must not silently regenerate or substitute API
   or runtime. Installation is a separate authorized root workflow.

The exact thirteen replacements plus three archived removals are sufficient for
this observed source state. Do not delete other unlisted files in selfhost/build,
previous phases, tools, tests or unrelated trees. If later root work changes the
source state, preserve this plan as historical and create a new version.
