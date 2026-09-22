# Pinned TypeScript compilation of the final compiler source

This follow-up preserves the earlier `rapid/native-fullsource-upstream.mjs` experiment and adapts its checked library/root comparison to the final source. It runs **three fresh serial pinned TypeScript compilations**, with no serialized Base cache, after the small paired compiler matrix. It does not rerun H or native compilation and must not be described as a paired whole-compiler benchmark.

The input must be the final checked integration report's assembled source, with the exact canonical Base used by the self-emission proof. The supplied self-emitted classifier API must be recorded as a successful verified output in that proof. A copied proof report retains whether the fixed-point proof was complete at the start. Source, Base, driver/helpers, initial compiler and integration input identities are verified; all child stdout/stderr are captured to files.

Configuration:

```json
{
  "upstream": "../../.bootstrap/upstream",
  "input": "ABSOLUTE_FROZEN_COMPILER_SOURCE_FROM_REPORT",
  "base": "../../.bootstrap/upstream/bend2/base.bend",
  "classifierApi": "final-fixedpoint/stage2.mjs",
  "integrationReport": "native-integrated/report.json",
  "proofReport": "final-fixedpoint/report.json",
  "cpu": 1,
  "repetitions": 3,
  "timeoutMs": 120000
}
```

From `selfhost/`:

```sh
node --stack-size=4096 --max-old-space-size=12288 \
  tools/performance/phase3/final-fullsource-typescript.mjs CONFIG.json NEW_OUTPUT_DIRECTORY \
  > LAUNCH.stdout 2> LAUNCH.stderr
```

Each sample performs actual source loading, full checking, ownership and unresolved-law/hole gates, then JS library emission. Roots follow the same structural policy as `j_library_roots`, including Base foreign definitions. The actual self-emitted Bend classifier independently checks the selected root set from the upstream checked metadata. Output syntax, export order and simple scalar/ASCII API behavior are checked. Different emitters' output bytes need not match.

The pinned TypeScript source files are copied unchanged to a private directory, with Base/effect symlinks pointing to the recorded canonical inputs. That changed module location remains an explicit provenance limitation; it is not silently called the original checkout's CLI. Metadata transport and the independent Bend root-classifier oracle occur outside `compileMs`. Separately report load/check/emit, process wall, and variation across the three samples. Ratios to a single independently recorded H/native observation are descriptive, not paired statistical estimates.

The final three samples passed every gate and selected exactly **1,497 roots**, independently confirmed by the actual final H classifier. All three emitted the same 1,194,416-byte TS library, SHA256 `13d3870b15df7f27e045959bad7d1b9de16f3a891d0a08efdbf22b322e4e26e0`. Evidence is [final-fullsource-typescript.json](../../../../implementation/phase3/final-fullsource-typescript.json), including original report hash, all consumed identities and per-sample observations.

Compilation took **49.468, 49.647 and 49.636 seconds** (median 49.636); process wall median was 50.062 seconds. Median recorded phases were load 1.758 seconds, checking plus ownership 4.896 seconds, and emission 42.904 seconds. Independent phase medians need not sum to the total median. These three serial CPU1 observations characterize pinned TS variation; any ratio to separately recorded H/native full-source timings remains descriptive and unpaired.
