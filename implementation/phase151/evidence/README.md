# Phase151 evidence and replay

`phase151.tar.gz` contains exact source assemblies, all guarded commands/timings,
failures, selected complete QBE, original/patched assembly and closed-run receipts.
`capsule.json` records every payload and byte-identical alias. The archive is
746,929 bytes, SHA256
`7910ba7d54355728c32b1ec0b1eec3962efdf526bd21ec44702c3640f8c18800`.
Every stored member was decompressed and checked against its size/hash.

Executables, runtime/toolchain files and large generated APIs are not embedded.
They remain in their pinned operational locations or verified local retention
capsules under `selfhost/build-retention/phase151/`. Reproduction requires those
assets or explicit reacquisition; this archive is not a standalone toolchain.
Do not extract over live build roots. Extract to isolated scratch, verify hashes,
restore any needed aliases from their identical payloads, then use fresh run roots.

The current experimental sources are under `selfhost/tests/phase151/`. Three
alternatives were removed from the working source tree only after exact archive
verification: `dispatch-direct.bend`, `decode-probe.bend` (prepared, unexecuted),
and the failed large `unit-counterfactual-pins.bend`. Their original paths are
archive member names. The capsule also retains every frozen complete assembly,
so replay does not depend on rediscovering a source slice.

## Replay order

1. Inspect the frozen guard `process.json` for exact producer, Base, carrier,
   runtime, input, tool and CPU pins. The native producer is qualified Phase147
   N2 (`ab5662a1…27ca32`), not an implicitly rebuilt compiler.
2. Source-check `probe-source02/probe.bend`, then acquire it with the maintained
   native builder. Its controls use `-- phase151 controls 0 0`; timings select
   `reference-roles`, `candidate-roles`, `reference-binary` or `candidate-binary`,
   followed by `20000000 4294967290`. Native runtime flags remain
   `--threads 1 --gpu off` before `--`.
3. Acquisition comparisons use `acquisition-source01/{reference,candidate}.bend`;
   the balanced alternative is `direct-source02/acquisition.bend`. Separate
   requests `emission01..06` require exact complete QBE oracles. Their acquisition
   and emission clocks are distinct.
4. For the counterfactual, use the small **runtime-pin** patcher assembly
   `unit-source03/patcher.bend` and the current
   [API/dependency recipe](../../../selfhost/tests/phase151/unit-counterfactual-api.json).
   Authenticate the full input and both raw pins against the original manifest,
   before and after invocation. The successful CLI is
   `-- phase151-unit INPUT ROLESPIN BINARYPIN OUTPUT`. The old compiled-pins
   manifest describes a rejected acquisition route; its shorter CLI is historical.
5. Require the exact84-line diff and unchanged bytes outside the two selector
   workers. Build the resulting QBE through the same runtime/QBE/toolchain, run
   controls, and repeat the `unit-timing00..16` schedule. The three refusal inputs
   must exit1 without creating output. No emitted invalid input is executed.

The diagnostic transform is implemented in Bend. Host scripts assemble exact
source bytes, supervise processes, authenticate artifacts and summarize receipts;
they do not implement the proposed compiler optimization.
