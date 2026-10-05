# Final measurement and publication plan

This is a prepared procedure, not a completed release or writer-closure receipt.
The root agent selects the exact checked candidate, runs target work serially,
and decides when every raw writer has stopped. Historical Phase45–47 tools,
bundles and raw trees remain read-only. Every output below must be fresh.

## Full runtime comparison

Reuse the maintained Phase37 catalog and Phase48's already prepared array06/TS
baseline. The [Phase48 queue](../../selfhost/tools/performance/phase48/run-corpus.py)
is a narrow derivative of the frozen Phase47 queue: explicit bundle arguments,
Phase48 destinations and preserved queue provenance. It invokes the existing
`programs/run.py` three times, with the catalog's first, middle and last 15 IDs.

```sh
python3 selfhost/tools/performance/phase48/run-corpus.py \
  selfhost/build/phase48/baseline/manifest.json \
  "$P48_CANDIDATE_MANIFEST" "$P48_FRESH_CORPUS_OUT"
```

The caller sets `P48_CANDIDATE_MANIFEST` to the selected complete 45-point
acquisition and `P48_FRESH_CORPUS_OUT` to a nonexistent Phase48 raw directory.
Each batch uses the unchanged 600-second preset: five fresh rotated rounds per
role, except the existing three-round raytrace policy. CPU 3, Node 24.18.0,
1,024 MiB heap, 2,048 MiB process-tree RSS and 4,096 MiB available-memory floor
remain unchanged. The maintained runner owns `ExecutionGuard`; do not wrap this
queue in another process holding the same execution lock. Keep CPU 7, CPU 3's
SMT sibling, quiet during timing. Compilation, profiles and publishers run at
other times. The preset is a deadline and coverage choice, not a promise to use
exactly 600 seconds.

After all three batches pass, the queue calls the unchanged
[Phase44 summarizer](../../selfhost/tools/performance/phase44/summarize-runtime.py).
Its explicit CLI is also usable after an interruption without rerunning completed
batches:

```sh
python3 selfhost/tools/performance/phase44/summarize-runtime.py \
  selfhost/tools/performance/phase37/catalog.json \
  selfhost/build/phase48/baseline/manifest.json \
  "$P48_CANDIDATE_MANIFEST" "$P48_FRESH_SUMMARY" \
  "$P48_BATCH0_REPORT" "$P48_BATCH1_REPORT" "$P48_BATCH2_REPORT"
```

Admission requires all 45 IDs exactly once, 669 passing samples, equal source
and point bindings, the same API/runtime/Base/compiler roles and resource
protocol, exact rotated sample order, nonoverlapping process intervals, and
agreement between embedded observations and sample/process leaves. Every recorded
input is rehashed. An incomplete or failed batch is retained and rejected as
aggregate evidence; do not substitute an earlier candidate's timing.

The [Phase48 renderer](../../selfhost/tools/performance/phase48/render-results.py)
retains Phase47's saved-data verification prefix: it independently recomputes
all 135 medians and ratios, then the equal-point, equal-source and equal-family
geometric means. Its [derivation receipt](evidence/runtime-renderer-derivation.json)
pins the parent and exact changes. Labels and interpretation are data-driven;
Phase47's hardcoded short-fold/tree regression conclusions are not inherited.

```sh
taskset -c 0 python3 selfhost/tools/performance/phase48/render-results.py \
  "$P48_FRESH_SUMMARY" "$P48_EXPECTED_API_SHA256" \
  "$P48_EXPECTED_RUNTIME_SHA256" "$P48_DESCRIPTIVE_CANDIDATE_LABEL"
```

It requires fresh `implementation/phase48/results.md` and
`implementation/phase48/evidence/runtime-summary.json` outputs. The report includes
every point, observed regressions, TS wins, drift and exact role identities.
These 45 corpus-informed points are not an untouched holdout or every Bend
program. No diagnostic counter/profile samples enter the timing aggregates.

## Exact source and emitted-output accounting

[measure-size.py](../../selfhost/tools/performance/phase48/measure-size.py)
imports only the hash-pinned Phase47 counting/snapshot functions and the maintained
bundle reader. It disables Python bytecode writes before loading historical
helpers, executes no compiler or generated program, and extracts no archives.

```sh
taskset -c 0 python3 selfhost/tools/performance/phase48/measure-size.py \
  --baseline-attempt selfhost/build/phase47/checked-array06 \
  --baseline-bundle selfhost/build/phase48/baseline/manifest.json \
  --candidate-attempt "$P48_CHECKED_ATTEMPT" \
  --candidate-bundle "$P48_CANDIDATE_MANIFEST" \
  --out "$P48_FRESH_SIZE_RECEIPT"
```

The exact baseline is **23,254 physical lines, 19,175 nonblank/non-comment
lines, 2,622 definitions, 87 types and 86 manifest-listed Bend modules**. The tool
asserts those values rather than silently changing the denominator. It records
per-module deltas and separate API, checked API, assembled runtime and runtime-core
sizes. These image sizes are not added to maintained Bend line counts.

Output accounting verifies the full catalog, both compiler tuples and every
module hash. It reports all 45 points, the 23 source groups, changed points and
sources, and distinct `(source hash, output hash)` pairs. Observation-adapter
variants remain explicit rather than being discarded or counted as extra source
programs. Generated sizes include runtime prefixes. Their point/source geometric
byte ratios are size statistics, not execution gains or a count of concepts.

## Portable benchmark bundles

The baseline already exists through the reviewed Phase48 baseline-method
derivation. Do not regenerate, recompile or alter it for publication.
[publication-method.py](../../selfhost/tools/performance/phase48/publication-method.py)
freezes two narrowly modified Phase47 tools plus their parent bytes and an exact
derivation receipt. It does not itself package, compress, execute or install.

```sh
python3 selfhost/tools/performance/phase48/publication-method.py \
  --out "$P48_FRESH_PUBLICATION_METHOD"
```

After clean timing has stopped, root runs the emitted freezer on CPU 0:

```sh
taskset -c 0 python3 "$P48_FRESH_PUBLICATION_METHOD/freeze-current.py" \
  --from "$P48_CANDIDATE_MANIFEST" --attempt "$P48_CHECKED_ATTEMPT" \
  --baseline selfhost/build/phase48/baseline/manifest.json \
  --out selfhost/tools/performance/phase48/current \
  --baseline-out selfhost/tools/performance/phase48/baseline \
  --method-out "$P48_FRESH_FREEZER_OUTPUT" \
  --expected-api "$P48_EXPECTED_API_SHA256" \
  --expected-runtime "$P48_EXPECTED_RUNTIME_SHA256" \
  --label "$P48_DESCRIPTIVE_CANDIDATE_LABEL"
```

The expected candidate hashes must come from the selected checked attempt and
agree with the qualification receipts; API alone is insufficient. Starting
array06 API/runtime hashes are explicit defaults in the derivative. All outputs
are confined to fresh Phase48 locations, with historical portable bundle
inventories rechecked afterward. The unchanged Phase44 candidate freezer audits
the full acquisition; the original freezer label/manifest is preserved and a
separate derivation changes only the displayed Phase48 label and its pointer.

Both portable bundles are reopened through the maintained reader for all 45
points. Candidate module bytes must equal the timing inputs. Run the normal
portable smoke separately if selected, and identify it as a fresh execution
receipt rather than packaging evidence. Packaging does not establish compiler
installation, language conformance or performance improvement.

## Selected receipt and archive boundary

The Phase47 selected-receipt join is the model, not a file to copy blindly:
its candidate name, 27-request cost count and four Array control groups are
historical constants. A Phase48 join must use the actual selected attempt and
completed report paths. Required bindings include:

- Exact checked API, runtime, Base, manifest and frozen source files.
- Selected focused probes, maintained suites and all selected R/N/F/A mechanism
  controls, with each scope/count retained separately. Do not sum overlapping
  observations into a language-test count.
- Complete 45/669 runtime summary and the separately scoped compiler-cost report,
  using the actual request count and candidate identities.
- Installed compiler receipt, CLI smoke, portable publication/optional smoke,
  and final accounting cutoff. Installation must be independently verified.
- The 103-file protected inventory, unchanged and unstaged, plus preserved
  failed, refused, rejected and unselected attempts.

No fresh full frontend/native/GPU or fixed-point claim is inherited from earlier
phases. State precisely which fresh semantic inventories were run. The final
index should link the selected receipt, portable manifests, reports and
prerequisite Phase45/46/47 evidence by immutable hashes; it must not treat a
prototype's inclusion in the capsule as promotion.

Only after every raw writer, target job, diagnostic, publication preflight and
accounting update has finished does root create `writers-closed.json` and the
final protection receipt outside `selfhost/build/phase48`. Those receipts bind
the exact raw root, cutoff, selected attempt/API and original protected inventory.
No tool in this plan declares writer closure automatically.

Reuse the unchanged bounded streaming archive producer:

```sh
taskset -c 0 python3 selfhost/tools/performance/phase42/validation/archive-campaign-v1.py \
  --raw selfhost/build/phase48 \
  --out selfhost/tools/performance/phase48/evidence/raw \
  --writers-closed selfhost/tools/performance/phase48/evidence/writers-closed.json \
  --protected-final selfhost/tools/performance/phase48/evidence/protected-final.json
```

It retains every regular raw file, including failures and consumed tools,
rejects symlinks, streams bounded chunks, reopens and hashes every member, and
rehashes the entire source inventory before publication. Its historical
`phase42-closed-raw-campaign-archive` kind remains unchanged; the receipt's actual
`rawRoot` identifies Phase48. Never append a ledger event under the closed root.

If the verified gzip exceeds 40 MiB, run the emitted
`publish-archive-parts.py` on CPU 0. It requires the exact Phase48 raw root,
preserves the original stream, verifies every ordered part and the concatenated
size/hash, and ignores only the unsplit local stream. A capsule below the limit
stays a single tracked file. The index must record actual part names/counts;
recovery instructions must never guess them.

Finally, publish the index and recovery documentation outside raw, binding the
archive/parts metadata, closure/protection receipts, selected/installed receipts,
portable manifests and only Phase48 maintained documentation/tool identities.
Keep unrelated working-tree files outside this campaign's staging scope. Any
later experiment starts in a successor raw directory with fresh receipts.
