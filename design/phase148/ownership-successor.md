# Native ownership correction

The initial representation passes independent source checking and81 hosted
comparisons, but fails ordinary native execution. Keep those results separate.
`compiler-native02` reproduces the complete old output; its compact mode stops
before the first output. A31KB pack-only program reproduces the failure without
the scalar optimizer or verifier. Independent storage and dictionary-seeding
controls pass.

The source error is sharing an affine wrapper through `@unsafe +` parameters.
The native runtime permits explicitly shared raw Array handles, but constructor
sealing does not recursively make arbitrary Type values duplicable. In the
observed path, `p148c_vector_done` shares Build to inspect its position, which
shares Tape containing unsealed arrays. `ctr_take` reaches `span_fade` and the
runtime correctly refuses those unsealed children. This is not evidence of a
production conformance regression. Source checking an `@unsafe` definition is
not an ownership theorem.

Do not relax runtime checks or rely on incidental RFC normalization by an
optimizable fork/join expression. Correct the representation boundary instead.

## Successor interface

`P148Tape`, `P148Unit`, `P148Build`, `P148Ref` and consumer result records remain
affine Type wrappers. Each wrapper is consumed exactly once by its next helper.
Array-bearing constructor fields have no `+` annotation. Ordinary scalar and
String metadata may remain shareable.

Internal consumers receive raw arguments in this order:

```
words: Array<U32>, values: Array<U32>, names: Array<String>,
used: U32, valueUsed: U32, nameUsed: U32
```

Read-only raw handles may be explicitly shared under the existing Array handle
contract. Writes still sequence through consuming helpers; independent branch
facts still require a real `Array.clone`. Never share a wrapper to obtain its
metadata. Unpack it once, observe metadata, and reconstruct a fresh wrapper only
at a transfer/return boundary. The same rule applies to scalar scan, verifier
schema and flow records. It removes wrapper transport rather than adding a
hidden general-purpose cloning mechanism.

Public pack/unpack/scalar entry points stay consuming. Admission becomes:

```
type P148Checked is Type:
  P148Checked{unit: P148Unit, +error: String}

p148v_check(unit, ids, ready) -> P148Checked
p148v_function(unit, ids, ready) -> String  # consumes the checked result
```

The native pipeline decodes only the unit returned by `p148v_check`. A prior
unit alias is never reused. Hosted comparisons prepare independent units for
independent consumers so that permissive host sharing cannot hide this contract.

The codec provides the statement counter over the same six raw buffers. Its
construction helpers replace position queries on shared Build values with
affine observation/reconstruction. Internal decoder and verifier traversals
read the raw buffers without reconstructing structured statements between passes.

## Gates and scope

Preserve the first source, API, native image, failed execution, and each method
version. Recheck the successor source; repeat81 exact controls and supplementary
mutation/provenance controls. Then require ordinary native pack/roundtrip and
full-output success before taking a timing sample. Keep the same complete-region
workload and count encoding, decoding, cloning and cleanup. Do not rerun a full
compiler acquisition for this repair.

This correction is part of the more ambitious design: preserve ownership in the
representation and eliminate unnecessary wrapper work across consumers. It is
not a measured speedup or a justification to broaden the production compiler.
