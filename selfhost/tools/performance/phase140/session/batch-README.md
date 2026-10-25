# Optional bounded native batch

Checked and natively exercised by Phase140: compose `native-v03.bend` in place of
`native-v02.bend`, then add `native-batch-v02.bend` and
`native-batch-controls-v02.bend` (14 predicates). Deleting the new seven-token
CLI case from native-v03 reproduces the complete native-v02 file byte-for-byte.
The ordinary and two-revision entry paths are unchanged.

```text
IMAGE --threads 1 --gpu off -- phase140-batch LOGICAL BASE CARRIER STAMP JOBFILE v1
```

JOBFILE repeats exactly five LF-delimited fields, with an optional final LF:

```text
/physical/revision-A.bend
/fresh/output-A.frames
12345
first_edited_owner
cold
/physical/revision-B.bend
/fresh/output-B.frames
12345
first_edited_owner
warm
```

There are at most64 jobs and32768 UTF16 units. Canonical U32 hints are relative to
each physical source's text; all compilations use the same logical source path.
Before any output opens, Bend validates the entire job list and rejects outputs
that name any input (including later jobs) or another output. Repeated input paths
are allowed: LOGICAL matching revision A is intentional. The trusted supervisor
still pins files, canonical paths, fresh destinations and the fixed producer.

Prepared Base is acquired once. Each job reads only its source, checks hint bounds,
then calls the already checked `p140n_compile`. It retains only the previous
successful compiler/registry/render cache; publication follows output closure.
Cold clears all three caches inside the measured compiler interval. The first
job should capture before the earliest owner to be edited in the planned sequence.

Output labels are numeric ordinals: `phase140 batch N io_ms=… stats=…` and the
existing `phase140 stages N …` fields. `batch_prepare_ms` includes job-file read,
parse, preflight, Base/carrier IO and preparation. Per-job IO_ms includes source
reading and hint validation. Native stage clocks retain the pair-mode definition.
External process wall, host materialization and machine building remain separate.

REUSE frame ordinals refer to the **immediately preceding successful output**.
The supervisor must chain authenticated materialization receipts in that order,
including after a cold job. Each current physical source and fixed logical path
must be recorded; fresh comparison oracles must use the same logical path.

No framework, serialized compiler state, host-side compiler decisions, production
selection change or new runtime effect is introduced.

## Current evidence and limits

The [Phase140 report](../../../../../implementation/phase140/README.md) identifies
the exact active composition and measurements. `modules-native-v17.json` is the
composition behind `p140-n1c`; `full-product02` compares an actual full-compiler
product-policy edit against separate qualified fresh A and B products. The earlier
`full-batch01` contains three edits, but only A and product-policy B have independent
full-output references. Inline/continuation timings remain exploratory.

Use `run-batch-v01.py --image IMAGE --plan PLAN --out FRESH --seconds LIMIT`
under the existing resource guard. The JSON plan supplies `logical` and ordered
`jobs`, each with `name`, `source`, relative UTF16 `hint`, `owner`, `mode`, and an
optional independent `expected` QBE path. Missing `expected` means unqualified
output, not an implicit pass. The runner pins inputs and reconstructs each output
using authenticated previous-output ordinals; it makes no semantic cache choice.

This interface accepts a predeclared batch, not live edits from an interactive
development server. The pure API preserves successful state after a rejected
edit; the native CLI currently exits on an error and loses its process cache.
Native source checking, focused output equivalence, full self-reproduction and
installed adoption remain separate gates.

`run-batch-v02.py` additionally accepts an explicit generic sampler receipt for
diagnostic runs. Sampling times must not be substituted into clean speed ratios.
