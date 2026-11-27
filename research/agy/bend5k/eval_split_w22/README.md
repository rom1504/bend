# `bend5k` Generalization Split (Wave 22 -> Proven-22+)

Lightweight, anti-gaming **Development / Validation / Sealed-Test** evaluation suite for `bend5k`, split strictly by **algorithm family** with zero overlap with `bench/runtime/`, `unseen_oracle_w19/`, `eval_split_w20/`, `eval_split_w21/`, or `hand_asm_w21/kernels/`.

## Pool Structure (Disjoint by Algorithm Family)

1. **Development Pool (seen during optimization):**
   - `bench/runtime/*`, `native45`, `research/agy/bend5k/unseen_oracle_w19/`, `research/agy/bend5k/hand_asm_w21/kernels/`, and the retired Wave-20 & Wave-21 suites (`eval_split_w20/`, `eval_split_w21/`).
2. **Validation Pool (`validation/` — 4 fresh families × 2 input configs = 8 programs):**
   - `v1_sha256_compress` (`std`, `large`): FIPS 180-4 SHA-256 64-round ARX compression function + 64-word message schedule expansion (`W[0..63]`, `K[0..63]`, bit rotations, `Ch`/`Maj`, chaining state).
   - `v2_thomas_tridiag_f32` (`std`, `large`): Implicit 1D diffusion Tridiagonal Matrix Algorithm (Thomas solver) in `F32` over multi-array `Array<F32>` (forward elimination with `F32.div` + reverse-index back-substitution).
   - `v3_dsu_kruskal_union` (`std`, `skew`): Disjoint-Set Union (Union-Find with path halving & union by rank) over `Array<U32>` processing streaming graph edges and cycle/merge queries.
   - `v4_aatree_persist_map` (`std`, `deep`): Persistent AA-Tree balanced BST (`skew`/`split` structural rotations + lookups) over recursive `Data` ADT `AATree`.
3. **Final Held-Out Sealed-Test Pool (`test_sealed/` — 4 completely separate families × 2 input configs = 8 programs):**
   - Reserved strictly for frozen release candidates (never inspected during optimization).

## Lifecycle & Anti-Overfitting Rules

- **During optimization:** Optimizer agents may run ONLY `--split validation` (default) to check transfer of general compiler passes.
- **Validation hygiene:** If a validation family's generated assembly or hot loop is ever inspected to design a compiler pass, promote that family to the **Development** pool and replace it in Validation before the next wave.
- **Sealed-Test discipline:** Run `--split test_sealed` ONLY on frozen release candidates (e.g., Proven-22 promotion gate). Once a sealed test's per-family breakdown is revealed, retire those families for the next wave.
- **Information barrier:** Use `--aggregate-only` when reporting sealed-test results during an active wave so per-family hot-loop details are not leaked to optimizer agents.

## Strict Oracle & Anti-Gaming Rules (`evaluate.py`)

1. **Upstream compliance:** Every `.bend` program (`0 @unsafe`) passes `research/agy/locked_bun.sh --check-only` (`bend2/main.ts --check-only` on upstream `6180be5b`).
2. **Independent C oracle:** Every family has a clean, idiomatic handwritten C twin compiled with both `gcc-10 -O2 -ffp-contract=off` and `gcc-10 -O3 -march=native -ffp-contract=off`.
3. **Oracle-gated timing:** A program's timing is counted **only** when its stdout checksum matches the independent C oracle exactly and deterministically.
4. **No failure-gaming:** Any compile, link, runtime, timeout, nondeterminism, typecheck, or checksum failure is reported explicitly and **invalidates** the split aggregate score (`FAIL`).
5. **Equal family weighting:** Split scores use the **family-weighted geometric mean** (each algorithm family weighted equally, computed from the geometric mean of its input configs) alongside **total fixed-batch wall time**.

## Usage

```bash
# 1. Evaluate a candidate compiler on the Validation split (CPU 2, 5-run medians):
python3 research/agy/bend5k/eval_split_w22/evaluate.py \
  --candidate /path/to/bend5k_candidate \
  --split validation \
  --cpu-pin 2 \
  --skip-bun-check

# 2. Final frozen-candidate gate on the Sealed-Test split:
python3 research/agy/bend5k/eval_split_w22/evaluate.py \
  --candidate /path/to/bend5k_frozen \
  --split test_sealed \
  --cpu-pin 2 \
  --skip-bun-check \
  --aggregate-only

# 3. Re-freeze the Proven-21 reference baseline (includes full bun --check-only + C-O2/O3 medians):
python3 research/agy/bend5k/eval_split_w22/evaluate.py \
  --freeze-baseline \
  --split all \
  --cpu-pin 2
```

## Frozen Proven-21 Reference

Recorded in `proven21_baseline.json`:
- Compiler: `/home/ai/bend2_agy/selfhost/build/agy/bend5k/bend5k_o2` (commit `2f59e12b`, flags `-O2`)
- Runtime: `/home/ai/bend2_agy/selfhost/build/agy/unified/runtime-agy.o`
- Measurements: 5-run medians (1 warmup) pinned to CPU `2` (`taskset -c 2`), verified against `gcc-10 -O2 -ffp-contract=off` and `gcc-10 -O3 -march=native -ffp-contract=off`.
