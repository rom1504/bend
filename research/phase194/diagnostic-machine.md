# Phase194 integer and memory diagnostic machine audit

The smallest concrete next capability is physical commutative operand selection. The actual register-pressure-few kernel repeats eleven right-home XOR sequences whose two snapshot/copy moves are unnecessary. The value-identity pair already has spill-free loops; it does not establish a need for whole-function SSA. The memory pair exposes nested-state transport/ownership work around its array read, so it measures that work as well as load dependence.

Inputs are the successful `diag-baseline-build04` and `diag-selected-build02` binaries built from catalog-v3. “Selected” here means the existing float/predicate candidate, **not** the later commutative experiment. The [offline derivation](diagnostic-machine-witnesses/derive.py), [hashed report](diagnostic-machine-witnesses/report.json), and bounded function disassemblies preserve exact identities. No compiler, target or timing job was run by this audit.

| Actual kernel | Positive loop instructions | Explicit stack-memory instructions | Calls | Reserved frame bytes |
| --- | ---: | ---: | ---: | ---: |
| value-identity-rebind | 19 | 0 | 0 | 2352 |
| value-identity-helpers | 19 | 0 | 0 | 2384 |
| register-pressure-few | 89 | 0 | 0 | 2432 |
| register-pressure-many | 83 | 12 | 0 | 2448 |
| memory sequential: read_loop only | 15 | 4 | 1 | 2320 |
| memory dependent: read_loop only | 15 | 4 | 1 | 2320 |

Each row is identical in baseline and selected. Counts include the positive path's loop-header comparison/branch and backedge, excluding the exit. Stack counts include direct RBP/RSP memory operands, excluding LEA; they omit memory through scratch-address registers. Reserved stack size is not per-iteration memory traffic. Equal metrics do not imply binary equality.

The value kernels both contain ten moves, one multiply and one XOR, with no loop calls or spills. Their generated saved-old-value arithmetic survives lexical rebinding correctly under current selection; source helper spelling changes frame reservation by 32 bytes without changing these loop counts. This is evidence against making general value renaming the first response to this pair.

The few-live loop has 49 moves and eleven XORs. Each XOR currently snapshots its right register into R11, copies its left register into the destination (which aliases the original right home), then operates on R11. For integer add/multiply/AND/OR/XOR, the existing right home can instead consume the left register directly. `x190_binary_direct` in `register-binary.bend` currently rejects right/destination alias unless left already shares that home. The experimental `commutative-select-v2.bend` supplies this missing alternative, with U32/U64 checks, register-only operands, a toggle and exact fallback. It queries the left home only after cheap applicability checks. This requires physical identities, not a new analysis pass or reordered effects. Ten exact instruction-form controls and 6050 independent C observations per route are authored; execution belongs to the root-owned qualification lane.

The many-live loop demonstrates a different constraint: four arithmetic intermediates plus the decremented count and incremented index are stored/reloaded each iteration, accounting for its twelve explicit stack accesses. It has fewer static instructions than the few-live loop because its XOR chain already uses more direct operands, while its simultaneous live values exceed the useful register set. This pair therefore separates avoidable operand copies from real live-range pressure. Commutation does not claim to remove those spills. A pressure-aware schedule would be a larger, distinct change and is not proposed for this bounded experiment.

Memory-v3's actual read_loop calls read_cell on every iteration. On valid nested tuples and the inline array fast path, read_cell executes two `p125_rt_take2` calls, one array read, then calls product.read_step. That helper calls `p125_rt_ctor2` twice to rebuild the nested state. Including the read_loop→read_cell and read_cell→read_step edges gives six calls per iteration before counting instructions inside runtime helpers. The successful path is:

| Invoked portion | Instructions | Explicit stack-memory instructions | Calls | Frame |
| --- | ---: | ---: | ---: | ---: |
| read_loop positive path | 15 | 4 | 1 | 2320 |
| read_cell valid array fast path, including entry/return | 131 | 34 | 3 | 2544 |
| sequential product.read_step, including entry/return | 57 | 6 | 2 | 2368 |
| dependent product.read_step, including entry/return | 53 | 7 | 2 | 2368 |

The sum excludes the runtime helpers themselves and is a static successful-path count, not a measured hot-PC attribution. Array setup remains part of the full diagnostic too. This is a useful nested-product transport witness, overlapping the separate product audit; it is not an isolated cache/DRAM latency experiment. Attribution to an x86-specific deficiency awaits the C/QBE machine comparison rather than being inferred from these x86 artifacts alone.

The completed `diag-references02` supplies the [C/QBE reference report](diagnostic-machine-witnesses/reference-report.json) and [reproducible bounded extraction](diagnostic-machine-witnesses/references.py). Both reference representations retain work relevant to interpretation:

| Kernel | Direct x86 selected | QBE | C |
| --- | --- | --- | --- |
| value identity, both spellings | 19 instructions/iteration, no spills | 18 instructions/iteration, no spills | 23-instruction main loop performs **four** iterations; 10-instruction remainder loop; no spills |
| pressure few | 89 instructions, no spills | 78 instructions, no spills | 34-instruction SIMD loop, no spills |
| pressure many | 83 instructions, 12 explicit stack accesses | 78 instructions, no spills | Same 34-instruction SIMD loop as few, no spills |

The C value kernel unrolls four recurrence steps; its main-loop count is not directly comparable with one scalar iteration. C pressure kernels use packed integer multiply/add/XOR and reduce the result; the two source schedules converge. QBE pressure-many uses RAX/R10/R11 and additional registers for live terms, while current direct x86 excludes scratch homes from its nine allocatable integer colors. Thus the spill gap is not solely about source schedule: operand-local scratch lifetime contracts could eventually make more physical registers usable, but that is materially larger than the isolated commutative selector. QBE still contains redundant narrow self-moves, illustrating why counting fewer instructions is not by itself a performance ordering.

**Nested-state boxing is not x86-only.** QBE's read_loop also calls read_cell, which takes two tuples and calls product.read_step; that helper constructs two tuples. The same six generated/runtime call edges remain on the valid array fast path. QBE's read_loop is 75 bytes versus direct x86's 120; read_cell is 376/375 versus 776 bytes, and sequential/dependent product.read_step is 113/100 versus 218/201 bytes. QBE reserves 2064 bytes in read_cell and 2048 in product.read_step, while its read_loop has no explicit stack reservation (callee-save pushes still exist). These size differences show a distinct machine-selection/argument-staging gap on top of the shared representation.

C inlines much of read_cell/step into the loop but retains tuple allocation/reference-count handling: its actual read_loop contains inline allocation paths and calls to `rfc_wrap`, `heap_alloc_miss`, `heap_hand`, `span_fade`, and `term_drop`. These are branch-dependent call sites, not claims that each executes once per iteration. Its generated C and machine paths do not reduce to a lone array load either. Improving nested-product representation is therefore a shared lowering/runtime opportunity, separate from reducing direct x86 staging moves.

No speed estimate follows from these counts. Ordinary-workload transfer remains the commutative experiment's promotion question.


## Commutative candidate machine confirmation

The later `diag-commutative-build01` artifacts are now included in the hashed report. Against `diag-selected-build02`, the few-live loop changes exactly as predicted: **89→67 instructions and 49→27 MOVs**, with eleven XORs, twelve IMULs, zero calls and zero explicit stack accesses unchanged. Its kernel shrinks **401→335 bytes**, retaining its **2432-byte** frame. Each former `mov %rdi,%r11; mov %rdx,%rdi; xor %r11,%rdi` becomes `xor %rdx,%rdi`; the subsequent accumulator-publication move remains. This is 22 removed moves, not removed arithmetic.

The many-live kernel remains **456 bytes**, **83 loop instructions**, **43 MOVs**, **12 explicit stack accesses**, and a **2448-byte frame**. Its XOR chain already had usable operand homes. The other sampled value/memory functions retain all measured metrics. Whole `.text` shrinks 101489→101233 bytes for few and 101569→101441 for many; the many case's section change occurs outside its unchanged kernel, so whole-section savings must not be presented as hot-loop savings.

V2's compiler-cost guard is sound: `x194_cr_applicable` checks the toggle, physical right/destination equality, width and operation before the lazy branch enters `x194_cr_attempt`. Only that admitted branch queries the left home. The old direct function body remains exact under its renamed fallback. There is still a narrower cost opportunity: an otherwise eligible operation with a nonregister left operand performs the new lookup and then repeats the old refusal lookup. Since right==destination and a nonregister left cannot satisfy the old direct condition, that path could return Empty immediately in a later refinement. No such further change was made to the checked candidate, and no compiler-cost or runtime improvement is inferred here. Root-owned finite controls passed 6050 independent observations on each of the two emitted routes.

## Apparent gains beyond the pressure kernel

The [expanded call-path witnesses](diagnostic-machine-witnesses/apparent-gains.json) and [extraction](diagnostic-machine-witnesses/apparent.py) distinguish actual work removal from unresolved timing effects. Unique-product was outside the six-case integer/memory sample: its hot scalar kernel does improve, **24→22 loop instructions**, **15→13 MOVs**, **150→143 function bytes**. The final U32 add loses its right snapshot and left copy. Predicate-mask also loses four hot MOVs: **44→40 loop instructions**. These are concrete transfers of the same physical-operand rule, not product-layout or predicate-plan changes.

Value-rebind's entire 137-byte kernel is byte-identical before/after (SHA256 `81f10e8450a1fa7e4f5e4578d37a0070abe23fa20f5fabcef48a5022bccac00a`); helpers' kernel is likewise byte-identical to its own previous version. Both outer repetition/validation functions lose two moves around an OR, once per full 1024-step kernel invocation. Rebind's loop header changes address modulo 64 from 13 to 57; helpers changes 19 to 56. The root-owned timing gain for rebind therefore cannot be credited to removing work inside that recurrence. Layout/cache effects and measurement variation remain possible, unisolated explanations; no causal share is assigned to either.

The exact checked v2 declarations were subsequently integrated into existing `register-binary.bend`, with no manifest change or selector refinement. [Integration audit](commutative-integration-audit.json) records 5312 matching declarations under the same seven API roots, eight matching new/replaced declarations, and byte-identical assemblies for all five other profiles. Source assembly is metadata work; root-owned source checking and native qualification remain separate.
