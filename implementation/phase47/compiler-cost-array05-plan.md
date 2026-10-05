# Final array05 compiler-cost screen

Status: prepared commands only; no plan factory, compiler request, cache priming,
acquisition, or target execution has been run by this owner. Execute after the
array05 source/API freeze and after the active corpus campaign stops.

Use **local-fold, editdist, and lexer**, with three requests per variant and input
(27 total), under the unchanged Phase30 worker and existing Phase47 runner.
Replace local-pair with editdist for this final screen: the
[nested-array entry diagnosis](nested-array-entry.md) identifies editdist's
binary-tree helper declarations as the new compiler work. Local fold retains a
common raw-array entry; lexer retains the larger unrelated compilation input.
This selection observes the new tree cost without expanding the campaign.
It is a regression-input sample, not a universal compiler-latency estimate.

The tree proposal predicts additional lexical helper declarations, audits, and
generated code. It gives no measured compiler-cost promise. Sharing the existing
tree recognizer/body bounds implementation scope but does not eliminate this
work. The final screen measures whole checked-library requests; it cannot assign
the resulting difference solely to the tree audit or emitter.

[compiler-cost-plan-v1.py](../../selfhost/tools/performance/phase47/compiler-cost-plan-v1.py)
is a data-only factory. It requires the exact Phase39 planner, Phase30 worker,
and current Phase47 runner hashes. It changes only the original tool-directory
anchor, the two 4-GiB available-memory settings already used in array04, and the
default cases. It emits a fresh planner plus an explicit derivation receipt.
The actual planner retains all acquisition/compiler/cache identity gates and
historical metadata verbatim; the separate receipt supplies current attribution.
The factory does not itself execute that planner or create a measured config.
It copies the three exact Worker23 modules and their unchanged checked-emission
receipts from `phase45/full-preparation-worker23/manifest.json` into a fresh
baseline subset. Only manifest role keys change from original `candidate` to
current `baseline`; compiler identities and receipt bytes remain unchanged.
The original manifest hash, source/point, catalog, checked attempt, compiler, and
output digests are required before copying. No baseline compilation is needed.

Root-only commands follow. Set `ATTEMPT` to the final frozen checked array05
attempt, and `CANDIDATE_PREPARATION` to its complete, unadapted full acquisition
manifest. Both must describe the same API/runtime/driver. All output directories
must be fresh. If a command fails, preserve it and choose a new suffix for retry.

```sh
NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
ATTEMPT=selfhost/build/phase47/checked-array05
CANDIDATE_PREPARATION=selfhost/build/phase47/array05-full/manifest.json

# Candidate full acquisition must already have primed the exact candidate API's
# Base cache; Worker23 retains its previously primed verified cache. The pinned
# TypeScript acquisition already contains these sources. This data-only factory
# copies only three frozen baseline modules/receipts and emits the planner.
python3 selfhost/tools/performance/phase47/compiler-cost-plan-v1.py \
  selfhost/build/phase47/compiler-cost-array05-producer01

python3 selfhost/build/phase47/compiler-cost-array05-producer01/planner.py \
  "$ATTEMPT" "$CANDIDATE_PREPARATION" \
  selfhost/build/phase47/compiler-cost-array05-plan01 \
  --baseline-attempt selfhost/build/phase45/checked-worker23 \
  --baseline-preparation selfhost/build/phase47/compiler-cost-array05-producer01/baseline/manifest.json \
  --typescript-preparation selfhost/build/phase37/typescript01/manifest.json \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --cases local-fold,editdist,lexer

python3 selfhost/tools/performance/phase47/compiler-cost-run.py \
  selfhost/build/phase47/compiler-cost-array05-plan01/config.json \
  selfhost/build/phase47/compiler-cost-array05-screen01
```

The final command preserves CPU 3, rotated three fresh processes per variant,
1,024-MiB V8 heap, 2,048-MiB process-tree RSS, 4,096-MiB available-memory floor,
60-second request deadlines, and the existing 240-second campaign limit. Do not
extend a consumed attempt silently if the new input exceeds the campaign limit.
The existing plan's `timeoutMs=180000` field is unchanged; the Phase47 execution
runner applies its narrower 60/240-second envelope.

Require complete/pass on the plan, all 27 requests, and final report. Each
emission must match that variant's independent acquisition digest; different
compiler variants need not produce identical bytes. Record source/API/runtime/
Base/cache/worker/runner identities, sample ranges, whole-process RSS, host-import
times, request medians, emitted sizes, and campaign wall time. Pre/post verification
and writing/hash-checking expected output remain outside the request timer;
lazy API loading and ordinary Base-cache handling remain inside Bend `inspect`.

Preserve [array04 compiler cost](compiler-cost.md) and
[its summary](evidence/compiler-cost.json) unchanged. When root supplies the
completed array05 report, write a distinct final-cost outcome and hash-bound
summary; compare common fold/lexer rows explicitly and identify editdist as a
different third input. Do not merge the separate memo diagnostic reduction into
either normal candidate measurement. Generated-program execution remains a
separate study. This owner reserves that final data-only reporting follow-up.

## Completed final successor: array06

The original array05 command proposal above remains unchanged. Root froze the
final successor as `checked-array06`, used the same fold/editdist/lexer selection,
and completed `compiler-cost-array06-plan02` plus all 27 cost requests in
`compiler-cost-array06`. The first `compiler-cost-array06-plan` was refused by
the occupied execution lock before any binding child or measured request; its
`preparation.json` is retained. The successful final cost campaign passed in
216.740 seconds. See [final outcome](compiler-cost-final.md) and
[hash-bound final evidence](evidence/compiler-cost-final.json) for exact medians,
ranges, output pins, and API/runtime identities. No array04 data or consumed plan
was changed. This appendix records completed compiler cost separately from the
independently measured generated-program corpus.
