# Constant-divisor arithmetic on the direct x86 path

The first experiment replaced a frontend fallback for scalar division and remainder. Four independently re-emitted current objects matched their production bytes exactly. The generated lexer still called runtime operation 19 on the fixed divisors 10 and 26. Instrumentation counted 2,633 and 4,578 such operations per work item respectively. [Earlier lowering](../quotient/rule.bend) · [Operation counter](../profile/count.py)

This experiment uses the same integer plan in the machine pass that already visits every typed instruction. Only a direct call to the exact runtime symbol can trigger inspection. Ten preceding instructions must establish the complete serial runtime call convention, its operation and arity, a full-width constant divisor store at offset eight, and identical aligned negative RBP displacements for the store pointer and the call buffer. Any intervening label, branch, write or other unmatched instruction closes the window. The rule uses no program names.

All argument setup and memory stores remain in the emitted sequence. The replacement reads the numerator's low 32 bits at the actual call site. It computes the result in RAX with R10 and R11 as caller-saved scratch registers. A power of two selects a shift or mask. A proven reciprocal selects a 64-bit product and shift, followed by a low-32-bit multiply and subtract for remainder. Zero, unproved divisors and other call shapes retain the runtime path. In particular, runtime remainder by zero returns the complete raw numerator.

The structured controls use the checked API to assemble a standalone object and compare both public operations against unsigned C arithmetic across full-width inputs. They check the two scratch words after each return and require fallback for a modified frame address, store width/offset, divisor, argument count, operation ID, symbol and intervening instruction. Additional full-program checks reuse the ordinary checked machine producer, actual current direct-object binaries, frozen C references, original stdout/count protocol, and legal variations of each input. [Machine rule](machine.bend) · [API preparation](prepare.py) · [Control generator](controls.mjs)

## Focused hardware result

The checked API emitted distinct direct objects for both programs. All 5,200 public division/remainder checks passed on the assembled fixture, together with 13 admission refusals. Three independent C input variations for lexer and four for record aggregation matched both direct products. The native producers and C reference each ran six measured samples on the original catalog input, using separate calibration and rotating their order. [Frozen timing and control recipe](quotient-machine-focused01-argv.json)

| Program | Candidate / original | Candidate / C | Rounds faster | Runtime operations removed per work item |
|---|---:|---:|---:|---:|
| Lexer | 0.96423 | 2.55960 | 5 of 6 | 7,979 remainders |
| Record aggregation 256 | 0.95556 | 2.71875 | 6 of 6 | 1,868 divisions and 1,646 remainders |

The counts use the second-minus-first repetition difference on a separately instrumented binary. The lexer removed exactly 2,633 remainder calls with divisor 10, 4,578 with divisor 26 and 768 with divisor 6. The earlier object-level test had changed zero of four programs. The focused late rule reached ordinary program objects and improved both measured workloads. Transfer to the composed portfolio and self-hosted native compiler is still unmeasured. [Counter recipe](quotient-machine-focused-count01-argv.json) · [Summary and round ratios](evidence/focused-summary.json) · [Replay evidence](evidence/focused-replay.tar.gz)
