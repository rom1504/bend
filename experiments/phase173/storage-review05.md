# N1 acquisition intermediates: one-root archival proposal

Archive exactly `program.ssa`, `program.s` and `program.o` from
`selfhost/build/phase173/owned-native-n1-08`. Keep its executable, complete build
receipt/image binding, source snapshot, runtime, requests and every other file.

The selection is **187.87109375 MiB allocated**, with exclusive stable inodes and
fresh hashes matching the successful build receipt. The guard succeeded and the
original lifecycle is sealed/completed. This acquisition is not being described
as a qualified installed compiler.

The exact compatible proposal is
[storage-proposal05.json](storage-proposal05.json). No target, capture or apply ran.

## Following native generation remains supported

`selfhost/tools/build/request.py:image_binding` authenticates the executable and
`--image-receipt`, checks the recorded host/stage/target contract, and returns
those two files as image inputs. It does not open the receipt's generated
assembly, object or retained QBE. `request.plan` and `native.build` independently
authenticate the requested source, Base/carrier, runtime and machine toolchain.
All of those inputs remain hot.

The image binding records the N1 executable SHA256
`a634d2405acee15369b050f9b931201d0662d3bae085a32989e825b29791e85a`
and `owned-native-source08/compiler.bend`; neither is selected for archival.
A bounded scan of 1,098 current Phase173/test/manifest receipts found the three
selected paths only as output identities in their own original build report.

**N1 QBE must not be used as the N2 fixed-point oracle.** N1 was produced by the
old optimizer, while N2 executes the new optimizer and may emit different QBE.
Retain N2 IR for N2→N3 self-reproduction. Normal compilation with
`--image owned-native-n1-08/program --image-receipt owned-native-n1-08/report.json`
continues to work after this archival. Later N1 relinking, detailed machine
inspection or profiler ownership mapping requires exact restoration first.

## Capacity and commands

At review, free space above the 5 GiB reserve was **147.90 MiB**. Comparable
QBE/assembly/object captures suggest an archive around **24.40 MiB**, giving
roughly **163.47 MiB net recovery** and **311.37 MiB above reserve** afterward.
These are estimates. Even subtracting the full 32 MiB archive cap leaves
**155.87 MiB** recovery before small receipts/filesystem effects, or about
**303.77 MiB above reserve** at the observed starting point. The previous build's
256 MiB budget should then fit; its actual measured peak was 203.66 MiB. Recheck
actual free space before admitting N2, since other writers can change it.

The existing helper is directly compatible; no new capture machinery or graph
campaign is needed. Root must enforce **5 GiB + 32 MiB** before capture because
the historical helper internally permits a 4 GiB floor, and recheck afterward:

```sh
python3 -B experiments/phase169/archive-selected-v02.py \
  --proposal experiments/phase173/storage-proposal05.json \
  --name p173-owned-native-n1-08 \
  --out selfhost/build-retention/phase169/p173-owned-native-n1-08
```

Inspect `capture.json` and `verified/plan.json`, then separately apply exactly
those three leaves:

```sh
python3 -B selfhost/tools/build-retention/archive-v02.py apply \
  --plan selfhost/build-retention/phase169/p173-owned-native-n1-08/verified/plan.json \
  --out selfhost/build-retention/phase169/p173-owned-native-n1-08/applied
```

Preserve the capsule, plan and apply journal. The maintained `restore` command
with the same verified plan and a fresh receipt directory recovers all three
exact products. Do not reopen the completed lifecycle or remove any directory.
