# Native45 algorithm counterparts

Each mapped source is a separate C11 translation unit without `main`. Numeric
entries expose `uint32_t bench_u32(uint32_t a, uint32_t b)`; the row-state entry
exposes `char *bench_text(uint32_t a, uint32_t b)`. Its result is NUL-terminated,
malloc-owned ASCII/UTF-8 without a trailing newline; the caller frees it after
each invocation. There are no embedded result oracles or benchmark-ID branches.
All variants call the same family kernel with their supplied arguments.

The authoritative semantics are the exact files under
`selfhost/tools/bench/catalogs/native45/fixtures/`. The base/variation algorithm
prefixes (everything before `p93.arguments`) are byte-identical within each of
the editdist, tree-bitonic and lexer families. The catalog's retained oracle
and runtime arguments remain the independent acceptance boundary.

| Source | Bend source and relevant declarations | Upstream C comparison |
|---|---|---|
| `editdist.c`, `editdist_kernel.h` | `editdist.bend`: `gen`, `init`, `cell.f1`–`cell.f4`, `row`, `dp`, `pair`, `batch`, `bench`; both `variation-editdist-*` fixtures | `bench/runtime/editdist/main.c` |
| `complete-generic-row.c` | `complete-generic-row32.bend`: shared edit-distance helpers, `row.probe`, `p88_row_array`, `p88_row_output` | Same edit-distance twin for the shared cell kernel; no upstream complete-state twin |
| `tree-bitonic.c` | `tree-bitonic.bend`: `warp_leaf`, `warp_zip`, `warp`, `flow`, `bsort`, `scan`, `stat_out`; both `variation-tree-bitonic-*` fixtures | Adapted from `bench/runtime/tree-bitonic/main.c` |
| `lexer.c` | `lexer.bend`: `tpl`, `gen`, `ident`, `num`, `step.at`, `flush`, `lex`, `batch`; both `variation-lexer-*` fixtures | `bench/runtime/lexer/main.c` for generator/hash cross-reference |

## Representation and ownership

- Edit distance retains U32 symbols, two 256-word sequences, and two 512-word
  rolling rows. The upstream C twin uses byte symbols and 257-word rows; this
  implementation keeps the fixture's capacities. The arrays are automatic C
  storage, zero-initialized per pair, and leave scope after the checksum.
  Batch recursion still splits the same pair-index tree. It is sequential.
- The complete-state probe retains all four 128-word arrays, including unused
  zeros. It computes one row, swaps prev/cur even at zero length, then emits all
  512 values in `[a,b,prev,cur]` order. `row.probe` starts `cur[0]` at zero, not
  the ordinary DP prologue's one. Array-to-list conversion uses temporary linked
  U32 nodes, consumed/freed by the serializer. The final UTF-8 transport uses a
  bounded native byte buffer instead of Bend's character-list concatenations.
- Bitonic sorting retains the same tree network and compare/warp/zip/flow
  algorithm, including opposite child directions and odd/even index order.
  As in the upstream C twin, leaves are unboxed words and node edges are arena
  indices. Consumed nodes enter a freelist; zip/flow reuse owned nodes. This is
  tree storage, not flattening to an array sort. Arena growth starts on demand;
  unlike the upstream compile-time-depth executable it does not preallocate
  from a fixed depth. The entire arena is freed before every return.
- Lexer template and generated source both remain linked lists of U32
  characters. Generation builds the tail first and prepends each expansion;
  the three lexer modes and token-boundary transitions follow `step.at`.
  Template nodes and generated nodes are consumed/freed once each. The upstream
  C twin instead uses a stack byte buffer and token loops; that representation
  shortcut is deliberately absent here. Immutable template/operator spelling
  is stored in ordinary C string literals.

All arithmetic words are `uint32_t`: PRNGs, seeds, indices, checksums, decimal
accumulation and DP increments wrap modulo 2^32. Natural loop/depth arguments
originate from U32 and only decrement; no additional Nat arithmetic is needed.
`U32.shln(1,n)` is modeled as zero for `n >= 32`, not a C oversized shift.
Probe array access masks by 127, retaining Base's wrapped `Array.get/set`
semantics even beyond the catalog's 32-cell probe. `U32.inc(a)` wraps before
the probe initialization count is converted to its loop bound.

Allocation exhaustion aborts the native process; it is not a successful result
or a substitute oracle. Extremely large depth/count inputs are resource-bound,
as are the source programs. The mapped finite catalog inputs remain the scope
of benchmark qualification.

## Controls for the root execution lane

No C compilation, target execution, or performance claim was made while writing
these sources. Run all ten mapped catalog oracles with their real arguments.
Useful additional finite differential controls are depth zero and one with
seeds 0 and `UINT32_MAX` for every family; editdist/lexer depth two at the same
seeds; and row-probe lengths 0, 1, 127, 128, and 129 with seeds 0, 17, and
`UINT32_MAX`. The last two probe lengths test wrapped cells, while zero checks
the unconditional row swap. Tree depth zero checks the leaf-only arena path.
Repeated calls and an allocation/leak checker should verify complete cleanup,
with returned row strings freed by the caller. Keep validation inputs distinct
from timed catalog inputs and retain any failures before changing code.
