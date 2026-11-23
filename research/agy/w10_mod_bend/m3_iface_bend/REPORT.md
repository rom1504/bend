# Phase 1 — M3: Pure-Bend `x86-iface` (`.p130` Interface Carrier Emitter)

## Objective
Eliminate `research/agy/w7_modules/build_iface_carrier.mjs` completely by implementing **`x86-iface`** in **100% pure Bend** inside `compiler.bend` (staged in `research/agy/w10_mod_bend/m3_iface_bend/iface_emit.bend`):

```
x86-iface ABS_PREFIX ABS_BASE live|cache ABS_BASE_CARRIER STAMP
```

## Implementation Summary (`iface_emit.bend`)
All logic is 100% pure Bend using existing compiler primitives (`p88_cache_prepare`, `p86_plan`, `x198pw_plan`, `p111v_get`/`p111v_put`, `f_fresh_defs`, `base_prefix_resume_saved`, `p86_checked_prefix`, `base_prefix_world_prepare`, `f_ready_prefix_prepare`):

1. **Base & Prefix Checking (Zero Base Re-check)**:
   - Loads `Base` from `ABS_BASE_CARRIER` + `STAMP` via `p88_cache_prepare` (or `p86_prepare` in `live` mode).
   - Checks `ABS_PREFIX` via `p86_plan` and lowers via `x198pw_plan` to obtain `P134Cursor`.
2. **Direct vs. CPS ABI Extraction (Zero `nm`, Zero `.o` Needed)**:
   - `w10_if_collect_abi` walks `P134Private` (`P113DFunction`) and `P134Public` (`N111Segment`) directly from `P134Cursor` into hash-trie indexes (`W10IfAbi{direct, public}`).
   - `w10_if_force_cps` sets `force_cps = has_public("$direct." ++ name) && !has_direct("$direct." ++ name)`.
3. **ABI-Matched Self-Recursive Stubs & Span Zeroing**:
   - Excludes `main` from the exported interface carrier so downstream modules define their own `main`.
   - Preserves forward `law` declarations (`value == Absent`) and looks up their type signatures when stubbing matching `def`s.
   - Replaces filled non-Base `Def` bodies (`templates == 0`) with self-recursive stubs (`w10_if_build_stub`), adding an annotated non-erased CPS closure binding (`Bind{quant=1, Ann(Lam, U32 -> U32)}`) when `force_cps == True{}`.
   - Zeroes `(originBegin, originEnd) = (0, 0)` on all stripped terms so downstream `n1 x86-module` accepts plain `selfhost/dist/base.bend` directly (no `combinedPath` file required).
   - Re-freshens via `f_fresh_defs(stripped, base_next)` and type-checks every generated stub via `base_prefix_resume_saved`.
4. **Deterministic Dual 32-bit FNV-1a Interface Stamp**:
   - `w10_if_h_defs` hashes exported `KDef` names, kinds, arities, templates, alpha-invariant/span-independent type signatures (`w10_if_h_term` with De Bruijn binder indexing), ADT constructors, and `Def` ABI (`1` = direct, `2` = CPS).
   - **Function bodies (`dv(d)`), source spans, and raw fresh var IDs are excluded**, so body-only edits that preserve interface & ABI yield the exact same stamp.
   - Emits `p130-word-pair-v1:w10-iface-v1:<16-hex>` into the `.p130` header and prints it to stderr.
5. **Pure-Bend `.p130` Word-Pair Streaming Serializer**:
   - Encodes all 12 schema tags (`0..11`) and 5 roots `[sBook, sState, sFresh, sWorld, sReady]` in exact `p130-word-pair-v1` word-pair format (`65536 + lo`, `65536 + hi`).
   - Structurally interns strings and records via `p111v_get`/`p111v_put` hash-tries and streams in 64-item batches to `/dev/stdout` via `File.write`.

## Verification Receipts

### 1. Type-Check & Compilation
- Temp copy assembled at `/tmp/agy_m3_iface/compiler.bend` (3,387,641 bytes) from `selfhost/build/agy/wave8_unified/compiler.bend` + `iface_emit.bend` + `x86-iface` dispatch in `x181_entry_args`.
- `bash research/agy/locked_bun.sh /tmp/agy_m3_iface/compiler.bend -o /tmp/agy_m3_iface/iface_cli.mjs`: **PASS** (rc=0, 0 type errors across all 8,553 defs).

### 2. End-to-End Cross-Module Verification (`compiler_slice.bend` → `modB` + `modA` on `wave8-native-self/n1`)

| Case | Description | Interface Stamp | `.p130` Size (nodes / strings) | `n1 x86-module` `modA` | Linked Output | Result |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Test 1 (v1)** | Clean `modB` → pure-Bend `iface_v1.p130` → `n1 x86-module` on `modA` + link `modB_v1.o` | `p130-word-pair-v1:w10-iface-v1:71eb49620ebd4c52` | 4,651,837 B (86,306 / 2,629) | 1,410.6 ms (rc=0) | **`34`** | **PASS** |
| **Test 2 (v2)** | Body-only edit to `modB` (`base_prefix_stamp` `+10`); `modA_v1.o` reused untouched | `p130-word-pair-v1:w10-iface-v1:71eb49620ebd4c52` (**IDENTICAL**) | 4,651,837 B (86,306 / 2,629) | **0 ms (reused!)** | **`44`** | **PASS** |
| **Test 3 (v3)** | Incompatible signature change to `modB` (`base_prefix_stamp` adds `+bonus: U32`) | `p130-word-pair-v1:w10-iface-v1:f6da53fd6a54942c` (**CHANGED**) | 4,652,331 B (86,315 / 2,630) | 1,396.2 ms (v3 `modA`) | **`54`** | **PASS** |

- **Negative / invalidation gates on Test 3**:
  - Stale `stamp_v1` against `iface_v3.p130`: rejected cleanly by `wave8-native-self/n1` (`rc=1`, `base_cache: cache stamp`).
  - Old `modA_v1.bend` against `iface_v3.p130` + `stamp_v3`: rejected cleanly by `wave8-native-self/n1` (`rc=1`, `check: main: type mismatch`).

## Cleanup
- `selfhost/build/agy/wave8_unified/*` untouched.
- `/tmp/agy_m3_iface/` removed after final compile check.
