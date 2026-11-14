# Remaining profiles: price the worker gap before another local optimization

Fresh Phase194 tree/map/lexer profiles do **not** establish one removable
parity-scale cost shared by all three. Their largest category is generated
worker execution. Map and lexer spend less absolute CPU in separately named
ownership/product helpers than QBE, while their generated workers cost more.
The strongest additional common boundary is closed-continuation resume
transport in tree and lexer; it covers about23% of those programs but less
than1% of map. Constant-remainder lowering is a separate smaller opportunity.

Root's `profile-remaining02` capture passed all outputs. Offline normalization
is `profile-remaining-plan01/per-invocation02.json`; exact assembly and53 initial
input pins, extended with C workers and the remainder witness, are retained in
`research/phase195/profiles/remaining-machine/`. No target ran in this analysis.

## Absolute costs and the four major physical categories

All values below are estimated CPU microseconds per invocation, obtained from
each role's one clean CPU observation and its own repetition denominator.
Startup, four warmups and output remain included. Generated means every
`_FID_` symbol, including C's `WL_FID_*`; that prefix is not scheduler overhead.

| Case / role | Whole process | Generated workers | Ownership/product helpers | Other runtime/dispatch/math | Allocation/reclamation helpers |
| --- | ---: | ---: | ---: | ---: | ---: |
| tree / x86 | 572.829 | 338.066 | 186.674 | 35.791 | 0 |
| tree / C | 168.742 | 168.742 | 0 | 0 | 0 |
| tree / QBE | 391.926 | 266.709 | 76.457 | 40.224 | 0 |
| map / x86 | 30.492 | 18.681 | 6.747 | 3.648 | 1.154 |
| map / C | 10.459 | 7.975 | 1.211 | 0.146 | 1.126 |
| map / QBE | 25.273 | 12.301 | 7.947 | 3.755 | 0.829 |
| lexer / x86 | 1056.529 | 677.296 | 244.005 | 119.192 | 16.036 |
| lexer / C | 386.236 | 341.581 | 44.655 | 0 | 0 |
| lexer / QBE | 831.858 | 463.652 | 271.222 | 82.507 | 14.477 |

Unresolved costs, excluded from these four named columns but retained in the
whole-process denominator, are tree x86/QBE12.298/8.536µs and map
x86/QBE0.262/0.441µs. C inlines ownership/allocation into its generated workers:
zero separately named helper samples is **not zero ownership or allocation**.
These categories cannot measure equivalent semantic work or isolate call costs.

The candidate tree's largest helpers are ctor2 95.330µs and take2 85.322µs;
QBE take2 is72.097µs and ctor2 has no delivered samples. In map, candidate
take2/ctor2 are2.603/1.635µs versus QBE3.398/1.962µs. Lexer candidate
take2/ctor2 are140.187/31.741µs versus QBE159.248/52.015µs.
Consequently a claim that identical helper instructions are uniformly slower
would contradict the observed map/lexer absolute shares. Generated caller
plans, selected/inlined operations, input ownership paths and sampling can
change these distributions; no dynamic helper invocation counts were recorded.

## Strongest new common witness: closed-continuation resume transport

Tree's exact `p114r_FID_$direct.warp` costs121.622µs versus QBE63.499µs;
lexer's `p114r_FID_$direct.gen` costs239.542µs versus QBE91.091µs.
Their final allocation diagnostics already admit the joint path at182 and130
rows, respectively. C's separate generated warp/gen leaves cost26.739/25.753µs,
but its inlining distributes work among other workers, so those are not matched
inclusive costs. Candidate total H-worker shares are22.71% tree,22.67% lexer
and0.99% map. This is a cross-family candidate, not suite parity.

Actual x86/QBE worker sizes are557/301 instructions for warp and360/150 for gen.
These totals include alternative paths and are not executed instruction counts.
The exact hot x86 resume path repeatedly loads `state+16` before each captured
word after the same pop. Lexer resumes four captures; tree resumes three.
The source factory `x192h_case_prefix` emits a pop followed by separate
`x192h_restore` stack-get calls. Late expansion turns each get into its own
state-SP load, after earlier ordinary facts have run. The machine has real
repeated loads, capture-home publications, mode/result transport and a branch
back through the mode dispatcher. QBE retains the SP/address across capture
loads. Sampled PCs include lexer0x411d43 and tree0x411f03, both repeated SP
loads; these locations are not identified memory stalls.

**Cheapest falsifier, not implemented:** within the already certified H-case
factory, snapshot the post-pop SP once and load every capture from that same
snapshot before ordinary optimization/allocation. Preserve the exact FID pop,
capture pop, capture order, zero pop-status binding and result binding. Do not
carry the pointer across a call, stack mutation, dispatch or unknown escape.
Use the existing deep-recursion/multiple-capture/alias controls, then require
the actual tree/lexer resume blocks to lose repeated SP loads without new
caller spills. Measure those two complete ordinary programs before broadening.
The larger direct descend/unwind-label representation is a separate hypothesis.

Do not repeat Phase192's scoped-frame-call-only proposal as if untested:
`scoped-frame-machine-work.md` already records removing those calls while
leaving transport and growing lexer. Current `rt_frame` leaves are only
4.241µs tree and9.092µs lexer. Removing the call alone cannot explain the
worker gap. Nor may the whole23% H-worker share be called removable overhead.

## Separate primitive gap: constant unsigned remainder

Lexer has57.034µs (5.40%) in `p111_rt_op`; QBE has no samples in that leaf.
The hottest current runtime PC is0x41cd21, the remainder-result move after
`div ecx` at0x41cd1f. Source `ident`, `num` and `expand` use U32 remainder by
26,10 and6. This is a concrete general constant-divisor opportunity, with
prospective decimal/text/compiler transfer, not a benchmark-specific rewrite.
Its cheap falsifier is one bounded literal-denominator lowering through the
existing typed operand contract, independent full-width edge oracles, and
actual removal of those runtime call sites. Divisor-zero behavior, truncation,
high bits and reserved-register clobbers must retain their original semantics.
No implementation or broad benefit is established;57µs includes required
arithmetic and excludes caller work, so it is not a removable-time ceiling.

## Negative evidence and limits

The hot editdist function is `p113d_FID_$product.row`, placement99/original108,
with32 joint candidates. The similarly named167-row `p117v` fallback is
unsampled. Economics' regional-overlay census finds only two eligible local
names in the hot owner, versus59 in the fallback: the latter is not hot-loop
coverage. Actual x86/QBE/C inner-loop windows contain75/42/26 instructions.
All still implement four array reads and one write; C still masks indices.
Thus new cross-iteration array forwarding is not an explanation for the existing
C gap, though it could be a separate future optimization.

All nine remaining pools are adequate with638–678 samples, both periods,
zero rejected captures and zero loss.
Minimum sampled-thread CPU coverage is99.99940%. Unknown weighted shares are
tree2.147%/0/2.178%, map0.860%/0/1.747%, lexer0/0/0 (x86/C/QBE).
Individual captures remain below500; preserve original `profilesUsable=false`.
Sampled/clean ratios span0.9696–1.0307. The maintained pool policy admits these;
the stricter historical zero-unknown condition fails native tree/map.
No confidence intervals, causal speedups, dynamic calls or stall counts follow.
