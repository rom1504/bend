# P65-007: reduce fresh frame4 decoder tiering cost

- Owner: qualification/measurement lane; reviewer: cache-contract lane.
- Scope: isolated transport helper, same selected State09 API and cache bytes.
- Status: case-local loads rejected; static readers pass 87 controls and eight
  microprobe workers, first decode 0.4208× baseline. Four-source whole-request
  confirmation passes sixteen exact-output workers, compilation 0.89069× and
  imports plus compilation 0.91533×. Selected snapshot qualification is separate.
- Report: [decoder](../../implementation/phase65/decoder.md).

The selected helper validates and materializes 46,757 records. Loading only a
tag's actual fields reduced source loads by 46.69%, but made the first complete
decode 4.74% slower. Its separately attributed V8 trace shows repeated large
decoder recompilation and deoptimization as later tags/values arrive. Source
load counts and warm-only timings therefore do not predict request latency.

Test a small record loop with static, fixed-shape per-tag readers. Retain every
original constructor body, reference/subtype check, span/Unicode check, record
length/bounds check, legacy world shape and eager validation of unused records.
No compiler semantic algorithm moves into JavaScript. The encoder is unchanged.

The first successor adds 63 lines to the 285-line helper. A single dispatch table
calls twelve static readers; three static validation functions replace decoder
closures. One state object per decode carries shared arrays and the resulting
kind. Rare tags receive separate feedback. This is a hypothesis about V8's
optimization boundaries, not a claim that indirect calls are universally faster.

The frozen successor manifest is
`selfhost/build/phase65/frame4-static-tags01/manifest.json`
(`c3781176ca1a5c2b9a972ebaa896ad8c19c0971d374aeaf36b1ecfcc761e1671`).
Root runs the existing 87 domain controls and eight fresh-process workers with
complete graph-value, property-order and sharing equality. Reject on any changed
validation/value, no fresh-decode gain, or meaningful warm regression. A passing
microprobe only authorizes a same-image full-request experiment; it cannot
establish compiler speed or qualification by itself. Keep all prior consumed
artifacts immutable, and rebase explicitly if a different world schema is selected.
