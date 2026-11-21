# Packet-window scan transfer

The frozen program integrates two segments of timestamped U32 samples into a circular telemetry window. The first segment and the resumed segment write the same 64 cells at different absolute timestamps. They share the final carry. Three seeded positions differ from the initial fill. The ordinary point wraps the U32 timestamp in the first segment, wraps the ring many times, and resumes at another offset. It uses independent names and data from the 128-cell local-fold benchmark. The per-cell contract retains the ascending ring traversal, modular addition, XOR with the full timestamp, and array-first result required by the proposed four-lane rule.

| Point | Size | Seed | Segment starts | Segment lengths | Timed whole-state digest |
| --- | ---: | ---: | --- | --- | ---: |
| Primary | 6,147 | 305,419,899 | 4,294,967,295 and 3,989,547,403 | 6,147 and 1,232 | 2,148,527,053 |
| Alternate | 263 | 4,294,967,293 | 4,294,967,293 and 13 | 263 and 55 | 1,289,343,279 |

Each correctness observation prints the final carry and all 64 U32 cells in their physical slot order. Every timed repetition hashes those 65 words and checks the frozen digest for the selected point. Eight additional sizes and seeds exercise empty first segments, scalar tails, capacity boundaries and disjoint restarts. They use the complete printed result with zero timed repetitions. [Bend program](packet-window.bend), [independent scalar oracle](oracle.py), and [full vectors for all points](oracles.json).

The Bend source froze at SHA-256 `62f91b9f53e3f094414549368432cabe6cae4253d457ad22cc93db216b78877a` before acquisition or timing on either target. The scalar oracle file froze at `ddea827a138db0006e377f4e67b112d4d9699f1d41499695be4947c6e55180d5`. The first guarded baseline uses the pinned upstream source and zero-hole checker, the Phase198 progress N2 direct encoder, and the same public Bend-C emitter and Clang policy as the existing mature local-fold reference. [Baseline and oracle driver](baseline.py).

For the original local-fold input variation, use size 6,149 and seed 4,045,620,583. The expected carry is 1,660,901,827; the independent oracle also retains its 128 final cells. The ordinary original binary can check this carry with zero warmups and repetitions. For a timing point, [original-alternate.py](original-alternate.py) substitutes exactly one harness success constant. The original worker, harness wire format, inputs and semantics are unchanged. Check both scalar and candidate whole outputs before rotating timed pairs. A separate raw-worker ABI experiment owns exact array/carry/canary comparisons on the original worker.

From the repository root, the reproducible baseline command under the shared Phase199 scheduling guard is

```bash
python3 -B research/phase199/screen/job.py --rss-mib 3072 transfer-base-FRESH 25 48 \
  python3 -B research/phase199/scan-transfer/baseline.py --out selfhost/build/phase199/transfer-base-FRESH
```
