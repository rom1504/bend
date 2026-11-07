# Independent Packet value oracle

`selfhost/tests/phase173/owned-decomposition-oracle.mjs` is a separate,
minimally extended copy of the frozen `borrow-oracle.mjs`. It adds the exact
source schema for `P173OwnedPacket` / `P173OwnedVacant` and two modes:

- `packet`: observe the unchanged workload's complete `List<&2,P173OwnedPacket>`.
- `packet-digest`: observe the timing workload's `U32`; authenticate the same
  Packet declaration even though the result is scalar.

Both require a successful independent upstream source-check/acquisition receipt
exporting exactly `main`, run with that receipt's exact engine, verify input pins
before and after, bind constructor field order to the actual source declaration,
and serialize the observed value into a separately checked constant Bend
program. The original oracle transport is unchanged. There is no optimization
algorithm or reconstruction of the tested computation in this host adapter.

The fixed-size Packet result needs no giant-literal splitting. The scalar timing
oracle does **not** replace the complete-value gate. As with the original tool,
the generated constant still requires source checking and ordinary baseline
native readback before its stdout is an execution oracle.

## Source snapshots and root-owned execution recipe

All paths below are relative to the repository root. Use a fresh output suffix
if any named directory exists. `<engine>` and `<upstream>` must be the existing
pinned Bun binary and upstream checkout from the current checked API receipts;
do not choose a new toolchain. Only the coordinating root runs target commands,
under the existing resource guard and single execution lane.

Freeze the full source byte-for-byte and a digest version differing only in
`main` (metadata operation, no target execution):

```sh
python3 -B selfhost/tests/phase173/owned-decomposition-snapshot.py \
  --workload selfhost/tests/phase173/owned-decomposition-workload.bend \
  --digest-main selfhost/tests/phase173/owned-decomposition-workload-digest.bend \
  --out selfhost/build/phase173/owned-packet-source01
```

The report pins both inputs, the assembly helper, every unchanged declaration,
the original/replacement `main` bodies, and both output sources. The source
checker, not the metadata transport, establishes Bend validity.

Independently check and acquire the unchanged full workload:

```sh
python3 -B selfhost/tests/phase173/job.py owned-packet-oracle-api01 120 32 \
  <engine> selfhost/tools/build/hosted.mjs acquire \
  --source selfhost/build/phase173/owned-packet-source01/full.bend \
  --exports selfhost/tests/phase173/borrow-oracle-exports.json \
  --engine <engine> --upstream <upstream> \
  --out selfhost/build/phase173/owned-packet-oracle-api01

python3 -B selfhost/tests/phase173/job.py owned-packet-oracle-value01 30 16 \
  <engine> selfhost/tests/phase173/owned-decomposition-oracle.mjs \
  --kind packet \
  --receipt selfhost/build/phase173/owned-packet-oracle-api01/report.json \
  --out selfhost/build/phase173/owned-packet-oracle-value01
```

Acquire and observe the digest independently, with the same pinned upstream:

```sh
python3 -B selfhost/tests/phase173/job.py owned-packet-digest-oracle-api01 120 32 \
  <engine> selfhost/tools/build/hosted.mjs acquire \
  --source selfhost/build/phase173/owned-packet-source01/digest.bend \
  --exports selfhost/tests/phase173/borrow-oracle-exports.json \
  --engine <engine> --upstream <upstream> \
  --out selfhost/build/phase173/owned-packet-digest-oracle-api01

python3 -B selfhost/tests/phase173/job.py owned-packet-digest-oracle-value01 60 16 \
  <engine> selfhost/tests/phase173/owned-decomposition-oracle.mjs \
  --kind packet-digest \
  --receipt selfhost/build/phase173/owned-packet-digest-oracle-api01/report.json \
  --out selfhost/build/phase173/owned-packet-digest-oracle-value01
```

Then use the existing ordinary QBE emission, final verification, native build,
and complete-stdout comparison gates for the same full source under baseline
and candidate. Independently build the constant oracle using the unchanged
baseline. Repeat for the digest and only then use balanced clean timing and a
separate event-counter pair. Receipt identity must distinguish original versus
transformed compiler API and keep source/preparation/runtime identical.

## Additional source-level arithmetic check

This is a hand-derived check, not a replacement for observing the independently
checked upstream implementation. The five complete records should be:

```bend
[
  P173OwnedPacket{"9",[13,14,15,16,17,18,19],9,[31,37]},
  P173OwnedPacket{"17",[28,29,30,31,32,33],17,[31,37]},
  P173OwnedPacket{"17",[17,18,19,20,21,22],17,[31,37]},
  P173OwnedPacket{"same-child",[4,5,6,7,8],43,[3,4,5,6,7]},
  P173OwnedVacant{71}
]
```

The timing workload updates values `7..134` exactly 10,000 times. Their sum is
1,289,024; stamp 7, backup sum 68 and label length 1 give **1,289,100**. This
checks the root agent's independent arithmetic prediction as well as the
upstream-derived digest. The retained root alias and shared child alias are
covered by the complete-value workload, not inferred from this scalar.

No target was run while preparing this transport. Actual admission, output,
runtime and counter evidence belongs to the coordinator's execution receipts.
