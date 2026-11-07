# Native candidate acquisition checkpoint

Two complete acquisitions of the **same Phase175 candidate source** succeeded:

| Producer → output | Complete pipeline | Emission + QBE | Guarded wall time |
|---|---:|---:|---:|
| Installed Phase171 compiler → N1 |188.627s|183.286s|189.013s|
| Candidate N1 → N2 |180.583s|174.606s|182.375s|

Elapsed pipeline time decreased by **8.044s, 4.26%**. These are two sequential
acquisitions, not counterbalanced samples. N1 retained QBE while N2 streamed
without retaining it and compared against N1's QBE. Consequently the difference
is not a clean isolated compiler-throughput estimate.

Both compile candidate source
`a0e953a84de73aa22403dde7ec2144540197633857a0f7b5b9784f9e66f5ad04`.
This is distinct from the frozen Phase170 input used in the controlled
fixed-source benchmark reported below.

The generated products agree exactly at these boundaries:

| Product | Bytes | SHA256 |
|---|---:|---|
| QBE |98,149,013|`a52b5adeabcc3201a239bb4a8c4a07597a477fee5103fe1634f83c69cbe98644`|
| Assembly |73,713,271|`65876e920a3704e266dcd16ce2350bdf6f2aa2d5a6828010cf2495aa34333e24`|
| Object |20,977,848|`44ae8100a8dc995c49f2caf157186007d90c18ee6009814f1a43d7b3a0741cf2`|

The two ELF files have equal size but different hashes. The independent
[static ELF audit](../../experiments/phase175/elf-audit.md) established exact
loaded bytes, code/data, headers and symbol records. One nonloaded `.strtab`
pathname byte changes `full-native-n1/program.o` to `full-native-n2/program.o`.
Whole-file identity is false; ordinary loaded-image identity is exact. QBE
reproduction and static artifact equality establish bootstrap consistency,
not an independent proof of compiled-program correctness.

Raw [N1](evidence/full-native-n1/report.json) and
[N2](evidence/full-native-n2/report.json) build receipts, compiler diagnostics
and [N1](evidence/full-native-n1-guard/process.json) /
[N2](evidence/full-native-n2-guard/process.json) guards are copied losslessly.
The installed compiler remains unchanged. The subsequent focused/broad native
gate passes 64/64 cases, and all 45 exact timed-wrapper QBE products match their
retained references. N2's Q3 emission also matches the candidate-source QBE
exactly: 157.007s native execution, 158.254s complete request, without machine
construction. These are different correctness, product and reproduction gates;
none is a new generated-program runtime measurement.

The frozen historical-input pair completes in 185.550s baseline versus 178.937s
candidate: 6.612s, or 3.56%, less time. Both use the same expected-QBE checking
with no retained IR. The candidate ran first, then baseline, once each. The
[receipt audit](evidence/fixed-pair-audit.json) verifies 33 source/request/runtime/
toolchain/resource/output conditions. Use this pair for the complete-build
observation; do not derive it from the different-source acquisition table above.
