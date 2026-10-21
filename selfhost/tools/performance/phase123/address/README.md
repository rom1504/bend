# Scaled-address finite controls

Export `p123a_scale` and `p117h_address` from a checked API composed with
`scaled-address02.bend` and the current packed32 Phase121/123 parent. Run:

```
node selfhost/tools/performance/phase123/address/controls.mjs CHECKED_RECEIPT selfhost/build/phase123/address-controls01
```

The harness authenticates the checked receipt/API inputs, itself, the selected
module and host executable before and after use. It checks80 bitvector pairs
across shifts0,1,2,3,4,31,32,63 and ten unsigned64-bit boundaries. Admission is
exact for0..3; the other shifts must return the unchanged shift node.

Nine GET/SET/SWAP/site/origin combinations must preserve the exact mask, packed
multiply4, offset and optional load order. SET has no old-value load; GET/SWAP
retain one U32 load. Another450 independent masked-offset observations use
BigInt modulo64 arithmetic. Pointer addition and memory are never executed.

This is finite analysis evidence; whole-program verification, ordinary array
output controls and timing remain separate. The author has not run this harness
or acquired its checked API.
