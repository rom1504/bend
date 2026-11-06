# Restore source-authorized cold metadata after verification

The optional `cold-emission.bend` seam restores the maintained cold-constructor
plan without restoring the old global preparation pipeline. Its only override
is the certified renderer's `p169a_checked`. Existing original/static/adapter/
private verification and complete borrowed-view verification have already run.
The enabled array/transport namespace gate still runs before any emission.

After those successes, the seam constructs `P113AProgram` from that exact verified
program, view and actual request certificate. If `certificate.scalar` is true,
it derives `p118c_plan(request)` from the same original checked request and calls
unchanged `p118c_apply_plan`. That helper applies only valid/error-free plans and
otherwise returns the original program. Only constructor hot flags change;
constructor order/IDs, generic segments, static nodes, functions, effects, public
view and array certificate remain unchanged.

The false-scalar fast path is justified by the exact definitions:
`p113a_certificate` records `ns_definitions(book,names)` and `p118c_plan` uses
that same expression as its permission. False scalar therefore implies the
cold plan would be invalid. No cold plan is derived on this path, and the old
`p169s_seeded` emitter receives the exact original values. `unshared` is not cold
authority: a scalar-true/unshared-false request may still derive a valid cold plan.
No benchmark name, size threshold, host Boolean or constructor whitelist selects
the treatment.

Existing error precedence is preserved. Failed view verification calls the same
`p169sv_refused` fallback; array/transport namespace errors retain the same prefix
and occur before cold planning. The current array-enabled renderer remains
unchanged; its `p118c_tables` derives capability8 from the actual resulting cold
flags. There is no constant descriptor15 write.

`cold-emission-controls.bend` adds eight finite controls: actual source permission
refusal, scalar versus unshared separation, false-source preservation, valid/
invalid/error plan flag mechanics and namespace-error order. Synthetic
`P118CPlan` values exercise the unchanged application's mechanics only; they do
not establish entry authorization. Actual checked cold-positive tree/lexer
requests, complete outputs and measured execution remain necessary.

The independent compiler-research reviewer found no blocker and confirmed the
same-request authority and metadata-only boundary. Source/type admission and
target outcomes were pending when this seam was prepared. No targets, runtime
changes, production edits or image acquisition were performed by this lane.

Preparation is optional and preserves all consumed predecessor methods:

```sh
taskset -c 0 python3 -B experiments/phase169/tools/prepare-cold-emission.py \
  --api --publication --admission --lazy --single-verify --native-protocol \
  --ordinary-composition --cold-constructors \
  --out selfhost/build/phase169/cold-api-source01
```

The resulting1,657,597-byte compiler has4,839 declarations, SHA256
`7cf2a64a992fc7dd0e0cfad09c056ae4221712c526463d7d6c7abcf62640a74e`.
Its manifest pins the frozen modules and wrapper derivation. Omit
`--cold-constructors` for the exact predecessor treatment; native export-only
preparation is separately owned by the research lane.
