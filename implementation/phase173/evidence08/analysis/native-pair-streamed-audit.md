# Streamed native-product comparison

`selfhost/tests/phase173/native-pair-streamed.py` is a separate transport-only
comparison harness. It leaves `native.py`, the original `native-pair.py`, compiler
semantics, source checking and output oracles unchanged. Its purpose is to time
already-built executables without requiring a second hot copy of streamed QBE.

## Why the missing text is acceptable here

The maintained builder hashes every byte read from the producer and delivers
the same bounded buffer completely to QBE before reading the next buffer.
Successful source builds require producer EOF, producer/QBE zero exits, nonempty
IR, empty producer/QBE diagnostics, completed assembly/linking and unchanged
input hashes. The final executable and linked runtime have their own pins.
Keeping the complete stream digest is sufficient provenance for this bounded
execution comparison. It is not evidence that the compiler or backend is
correct, nor permission to claim a later textual or machine-code analysis.

The new harness requires:

- A versioned, completed, unchanged maintained build receipt for each executable.
- A nonempty complete stream digest and successful machine-stage receipts, with
  commands bound to the recorded assembly/object/executable paths and runtime.
- Successful source producer/QBE exits and empty diagnostic streams for streamed
  source builds; an authenticated complete hosted receipt for JS producers.
- Every build/request input still present and matching its pin, including source,
  compiler image, Base/carrier, providers, manifests and build tooling. A missing
  input is an error; an IR digest does not excuse missing source provenance.
- The same runtime, runtime policy, machine flags and exact QBE/assembler/linker
  executable identities on both sides. Comparing flags alone is insufficient.
- A mandatory caller-supplied fixed expected-output file. Its independence must
  be established by the surrounding source/oracle experiment, not inferred by
  this host adapter. No first-run baseline becomes the oracle implicitly.
- Input verification before and after timing, and binary verification immediately
  before each execution. Runtime arguments, sanitized environment, alternating
  order, 1/4 rounds and the 30 ms resolution floor match the existing harness.

Assembly/object copies are not required to remain hot after a completed build.
Their recorded identities and construction commands remain in the original
receipt. Supplied source IR and explicitly retained IR are authenticated when
present. No file is deleted or receipt rewritten by the comparison.

## Mixed supplied-IR and streamed-source pair

The contextual materializer baseline first completed emission, QBE and assembly,
but the original build was interrupted before linking. Its
`context-value-baseline09/report.json` remains `complete=false`. The separate
`context-value-baseline10/report.json` is a successful `native.py --ir` rebuild
of the exact original retained QBE. It contains no compiler command or compiler
exit, so requiring those fields would misdescribe that operation.

For a supplied-IR product the new harness additionally requires
`--baseline-emission` or `--candidate-emission`, as appropriate. It authenticates
the original source/compiler/assets and successful emission portion, requires
its retained IR and digest to match the rebuild's `sourceIR`, and checks the
same runtime/QBE toolchain. The original report need not describe a completed
link, but recorded changed inputs or unsuccessful emission are rejected.
The comparison records `originalEmissionBuildComplete=false`; it does not turn
the interrupted acquisition into a successful original source-to-executable
measurement. Original acquisition costs and failure stay separate evidence.

For this particular baseline the additional argument is:

```text
--baseline-emission selfhost/build/phase173/context-value-baseline09/report.json
```

The `--baseline` argument selects the successful `context-value-baseline10`
receipt. The candidate selects its successful source build without `--retain-ir`.
The caller supplies the independently established `--expected` bytes and a fresh
`--out` under `selfhost/build`, using the existing outer disk/process guard.

## Bounded validation performed

`native-pair-streamed-controls.json` pins the reviewed harness, common helper and
three actual build receipts. Source parsing and read-only authentication accepted
both the recovered-IR baseline and the existing N3 streamed build. It rejected
15 altered receipts covering incomplete products, changed inputs, failed producer
or QBE, diagnostics, missing linking, unbound runtime/source/compiler/tool inputs,
empty streams, missing original emission and mismatched/failed/changed original
emission. No compiled target or timing loop was executed during these controls.

The actual balanced exact-output run remains the coordinating agent's execution
gate. These finite provenance controls are not a proof against maliciously
fabricated receipts; the trust boundary remains the pinned maintained builder and
the independently preserved experiment records.
