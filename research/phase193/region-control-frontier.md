# Bounded H control and state investigation

Source inspected at Phase192 HEAD `dc413be`; no compiler or target jobs were
run by this investigator. Experimental files are under
`selfhost/tests/phase193/loop-threading-*`; production source is unchanged.

The smallest low-risk opportunity is constant-edge threading through the
existing single loop header. There are no duplicate descend/unwind loops to
merge. `x192h_worker_body` emits one `P113DIf(mode, unwind, descend)`, and every
`x192h_transfer` supplies mode as a literal 0 or 1. The generic `Again`
selector nevertheless jumps to the same header on every edge.

## Source and exact machine witness

`selfhost/src/back/x86/recursive-regions.bend:20` adds mode/depth/value to the
worker formals. Lines 27–32 create the common `Again` vector; lines 55–58 emit
argument preparation and snapshots before the mode-zero transfer. The
`x192h_worker_body`, `x192h_unwind`, and `x192h_case_prefix` functions preserve
the explicit continuation-stack protocol. `x181_again` delegates to the
existing physical parallel-move scheduler; `x181_tail_moves` emits the final
jump to `x181_loop_label`. The final typed-sequence hook is
`x181_function_done` in `selfhost/src/back/x86/function.bend`.

Exact retained disassembly:

- `selfhost/build/phase192/scoped-machine-audit01/tree-bitonic/h3.0.asm`:
  scan entry is `0x9516`; loop header `0x954f` is `mov %rdi,%r10`,
  `test %r10d,%r10d`, `je 0x96e2`. Nonzero falls through to unwind at
  `0x955b`. The edge `0x9611..0x9623` materializes mode zero into R10,
  copies R10 to RDI, and jumps to `0x954f`; mode one has the same pattern
  at `0x9686..0x9698`.
- `selfhost/build/phase192/scoped-machine-audit01/lexer/h3.0.asm`:
  gen entry `0xc9d3`; header `0xca1e` has the same three instructions,
  selecting descend `0xcc30` or unwind `0xca2a`. The exact adjacent
  zero-mode edge is `0xcb30..0xcb42`.

These are relocatable-object addresses, not sampled PCs. The audit report
authenticates the original H3 objects. Phase192's implementation report states
that maintained integration reproduces all three H-prototype objects exactly.
The source and machine match is therefore concrete, but does not itself
measure the dynamic frequency or cost of these edges.

## Experimental mechanism

The prototype matches the generic emitted loop label and exact typed header:

```
HEADER: movq HOME, R10; testl R10d, R10d; jz ZERO
NONZERO: ...
```

For an adjacent edge `movq IMM,R10; movq R10,HOME; jmp HEADER`, it retains
both assignments and substitutes `testl R10d,R10d; jmp SELECTED` for the
final jump. It inserts a fresh label at the nonzero fallthrough. The initial
header and all other incoming edges remain unchanged. No H function name or
parameter name is recognized.

The original six dynamically executed instructions become four. The
replacement TEST deliberately preserves all defined condition flags; R10
already holds exactly the value the removed header load would have read.
This saves two instructions per selected edge and adds one three-byte TEST
per static edge. Removing TEST as well would require a new flags-dead proof;
merely assuming the scratch register/flags are unobservable is unnecessary.

All stores, frame operations, parameter snapshots, depth operations, calls,
and existing parallel moves remain. Acyclic copies and self moves are already
handled by `x186_parallel`; there is no basis to credit all source-level
`Again` arguments as actual redundant machine copies.

The exact adjacent matcher reaches four scan edges, two warp edges, six eval
edges, and one lexer-gen edge in retained H3. In particular, other lexer/warp
tails place result assignments after the mode assignment, so this deliberately
small matcher refuses them. A write to the result home immediately before the
jump must not be mistaken for the mode write.

## Legality and refusal contract

1. Entry and zero-target labels must each have exactly one definition; the
   synthetic nonzero label must not already exist. The header has the exact
   width/opcode/operand pattern, and its zero target is not its own entry.
2. HOME is an ordinary full-width GPR other than RSP/RBP/R10/R11, or an
   aligned negative private RBP slot. The edge writes that identical physical
   home. Memory operands use exact base/displacement equality.
3. The immediate assignment, home store, and unconditional jump are adjacent
   typed instructions. Calls, labels, explicit empty directives, writes and
   any other items break the pattern. Structural empty sequence nodes may be
   crossed because they emit no item.
4. The predicate is the low 32 bits of the immediate, matching `testl`,
   including the case where the full 64-bit word is nonzero but its low word
   is zero. Both paths preserve R10's full 64-bit value and TEST flags.
5. Flattening is bounded at 16,384 sequence nodes. Any bound failure or absent
   header retains the original sequence. No new recursive runtime call,
   machine stack growth, liveness fact, allocation decision, or loop-depth
   assumption is introduced.

The integration patch is one call after existing frame forwarding in
`x181_function_done`. The experimental module must be included in checked
source before applying it. It is not a qualified production selection.

## Independent controls and status

`loop-threading-controls.bend` exports `p193lt_controls`: twenty full-sequence
data checks cover zero/nonzero/high-word predicates, private stack homes,
disabled identity, wrong symbols, width/opcode refusals, forbidden/unaligned
homes, label collisions, duplicate entry/targets, intervening calls/labels/
writes, and an unrelated jump target. These are authored but not yet executed
in this investigator's lane; the root owns source checking and compiler jobs.

`loop-threading-oracle.py` independently models the original and replacement
instruction effects over all registers, stack contents, and defined TEST flags.
It passed 2,224 finite observations and rejects two deliberately wrong variants:
dropping TEST, and deciding the branch using all 64 bits. This validates the
stated rewrite contract, not the Bend matcher, encoder, or real machine code.
The initial observer run failed because this Python lacks `int.bit_count`;
the observer now uses `bin(value).count("1")`, and the corrected run passed.
No failure was a compiler or generated-program execution.

## Other state opportunities, not selected

The H source lowers argument tails to stores into scratch followed by loads
into edge temporaries. Existing forwarding removes some loads/self copies,
yet retained scan still has three instructions storing its next argument at
`0x9604..0x9611`; lexer has nine instructions storing three next arguments at
`0xcb07..0xcb30`. `p112t_tail_store` checks that the final suffix consists of
ordered full-width `scratch[8*i]` stores. `p126r_arguments` permits earlier
scalar preparation, including scratch access.

Replacing that exact final suffix with scalar snapshots could remove real
stores, but terminal scratch contents are not automatically dead: a later
loop/case entry could read a stale scratch slot before overwriting it. A
proof of overwrite-before-read across each relevant reentry, or an existing
verified stronger scratch-initialization invariant, is needed. Merely matching
the argument-store suffix does not supply that proof. This is why the current
prototype preserves all memory effects.

Likewise, parameters carried unchanged into unwind and result carried unchanged
into descend are often semantically irrelevant until overwritten. The shared
P113D loop liveness merges the modes, so deleting them needs an edge-sensitive
contract. Setting them to zero is not automatically profitable or sound in
every admission. Direct multi-entry control could expose that later, but is
larger than this bounded experiment.

The failed scoped-frame expansion remains excluded: six frame-helper sites
disappeared, but lexer grew nine instructions and acquired outgoing-argument
snapshots; the broad screen was mixed. Nothing here reintroduces that pass,
changes runtime continuation layout, or interprets helper shares as removable
overhead. Static coverage and the finite state oracle justify only a small
source/machine experiment; whole-program benefit remains unmeasured.
