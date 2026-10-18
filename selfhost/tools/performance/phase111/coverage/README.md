# Phase111 independent coverage

`manifest.json` freezes 19 focused sources and six broader complete-output
oracles. `fixtures/` contains unchanged Phase108 controls, unchanged repository
contracts and two small manually specified pure arithmetic results. All reused
controls are regressions, including Phase108's formerly held-out String case.
No compiler or generated target was run during preparation.

Root's `source-closure01` and `closure-build01` subsequently passed the first
actual checked-source closure/IO gate, producing exactly `captured=42` plus LF
through direct QBE and `runtime-source03/runtime.o`. This used the hosted checked
Bend API, not a native Phase111 compiler. The remaining source gates are pending
in this initial status note; later execution receipts are authoritative.

Start with `higher-order-capture`, `non-tail-list`, `arrays-io`, `pure-u32` and
`pure-string`. They distinguish dynamic capture/application, continuation
resumption, array ownership and IO, and pure-result readback. Then run the
remaining ownership/scanner, pure aggregate/Char/F32 and primitive cases, plus
the three source refusals. A valid unsupported program is an explicit backend
gap, not a successful negative test.

The intended root entry is `IMAGE --threads 1 --gpu off -- phase111 ABS_INPUT
cache|live`. Root records the actual module/data output and link interface when
those contracts are ready. Do not reuse Phase108's runner unchanged: it emits C
and invokes cproc, which would defeat this phase's direct-path gate. Keep source
admission, structured lowering, QBE assembly, link and execution failures distinct.

Root can now run the serial supervisor under its existing outer process-tree
guard and CPU3 affinity:

```sh
python3 -B selfhost/tools/performance/phase111/coverage/run.py \
  --api selfhost/build/phase111/full-api03/api.mjs \
  --runtime selfhost/build/phase111/runtime-source03/runtime.o \
  --out selfhost/build/phase111/coverage-FRESH --mode cache
```

The default is the five-case `fastOrder`. `--names NAME ...` selects focused or
broader cases (`broad:NAME` also works); `--mode live` changes Base preparation.
Inputs, method, manifest and every child receipt are pinned before and after the
campaign. The runner stops at the first failed gate unless `--keep-going` is
explicit. Progress and partial results remain in `report.json`. Expected
frontend refusals count separately from compiled and executed positives; a
lowering/IR/transport failure cannot satisfy a source-negative case. Individual
steps default to 60 seconds, bounded further by root's outer guard. This tool
has only been syntax-reviewed by its author, not launched.

`python3 -B selfhost/tools/performance/phase111/coverage/verify.py` authenticates
the frozen inputs without executing a target. To compare a saved observation,
add `--case NAME --stage execute --exit-code N --stdout FILE --stderr FILE`.
Use `broad:NAME` for a representative. Source negatives use
`--stage source-admission --exit-code N` and repeat `--product PATH` for every
intended QBE/data/object/executable output. This checker never launches programs
or obtains an oracle from a candidate.

`broad-inventory.json` records all 45 existing broad source/output contracts and
their historical generated C pins. Those C files are provenance and inspection
inputs only. The new compiler must lower actual checked erased facts directly;
it must not parse those files or translate strings emitted by the old backend.
Use the six representatives before the complete broad gate. They include real
lexer work, floating-point geometry, captured closures, Unicode, persistent maps
and arithmetic. All 45 source, output-record and historical C pins matched at
preparation; this is availability evidence, not Phase111 admission or execution.

The [coverage notes](../../../../../implementation/phase111/coverage-notes.md)
describe the remaining ABI controls and full compiler/successor gate. Cleanup
proposals in this directory are read-only inventories; root owns every deletion
or lossless compression and its separate receipt.
