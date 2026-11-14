# Phase194 float definition-identity machine audit

The prototype reaches its intended numeric machine region. All three targeted XMM→GPR→XMM round trips disappear. Ray has useful reductions and a concrete allocator tradeoff: larger frames, plus four extra stack-memory instructions in `direct.isect5`. This is static evidence only; runtime and promotion remain separate decisions.

Compared final Phase193 `selfhost/build/phase193/budget-native45-02` with the six checked-API products in `selfhost/build/phase194/float-dev-build01`. Parent reports float-api02 checked and float-controls01 passing20 structural rows and28,880 observations on each emission route. This audit ran objdump/readelf and host metadata scripts only. Exact binary/.text hashes, sizes and per-function metrics are in [float-machine.json](float-machine.json); changed-function disassembly is preserved in [float-machine-witness.zip](float-machine-witness.zip).

| Region | Instructions before→after | MOVD instructions before→after | Explicit stack-memory instructions before→after | Frame bytes before→after |
|---|---:|---:|---:|---:|
| numeric `direct.p37.numeric` |90→86|15→9|7→7|2368→2384|
| ray `direct.pixel` |1612→1594|414→380|470→456|4064→4448|
| ray `direct.nearest.t` |626→602| unchanged |140→128|3008→3312|
| ray `direct.nearest` |875→858| unchanged |295→285|3280→3584|
| ray `product.nearest` |791→775| unchanged |211→201|3072→3376|
| ray `direct.trace` |2060→2060| unchanged |730→730|4320→4496|
| ray `product.trace` |1978→1978| unchanged |690→690|4288→4464|
| ray `direct.isect5` |221→213| unchanged |31→35|2656→2800|

Numeric's original pairs at0x4083f0/0x4083f4,0x40840f/0x408413 and0x40844a/0x40844e are replaced by direct XMM arithmetic/forwarding. The first multiplication now produces xmm2 and forwards via MOVAPS; the next subtraction also stays in XMM. The multiply feeding F32→U32 conversion no longer publishes to edi and reloads xmm0. Float arithmetic count/order is unchanged. The whole numeric .text shrinks16 bytes (function instruction encoding shrinks18 bytes; linked alignment accounts for the whole-section distinction). Its extra16 reserved frame bytes do not introduce extra static stack references.

Ray changes15 generated function bodies after ignoring absolute code addresses and resolving RIP-relative references symbolically. Besides the table, these include clamp01.hi/go, clamp01, fmax0, fl, isect.t/go2/go. Pixel removes17 adjacent transfer pairs (42→25) and34 MOVD instructions. Other gains include fewer XMM shuffles and improved stack forwarding in the nearest variants. Whole ray has94 fewer decoded instructions,34 fewer MOVD instructions and42 fewer explicit stack-memory instructions; .text shrinks464 bytes. These totals include linked alignment, are static rather than weighted by execution frequency, and are not a speedup estimate.

The adverse allocator effect is real machine work, not merely reservation: `direct.isect5` now stores a comparison result at `-0xa08(%rbp)` and the following decoded Boolean at `-0xa20(%rbp)`, where baseline kept them in rdi. Its static stack-reference count increases31→35. Fresh float identities enter existing whole-function GPR metadata; the experiment therefore changes GPR placement as well as XMM homes. Trace variants add176 frame bytes without removing instructions or stack references. Pixel's frame grows384 bytes and each nearest variant304 bytes. Whether these costs offset benefits requires the paired runtime screen; no compensating allocator tweak was made here.

Do not use total adjacent round trips as the sole score: ray's count only falls130→128, because several conversion-to-XMM paths now make an already-required XMM→GPR→XMM conversion sequence adjacent after deleting an intervening GPR move. Total MOVD instructions and function-specific comparisons distinguish this effect.

`editdist`, `lexer`, `local-pair`, and `tree-bitonic` have byte-identical entire .text sections against final Phase193. Their full ELF hashes differ, so this report does not claim complete binary identity. Normalization additionally sees main/_start changes in numeric/ray due to address/layout consequences; these are preserved in the witness and excluded from the generated-function count.

MOVD counts include memory-source MOVD instructions as well as register-bank transfers. Stack-memory counts include all explicit RBP/RSP memory operands, including LEA; they are not a precise spill count or dynamic memory-operation count. Changes were not tuned against timings or held-out data.
