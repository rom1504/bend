# `bend5k` Generalization Split (Wave 20 -> Proven-20+)

Lightweight, anti-gaming **Development / Validation / Sealed-Test** evaluation suite for `bend5k`, split strictly by **algorithm family**.

## Pool Structure (Disjoint by Algorithm Family)

1. **Development Pool (seen during optimization):**
   - `bench/runtime/*`, `native45`, and the 6 Wave-19 workloads in `research/agy/bend5k/unseen_oracle_w19/`.
2. **Validation Pool (`validation/` — 4 families × 2 input configs = 8 programs):**
   - `v1_tlv_decoder` (`std`, `skew`): Binary TLV/packet protocol decoder over `List<&2, Packet>` (8-way ADT switch dispatch + read-only borrow).
   - `v2_fir_filter_f32` (`std`, `large`): 1D FIR digital signal convolution over `Array<F32>` (FP accumulation + dual-array hoisting).
   - `v3_base64_codec` (`std`, `large`): Table-driven 64-entry Base64 encoder + FNV-1a checksum over `Array<U32>` (`.rodata` LUT + 3-byte bit-packing).
   - `v4_list_partition_tree` (`std`, `skew`): Functional 3-way list partition -> BST build & in-order fold over `List<&2, U32>` (allocation, `IReuse`, TRMC, multi-field return).
3. **Final Held-Out Sealed-Test Pool (`test_sealed/` — 4 completely separate families × 2 input configs = 8 programs):**
   - Reserved strictly for frozen release candidates (never inspected during optimization).

## Lifecycle & Anti-Overfitting Rules

- **During optimization:** Optimizer agents may run ONLY `--split validation` (default) to check transfer of general compiler passes.
- **Validation hygiene:** If a validation family's generated assembly or hot loop is ever inspected to design a compiler pass, promote that family to the **Development** pool and replace it in Validation before the next wave.
- **Sealed-Test discipline:** Run `--split test_sealed` ONLY on frozen release candidates (e.g., Proven-20 promotion gate). Once a sealed test's per-family breakdown is revealed, retire those families for the next wave.
- **Information barrier:** Use `--aggregate-only` when reporting sealed-test results during an active wave so per-family hot-loop details are not leaked to optimizer agents.

## Strict Oracle & Anti-Gaming Rules (`evaluate.py`)

1. **Upstream compliance:** Every `.bend` program passes `research/agy/locked_bun.sh --check-only` (`bend2/main.ts --check-only`).
2. **Independent C oracle:** Every family has a clean, idiomatic handwritten C twin compiled with both `gcc-10 -O2 -ffp-contract=off` and `gcc-10 -O3 -march=native -ffp-contract=off`.
3. **Oracle-gated timing:** A program's timing is counted **only** when its stdout checksum matches the independent C oracle exactly and deterministically.
4. **No failure-gaming:** Any compile, link, runtime, timeout, nondeterminism, typecheck, or checksum failure is reported explicitly and **invalidates** the split aggregate score (`FAIL`). A compiler can never improve its score by failing on a slow program.
5. **Equal family weighting:** Split scores use the **family-weighted geometric mean** (each algorithm family weighted equally, computed from the geometric mean of its input configs) alongside **total fixed-batch wall time**.

## Usage

```bash
# 1. Evaluate a candidate compiler on the Validation split (CPU 7, 5-run medians):
python3 research/agy/bend5k/eval_split_w20/evaluate.py \
  --candidate /path/to/bend5k_candidate \
  --split validation \
  --cpu-pin 7 \
  --skip-bun-check

# 2. Final frozen-candidate gate on the Sealed-Test split:
python3 research/agy/bend5k/eval_split_w20/evaluate.py \
  --candidate /path/to/bend5k_frozen \
  --split test_sealed \
  --cpu-pin 7 \
  --skip-bun-check \
  --aggregate-only

# 3. Re-freeze the Proven-19 reference baseline (includes full bun --check-only + C-O2/O3 medians):
python3 research/agy/bend5k/eval_split_w20/evaluate.py \
  --freeze-baseline \
  --split all \
  --cpu-pin 7
```

## Frozen Proven-19 Reference

Recorded in `proven19_baseline.json`:
- Compiler: `/home/ai/bend2_agy/selfhost/build/agy/bend5k/bend5k_o2` (commit `801fde8a`, flags `-O2`)
- Runtime: `/home/ai/bend2_agy/selfhost/build/agy/unified/runtime-agy.o`
- Measurements: 5-run medians (1 warmup) pinned to CPU `7` (`taskset -c 7`), verified against `gcc-10 -O2 -ffp-contract=off` and `gcc-10 -O3 -march=native -ffp-contract=off`.
