# Phase85 SCC bytecode and trace findings

Offline analysis of completed root-run `bytecode01` and `trace01`; no target was
executed by this lane. [Machine-readable evidence](scc-bytecode.json) binds the
raw logs, image, bytecode receipt and process guard by SHA256. Analysis ran on
CPU0. Image remains Phase82 `098320e8…`; runtime is Node24.18.0 / V8
`13.6.233.17-node.50`. The instrumented bytecode request passes exact C.

## The size-ceiling hypothesis is false for the exercised code

| SCC | Actual bytecode bytes | Interpreter registers | Interpreter frame bytes | Wide instructions / all |
| --- | ---: | ---: | ---: | ---: |
| `f_context_publish` | 20,700 | 685 | 5,480 | 3,339 / 4,305 |
| `f_context_grow` | 9,210 | 262 | 2,096 | 1,404 / 2,029 |
| `norm_cmp_loop` | 8,302 | 376 | 3,008 | 1,176 / 1,843 |
| `g_eval` | 7,554 | 397 | 3,176 | 1,059 / 1,655 |
| `f_lex_scanned` | 4,888 | 184 | 1,472 | 600 / 1,151 |
| `norm_eval_node` | 3,872 | 235 | 1,880 | 470 / 952 |

The maximum across all 2,153 printed functions is 20,700 bytes, well below the
60 KiB TurboFan bytecode ceiling. Seventy-nine of the 170 statically present SCCs
were exercised and printed; this does not size unexecuted lazy functions. Large
source bytes had overstated this concern. Raising the ceiling has no rationale
from this sample.

Register/frame sizes and wide encodings are real observations and better leads.
They are **interpreter** quantities, not measured TurboFan register spills or a
claim that each local remains live in optimized code. Mixed-role loop slots,
numerous lexical locals and context capture warrant examining actual optimized
code before choosing a lowering change.

## A concrete lexer context-capture mechanism

The five-state lexer has five `CreateBlockContext` sites and five `CreateClosure`
sites. The cursor state (case4) executes `CreateBlockContext` at bytecode3143,
initializes context slots and stores scanner locals **before** testing whether
its source string is empty. Expression-position IIFEs in that lexical case
capture locals even though the EOF choice runs only on the exit path.

The EOF choice is an immediate zero-argument arrow selecting the existing token
list or an added EOF token. At bytecode3228 V8 emits `CreateClosure`; at3236 it
emits `CallUndefinedReceiver0.Wide`. Source position641546 maps to image line12460.
In the lexer fixture's first request, the trace records a `wrong call target`
deopt at exactly3236. This is a generated IIFE call, not a user callback or a
wrong-map field load. Another first-request deopt on Functions65 occurs at2913,
a `String.is_empty` call in the comment state (source line12426).

The emitter deliberately creates these expression scopes in
`selfhost/src/back/js/direct/choices.bend:55,80` (`jd_choice_expr` and
`jd_choice_ordered_done`). A restricted IIFE-to-ternary diagnostic is therefore
meaningful: it tests a general choice-lowering mechanism without changing
compiler algorithms. Statement lowering is another eventual option, but it must
preserve ordered prefixes, lazy selected arms, lexical captures and tail context.

The subsequent exact-filter assembly run proves that TurboFan retains a context
allocation on the common cursor path; see the assembly evidence below. What
remains unproved is its complete-request cost and how much the mechanism
contributes outside the lexer. Bytecode allocation alone would not have proved
this optimized allocation.

## Cold optimization events, not hypothetical universal non-inlining

Only events between `request-start(call1)` and its matching `request-end` enter
the following table. Background job duration fields are not additive request
savings: they overlap JavaScript execution and each other, and tracing perturbs
execution.

| First request | Lexer completed TurboFan OSR job duration fields, ms | Normalizer insufficient-call-feedback deopts | Parser-publish completed optimization |
| --- | --- | ---: | --- |
| Numeric | 150.980 | 5 | None; 10 IC-changed delays |
| Functions65 | 166.795 | 1 | Maglev OSR; 6 delays |
| Lexer | 129.823 and181.289 | 5 | None; 16 delays |
| Map | 153.753 | 5 | None; 10 delays |

The lexer also completes Maglev OSR in each first request. Its loop backedge is
bytecode4880 (`JumpLoop.Wide` to0). Numeric's cold TurboFan job logs46 helper
inlining events into the lexer; this could expand optimization work, but is not
proof that inlining is a net loss.

Parser-publish does optimize in later calls: for example, the lexer trace's
call2 contains Maglev and TurboFan completions (the latter reports345.133 ms).
Thus "never optimized" would be false; the observed issue is cold timing and
feedback. Do not conflate later completion with the first-request metric.

Normalizer deopts in Numeric, Map and Lexer occur at the same five distinct
call sites:

| Bytecode offset | SCC state | Image source line | Actual call |
| --- | ---: | ---: | --- |
| 252 | 1, application | 2089 | `kid(term, 0)` |
| 558 | 2, annotation | 2107 | `kid(term, 0)` |
| 2265 | 7, reference | 2235 | `norm_apply(term, args)` |
| 2494 | 8, arguments | 2255 | `tg(term)` |
| 2939 | 9, match | 2299 | `kid(term, 0)` |

Offsets map via V8's printed UTF16 source positions into the exact image. These
are newly encountered call-feedback sites in different SCC arms, not evidence
of changing object maps. Splitting cold paths or controlling speculative tiering
might help, but must preserve stack-safe tail cycles. TurboFan already inlines
`tg`, `String.eq`, `dk`, `nm` and sometimes `lookup` into this SCC. The broader
claim that generic accessors cannot inline is contradicted by these traces.

## Filter caveat and next single target

The literal `--print-bytecode-filter=*$scc` is preserved in both process argv and
Node execArgv, yet accepts2,153 functions including `inspectWithMemo`. This is
not shell expansion. V8's filter convention supports exact names and trailing
prefix wildcards; its utility treats a leading `*` as accept-all. The observed
behavior is consistent with that implementation.
[Primary V8 filter implementation](https://android.googlesource.com/platform/external/v8/+/1db205cd1d12b375134fe0624620918c399c036a/src/utils/utils.cc).
Keep the raw evidence and failed selectivity; use an exact name next.

**Best next target: `$jd$f_95_lex_95_scanned$scc`.** Print only its optimized
code/selected IR, retaining request markers and resource caps. Determine whether
case4's context allocation survives, whether its slot loads/stores become spills,
and how much helper inlining expands the graph. Pair that evidence with a
hash-bound, disposable restricted-choice transform and exact C checks; only
then measure clean cold requests. This is more decisive than raising a disproven
size limit or rewriting all SCCs. The coordinating lane owns those target runs.

## Optimized assembly: allocation survives on the common lexer path

The completed `assembly01` exact-filter Numeric request passes exact C. Its
single printed lexer body is TurboFan OSR code, optimization109: 41,416 machine
code bytes, 12 distinct inlined functions, 263 deoptimization points and a
safepoint layout with 213 stack slots / 87 entries. These are observed sizes,
not evidence that each slot is a live spill or that every deopt point fires.
The JSON receipt pins the raw log (`e298e22c…`), process and result.

The state4 dispatch targets machine offset `0x1c7`. V8 first compares the source
against the empty string and materializes a boolean, then unconditionally:

1. Reads `Heap::NewSpaceAllocationTopAddress()` at `0x1f9`.
2. Checks available space and advances the allocation top by `0x50` (80 bytes)
   at `0x20e`/`0x212`.
3. Stores a `BLOCK_CONTEXT_TYPE` map at `0x21a`, its scope and parent context,
   then six captured scanner locals at `0x24c` through `0x283`.
4. Branches on the already computed EOF boolean only at `0x2a8`/`0x2af`.

The source-position table maps `0x1f9` to UTF16 position640863, at the cursor
case's entry, and maps the local initialization instructions into that case.
This is an actual bump-pointer allocation on the nonempty scanning path. It
survives optimization; closure escape elimination has not removed it. The
allocation-limit check reserves `0x88` bytes for combined allocation space, but
the context itself advances the top by `0x50`, so reporting136 bytes per context
would be wrong. Do not assign all six captured locals solely to the EOF IIFE:
the case contains more than one expression choice.

The inlined functions include `String.is_empty`, `String.eq`, `Char.to_u32`,
`f_ascii_space_code`, `f_cursor_add` and `List.reverse`. Inlining does occur;
the more precise concern is the resulting graph size, context capture and
speculative call feedback. This assembly provides the requested optimizer-level
evidence without requiring a large TurboFan IR dump.

## Bounded source-only falsifier

[`lexer-choice.py`](../../selfhost/tools/performance/phase85/lexer-choice.py)
accepts only the exact frozen image hash and transforms only the lexer SCC.
It recognizes immediate zero-argument arrows whose sole body is an `if`/`else`
tree with return-expression leaves, retaining condition evaluation order and
lazy selected-arm evaluation. It rejects declarations, other statements,
return/ASI newlines and overlapping edits. Four choices qualify; the fifth
contains declarations and remains intact. No whole-program transformation or
compiler algorithm change is proposed by this diagnostic.

Default invocation is a read-only preview. Optional output is restricted to a
new artifact inside `selfhost/build/phase85`, and existing files cannot be
overwritten. The preview records full before/after function text and individual
edits. The source scanner and transformer compile as Python; this lane ran no
target compiler or JavaScript image. Root owns syntax validation, exact output
checks, filtered assembly comparison and clean timing.

The candidate image hash is
`cf15ec8c1c3ae98ae5db7d8030570ef41bf8174a4f7a3ddba5fd51f69b5df888`.
The decisive checks are whether the common case4 context allocation disappears
and whether clean cold requests improve across several source classes. Neither
is implied by reducing four source-level arrows. If no useful request gain
appears, retain the evidence and reject promotion instead of expanding the
rewrite. If it wins, implement the equivalent general choice lowering in Bend,
then validate ordinary compiled-program behavior and all target outputs.

## Completed falsifier: allocation removed, promotion rejected

Root completed `choice-code01` with the exact candidate image and exact C pass.
The causal mechanism changed as intended. Candidate state4 jumps to machine
offset `0x185`, compares the source with the empty string at `0x193`, and
branches immediately at `0x196`. The original 80-byte context allocation is
absent; the nonempty path proceeds directly to the scanning calls. This rejects
the explanation that the experiment failed to remove its intended allocation.

| Lexer quantity | Baseline | Restricted choice candidate |
| --- | ---: | ---: |
| Bytecode bytes | 4,888 | 4,948 |
| Bytecode instructions | 1,151 | 1,128 |
| Wide instructions | 600 | 651 |
| Interpreter registers | 184 | 196 |
| Interpreter frame bytes | 1,472 | 1,568 |
| Bytecode block-context sites | 5 | 2 |
| Bytecode closure sites | 5 | 1 |
| TurboFan machine code bytes | 41,416 | 39,880 |
| Distinct inlined functions | 12 | 10 |
| Deoptimization points | 263 | 269 |
| OSR safepoint stack slots | 213 | 225 |
| Safepoint entries | 87 | 84 |

The two remaining contexts have a concrete source cause: the retained
declaration-bearing nesting-depth IIFE in state 2 (symbol scanning). A 48-byte
context at bytecode 1394 / machine `0x36bc` captures the source string
`$x16269` and nesting depth `$x16272`. A second 48-byte context at bytecode 2289 /
machine `0x43fd`, reached on the single-symbol branch, holds the two opening
delimiter predicates `$ord2` and `$ord3`. The retained closure is created at
bytecode 2554 and called at 2562, mapping to candidate source line 12389. The
restricted rewrite correctly left these declaration-bearing scopes unchanged.

The candidate has fewer machine code bytes but more bytecode bytes and larger
register/frame layouts. `f_ascii_space` and `f_ascii_space_code` were inlined
in the baseline printed body but are absent from the candidate's inlined list.
These differences show that removing closures changed more than allocation;
they do **not** isolate the cause of its net timing result. Interpreter register
growth and OSR stack slots still must not be presented as measured spill cost.

Root's clean comparison used three paired rounds, four sources and five calls
per process; all 120 emitted C results passed exact comparison. Ratios below are
candidate/control medians across the three rounds at the specified call number.
The JSON contains the raw timings and pins all 24 process-result receipts.

| Source | First request ratio | Fifth request ratio |
| --- | ---: | ---: |
| Functions65 | 0.9965 | 1.0469 |
| Lexer | 0.9831 | 0.8854 |
| Map | 1.0029 | 1.0601 |
| Numeric | 0.9978 | 1.2297 |
| Geometric mean | **0.9951** | **1.0485** |

The cold result is effectively null and the fifth-call aggregate regresses.
The Lexer fixture's later-call improvement is insufficient to promote a change
whose other classes regress. This is a successful causal diagnostic and a
negative optimization result: context allocation existed and was removed, but
removing it did not produce the required general compilation-speed improvement.
Keep the restricted transform as experimental evidence; do not change the
installed compiler or expand the rewrite on these results alone.
