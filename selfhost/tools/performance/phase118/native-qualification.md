# Phase118 native qualification preparation

`native-plan-v2.py` prepares commands and authenticates data; it executes no target.
`native-comparison.py` authenticates completed lineage and compares raw files;
it executes no compiler or executable. No source/runtime combination is selected
by these tools. Root supplies all three exact files and executes any target jobs.

This is a new Phase118 contract. Phase114's wrapper only changed paths/time
limits around the Phase113 staged lowering/verifier/renderer gate. That gate
requires an older native hook and is not reused here. Hosted acquisition uses
the current `native-hosted-v2.mjs`: prepare Base, check source into one request,
check runtime admission, then invoke the actual request-bound
`p111_emit_admitted(request, "")`. The checked Bend entry performs lowering,
original verification and any applicable derived-worker checks. Internal work
is one integrated timing stage; old separately timed lowering/verification
stages must not be fabricated or compared as identical clocks.

Preparation requires adjacent complete source, API and runtime receipts. It
replays the Phase118 declaration composition byte for byte from the pinned
parent and numbered module snapshots; authenticates the original module inputs;
matches the request-bound lowering/verification entry declarations; and retains
the original native main/request bridge. All compiler source, API, runtime
source/object, Base/carrier/stamp authority, relevant methods, machine tools,
ordinary fixtures and full-output oracles are pinned into the plan. The source
must currently have the `prepare-v4.py` manifest/snapshot layout. A changed
factory or composition format needs explicit review rather than a relaxed gate.

From the repository root, after choosing checked inputs:

```sh
python3 -B selfhost/tools/performance/phase118/native-plan-v2.py prepare \
  --api /absolute/checked-api/api.mjs \
  --source /absolute/frozen-source/compiler.bend \
  --runtime /absolute/qualified-runtime/runtime.o \
  --tag p118-native-selected01 \
  --rss-mib 6144 \
  --out selfhost/build/phase118/native-selected01-plan.json
```

The command emits `rootGuardCommand`; only the root coordinator runs it, after
checking the chosen source/runtime and available resource window. Defaults are
1200 seconds each for hosted and native self-emission, and 120 seconds per
QBE/assembler/linker child. Options `--hosted-seconds`, `--native-seconds` and
`--build-seconds` set explicit limits before freezing the plan. `--rss-mib`
records an explicit 2–6 GiB RSS ceiling (default4 GiB). The outer guard
retains CPU3, a16 GiB available-memory floor, and a128 MiB file cap.
These are ceilings, not forecasts. A larger actual image may require a separate
review of limits. Failed attempts and partial products remain in their own
directories; a retry requires a fresh tag and plan.

The serial jobs are:

1. Authenticate every frozen plan input.
2. Hosted integrated emission of the exact full compiler source.
3. Build N1 using pinned QBE and the explicit cached runtime.
4. Run the unchanged focused19 ordinary source suite on N1.
5. Ask actual N1 to compile the same full source in cache mode; retain raw stdout
   as QBE and build N2 against the same runtime.
6. Authenticate hosted→N1→self-emission→N2 lineage and compare every QBE byte.
7. Run focused19 on N2, followed by the unchanged original full45 conformance
   suite. The expected source/backend refusals are ordinary compiler diagnostics,
   not custom failure probes.

Legacy native capture/build/suite methods remain unchanged and require product
directories under `phase111`. The serial runner requires a `phase113` jobs
directory. All names start `p118-`; the new plan, guard and comparison live under
`phase118`. The new plan kind is not disguised as the old Phase113 contract.

The comparer requires the integrated hosted kind/version/entry/stage sequence,
checked API identity, the same request source and Base/cache on both paths,
actual adjacent build receipts, identical cached runtime input, successful
QBE/assemble/link stages, and native stdout/stderr bindings. It streams a direct
byte comparison without whitespace, newline, symbol or metadata normalization.
It preserves a failed comparison receipt on a lineage/byte mismatch after plan
authentication. It does not pass the new hosted report to the legacy native
capture tool's incompatible `--reference` gate.

Qualification requires **all** planned jobs to complete, comparison
`complete=true, byteExact=true`, each focused report's 16 semantic passes and
3 expected refusals with no pending cases, and N2 full45's 45 semantic passes
with no pending cases. The byte-comparison receipt deliberately precedes the N2
suites and cannot alone assert full qualification. Preserve every stage's
report, inputs, method snapshot and raw stdout/stderr. Timing scopes remain
separate: hosted internal stages, whole native request, machine builds, semantic
executions, and outer guard wall overlap and must not be summed indiscriminately.

No N2→N3 reproduction, ELF fixed point, native-produced runtime speed score,
parallel/GPU qualification or installed-selection change is implied. The old
Phase114 qualification remains historical evidence for its own pinned inputs.

Historical source-only preparation check: both Python files parsed successfully, and the
data-only composition/entry check replayed existing `transport-source01`
exactly with 14 frozen module snapshots. No qualification plan was materialized
and no target job was run by this preparation task.

Completed qualification: safe-source03 with p118-safe-api03 and runtime-extend01
passes the above workflow in the frozen `native-safe03-plan.json`. Its explicit
6GiB guard is based on measured compiler-scale memory, not ordinary-run defaults.
[Native result](../../../../implementation/phase118/native-results.md) records
all gates and timings. Use fresh artifact paths for a repeat; existing outputs
are immutable evidence. v2 preserves the integrated entry and captures exception
stacks, which identified the older eager foreign-catalogue recursion.
