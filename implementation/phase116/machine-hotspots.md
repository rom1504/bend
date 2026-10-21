# Phase116: current sampled machine hotspots

Read-only follow-up to root's Phase116 runs. No targets, compilers or new machine
products were executed for this audit; existing ELF disassembly and sample files
were inspected. Profiles are physical instruction leaves, not inclusive call
stacks. QBE text symbols with no ELF size use the next text symbol as a boundary;
raw PCs remain authoritative. Sampled clocks are not performance measurements.

## The important correction to the old ranking

**Typed array regions and the shared generic native runtime boundary now have
stronger measured support than tree Stat-result scalarization.** Tree's scan is
only3/930 named leaf samples; warp workers dominate the observed Bend leaf work.
That does not measure scan's inclusive ctor/take cost, but it removes the basis
for treating Stat construction as the demonstrated dominant tree bottleneck.

The ordinary clean three-round medians, milliseconds for identical case-specific
repetitions, are:

| Case | Upstream C | Self-hosted C | Direct QBE | Upstream JS | Self-hosted JS |
| --- | ---: | ---: | ---: | ---: | ---: |
| variation-local-fold-128-0 | 201 | 201 | 2364 | 3900 | 4314 |
| tree-bitonic | 200 | 269 | 1332 | 466 | 453 |
| lexer | 186 | 201 | 1371 | 954 | 994 |

These are three selected cases, not the Phase114 broad45 score. Mature C is a
particularly useful reference: its array loop is already at upstream speed,
and its lexer is close, whereas QBE retains a much larger gap.

## Fold: direct evidence of representation overhead

Pooled QBE samples:644/907 (71.0%) in `$product.fold.loop`,197/907 (21.7%)
in `term_drop`,57/907 (6.3%) in `p111_rt_op`. Both8ms and13ms periods agree on
this distribution. Upstream C places855/919 samples in its fused `spin_18` and
64/919 in `term_drop`; self-hosted C places840/900 in the fused batch loop and
60/900 in `term_drop`. These leaf proportions locate work; comparing proportions
alone does not estimate absolute savings.

The current QBE machine loop at `0x405950–0x405b54` does all of the following:

- Extracts ARR tag, checks dynamic/static location, decodes array class, constructs
  the mask and addresses on each iteration (`0x40596a–0x4059d8`).
- Reads a64-bit Term and checks its tag is scalar (`0x405a27–0x405a42`).
- Stores flat get-result words into scratch and reads the scalar back through a
  merged path (`0x405a87–0x405aa7`).
- Constructs arguments for a put fallback even on the fast path, rereads/checks
  the old cell, checks the replacement scalar and stores64bits
  (`0x405ab4–0x405b44`).

Samples land repeatedly in these exact fast-path instruction groups. The presence
of fallback calls in the disassembly does not mean they execute on each iteration.
The57 `p111_rt_op` samples instead concentrate in the array initialization fill
loop: `0x417cb7` stores the initial word, `0x417cba` advances the pointer, and
`0x417cc1` repeats. They are not evidence that array get/put falls back57 times.
The destructor hot points `0x415bef/0x415bf3` belong to generic per-element Term
traversal after the finished array is sunk.

Upstream's actual hot loop `0xa730–0xa760` carries the base/mask as invariants,
uses **32-bit elements with scale4 addressing**, directly adds/xors/stores, and
unrolls two iterations. Current QBE uses **64-bit Term cells with scale8** plus
the checks and scratch joins above. This is a representation/semantic-fact gap,
not merely a claim that QBE has a worse register allocator. Clang additionally
specializes/unrolls initialization and the kernel.

The best small experiment is an explicit checked scalar-array region: preserve
array element kind, owner/handle identity and shape through the loop; prove
get/put cannot replace the owner or introduce owning elements; hoist invariant
checks and remove redundant scalar checks/scratch joins. Then consider packed
U32 cells and scalar-array destruction. Representation changes need a real ABI
adapter and fallback at escaping/generic boundaries; a U64 machine word alone is
not an array-ownership certificate. An initial facts-only experiment can isolate
how much gain exists before changing layout.

## Tree: constructor extraction and runtime transfer, not allocator folklore

QBE's930 pooled samples include164 (17.6%) in `p111_rt_take`,164 (17.6%)
in `p111_rt_ctor`,140 (15.1%) in libc,87 (9.4%) in the local recursive
`$direct.warp`,41 in `warp_leaf` and23 in `warp_zip`. Scan itself has only3
named samples. The C references concentrate leaf samples in warp/flow workers;
inlining means their allocation/ownership work can live under those names.
Do not interpret the absence of a helper symbol as absence of its semantics.

Actual helper hotspots are more specific than call counts:

- `p111_rt_ctor:0x41a1fb` updates the allocator freelist after taking a cell.
  The helper recomputes class from arity (`bsr`, shifts), validates CID/arity,
  and loops over fields to seal/check them. Its generic API loses constant
  constructor/layout/field facts available at the source match/construction.
- `p111_rt_take:0x41a454` copies a field on the **shared RFC wrapper path**.
  The preceding `0x41a425–0x41a43a` loads the wrapper count and checks uniqueness.
  Other samples hit metadata checks/prologue. This directly argues against
  assuming all ordinary tree takes are uniquely owned; exact constructor identity
  and ownership uniqueness are separate facts.
- Mapping the libc PCs through each run's recorded mappings gives83 samples in
  the fill implementation around `0xa3d00` and57 in the copy implementation
  around `0xa3930`. These are small memset/memcpy-family implementations, not
  malloc. The actual instructions broadcast the fill byte into XMM registers or
  copy one/two words/short vector blocks.

`p111_set_regs` in this exact binary calls `memmove@plt` at `0x4170fb` and tail
jumps to `memset@plt` at `0x4170ed`, clearing the remainder of the logical register
bank on each transition. This is a concrete possible source of those library
samples, but a leaf-only profile cannot prove all140 belong to that caller.
Other copy/clear sites must be accounted for before claiming its inclusive cost.

The next general transformation should preserve known constructor/layout/field
facts into owned extraction and constant-size construction, including correct
shared/static fallback, and inspect the **warp path** first. Expand direct
closed regions or optimize transport only where measured call paths retain that
boundary. Stat scalarization remains plausible, but should be validated as a
small mechanism witness rather than sold as tree's main runtime opportunity.

## Lexer: transport and construction matter before isolated tagged-state work

QBE919 pooled samples:218 (23.7%) in libc,73 (7.9%) take,71 (7.7%) dispatcher,
64 (7.0%) ctor,42 jump,40 special-take and34 set-regs. Its `product.lex` and
`product.step.at` account for43 and31 direct leaves respectively; generator/
expand/continuation work is substantial. These are separate exclusive leaves;
no caller assignment is implied for runtime helpers.

All218 libc hits normalize to the same fill/copy implementations as tree:
144 fill and74 copy. That makes transport a cross-program mechanism, whereas
flattening tagged Mode would affect only a narrower part of the computation.
Its exact inclusive benefit remains unknown. A bounded caller-category counter
or carefully authenticated direct transition variant would resolve that question
more decisively than another broad campaign or a blanket no-zeroing change.

The mature C lexer spends277/905 leaves in `product.step.at`,257 in direct lex,
177 in gen.at and116 in rfc_wrap. It is already6.82× faster than QBE in this
screen, despite retaining some of those same source algorithms and allocations.
The opportunity is composition of those algorithms with efficient ownership and
control transfer, not replacing the source algorithm with a benchmark shortcut.

## Ranked next experiments from this evidence

1. **Certified scalar-array loop facts**, then typed layout/destruction if needed.
   Strongest isolated expensive region with a clean upstream machine reference;
   test transfer to local-pair/editdist before broad promotion.
2. **Preserve known constructor and field facts through owning recursive paths**,
   including shared cases. Tree warp and list/map should supply independent
   workloads; constructor helper specialization alone may still be incremental.
3. **Attribute and remove small register-bank copies/clears across closed calls**.
   Cross-program15–24% libc leaf share makes this worth investigating, but even
   eliminating that measured category alone cannot explain a5× overall win.
   Needed captures and inactive-register invariants remain correctness obligations.
4. **Flat recursive results and tagged-state representations** only after their
   execution coverage is measured. The earlier scan/Stat story is weakened, not
   refuted; leaf sampling cannot attribute all its generic-helper time.

No new improvement is demonstrated by this note. It narrows which changes deserve
implementation and which static opportunities should move down the queue.

## Reproducible identities

The following files were read after their individual captures completed; the
whole profiling campaign may still have been running when this note was written.
The analysis derives directly from those immutable per-capture records and exact
ELFs. A report hash establishes identity, not correctness by itself.

| Artifact | Bytes | SHA256 |
| --- | ---: | --- |
| `selfhost/build/phase116/clean01/report.json` | 189877 | `39abbbd8fc4c451aa17f0679a4892d987c0251f2bd77247f6e998b26b8071d80` |
| `selfhost/build/phase116/native01/variation-local-fold-128-0-qbe-13000.analysis.json` | 13382 | `856fb69250cc8d605a857860c08bc1d7b1e848565d3bd6461ce3c456e775101b` |
| `selfhost/build/phase116/native01/variation-local-fold-128-0-qbe-13000.samples` | 8102 | `ec4e963f1f1c1fcbcb66e879ba0ff40690a5cb9a4d18062eb1eca1acd4849789` |
| `selfhost/build/phase111/p114-final45-variation-local-fold-128-0-build/program` | 211096 | `3565448318a953da702d8504198ba29b665d764f2e4bdc27db293f6ef1c341c9` |
| `selfhost/build/phase116/native01/variation-local-fold-128-0-qbe-8000.analysis.json` | 15204 | `d4a7cbb6edc8b39c8a96355d63ae11bf2d0e03f5a9c96982f983d0fe78d608ed` |
| `selfhost/build/phase116/native01/variation-local-fold-128-0-qbe-8000.samples` | 9575 | `6fd8a52bedd0132203e132cbc78422cd09f82f90760f7b287e581a334dd35f31` |
| `selfhost/build/phase116/native01/variation-local-fold-128-0-upstream_c-13000.analysis.json` | 8421 | `aa3a3b396189615892ffeb2ee5801ed60a9330872dd3b5ad6cdd21ac29559fe4` |
| `selfhost/build/phase116/native01/variation-local-fold-128-0-upstream_c-13000.samples` | 10154 | `ca7173aedecc89697de4bb0325be4a1e86d33b52fbc924c372507048919567d1` |
| `selfhost/build/phase93/broad01/variation-local-fold-128-0/upstream.program` | 58864 | `1a4534c5b56fd19d83688dd9f4dbd7aae2c34c0e729daefa97186744c4ac9517` |
| `selfhost/build/phase116/native01/variation-local-fold-128-0-upstream_c-8000.analysis.json` | 10467 | `acb8dc74023588f8e1cf1668a0649b5170956d15645716758578dfad8725e127` |
| `selfhost/build/phase116/native01/variation-local-fold-128-0-upstream_c-8000.samples` | 12737 | `298db65c921bb20c180fa3568b4f2d4e955f89aa36764e9004be7ff918e9a654` |
| `selfhost/build/phase116/native01/variation-local-fold-128-0-selfhost_c-13000.analysis.json` | 10651 | `ad22e7932500456917324cdf80d05196a2ef136c10ec36d287d71c93ee9f91e1` |
| `selfhost/build/phase116/native01/variation-local-fold-128-0-selfhost_c-13000.samples` | 10038 | `74e7c47d4fa039ec913c389822bc904f63106363afb681227182ac61999591ed` |
| `selfhost/build/phase99/phase102-runtime-products04/variation-local-fold-128-0/candidate.program` | 94512 | `42b7a40269ea74ccae4d64940ef1c7d69c189a21b1c05cb5e5fd6396b84ef5fe` |
| `selfhost/build/phase116/native01/variation-local-fold-128-0-selfhost_c-8000.analysis.json` | 11407 | `29be340025080669789793cc6a0e1755504151f1ef2695f1a88e3716b8a814f2` |
| `selfhost/build/phase116/native01/variation-local-fold-128-0-selfhost_c-8000.samples` | 12819 | `6e6c9f3a4a47e262b54efa35197735f0432b77eb486debaf519c9bfdea34c734` |
| `selfhost/build/phase116/native01/tree-bitonic-qbe-13000.analysis.json` | 40735 | `ec42c16fd95e292c09d4fadced86531799810524aa2068b4415916bded949f30` |
| `selfhost/build/phase116/native01/tree-bitonic-qbe-13000.samples` | 8495 | `af28d294bf1b3826f7566ca27fa66b8af709882a59a0fd6c24ca34947bed9df4` |
| `selfhost/build/phase111/p114-final-screen01-tree-bitonic-build/program` | 235000 | `462d2a44cbffcbd81236ccdd90575350d86b7a7b28f8fcd842305d91159e7a96` |
| `selfhost/build/phase116/native01/tree-bitonic-qbe-8000.analysis.json` | 51097 | `dd71eec5e5f7c7b9cfdc057d5453fd1e108247aa488177b47900fff99708de9f` |
| `selfhost/build/phase116/native01/tree-bitonic-qbe-8000.samples` | 10102 | `c67af444b123b9bb703ca327dcf49c6db237fcac2671018138c8b41d4af3a727` |
| `selfhost/build/phase116/native01/tree-bitonic-upstream_c-13000.analysis.json` | 23644 | `e430062661eeaa1e3416772b31e4e55fb901c1ae9442144e4b0c10b861700e24` |
| `selfhost/build/phase116/native01/tree-bitonic-upstream_c-13000.samples` | 9889 | `75a996c94c691bae5065499f97eccbd22955bd2f2278fe8a41380f7bcf00f302` |
| `selfhost/build/phase93/broad01/tree-bitonic/upstream.program` | 67952 | `5afd7bca608250b93f0f701d566235c1e5c8ba2ea1ccba8c09ea34870b900a88` |
| `selfhost/build/phase116/native01/tree-bitonic-upstream_c-8000.analysis.json` | 30566 | `2b5a3bda986d52265af612b85e25d04ddb62700a320bc0d0a4ca4c978f05142e` |
| `selfhost/build/phase116/native01/tree-bitonic-upstream_c-8000.samples` | 13216 | `b2a28825772cb019e472221d52ee409ea1bf54d7364c873c538db732531bde65` |
| `selfhost/build/phase116/native01/tree-bitonic-selfhost_c-13000.analysis.json` | 34924 | `34bd8b1f82a3f9563dca93d885a9e334c417412084b277c78533892e997657f3` |
| `selfhost/build/phase116/native01/tree-bitonic-selfhost_c-13000.samples` | 10020 | `8346c59515714feeb16888eea37f89d69d6a117dc306c161caa4180074c1dcf8` |
| `selfhost/build/phase99/phase102-runtime-products04/tree-bitonic/candidate.program` | 116536 | `61a0db20ef32ec71f52e2caf7e543d6f5dd66bc2b6edd6d856b53cd4a221080f` |
| `selfhost/build/phase116/native01/tree-bitonic-selfhost_c-8000.analysis.json` | 40852 | `b22cb4a083fa3bfc49e815e24fac2592121e4bb9d6ee1c606ec8c40de6bf2b61` |
| `selfhost/build/phase116/native01/tree-bitonic-selfhost_c-8000.samples` | 12931 | `a4bbbb63318ec0fc91600b86f3c1c47e8e29ec20a003f9f308c6968bacdd7098` |
| `selfhost/build/phase116/native01/lexer-qbe-13000.analysis.json` | 38070 | `f8f88e772d5594aa96b4f3d8b4f7a7a9624b8a00277f67636e0a8e222438cf61` |
| `selfhost/build/phase116/native01/lexer-qbe-13000.samples` | 8518 | `d5f49eff452bdc2ad15607557abe9fb61242eda44c2ac9827733097ac407d118` |
| `selfhost/build/phase111/p114-final-screen01-lexer-build/program` | 250008 | `87ee5d645aab3bb40a3fe986837474841e275f21dbe90c77b79a82480130093e` |
| `selfhost/build/phase116/native01/lexer-qbe-8000.analysis.json` | 49661 | `76213cc170e9b9fc319e3718d1073d926d3dc06f5ba553d7b01380790470bb92` |
| `selfhost/build/phase116/native01/lexer-qbe-8000.samples` | 10386 | `f8ea5791bc623d239571ca09a02cf7f3acc091a60cdaf5a95595702f862d43a5` |
| `selfhost/build/phase116/native01/lexer-upstream_c-13000.analysis.json` | 25052 | `0d26461cbce415b4adcaa5a96333a7b254e6157e1cc81ac3e62b20f9e503df73` |
| `selfhost/build/phase116/native01/lexer-upstream_c-13000.samples` | 9880 | `b4a3ed820a5e35b151d20836b9fbc4b4213b3996d30c2ae2b33e9dfe2714cb23` |
| `selfhost/build/phase93/broad01/lexer/upstream.program` | 65584 | `8c1802ee57b2469c7eb3cd8220b3a32c3e499baf3a167009a0143d6fce9d10f4` |
| `selfhost/build/phase116/native01/lexer-upstream_c-8000.analysis.json` | 30601 | `0cc358b7983a53c2c1988cca32a815642a7c66553c4cdd5b98e5a7efdab12b12` |
| `selfhost/build/phase116/native01/lexer-upstream_c-8000.samples` | 12713 | `928ec0579f54b61b450449e521e92570e9c57a420a334644c5b83be26a22940c` |
| `selfhost/build/phase116/native01/lexer-selfhost_c-13000.analysis.json` | 30624 | `387608861c90172605a3fb4e1862f89161638e4e847f5e41300f29e34dc3897e` |
| `selfhost/build/phase116/native01/lexer-selfhost_c-13000.samples` | 9972 | `92c3d73f70d475733ef11d44a3b671847a255f205a8795e2f4d7f89c47b64cf3` |
| `selfhost/build/phase99/phase102-runtime-products04/lexer/candidate.program` | 113568 | `4f04e222b4e34fc8996288368217c861ac75c1ef50da0cd612a5163f12e1c8e7` |
| `selfhost/build/phase116/native01/lexer-selfhost_c-8000.analysis.json` | 40942 | `cce5c8237769c71e86f24667d5b5af3af96df3c371e610d8e2123f3acfbee219` |
| `selfhost/build/phase116/native01/lexer-selfhost_c-8000.samples` | 12740 | `4e64943960ca733bbc939631981f9aabe7e34e3a92882e04235324e79d4b74ad` |
| `/usr/lib/x86_64-linux-gnu/libc-2.31.so` | 1901536 | `d13f170ab30a0f91d9713e0c2196efa5fe0bc42f0f2737cf0e56380df8051159` |


## Completed-capture follow-up: map and the compiler itself

The root completed all48 native captures. This follow-up reads the final map
captures and the separate four-capture current N1 lexer-compilation survey.
It runs no targets and makes no new timing claim.

**Map transfers the tree mechanism.** Across824 QBE leaf samples, ctor has134
(16.3%), take120 (14.6%), libc173 (21.0%), work_loop35, set_regs27, jump26 and
return20. All173 libc PCs normalize through the recorded maps to the same short
fill/copy implementations:110fill,63copy. This is not a malloc hotspot.
`Map.bit.go` is the most sampled named Bend computation; generic helper samples
cannot be assigned exclusively to it. Clean medians are1965ms QBE,227ms upstream
C and143ms self-hosted C, or8.66× and13.74× respectively on this fixed case.
The faster C route still spends time in Map traversal and ownership; its inlining
changes where leaf samples are labeled.

Exact map machine PCs confirm the same generic overhead seen in tree:
`0x42f2ec` validates runtime arity, `0x42f32e/0x42f33b` tests/updates the constructor
freelist, and `0x42f594` copies a field from the shared RFC extraction path after
reading the wrapper count. This argues for carrying constructor/layout/field
facts through the IR while preserving the shared path, not a uniqueness shortcut.
Map and tree are therefore useful independent transfer checks for a general
owned-extraction or direct closed-call transformation.

**Compiler:** four complete zero-loss captures at8/13ms pool1082 physical leaves.
Each sampled lexer request emits the prior expected full QBE bytes. This checks
instrumentation transparency on that request; it is not a new compiler correctness
proof, full-self profile or attribution of every compiler stage.

| Current N1 leaf category | Samples | Fraction |
| --- | ---: | ---: |
| libc mapping |193|17.8%|
| `term_drop` |182|16.8%|
| `p111_rt_take` |120|11.1%|
| `p111_rt_ctor` |93|8.6%|
| `span_fade` |86|7.9%|
| `p111_rt_special_take` |30|2.8%|
| `work_loop` |19|1.8%|
| `p111_set_regs` |18|1.7%|

Of the193 libc samples,133 lie in the short fill implementation,59 in copy and
one elsewhere. The compiler therefore shares the array/tree/map transport and
ownership categories, while destruction/reclamation contributes more prominently.
The separate names above are exclusive instruction leaves, but they still do not
form a source operation's inclusive cost. Do not claim that a proposed observer
will eliminate every destructor, constructor or memset sample.

The actual current compiler QBE contains a concrete missing mature optimization
opportunity in `p111_FID_$direct.String.cmp` (full image byte offset70705328).
Its nonempty match invokes generic take on strings, returns reconstructed SCon
nodes and nested Tuple results on terminal branches, and jumps through the runtime
to continue comparison. `String.cmp`, `String.cmp.fin` and `String.cmp.rec` jointly
have41 named leaves (3.8%); their child runtime work is unlabeled by this profile.
A low exclusive share therefore neither proves nor disproves a large inclusive
cost. The decisive evidence is actual reconstruction of roots during a logically
observational comparison, coupled with the mature C observer machinery that can
retain those roots and inspect borrowed fields lawfully.

Reuse the existing structural/schema and ownership conditions from the mature
observer implementation: `selfhost/src/back/native/observer-{layout,emitter,
integration}.bend` and the Phase98 observer-permission work. A function-name match
or accepting arbitrary raw words would be insufficient. Preserve root ownership,
exact result shape, alias handling and character/order semantics; emit the borrowed
comparison directly in structured IR with ordinary fallback. First measure the
unchanged compiler lexer request plus unrelated String/Map applications. This
would test whether one general generated-code optimization also improves the
compiler, without another expensive full acquisition to discover the mechanism.

The updated strategic choice is now stronger: pursue typed array facts for the
largest isolated simple kernel, or owned observational/constructor/control paths
for cross-program **and compiler** transfer. Both have actual executed evidence.
The old blanket claim that an optimizing machine backend alone could close the
gap is unsupported: our structured lowering is demonstrably emitting extra
representation and runtime work before QBE sees it.

### Follow-up identity pins

| Artifact | Bytes | SHA256 |
| --- | ---: | --- |
| `selfhost/build/phase116/native01/coverage-map-churn-128-qbe-8000.analysis.json` | 54651 | `e1bbe8937ab355de7edaf7ba82c1fd4f1e52c338125ac59d6cd901cbb72dc4f8` |
| `selfhost/build/phase116/native01/coverage-map-churn-128-qbe-13000.analysis.json` | 41047 | `ec72555839bac137829661fbe9040b8de8f83b6693a4c3e75ffebab9ff09da73` |
| `selfhost/build/phase116/compiler01/1.analysis.json` | 47549 | `e97ac315df60e3feecc314969e028426c8e1f9f4a4f84f4e0485faf373f27454` |
| `selfhost/build/phase116/compiler01/4.analysis.json` | 31397 | `d2ce306f96ffa7c3586c7cbfa3915b44f94fbda53a3e984e12ee2cd0084e9596` |
| `selfhost/build/phase116/compiler01/2.analysis.json` | 34446 | `631415aa470a3cf2e50bc6e490bbcbc6a95c766d8a26cce7bcac58e5c80161ee` |
| `selfhost/build/phase116/compiler01/3.analysis.json` | 45007 | `a782d3fd3f672d55c83d1d2d743e915721b49d193f687fa21c62b1c4599edb5f` |
| `selfhost/build/phase116/native01/coverage-map-churn-128-qbe-8000.samples` | 9854 | `c442cd7e9e21caed5a8438fe7358b08b6f57e735f3c9ffa3f4188f4437f1813c` |
| `selfhost/build/phase116/native01/coverage-map-churn-128-qbe-13000.samples` | 8325 | `efcb29bcb9a8c9458fbebac0ec33e8582d83d3bebc162b249c718b91b02ed7ab` |
| `selfhost/build/phase116/compiler01/1.samples` | 8302 | `2954746a59d7d09aec3834df03a830773d13d2a04b2c4371b4201f69521ccb80` |
| `selfhost/build/phase116/compiler01/4.samples` | 7254 | `52190d9ea74737b31f5039143c7d88b46a898a3f7d64cb3340005db29654195c` |
| `selfhost/build/phase116/compiler01/2.samples` | 7284 | `96a13c0e7865fdbc03e671aba8b3f1aeb9cb72bf6e6fd3eedae09ef733015f46` |
| `selfhost/build/phase116/compiler01/3.samples` | 8391 | `2bee7d0061c1b6332b34c2b2ecc430682cbe178618a2f4362da1474d23311025` |
| `selfhost/build/phase116/compiler01/report.json` | 7726 | `8a8e7d91a43b0eb3d1451f1cb16d7ea88d0eca90c8f1e3973d4e821d626939e1` |
| `selfhost/build/phase111/p114-native-final02-n1/program` | 12226016 | `88b101fac67691a125ba3029c4a771542fc5bc3b2af7c5965ddbcb44399d8f8b` |
| `selfhost/build/phase111/p114-native-final02-full-emit/program.ssa` | 74220801 | `f1abc6d75d176e30d4528f796bd9c866b20964cc74248c929e6b51deb7c4024b` |
| `selfhost/build/phase111/p114-final-screen01-coverage-map-churn-128-build/program` | 365072 | `79f7cc5cd5e3375841f9c07bd720fa7b2cc467e9e419edc620dd03c215bfe0d7` |
