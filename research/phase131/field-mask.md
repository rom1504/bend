# Borrowed reader field demand: a bounded machine-code ceiling

Status: **rejected for implementation after paired timing**. This is a frozen
generated-QBE experiment; no production compiler or runtime change. The four
ordinary native executions passed independent frozen output oracles, and all 30
timed executions passed. Removing real instructions produced no material runtime
benefit on either family. Do not add a new field-demand pass on this evidence.

## Finding

The useful remaining opportunity is demand-driven field reading, rather than
removing the current layout checks. The compiler already carries held-root
origins across private reader calls (`p128br_held` and `p128br_arguments`), avoiding
another public borrow adapter. Those facts establish lifetime, but not the full
tag, constructor layout, and RFC-indirection facts needed for a raw heap access.
`OFact` additionally records a matched constructor's field origins; currently
`noa_equal` consumes it for reconstruction identity, rather than using it as a
general repeated-match witness.

The generated machine code already shares some tag/CID arithmetic. In the actual
`p98_tag_eq` reader, the extra matched-branch combined guard is a `test` and
conditional branch, with a register exchange in the original allocation. Eight
QBE statements are not eight additional machine instructions here. No guard was
removed in this experiment.

The larger concrete loss is that `p128bf_fields` copies **all eight KTerm fields**
from the heap to private scratch, although this branch only uses field0 (the
text tag). The original native block at `0x4096fc–0x409754` performs eight heap
loads and eight stack stores; `0x40975b` reloads only field0. The optimized ceiling
keeps one heap load/store pair. The RFC test and decoding, constructor/tag guard,
and original `p118_rt_borrow_fields` fallback are retained.

## Why ordinary dead-store elimination does not recover this automatically

Scratch is passed both to the fallback borrow import and to nullary
`p111_rt_special_ctor`. QBE sees external calls rather than their precise memory
effects. Two bounded experiments distinguish this from a presumed missing
general optimizer:

1. **Nullary pointer ablation:** pass null instead of scratch to exactly
   `special_ctor(kind1 or kind2, count0)`. The runtime checks arity and returns a
   scalar without reading or retaining its argument buffer. This removes that
   particular escape, but QBE1.3 still retains every field copy. The simpler
   no-demand-analysis route did not achieve the intended machine-code change.
2. **Explicit field-demand ceiling:** compute backwards liveness of the actual
   private scratch slots in the two frozen reader functions; remove only dead
   generated field stores and their now-unused pure definitions. The exact call,
   conditional-branch, label and guard sequences remain. This removes real
   machine work, without changing an import or its fallback.

The runtime audit checked `runtime-borrow01/runtime.c:4367–4390` (nullary special
constructors) and `:4624–4637` (borrow fields). The latter writes its output slots,
does not retain the output pointer, and does not modify state. An independent
reviewer inspected all 53 scratch aliases in the compiler reader and 11 in the
record reader. No stored pointer, copied pointer escape, or unclassified call
uses the buffer. Other called readers receive Terms and state, not this private
stack address. This is a proof argument for these frozen functions on valid
checked Bend heaps, not an admission rule for arbitrary foreign or malformed
Terms.

The ceiling script alone is deliberately insufficient as a general optimizer:
it does not reject every hypothetical non-call pointer escape. Generalization
would require complete checked alias/effect information. Also, directly
inserting a null pointer into the current checked N111 IR is not admitted by
`p113e_nonstate_pointer`; the ablation changes frozen QBE only. It is not a reason
to weaken that verifier.

## Static and ordinary-execution results

| Exact private reader | Baseline QBE lines | Masked QBE lines | Baseline machine instructions | Masked instructions | Null-pointer instructions |
|---|---:|---:|---:|---:|---:|
| Compiler `p98_tag_eq`, inside unchanged `nq_uses` proxy | 963 | 823 | 745 | 635 | 745 |
| Unrelated `p131_packet_query` record consumer | 153 | 123 | 133 | 123 | 133 |

Machine call sites remain 38 and 8 respectively. These counts include mutually
exclusive branches, cold paths and alignment instructions. They are not dynamic
counts or speedup predictions. The mask removes 24 field stores across the first
reader's branches and 5 across the second; the hot KTerm branch removes seven
load/store pairs.

Each of the four candidate binaries was built with the same QBE1.3, aligned
assembly recipe and exact cached runtime object as its corresponding baseline.
The unchanged compiler proxy passed its ten-line independent ordinary oracle;
the record proxy passed its twelve-line oracle. No failure-runtime probes,
runtime ABI changes, full compiler rebuilds, or production-selection changes
were used.

## Reproducible evidence and next decision

The root ran five clean rounds per role on CPU3, rotating order, with no concurrent
target execution. Whole-child medians were:

| Proxy | Baseline | Explicit mask | Mask change | Null pointer | Null-pointer change |
|---|---:|---:|---:|---:|---:|
| Unchanged compiler `nq_uses` | 482.927ms | 481.908ms | −0.21% | 482.332ms | −0.12% |
| Unrelated record consumer | 160.316ms | 160.648ms | +0.21% | 160.833ms | +0.32% |

CPU-time median changes support the same conclusion: mask −0.11% / +0.20%, null
pointer −0.01% / +0.25%. The median same-round mask wall ratios were 0.9978 and 1.0044.
The effect is small relative to the observed run variability and does not
generalize into a useful runtime gain. No statistical significance is claimed.
The 30 timed children consumed 9.658s wall and 9.631s CPU in total; no full compiler
image had to be rebuilt to reject the optimization.

This is evidence against treating static field-copy counts as an optimization
priority. A plausible explanation is that cached loads/stores overlap other
execution and that tag comparison/recursive traversal dominate the complete
computation; this experiment does not measure a causal microarchitectural
explanation. The static total also includes cold, mutually exclusive branches.
Do not convert the 14.8% reader instruction reduction into a compiler speed claim.

Timing receipt: `selfhost/build/phase131/field-ceiling-timed01/report.json`,
59,315 bytes, SHA256
`eb45ce0be9c186460d3ee0c834676671bbb09811a0fbc14a31224579e303f242`.

Tools live in `selfhost/tools/performance/phase131/field-mask/`:

- `ceiling.py` preserves the input/runtime/script hashes, removed statements and
  output hash, and asserts unchanged control/call authority.
- `timing.py` seals six independently passing binaries: baseline, explicit mask,
  null-pointer ablation for each family. It reuses the existing source-frozen
  repetition calibrations: 2,047 traversals and 1,000,000 record-query repetitions.
- `inspect-v02.py` retains exact reader SSA and native disassembly. The first
  inspection's `call` counter missed the `callq` spelling; its receipt is retained
  as negative tooling evidence. V02 corrects that counter; the instruction,
  field-copy, and ordinary-output observations were unaffected.

Build receipts are `selfhost/build/phase111/p131-field-ceiling-{uses,packet}-`
`{mask,null}01/report.json`; transformation receipts are the corresponding
`selfhost/build/phase131/field-ceiling-*` directories. Static evidence is
`selfhost/build/phase131/field-ceiling-inspection02/report.json`. The root-owned
paired-timing manifest is `field-ceiling-timing01/manifest.json`.

Were a different measured hot computation to show useful transfer, an appropriate
compiler design would be a
small checked **field-demand fact** attached to an existing private match or
reader plan, carried into the already guarded late load template. Demand must
come from the complete residual consumer, not one instruction or a function
name. Reuse existing body-use summaries where sound; avoid adding another
repeated whole-body walk. Unknown demand retains full reads. The independent
verifier, shape/RFC guard, owning fallback and public alias boundaries remain.

The current decision is to stop. Preserve the demand-loss finding for a future
transformation that removes a larger computation or makes these loads dominant;
do not implement it independently now. Neither a prettier SSA program nor fewer
static instructions justifies another compiler pass or native qualification
campaign. Prioritize the newly measured whole-compiler bottlenecks instead.
