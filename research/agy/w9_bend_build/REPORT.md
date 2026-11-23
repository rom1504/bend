# Wave 9: 100% Pure-Bend Incremental & Parallel Module Build Driver

## Summary

Implemented a **100% pure-Bend** incremental & parallel module build driver (zero Python, zero JS, zero `@unsafe` — passes `bend2/main.ts --check-only` with `ALL PROOFS CHECK`) that orchestrates Wave 8 `x86-module` compilation, dual 32-bit FNV-1a content-hash caching, live millisecond-timed stderr progress, and `gcc-10` linking with `p111_link_merge.c`.

Because `wave8-native-self/n1`'s fixed native runtime (`ABI11102`) does not yet expose subprocess/concurrency effects (`Process.run`, `IO.fork`/`Chan.*`), we provide **two** verified pure-Bend drivers covering both execution targets:

1. **[`bend_build.bend`](bend_build.bend)** — **Native ABI11102 edition**: uses ONLY effects admitted by `wave8-native-self/n1` (`p111_runtime_names()`), compiles to a standalone **549,760-byte native x86-64 ELF binary** via `n1 x86-object` + `gcc-10`, runs hash/cache analysis in **1–3 ms**, logs live progress to stderr, and emits the exact parallel build & link plan to stdout (`bend_build ... | bash`).
2. **[`bend_build_exec.bend`](bend_build_exec.bend)** — **Hosted Direct-Execution edition** (`bend2/main.ts`): uses `IO.fork`, `IO.join`, and `Process.run` from `selfhost/dist/base.bend` to spawn `n1 x86-module` workers in parallel and invoke `gcc-10` directly inside Bend with no external shell pipeline.

---

## IO Effect Compatibility Matrix: Native (`wave8-native-self/n1`) vs Hosted (`bend2/main.ts`)

Audited against [`selfhost/dist/base.bend`](../../../selfhost/dist/base.bend) and [`selfhost/build/agy/wave8_unified/compiler.bend:34017-34018`](../../../selfhost/build/agy/wave8_unified/compiler.bend#L34017-L34018) (`p111_runtime_names()`):

| Effect | `bend2/main.ts` (Hosted C/JS) | `wave8-native-self/n1` (ABI11102) | Notes |
| --- | :---: | :---: | --- |
| `IO.args`, `IO.args_bytes` | Yes | Yes | CLI argument list (`argv[0]` included) |
| `IO.now` | Yes | Yes | Millisecond wall clock (`IO(Nat)`) |
| `IO.print`, `IO.print_err` | Yes | Yes | Stdout / stderr line output (appends `\n`) |
| `File.open`, `File.open_bytes` | Yes | Yes | Linear `File` handle (`"r"`, `"w"`, etc.) |
| `File.read`, `File.read_line`, `File.read_bytes`, `File.read_at`, `File.size` | Yes | Yes | Chunked reading supported |
| `File.write`, `File.write_at`, `File.write_bytes`, `File.close` | Yes | Yes | Hash cache persistence |
| `IO.die` | Yes | Yes | Non-zero exit with message |
| `NativeHost.read/path/publish` | No | Yes | Self-host internal host hooks |
| `Process.run` | Yes | **No** | Subprocess execution (`base.bend:235`, `bend2/effs/process_run.{c,js}`) |
| `IO.spawn`, `IO.fork`, `IO.join`, `Chan.*` | Yes | **No** | Concurrent workers / channels (`base.bend:261-322`) |
| `IO.exit`, `IO.get_env`, `IO.sleep`, `IO.write` | Yes | **No** | Not in `p111_runtime_names()` |

Note: There is no `IO.exec` in `base.bend`; the subprocess effect is `Process.run(program, args, input, max_output, timeout_ms)`. Attempting to compile `bend_build_exec.bend` with `wave8-native-self/n1` fails cleanly at the ABI11102 admission gate:

```text
compile: foreign provider unavailable in fixed runtime: Chan.close
```

---

## Manifest Format & CLI

Manifest (`name src fid_base out_o`, `#` comments and blank lines ignored):

```text
modB /path/to/modB.bend 0 /path/to/modB.o
modA /path/to/modA.bend 256 /path/to/modA.o
```

CLI:

```sh
bend_build <manifest> <compiler_bin> <base_bend> <carrier_p130> <stamp> \
           <merge_c> <runtime_o> <entry_mod> <out_exe>
```

Each module's content hash is a dual 32-bit FNV-1a digest (`<h1_hex>:<h2_hex>`) over `source + "\n" + stamp + "\n" + fid_base + "\n" + name` computed in pure Bend (`U32.xor` + `U32.mul`). A module is a `[cache HIT]` iff both `<out_o>` exists and `<out_o>.hash` matches the computed digest.

---

## Verification Receipts

### 1. Type Checking (`--check-only`)

Both files pass `bend2/main.ts --check-only` with **0 errors** and **0 `@unsafe`** definitions:

```text
bend_build.bend      -> ALL PROOFS CHECK
bend_build_exec.bend -> ALL PROOFS CHECK
```

### 2. Native Compilation with `wave8-native-self/n1`

```text
n1 x86-object research/agy/w9_bend_build/bend_build.bend ... -> 12572 ms (rc=0)
gcc-10 -no-pie bend_build.o runtime-agy.o -o bend_build -lm -lpthread -> 45 ms (rc=0)
Binary size: 549,760 bytes
```

### 3. Native `bend_build` 2-Module End-to-End Test (`modB` fid_base=0, `modA` fid_base=256)

- **Cold build** (2 `[MISS]`):
  ```text
  [bend-build] manifest=/tmp/agy_w9_bend_build/t_native/manifest.txt modules=2 entry=modA
  [bend-build] [1/2] modB (/tmp/agy_w9_bend_build/t_native/modB.o) [MISS] hash=24b55437:d6ebb1a7 (0ms)
  [bend-build] [2/2] modA (/tmp/agy_w9_bend_build/t_native/modA.o) [MISS] hash=5efe4664:b3f2e1c0 (1ms)
  [bend-build] plan ready: total=2 rebuilt=2 cached=0 link=yes (3ms)
  app_cold=41
  ```
- **Warm build (no edits)** (2 `[cache HIT]`):
  ```text
  [bend-build] manifest=/tmp/agy_w9_bend_build/t_native/manifest.txt modules=2 entry=modA
  [bend-build] [1/2] modB (/tmp/agy_w9_bend_build/t_native/modB.o) [cache HIT] hash=24b55437:d6ebb1a7 (1ms)
  [bend-build] [2/2] modA (/tmp/agy_w9_bend_build/t_native/modA.o) [cache HIT] hash=5efe4664:b3f2e1c0 (0ms)
  [bend-build] plan ready: total=2 rebuilt=0 cached=2 link=no (1ms)
  app_warm=41
  ```
- **Single-module edit (`modA.bend`: `helper_a(18)` -> `helper_a(20)`)**:
  ```text
  [bend-build] manifest=/tmp/agy_w9_bend_build/t_native/manifest.txt modules=2 entry=modA
  [bend-build] [1/2] modB (/tmp/agy_w9_bend_build/t_native/modB.o) [cache HIT] hash=24b55437:d6ebb1a7 (0ms)
  [bend-build] [2/2] modA (/tmp/agy_w9_bend_build/t_native/modA.o) [MISS] hash=4afdbb3f:928ad4eb (1ms)
  [bend-build] plan ready: total=2 rebuilt=1 cached=1 link=yes (2ms)
  app_edit=45
  modB_sha_unchanged=YES
  ```

### 4. Hosted Direct-Execution `bend_build_exec.bend` (`IO.fork` + `Process.run`)

- **Cold build** (parallel `IO.fork` on both modules — wall time 1436 ms vs ~2445 ms sequential sum):
  ```text
  [bend-build] (direct-exec) manifest=/tmp/agy_w9_bend_build/t_exec/manifest.txt modules=2 entry=modA
  [bend-build] [1/2] modB (/tmp/agy_w9_bend_build/t_exec/modB.o) compiling ...
  [bend-build] [2/2] modA (/tmp/agy_w9_bend_build/t_exec/modA.o) compiling ...
  [bend-build] [1/2] modB (/tmp/agy_w9_bend_build/t_exec/modB.o) [REBUILT] hash=24b55437:d6ebb1a7 (1222ms)
  [bend-build] [2/2] modA (/tmp/agy_w9_bend_build/t_exec/modA.o) [REBUILT] hash=5efe4664:b3f2e1c0 (1223ms)
  [bend-build] linked /tmp/agy_w9_bend_build/t_exec/app (203ms)
  [bend-build] done: total=2 rebuilt=2 cached=0 (1436ms)
  exec_cold=41
  ```
- **Single-module edit (`modA.bend`: `helper_a(18)` -> `helper_a(25)`)**:
  ```text
  [bend-build] (direct-exec) manifest=/tmp/agy_w9_bend_build/t_exec/manifest.txt modules=2 entry=modA
  [bend-build] [1/2] modB (/tmp/agy_w9_bend_build/t_exec/modB.o) [cache HIT] hash=24b55437:d6ebb1a7 (4ms)
  [bend-build] [2/2] modA (/tmp/agy_w9_bend_build/t_exec/modA.o) compiling ...
  [bend-build] [2/2] modA (/tmp/agy_w9_bend_build/t_exec/modA.o) [REBUILT] hash=39973cfc:4f1e1944 (676ms)
  [bend-build] linked /tmp/agy_w9_bend_build/t_exec/app (157ms)
  [bend-build] done: total=2 rebuilt=1 cached=1 (844ms)
  exec_edit=55
  exec_modB_sha_unchanged=YES
  ```

---

## Artifacts

- [`research/agy/w9_bend_build/bend_build.bend`](bend_build.bend) — Native ABI11102 pure-Bend build driver
- [`research/agy/w9_bend_build/bend_build_exec.bend`](bend_build_exec.bend) — Hosted direct-execution pure-Bend build driver (`Process.run` + `IO.fork`/`IO.join`)
- [`research/agy/w9_bend_build/REPORT.md`](REPORT.md) — This report
