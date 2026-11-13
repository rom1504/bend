# Scoped H-frame expansion: exact emitted work

The scoped candidate removes **all six residual `p111_rt_frame` call sites**
from the four affected recursive workers. Relocation records confirm the call
targets in the actual ELF objects; the surrounding runtime-frame writes remain.
This is real selection, not merely a source-level matcher or an unused helper.
It does not uniformly reduce caller instruction or store counts.

The offline [audit](../../selfhost/build/phase192/scoped-machine-audit01/report.json)
authenticates object/assembly pins from `recursive-emit01/report.json` (H3) and
`scoped-emit02/report.json`. It retains exact function instructions, symbol
sizes, relocation records, and call-site offsets. Only nm/objdump and metadata
analysis ran. These are relocatable-object offsets, not final ELF addresses;
no linking, runtime measurement or target execution was performed.

| Recursive worker | `rt_frame` sites H3→scoped | Instructions | Bytes | Explicit RBP memory references | Explicit MOV memory stores, all bases |
|---|---:|---:|---:|---:|---:|
| Tree `scan` | 1→0 | 238→233 | 1118→1106 | 28→31 | 38→40 |
| Tree `warp` | 1→0 | 557→550 | 2806→2772 | 144→146 | 122→122 |
| Expression `eval` | 3→0 | 413→406 | 2083→2066 | 79→87 | 78→84 |
| Lexer `gen` | 1→0 | 360→369 | 1746→1788 | 85→82 | 84→87 |

Other target-call multisets are unchanged. Expression `p37.expr` and each
`String.length` recursive worker retain identical static counts and call
multisets. Whole-function totals include alternate/failure paths. RBP memory
references exclude LEA and miss frame accesses via another register; all-base
store counts include the newly explicit continuation-stack stores. Thus neither
column is a spill-cost or dynamic-frequency estimate.

## Exact selected window

The first expression `eval` frame setup, with continuation FID `0x48`, changes
from function-relative `[0xaa,0xe7)` (12 instructions, 61 bytes) to
`[0xaa,0xcf)` (seven instructions, 37 bytes). The
[witness](../../selfhost/build/phase192/scoped-machine-audit01/expression-frame-witness.json)
retains every instruction. The original path stages the captured word in private
scratch, prepares state/FID/pointer/count arguments, calls the runtime helper,
and stores its result. The selected path loads `state+0x10`, stores the captured
word and FID into the continuation stack, advances the stack pointer by 16, and
stores it back. The original helper's body is outside the 12-instruction count.

The other two expression sites also expand, but their resulting stack-pointer
temporary spills to RBP and reloads before updating `state+0x10`. This contributes
to the increased explicit frame-memory count. All three still increment local
region depth and preserve the continuation payload/FID ordering.

## Remaining transport and a concrete tradeoff

Lexer removes its frame call yet grows by nine instructions and 42 bytes.
Placement changes `p114r_value` from a frame home to RSI. A subsequent
`gen.at` helper call now stages four outgoing arguments to RSP slots
`0x20..0x38` and reloads them into RDI/RSI/RDX/RCX. Explicit RSP references
increase 0→8, and the machine frame allocation grows `0x1ae0→0x1af0` bytes.
This is a visible ABI snapshot cost, not an identified correctness error: the
snapshot protects simultaneous argument reads before register writes.

The two-capture lexer frame retains one scratch store/load while directly
publishing the other captured word. Scope expansion does not imply that every
argument staging store became dead. Repeated `state+0x10` loads, short-lived
stack-pointer spills, local mode/depth/result transport, and unchanged ownership
calls remain. Do not add per-case register/home rules to erase this one layout.
The broad runtime screen decides whether helper removal outweighs these costs.

## Headroom after H selection

The H port removes scheduler transitions, but its structured mode loop still
materializes mode/depth/value and carries parameters through local `Again`
edges. QBE's recursive `warp` core has 301 static instructions versus scoped
x86's 550; expression has 204 versus 406. These differences include lowering
and ABI choices, and are not predicted speedups. A future late representation
with direct descend/unwind labels and explicit live edge values could avoid
unnecessary mode and parameter transport while retaining the same runtime stack
and terminal checks. It requires its own correctness and profitability evidence.

Known constructor/take fast paths remain another general opportunity. The
pre-H physical shares were about 19.03% tree, 10.56% expression, and 9.24% lexer;
those helper bodies perform required ownership/allocation work, so the shares
are not removable overhead. They must be remeasured on the selected H product
before ranking them against new caller transport. C inlines many such paths,
while native helpers preserve an ABI boundary. Keep that route separate from
the already rejected generic call-move experiment and from a register-count
increase unsupported by dynamic spill evidence.

An independent source review of `x192h_stmt`, `x192h_unwind`, and
`x192h_case_prefix` found no mismatch with the QBE H emitter in the inspected
ordering: frame→depth→arguments/call; depth guard before pop; FID pop1→get0;
capture pop→get(index); pop-status zeroing; result binding; and snapshot-before-
Again with invariant state excluded. This is a scoped review, not a proof or
substitute for the adversarial deep-recursion, alias, and refusal controls.
