# Independent lexer trace interpretation

Data-only analysis of all four completed trace roles. Raw receipts are retained as `selfhost/build/phase57/trace-analysis01/report.json` and `trace-interpretation01/budgets.json`. The approved analyzer ran
on CPU0 and passed four rows; no compiler request or trace was launched here.
[Compact budgets](evidence/v8-budgets.json) independently recomputes window wall durations, GC pause sums,
event counts and typed-stage medians, pinned to the trace and CPU analysis.
These are instrumented observations, not clean speed ratios.

| Role | API load ms | First request ms | Later requests | Later median ms | Later total ms | Later GC pause ms | Later deopts |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| typescript | 0.04 | 415.14 | 32 | 119.68 | 4315.97 | 883.5 | 103 |
| raw | 52.82 | 3463.87 | 3 | 2126.64 | 6530.21 | 214.1 | 3 |
| source | 62.57 | 1856.06 | 6 | 896.74 | 5512.84 | 261.0 | 2 |
| direct | 105.96 | 3256.62 | 4 | 1604.74 | 6518.37 | 257.1 | 2 |

Bend-image later request windows attribute 3.28% (raw), 4.73% (derived B1)
and 3.94% (direct B2) of recorded wall totals to logged GC pauses. TS has
20.47% in its much larger 32-request window. Roles have different request counts;
whole-run GC/event counts cannot rank per-request costs. These pause fractions
are direct log accounting, distinct from CPU sample-weighted or count-weighted
GC shares. Logging overhead and different sampling windows prevent treating
any of them as an uninstrumented CPU fraction or causal speed estimate.

## Absolute typed-stage budgets

| Later-stage median ms | Raw B1 | Derived B1 | Direct B2 |
| --- | ---: | ---: | ---: |
| Discover (including parsing/cache/graph completion) | 408.0 | 254.0 | 388.5 |
| Check book (composite) | 1021.0 | 347.5 | 740.0 |
| Reachable-definition prune | 23.0 | 4.5 | 10.0 |
| Annotate | 15.0 | 5.5 | 10.5 |
| Direct runtime dependency prune | 80.0 | 38.5 | 78.5 |
| Runtime layouts | 16.0 | 7.0 | 11.5 |
| Emit library | 624.0 | 230.5 | 312.5 |

Stage medians are independently computed and do not necessarily sum to the
median whole request. Markers use millisecond wall clocks; all recorded events
fit their assigned request windows and none goes backwards. The separate
load-and-elaborate interval is zero here because discover already completes it.
Checking includes specialization and subsequent preparation; dependency pruning
renders definitions to discover references, and emission includes assembly and
runtime/module reads. Nested ABI costs must not be added to these totals.

## Tiering and exact CPU joins

First request deoptimizations are raw73, derived72 and B263, versus only3/2/2
in the respective later request windows. Three warmups still log7/12/7 deopts.
First-request completed compilation events number1263/1159/1273, and later
windows still log738/1073/946 completions. Completion counts can include different
tiers/phases and do not quantify exclusive compiler CPU time; concurrent work
may start before its completion's assigned window. Three warmups therefore do
not certify settled tiering. OSR preparation is a tier transition, not by itself
a harmful repeated failure. Many reasons are unknown; preserve them as unknown.

The authoritative CPU analysis joins source positions to exact image spans:
raw `String.cmp`/`String.cmp.fin` occupy14.10%/13.20% sampled weighted self;
derived `run_loop`20.19%, `sk_char`4.17%, `validateSpanCache`4.94%; B2
`run_loop`15.15%, `$jd$kt`9.28% and `jd_primitive_table`2.93%. Those are
sampled views, not shares reconstructed from trace counts. Inclusive frames
overlap, and the large check-program diagnostic frame is not pure checker work.
Raw cmp/fin, B2 kt/primitive table and run_loop show optimization activity in
the first-request window; the trace logs no later-window deopt for these named
hot functions. This weakens a repeated-deopt explanation, but proves neither
ideal optimized code nor stable hidden classes across other workloads.

## Next discriminating inspection

Direct B2's106ms API load is materially smaller than its1.605s later request
median in this run. This does not isolate lazy parsing or explain cold first-use
cost: first request is3.257s, contains extensive tiering, and source/type work
also changes with first use. A larger module is not evidence that all its source
is eagerly compiled. The existing stage/CPU evidence points first to exact
filtered assembly for B2 kt and run_loop, or derived sk_char, then source-level
primitive dispatch/continuation work. Inspect root-selected hot functions only.
Do not infer that all JIT is bad, disable tiers as an optimization, or issue a
global graph/inlining dump. Clean request measurements remain the latency oracle.


## Exact kt bytecode and optimized-code follow-up

Both frozen worker-v3 requests pass their full prepared lexer-output byte checks
(first request, three warmups and one later request). Raw logs are
`selfhost/build/phase57/kt-inspection01/job-{source,direct}/stdout.log`;
[compact dump identities](evidence/kt-inspection.json) pin them and both images.
Only exact `$kt$`/`$jd$kt` bytecode and optimized-code filters were enabled.
These runs are diagnostic, not clean performance measurements.

| Observed emitted kt code | Derived B1, plain names | Direct B2, computed constant names |
| --- | ---: | ---: |
| Bytecode length | 38 bytes | 103 bytes |
| Interpreter registers / frame | 1 / 8 bytes | 7 / 56 bytes |
| Object boilerplate descriptions | One, `[18]` | Two, each `[2]` |
| Dynamic property-definition bytecodes | Five named | Eight keyed |
| TurboFan instruction bytes | 532 | 788 |
| Deoptimization metadata points (not executed events) | 6 | 9 |
| Safepoint entries | 2 | 5 |

Representative exact bytecode excerpt (addresses omitted; operation text retained):

```text
B1 @ 0:  CreateObjectLiteral [0], [0], #8
B1 @ 7:  DefineNamedOwnProperty r0, [1], [1]
B1 @31:  DefineNamedOwnProperty r0, [5], [9]
B2 @15:  CreateObjectLiteral [0], [0], #41
B2 @25:  DefineKeyedOwnPropertyInLiteral r5, r6, #0, [1]
B2 @73:  CreateObjectLiteral [7], [11], #41
B2 @77:  DefineKeyedOwnPropertyInLiteral r5, r6, #0, [12]
B2 @86:  DefineKeyedOwnPropertyInLiteral r5, r6, #0, [14]
B2 @95:  DefineKeyedOwnPropertyInLiteral r5, r6, #0, [16]
```

The B1 boilerplate already contains the literal `removed: Nil` and zero origin
fields. B2 starts its KTerm literal with only the static `$` field, then adds
computed properties; its Nil literal is created separately in bytecode. This
is a counterexample to assuming constant computed names necessarily canonicalize
to the same constructor code as plain literal names in this pinned V8.

The difference survives TurboFan in this execution. B2 writes successive
`Map[96](HOLEY_ELEMENTS)` identities as fields are added, followed by main-path
runtime entry calls at the `removed`, `originBegin` and `originEnd` definitions.
Exact bounded assembly excerpts (offsets and instruction operands retained):

```text
B1 +db:  movq [r8+0x47],rdi        ; removed Nil field
B1 +df:  movq [r8+0x4f],0x0       ; originBegin
B1 +e7:  movq [r8+0x57],0x0       ; originEnd
B2 +a4:  movq [rcx-0x1],r11       ; next Map[96]
B2 +a8:  movq [rcx+0x1f],r9       ; tag value
B2 +c4:  movq [rcx-0x1],r12       ; next Map[96]
B2 +c8:  movq [rcx+0x27],r11      ; name value
B2 +1e7: movq r10,0x1aa2980       ; CEntry_Return1_ArgvOnStack_NoBuiltinExit
B2 +1f1: call r10                 ; removed site, bytecode77
B2 +22e: call r10                 ; originBegin site, bytecode86
B2 +26b: call r10                 ; originEnd site, bytecode95
```

The runtime entry's concrete callee symbol is not named in the dump; the source
positions, key constants and deoptimization metadata bind these calls to those
property-definition sites. Do not invent a callee name or treat metadata deopt
points as executed bailouts. Other argument checks and the out-of-line
stack/allocation slow paths occur in both versions.

Both optimized versions reserve a `0x90` (144-byte) young-space allocation batch
in this specialization. The visible allocation sequence includes a heap number
for the numeric id field, a Nil object and the KTerm object. This is neither an
allocation-free constructor nor evidence of greater B2 allocation bytes in this
specific dump. It does not establish all runtime input representations or all
allocation slow-path behavior. The trivial `for(;;)` and argument alias moves
have no surviving loop/alias-copy sequence on B2's optimized return path: their
presence in emitted source alone is not evidence of optimized loop overhead.

Each dump reports **zero inlined functions inside kt**. That says nothing about
whether callers inline kt; filtered kt code does not inspect caller decisions.
The logs prove a code-shape difference, not its share of the 9.28% CPU-hot kt
cost and not a clean constructor or whole-request speedup. A syntax-only saved
counterfactual with exact output/semantic controls and fresh clean request timing
would isolate the proposed change. General emission must preserve computed
own-property semantics for special names such as `__proto__`; blindly converting
all names to plain object-literal fields would change the language contract.
