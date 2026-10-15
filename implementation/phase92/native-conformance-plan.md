# Phase92 frozen native-host conformance plan

Preparation is complete; no compiler or generated program was executed by this
agent. The reusable method is under
[`phase92/conformance`](../../selfhost/tools/performance/phase92/conformance/README.md).
Root must run the actual authenticated images before any pass count is reported.

## What the unchanged entry can observe

Frozen source `d04ad79c…` implements only checked C compilation. The entry runs
header parsing, Base-seeded loading, `check_program_diagnostic_world`, ownership
and entry validation, annotation, native lowering and complete C output. It
accepts one source importing Base; `p86_import_error` explicitly rejects other
top-level imports. `p86_effect_file` admits only args, print, now, print_err,
file_open, file_read, file_size, file_write and file_close from canonical Base.
Arbitrary fixture-local foreign files are outside that contract.

There is no protocol switch for parse-only, check-only or JS emission. An
unsuccessful C request is not interchangeable with a checker observation: a
valid declaration-only book may fail later for missing main, or a checked
program may hit an unsupported foreign path. Therefore the full3174 frontend
observations and JS23 module join cannot be transferred to this native image
without changing its entry. Reusing the JS-hosted results as native results
would be incorrect.

`p86_plan_checked` consumes `DResult{error,book,diagnostic}` but returns only
`"check: " ++ error` on failure. It does not call the host rich-page rendering
path that overflowed in Phase91. A concise native rejection of deep_list_walk
is expected by this protocol; it neither fixes nor reproduces that rendering
failure.

## Exact native100 subset and retained exclusions

An offline audit of the exact Phase91 candidate inventory and original Phase82
native100 selection found69 Base-only fixtures and31 host-contract exclusions.
Thirty exclusions import additional Bend modules; one uses only a fixture-local
foreign provider. Two of those30 module fixtures also import custom providers.
All69 eligible fixtures have executable main and existing golden execution
outputs. Some intentionally fail at runtime; their complete output and exit
remain part of the oracle. None is a negative frontend golden fixture.

The data-only inventory is
`selfhost/build/phase92/conformance-inventory01/inventory.json`.
The qualification preparation rechecks the inventory and pins every original
source, expected result, method and shared runtime asset. It never edits test
sources, flattens module imports or substitutes a different Base. Excluded cases
remain enumerated by ID and exact hash; the eventual headline is at most
**69/69 executable cases per role,31/100 outside native-host scope**.

## Native B1/B2 and execution boundary

`comparison/support.py` verifies the new upstream-built native B1 receipt at
`selfhost/build/phase92/upstream-b1/build.json` and existing native07 admission.
Both consume identical D04 source and authenticated request assets. The B1
receipt identifies checked upstream emission and actual Clang build; native07
retains its own native-emitted C lineage. Only argv transport differs: upstream
IO.args includes the executable head; own runtime requires its explicit
sentinel. The method does not fabricate a native07 admission for B1.

Existing `conformance/run.mjs`, `run-probe.mjs` and `judge.mjs` supply isolation,
process-group timeout handling, unchanged-input checks and exact golden output
judgment. The new adapter invokes the native executable, builds emitted C with
the pinned Clang C11/O3 recipe, then executes it with one CPU worker/GPU off.
Node imports no JS compiler. Original combined stdout/stderr and exit behavior
are checked. This is a bounded single-worker CPU test, not parallel/GPU proof.

Each role gets one300-second/2GiB guard, jobs1, with60-second per-case timeouts;
the two roles must run sequentially. Historical JS-hosted native100 took about
two minutes, but new native-host cost is unmeasured. Start with a small selected
execution if root needs an early discriminator. No per-case nested guards are
created. Successful source/ELF workdirs are removed by the existing failed-only
retention policy; complete raw stdout/stderr and hashes remain in report JSON.
Failure artifacts remain and a160MiB free-space floor refuses further work.

## Three focused rejection controls

Run original malformed-source and type-error fixtures from Phase90 plus original
`page/deep_list_walk.bend`, in both native roles. Require compiler exit1, no C,
expected parse/check prefix and exact cross-role concise diagnostic. Existing
native diagnostic text is the reference for the first two. The deep case also
records comparison to Phase91's12119-character full page and57-character JS
fallback, including its identical underlying checker message. Strip only the
three exact leading telemetry lines when extracting protocol diagnostics;
retain every original byte alongside the extracted value.

The rejection collector distinguishes refusal correctness from rich diagnostic
fidelity. No native frontend3174 score, true rich-page rendering claim, or
larger-stack workaround follows from these six observations.

## Status and acceptance

Python AST and Node syntax checks pass. The69/31 static inventory was generated
without invoking the Bend compiler or Clang. Full authenticated preparation now
passes against the completed B1 build: image `6bb07e94…` and native07 image
`d7c7a479…`, with248 pinned inputs. Frozen plan
`selfhost/build/phase92/conformance01/plan.json` has SHA256
`8e67de8cb4190bb33ed83c67d8567930273998e0b1149ee86831b1ab4eda5297`.
Its adjacent `commands.json` contains three serial guarded commands. Actual
targets and result collection are pending.
The offline collector will require completed guards,69 golden execution passes
per role, unchanged inputs, exact historical runtime observations, and all six
rejections; it preserves every exclusion and reports failures honestly.
