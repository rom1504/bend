# `bend5k` Generalization Split (Wave 21 -> Proven-21+)

Lightweight, anti-gaming **Development / Validation / Sealed-Test** evaluation suite for `bend5k`, split strictly by **algorithm family** with zero overlap with `bench/runtime/`, `unseen_oracle_w19/`, or `eval_split_w20/`.

## Pool Structure (Disjoint by Algorithm Family)

1. **Development Pool (seen during optimization):**
   - `bench/runtime/*`, `native45`, `research/agy/bend5k/unseen_oracle_w19/`, and the retired Wave-20 suite (`research/agy/bend5k/eval_split_w20/`).
2. **Validation Pool (`validation/` — 4 fresh families × 2 input configs = 8 programs):**
   - `v1_csv_record_scanner` (`std`, `skew`): RFC-4180 CSV quoted-field structural state machine & field hash accumulator over `Array<U32>` (5-state ADT dispatch + quote-escape handling).
   - `v2_biquad_iir_f32` (`std`, `large`): Cascaded 2nd-order Biquad IIR filter bank (Direct Form II Transposed) in `F32` over `Array<F32>` (loop-carried FP recurrence `z1`/`z2` + multi-section cascade).
   - `v3_bloom_dedup_ring` (`std`, `skew`): 3-probe bit-packed Bloom filter + circular eviction ring-buffer deduplicator over `Array<U32>` (bitset masking, dynamic shifts, conditional ring-buffer update).
   - `v4_huffman_trie_codec` (`std`, `deep`): Binary Prefix-Code Trie builder & bit-by-bit bitstream decoder over `Data` ADT `Trie` (ADT tree construction + deep read-only tree traversal).
3. **Final Held-Out Sealed-Test Pool (`test_sealed/` — 4 completely separate families × 2 input configs = 8 programs):**
   - Reserved strictly for frozen release candidates (never inspected during optimization).

## Lifecycle & Anti-Overfitting Rules

- **During optimization:** Optimizer agents may run ONLY `--split validation` (default) to check transfer of general compiler passes.
- **Validation hygiene:** If a validation family's generated assembly or hot loop is ever inspected to design a compiler pass, promote that family to the **Development** pool and replace it in Validation before the next wave.
- **Sealed-Test discipline:** Run `--split test_sealed` ONLY on frozen release candidates (e.g., Proven-21 promotion gate). Once a sealed test's per-family breakdown is revealed, retire those families for the next wave.
- **Information barrier:** Use `--aggregate-only` when reporting sealed-test results during an active wave so per-family hot-loop details are not leaked to optimizer agents.

## Strict Oracle & Anti-Gaming Rules (`evaluate.py`)

1. **Upstream compliance:** Every `.bend` program (`0 @unsafe`) passes `research/agy/locked_bun.sh --check-only` (`bend2/main.ts --check-only` on upstream `6180be5b`).
2. **Independent C oracle:** Every family has a clean, idiomatic handwritten C twin compiled with both `gcc-10 -O2 -ffp-contract=off` and `gcc-10 -O3 -march=native -ffp-contract=off`.
3. **Oracle-gated timing:** A program's timing is counted **only** when its stdout checksum matches the independent C oracle exactly and deterministically.
4. **No failure-gaming:** Any compile, link, runtime, timeout, nondeterminism, typecheck, or checksum failure is reported explicitly and **invalidates** the split aggregate score (`FAIL`).
5. **Equal family weighting:** Split scores use the **family-weighted geometric mean** (each algorithm family weighted equally, computed from the geometric mean of its input configs) alongside **total fixed-batch wall time**.

## Usage

```bash
# 1. Evaluate a candidate compiler on the Validation split (CPU 4, 5-run medians):
python3 research/agy/bend5k/eval_split_w21/evaluate.py \
  --candidate /path/to/bend5k_candidate \
  --split validation \
  --cpu-pin 4 \
  --skip-bun-check

# 2. Final frozen-candidate gate on the Sealed-Test split:
python3 research/agy/bend5k/eval_split_w21/evaluate.py \
  --candidate /path/to/bend5k_frozen \
  --split test_sealed \
  --cpu-pin 4 \
  --skip-bun-check \
  --aggregate-only

# 3. Re-freeze the Proven-20 reference baseline (includes full bun --check-only + C-O2/O3 medians):
python3 research/agy/bend5k/eval_split_w21/evaluate.py \
  --freeze-baseline \
  --split all \
  --cpu-pin 4
```

## Frozen Proven-20 Reference

Recorded in `proven20_baseline.json`:
- Compiler: `/home/ai/bend2_agy/selfhost/build/agy/bend5k/bend5k_o2` (commit `89d393d6`, flags `-O2`)
- Runtime: `/home/ai/bend2_agy/selfhost/build/agy/unified/runtime-agy.o`
- Measurements: 5-run medians (1 warmup) pinned to CPU `4` (`taskset -c 4`), verified against `gcc-10 -O2 -ffp-contract=off` and `gcc-10 -O3 -march=native -ffp-contract=off`.
