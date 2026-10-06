# Targeted V8 inspection of compiler requests

Prepared strategy only. No compiler request, generated target or forced optimization
has run for this document. Root first selects a concrete hot function from fresh
CPU profiles; this plan then explains how to inspect that function without a
whole-compiler graph dump. Instrumented durations are diagnostic, not compiler
throughput measurements.

## Pinned runtime and retained method

Read-only CPU0 queries of `/home/ai/.nvm/versions/node/v24.18.0/bin/node`
(`v24.18.0`) retain full `--v8-options` and `process.versions` in
`selfhost/build/phase57/v8-options01`. The receipt pins the executable and these
outputs. This checks flag availability, not whether any particular generated
function optimizes or whether a graph dump completes.

The [Phase49 method](../../selfhost/tools/performance/phase49/README.md) separates
import, first invocation, warmup and repeated calls, retains failures and limits
output files. Its [driver](../../selfhost/tools/performance/phase49/v8-probe.mjs)
requires finite numeric results and repeated public exports. A compiler request
returns structured observations, so it cannot be passed unchanged to that driver.
Reuse the request wrapper and result/hash oracle selected by root; add explicit
flag validation and phase markers in a new Phase57 producer rather than editing
historical Phase49 or Phase55 tools.

## What the flags actually permit

| Question | Available flags | Scope and limitation |
| --- | --- | --- |
| Optimization and deoptimization events | `--trace-opt --trace-deopt --trace-file-names` | No function-name filter is exposed for these event logs. Capture one bounded request/window; post-filter by verified function and file/source location. This is not selective trace production. |
| Inlining | `--trace-turbo-inlining` | Global, as recorded by Phase49. `--trace-turbo-filter` does not make this log function-local. Avoid it by default for the full compiler; use only a short capped diagnostic if a specific unresolved inlining question remains. |
| Selected optimized assembly | `--print-opt-code --print-opt-code-filter=EXACT_NAME` | Preferred second diagnostic. No assembly means no matching optimized code was printed; it does not establish that the function was never called. |
| Selected bytecode | `--print-bytecode --print-bytecode-filter=EXACT_NAME` | Optional when the function remains unoptimized. Bytecode describes compiled interpreter operations, not runtime call counts. |
| Selected TurboFan IR | `--trace-turbo --trace-turbo-filter=EXACT_NAME --trace-turbo-path=FRESH_DIR` | Optional only after simpler evidence. Avoid graph/schedule/reducer verbosity initially. Complete graph JSON must be checked separately from successful request exit. |
| Parse/compile event study | `--log-function-events --logfile=FRESH_FILE` | Global event log; separately capped diagnostic if import/first-use costs justify it. No clean speed ratio from this run. |

Do not use `--print-code`, `--print-opt-source`, `--log-all`, wildcard TurboFan
filters or global graph dumps. Do not restrict `--maglev-filter` merely to obtain
local output: that flag changes which functions may optimize, hence the observed
execution policy. Do not disable tiers, concurrency or lazy compilation in the
primary diagnostic, and do not add `%OptimizeFunctionOnNextCall` or
`--allow-natives-syntax` to manufacture optimization.

## Binding a hot name to the exact B1/B2 image

1. Pin the selected B1/B2 module, corresponding attempt/subject source,
   adapter, driver, runtime, Base and request fixture. Retain raw image identity;
   do not normalize or regenerate it for inspection.
2. CPU profile rows supply `functionName`, URL and line/column. Locate the
   declaration/body at that exact source position. Anonymous closures and
   repeated helper names require location evidence as well as their label.
3. Direct `jd_name` prefixes `$jd$` and encodes nonalphanumeric source characters
   as `_DECIMAL_CODE_`; for example source underscores become `_95_`. This is
   useful for lookup, but the emitted image is authoritative. Legacy B1
   descriptors/closures may have different or repeated names. Do not assume
   the same spelling identifies corresponding B1/B2 functions.
4. Place exact filter values in JSON argv entries, not unquoted shell text:
   `$jd$...` and legacy `$...` names must not undergo variable expansion.
   Reject empty/wildcard filters and ambiguous declaration matches before launch.
5. A request wrapper imports the exact image through the ordinary driver/adapter,
   then invokes the same API stage and validates the same observation/output
   hashes. Filters name generated implementation functions, not just public
   export keys. Importing a hot function separately or calling a private function
   with fabricated arguments changes its call site and feedback; avoid that.

## Bounded sequence after root assigns the function

Start with the selected CPU profile and preserved emitted source; these may
already explain dispatch or allocation cost without new execution. If tiering
is uncertain, prepare one short opt/deopt request run with import/first-use/API
stage markers and a post-filtered summary that also reports total/unmatched
trace lines. Never discard the raw trace or hide global-log size.

Next, request only the exact selected optimized function's assembly. If it did
not optimize, inspect matching bytecode or request an explicitly justified
longer warm window. Separate cold-request evidence from a repeated warm-request
experiment; warming cannot explain cold throughput by itself. For inlining,
first inspect the selected assembly's recorded inlining/source metadata. A
short global inlining trace is a last resort, with its scope plainly labeled.
A graph diagnostic is optional after those steps, limited to one exact function.

Use the existing serial resource supervisor from an unlocked parent: one guard,
CPU3 only after root grants the slot, 1 GiB Node heap, 2 GiB process-tree RSS,
4 GiB available-memory floor and a bounded deadline. Preserve Phase49's 64 MiB
per-file limit, but add a directory-wide output check if graph files are enabled;
per-file limits do not bound the sum of many files. Stop on truncation, incomplete
JSON or timeout, retain failure receipts, and do not repair dumps. Fresh outputs
and frozen tool/input hashes are mandatory. Root owns execution and chooses the
request count/deadline from the existing measured request cost.

## The 3.9 MB direct image and lazy parsing

The pinned runtime exposes `--lazy` enabled by default. A larger direct module
can plausibly increase initial source scanning/preparsing, first-use compilation,
and wrapper/marshalling setup even when much of its code is never executed.
A 3.9 MB image size alone does not show which of these costs dominates: JavaScript
module initialization, source parsing and API conversion are different stages.
Likewise, successful warm requests do not prove import cost is negligible.

First compare already-separated import, API loading, first request and subsequent
request observations in fresh processes using exact B1/B2 images and identical
fixtures. Ordinary driver `loadApi` plus the direct facade must remain in scope
where the question is end-to-end compiler latency. If import/first-use is
material, a separately capped function-event log can distinguish parse/compile
activity from wrapper execution. Do not claim that the whole image is eagerly
compiled, that lazy parsing solves its cost, or that wrapper duplication is the
cause until those observations support it. `--no-lazy` would be a deliberately
changed-policy counterfactual, not a baseline measurement.

No new runner/framework is needed before the hot-function identity is known.
The future plan should contain exact function/location pins, a request-specific
oracle, the minimal argv above and the same guard/receipt policy.
