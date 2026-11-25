# `bend5k` Scientific Optimization Wave Playbook

Concise operational playbook for running high-leverage, zero-regression optimization waves on `selfhost/bend5k/` (`~11.1k` LOC, hard cap `15k` LOC, 1-core `-O2` self-host `~4–5 s`).

---

## The 4-Ingredient Scientific Optimization Loop

Every wave follows four tightly coupled ingredients. Never guess what is slow, never land an ungeneralized benchmark hack, never collide on compiler files, and never let LOC ratchet upward unchecked.

### 1. Silicon Oracle — Hand-Edited ASM Ceiling Probes
Before writing compiler code, measure the **exact hardware ceiling** on real silicon:
1. Compile the target benchmark with `bend5k_o2 -O2 <src> <out>.o` and disassemble (`objdump -dr <out>.o`).
2. Hand-patch `.s` / `.o` for the candidate transform (e.g., `cmov` if-conversion, spill removal, TRMC loop, address CSE, static-string inline `ITake`), keeping the exact algorithm and runtime ABI.
3. Link with `selfhost/build/agy/unified/runtime-agy.o` (`gcc-10 -no-pie ... -lm -lpthread`) and run **5 back-to-back runs on `taskset -c 7`** paired against the unmodified baseline and `gcc-10 -O2` twin.
4. Verify **exact stdout checksums** on every variant.
5. Classify every probe:
   - **STRONG GO**: >= 1.25x speedup (or closes >= 25% of gap to C) with clean, general compiler mechanism.
   - **MARGINAL**: 1.05x–1.25x or narrow applicability; defer unless near-zero LOC.
   - **NO-GO**: < 1.05x, memory-latency/FP-latency bound, or requires unsound assumptions.
6. Archive full JSON evidence (raw runs, median, `vs_c`, `speedup_vs_base`, `verdict`, `estimated_loc`) in `research/agy/bend5k/asm_ceiling_probes_w<N>.json`.

### 2. Hardware-Informed Cost Laws & Generality Matrix
Encode every promoted optimization as a **machine-code contract** in `research/agy/bend5k/law_gate.py` backed by formal proofs in `selfhost/bend5k/laws/ownership_laws.bend`:
- **Generality Holdouts (Red -> Green):** every contract tests BOTH a real benchmark AND at least one **unrelated fresh Bend holdout** so pattern-matching hacks fail immediately.
- **Strict Contracts (5/5 enforced by default):**
  - `A` (`ret2` Law 1): 0 hot `p111_rt_ctor` in `queens:$direct.solve` + holdout 2-scalar loop.
  - `B` (`IReuse` Law 2): 0 hot `p111_rt_ctor` + direct slot stores in `tree-bitonic:$direct.warp` + holdout tree-map.
  - `C` (`.rodata` LUT): RIP-relative `.rodata` load + `<10` `jcc` in `merkle:$direct.spk` + 10-case `Nat` holdout.
  - `D` (`borrow` Law 3): 0 `p111_rt_take` in `symreg:$direct.eval` & `hashmap:$direct.has`.
  - `E` (`Linear-Array Hoist` Law 4): preheader decode + 0 loop decodes/`p111_rt_op`/calls across `editdist`, `terrain`, and 3 unrelated array holdouts.
- **Staging & Hardware Triager:**
  - `F` (`Static String & Static-Take`, `[REPORT]` / `--strict-static-str`): 0 heap `SCon` `p111_rt_ctor` on constant strings (`lexer:$direct.tpl` + holdout) and tracks `p111_rt_take` on traversal (`lexer:$direct.gen` + holdout).
  - `G` (`Hardware-Informed Loop Bottleneck Triager`, `--triage <file.bend>`): reports `[rbp-]` spills, `jcc`, `cmov`, `p111_rt_*`, `div`/`idiv`, and `sqrtss`/`divss` latency-bound ops (built-in report on `kmeans:$direct.chunk` & `list-pipeline`).
- **Fault-Injection Self-Test (`--self-test-fault-injection`):** must trip 100% of strict contracts (`A–E`) at `-O0` and on synthetic disassembly faults.

### 3. File-Disjoint Parallel Optimization Wave
Partition each wave across **strictly disjoint files** so parallel workers never merge-conflict:

| Track / Role | Exclusive File Ownership | Typical Scope |
|---|---|---|
| `P-OPT` | `selfhost/bend5k/opt.bend` | IR transforms, `cmov` if-conversion, hoisting, fusion, borrow/reuse |
| `P-X64` | `selfhost/bend5k/x64.bend` | Instruction selection, peepholes, inline fast-paths, static-`ITake` |
| `P-REGALLOC` | `selfhost/bend5k/regalloc.bend` | Liveness, coalescing, wide-arity TCO spill elimination |
| `P-LOWER` | `lower.bend`, `elf.bend`, `core.bend` | Lowering, `.rodata`/static image layout, IR constructors |
| `P-FRONT` | `parse.bend`, `check.bend`, `lex.bend` | Frontend parsing, type/affinity checks, lexing |
| `P-COSTLAW` | `research/agy/bend5k/law_gate.py`, docs | Cost laws, holdouts, bottleneck triager, playbook |
| `P-SIMPLIFY` | Designated cleanup targets (post-merge) | Dedicated LOC-simplification pass |

**Mandatory Soundness & Engineering Rules:**
- **`G1-C` `{r8..r11}` Cold-Path Contract:** any live caller-saved register (`r8`–`r11`, plus `rdi`/`rsi`/`rdx`/`rcx`) held across a cold stub or `p111_rt_*` call MUST be saved/restored around the call.
- **No 4+ Scrutinee Simultaneous `match`es:** keep `match` arity <= 3 in `selfhost/bend5k/*.bend` so `build_b5k.py --check-only` stays fast.
- **No Bend Keywords as Locals:** avoid `def`, `type`, `match`, `case`, `use`, `let`, `in`, `for`, `law`, `is`, `import`, etc. as variable names.
- **Never Edit `bend2/bend.ts`:** upstream language/checker is human-written and read-only.
- **CPU Isolation:** pin build/probe work to non-benchmark cores (e.g. `taskset -c 4-5`); reserve `taskset -c 7` for uncontended timing.

### 4. Dedicated LOC-Simplifier Every Wave
Run a dedicated simplifier pass every wave targeting **-150 to -250 LOC** with **zero semantic or codegen drift**:
- Dead helper removal, factoring duplicated IR/x64 builders, collapsing redundant match arms.
- **Proof of Equivalence:** `17/17` **bit-identical** `.o` files across `bench/runtime/*` (`sha256sum` before == after).
- Keeps total compiler size near `~10–11k` LOC (well below the `15k` hard cap) and 1-core `-O2` self-host compile time near `~4–5 s`.

---

## Exact Uncontended CPU 7 Close-Out Qualification Checklist

Run sequentially after all wave tracks merge, with **no concurrent heavy jobs** on the machine (all timings on `taskset -c 7`):

1. **Frontend Type & LOC Cap Check (`<= 15,000` LOC):**
   ```bash
   python3 selfhost/bend5k/build_b5k.py --check-only
   ```
2. **3-Stage Bit-Identical `-O2` Self-Host (`s1 -> s2 -> s3`):**
   ```bash
   # Assemble + build s1 with existing bend5k_o2 (or build_b5k.py --opt O2)
   # Compile /tmp/agy_b5k/bend5k.bend with s1 -> s2.o (link s2), then s2 -> s3.o
   taskset -c 7 /tmp/agy_b5k/s1 -O2 /tmp/agy_b5k/bend5k.bend /tmp/agy_b5k/s2.o
   /usr/bin/x86_64-linux-gnu-gcc-10 -no-pie /tmp/agy_b5k/s2.o selfhost/build/agy/unified/runtime-agy.o -o /tmp/agy_b5k/s2 -lm -lpthread
   taskset -c 7 /tmp/agy_b5k/s2 -O2 /tmp/agy_b5k/bend5k.bend /tmp/agy_b5k/s3.o
   sha256sum /tmp/agy_b5k/s2.o /tmp/agy_b5k/s3.o   # MUST be bit-identical
   ```
   Promote `/tmp/agy_b5k/s2` -> `selfhost/build/agy/bend5k/bend5k_o2` once stages match.
3. **64/64 Phase182 Qualification (`-O0` and `-O2`):**
   ```bash
   python3 selfhost/bend5k/run_qual_b5k.py --bend5k selfhost/build/agy/bend5k/bend5k_o2 --opt O0 --work-dir /tmp/agy_b5k/qual_o0
   python3 selfhost/bend5k/run_qual_b5k.py --bend5k selfhost/build/agy/bend5k/bend5k_o2 --opt O2 --work-dir /tmp/agy_b5k/qual_o2
   ```
4. **Live-Metadata Observer Gate (`15/15` across `normal`, `cap-no8`, `all-hot`):**
   ```bash
   python3 research/agy/wave3_fuzz/observer_wave2_gate.py
   ```
5. **Cost-Law Gate (`5/5` STRICT PASS + `8/8` GREEN + Fault-Injection Self-Test):**
   ```bash
   python3 research/agy/bend5k/law_gate.py --bend5k selfhost/build/agy/bend5k/bend5k_o2
   python3 research/agy/bend5k/law_gate.py --bend5k selfhost/build/agy/bend5k/bend5k_o2 --self-test-fault-injection
   ```
6. **7-Family Proxy + Terrain Holdout Benchmark (Uncontended CPU 7, 5 runs):**
   ```bash
   python3 selfhost/bend5k/bench_b5k.py --bend5k selfhost/build/agy/bend5k/bend5k_o2 \
     --opt-flag -O2 --runs 5 --cpu 7 --label proven11 \
     --json-out research/agy/bend5k/final_proven11_7fam_results.json
   ```
7. **Periodic Cross-Suite Sweeps (every 2–3 waves or major IR/backend change):**
   - Full `bench/runtime/*` 17-benchmark suite vs `gcc-10 -O2` (exact checksums + geomean).
   - Full `native45` 45-fixture sweep (`selfhost/tools/bench/catalogs/native45/fixtures/`).
8. **Cleanup:** remove scratch dirs under `/tmp/agy_b5k*` and verify `git status` is clean of untracked junk.
