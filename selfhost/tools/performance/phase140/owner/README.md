# Internal owner reuse experiment

The checked Bend implementation reuses annotation, erasure, generic raw lowering and private candidate products belonging to unchanged owners. It does not replace parsing, checking, ownership/entry admission, the annotation consistency check, static preparation, optimizer closure or the independent final verifier. Root integration owns the complete session and publishes the returned state only after the complete request succeeds.

## Active checked modules

Compose, in order, `core-v03.bend`, `products-v01.bend`, `raw-v01.bend`, `controls-v01.bend` and `bridge-v01.bend` with the Phase140 source composer. The independently checked source is `selfhost/build/phase140/owner-source03/compiler.bend`, SHA256 `a2cf9b106da319a507cab448cd7b1eab58a0783d3d04d0554b493a8bb664e50f`. API04 exposes the existing fresh pipeline for differential comparisons. `evidence-v01.json` pins the actual source and receipts.

- `p140of_context(context, verdict, previous)` returns `P140OFResult{plan, cache, stats}`. Supply the exact context at the existing `p86_plan_entry` boundary, after the original driver, ownership and entry gates. It reruns `jl_checked_error` before accepting annotation and constructs the original `NR_Request`. Stats: annotation hits/misses, erasure hits/misses, dirty owner count and analysis admission.
- `p140or_lower(request, previous)` returns `P140ORResult{lowering, cache, stats}`. It preserves `nc_compile_error_known`, static preparation, the original generic/private producers and original initial closure. Stats: generic hits/misses, private hits/misses, dirty owner count, analysis admission and global-key admission.
- Empty states are `p140of_empty()` and `p140or_empty()`. These are internal typed values in one process built by one producer, not serialized or untrusted cache entries. A failed overall request must retain the previously successful states.

## Invalidation contract

Whole-book exact keys would make every edit miss. Instead, the implementation requires exact ordered names, types, child declarations, flags, Foreign bodies and global fresh bound, then compares owner bodies and propagates changes through a conservative old dependency graph. The graph includes every term name and implicit primitive-type dependencies. Annotation normalization can unfold definition bodies, so a caller must be invalidated transitively even when all public types are unchanged. Changed owners get a refreshed graph for the next revision; old edges remain sufficient for invalidating unchanged owners in the current revision.

Raw lowering additionally requires exact ordered reachable names, bang flags, complete signature context and static image node offsets/contents. Changes to derived erased/static bodies also invalidate callers. A cached generic product must have the same incoming global fresh counter. Therefore shifted global IDs, constructor/header changes or static-pool movement safely miss; stable owner symbols and relocation are not implemented here.

This is a conservative implementation with finite and differential evidence, not a formal proof that every possible compiler observation has been modeled. The state must remain private to the pinned producer. Root integration must test the real full compiler and reject any structural/final-output mismatch.

## Results

All 18 finite controls pass: exact no-op reuse, changed leaves and transitive callers, cycles, refreshed dependencies, unrelated edits and conservative refusal for changed bounds, headers, Foreign bodies, inserted names, absent graphs and static image mutations.

The real two-edit screen compares the entire `P128RawLowering`, including generic segments and private candidates, rather than just hit counters. It passes cold, warm and unchanged-request comparisons. Original downstream optimization and independent verification then produce exactly the same B QBE as independent fresh lowering. A matches frozen native reference QBE, and B differs from A.

| Same-path body edit | Raw fresh B | Raw warm B | Generic/private hits versus misses | Observation |
|---|---:|---:|---:|---|
| Lexer shift constant 13 to 12 | 0.557 s | 0.768 s | 33 / 12 | Warm path is 38% slower in this ordered screen |
| Map multiplication constant 31 to 29 | 2.888 s | 0.799 s | 69 / 3 | Raw stage is 3.62 times faster in this ordered screen |

These are single ordered hosted observations, affected by JIT warmup and shared-process allocation. They are not calibrated native or end-to-end results. The full screen costs 48.16 seconds and peaks at 640 MB under the CPU4/3 GiB guard. Cold acquisition, frontend, downstream optimization, verification and output remain separate costs. No-op raw times are 0.336 s and 0.467 s with all 45 and 72 owners reused. Dependency/key scans can outweigh the skipped small lowerings; the Lexer negative result must be retained.

Annotation/erasure bridge code is independently source checked; this screen exercises only the raw bridge on genuinely prepared requests. Full context/session differential tests remain an integration gate.

## Reproduction

Use a fresh Phase140 output directory for every command and the shared resource guard. API04 and its pinned inputs must still match their receipts.

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase140/owner-screen02-guard --seconds 90 \
  --rss-mib 3072 --available-mib 16384 --file-mib 64 --cpu 4 -- \
  selfhost/.bootstrap/bun-1.4.3/bun \
  selfhost/tools/performance/phase140/owner/screen-v01.mjs \
  selfhost/build/phase111/p140-owner-api04/report.json \
  selfhost/build/phase140/owner-screen02
```

The script orchestrates checked Bend exports and independent exact comparisons; it contains no compiler transformation. `finite-v01.mjs` transports the Bend finite control results. Earlier core-v01/v02 source-check failures remain preserved (missing affine sharing annotations). The first finite guard also retains an incorrect Bun-path failure; the successful binary is `.bootstrap/bun-1.4.3/bun`.

## Cost opportunities, not measured gains

The current conservative analysis scans headers, owner bodies and derived facts, then repeats comparisons during dependency refresh and scans edges to a fixed point. Avoiding repeated equality work and skipping propagation on zero dirty owners are cheap follow-ups. A reverse dependency index or stable symbols could reduce larger costs but should follow actual integrated native profiles. Global static-image/key mismatches deliberately fall back; this experiment does not solve relocatable literals or promise broad 5–10 times warm rebuild speed.
