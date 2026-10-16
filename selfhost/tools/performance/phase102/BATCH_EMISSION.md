# Batch checked-API emission

`emit-batch-v2.py` and `compile-batch.mjs` are successors to the unchanged per-source
`emit.py` / `compile-api.mjs`. Root owns execution through the same serial
Phase86 guard (2 GiB RSS bound). This method prepares authenticated Base once
inside one checked testing API process. Each source independently runs
`p86_plan`, effect parsing/lowering and `nr_compile_prepared`.

```sh
python3 -B selfhost/tools/performance/phase102/emit-batch-v2.py \
  --acquisition selfhost/build/phase102/SELECTED-api/report.json \
  --apps source-index,image-render,dependency-plan \
  --out selfhost/build/phase102/NEW-batch-emission --seconds 180
```

The existing `--source FILE...` and `--manifest FILE` selections are also
supported. Repeated references to the same ID and exact resolved source path are
deduplicated in first-occurrence order; the same ID with a different source is
refused. This supports benchmark manifests with several cases per source.
The unused original `emit-batch.py` is retained with its stricter duplicate
refusal; use v2 for new runs. The JavaScript method is unchanged.
`--seconds` bounds the entire batch, not each source; its range is 1–600.

Outputs retain `<id>/emitted/program.c` and `<id>/emitted/report.json`. Every
program receipt binds the API, source, method, pinned runtime/providers and an
immutable `batch/preparation.json`. That shared receipt records exactly one
Base preparation and its time. Per-program `basePrepareMs` is zero;
`sharedBasePrepareMs` names the shared cost rather than charging it repeatedly.
These timings are warm batch observations, not independent cold requests.

The top-level receipt binds the checked API acquisition, compiler source,
method snapshots, input manifest, guard receipt, shared preparation and all
per-program receipts. The child persists phase/source progress before compiler
calls. The first failure stops the batch; already completed C and the failed
source's partial receipt remain. The parent also preserves the last child state
when the guard terminates it. Later programs remain explicitly unrun.

Only the immutable Base seed is reused (`p86_plan` accepts `+seed`). Request,
effect and result graphs are scoped per source; Bun garbage collection runs
between programs to control retained memory. There is no cross-source request
or code-output cache, provider-name-only permission, or compiler implementation
outside Bend. The pre-existing native request transport pin is unchanged.

Before use for broad controls, root should compare the complete emitted C for
the three applications against the old runner with the same checked API.
Include a valid/invalid/valid source order once to establish failure retention
and early stopping. These are qualification checks, not completed results.
The methods were only syntax-checked and inspected offline when prepared.
