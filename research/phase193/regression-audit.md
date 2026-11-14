# Phase193 regression audit: local-fold and Unicode64

The reported full-suite candidate/baseline ratio is 0.9533. Retain the reported
local-fold +4.2831% regression (unflagged) and Unicode64 +5.0595% regression
(flagged) without adjustment. This bounded offline inspection does not establish
why either timing changed and does not classify the local-fold result as noise.

Inputs are the exact executables under
`selfhost/build/phase192/native45-02/CASE/machine/program` and
`selfhost/build/phase193/native45-01/CASE/machine/program`. Full file/section and
function fingerprints, instruction counts and call inventories are in
`regression-audit.json`. Inspection used objdump, Python reading and SHA-256;
no compiler, target, sampler, timing rerun, tuning or production edit occurred.

## Local-fold: identical repeated loop, different surrounding product

The retained earlier research identifies `$product.fold.loop` as the repeated
worker. Its complete **469 bytes and all 122 instructions are identical at the
same address 0x409022** in both executables. The loop header is 0x409177; its
positive body is 0x4091b4..0x4091f2, including the scale-four load/store and local
backedge. There is no new composition inside this worker and no relocation of
this loop. The 170-byte direct fold wrapper is also identical at 0x408c58.

The private `$direct.bench` and `$direct.p93.loop` remain respectively at
0x40934e and 0x409c69 with identical instruction/operand sequences after
normalizing resolved branch/call targets. Their raw bytes differ because call
relocations differ. The public p93.loop wrapper moves 0x40d813 → 0x40d84a while
retaining its normalized instruction sequence.

**The whole products are not identical.** This limits the negative conclusion
to the inspected loop and normalized workers; it does not eliminate a compiler
mechanism elsewhere in the measured request.

| Local-fold section | Phase192 bytes | Phase193 bytes | Contents equal? |
| --- | ---: | ---: | --- |
| Object `.text` | 49,875 | 50,267 | No |
| Object `.data` | 5,080 | 5,080 | Yes |
| Linked `.text` | 104,833 | 105,217 | No |
| Linked `.rodata` | 5,264 | 5,264 | No |
| Linked `.data` | 5,100 | 5,100 | No |
| Linked `.data.rel.ro` | 240 | 240 | No |

The ELF sizes are 180,544 → 184,640 bytes. Linked data differences are not
automatically semantic data changes: relocation values differ, but this audit
does not fully classify every differing byte. The object `.data` equality does
not imply linked table/pointer identity.

After normalization of absolute control targets and symbolic RIP relocations,
15 generated public bodies actually change: `$direct.Nat.read` (145 → 158
instructions) and continuations `$p111.k.{10466,10474,10475,4178,4193,4196,4211,
4214,4225,4228,7330,7333,8395,9431}`. For example k.7330 grows 90 → 109 and k.7333
71 → 92, while k.4193 and k.4211 shrink 85 → 76. Their call inventories and
counts are retained in the JSON. They are outside the repeated fold worker;
this inspection has no new dynamic attribution proving all of them irrelevant.

Executable SHA-256:

- Phase192: `9d96568866193119bb8d90c5ee8f2d5eedcc69b22f09e049eb44648d3883cd8b`
- Phase193: `3afba791d3bd94862ca99ef83b176a9c1d495bbf7fe16dba0a8ead113ec4b6d6`

Thus “changed/relocated hot fold loop” is unsupported, and “identical executable”
is false. Surrounding composition, call placement, runtime placement and the
execution environment remain possible factors; none is established as the
cause of the measured 4.2831% regression.

## Unicode64: actual public composition changes as well as relocation

The H workers retain their normalized instructions and symbolic call targets:

| Worker | Instructions | Phase192 → Phase193 entry |
| --- | ---: | --- |
| `$direct.p37.text.repeat` | 147 | 0x40db05 → 0x40dc0c |
| `$direct.sjoin.go` | 227 | 0x40ea2f → 0x40eb66 |
| `$direct.ssplit` | 240 | 0x40f4ca → 0x40f661 |

These bodies relocate; their raw call displacements differ. The private
`ssplit.pick` remains at 0x408495 with 111 normalized-equal instructions.
The public p93.loop is also normalized-equal, moving 0x4102c0 → 0x410483.

However the public path is **not merely relocated**. Public `$direct.bench`
changes 76 → 79 instructions and its stack frame grows 0x960 → 0x1160. The
candidate directly calls `p112w_FID_$direct.U32.show`, replacing the old
continuation scheduling sequence; it transports two result arguments to the
next transition instead of one. These are equivalent intended source operations
with different execution machinery, not evidence of additional source-level work.

The repetition continuation k.11547 changes 87 → 105 instructions, frame
0x980 → 0x11a0, and adds saved-register traffic plus direct calls to
`p112w_FID_$direct.String.eq` and `p112w_FID_$direct.Bool.to_u32`. Continuation
k.11548 changes 83 → 93 instructions with the same frame growth and a direct
Bool.to_u32 call. The previous forms publish another runtime continuation; the
new forms compose the helper calls and accumulation locally. Whole-path cost
cannot be inferred by comparing either single wrapper's instruction count:
the removed dispatch/continuation work must also be accounted for.

Unicode therefore has a concrete composition tradeoff witness in addition to
relocated unchanged H workers. It remains unknown whether these changes explain
the flagged +5.0595% timing. Keep that result and its dispersion flag visible;
this audit supplies no basis for correcting it, claiming layout causation, or
retuning the selected compiler.
