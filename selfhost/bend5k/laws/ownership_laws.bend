import Base

# =============================================================================
# bend5k Zero-Cost Ownership & Representation Laws (Pure Bend, zero unsafe)
# =============================================================================
# Formalizes and proves four core optimization laws enforced by bend5k:
#   Law 1 — Unboxed 2-Scalar Direct Transfer (`ret2`)
#   Law 2 — Unique-Slot In-Place Reuse (`IReuse`)
#   Law 3 — Read-Only Borrow-Walk Erasure (`borrow`)
#   Law 4 — Linear-Array Handle Hoist & Dead-Swap-Old-Load Erasure
# =============================================================================


# =============================================================================
# LAW 1: Unboxed 2-Scalar Direct Transfer (`ret2`)
# =============================================================================
# Packing two U32 scalars (Word(32n) + Word(32n)) into a single 64-bit register
# word (Word(64n)) and unpacking them preserves both `fst` and `snd` identically
# to heap Pair boxing+unpacking, while performing 0 heap allocations.

type PairU32 is Data:
  MkPairU32{fst: U32, snd: U32}

type TransferRes is Data:
  MkTransfer{val: PairU32, allocs: Nat}

def word_pack(+n: Nat, -m: Nat, a: Word(n), b: Word(m)) -> Word(Nat.add(n, m)):
  match n a:
    case 0n WNil{}:
      b
    case 1n+p WCon{h, t}:
      WCon{h, word_pack(p, m, t, b)}

def word_take(+n: Nat, -m: Nat, w: Word(Nat.add(n, m))) -> Word(n):
  match n w:
    case 0n _:
      WNil{}
    case 1n+p WCon{h, t}:
      WCon{h, word_take(p, m, t)}

def word_drop(+n: Nat, -m: Nat, w: Word(Nat.add(n, m))) -> Word(m):
  match n w:
    case 0n w0:
      w0
    case 1n+p WCon{h, t}:
      word_drop(p, m, t)

# Structural induction on bit-width n: taking the low n bits of pack(a, b) = a.
law word_take_pack:
  for +n: Nat
  for -m: Nat
  for  a: Word(n)
  for  b: Word(m)
  {word_take(n, m, word_pack(n, m, a, b)) == a : Word(n)}

def word_take_pack(n, m, a, b):
  match n a:
    case 0n WNil{}:
      {==}
    case 1n+p WCon{+h, t}:
      %word_take_pack(p, m, t, b) : {WCon{h, word_take(p, m, word_pack(p, m, t, b))} == WCon{h, _} : Word(1n+p)}
      {==}

# Structural induction on bit-width n: dropping the low n bits of pack(a, b) = b.
law word_drop_pack:
  for +n: Nat
  for -m: Nat
  for  a: Word(n)
  for  b: Word(m)
  {word_drop(n, m, word_pack(n, m, a, b)) == b : Word(m)}

def word_drop_pack(n, m, a, b):
  match n a:
    case 0n WNil{}:
      {==}
    case 1n+p WCon{h, t}:
      word_drop_pack(p, m, t, b)

# 64-bit register packing/unpacking of two U32 scalars
def u32_pack64(a: U32, b: U32) -> Word(64n):
  match a b:
    case U32{wa} U32{wb}:
      word_pack(32n, 32n, wa, wb)

def u32_unpack_fst(w: Word(64n)) -> U32:
  U32{word_take(32n, 32n, w)}

def u32_unpack_snd(w: Word(64n)) -> U32:
  U32{word_drop(32n, 32n, w)}

# Reference heap-boxed Pair transfer (1 heap allocation)
def transfer_boxed(a: U32, b: U32) -> TransferRes:
  MkTransfer{MkPairU32{a, b}, 1n}

# Optimized unboxed ret2 direct register transfer (0 heap allocations)
def transfer_ret2(a: U32, b: U32) -> TransferRes:
  +w = u32_pack64(a, b)
  MkTransfer{MkPairU32{u32_unpack_fst(w), u32_unpack_snd(w)}, 0n}

def tr_fst(r: TransferRes) -> U32:
  match r:
    case MkTransfer{MkPairU32{x, _}, _}:
      x

def tr_snd(r: TransferRes) -> U32:
  match r:
    case MkTransfer{MkPairU32{_, y}, _}:
      y

def tr_allocs(r: TransferRes) -> Nat:
  match r:
    case MkTransfer{_, k}:
      k

# Law 1a: ret2 preserves `fst` identically to heap Pair boxing+unpacking
law law_ret2_fst:
  for +a: U32
  for +b: U32
  {tr_fst(transfer_ret2(a, b)) == tr_fst(transfer_boxed(a, b)) : U32}

def law_ret2_fst(a, b):
  match a b:
    case U32{wa} U32{wb}:
      %word_take_pack(32n, 32n, wa, wb) : {U32{word_take(32n, 32n, word_pack(32n, 32n, wa, wb))} == U32{_} : U32}
      {==}

# Law 1b: ret2 preserves `snd` identically to heap Pair boxing+unpacking
law law_ret2_snd:
  for +a: U32
  for +b: U32
  {tr_snd(transfer_ret2(a, b)) == tr_snd(transfer_boxed(a, b)) : U32}

def law_ret2_snd(a, b):
  match a b:
    case U32{wa} U32{wb}:
      %word_drop_pack(32n, 32n, wa, wb) : {U32{word_drop(32n, 32n, word_pack(32n, 32n, wa, wb))} == U32{_} : U32}
      {==}

# Law 1c: ret2 performs exactly 0 heap allocations
law law_ret2_zero_allocs:
  for +a: U32
  for +b: U32
  {tr_allocs(transfer_ret2(a, b)) == 0n : Nat}

def law_ret2_zero_allocs(a, b):
  {==}


# =============================================================================
# LAW 2: Unique-Slot In-Place Reuse (`IReuse`)
# =============================================================================
# On an abstract heap of k-field cells, consuming a unique cell (rc == 1n) and
# overwriting its fields in place produces the exact same observable heap state
# as `free + alloc`, with 0 net heap allocations and 0 frees.

type Cell is Data:
  FreeCell{}
  LiveCell{rc: Nat, tag: Nat, f0: U32, f1: U32}

type Heap is Data:
  HNil{}
  HCon{head: Cell, tail: Heap}

type HeapStep is Data:
  MkHeapStep{heap: Heap, allocs: Nat, frees: Nat}

def heap_read(h: Heap, addr: Nat) -> Cell:
  match h addr:
    case HNil{} _:
      FreeCell{}
    case HCon{c, _} 0n:
      c
    case HCon{_, t} 1n+p:
      heap_read(t, p)

def heap_write(h: Heap, addr: Nat, c: Cell) -> Heap:
  match h addr:
    case HNil{} _:
      HNil{}
    case HCon{_, t} 0n:
      HCon{c, t}
    case HCon{x, t} 1n+p:
      HCon{x, heap_write(t, p, c)}

# Reference semantics: free the unique cell (rc == 1n), then allocate a new cell
# in the same slot (1 free + 1 alloc).
def heap_free_unique(h: Heap, addr: Nat) -> Heap:
  heap_write(h, addr, FreeCell{})

def heap_alloc_at(h: Heap, addr: Nat, tag: Nat, f0: U32, f1: U32) -> Heap:
  heap_write(h, addr, LiveCell{1n, tag, f0, f1})

def step_free_alloc(h: Heap, +addr: Nat, tag: Nat, f0: U32, f1: U32) -> HeapStep:
  h1 = heap_free_unique(h, addr)
  h2 = heap_alloc_at(h1, addr, tag, f0, f1)
  MkHeapStep{h2, 1n, 1n}

# Optimized IReuse semantics: overwrite the unique cell in place (0 allocs, 0 frees).
def step_ireuse(h: Heap, addr: Nat, tag: Nat, f0: U32, f1: U32) -> HeapStep:
  h1 = heap_write(h, addr, LiveCell{1n, tag, f0, f1})
  MkHeapStep{h1, 0n, 0n}

def hs_heap(s: HeapStep) -> Heap:
  match s:
    case MkHeapStep{h, _, _}:
      h

def hs_allocs(s: HeapStep) -> Nat:
  match s:
    case MkHeapStep{_, a, _}:
      a

def hs_frees(s: HeapStep) -> Nat:
  match s:
    case MkHeapStep{_, _, f}:
      f

# Structural induction on (h, addr): writing c1 then c2 at the same slot equals
# writing c2 directly (overwrite absorbs the intermediate FreeCell write).
law heap_write_overwrite:
  for  h: Heap
  for +addr: Nat
  for  c1: Cell
  for +c2: Cell
  {heap_write(heap_write(h, addr, c1), addr, c2) == heap_write(h, addr, c2) : Heap}

def heap_write_overwrite(h, addr, c1, c2):
  match h addr:
    case HNil{} _:
      {==}
    case HCon{_, _} 0n:
      {==}
    case HCon{+x, t} 1n+p:
      %heap_write_overwrite(t, p, c1, c2) : {HCon{x, heap_write(heap_write(t, p, c1), p, c2)} == HCon{x, _} : Heap}
      {==}

# Law 2a: IReuse produces the exact same heap state as free + alloc
law law_ireuse_heap_eq:
  for  h: Heap
  for +addr: Nat
  for +tag: Nat
  for +f0: U32
  for +f1: U32
  {hs_heap(step_ireuse(h, addr, tag, f0, f1)) == hs_heap(step_free_alloc(h, addr, tag, f0, f1)) : Heap}

def law_ireuse_heap_eq(h, addr, tag, f0, f1):
  Equal.sym(
    Heap,
    heap_write(heap_write(h, addr, FreeCell{}), addr, LiveCell{1n, tag, f0, f1}),
    heap_write(h, addr, LiveCell{1n, tag, f0, f1}),
    heap_write_overwrite(h, addr, FreeCell{}, LiveCell{1n, tag, f0, f1})
  )

# Law 2b: Every observable slot query `q` sees the exact same Cell
law law_ireuse_obs_eq:
  for  h: Heap
  for +addr: Nat
  for +q: Nat
  for +tag: Nat
  for +f0: U32
  for +f1: U32
  {heap_read(hs_heap(step_ireuse(h, addr, tag, f0, f1)), q) == heap_read(hs_heap(step_free_alloc(h, addr, tag, f0, f1)), q) : Cell}

def law_ireuse_obs_eq(h, addr, q, tag, f0, f1):
  Equal.cong(
    Heap,
    Cell,
    hp => heap_read(hp, q),
    hs_heap(step_ireuse(h, addr, tag, f0, f1)),
    hs_heap(step_free_alloc(h, addr, tag, f0, f1)),
    law_ireuse_heap_eq(h, addr, tag, f0, f1)
  )

# Law 2c: IReuse performs 0 net heap allocations and 0 frees
law law_ireuse_zero_allocs:
  for  h: Heap
  for  addr: Nat
  for  tag: Nat
  for  f0: U32
  for  f1: U32
  {hs_allocs(step_ireuse(h, addr, tag, f0, f1)) == 0n : Nat}

def law_ireuse_zero_allocs(h, addr, tag, f0, f1):
  {==}

law law_ireuse_zero_frees:
  for  h: Heap
  for  addr: Nat
  for  tag: Nat
  for  f0: U32
  for  f1: U32
  {hs_frees(step_ireuse(h, addr, tag, f0, f1)) == 0n : Nat}

def law_ireuse_zero_frees(h, addr, tag, f0, f1):
  {==}


# =============================================================================
# LAW 3: Read-Only Borrow-Walk Erasure (`borrow`)
# =============================================================================
# On an inductive expression Tree (modeling `symreg:eval`) and an inductive
# bucket Chain (modeling `hashmap:has`), erasing balanced `keep` (+1) / `sink` (-1)
# RC operations on read-only recursive traversals produces the exact same return
# value and exact same final refcount (`rc' == rc`) with 0 RC operations.

type BTree is Data:
  BLeaf{v: Nat}
  BNode{l: BTree, r: BTree}

type Chain is Data:
  CEnd{}
  CLink{key: Nat, rest: Chain}

type WalkRes is Data:
  MkWalkRes{val: Nat, rc: Nat, ops: Nat}

def wr_val(w: WalkRes) -> Nat:
  match w:
    case MkWalkRes{v, _, _}:
      v

def wr_rc(w: WalkRes) -> Nat:
  match w:
    case MkWalkRes{_, r, _}:
      r

def wr_ops(w: WalkRes) -> Nat:
  match w:
    case MkWalkRes{_, _, o}:
      o

# Balanced RC primitives: keep increments rc (+1), sink decrements rc (-1).
def rc_keep(rc: Nat) -> Nat:
  1n+rc

def rc_sink(rc: Nat) -> Nat:
  match rc:
    case 0n:
      0n
    case 1n+p:
      p

# Reference RC-tracked tree walk (keep on entry, sink on exit, +2 RC ops per node)
def walk_tree_rc(t: BTree, rc: Nat) -> WalkRes:
  match t:
    case BLeaf{v}:
      MkWalkRes{v, rc_sink(rc_keep(rc)), 2n}
    case BNode{l, r}:
      +wl = walk_tree_rc(l, rc_keep(rc))
      +wr = walk_tree_rc(r, wr_rc(wl))
      MkWalkRes{Nat.add(wr_val(wl), wr_val(wr)), rc_sink(wr_rc(wr)), Nat.add(2n, Nat.add(wr_ops(wl), wr_ops(wr)))}

# Borrow-erased tree walk (0 RC ops, rc unchanged)
def walk_tree_borrow(t: BTree, rc: Nat) -> WalkRes:
  match t:
    case BLeaf{v}:
      MkWalkRes{v, rc, 0n}
    case BNode{l, r}:
      +wl = walk_tree_borrow(l, rc)
      +wr = walk_tree_borrow(r, wr_rc(wl))
      MkWalkRes{Nat.add(wr_val(wl), wr_val(wr)), wr_rc(wr), 0n}

# Law 3a (Tree): Balanced RC walk restores the exact initial refcount (rc' == rc)
law law_borrow_tree_rc:
  for  t: BTree
  for +rc: Nat
  {wr_rc(walk_tree_rc(t, rc)) == rc : Nat}

def law_borrow_tree_rc(t, rc):
  match t:
    case BLeaf{v}:
      {==}
    case BNode{+l, r}:
      %Equal.sym(Nat, wr_rc(walk_tree_rc(r, wr_rc(walk_tree_rc(l, 1n+rc)))), wr_rc(walk_tree_rc(l, 1n+rc)), law_borrow_tree_rc(r, wr_rc(walk_tree_rc(l, 1n+rc)))) : {rc_sink(_) == rc : Nat}
      %Equal.sym(Nat, wr_rc(walk_tree_rc(l, 1n+rc)), 1n+rc, law_borrow_tree_rc(l, 1n+rc)) : {rc_sink(_) == rc : Nat}
      {==}

# Law 3b (Tree): Borrow-erased walk preserves exact refcount (rc' == rc)
law law_borrow_tree_erased_rc:
  for  t: BTree
  for +rc: Nat
  {wr_rc(walk_tree_borrow(t, rc)) == rc : Nat}

def law_borrow_tree_erased_rc(t, rc):
  match t:
    case BLeaf{v}:
      {==}
    case BNode{+l, r}:
      %Equal.sym(Nat, wr_rc(walk_tree_borrow(r, wr_rc(walk_tree_borrow(l, rc)))), wr_rc(walk_tree_borrow(l, rc)), law_borrow_tree_erased_rc(r, wr_rc(walk_tree_borrow(l, rc)))) : {_ == rc : Nat}
      %Equal.sym(Nat, wr_rc(walk_tree_borrow(l, rc)), rc, law_borrow_tree_erased_rc(l, rc)) : {_ == rc : Nat}
      {==}

# Law 3c (Tree): Borrow-erased walk returns the exact same value as RC walk
law law_borrow_tree_val:
  for  t: BTree
  for +rc1: Nat
  for +rc2: Nat
  {wr_val(walk_tree_borrow(t, rc1)) == wr_val(walk_tree_rc(t, rc2)) : Nat}

def law_borrow_tree_val(t, rc1, rc2):
  match t:
    case BLeaf{v}:
      {==}
    case BNode{+l, +r}:
      %Equal.sym(Nat, wr_val(walk_tree_borrow(l, rc1)), wr_val(walk_tree_rc(l, 1n+rc2)), law_borrow_tree_val(l, rc1, 1n+rc2)) : {Nat.add(_, wr_val(walk_tree_borrow(r, wr_rc(walk_tree_borrow(l, rc1))))) == Nat.add(wr_val(walk_tree_rc(l, 1n+rc2)), wr_val(walk_tree_rc(r, wr_rc(walk_tree_rc(l, 1n+rc2))))) : Nat}
      %Equal.sym(Nat, wr_val(walk_tree_borrow(r, wr_rc(walk_tree_borrow(l, rc1)))), wr_val(walk_tree_rc(r, wr_rc(walk_tree_rc(l, 1n+rc2)))), law_borrow_tree_val(r, wr_rc(walk_tree_borrow(l, rc1)), wr_rc(walk_tree_rc(l, 1n+rc2)))) : {Nat.add(wr_val(walk_tree_rc(l, 1n+rc2)), _) == Nat.add(wr_val(walk_tree_rc(l, 1n+rc2)), wr_val(walk_tree_rc(r, wr_rc(walk_tree_rc(l, 1n+rc2))))) : Nat}
      {==}

# Law 3d (Tree): Borrow-erased walk performs exactly 0 RC ops
law law_borrow_tree_zero_ops:
  for t: BTree
  for rc: Nat
  {wr_ops(walk_tree_borrow(t, rc)) == 0n : Nat}

def law_borrow_tree_zero_ops(t, rc):
  match t:
    case BLeaf{v}:
      {==}
    case BNode{l, r}:
      {==}

# Chain lookup model (`hashmap:has`): returns 1n if target is found, 0n otherwise.
def chain_rc_pick(hit: Bool, rc1: Nat, +wr: WalkRes) -> WalkRes:
  match hit:
    case True{}:
      MkWalkRes{1n, rc_sink(rc1), 2n}
    case False{}:
      MkWalkRes{wr_val(wr), rc_sink(wr_rc(wr)), Nat.add(2n, wr_ops(wr))}

def walk_chain_rc(c: Chain, +target: Nat, +rc: Nat) -> WalkRes:
  match c:
    case CEnd{}:
      MkWalkRes{0n, rc_sink(rc_keep(rc)), 2n}
    case CLink{k, rest}:
      chain_rc_pick(Nat.is_eq(k, target), rc_keep(rc), walk_chain_rc(rest, target, rc_keep(rc)))

def chain_borrow_pick(hit: Bool, rc: Nat, wr: WalkRes) -> WalkRes:
  match hit:
    case True{}:
      MkWalkRes{1n, rc, 0n}
    case False{}:
      wr

def walk_chain_borrow(c: Chain, +target: Nat, +rc: Nat) -> WalkRes:
  match c:
    case CEnd{}:
      MkWalkRes{0n, rc, 0n}
    case CLink{k, rest}:
      chain_borrow_pick(Nat.is_eq(k, target), rc, walk_chain_borrow(rest, target, rc))

# Law 3e (Chain): RC walk restores exact refcount (rc' == rc)
law chain_rc_pick_rc:
  for  hit: Bool
  for +rc: Nat
  for +wr: WalkRes
  for  ih: {wr_rc(wr) == 1n+rc : Nat}
  {wr_rc(chain_rc_pick(hit, 1n+rc, wr)) == rc : Nat}

def chain_rc_pick_rc(hit, rc, wr, ih):
  match hit:
    case True{}:
      {==}
    case False{}:
      %Equal.sym(Nat, wr_rc(wr), 1n+rc, ih) : {rc_sink(_) == rc : Nat}
      {==}

law law_borrow_chain_rc:
  for  c: Chain
  for +target: Nat
  for +rc: Nat
  {wr_rc(walk_chain_rc(c, target, rc)) == rc : Nat}

def law_borrow_chain_rc(c, target, rc):
  match c:
    case CEnd{}:
      {==}
    case CLink{k, +rest}:
      chain_rc_pick_rc(Nat.is_eq(k, target), rc, walk_chain_rc(rest, target, 1n+rc), law_borrow_chain_rc(rest, target, 1n+rc))

# Law 3f (Chain): Borrow-erased chain walk returns the exact same value as RC walk
law chain_pick_val:
  for  hit: Bool
  for +rc1: Nat
  for +rc2: Nat
  for +wb: WalkRes
  for +wr: WalkRes
  for  ih: {wr_val(wb) == wr_val(wr) : Nat}
  {wr_val(chain_borrow_pick(hit, rc1, wb)) == wr_val(chain_rc_pick(hit, 1n+rc2, wr)) : Nat}

def chain_pick_val(hit, rc1, rc2, wb, wr, ih):
  match hit:
    case True{}:
      {==}
    case False{}:
      ih

law law_borrow_chain_val:
  for  c: Chain
  for +target: Nat
  for +rc1: Nat
  for +rc2: Nat
  {wr_val(walk_chain_borrow(c, target, rc1)) == wr_val(walk_chain_rc(c, target, rc2)) : Nat}

def law_borrow_chain_val(c, target, rc1, rc2):
  match c:
    case CEnd{}:
      {==}
    case CLink{k, +rest}:
      chain_pick_val(Nat.is_eq(k, target), rc1, rc2, walk_chain_borrow(rest, target, rc1), walk_chain_rc(rest, target, 1n+rc2), law_borrow_chain_val(rest, target, rc1, 1n+rc2))

# Law 3g (Chain): Borrow-erased chain walk performs 0 RC ops
law chain_pick_zero_ops:
  for  hit: Bool
  for  rc: Nat
  for  wb: WalkRes
  for  ih: {wr_ops(wb) == 0n : Nat}
  {wr_ops(chain_borrow_pick(hit, rc, wb)) == 0n : Nat}

def chain_pick_zero_ops(hit, rc, wb, ih):
  match hit:
    case True{}:
      {==}
    case False{}:
      ih

law law_borrow_chain_zero_ops:
  for  c: Chain
  for +target: Nat
  for +rc: Nat
  {wr_ops(walk_chain_borrow(c, target, rc)) == 0n : Nat}

def law_borrow_chain_zero_ops(c, target, rc):
  match c:
    case CEnd{}:
      {==}
    case CLink{k, +rest}:
      chain_pick_zero_ops(Nat.is_eq(k, target), rc, walk_chain_borrow(rest, target, rc), law_borrow_chain_zero_ops(rest, target, rc))


# =============================================================================
# LAW 4: Linear-Array Handle Hoist & Dead-Swap-Old-Load Erasure
# =============================================================================
# On a unique linear array handle `ArrH{dp, len, data}` threaded through a
# Nat-counted loop performing `Array.get` / `Array.swap` without resizing or
# aliasing:
#   - Hoisting `(dp, len)` to the loop preheader produces the exact same final
#     array state (`==`) as decoding the handle on every iteration, with 0
#     per-iteration tag/len decodes (`decodes == 0n`).
#   - When the old value returned by `Array.swap` is unused (`dead_old`),
#     eliding the old-value read produces the exact same final array state
#     (`==`) with 0 dead old-value loads (`dead_loads == 0n`).

type ArrData is Data:
  ANil{}
  ACon{head: U32, tail: ArrData}

type ArrH is Data:
  ArrH{dp: Nat, len: Nat, data: ArrData}

type SwapPair is Data:
  MkSwapPair{data: ArrData, old: U32}

type ArrLoopRes is Data:
  MkArrLoopRes{arr: ArrH, decodes: Nat, dead_loads: Nat}

def arr_get_data(d: ArrData, idx: Nat) -> U32:
  match d idx:
    case ANil{} _:
      0
    case ACon{x, _} 0n:
      x
    case ACon{_, t} 1n+p:
      arr_get_data(t, p)

def arr_set_data(d: ArrData, idx: Nat, v: U32) -> ArrData:
  match d idx:
    case ANil{} _:
      ANil{}
    case ACon{_, t} 0n:
      ACon{v, t}
    case ACon{x, t} 1n+p:
      ACon{x, arr_set_data(t, p, v)}

# Reference Array.swap: reads old value at idx, writes new value, returns (data', old)
def arr_swap_with_old(+data: ArrData, +idx: Nat, v: U32) -> SwapPair:
  MkSwapPair{arr_set_data(data, idx, v), arr_get_data(data, idx)}

def sp_data(sp: SwapPair) -> ArrData:
  match sp:
    case MkSwapPair{d, _}:
      d

def alr_arr(r: ArrLoopRes) -> ArrH:
  match r:
    case MkArrLoopRes{a, _, _}:
      a

def alr_decodes(r: ArrLoopRes) -> Nat:
  match r:
    case MkArrLoopRes{_, d, _}:
      d

def alr_dead_loads(r: ArrLoopRes) -> Nat:
  match r:
    case MkArrLoopRes{_, _, l}:
      l

def alr_add_costs(r: ArrLoopRes, d: Nat, l: Nat) -> ArrLoopRes:
  match r:
    case MkArrLoopRes{a, decs, dloads}:
      MkArrLoopRes{a, Nat.add(d, decs), Nat.add(l, dloads)}

# Reference unhoisted loop: decodes ArrH on every iteration (2 decodes/iter:
# Array.get + Array.swap) and loads the unused old value on Array.swap (1 dead_load/iter).
def arr_loop_ref(+n: Nat, h: ArrH, +delta: U32) -> ArrLoopRes:
  match n:
    case 0n:
      MkArrLoopRes{h, 0n, 0n}
    case 1n+p:
      match h:
        case ArrH{dp, len, +data}:
          v = arr_get_data(data, p)
          sp = arr_swap_with_old(data, p, U32.add(v, delta))
          alr_add_costs(arr_loop_ref(p, ArrH{dp, len, sp_data(sp)}, delta), 2n, 1n)

# Hoisted inner loop (preheader decoded dp/len once; still loads dead old value)
def arr_loop_hoisted_with_old(+n: Nat, +data: ArrData, +delta: U32) -> ArrData:
  match n:
    case 0n:
      data
    case 1n+p:
      v = arr_get_data(data, p)
      sp = arr_swap_with_old(data, p, U32.add(v, delta))
      arr_loop_hoisted_with_old(p, sp_data(sp), delta)

def arr_loop_hoisted(+n: Nat, h: ArrH, delta: U32) -> ArrLoopRes:
  match h:
    case ArrH{dp, len, data}:
      MkArrLoopRes{ArrH{dp, len, arr_loop_hoisted_with_old(n, data, delta)}, 0n, n}

# Hoisted + dead-swap-old-load erased inner loop (0 per-iter decodes, 0 dead old loads)
def arr_loop_hoisted_no_old(+n: Nat, +data: ArrData, +delta: U32) -> ArrData:
  match n:
    case 0n:
      data
    case 1n+p:
      v = arr_get_data(data, p)
      d1 = arr_set_data(data, p, U32.add(v, delta))
      arr_loop_hoisted_no_old(p, d1, delta)

def arr_loop_hoisted_erased(+n: Nat, h: ArrH, delta: U32) -> ArrLoopRes:
  match h:
    case ArrH{dp, len, data}:
      MkArrLoopRes{ArrH{dp, len, arr_loop_hoisted_no_old(n, data, delta)}, 0n, 0n}

# Helper: adding cost counters does not change the final array state
law alr_arr_add_costs:
  for r: ArrLoopRes
  for d: Nat
  for l: Nat
  {alr_arr(r) == alr_arr(alr_add_costs(r, d, l)) : ArrH}

def alr_arr_add_costs(r, d, l):
  match r:
    case MkArrLoopRes{a, decs, dloads}:
      {==}

# Structural induction on n: hoisting (dp, len) preserves the exact final ArrH
law law_arr_hoist_inner:
  for +n: Nat
  for +dp: Nat
  for +len: Nat
  for +data: ArrData
  for +delta: U32
  {ArrH{dp, len, arr_loop_hoisted_with_old(n, data, delta)} == alr_arr(arr_loop_ref(n, ArrH{dp, len, data}, delta)) : ArrH}

def law_arr_hoist_inner(n, dp, len, data, delta):
  match n:
    case 0n:
      {==}
    case 1n+p:
      +d1 = sp_data(arr_swap_with_old(data, p, U32.add(arr_get_data(data, p), delta)))
      %alr_arr_add_costs(arr_loop_ref(p, ArrH{dp, len, d1}, delta), 2n, 1n) : {ArrH{dp, len, arr_loop_hoisted_with_old(p, d1, delta)} == _ : ArrH}
      law_arr_hoist_inner(p, dp, len, d1, delta)

# Law 4a: Preheader handle hoist produces the exact same final array state
law law_arr_hoist_eq:
  for +n: Nat
  for  h: ArrH
  for +delta: U32
  {alr_arr(arr_loop_hoisted(n, h, delta)) == alr_arr(arr_loop_ref(n, h, delta)) : ArrH}

def law_arr_hoist_eq(n, h, delta):
  match h:
    case ArrH{dp, len, data}:
      law_arr_hoist_inner(n, dp, len, data, delta)

# Law 4b: Preheader handle hoist performs 0 per-iteration tag/len decodes
law law_arr_hoist_zero_decodes:
  for +n: Nat
  for  h: ArrH
  for  delta: U32
  {alr_decodes(arr_loop_hoisted(n, h, delta)) == 0n : Nat}

def law_arr_hoist_zero_decodes(n, h, delta):
  match h:
    case ArrH{dp, len, data}:
      {==}

# Structural induction on n: eliding dead old-value loads preserves ArrData
law law_arr_dead_swap_data_eq:
  for +n: Nat
  for +data: ArrData
  for +delta: U32
  {arr_loop_hoisted_no_old(n, data, delta) == arr_loop_hoisted_with_old(n, data, delta) : ArrData}

def law_arr_dead_swap_data_eq(n, data, delta):
  match n:
    case 0n:
      {==}
    case 1n+p:
      law_arr_dead_swap_data_eq(p, arr_set_data(data, p, U32.add(arr_get_data(data, p), delta)), delta)

# Law 4c: Hoisting + dead-swap-old-load erasure produces the exact same final ArrH
law law_arr_dead_swap_eq:
  for +n: Nat
  for  h: ArrH
  for +delta: U32
  {alr_arr(arr_loop_hoisted_erased(n, h, delta)) == alr_arr(arr_loop_ref(n, h, delta)) : ArrH}

def law_arr_dead_swap_eq(n, h, delta):
  match h:
    case ArrH{+dp, +len, +data}:
      e1 = Equal.cong(
        ArrData,
        ArrH,
        d => ArrH{dp, len, d},
        arr_loop_hoisted_no_old(n, data, delta),
        arr_loop_hoisted_with_old(n, data, delta),
        law_arr_dead_swap_data_eq(n, data, delta)
      )
      e2 = law_arr_hoist_inner(n, dp, len, data, delta)
      Equal.trans(
        ArrH,
        ArrH{dp, len, arr_loop_hoisted_no_old(n, data, delta)},
        ArrH{dp, len, arr_loop_hoisted_with_old(n, data, delta)},
        alr_arr(arr_loop_ref(n, ArrH{dp, len, data}, delta)),
        e1,
        e2
      )

# Law 4d: Hoisted + dead-erased loop performs 0 per-iteration decodes
law law_arr_erased_zero_decodes:
  for +n: Nat
  for  h: ArrH
  for  delta: U32
  {alr_decodes(arr_loop_hoisted_erased(n, h, delta)) == 0n : Nat}

def law_arr_erased_zero_decodes(n, h, delta):
  match h:
    case ArrH{dp, len, data}:
      {==}

# Law 4e: Hoisted + dead-erased loop performs 0 dead old-value loads
law law_arr_erased_zero_dead_loads:
  for +n: Nat
  for  h: ArrH
  for  delta: U32
  {alr_dead_loads(arr_loop_hoisted_erased(n, h, delta)) == 0n : Nat}

def law_arr_erased_zero_dead_loads(n, h, delta):
  match h:
    case ArrH{dp, len, data}:
      {==}


# =============================================================================
# Top-level Witness Pack
# =============================================================================

def sample_heap() -> Heap:
  HCon{LiveCell{1n, 0n, 10, 20}, HCon{LiveCell{1n, 1n, 30, 40}, HNil{}}}

def sample_tree() -> BTree:
  BNode{BLeaf{3n}, BNode{BLeaf{5n}, BLeaf{7n}}}

def sample_chain() -> Chain:
  CLink{2n, CLink{5n, CEnd{}}}

def sample_arr() -> ArrH:
  ArrH{100n, 4n, ACon{1, ACon{2, ACon{3, ACon{4, ANil{}}}}}}

def main() -> U32:
  _ = law_ret2_fst(42, 99)
  _ = law_ret2_snd(42, 99)
  _ = law_ret2_zero_allocs(42, 99)
  _ = law_ireuse_obs_eq(sample_heap(), 1n, 1n, 2n, 77, 88)
  _ = law_ireuse_zero_allocs(sample_heap(), 1n, 2n, 77, 88)
  _ = law_ireuse_zero_frees(sample_heap(), 1n, 2n, 77, 88)
  _ = law_borrow_tree_rc(sample_tree(), 3n)
  _ = law_borrow_tree_val(sample_tree(), 3n, 3n)
  _ = law_borrow_tree_zero_ops(sample_tree(), 3n)
  _ = law_borrow_chain_rc(sample_chain(), 5n, 2n)
  _ = law_borrow_chain_val(sample_chain(), 5n, 2n, 2n)
  _ = law_borrow_chain_zero_ops(sample_chain(), 5n, 2n)
  _ = law_arr_hoist_eq(4n, sample_arr(), 7)
  _ = law_arr_hoist_zero_decodes(4n, sample_arr(), 7)
  _ = law_arr_dead_swap_eq(4n, sample_arr(), 7)
  _ = law_arr_erased_zero_decodes(4n, sample_arr(), 7)
  _ = law_arr_erased_zero_dead_loads(4n, sample_arr(), 7)
  0
