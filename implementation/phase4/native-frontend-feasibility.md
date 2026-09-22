# Native frontend feasibility: no cheap mode switch

**Stop the bounded prototype before a native build.** The existing native host cannot produce genuine parse/check observations, and a useful batch needs a new frontend result/discovery/cache lifecycle. Reusing its compile result would break observable behavior. This is a feasibility rejection of the shortcut, not a claim that a native frontend batch cannot be faster.

The established ordinary loop remains the measured 37.217-second checked rebuild plus cold 21-case command, and 9.328-second warm command. No replacement latency was measured here.

## Actual capability and observation controls

The current final native compiler and adapter expose only program/library emission. The adapter returned **unsupported for all 12 parse/check requests** over six existing native fixtures: nested imports, non-BMP source, a library without a main entry, imported parse error, imported type error and imported unfilled-law use. This refusal is correct.

Current checked B1 `0653f21e…` and proven H `b33b38e3…` produced **12/12 identical complete parse/check observation records** on those same physical fixtures. Live pinned TypeScript agreed on all 12 status/phase/checked/exit observations. Nine exact diagnostic/report texts agreed; the other three retained known parse-diagnostic formatting and imported-type source-location differences. Both raw records are preserved, including the extra `files` field exposed by the port. They were not silently normalized into full-record equality with TypeScript.

These are serial correctness observations on CPU3 with 4 MiB stack/4 GiB heap, reused API sessions and validated Base preparation. The same frozen host, canonical Base, runtime and API identities were retained. The original input set stayed unchanged; a supplemental rehash checks fixture dependency bytes against the earlier native validation report. No performance conclusion is drawn from these runs.

The existing native **compile** observations expose the mismatch concretely:

| Imported error | Current B1/H check observation | Existing native compile observation |
| --- | --- | --- |
| Type mismatch | Located `expected : U32`, `observed : String`, `Location: bad.answer` | Plain `bad.answer: constructor does not belong to goal or field count differs` |
| Unfilled-law use | Detailed expected/observed/location report | Plain `main: live use of an unfilled law` |

Accepted native observations have phase `compile` and emitted JavaScript; genuine check returns phase `check` and the declaration report. Parse must return checked=false immediately after loading/elaboration. Merely removing emission after `check_book` would still miss detailed diagnostics, exact-prefix handling, owned/TODO/specialization gates and successful report text.

## Cost evidence and why caching matters

The already completed final native validation recorded fresh positive compilation times of **1.602–1.658 seconds** for these small programs/libraries, including source loading, full Base checking and emission. Those are historical compilation observations, **not native check timings or lower bounds for a new check implementation**.

The earlier [controlled small-workload experiment](../phase2/native-host.md#controlled-small-workload-comparison) found fresh native requests at 1.892–1.927 seconds versus cached B1 at 1.591–1.851 seconds. It explicitly rejected a build-cost amortization advantage on those workloads. That evidence cannot be replaced by a comparison against uncached JavaScript.

The native code still invokes `f_load_graph` and `check_book` for every process. The current JS host uses `f_load_graph_seed_trace` plus `check_from_exact_prefix` when validated Base is present. A frontend batch needs the equivalent **Bend** seed/trace/prefix reuse; simply keeping the executable process alive does not remove Base work. No full-source profiler or native C build was started for this feasibility task.

## Smallest credible next implementation

This is a separate host-wrapper project; the 59 frozen compiler modules need not change.

1. Add a dedicated checked Bend frontend entry returning status, phase, checked flag, exact stdout/diagnostic and consumed paths. On parse, stop after graph elaboration. On check, preserve the existing diagnostic replay/location and owned/TODO/specialization/report sequence. Reuse existing compiler functions rather than reimplement checker algorithms in a host language.
2. Add a finite request batch that prepares and validates Base once, carries its immutable book/path/text into each seeded graph load and exact-prefix check, and starts fresh request trace/error state. Validate the source/compiler/Base identity and enforce request-count, RSS, deadline and output bounds. Do not deserialize an unchecked host-supplied book as a cache shortcut.
3. Resolve discovery semantics. Existing manifests are explicit and current native source reading is eager over their module list. The JS host parses the main source before recursively reading imports. An overcomplete manifest containing an unavailable unused source, or an imported missing file after an earlier syntax error, can change which error appears first. A native discovery loop or demand-driven path catalog must preserve physical aliases, depth-first order and first errors. A catalog should provide paths/bytes only; do not hide a B1/TypeScript parser/checker fallback in setup.
4. Extend the filesystem/result boundary for successful frontend observations, which publish no JavaScript. Retain source alias protection, snapshot/provenance checks and failures. Keep unreachable foreign assets unread and do not impose main-entry or emission-layout requirements on check.

The pure frontend functions are available, but combining those four pieces is not a flag change. Existing full checked-native preparation/emission plus O2 miss took approximately **135.7 seconds** for the final host (including preparation, excluding semantic validation); a smaller frontend-only wrapper could differ and has not been built. More important is correctness engineering across discovery, diagnostic and batch boundaries. Do not spend that build and integration budget before assigning the wrapper explicitly.

A subsequent bounded pilot should compare a finite 21-case batch against the genuine cached B1 command, including native build and first-cache cost separately. Add unused missing modules/assets, missing imports after syntax failures, duplicate physical aliases, source/import changes between requests, exact negative diagnostics and declaration reports. Require convincing repeated whole-batch improvement before running all 2,756 frontend probes. No speculative total-suite speedup is claimed.

## Evidence and reproduction

[Comparison record](native-frontend-evidence/comparison.json), [complete execution record](native-frontend-evidence/report.json.gz) and [archive manifest](native-frontend-evidence/manifest.json) preserve all observations, original native compile records, selected fixture sources, consumed helper sources and identities. The existing checked native C/O2 build metadata are included; large APIs/binaries remain identified prerequisites.

The read-only tool is `selfhost/tools/performance/phase4/native-frontend-feasibility.mjs`. From the repository root, with the frozen Phase4 artifacts present:

```sh
taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --stack-size=4096 --max-old-space-size=4096 \
  selfhost/tools/performance/phase4/native-frontend-feasibility.mjs \
  --run selfhost selfhost/build/phase4/NEW_FEASIBILITY_DIRECTORY
```

It performs genuine requested-mode observations through the unchanged adapters; it does not emit code or claim native frontend support. No production compiler, native protocol, API or canonical private package was changed.
