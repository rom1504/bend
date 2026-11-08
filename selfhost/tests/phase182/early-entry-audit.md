# Phase182 early-entry effect permission

Source review accepts the seven-name extension in
`src/back/native/effect-admission.bend:16`: `IO.args_bytes`,
`File.open_bytes`, `File.read_line`, `File.read_bytes`, `File.read_at`,
`File.write_bytes`, and `File.write_at`. This conclusion assumes the existing
checked-source, exact authenticated Base/provider/runtime, and ownership ABI
preconditions. It is not a proof for arbitrary foreign implementations with
those names, nor a claim of executed runtime conformance.

The audited upstream is `9a4223d577ba56a0cb53d1fd952d2b481c38930f`.
Its `bend2/effs/args.c`, `file_open.c`, `file_read.c`, and `file_write.c`
implement these operations as follows:

* Arguments create fresh lists from OS argument bytes.
* Open and write copy the supplied String/List into a separate malloc buffer
  through `io_cbuf`. Bytes outside 0..255 are rejected by the byte providers.
* Read variants allocate a C buffer and construct fresh String/List results.
* File operations act on external descriptors and offsets. They neither return
  immutable Bend root addresses nor compare or expose allocation identity.

The maintained QBE runtime has the corresponding providers at
`src/runtime/qbe/runtime.c:3258`, `:3369`, `:3416`, and `:3577`; the runtime
object recipe retained in `build/phase182/runtime-build02/report.json` binds
that source (SHA256 `27e2baff91b03252d66062235208cd2a17ab0038b17003ac76fbb7c8a7e30dca`).
The C backend's current provider groups use the same conversion pattern.
`io_cbuf` consumes values through `ctr_take` (`runtime.c:2545` and `:1074`):
unique storage can be reclaimed, while shared storage preserves its fields
through `span_fade`/reference counts. Reference-count changes and reclaiming
uniquely owned nodes do not mutate a retained immutable root's value. No Array
payload, root identity, or writable alias is exported to these OS calls.

Keep `NativeHost.read/path/publish` separate. Their fixed-runtime availability
in `src/back/qbe/lower.bend:705` is not observer permission. The extension does
not add these build bridge names to `no_effect_foreign_allowed`.

`p169np_plan` first runs ordinary runtime admission, then
`p168_request_mode(1, request)` and the existing original/private/borrowed/direct
verification path (`src/host/qbe-early-entry.bend:52`,
`src/back/qbe/early-emission.bend:158`, `:250`, `:264`, `:274`). The previous
generic `p134e_plan` preflight did not exercise this same early permission
boundary. The new control calls the actual entry without a supplied certificate
and drains its whole cursor using the same newline rules as `p169s_prefix` and
`p134w_step`; it performs no host-side compiler transformation.

## Finite gate recipe

Run from the repository root, with fresh output names. These commands are
prepared, not executed by this audit:

```sh
python3 -B selfhost/tests/phase182/job.py --rss-mib 4096 early-api02 90 80 \
  selfhost/.assets/bin/bun selfhost/tools/build/hosted.mjs acquire \
  --source selfhost/build/phase182/snapshot08/compiler.bend \
  --exports selfhost/tests/phase182/early-entry-exports.json \
  --engine selfhost/.assets/bin/bun \
  --out selfhost/build/phase182/early-api02

python3 -B selfhost/tests/phase182/job.py early-controls01 90 60 \
  selfhost/.assets/bin/bun selfhost/tests/phase182/early-entry-controls.mjs \
  --api selfhost/build/phase182/early-api02/report.json \
  --source selfhost/build/phase182/snapshot08/compiler.bend \
  --assets selfhost/build/phase182/assets-candidate11.json \
  --out selfhost/build/phase182/early-controls01
```

Require four completed passing rows: three complete QBE products (`argv`,
`files`, `open-errors`) and the exact historical `p108_missing` backend refusal
with empty forwarders/end cursor. A frontend failure, exception, or timeout is
not that negative oracle. The fresh report pins the checked acquisition,
canonical source, Base, engine, fixtures, assets, runtime object, and adapter;
changed inputs invalidate it. Limits are 32 MiB of QBE, 100000 forwarders, and
100000 cursor pieces per positive case.

The script stores fixed literal stdout/stderr/status oracles and machine-build
commands in its report. It does not claim those outputs were observed. Each
positive product can subsequently use the existing `native.py --ir` lane with
the same assets; run the resulting program in a fresh directory and compare
complete stdout/stderr/status to its retained oracle. The reported argument
prefix comes from the authenticated `qbe-runtime` provider, including the
`bend-rts-v1` convention. The three requested cases cover the failed entry
paths; they are not a new exhaustive runtime suite for all seven providers.

Root execution completed: [early-controls01](../../../implementation/phase182/evidence/early-controls01.json) passes all four rows. The initial acquisition hit the default 2 GiB RSS cap; the fresh API02 acquisition passed under the explicit 4 GiB bound used for full-source hosted acquisitions. Generated-program execution remains a separate gate.
