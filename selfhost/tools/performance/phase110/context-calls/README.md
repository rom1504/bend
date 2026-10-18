This directory contains a separate, post-selection call ABI experiment. It does
not change the selected native compiler image. Both modes preserve public
`ctx, owned... -> owned` exports and regenerate private workers from the same
verified ownership library. `threaded` forwards the stable heap and allocator
base addresses; `context` loads them from authenticated context offsets. Public
wrappers retain both checked accessors. Exact machine regeneration, closed
owning-call verification and the original namespace gate remain required.

All compiler acquisition, emitted-code execution and timing run under the root
agent's serial CPU guard. The scripts below are transport and supervision; Bend
implements admission, closure, transformation, verification and emission.

The current source is `context-source07`, admitted by `context-admission07`.
`build-api.py --source ... --admission ... --out FRESH` acquires the checked API
and records a complete source/API receipt only on success. Earlier failed
source/API snapshots are preserved.

The ordinary checked driver exports only annotated definitions reachable from
`main`. A String-only source consequently omits the unused List descriptor,
although the native general factory's full checked request retains it.
`prepare-capture.py --source FROZEN_SOURCE --out FRESH` prepares a pinned scoped
driver copy with native annotation roots `main`, `List`, `String`, `Char`.
Its manifest and diff separate that one semantic transport change from module
path relocation. Run the generated `capture.mjs PREPARED_MANIFEST FRESH_CAPTURE`
with the pinned Bun. It still checks the unchanged actual source, uses the same
Base and compiler, and derives all descriptors and erased facts in Bend.

Run `emit-v4.mjs API.mjs CAPTURE_DIR FRESH_EMISSION` with Bun. It requires all 31
named Bend controls, compares original QBE and C exactly against the qualified
native products, then emits baseline/threaded/context for actual Base
String.append and the unchanged reverse/nt_append libraries. Fifty-four
explicit malformed-certificate probes are data-only refusal checks. The
original emit and v2/v3 files remain for their preserved failed receipts.
The context verifier compares complete serialized graphs using a consuming
full-codepoint tail comparator; the older generic String equality overflowed
the hosted stack on the larger reverse graph. Six additional focused equality
controls cover empty, Unicode equality, first/last mismatch, length and complete
Unicode scalar comparison.

`context-api07` and `context-emit04` passed acquisition and hosted qualification:
31 named controls, nine products, 54 refusals, and exact native baseline QBE/C.
The generated exact comparator uses a loop with `continue`, not host recursion.

Run `run-v2.py --emission EMISSION --admission ADMISSION --transfer-plan PLAN
--runtime-object OBJECT --runtime-build BUILD_RECEIPT --out FRESH --clang CLANG
--gcc-include /usr/lib/gcc/x86_64-linux-gnu/10/include`
under the serial guard. The explicit standard-header path is used for every
Clang mode and stddef.h is pinned. This resolves the pinned Lean Clang resource
header omission without changing generated sources; the first machine failure
and original runner are preserved. The runner requires the exact admitted runtime source and its
successful build receipt, builds QBE and Clang workers, checks the original
String/list/reverse semantic oracles, then repeats only the frozen two bounded
String.append timing graphs. It reports paired ratios against the same compact
general baseline. No variant is selected from these reused cases.

The runtime source proof assumes one synchronous context: heap extension never
relocates its base, allocator storage has a stable address, and admitted calls
cannot close or replace the context. Mutable contents remain ordinary loads.
There are no callbacks, concurrent workers or reentry in the qualified corpus.

`context-machine02` completed all 18 worker builds and 234 original semantic
observations. Its five paired rounds on the two existing String.append timing
cases show every variant/baseline ratio below one; QBE median ratios range from
0.850 to 0.904 and Clang from 0.834 to 0.907. These are diagnostic comparisons
with the same compact/general baseline, not new heldouts or a policy change.
The offline `implementation/phase110/evidence/machine08` receipt pins binaries
and disassembly; its adjacent analysis explains getter removal, argument
forwarding and stack tradeoffs. No generated executable is run by `inspect.py`.

The separate synthetic wide fixture is prepared in `context-wide-source04`,
admitted by `context-wide-admission04`, and checked by `context-wide-api04`.
It constructs an owning root with eight arguments that calls a leaf, sinks the
first seven and returns the eighth. Its public/context signatures have nine
machine arguments; the threaded private signature has eleven. This is an ABI
witness, not a checked-source algorithm or timing workload.
`run-wide-v2.py --api API --source PREPARED --admission ADMISSION --runtime-build
BUILD_RECEIPT --clang CLANG --gcc-include GCC_INCLUDE --out FRESH` uses the root's
serial guard. The independent oracle checks unique and physically shared
String arguments, retained aliases, both release orders, and zero pending/live
ownership. The C controls disable inlining and sibling-call optimization;
machine inspection checks whether Clang eliminates unused private pointer
arguments before claiming an eleven-argument C execution.

`context-wide-machine02` passes all six builds and 24 ownership observations.
The offline `machine09-wide` receipt confirms QBE actually forwards eleven
private arguments, including five stack slots. Clang eliminates both unused
borrowed pointers and hoists the eighth return value to the public wrapper;
its private calls have eight arguments. Thus this gate qualifies the public
nine-argument ABI in both backends and QBE's eleven-argument private ABI, while
Clang's eleven-argument machine behavior remains outside the measured scope.
The wide gate has no timings and does not alter selection.
