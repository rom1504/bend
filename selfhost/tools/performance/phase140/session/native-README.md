# Native two-revision session adapter

`native-v02.bend` adds only the experimental native CLI dispatch. The ordinary
six-argument branch and usage fallback are unchanged, byte for byte (527 bytes).
The production parser/checker/lowering/verifier functions are not overridden.

```text
IMAGE --threads 1 --gpu off -- phase140-session \
  A B BASE CARRIER STAMP OUT_A OUT_B warm|cold RELATIVE_UTF16_HINT OWNER
```

Paths are absolute; output paths are distinct from one another and the inputs.
The trusted supervisor also requires fresh output directories and pins physical
inputs, producer, Base, carrier and runtime. Both revisions use **A as the logical
source path**. B's bytes are read from physical path B. Receipts must distinguish
this from compiling B with B's own logical path, which changes diagnostic origins
and can prevent parser reuse. The mode drops or retains all three cache layers:
compiler session, registry and render. The producer remains fixed inside this
one process; candidate source changes are inputs, not new producer epochs.

The hint is canonical decimal U32. It counts UTF16 units from the beginning of
each source, and must fit both source widths. The adapter adds the authenticated
Base source end to form the actual parser offset, rejecting arithmetic overflow.
The owner name goes through `p140f_named` and the actual freshened event list,
not a host declaration counter. Missing owners conservatively capture zero
source events; existing independent checkpoint admission remains authoritative.

Each revision reports:

- frontend: parser, full freshening, checker, reporting, annotation and erasure;
- raw: runtime admission and generic/private native lowering;
- backend: optimizer passes and final independent verification;
- registry: fusion/worker registry planning;
- render/close: output framing, rendering or reuse decisions, writes and close;
- total: the sum of those intervals.

Cold cache disposal happens **after** the revision timer starts. Preparation is
reported separately and includes Base/carrier IO+decode, both input reads and
hint validation. External process wall time also includes gaps, printing and
teardown. Host frame reconstruction and machine building are outside these
native stage clocks and must be charged separately. Clocks do not claim that
render reuse avoids host byte materialization.

Pending typed state is returned only after `p140rw_drain` successfully completes
and closes its output. Compilation/write errors terminate the process and cannot
publish state into revision B. No serialized cache or unchecked heap injection
is supported. Registry and render decisions use their existing checked Bend
interfaces. Frames are emitted with the separately versioned counted UTF8 writer.

`native-controls-v02.bend` contains20 pure guard probes: path rules, actual warm/
cold cache selection, canonical integer parsing, and the exact bound arithmetic
used by the adapter. Numeric/bound probes do not replace the actual IO smoke.
`modules-native-v03.json` records the full composition; native-source03 and
p140-native-api03 are its acquisition paths. Subsequent parent integration may
choose a later explicitly recorded composition.

Preserved failures: native-api01 rejected a nested pattern after a later binder;
native-api02 rejected the newly added safe control helper's forward reference.
Neither was a semantic execution failure or native benchmark result.
