# bend5k/lower.bend — Direct-First ANF/CFG Lowerer (Book -> IrProg)
# ==================================================================
type LowerRes is Data:
  LowerRes{ok: Bool, err: String, prog: IrProg}
# 16-Level U32 -> U32 Bit-Trie (0 = absent)
type U32Map is Data:
  UM0{}
  UML{val: U32}
  UMN{lo: U32Map, hi: U32Map}
def um_set_go(depth: Nat, +k: U32, v: U32, m: U32Map, is_lo: Bool) -> U32Map:
  match depth m is_lo:
    case 0n _ _: UML{v}
    case 1n+p UMN{lo, hi} True{}:
      +nxt = U32.shr(k)
      UMN{um_set_go(p, nxt, v, lo, U32.is_zero(U32.and(nxt, 1))), hi}
    case 1n+p UMN{lo, hi} False{}:
      +nxt = U32.shr(k)
      UMN{lo, um_set_go(p, nxt, v, hi, U32.is_zero(U32.and(nxt, 1)))}
    case 1n+p _ True{}:
      +nxt = U32.shr(k)
      UMN{um_set_go(p, nxt, v, UM0{}, U32.is_zero(U32.and(nxt, 1))), UM0{}}
    case 1n+p _ False{}:
      +nxt = U32.shr(k)
      UMN{UM0{}, um_set_go(p, nxt, v, UM0{}, U32.is_zero(U32.and(nxt, 1)))}
def um_set(m: U32Map, +k: U32, v: U32) -> U32Map:
  um_set_go(16n, k, v, m, U32.is_zero(U32.and(k, 1)))
def um_get_go(depth: Nat, +k: U32, m: U32Map, is_lo: Bool) -> U32:
  match depth m is_lo:
    case _ UM0{} _: 0
    case _ UML{v} _: v
    case 0n UMN{_, _} _: 0
    case 1n+p UMN{lo, hi} True{}:
      +nxt = U32.shr(k)
      um_get_go(p, nxt, lo, U32.is_zero(U32.and(nxt, 1)))
    case 1n+p UMN{lo, hi} False{}:
      +nxt = U32.shr(k)
      um_get_go(p, nxt, hi, U32.is_zero(U32.and(nxt, 1)))
def um_get(m: U32Map, +k: U32) -> U32:
  um_get_go(16n, k, m, U32.is_zero(U32.and(k, 1)))
# Embedded Base/Runtime Prelude (parsed into Book before Pass 1)
def b5k_prelude_src() -> String:
  "def Bool.not(b: Bool) -> Bool:\n  if b: False{} else: True{}\ndef Bool.and(a: Bool, b: Bool) -> Bool:\n  if a: b else: False{}\n" ++
  "def Bool.or(a: Bool, b: Bool) -> Bool:\n  if a: True{} else: b\ndef Bool.xor(a: Bool, b: Bool) -> Bool:\n  if a: Bool.not(b) else: b\n" ++
  "def Bool.to_u32(b: Bool) -> U32:\n  if b: 1 else: 0\ndef Bool.pick(-T: Data, b: Bool, t: T, f: T) -> T:\n  if b: t else: f\n" ++
  "def Char.to_u32(c: Char) -> U32:\n  c\ndef Char.from_u32(n: U32) -> Char:\n  n\ndef Char.show(c: Char) -> String:\n  SCon{c, SNil{}}\n" ++
  "def Char.cmp(a: Char, b: Char) -> Cmp:\n  Tuple{Tuple{a, b}, if U32.is_lt(a, b): LT{} else: if U32.is_gt(a, b): GT{} else: EQ{}}\n" ++
  "def Cmp.is_eq(c: Cmp) -> Bool:\n  match c:\n    case EQ{}: True{}\n    case _: False{}\n" ++
  "def Maybe.default(-q: Data, -A: Data, m: Maybe<A>, d: A) -> A:\n  match m:\n    case None{}: d\n    case Some{v}: v\n" ++
  "def List.append(-q: Data, -T: Data, a: List<T>, b: List<T>) -> List<T>:\n  match a:\n    case Nil{}: b\n    case Con{h, t}: Con{h, List.append(q, T, t, b)}\n" ++
  "def String.is_empty(s: String) -> Bool:\n  match s:\n    case SNil{}: True{}\n    case SCon{_, _}: False{}\n" ++
  "def String.length.go(s: String, acc: Nat) -> Nat:\n  match s:\n    case SNil{}: acc\n    case SCon{_, t}: String.length.go(t, U32.add(acc, 1))\n" ++
  "def String.length(s: String) -> Nat:\n  String.length.go(s, 0)\n" ++
  "def String.starts_with(s: String, p: String) -> Bool:\n  match p s:\n    case SNil{} _: True{}\n    case SCon{_, _} SNil{}: False{}\n    case SCon{c1, t1} SCon{c2, t2}: if U32.is_eq(c1, c2): String.starts_with(t2, t1) else: False{}\n" ++
  "def String.drop(s: String, n: Nat) -> String:\n  match n s:\n    case 0n _: s\n    case _ SNil{}: SNil{}\n    case 1n+p SCon{_, t}: String.drop(t, p)\n" ++
  "def String.append(a: String, b: String) -> String:\n  match a:\n    case SNil{}: b\n    case SCon{h, t}: SCon{h, String.append(t, b)}\n" ++
  "def String.reverse.go(s: String, acc: String) -> String:\n  match s:\n    case SNil{}: acc\n    case SCon{h, t}: String.reverse.go(t, SCon{h, acc})\n" ++
  "def String.reverse(s: String) -> String:\n  String.reverse.go(s, SNil{})\n" ++
  "def String.cmp(a: String, b: String) -> Cmp:\n  match a b:\n    case SNil{} SNil{}: EQ{}\n    case SNil{} SCon{_, _}: LT{}\n    case SCon{_, _} SNil{}: GT{}\n    case SCon{x, t1} SCon{y, t2}:\n      if U32.is_lt(x, y): LT{} else: if U32.is_gt(x, y): GT{} else: String.cmp(t1, t2)\n" ++
  "def String.eq(a: String, b: String) -> Bool:\n  match String.cmp(a, b):\n    case EQ{}: True{}\n    case _: False{}\n" ++
  "def U32.show.go(n: U32, acc: String) -> String:\n  if U32.is_zero(n): acc else: U32.show.go(U32.div(n, 10), SCon{U32.add(48, U32.mod(n, 10)), acc})\n" ++
  "def U32.show(n: U32) -> String:\n  if U32.is_zero(n): \"0\" else: U32.show.go(n, SNil{})\ndef F32.show(x: F32) -> String:\n  U32.show(F32.to_u32(x))\n" ++
  "def U32.read.go(s: String, acc: U32) -> Maybe<U32>:\n  match s:\n    case SNil{}: Some{acc}\n    case SCon{c, t}: U32.read.go(t, U32.add(U32.mul(acc, 10), U32.sub(c, 48)))\n" ++
  "def U32.read(s: String) -> Maybe<U32>:\n  match s:\n    case SNil{}: None{}\n    case SCon{c, t}: U32.read.go(t, U32.sub(c, 48))\n" ++
  "def U32.max(a: U32, b: U32) -> U32:\n  if U32.is_gt(a, b): a else: b\ndef U32.min(a: U32, b: U32) -> U32:\n  if U32.is_lt(a, b): a else: b\n" ++
  "def U32.log2.go(k: Nat, n: U32, b: Nat) -> Nat:\n  match k:\n    case 0n: b\n    case 1n+p:\n      s = U32.shln(1, p)\n      t = if U32.is_ne(U32.shrn(n, s), 0): s else: 0\n      U32.log2.go(p, U32.shrn(n, t), U32.add(b, t))\ndef U32.log2(n: U32) -> Nat:\n  U32.log2.go(5n, n, 0)\n" ++
  "def U32.cmp(a: U32, b: U32) -> Cmp:\n  if U32.is_lt(a, b): LT{} else: if U32.is_eq(a, b): EQ{} else: GT{}\n" ++
  "def Nat.add(a: Nat, b: Nat) -> Nat:\n  U32.add(a, b)\ndef Nat.sub(a: Nat, b: Nat) -> Nat:\n  if U32.is_lt(a, b): 0 else: U32.sub(a, b)\n" ++
  "def Nat.min(a: Nat, b: Nat) -> Nat:\n  if U32.is_lt(a, b): a else: b\ndef Nat.max(a: Nat, b: Nat) -> Nat:\n  if U32.is_gt(a, b): a else: b\n" ++
  "def Nat.mul(a: Nat, b: Nat) -> Nat:\n  U32.mul(a, b)\ndef Nat.double(a: Nat) -> Nat:\n  U32.add(a, a)\n" ++
  "def Nat.is_lt(a: Nat, b: Nat) -> Bool:\n  U32.is_lt(a, b)\ndef Nat.is_le(a: Nat, b: Nat) -> Bool:\n  U32.is_le(a, b)\n" ++
  "def Nat.is_gt(a: Nat, b: Nat) -> Bool:\n  U32.is_gt(a, b)\ndef Nat.is_ge(a: Nat, b: Nat) -> Bool:\n  U32.is_ge(a, b)\n" ++
  "def Nat.is_eq(a: Nat, b: Nat) -> Bool:\n  U32.is_eq(a, b)\ndef Nat.cmp(a: Nat, b: Nat) -> Cmp:\n  if U32.is_lt(a, b): LT{} else: if U32.is_eq(a, b): EQ{} else: GT{}\n" ++
  "def Nat.divmod(a: Nat, b: Nat) -> Nat:\n  if U32.is_zero(b): Tuple{0, a} else: Tuple{U32.div(a, b), U32.mod(a, b)}\n" ++
  "def Nat.show(n: Nat) -> String:\n  U32.show(n)\ndef Nat.read(s: String) -> Maybe<Nat>:\n  U32.read(s)\n" ++
  "def IO.pure(-A: Data, x: A) -> IO(A):\n  k => k(x)\ndef IO.bind(-A: Data, -B: Data, m: IO(A), f: A -> IO(B)) -> IO(B):\n  k => m(x => f(x)(k))\n" ++
  "def IO.print(s: String) -> IO(Unit):\n  k => __io_print(s, k)\ndef IO.print_err(s: String) -> IO(Unit):\n  k => __io_print_err(s, k)\n" ++
  "def IO.exit(c: U32) -> IO(Unit):\n  k => Exit{c}\ndef __b5k_seal_args(xs: List<String>) -> List<String>:\n  match xs:\n    case Nil{}: Nil{}\n    case Con{s, t}: Con{String.reverse(String.reverse(s)), __b5k_seal_args(t)}\ndef IO.args() -> IO(List<String>):\n  IO.bind(List<String>, List<String>, k => __io_args(k), xs => IO.pure(List<String>, __b5k_seal_args(xs)))\ndef IO.now() -> IO(U32):\n  k => __io_now(k)\n" ++
  "def File.open(p: String, m: String) -> IO(U32):\n  k => __file_open(p, m, k)\ndef File.read(f: U32, n: U32) -> IO(U32):\n  k => __file_read(f, n, k)\n" ++
  "def File.size(f: U32) -> IO(U32):\n  k => __file_size(f, k)\ndef File.write(f: U32, s: String) -> IO(U32):\n  k => __file_write(f, s, k)\n" ++
  "def File.write_bytes(f: U32, bs: List<U32>) -> IO(U32):\n  k => __file_write_bytes(f, bs, k)\ndef File.close(f: U32) -> IO(Unit):\n  k => __file_close(f, k)\n" ++
  "def __arr_mk(d: Nat, v: U32) -> Array<U32>:\n  match d:\n    case 0n: ALeaf{v}\n    case 1n+p: ANode{__arr_mk(p, v), __arr_mk(p, v)}\n" ++
  "def __arr_mk_len(n: U32, v: U32) -> Array<U32>:\n  if U32.is_le(n, 1): ALeaf{v} else: ANode{__arr_mk_len(U32.shr(n), v), __arr_mk_len(U32.shr(n), v)}\n" ++
  "def __arr_len(n: U32, v: U32) -> Array<U32>:\n  h = if U32.is_le(n, 1): 0 else: U32.shln(1, U32.sub(U32.log2(n), 1))\n  WCon{h, __arr_mk_len(n, v)}\n" ++
  "def Array.new(-T: Data, d: Nat, v: T) -> Array<T>:\n  h = if U32.is_zero(d): 0 else: U32.shln(1, U32.sub(d, 1))\n  WCon{h, __arr_mk(d, v)}\n" ++
  "def __arr_clean(a: Array<U32>) -> Array<U32>:\n  match a:\n    case MNode{l, r, _}: ANode{__arr_clean(l), __arr_clean(r)}\n    case MLeaf{v, _}: ALeaf{v}\n    case other: other\n" ++
  "def __arr_join(a: Array<U32>, b: Array<U32>) -> Array<U32>:\n  match a:\n    case MNode{l1, r1, _}:\n      match b:\n        case MNode{l2, r2, _}: MNode{__arr_join(l1, l2), __arr_join(r1, r2), 0}\n        case _: MNode{l1, r1, 0}\n    case MLeaf{v1, _}: MLeaf{v1, 0}\n    case _: b\n" ++
  "def Array.clone(-T: Data, a: Array<T>) -> Array<T>:\n  Tuple{a, a}\ndef Array.fork(-T: Data, a: Array<T>) -> Array<T>:\n  match a:\n    case WCon{h, t}:\n      c = WCon{h, __arr_clean(t)}\n      Tuple{c, c}\n    case other:\n      c = __arr_clean(other)\n      Tuple{c, c}\ndef Array.join(-T: Data, a: Array<T>, b: Array<T>) -> Array<T>:\n  match a b:\n    case WCon{h, t1} WCon{_, t2}: WCon{h, __arr_join(t1, t2)}\n    case x y: __arr_join(x, y)\n" ++
  "def __arr_get(a: Array<U32>, i: U32, h: U32) -> Array<U32>:\n  match a:\n    case ALeaf{v}: Tuple{ALeaf{v}, v}\n    case MLeaf{v, _}: Tuple{MLeaf{v, 0}, v}\n    case ANode{l, r}:\n      if U32.is_zero(U32.and(i, h)):\n        (l2, v) = __arr_get(l, i, U32.shr(h))\n        Tuple{ANode{l2, r}, v}\n      else:\n        (r2, v) = __arr_get(r, i, U32.shr(h))\n        Tuple{ANode{l, r2}, v}\n    case MNode{l, r, _}:\n      if U32.is_zero(U32.and(i, h)):\n        (l2, v) = __arr_get(l, i, U32.shr(h))\n        Tuple{MNode{l2, r, 0}, v}\n      else:\n        (r2, v) = __arr_get(r, i, U32.shr(h))\n        Tuple{MNode{l, r2, 0}, v}\n" ++
  "def __arr_get_raw(a: Array<U32>, i: U32) -> Array<U32>:\n  match a:\n    case ALeaf{v}: Tuple{ALeaf{v}, v}\n    case ANode{l, r}:\n      if U32.is_zero(U32.and(i, 1)):\n        (l2, v) = __arr_get_raw(l, U32.shr(i))\n        Tuple{ANode{l2, r}, v}\n      else:\n        (r2, v) = __arr_get_raw(r, U32.shr(i))\n        Tuple{ANode{l, r2}, v}\n" ++
  "def Array.get(-T: Data, a: Array<T>, i: U32) -> Array<T>:\n  match a:\n    case WCon{h, t}:\n      (t2, v) = __arr_get(t, i, h)\n      Tuple{WCon{h, t2}, v}\n    case other: __arr_get_raw(other, i)\n" ++
  "def Array.get_unchecked(-T: Data, a: Array<T>, i: U32) -> Array<T>:\n  Array.get(T, a, i)\n" ++
  "def __arr_set(a: Array<U32>, i: U32, h: U32, v: U32) -> Array<U32>:\n  match a:\n    case ALeaf{_}: MLeaf{v, 0}\n    case MLeaf{_, _}: MLeaf{v, 0}\n    case ANode{l, r}:\n      if U32.is_zero(U32.and(i, h)): MNode{__arr_set(l, i, U32.shr(h), v), r, 0}\n      else: MNode{l, __arr_set(r, i, U32.shr(h), v), 0}\n    case MNode{l, r, _}:\n      if U32.is_zero(U32.and(i, h)): MNode{__arr_set(l, i, U32.shr(h), v), r, 0}\n      else: MNode{l, __arr_set(r, i, U32.shr(h), v), 0}\n" ++
  "def __arr_set_raw(a: Array<U32>, i: U32, v: U32) -> Array<U32>:\n  match a:\n    case ALeaf{_}: ALeaf{v}\n    case ANode{l, r}:\n      if U32.is_zero(U32.and(i, 1)): ANode{__arr_set_raw(l, U32.shr(i), v), r}\n      else: ANode{l, __arr_set_raw(r, U32.shr(i), v)}\n" ++
  "def Array.set(-T: Data, a: Array<T>, i: U32, v: T) -> Array<T>:\n  match a:\n    case WCon{h, t}: WCon{h, __arr_set(t, i, h, v)}\n    case other: __arr_set_raw(other, i, v)\n" ++
  "def __arr_swap(a: Array<U32>, i: U32, h: U32, v: U32) -> Array<U32>:\n  match a:\n    case ALeaf{o}: Tuple{MLeaf{v, 0}, o}\n    case MLeaf{o, _}: Tuple{MLeaf{v, 0}, o}\n    case ANode{l, r}:\n      if U32.is_zero(U32.and(i, h)):\n        (l2, o) = __arr_swap(l, i, U32.shr(h), v)\n        Tuple{MNode{l2, r, 0}, o}\n      else:\n        (r2, o) = __arr_swap(r, i, U32.shr(h), v)\n        Tuple{MNode{l, r2, 0}, o}\n    case MNode{l, r, _}:\n      if U32.is_zero(U32.and(i, h)):\n        (l2, o) = __arr_swap(l, i, U32.shr(h), v)\n        Tuple{MNode{l2, r, 0}, o}\n      else:\n        (r2, o) = __arr_swap(r, i, U32.shr(h), v)\n        Tuple{MNode{l, r2, 0}, o}\n" ++
  "def __arr_swap_raw(a: Array<U32>, i: U32, v: U32) -> Array<U32>:\n  match a:\n    case ALeaf{o}: Tuple{ALeaf{v}, o}\n    case ANode{l, r}:\n      if U32.is_zero(U32.and(i, 1)):\n        (l2, o) = __arr_swap_raw(l, U32.shr(i), v)\n        Tuple{ANode{l2, r}, o}\n      else:\n        (r2, o) = __arr_swap_raw(r, U32.shr(i), v)\n        Tuple{ANode{l, r2}, o}\n" ++
  "def Array.swap(-T: Data, a: Array<T>, i: U32, v: T) -> Array<T>:\n  match a:\n    case WCon{h, t}:\n      (t2, o) = __arr_swap(t, i, h, v)\n      Tuple{WCon{h, t2}, o}\n    case other: __arr_swap_raw(other, i, v)\n" ++
  "def __arr_sz_raw(a: Array<U32>) -> Array<U32>:\n  match a:\n    case ALeaf{v}: Tuple{ALeaf{v}, 1}\n    case ANode{l, r}:\n      (l2, s) = __arr_sz_raw(l)\n      Tuple{ANode{l2, r}, U32.shl(s)}\n" ++
  "def Array.size(-T: Data, a: Array<T>) -> Array<T>:\n  match a:\n    case WCon{h, t}: Tuple{WCon{h, t}, if U32.is_zero(h): 1 else: U32.shl(h)}\n    case other: __arr_sz_raw(other)\n" ++
  "def __arr_toli(a: Array<U32>, acc: List<U32>) -> List<U32>:\n  match a:\n    case ALeaf{v}: Con{v, acc}\n    case MLeaf{v, _}: Con{v, acc}\n    case ANode{l, r}: __arr_toli(l, __arr_toli(r, acc))\n    case MNode{l, r, _}: __arr_toli(l, __arr_toli(r, acc))\n" ++
  "def Array.to_list(-T: Data, a: Array<T>) -> List<T>:\n  match a:\n    case WCon{_, t}: __arr_toli(t, Nil{})\n    case other: __arr_toli(other, Nil{})\n" ++
  "def Map.new(-q: Data, -V: Data) -> Map<V>:\n  MTip{}\n" ++
  "def Map.set(-q: Data, -V: Data, m: Map<V>, k: String, v: V) -> Map<V>:\n  match m:\n    case MTip{}: MNode{Tuple{k, v}, MTip{}, MTip{}}\n    case MNode{kv, l, r}:\n      (k0, v0) = kv\n      match String.cmp(k, k0):\n        case LT{}: MNode{Tuple{k0, v0}, Map.set(q, V, l, k, v), r}\n        case GT{}: MNode{Tuple{k0, v0}, l, Map.set(q, V, r, k, v)}\n        case EQ{}: MNode{Tuple{k, v}, l, r}\n" ++
  "def Map.get(-V: Data, d: V, m: Map<V>, k: String) -> Map<V>:\n  match m:\n    case MTip{}: Tuple{MTip{}, d}\n    case MNode{kv, l, r}:\n      (k0, v0) = kv\n      match String.cmp(k, k0):\n        case LT{}:\n          (l2, res) = Map.get(V, d, l, k)\n          Tuple{MNode{Tuple{k0, v0}, l2, r}, res}\n        case GT{}:\n          (r2, res) = Map.get(V, d, r, k)\n          Tuple{MNode{Tuple{k0, v0}, l, r2}, res}\n        case EQ{}: Tuple{MNode{Tuple{k0, v0}, l, r}, v0}\n" ++
  "def Map.del_min(m: Map<U32>) -> Map<U32>:\n  match m:\n    case MNode{kv, MTip{}, r}: Tuple{kv, r}\n    case MNode{kv, l, r}:\n      (mn, l2) = Map.del_min(l)\n      Tuple{mn, MNode{kv, l2, r}}\n" ++
  "def Map.del(-q: Data, -V: Data, m: Map<V>, k: String) -> Map<V>:\n  match m:\n    case MTip{}: MTip{}\n    case MNode{kv, l, r}:\n      (k0, v0) = kv\n      match String.cmp(k, k0):\n        case LT{}: MNode{Tuple{k0, v0}, Map.del(q, V, l, k), r}\n        case GT{}: MNode{Tuple{k0, v0}, l, Map.del(q, V, r, k)}\n        case EQ{}:\n          match l r:\n            case MTip{} _: r\n            case _ MTip{}: l\n            case _ _:\n              (mn, r2) = Map.del_min(r)\n              MNode{mn, l, r2}\n" ++
  "def Map.to_list.go(m: Map<U32>, acc: List<U32>) -> List<U32>:\n  match m:\n    case MTip{}: acc\n    case MNode{kv, l, r}: Map.to_list.go(l, Con{kv, Map.to_list.go(r, acc)})\n" ++
  "def Map.to_list(-q: Data, -V: Data, m: Map<V>) -> List<V>:\n  Map.to_list.go(m, Nil{})\n" ++
  "def Map.has(-q: Data, -V: Data, m: Map<V>, k: String) -> Map<V>:\n  match m:\n    case MTip{}: Tuple{MTip{}, False{}}\n    case MNode{kv, l, r}:\n      (k0, v0) = kv\n      match String.cmp(k, k0):\n        case LT{}:\n          (l2, h) = Map.has(q, V, l, k)\n          Tuple{MNode{Tuple{k0, v0}, l2, r}, h}\n        case GT{}:\n          (r2, h) = Map.has(q, V, r, k)\n          Tuple{MNode{Tuple{k0, v0}, l, r2}, h}\n        case EQ{}: Tuple{MNode{Tuple{k0, v0}, l, r}, True{}}\n" ++
  "def Map.pop_eq(l: Map<U32>, r: Map<U32>, v0: U32) -> Map<U32>:\n  match l r:\n    case MTip{} _: Tuple{r, Some{v0}}\n    case _ MTip{}: Tuple{l, Some{v0}}\n    case _ _:\n      (mn, r2) = Map.del_min(r)\n      Tuple{MNode{mn, l, r2}, Some{v0}}\n" ++
  "def Map.pop(-q: Data, -V: Data, m: Map<V>, k: String) -> Map<V>:\n  match m:\n    case MTip{}: Tuple{MTip{}, None{}}\n    case MNode{kv, l, r}:\n      (k0, v0) = kv\n      match String.cmp(k, k0):\n        case LT{}:\n          (l2, o) = Map.pop(q, V, l, k)\n          Tuple{MNode{Tuple{k0, v0}, l2, r}, o}\n        case GT{}:\n          (r2, o) = Map.pop(q, V, r, k)\n          Tuple{MNode{Tuple{k0, v0}, l, r2}, o}\n        case EQ{}: Map.pop_eq(l, r, v0)\n" ++
  "def Map.from_list.go(xs: List<U32>, m: Map<U32>) -> Map<U32>:\n  match xs:\n    case Nil{}: m\n    case Con{kv, t}:\n      (k, v) = kv\n      Map.from_list.go(t, Map.set(0, 0, m, k, v))\n" ++
  "def Map.from_list(-q: Data, -V: Data, xs: List<U32>) -> Map<V>:\n  Map.from_list.go(xs, MTip{})\n" ++
  "def Map.union(-q: Data, -V: Data, a: Map<V>, b: Map<V>) -> Map<V>:\n  Map.from_list.go(Map.to_list(q, V, b), a)\n" ++
  "def Map.keys.go(m: Map<U32>, acc: List<String>) -> List<String>:\n  match m:\n    case MTip{}: acc\n    case MNode{kv, l, r}:\n      (k, v) = kv\n      Map.keys.go(l, Con{k, Map.keys.go(r, acc)})\n" ++
  "def Map.keys(-q: Data, -V: Data, m: Map<V>) -> List<String>:\n  Map.keys.go(m, Nil{})\n" ++
  "def Map.values.go(m: Map<U32>, acc: List<U32>) -> List<U32>:\n  match m:\n    case MTip{}: acc\n    case MNode{kv, l, r}:\n      (k, v) = kv\n      Map.values.go(l, Con{v, Map.values.go(r, acc)})\n" ++
  "def Map.values(-q: Data, -V: Data, m: Map<V>) -> List<V>:\n  Map.values.go(m, Nil{})\n" ++
  "def Set.new() -> Map<Unit>:\n  MTip{}\ndef Set.add(s: Map<Unit>, k: String) -> Map<Unit>:\n  Map.set(0, 0, s, k, Unit{})\n" ++
  "def Set.has(s: Map<Unit>, k: String) -> Map<Unit>:\n  Map.has(0, 0, s, k)\ndef Set.del(s: Map<Unit>, k: String) -> Map<Unit>:\n  Map.del(0, 0, s, k)\n" ++
  "def Set.to_list(s: Map<Unit>) -> List<String>:\n  Map.keys(0, 0, s)\n"
# Lowering Environment & Pass 1 Tables
type CoreCtorSpec is Data:
  CoreCtorSpec{name: String, arity: U32}
def low_core_specs() -> List<&2, CoreCtorSpec>:
  [CoreCtorSpec{"SNil", 0}, CoreCtorSpec{"SCon", 2}, CoreCtorSpec{"WNil", 0}, CoreCtorSpec{"WCon", 2}, CoreCtorSpec{"Nil", 0}, CoreCtorSpec{"Con", 2}, CoreCtorSpec{"Tuple", 2}, CoreCtorSpec{"Unit", 0}, CoreCtorSpec{"None", 0}, CoreCtorSpec{"Some", 1}, CoreCtorSpec{"Fail", 1}, CoreCtorSpec{"Done", 1}, CoreCtorSpec{"Emit", 2}, CoreCtorSpec{"Halt", 1}, CoreCtorSpec{"True", 0}, CoreCtorSpec{"LT", 0}, CoreCtorSpec{"EQ", 0}, CoreCtorSpec{"GT", 0}, CoreCtorSpec{"False", 0}, CoreCtorSpec{"Pair", 2}, CoreCtorSpec{"Inl", 1}, CoreCtorSpec{"Inr", 1}, CoreCtorSpec{"ALeaf", 1}, CoreCtorSpec{"ANode", 2}, CoreCtorSpec{"MTip", 0}, CoreCtorSpec{"MLeaf", 2}, CoreCtorSpec{"MNode", 3}, CoreCtorSpec{"Exit", 1}, CoreCtorSpec{"IO.print", 2}, CoreCtorSpec{"IO.print_err", 2}, CoreCtorSpec{"IO.args", 1}, CoreCtorSpec{"IO.now", 1}, CoreCtorSpec{"File.open", 3}, CoreCtorSpec{"File.read", 3}, CoreCtorSpec{"File.size", 2}, CoreCtorSpec{"File.write", 3}, CoreCtorSpec{"File.write_bytes", 3}, CoreCtorSpec{"File.close", 2}, CoreCtorSpec{"__io_emit", 0}]
type CtorTabAcc is Data:
  CtorTabAcc{syms: SymTab, next_cid: U32, by_sym: U32Map, ctors_rev: List<&2, IrCtor>}
def low_seed_core_one(sr: SymRes, name: String, ar: U32, +cid: U32, by_sym: U32Map, rev: List<&2, IrCtor>) -> CtorTabAcc:
  match sr:
    case SymRes{s2, sym}: CtorTabAcc{s2, U32.add(cid, 1), um_set(by_sym, sym, U32.add(cid, 1)), Con{IrCtor{cid, name, ar, False{}}, rev}}
def low_seed_core(specs: List<&2, CoreCtorSpec>, acc: CtorTabAcc) -> CtorTabAcc:
  match specs acc:
    case Nil{} _: acc
    case Con{CoreCtorSpec{+nm, ar}, t} CtorTabAcc{syms, cid, by_sym, rev}:
      low_seed_core(t, low_seed_core_one(symtab_intern(syms, nm), nm, ar, cid, by_sym, rev))
def low_add_ctor_one(has: Bool, +sym: U32, fields: List<&2, Param>, acc: CtorTabAcc) -> CtorTabAcc:
  match has acc:
    case True{} a: a
    case False{} CtorTabAcc{+syms, +cid, by_sym, rev}:
      CtorTabAcc{syms, U32.add(cid, 1), um_set(by_sym, sym, U32.add(cid, 1)), Con{IrCtor{cid, symtab_name(syms, sym), b5k_list_len(Param, fields), False{}}, rev}}
def low_add_ctors(cs: List<&2, CtorDef>, acc: CtorTabAcc) -> CtorTabAcc:
  match cs acc:
    case Nil{} a: a
    case Con{CtorDef{+sym, _, fields}, t} CtorTabAcc{syms, cid, +by_sym, rev}:
      low_add_ctors(t, low_add_ctor_one(U32.is_ne(um_get(by_sym, sym), 0), sym, fields, CtorTabAcc{syms, cid, by_sym, rev}))
def low_add_types(ts: List<&2, TypeDef>, acc: CtorTabAcc) -> CtorTabAcc:
  match ts:
    case Nil{}: acc
    case Con{TypeDef{_, _, _, cs}, t}: low_add_types(t, low_add_ctors(cs, acc))
def low_param_arity_go(ps: List<&2, Param>, acc: U32) -> U32:
  match ps:
    case Nil{}: acc
    case Con{Param{_, _, erased, _}, t}:
      match erased:
        case True{}: low_param_arity_go(t, acc)
        case False{}: low_param_arity_go(t, U32.add(acc, 1))
def low_param_emask_go(ps: List<&2, Param>, +idx: U32, acc: U32) -> U32:
  match ps:
    case Nil{}: acc
    case Con{Param{_, _, erased, _}, t}:
      bit = Bool.pick(U32, Bool.and(erased, U32.is_lt(idx, 32)), U32.shln(1, U32.to_nat(idx)), 0)
      low_param_emask_go(t, U32.add(idx, 1), U32.or(acc, bit))
type FnTabAcc is Data:
  FnTabAcc{next_fid: U32, by_sym: U32Map, arity: U32Map, emask: U32Map, main_fid: U32, main_sym: U32}
def low_add_defs(+syms: SymTab, ds: List<&2, Def>, acc: FnTabAcc) -> FnTabAcc:
  match ds:
    case Nil{}: acc
    case Con{Def{+sym, +params, _, _, _, _}, t}:
      match acc:
        case FnTabAcc{+fid, by_sym, arity, emask, main_fid, main_sym}:
          m2 = um_set(by_sym, sym, U32.add(fid, 1))
          a2 = um_set(arity, fid, U32.add(low_param_arity_go(params, 0), 1))
          e2 = um_set(emask, fid, low_param_emask_go(params, 0, 0))
          +is_m = b5k_str_eq(symtab_name(syms, sym), "main")
          low_add_defs(syms, t, FnTabAcc{U32.add(fid, 1), m2, a2, e2, Bool.pick(U32, is_m, fid, main_fid), Bool.pick(U32, is_m, sym, main_sym)})
type LowEnv is Data:
  LowEnv{
    syms: SymTab, ctor_by_sym: U32Map, fn_by_sym: U32Map, fn_arity: U32Map, fn_emask: U32Map,
    main_fid: U32, main_pure: Bool,
    sym_io_bind: U32, sym_io_pure: U32, sym_str_app: U32, sym_tmp: U32,
    sym_arr_len: U32, sym_arr_get: U32, sym_arr_set: U32
  }
def env_syms(e: LowEnv) -> SymTab:
  match e:
    case LowEnv{s, _, _, _, _, _, _, _, _, _, _, _, _, _}: s
def env_ctors(e: LowEnv) -> U32Map:
  match e:
    case LowEnv{_, m, _, _, _, _, _, _, _, _, _, _, _, _}: m
def env_fns(e: LowEnv) -> U32Map:
  match e:
    case LowEnv{_, _, m, _, _, _, _, _, _, _, _, _, _, _}: m
def env_arity(e: LowEnv) -> U32Map:
  match e:
    case LowEnv{_, _, _, m, _, _, _, _, _, _, _, _, _, _}: m
def env_emask(e: LowEnv) -> U32Map:
  match e:
    case LowEnv{_, _, _, _, m, _, _, _, _, _, _, _, _, _}: m
def env_io_bind(e: LowEnv) -> U32:
  match e:
    case LowEnv{_, _, _, _, _, _, _, s, _, _, _, _, _, _}: s
def env_io_pure(e: LowEnv) -> U32:
  match e:
    case LowEnv{_, _, _, _, _, _, _, _, s, _, _, _, _, _}: s
def env_str_app(e: LowEnv) -> U32:
  match e:
    case LowEnv{_, _, _, _, _, _, _, _, _, s, _, _, _, _}: s
def env_tmp(e: LowEnv) -> U32:
  match e:
    case LowEnv{_, _, _, _, _, _, _, _, _, _, s, _, _, _}: s
def env_arr_len(e: LowEnv) -> U32:
  match e:
    case LowEnv{_, _, _, _, _, _, _, _, _, _, _, s, _, _}: s
def env_arr_get(e: LowEnv) -> U32:
  match e:
    case LowEnv{_, _, _, _, _, _, _, _, _, _, _, _, s, _}: s
def env_arr_set(e: LowEnv) -> U32:
  match e:
    case LowEnv{_, _, _, _, _, _, _, _, _, _, _, _, _, s}: s
# Use-Count & Free-Variable Scanners
def pat_binds_all(fuel: Nat, +sym: U32, ps: List<&2, Pat>) -> Bool:
  match fuel ps:
    case Zero{} _: False{}
    case Succ{_} Nil{}: False{}
    case Succ{p} Con{PVar{s, _}, t}: Bool.or(U32.is_eq(sym, s), pat_binds_all(p, sym, t))
    case Succ{+p} Con{PCtr{_, fs}, t}: Bool.or(pat_binds_all(p, sym, fs), pat_binds_all(p, sym, t))
    case Succ{p} Con{PPair{a, b}, t}: pat_binds_all(p, sym, Con{a, Con{b, t}})
    case Succ{+p} Con{PList{es}, t}: Bool.or(pat_binds_all(p, sym, es), pat_binds_all(p, sym, t))
    case Succ{p} Con{_, t}: pat_binds_all(p, sym, t)
def params_bind(+sym: U32, ps: List<&2, Param>) -> Bool:
  match ps:
    case Nil{}: False{}
    case Con{Param{s, _, _, _}, t}: Bool.or(U32.is_eq(sym, s), params_bind(sym, t))
type UseItem is Data:
  UIExpr{e: Expr}
  UIExprs{es: List<&2, Expr>}
  UICases{cs: List<&2, Case>}
  UIStmts{ss: List<&2, Stmt>}
def count_uses_go(fuel: Nat, +sym: U32, item: UseItem) -> U32:
  match fuel item:
    case Zero{} _: 0
    case Succ{_} UIExprs{Nil{}}: 0
    case Succ{+p} UIExprs{Con{h, t}}: U32.add(count_uses_go(p, sym, UIExpr{h}), count_uses_go(p, sym, UIExprs{t}))
    case Succ{_} UICases{Nil{}}: 0
    case Succ{+p} UICases{Con{Case{ps, body}, t}}: U32.add(Bool.pick(U32, pat_binds_all(64n, sym, ps), 0, count_uses_go(p, sym, UIExpr{body})), count_uses_go(p, sym, UICases{t}))
    case Succ{_} UIStmts{Nil{}}: 0
    case Succ{+p} UIStmts{Con{StBind{pat, v}, t}}: U32.add(count_uses_go(p, sym, UIExpr{v}), Bool.pick(U32, pat_binds_all(64n, sym, Con{pat, Nil{}}), 0, count_uses_go(p, sym, UIStmts{t})))
    case Succ{+p} UIStmts{Con{StLet{pat, v}, t}}: U32.add(count_uses_go(p, sym, UIExpr{v}), Bool.pick(U32, pat_binds_all(64n, sym, Con{pat, Nil{}}), 0, count_uses_go(p, sym, UIStmts{t})))
    case Succ{+p} UIStmts{Con{StExpr{v}, t}}: U32.add(count_uses_go(p, sym, UIExpr{v}), count_uses_go(p, sym, UIStmts{t}))
    case Succ{+p} UIStmts{Con{StRet{v}, t}}: U32.add(count_uses_go(p, sym, UIExpr{v}), count_uses_go(p, sym, UIStmts{t}))
    case Succ{_} UIExpr{EVar{s}}: Bool.to_u32(U32.is_eq(sym, s))
    case Succ{+p} UIExpr{EApp{f, args}}: U32.add(count_uses_go(p, sym, UIExpr{f}), count_uses_go(p, sym, UIExprs{args}))
    case Succ{p} UIExpr{ELam{ps, body}}: Bool.pick(U32, params_bind(sym, ps), 0, count_uses_go(p, sym, UIExpr{body}))
    case Succ{+p} UIExpr{ELet{pat, v, body}}: U32.add(count_uses_go(p, sym, UIExpr{v}), Bool.pick(U32, pat_binds_all(64n, sym, Con{pat, Nil{}}), 0, count_uses_go(p, sym, UIExpr{body})))
    case Succ{+p} UIExpr{EMat{scruts, cs}}: U32.add(count_uses_go(p, sym, UIExprs{scruts}), count_uses_go(p, sym, UICases{cs}))
    case Succ{p} UIExpr{ECtr{_, fs}}: count_uses_go(p, sym, UIExprs{fs})
    case Succ{p} UIExpr{EAnn{v, _}}: count_uses_go(p, sym, UIExpr{v})
    case Succ{p} UIExpr{EArrNew{es}}: count_uses_go(p, sym, UIExprs{es})
    case Succ{+p} UIExpr{EArrGet{a, i}}: U32.add(count_uses_go(p, sym, UIExpr{a}), count_uses_go(p, sym, UIExpr{i}))
    case Succ{+p} UIExpr{EArrSet{a, i, v}}: U32.add(count_uses_go(p, sym, UIExpr{a}), U32.add(count_uses_go(p, sym, UIExpr{i}), count_uses_go(p, sym, UIExpr{v})))
    case Succ{+p} UIExpr{EOp{_, a, b}}: U32.add(count_uses_go(p, sym, UIExpr{a}), count_uses_go(p, sym, UIExpr{b}))
    case Succ{p} UIExpr{EUnOp{_, a}}: count_uses_go(p, sym, UIExpr{a})
    case Succ{+p} UIExpr{EIf{c, t, f}}: U32.add(count_uses_go(p, sym, UIExpr{c}), U32.add(count_uses_go(p, sym, UIExpr{t}), count_uses_go(p, sym, UIExpr{f})))
    case Succ{p} UIExpr{EDo{ss}}: count_uses_go(p, sym, UIStmts{ss})
    case Succ{+p} UIExpr{EPair{a, b}}: U32.add(count_uses_go(p, sym, UIExpr{a}), count_uses_go(p, sym, UIExpr{b}))
    case Succ{p} UIExpr{EList{es}}: count_uses_go(p, sym, UIExprs{es})
    case Succ{_} _: 0
def u32_mem(xs: List<&2, U32>, +x: U32) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{h, t}: Bool.or(U32.is_eq(h, x), u32_mem(t, x))
def fv_add_pat(fuel: Nat, ps: List<&2, Pat>, bnd: U32Map) -> U32Map:
  match fuel ps:
    case Zero{} _: bnd
    case Succ{_} Nil{}: bnd
    case Succ{p} Con{PVar{s, _}, t}: fv_add_pat(p, t, um_set(bnd, s, 1))
    case Succ{+p} Con{PCtr{_, fs}, t}: fv_add_pat(p, t, fv_add_pat(p, fs, bnd))
    case Succ{p} Con{PPair{a, b}, t}: fv_add_pat(p, Con{a, Con{b, t}}, bnd)
    case Succ{+p} Con{PList{es}, t}: fv_add_pat(p, t, fv_add_pat(p, es, bnd))
    case Succ{p} Con{_, t}: fv_add_pat(p, t, bnd)
def fv_add_params(ps: List<&2, Param>, bnd: U32Map) -> U32Map:
  match ps:
    case Nil{}: bnd
    case Con{Param{s, _, _, _}, t}: fv_add_params(t, um_set(bnd, s, 1))
def fv_add_one(in_vm: Bool, in_bnd: Bool, seen: Bool, sym: U32, acc: List<&2, U32>) -> List<&2, U32>:
  match in_vm in_bnd seen:
    case True{} False{} False{}: Con{sym, acc}
    case _ _ _: acc
def fv_go(fuel: Nat, +vmap: U32Map, +bnd: U32Map, item: UseItem, acc: List<&2, U32>) -> List<&2, U32>:
  match fuel item:
    case Zero{} _: acc
    case Succ{_} UIExprs{Nil{}}: acc
    case Succ{+p} UIExprs{Con{h, t}}: fv_go(p, vmap, bnd, UIExprs{t}, fv_go(p, vmap, bnd, UIExpr{h}, acc))
    case Succ{_} UICases{Nil{}}: acc
    case Succ{+p} UICases{Con{Case{ps, body}, t}}: fv_go(p, vmap, bnd, UICases{t}, fv_go(p, vmap, fv_add_pat(32n, ps, bnd), UIExpr{body}, acc))
    case Succ{_} UIStmts{Nil{}}: acc
    case Succ{+p} UIStmts{Con{StBind{pat, v}, t}}: fv_go(p, vmap, fv_add_pat(32n, [pat], bnd), UIStmts{t}, fv_go(p, vmap, bnd, UIExpr{v}, acc))
    case Succ{+p} UIStmts{Con{StLet{pat, v}, t}}: fv_go(p, vmap, fv_add_pat(32n, [pat], bnd), UIStmts{t}, fv_go(p, vmap, bnd, UIExpr{v}, acc))
    case Succ{+p} UIStmts{Con{StExpr{v}, t}}: fv_go(p, vmap, bnd, UIStmts{t}, fv_go(p, vmap, bnd, UIExpr{v}, acc))
    case Succ{+p} UIStmts{Con{StRet{v}, t}}: fv_go(p, vmap, bnd, UIStmts{t}, fv_go(p, vmap, bnd, UIExpr{v}, acc))
    case Succ{_} UIExpr{EVar{+s}}:
      +a0 = acc
      fv_add_one(U32.is_ne(um_get(vmap, s), 0), U32.is_ne(um_get(bnd, s), 0), u32_mem(a0, s), s, a0)
    case Succ{+p} UIExpr{EApp{f, args}}: fv_go(p, vmap, bnd, UIExprs{args}, fv_go(p, vmap, bnd, UIExpr{f}, acc))
    case Succ{p} UIExpr{ELam{ps, body}}: fv_go(p, vmap, fv_add_params(ps, bnd), UIExpr{body}, acc)
    case Succ{+p} UIExpr{ELet{pat, v, body}}: fv_go(p, vmap, fv_add_pat(32n, [pat], bnd), UIExpr{body}, fv_go(p, vmap, bnd, UIExpr{v}, acc))
    case Succ{+p} UIExpr{EMat{sc, cs}}: fv_go(p, vmap, bnd, UICases{cs}, fv_go(p, vmap, bnd, UIExprs{sc}, acc))
    case Succ{p} UIExpr{ECtr{_, fs}}: fv_go(p, vmap, bnd, UIExprs{fs}, acc)
    case Succ{p} UIExpr{EAnn{v, _}}: fv_go(p, vmap, bnd, UIExpr{v}, acc)
    case Succ{p} UIExpr{EArrNew{es}}: fv_go(p, vmap, bnd, UIExprs{es}, acc)
    case Succ{+p} UIExpr{EArrGet{a, i}}: fv_go(p, vmap, bnd, UIExpr{i}, fv_go(p, vmap, bnd, UIExpr{a}, acc))
    case Succ{+p} UIExpr{EArrSet{a, i, v}}: fv_go(p, vmap, bnd, UIExpr{v}, fv_go(p, vmap, bnd, UIExpr{i}, fv_go(p, vmap, bnd, UIExpr{a}, acc)))
    case Succ{+p} UIExpr{EOp{_, a, b}}: fv_go(p, vmap, bnd, UIExpr{b}, fv_go(p, vmap, bnd, UIExpr{a}, acc))
    case Succ{p} UIExpr{EUnOp{_, a}}: fv_go(p, vmap, bnd, UIExpr{a}, acc)
    case Succ{+p} UIExpr{EIf{c, t, f}}: fv_go(p, vmap, bnd, UIExpr{f}, fv_go(p, vmap, bnd, UIExpr{t}, fv_go(p, vmap, bnd, UIExpr{c}, acc)))
    case Succ{p} UIExpr{EDo{ss}}: fv_go(p, vmap, bnd, UIStmts{ss}, acc)
    case Succ{+p} UIExpr{EPair{a, b}}: fv_go(p, vmap, bnd, UIExpr{b}, fv_go(p, vmap, bnd, UIExpr{a}, acc))
    case Succ{p} UIExpr{EList{es}}: fv_go(p, vmap, bnd, UIExprs{es}, acc)
    case Succ{_} _: acc
# Closure Registry & CFG Builder State
type CloEntry is Data:
  CloEntry{cid: U32, fid: U32, ncaps: U32}
type CloBank is Data:
  CloBank{next_fid: U32, next_cid: U32, ctors_rev: List<&2, IrCtor>, fns_rev: List<&2, IrFn>, entries_rev: List<&2, CloEntry>}
type CfgSt is Data:
  CfgSt{
    cur_fid: U32, next_reg: U32, next_blk: U32, cur_blk: U32,
    cur_ops: List<&2, IrOp>, blocks: List<&2, IrBlock>,
    sealed: Bool, res: U32, rlist: List<&2, U32>, vmap: U32Map, merged: Bool, bank: CloBank
  }
def cfg_new(fid: U32, nparams: U32, bank: CloBank) -> CfgSt:
  CfgSt{fid, nparams, 1, 0, Nil{}, Nil{}, False{}, 0, Nil{}, UM0{}, False{}, bank}
def cfg_res(st: CfgSt) -> U32:
  match st:
    case CfgSt{_, _, _, _, _, _, _, r, _, _, _, _}: r
def cfg_rlist(st: CfgSt) -> List<&2, U32>:
  match st:
    case CfgSt{_, _, _, _, _, _, _, _, rl, _, _, _}: rl
def cfg_vmap(st: CfgSt) -> U32Map:
  match st:
    case CfgSt{_, _, _, _, _, _, _, _, _, vm, _, _}: vm
def cfg_sealed(st: CfgSt) -> Bool:
  match st:
    case CfgSt{_, _, _, _, _, _, s, _, _, _, _, _}: s
def cfg_merged(st: CfgSt) -> Bool:
  match st:
    case CfgSt{_, _, _, _, _, _, _, _, _, _, m, _}: m
def cfg_cur_fid(st: CfgSt) -> U32:
  match st:
    case CfgSt{fid, _, _, _, _, _, _, _, _, _, _, _}: fid
def cfg_bank(st: CfgSt) -> CloBank:
  match st:
    case CfgSt{_, _, _, _, _, _, _, _, _, _, _, bk}: bk
def cfg_set_res(st: CfgSt, r: U32) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, cb, ops, blks, s, _, rl, vm, mg, bk}: CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, mg, bk}
def cfg_set_rlist(st: CfgSt, rl: List<&2, U32>) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, cb, ops, blks, s, r, _, vm, mg, bk}: CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, mg, bk}
def cfg_set_vmap(st: CfgSt, vm: U32Map) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, _, mg, bk}: CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, mg, bk}
def cfg_set_merged(st: CfgSt, mg: Bool) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, _, bk}: CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, mg, bk}
def cfg_set_bank(st: CfgSt, bk: CloBank) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, mg, _}: CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, mg, bk}
def cfg_alloc_reg(st: CfgSt) -> CfgSt:
  match st:
    case CfgSt{f, +nr, nb, cb, ops, blks, s, _, rl, vm, mg, bk}: CfgSt{f, U32.add(nr, 1), nb, cb, ops, blks, s, nr, rl, vm, mg, bk}
def cfg_alloc_blk(st: CfgSt) -> CfgSt:
  match st:
    case CfgSt{f, nr, +nb, cb, ops, blks, s, _, rl, vm, mg, bk}: CfgSt{f, nr, U32.add(nb, 1), cb, ops, blks, s, nb, rl, vm, mg, bk}
def cfg_emit(st: CfgSt, op: IrOp) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, cb, ops, blks, sealed, r, rl, vm, mg, bk}:
      match sealed:
        case True{}: CfgSt{f, nr, nb, cb, ops, blks, True{}, r, rl, vm, mg, bk}
        case False{}: CfgSt{f, nr, nb, cb, Con{op, ops}, blks, False{}, r, rl, vm, mg, bk}
def cfg_seal(st: CfgSt, term: IrTerm) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, +cb, ops, blks, sealed, r, rl, vm, mg, bk}:
      match sealed:
        case True{}: CfgSt{f, nr, nb, cb, ops, blks, True{}, r, rl, vm, mg, bk}
        case False{}: CfgSt{f, nr, nb, cb, Nil{}, Con{IrBlock{cb, b5k_list_rev(IrOp, ops), term}, blks}, True{}, r, rl, vm, mg, bk}
def cfg_start(st: CfgSt, blk_id: U32) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, _, _, blks, _, r, rl, vm, mg, bk}: CfgSt{f, nr, nb, blk_id, Nil{}, blks, False{}, r, rl, vm, mg, bk}
def cfg_maybe_start(st: CfgSt, start_it: Bool, blk: U32) -> CfgSt:
  match start_it:
    case True{}: cfg_start(st, blk)
    case False{}: st
def cfg_fin_branch(st: CfgSt, sld: Bool, res_reg: U32, v: U32, merge_blk: U32, prev_mg: Bool) -> CfgSt:
  match sld:
    case True{}: cfg_set_merged(st, prev_mg)
    case False{}: cfg_set_merged(cfg_seal(cfg_emit(st, ICopy{res_reg, v}), TJmp{merge_blk}), True{})
def cfg_emit_keeps_go(k: Nat, st: CfgSt, +v: U32) -> CfgSt:
  match k:
    case 0n: st
    case 1n+p: cfg_emit_keeps_go(p, cfg_emit(st, IKeep{v, v}), v)
def cfg_apply_rc_go(st: CfgSt, +v: U32, z: Bool, do_keep: Bool, uses: U32) -> CfgSt:
  match z do_keep:
    case True{} _: cfg_emit(st, ISink{v})
    case False{} True{}: cfg_emit_keeps_go(U32.to_nat(U32.sub(uses, 1)), st, v)
    case False{} False{}: st
def cfg_apply_rc(st: CfgSt, v: U32, +uses: U32) -> CfgSt:
  cfg_apply_rc_go(st, v, U32.is_zero(uses), U32.is_gt(uses, 1), uses)
# Intrinsics (U32.*, F32.*, IO.*)
def low_u32_intr(+s: String) -> U32:
  r = Bool.pick(U32, b5k_str_eq(s, "F32.to_u32"), 53, Bool.pick(U32, Bool.or(b5k_str_eq(s, "U32.to_f32"), b5k_str_eq(s, "F32.from_u32")), 52, 0))
  r = Bool.pick(U32, b5k_str_eq(s, "F32.sqrt"), 51, Bool.pick(U32, b5k_str_eq(s, "F32.neg"), 50, r))
  r = Bool.pick(U32, b5k_str_eq(s, "F32.is_ge"), 49, Bool.pick(U32, b5k_str_eq(s, "F32.is_gt"), 48, Bool.pick(U32, b5k_str_eq(s, "F32.is_le"), 47, r)))
  r = Bool.pick(U32, b5k_str_eq(s, "F32.is_lt"), 46, Bool.pick(U32, b5k_str_eq(s, "F32.is_ne"), 45, Bool.pick(U32, b5k_str_eq(s, "F32.is_eq"), 44, r)))
  r = Bool.pick(U32, b5k_str_eq(s, "F32.div"), 43, Bool.pick(U32, b5k_str_eq(s, "F32.mul"), 42, Bool.pick(U32, b5k_str_eq(s, "F32.sub"), 41, Bool.pick(U32, b5k_str_eq(s, "F32.add"), 40, r))))
  r = Bool.pick(U32, b5k_str_eq(s, "__file_close"), 54, Bool.pick(U32, b5k_str_eq(s, "__file_write_bytes"), 39, Bool.pick(U32, b5k_str_eq(s, "__file_write"), 38, r)))
  r = Bool.pick(U32, b5k_str_eq(s, "__file_size"), 37, Bool.pick(U32, b5k_str_eq(s, "__file_read"), 36, Bool.pick(U32, b5k_str_eq(s, "__file_open"), 35, r)))
  r = Bool.pick(U32, b5k_str_eq(s, "__io_now"), 34, Bool.pick(U32, b5k_str_eq(s, "__io_args"), 33, Bool.pick(U32, b5k_str_eq(s, "__io_print_err"), 32, Bool.pick(U32, b5k_str_eq(s, "__io_print"), 31, r))))
  r = Bool.pick(U32, Bool.or(b5k_str_eq(s, "U32.from_nat"), Bool.or(b5k_str_eq(s, "U32.to_nat"), Bool.or(b5k_str_eq(s, "F32.bits"), Bool.or(b5k_str_eq(s, "Bool.to_u32"), Bool.or(b5k_str_eq(s, "Char.to_u32"), b5k_str_eq(s, "Char.from_u32")))))), 27, Bool.pick(U32, b5k_str_eq(s, "U32.not"), 26, r))
  r = Bool.pick(U32, b5k_str_eq(s, "U32.shrn"), 25, Bool.pick(U32, b5k_str_eq(s, "U32.shln"), 24, Bool.pick(U32, b5k_str_eq(s, "U32.shr"), 23, Bool.pick(U32, b5k_str_eq(s, "U32.shl"), 22, r))))
  r = Bool.pick(U32, Bool.or(b5k_str_eq(s, "U32.is_zero"), b5k_str_eq(s, "Bool.not")), 21, Bool.pick(U32, b5k_str_eq(s, "U32.dec"), 20, Bool.pick(U32, b5k_str_eq(s, "U32.inc"), 19, r)))
  r = Bool.pick(U32, Bool.or(b5k_str_eq(s, "U32.is_ge"), b5k_str_eq(s, "Nat.is_ge")), 16, Bool.pick(U32, Bool.or(b5k_str_eq(s, "U32.is_gt"), b5k_str_eq(s, "Nat.is_gt")), 15, Bool.pick(U32, Bool.or(b5k_str_eq(s, "U32.is_le"), b5k_str_eq(s, "Nat.is_le")), 14, r)))
  r = Bool.pick(U32, Bool.or(b5k_str_eq(s, "U32.is_lt"), b5k_str_eq(s, "Nat.is_lt")), 13, Bool.pick(U32, b5k_str_eq(s, "U32.is_ne"), 12, Bool.pick(U32, Bool.or(b5k_str_eq(s, "U32.is_eq"), b5k_str_eq(s, "Nat.is_eq")), 11, r)))
  r = Bool.pick(U32, Bool.or(b5k_str_eq(s, "U32.xor"), b5k_str_eq(s, "Bool.xor")), 8, Bool.pick(U32, Bool.or(b5k_str_eq(s, "U32.or"), b5k_str_eq(s, "Bool.or")), 7, Bool.pick(U32, Bool.or(b5k_str_eq(s, "U32.and"), b5k_str_eq(s, "Bool.and")), 6, Bool.pick(U32, b5k_str_eq(s, "U32.mod"), 5, r))))
  Bool.pick(U32, Bool.or(b5k_str_eq(s, "U32.add"), b5k_str_eq(s, "Nat.add")), 1, Bool.pick(U32, b5k_str_eq(s, "U32.sub"), 2, Bool.pick(U32, Bool.or(b5k_str_eq(s, "U32.mul"), b5k_str_eq(s, "Nat.mul")), 3, Bool.pick(U32, b5k_str_eq(s, "U32.div"), 4, r))))
def low_emit_bin_or_cmp(st: CfgSt, is_cmp: Bool, +op: U32, +va: U32, +vb: U32) -> CfgSt:
  +st1 = cfg_alloc_reg(st)
  +dst = cfg_res(st1)
  cfg_emit(st1, Bool.pick(IrOp, is_cmp, ICmp{dst, op, va, vb}, IBin{dst, op, va, vb}))
def low_emit_un(st: CfgSt, uop: U32, va: U32) -> CfgSt:
  +st1 = cfg_alloc_reg(st)
  cfg_emit(st1, IUn{cfg_res(st1), uop, va})
def low_emit_safe_shift(st: CfgSt, is_shr: Bool, +va: U32, +vb: U32) -> CfgSt:
  +st1 = cfg_alloc_reg(st)
  +c32 = cfg_res(st1)
  +st2 = cfg_alloc_reg(cfg_emit(st1, IConst{c32, 32}))
  +cond = cfg_res(st2)
  +st3 = cfg_alloc_blk(cfg_emit(st2, ICmp{cond, B5K_CMP_GE(), vb, c32}))
  +b_big = cfg_res(st3)
  +st4 = cfg_alloc_blk(st3)
  +b_ok = cfg_res(st4)
  +st5 = cfg_alloc_blk(st4)
  +b_m = cfg_res(st5)
  +st6 = cfg_alloc_reg(st5)
  +dst = cfg_res(st6)
  s0 = cfg_seal(st6, TBr{cond, b_big, b_ok})
  s1 = cfg_seal(cfg_emit(cfg_start(s0, b_big), IConst{dst, 0}), TJmp{b_m})
  +s2 = cfg_alloc_reg(cfg_start(s1, b_ok))
  s3 = cfg_seal(cfg_emit(cfg_emit(s2, IBin{cfg_res(s2), Bool.pick(U32, is_shr, B5K_OP_SHR(), B5K_OP_SHL()), va, vb}), ICopy{dst, cfg_res(s2)}), TJmp{b_m})
  cfg_set_res(cfg_start(s3, b_m), dst)
def low_emit_io_eff3(st: CfgSt, cid: U32, a: U32, b: U32, k: U32) -> CfgSt:
  +st1 = cfg_alloc_reg(st)
  +st2 = cfg_alloc_reg(cfg_emit(st1, ICallClosure{cfg_res(st1), 2, [k]}))
  cfg_emit(st2, ICtor{cfg_res(st2), cid, [a, b, cfg_res(st1)]})
def low_emit_io_eff2(st: CfgSt, cid: U32, arg: U32, k: U32) -> CfgSt:
  +st1 = cfg_alloc_reg(st)
  +st2 = cfg_alloc_reg(cfg_emit(st1, ICallClosure{cfg_res(st1), 2, [k]}))
  cfg_emit(st2, ICtor{cfg_res(st2), cid, [arg, cfg_res(st1)]})
def low_emit_io_eff1(st: CfgSt, cid: U32, k: U32) -> CfgSt:
  +st1 = cfg_alloc_reg(st)
  +st2 = cfg_alloc_reg(cfg_emit(st1, ICallClosure{cfg_res(st1), 2, [k]}))
  cfg_emit(st2, ICtor{cfg_res(st2), cid, [cfg_res(st1)]})
def low_emit_u32_intr2_rest(st: CfgSt, is_flt: Bool, +code: U32, va: U32, vb: U32) -> CfgSt:
  match is_flt:
    case True{}:
      +is_fcmp = U32.is_ge(code, 44)
      low_emit_bin_or_cmp(st, is_fcmp, Bool.pick(U32, is_fcmp, U32.sub(code, 38), U32.sub(code, 30)), va, vb)
    case False{}:
      +is_cmp = U32.is_gt(code, 10)
      low_emit_bin_or_cmp(st, is_cmp, Bool.pick(U32, is_cmp, U32.sub(code, 11), U32.sub(code, 1)), va, vb)
def low_emit_u32_intr2(st: CfgSt, +code: U32, +va: U32, +vb: U32) -> CfgSt:
  match code:
    case 24: low_emit_safe_shift(st, False{}, va, vb)
    case 25: low_emit_safe_shift(st, True{}, va, vb)
    case 31: low_emit_io_eff2(st, 28, va, vb)
    case 32: low_emit_io_eff2(st, 29, va, vb)
    case 37: low_emit_io_eff2(st, 34, va, vb)
    case 54: low_emit_io_eff2(st, 37, va, vb)
    case _: low_emit_u32_intr2_rest(st, U32.is_ge(code, 40), code, va, vb)
def low_emit_u32_intr3(st: CfgSt, code: U32, va: U32, vb: U32, vc: U32) -> CfgSt:
  match code:
    case 35: low_emit_io_eff3(st, 32, va, vb, vc)
    case 36: low_emit_io_eff3(st, 33, va, vb, vc)
    case 38: low_emit_io_eff3(st, 35, va, vb, vc)
    case 39: low_emit_io_eff3(st, 36, va, vb, vc)
    case _:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, IConst{cfg_res(st1), 0})
def low_emit_u32_intr1(st: CfgSt, +code: U32, +va: U32) -> CfgSt:
  match code:
    case 26: low_emit_un(st, 1, va)
    case 27: cfg_set_res(st, va)
    case 33: low_emit_io_eff1(st, 30, va)
    case 34: low_emit_io_eff1(st, 31, va)
    case 50: low_emit_un(st, 2, va)
    case 51: low_emit_un(st, 3, va)
    case 52: low_emit_un(st, 4, va)
    case 53: low_emit_un(st, 5, va)
    case _:
      +st1 = cfg_alloc_reg(st)
      +c = cfg_res(st1)
      +is_z = U32.is_eq(code, 21)
      op = Bool.pick(U32, U32.is_eq(code, 19), B5K_OP_ADD(), Bool.pick(U32, U32.is_eq(code, 20), B5K_OP_SUB(), Bool.pick(U32, U32.is_eq(code, 22), B5K_OP_SHL(), Bool.pick(U32, U32.is_eq(code, 23), B5K_OP_SHR(), B5K_CMP_EQ()))))
      low_emit_bin_or_cmp(cfg_emit(st1, IConst{c, Bool.pick(U32, is_z, 0, 1)}), is_z, op, va, c)
def low_emit_u32_intr(st: CfgSt, code: U32, vargs: List<&2, U32>) -> CfgSt:
  match vargs:
    case Con{va, Con{vb, Con{vc, Nil{}}}}: low_emit_u32_intr3(st, code, va, vb, vc)
    case Con{va, Con{vb, Nil{}}}: low_emit_u32_intr2(st, code, va, vb)
    case Con{va, Nil{}}: low_emit_u32_intr1(st, code, va)
    case _:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, IConst{cfg_res(st1), 0})
# Sequential Pattern Matching & Lowering Helpers
def low_alloc_regs_go(n: Nat, st: CfgSt, acc: List<&2, U32>) -> CfgSt:
  match n:
    case 0n: cfg_set_rlist(st, b5k_list_rev(U32, acc))
    case 1n+p:
      +st1 = cfg_alloc_reg(st)
      low_alloc_regs_go(p, st1, Con{cfg_res(st1), acc})
def pat_is_refut(fuel: Nat, ps: List<&2, Pat>) -> Bool:
  match fuel ps:
    case 0n _: False{}
    case _ Nil{}: False{}
    case 1n+p Con{PWild{}, t}: pat_is_refut(p, t)
    case 1n+p Con{PVar{_, _}, t}: pat_is_refut(p, t)
    case 1n+p Con{PPair{a, b}, t}: pat_is_refut(p, Con{a, Con{b, t}})
    case 1n+_ Con{_, _}: True{}
def low_test_cmp_const(st: CfgSt, cop: U32, r: U32, val: U32, fail_blk: U32) -> CfgSt:
  +st1 = cfg_alloc_reg(st)
  +st2 = cfg_alloc_reg(cfg_emit(st1, IConst{cfg_res(st1), val}))
  +st3 = cfg_alloc_blk(cfg_emit(st2, ICmp{cfg_res(st2), cop, r, cfg_res(st1)}))
  cfg_start(cfg_seal(st3, TBr{cfg_res(st2), cfg_res(st3), fail_blk}), cfg_res(st3))
def low_test_tag(st: CfgSt, r: U32, cid: U32, fail_blk: U32) -> CfgSt:
  +st1 = cfg_alloc_reg(st)
  low_test_cmp_const(cfg_emit(st1, ITag{cfg_res(st1), r}), B5K_CMP_EQ(), cfg_res(st1), cid, fail_blk)
def low_maybe_keep(st: CfgSt, need: Bool, +r: U32) -> CfgSt:
  match need:
    case False{}: cfg_set_res(st, r)
    case True{}: cfg_set_res(cfg_emit(st, IKeep{r, r}), r)
def low_special_ctor_kind(+nm: String) -> U32:
  r = Bool.pick(U32, b5k_str_eq(nm, "Chr"), 5, Bool.pick(U32, b5k_str_eq(nm, "Succ"), 4, 0))
  Bool.pick(U32, b5k_str_eq(nm, "False"), 1, Bool.pick(U32, b5k_str_eq(nm, "True"), 2, Bool.pick(U32, b5k_str_eq(nm, "Zero"), 3, r)))
type PatStep is Data:
  PSDone{st: CfgSt}
  PSNext{st: CfgSt, ps: List<&2, Pat>, regs: List<&2, U32>}
def low_opt_test_eq(hf: Bool, st: CfgSt, r: U32, val: U32, fb: U32) -> CfgSt:
  match hf:
    case True{}: low_test_cmp_const(st, B5K_CMP_EQ(), r, val, fb)
    case False{}: st
def low_opt_test_ne0(hf: Bool, st: CfgSt, r: U32, fb: U32) -> CfgSt:
  match hf:
    case True{}: low_test_cmp_const(st, B5K_CMP_NE(), r, 0, fb)
    case False{}: st
def low_opt_test_tag(hf: Bool, st: CfgSt, r: U32, cid: U32, fb: U32) -> CfgSt:
  match hf:
    case True{}: low_test_tag(st, r, cid, fb)
    case False{}: st
def low_opt_sink(hf: Bool, st: CfgSt, r: U32) -> CfgSt:
  match hf:
    case True{}: st
    case False{}: cfg_emit(st, ISink{r})
def low_opt_rc(skip: Bool, st: CfgSt, r: U32, uses: U32) -> CfgSt:
  match skip:
    case True{}: st
    case False{}: cfg_apply_rc(st, r, uses)
def low_pat_ctr_box(st: CfgSt, cid: U32, +fs: List<&2, Pat>, +pt: List<&2, Pat>, +r: U32, rt: List<&2, U32>, fail_blk: U32, +has_fail: Bool, nf_zero: Bool, nf: U32) -> PatStep:
  match nf_zero:
    case True{}: PSNext{low_opt_test_tag(has_fail, st, r, cid, fail_blk), pt, rt}
    case False{}:
      st1 = low_opt_test_tag(has_fail, st, r, cid, fail_blk)
      +stK = low_maybe_keep(st1, Bool.and(has_fail, Bool.or(pat_is_refut(16n, fs), pat_is_refut(16n, pt))), r)
      +st2 = low_alloc_regs_go(U32.to_nat(nf), stK, Nil{})
      +fregs = cfg_rlist(st2)
      PSNext{cfg_emit(st2, ITake{fregs, cfg_res(stK)}), b5k_list_app(Pat, fs, pt), b5k_list_app(U32, fregs, rt)}
def low_pat_ctr_step(kind: U32, env: LowEnv, st: CfgSt, sym: U32, +fs: List<&2, Pat>, pt: List<&2, Pat>, +r: U32, rt: List<&2, U32>, fail_blk: U32, +has_fail: Bool) -> PatStep:
  match kind:
    case 1: PSNext{low_opt_test_eq(has_fail, st, r, 0, fail_blk), pt, rt}
    case 2: PSNext{low_opt_test_eq(has_fail, st, r, 1, fail_blk), pt, rt}
    case 3: PSNext{low_opt_test_eq(has_fail, st, r, 0, fail_blk), pt, rt}
    case 4:
      st1 = low_opt_test_ne0(has_fail, st, r, fail_blk)
      +st2 = cfg_alloc_reg(st1)
      +c1 = cfg_res(st2)
      +st3 = cfg_alloc_reg(cfg_emit(st2, IConst{c1, 1}))
      +pr = cfg_res(st3)
      PSNext{cfg_emit(st3, IBin{pr, B5K_OP_SUB(), r, c1}), b5k_list_app(Pat, fs, pt), Con{pr, rt}}
    case 5: PSNext{st, b5k_list_app(Pat, fs, pt), Con{r, rt}}
    case _:
      +cv = um_get(env_ctors(env), sym)
      +nf = b5k_list_len(Pat, fs)
      low_pat_ctr_box(st, Bool.pick(U32, U32.is_zero(cv), 0, U32.sub(cv, 1)), fs, pt, r, rt, fail_blk, has_fail, U32.is_zero(nf), nf)
def low_pat_one(+env: LowEnv, st: CfgSt, p0: Pat, pt: List<&2, Pat>, +r: U32, rt: List<&2, U32>, body: Expr, fail_blk: U32, +has_fail: Bool) -> PatStep:
  match p0:
    case PWild{}: PSNext{low_opt_sink(has_fail, st, r), pt, rt}
    case PVar{+sym, _}:
      +uses = count_uses_go(U32.to_nat(2048), sym, UIExpr{body})
      +st1 = low_opt_rc(Bool.and(has_fail, U32.is_zero(uses)), st, r, uses)
      PSNext{cfg_set_vmap(st1, um_set(cfg_vmap(st1), sym, U32.add(r, 1))), pt, rt}
    case PNum{v}: PSNext{low_opt_test_eq(has_fail, st, r, v, fail_blk), pt, rt}
    case PChr{c}: PSNext{low_opt_test_eq(has_fail, st, r, c, fail_blk), pt, rt}
    case PPair{+a, +b}:
      +st0 = low_maybe_keep(st, Bool.and(has_fail, pat_is_refut(16n, [a, b])), r)
      +st1 = cfg_alloc_reg(st0)
      +ra = cfg_res(st1)
      +st2 = cfg_alloc_reg(st1)
      +rb = cfg_res(st2)
      PSNext{cfg_emit(st2, ITake{[ra, rb], cfg_res(st0)}), Con{a, Con{b, pt}}, Con{ra, Con{rb, rt}}}
    case PList{Nil{}}: PSNext{low_opt_test_tag(has_fail, st, r, 4, fail_blk), pt, rt}
    case PList{Con{h, tl}}:
      st0 = low_opt_test_tag(has_fail, st, r, 5, fail_blk)
      +stK = low_maybe_keep(st0, has_fail, r)
      +st1 = cfg_alloc_reg(stK)
      +rh = cfg_res(st1)
      +st2 = cfg_alloc_reg(st1)
      +rt2 = cfg_res(st2)
      PSNext{cfg_emit(st2, ITake{[rh, rt2], cfg_res(stK)}), Con{h, Con{PList{tl}, pt}}, Con{rh, Con{rt2, rt}}}
    case PCtr{+sym, fs}:
      low_pat_ctr_step(low_special_ctor_kind(symtab_name(env_syms(env), sym)), env, st, sym, fs, pt, r, rt, fail_blk, has_fail)
def low_match_pats_go(fuel: Nat, +env: LowEnv, step: PatStep, +body: Expr, +fail_blk: U32, +has_fail: Bool) -> CfgSt:
  match fuel step:
    case 0n PSDone{st}: st
    case 0n PSNext{st, _, _}: st
    case _ PSDone{st}: st
    case 1n+p PSNext{st, Nil{}, _}: st
    case 1n+p PSNext{st, _, Nil{}}: st
    case 1n+p PSNext{st, Con{p0, pt}, Con{r, rt}}:
      low_match_pats_go(p, env, low_pat_one(env, st, p0, pt, r, rt, body, fail_blk, has_fail), body, fail_blk, has_fail)
def low_match_pats(fuel: Nat, env: LowEnv, st: CfgSt, ps: List<&2, Pat>, regs: List<&2, U32>, body: Expr, fail_blk: U32, has_fail: Bool) -> CfgSt:
  low_match_pats_go(fuel, env, PSNext{st, ps, regs}, body, fail_blk, has_fail)
def low_apply_chain(vargs: List<&2, U32>, st: CfgSt, vfn: U32) -> CfgSt:
  match vargs:
    case Nil{}: cfg_set_res(st, vfn)
    case Con{va, t}:
      +st1 = cfg_alloc_reg(st)
      +dst = cfg_res(st1)
      low_apply_chain(t, cfg_emit(st1, ICallDirect{dst, 0, [vfn, va]}), dst)
def low_list_chain(vargs: List<&2, U32>, st: CfgSt) -> CfgSt:
  match vargs:
    case Nil{}:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, ICtor{cfg_res(st1), 4, Nil{}})
    case Con{h, t}:
      +st1 = low_list_chain(t, st)
      +st2 = cfg_alloc_reg(st1)
      cfg_emit(st2, ICtor{cfg_res(st2), 5, [h, cfg_res(st1)]})
def low_str_chain(s: String, st: CfgSt) -> CfgSt:
  match s:
    case SNil{}:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, ICtor{cfg_res(st1), 0, Nil{}})
    case SCon{c, t}:
      +st1 = low_str_chain(t, st)
      +st2 = cfg_alloc_reg(st1)
      +vc = cfg_res(st2)
      +st3 = cfg_alloc_reg(cfg_emit(st2, IConst{vc, Char.to_u32(c)}))
      cfg_emit(st3, ICtor{cfg_res(st3), 1, [vc, cfg_res(st1)]})
def low_cons_if(skip: Bool, h: Expr, rest: List<&2, Expr>) -> List<&2, Expr>:
  match skip:
    case True{}: rest
    case False{}: Con{h, rest}
def low_filter_erased(es: List<&2, Expr>, +emask: U32, +idx: U32) -> List<&2, Expr>:
  match es:
    case Nil{}: Nil{}
    case Con{h, t}:
      er = Bool.and(U32.is_lt(idx, 32), U32.is_ne(U32.and(U32.shrn(emask, U32.to_nat(idx)), 1), 0))
      low_cons_if(er, h, low_filter_erased(t, emask, U32.add(idx, 1)))
def low_app_direct(st: CfgSt, fid: U32, vargs: List<&2, U32>, is_self_tail: Bool) -> CfgSt:
  match is_self_tail:
    case True{}: cfg_set_res(cfg_seal(st, TTailCall{fid, vargs}), 0)
    case False{}:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, ICallDirect{cfg_res(st1), fid, vargs})
def low_emit_add_or_cat(+env: LowEnv, st: CfgSt, +va: U32, +vb: U32) -> CfgSt:
  +st1 = cfg_alloc_reg(st)
  +snil = cfg_res(st1)
  +st2 = cfg_alloc_reg(cfg_emit(st1, ICtor{snil, 0, Nil{}}))
  +c_sn = cfg_res(st2)
  +st3 = cfg_alloc_blk(cfg_emit(st2, ICmp{c_sn, B5K_CMP_EQ(), va, snil}))
  +b_sn = cfg_res(st3)
  +st4 = cfg_alloc_blk(st3)
  +b_chk = cfg_res(st4)
  +st5 = cfg_alloc_blk(st4)
  +b_sc = cfg_res(st5)
  +st6 = cfg_alloc_blk(st5)
  +b_add = cfg_res(st6)
  +st7 = cfg_alloc_blk(st6)
  +b_m = cfg_res(st7)
  +st8 = cfg_alloc_reg(st7)
  +dst = cfg_res(st8)
  s0 = cfg_seal(st8, TBr{c_sn, b_sn, b_chk})
  s1 = cfg_seal(cfg_emit(cfg_start(s0, b_sn), ICopy{dst, vb}), TJmp{b_m})
  +s2 = cfg_alloc_reg(cfg_start(s1, b_chk))
  +tg = cfg_res(s2)
  +s3 = cfg_alloc_reg(cfg_emit(s2, ITag{tg, va}))
  +c1 = cfg_res(s3)
  +s4 = cfg_alloc_reg(cfg_emit(s3, IConst{c1, 1}))
  +c_sc = cfg_res(s4)
  s5 = cfg_seal(cfg_emit(s4, ICmp{c_sc, B5K_CMP_EQ(), tg, c1}), TBr{c_sc, b_sc, b_add})
  +sfv = um_get(env_fns(env), env_str_app(env))
  +s6 = cfg_alloc_reg(cfg_start(s5, b_sc))
  s7 = cfg_seal(cfg_emit(cfg_emit(s6, ICallDirect{cfg_res(s6), Bool.pick(U32, U32.is_zero(sfv), 0, U32.sub(sfv, 1)), [va, vb]}), ICopy{dst, cfg_res(s6)}), TJmp{b_m})
  +s8 = cfg_alloc_reg(cfg_start(s7, b_add))
  s9 = cfg_seal(cfg_emit(cfg_emit(s8, IBin{cfg_res(s8), B5K_OP_ADD(), va, vb}), ICopy{dst, cfg_res(s8)}), TJmp{b_m})
  cfg_set_res(cfg_start(s9, b_m), dst)
def low_emit_op_go(is_zero: Bool, env: LowEnv, st: CfgSt, +op: U32, va: U32, vb: U32) -> CfgSt:
  match is_zero:
    case True{}: low_emit_add_or_cat(env, st, va, vb)
    case False{}:
      +is_cmp = Bool.and(U32.is_ge(op, 20), U32.is_le(op, 25))
      low_emit_bin_or_cmp(st, is_cmp, Bool.pick(U32, is_cmp, U32.sub(op, 20), op), va, vb)
def low_lookup_fvs(fvs: List<&2, U32>, +vm: U32Map) -> List<&2, U32>:
  match fvs:
    case Nil{}: Nil{}
    case Con{s, t}:
      +v = um_get(vm, s)
      Con{Bool.pick(U32, U32.is_zero(v), 0, U32.sub(v, 1)), low_lookup_fvs(t, vm)}
def low_bind_lam_caps(fvs: List<&2, U32>, st: CfgSt, +idx: U32, +body: Expr) -> CfgSt:
  match fvs:
    case Nil{}: st
    case Con{+s, t}:
      +st1 = cfg_apply_rc(st, idx, count_uses_go(U32.to_nat(2048), s, UIExpr{body}))
      low_bind_lam_caps(t, cfg_set_vmap(st1, um_set(cfg_vmap(st1), s, U32.add(idx, 1))), U32.add(idx, 1), body)
def low_bind_params(ps: List<&2, Param>, st: CfgSt, +idx: U32, +body: Expr) -> CfgSt:
  match ps:
    case Nil{}: st
    case Con{Param{+sym, _, erased, _}, t}:
      match erased:
        case True{}: low_bind_params(t, st, idx, body)
        case False{}:
          +st1 = cfg_apply_rc(st, idx, count_uses_go(U32.to_nat(2048), sym, UIExpr{body}))
          low_bind_params(t, cfg_set_vmap(st1, um_set(cfg_vmap(st1), sym, U32.add(idx, 1))), U32.add(idx, 1), body)
def low_curry_lam(ps: List<&2, Param>, body: Expr) -> Expr:
  match ps:
    case Nil{}: body
    case Con{p, Nil{}}: ELam{[p], body}
    case Con{p, rest}: ELam{[p], low_curry_lam(rest, body)}
def low_desugar_do(+env: LowEnv, ss: List<&2, Stmt>) -> Expr:
  match ss:
    case Nil{}: EUnit{}
    case Con{StRet{v}, _}: EApp{EVar{env_io_pure(env)}, [EUnit{}, v]}
    case Con{StExpr{v}, Nil{}}: v
    case Con{StExpr{v}, t}: EApp{EVar{env_io_bind(env)}, [EUnit{}, EUnit{}, v, ELam{[Param{env_tmp(env), None{}, False{}, False{}}], low_desugar_do(env, t)}]}
    case Con{StLet{pat, v}, t}: ELet{pat, v, low_desugar_do(env, t)}
    case Con{StBind{PVar{s, dup}, v}, t}: EApp{EVar{env_io_bind(env)}, [EUnit{}, EUnit{}, v, ELam{[Param{s, None{}, False{}, dup}], low_desugar_do(env, t)}]}
    case Con{StBind{pat, v}, t}:
      +tmp = env_tmp(env)
      EApp{EVar{env_io_bind(env)}, [EUnit{}, EUnit{}, v, ELam{[Param{tmp, None{}, False{}, False{}}], ELet{pat, EVar{tmp}, low_desugar_do(env, t)}}]}
def low_emit_ctor_kind(kind: U32, +env: LowEnv, st: CfgSt, sym: U32, nm: String, vfs: List<&2, U32>) -> CfgSt:
  match kind:
    case 1:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, IConst{cfg_res(st1), 0})
    case 2:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, IConst{cfg_res(st1), 1})
    case 3:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, IConst{cfg_res(st1), 0})
    case 4:
      match vfs:
        case Con{vx, _}:
          +st1 = cfg_alloc_reg(st)
          +c1 = cfg_res(st1)
          low_emit_bin_or_cmp(cfg_emit(st1, IConst{c1, 1}), False{}, B5K_OP_ADD(), vx, c1)
        case Nil{}:
          +st1 = cfg_alloc_reg(st)
          cfg_emit(st1, IConst{cfg_res(st1), 1})
    case 5:
      match vfs:
        case Con{vx, _}: cfg_set_res(st, vx)
        case Nil{}:
          +st1 = cfg_alloc_reg(st)
          cfg_emit(st1, IConst{cfg_res(st1), 0})
    case _:
      +cv = um_get(env_ctors(env), sym)
      cid = Bool.pick(U32, b5k_str_eq(nm, "Pair"), 6, Bool.pick(U32, U32.is_zero(cv), 0, U32.sub(cv, 1)))
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, ICtor{cfg_res(st1), cid, vfs})
def low_emit_ctor_expr(+env: LowEnv, st: CfgSt, +sym: U32, vfs: List<&2, U32>) -> CfgSt:
  +nm = symtab_name(env_syms(env), sym)
  low_emit_ctor_kind(low_special_ctor_kind(nm), env, st, sym, nm, vfs)
# Single Self-Recursive Expression -> Flat CFG Lowerer
type LowTask is Data:
  LTExpr{e: Expr}
  LTExprs{es: List<&2, Expr>, acc: List<&2, U32>}
  LTCases{base_vm: U32Map, cs: List<&2, Case>, vscruts: List<&2, U32>, res_reg: U32, merge_blk: U32}
  LTAppSym{sym: U32, args: List<&2, Expr>, lv: U32, lz: Bool}
  LTAppGlob{sym: U32, args: List<&2, Expr>, icode: U32, has_i: Bool, fv: U32, fz: Bool}
  LTAppFn{sym: U32, args: List<&2, Expr>, fid: U32, ar: U32, vargs: List<&2, U32>, is_sat: Bool, is_over: Bool}
  LTVar{sym: U32, lv: U32, lz: Bool}
  LTVarGlob{sym: U32, fz: Bool}
  LTLam{p0: Param, body: Expr, fvs: List<&2, U32>, bk: CloBank}
def low_type_head(+syms: SymTab, e: Expr) -> String:
  match e:
    case EVar{s}: symtab_name(syms, s)
    case ERef{s}: symtab_name(syms, s)
    case EApp{f, _}: low_type_head(syms, f)
    case _: ""
def low_f32_op(+op: U32) -> U32:
  Bool.pick(U32, U32.is_lt(op, 4), U32.add(op, 10), op)
def low_f32_ops(+fuel: Nat, e: Expr) -> Expr:
  match fuel e:
    case 0n _: e
    case 1n+p EOp{op, a, b}: EOp{low_f32_op(op), low_f32_ops(p, a), low_f32_ops(p, b)}
    case 1n+p EAnn{v, t}: EAnn{low_f32_ops(p, v), t}
    case 1n+_ other: other
def low_take_u32(n: Nat, xs: List<&2, U32>) -> List<&2, U32>:
  match n xs:
    case 0n _: Nil{}
    case _ Nil{}: Nil{}
    case 1n+p Con{h, t}: Con{h, low_take_u32(p, t)}
def low_drop_u32(n: Nat, xs: List<&2, U32>) -> List<&2, U32>:
  match n xs:
    case 0n _: xs
    case _ Nil{}: Nil{}
    case 1n+p Con{_, t}: low_drop_u32(p, t)
def low_bank_next_cid(bk: CloBank) -> U32:
  match bk:
    case CloBank{_, nc, _, _, _}: nc
def low_bank_finish_lam(+ncaps: U32, ar: U32, lam_st: CfgSt) -> CloBank:
  match lam_st:
    case CfgSt{_, nregs, _, _, _, blks_rev, _, _, _, _, _, CloBank{+lam_fid, +lam_cid, cr, fr, er}}:
      CloBank{U32.add(lam_fid, 1), U32.add(lam_cid, 1), Con{IrCtor{lam_cid, String.append("__clo_", b5k_u32_to_str(lam_fid)), ncaps, False{}}, cr}, Con{IrFn{lam_fid, String.append("__lam_", b5k_u32_to_str(lam_fid)), ar, nregs, True{}, False{}, False{}, b5k_list_rev(IrBlock, blks_rev)}, fr}, Con{CloEntry{lam_cid, lam_fid, ncaps}, er}}
def low_go(fuel: Nat, +env: LowEnv, st: CfgSt, task: LowTask, +is_tail: Bool) -> CfgSt:
  match fuel task:
    case Zero{} _: st
    case Succ{_} LTExprs{Nil{}, acc}: cfg_set_rlist(st, b5k_list_rev(U32, acc))
    case Succ{+p} LTExprs{Con{h, t}, acc}:
      +st1 = low_go(p, env, st, LTExpr{h}, False{})
      low_go(p, env, st1, LTExprs{t, Con{cfg_res(st1), acc}}, False{})
    case Succ{_} LTCases{_, Nil{}, _, _, _}: cfg_seal(st, TFail{1})
    case Succ{+p} LTCases{+base_vm, Con{Case{ps, +body}, rest}, +vscruts, +res_reg, +merge_blk}:
      match rest:
        case Nil{}:
          +st0 = st
          prev_mg = cfg_merged(st0)
          st1 = low_match_pats(64n, env, cfg_set_vmap(st0, base_vm), ps, vscruts, body, 0, False{})
          +st2 = low_go(p, env, st1, LTExpr{body}, is_tail)
          cfg_fin_branch(st2, cfg_sealed(st2), res_reg, cfg_res(st2), merge_blk, prev_mg)
        case Con{rh, rt}:
          +st0 = st
          prev_mg = cfg_merged(st0)
          +st_f = cfg_alloc_blk(st0)
          +nxt_blk = cfg_res(st_f)
          st1 = low_match_pats(64n, env, cfg_set_vmap(st_f, base_vm), ps, vscruts, body, nxt_blk, True{})
          +st2 = low_go(p, env, st1, LTExpr{body}, is_tail)
          st3 = cfg_fin_branch(st2, cfg_sealed(st2), res_reg, cfg_res(st2), merge_blk, prev_mg)
          low_go(p, env, cfg_start(st3, nxt_blk), LTCases{base_vm, Con{rh, rt}, vscruts, res_reg, merge_blk}, is_tail)
    case Succ{_} LTAppFn{_, _, +fid, _, vargs, True{}, _}:
      +st0 = st
      low_app_direct(st0, fid, vargs, Bool.and(is_tail, U32.is_eq(fid, cfg_cur_fid(st0))))
    case Succ{_} LTAppFn{_, _, fid, +ar, +vargs, False{}, True{}}:
      +st1 = low_app_direct(st, fid, low_take_u32(U32.to_nat(ar), vargs), False{})
      low_apply_chain(low_drop_u32(U32.to_nat(ar), vargs), st1, cfg_res(st1))
    case Succ{p} LTAppFn{sym, args, _, _, _, False{}, False{}}:
      +tmp = env_tmp(env)
      low_go(p, env, st, LTExpr{ELam{[Param{tmp, None{}, False{}, False{}}], EApp{EVar{sym}, b5k_list_app(Expr, args, [EVar{tmp}])}}}, False{})
    case Succ{p} LTAppGlob{_, args, icode, True{}, _, _}:
      +st1 = low_go(p, env, st, LTExprs{args, Nil{}}, False{})
      low_emit_u32_intr(st1, icode, cfg_rlist(st1))
    case Succ{+p} LTAppGlob{sym, +args, _, False{}, fv, False{}}:
      +fid = U32.sub(fv, 1)
      fargs = low_filter_erased(args, um_get(env_emask(env), fid), 0)
      +st1 = low_go(p, env, st, LTExprs{fargs, Nil{}}, False{})
      +vargs = cfg_rlist(st1)
      +av = um_get(env_arity(env), fid)
      +ar = Bool.pick(U32, U32.is_zero(av), 0, U32.sub(av, 1))
      +nargs = b5k_u32_list_len(vargs)
      low_go(p, env, st1, LTAppFn{sym, args, fid, ar, vargs, U32.is_eq(nargs, ar), U32.is_gt(nargs, ar)}, is_tail)
    case Succ{p} LTAppGlob{sym, args, _, False{}, _, True{}}:
      +st1 = low_go(p, env, st, LTExprs{args, Nil{}}, False{})
      low_emit_ctor_expr(env, st1, sym, cfg_rlist(st1))
    case Succ{p} LTAppSym{+sym, args, _, True{}}:
      +icode = low_u32_intr(symtab_name(env_syms(env), sym))
      +fv = um_get(env_fns(env), sym)
      low_go(p, env, st, LTAppGlob{sym, args, icode, U32.is_ne(icode, 0), fv, U32.is_zero(fv)}, is_tail)
    case Succ{p} LTAppSym{_, args, lv, False{}}:
      +st1 = low_go(p, env, st, LTExprs{args, Nil{}}, False{})
      low_apply_chain(cfg_rlist(st1), st1, U32.sub(lv, 1))
    case Succ{_} LTVar{_, lv, False{}}: cfg_set_res(st, U32.sub(lv, 1))
    case Succ{p} LTVar{+sym, _, True{}}:
      +fv = um_get(env_fns(env), sym)
      low_go(p, env, st, LTVarGlob{sym, U32.is_zero(fv)}, is_tail)
    case Succ{p} LTVarGlob{sym, False{}}:
      +tmp = env_tmp(env)
      low_go(p, env, st, LTExpr{ELam{[Param{tmp, None{}, False{}, False{}}], EApp{EVar{sym}, [EVar{tmp}]}}}, False{})
    case Succ{_} LTVarGlob{sym, True{}}: low_emit_ctor_expr(env, st, sym, Nil{})
    case Succ{p} LTLam{p0, +body, +fvs, bk0}:
      +st0 = st
      +ncaps = b5k_u32_list_len(fvs)
      +ar = U32.add(ncaps, 1)
      lam_st0 = low_bind_params([p0], low_bind_lam_caps(fvs, cfg_new(4294967295, ar, bk0), 0, body), ncaps, body)
      +lam_st1 = low_go(p, env, lam_st0, LTExpr{body}, True{})
      lam_cid = low_bank_next_cid(cfg_bank(lam_st1))
      bk2 = low_bank_finish_lam(ncaps, ar, cfg_seal(lam_st1, TRet{cfg_res(lam_st1)}))
      cap_vregs = low_lookup_fvs(fvs, cfg_vmap(st0))
      +st1 = cfg_alloc_reg(cfg_set_bank(st0, bk2))
      cfg_emit(st1, ICtor{cfg_res(st1), lam_cid, cap_vregs})
    case Succ{_} LTExpr{ENum{v}}:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, IConst{cfg_res(st1), v})
    case Succ{_} LTExpr{EFlt{bits}}:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, IFlt{cfg_res(st1), bits})
    case Succ{_} LTExpr{EChr{c}}:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, IConst{cfg_res(st1), c})
    case Succ{_} LTExpr{EUnit{}}:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, ICtor{cfg_res(st1), 7, Nil{}})
    case Succ{_} LTExpr{EStr{s}}: low_str_chain(s, st)
    case Succ{p} LTExpr{EVar{+sym}}:
      +st0 = st
      +lv = um_get(cfg_vmap(st0), sym)
      low_go(p, env, st0, LTVar{sym, lv, U32.is_zero(lv)}, is_tail)
    case Succ{p} LTExpr{ERef{sym}}: low_go(p, env, st, LTExpr{EVar{sym}}, is_tail)
    case Succ{+p} LTExpr{EOp{+op, a, b}}:
      +st1 = low_go(p, env, st, LTExpr{a}, False{})
      +st2 = low_go(p, env, st1, LTExpr{b}, False{})
      low_emit_op_go(U32.is_zero(op), env, st2, op, cfg_res(st1), cfg_res(st2))
    case Succ{p} LTExpr{EUnOp{op, a}}:
      +st1 = low_go(p, env, st, LTExpr{a}, False{})
      low_emit_un(st1, op, cfg_res(st1))
    case Succ{+p} LTExpr{ELet{pat, val, +body}}:
      +st0 = st
      base_vm = cfg_vmap(st0)
      +st1 = low_go(p, env, st0, LTExpr{val}, False{})
      st2 = low_match_pats(64n, env, st1, [pat], [cfg_res(st1)], body, 0, False{})
      cfg_set_vmap(low_go(p, env, st2, LTExpr{body}, is_tail), base_vm)
    case Succ{+p} LTExpr{EIf{cond, t, f}}:
      +st0 = st
      +base_vm = cfg_vmap(st0)
      +st1 = low_go(p, env, st0, LTExpr{cond}, False{})
      +st2 = cfg_alloc_blk(st1)
      +st3 = cfg_alloc_blk(st2)
      +st4 = cfg_alloc_blk(st3)
      +lbl_m = cfg_res(st4)
      +st5 = cfg_alloc_reg(st4)
      +res_reg = cfg_res(st5)
      +st6 = low_go(p, env, cfg_start(cfg_seal(st5, TBr{cfg_res(st1), cfg_res(st2), cfg_res(st3)}), cfg_res(st2)), LTExpr{t}, is_tail)
      +st7 = cfg_fin_branch(st6, cfg_sealed(st6), res_reg, cfg_res(st6), lbl_m, False{})
      +st8 = low_go(p, env, cfg_set_vmap(cfg_start(st7, cfg_res(st3)), base_vm), LTExpr{f}, is_tail)
      +st9 = cfg_fin_branch(st8, cfg_sealed(st8), res_reg, cfg_res(st8), lbl_m, cfg_merged(st7))
      cfg_set_res(cfg_set_vmap(cfg_maybe_start(st9, cfg_merged(st9), lbl_m), base_vm), res_reg)
    case Succ{p} LTExpr{ECtr{sym, fs}}:
      +st1 = low_go(p, env, st, LTExprs{fs, Nil{}}, False{})
      low_emit_ctor_expr(env, st1, sym, cfg_rlist(st1))
    case Succ{p} LTExpr{EApp{ERef{+sym}, args}}:
      +st0 = st
      +lv = um_get(cfg_vmap(st0), sym)
      low_go(p, env, st0, LTAppSym{sym, args, lv, U32.is_zero(lv)}, is_tail)
    case Succ{p} LTExpr{EApp{EVar{+sym}, args}}:
      +st0 = st
      +lv = um_get(cfg_vmap(st0), sym)
      low_go(p, env, st0, LTAppSym{sym, args, lv, U32.is_zero(lv)}, is_tail)
    case Succ{+p} LTExpr{EApp{other, args}}:
      +st1 = low_go(p, env, st, LTExpr{other}, False{})
      +st2 = low_go(p, env, st1, LTExprs{args, Nil{}}, False{})
      low_apply_chain(cfg_rlist(st2), st2, cfg_res(st1))
    case Succ{+p} LTExpr{EMat{scruts, cs}}:
      +st0 = st
      +base_vm = cfg_vmap(st0)
      +st1 = low_go(p, env, st0, LTExprs{scruts, Nil{}}, False{})
      +vscruts = cfg_rlist(st1)
      +st2 = cfg_alloc_reg(st1)
      +res_reg = cfg_res(st2)
      +st3 = cfg_alloc_blk(st2)
      +merge_blk = cfg_res(st3)
      +st4 = low_go(p, env, cfg_set_merged(st3, False{}), LTCases{base_vm, cs, vscruts, res_reg, merge_blk}, is_tail)
      cfg_set_res(cfg_set_vmap(cfg_maybe_start(st4, cfg_merged(st4), merge_blk), base_vm), res_reg)
    case Succ{p} LTExpr{EAnn{+v, typ}}:
      v2 = Bool.pick(Expr, b5k_str_eq(low_type_head(env_syms(env), typ), "F32"), low_f32_ops(32n, v), v)
      low_go(p, env, st, LTExpr{v2}, is_tail)
    case Succ{p} LTExpr{EList{es}}:
      +st1 = low_go(p, env, st, LTExprs{es, Nil{}}, False{})
      low_list_chain(cfg_rlist(st1), st1)
    case Succ{+p} LTExpr{EPair{a, b}}:
      +st1 = low_go(p, env, st, LTExpr{a}, False{})
      +st2 = low_go(p, env, st1, LTExpr{b}, False{})
      +st3 = cfg_alloc_reg(st2)
      cfg_emit(st3, ICtor{cfg_res(st3), 6, [cfg_res(st1), cfg_res(st2)]})
    case Succ{p} LTExpr{EArrNew{es}}:
      match es:
        case Con{v, Con{len, Nil{}}}: low_go(p, env, st, LTExpr{EApp{EVar{env_arr_len(env)}, [len, v]}}, is_tail)
        case _:
          +st1 = cfg_alloc_reg(st)
          cfg_emit(st1, IConst{cfg_res(st1), 0})
    case Succ{p} LTExpr{EArrGet{a, i}}: low_go(p, env, st, LTExpr{EApp{EVar{env_arr_get(env)}, [EUnit{}, a, i]}}, is_tail)
    case Succ{p} LTExpr{EArrSet{a, i, v}}: low_go(p, env, st, LTExpr{EApp{EVar{env_arr_set(env)}, [EUnit{}, a, i, v]}}, is_tail)
    case Succ{p} LTExpr{EDo{ss}}: low_go(p, env, st, LTExpr{low_desugar_do(env, ss)}, is_tail)
    case Succ{p} LTExpr{ELam{ps, +body}}:
      match ps:
        case Nil{}: low_go(p, env, st, LTExpr{body}, is_tail)
        case Con{p0, Con{p1, rest}}: low_go(p, env, st, LTExpr{low_curry_lam(Con{p0, Con{p1, rest}}, body)}, is_tail)
        case Con{+p0, Nil{}}:
          +st0 = st
          fvs = b5k_list_rev(U32, fv_go(U32.to_nat(2048), cfg_vmap(st0), fv_add_params([p0], UM0{}), UIExpr{body}, Nil{}))
          low_go(p, env, st0, LTLam{p0, body, fvs, cfg_bank(st0)}, False{})
    case Succ{_} _:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, IConst{cfg_res(st1), 0})
# Synthetic Runtime Dispatchers (__b5k_apply, __b5k_io_run, __b5k_io_cont)
def low_apply_arm_ops(is_z: Bool, fid: U32, res_reg: U32, +cap_regs: List<&2, U32>) -> List<&2, IrOp>:
  match is_z:
    case True{}: [ISink{0}, ICallDirect{res_reg, fid, [1]}]
    case False{}: [ITake{cap_regs, 0}, ICallDirect{res_reg, fid, b5k_list_app(U32, cap_regs, [1])}]
def low_mk_apply_arms(entries: List<&2, CloEntry>, +blk_id: U32, arms: List<&2, IrSwitchArm>, blks: List<&2, IrBlock>) -> List<&2, IrBlock> & List<&2, IrSwitchArm>:
  match entries:
    case Nil{}: (b5k_list_rev(IrBlock, blks), b5k_list_rev(IrSwitchArm, arms))
    case Con{CloEntry{cid, fid, +ncaps}, t}:
      st0 = low_alloc_regs_go(U32.to_nat(ncaps), cfg_new(0, 2, CloBank{0, 0, Nil{}, Nil{}, Nil{}}), Nil{})
      +res_reg = U32.add(2, ncaps)
      low_mk_apply_arms(t, U32.add(blk_id, 1), Con{IrArm{cid, blk_id}, arms}, Con{IrBlock{blk_id, low_apply_arm_ops(U32.is_zero(ncaps), fid, res_reg, cfg_rlist(st0)), TRet{res_reg}}, blks})
def low_max_caps(entries: List<&2, CloEntry>, acc: U32) -> U32:
  match entries:
    case Nil{}: acc
    case Con{CloEntry{_, _, nc}, t}: low_max_caps(t, U32.max(acc, nc))
def low_mk_apply_fin(entries: List<&2, CloEntry>, res: List<&2, IrBlock> & List<&2, IrSwitchArm>) -> IrFn:
  (arm_blks, arms) = res
  nregs = U32.max(5, U32.add(4, low_max_caps(entries, 0)))
  IrFn{0, "__b5k_apply", 2, nregs, True{}, False{}, False{},
    Con{IrBlock{0, [ITag{2, 0}], TSwitch{2, Con{IrArm{38, 1}, arms}, 2}},
    Con{IrBlock{1, [ISink{0}, IConst{3, 0}, ICtor{4, 12, [1, 3]}], TRet{4}},
    Con{IrBlock{2, Nil{}, TFail{1}}, arm_blks}}}}
def low_mk_apply_fn(+entries: List<&2, CloEntry>) -> IrFn:
  low_mk_apply_fin(entries, low_mk_apply_arms(entries, 3, Nil{}, Nil{}))
def low_mk_io_run_fn() -> IrFn:
  IrFn{1, "__b5k_io_run", 2, 4, True{}, False{}, False{}, [IrBlock{0, [ISink{1}, ICtor{2, 38, Nil{}}, ICallDirect{3, 0, [0, 2]}], TRet{3}}]}
def low_mk_io_cont_fn() -> IrFn:
  IrFn{2, "__b5k_io_cont", 2, 3, True{}, False{}, False{}, [IrBlock{0, [ICallDirect{2, 0, [0, 1]}], TRet{2}}]}
# Main Return Type & show_desc Builder
type ShowInfo is Data:
  ShowInfo{is_pure: Bool, desc: List<&2, U32>, names: List<&2, String>}
def low_find_law_ret(laws: List<&2, LawDef>, +msym: U32) -> Maybe<&2, Expr>:
  match laws:
    case Nil{}: None{}
    case Con{LawDef{s, _, ret}, t}: Bool.pick(Maybe<&2, Expr>, U32.is_eq(s, msym), Some{ret}, low_find_law_ret(t, msym))
def low_or_law(ret: Maybe<&2, Expr>, laws: List<&2, LawDef>, msym: U32) -> Maybe<&2, Expr>:
  match ret:
    case Some{r}: Some{r}
    case None{}: low_find_law_ret(laws, msym)
def low_find_main_ret(defs: List<&2, Def>, +laws: List<&2, LawDef>, +msym: U32) -> Maybe<&2, Expr>:
  match defs:
    case Nil{}: low_find_law_ret(laws, msym)
    case Con{Def{s, _, ret, _, _, _}, t}: Bool.pick(Maybe<&2, Expr>, U32.is_eq(s, msym), low_or_law(ret, laws, msym), low_find_main_ret(t, laws, msym))
type ShowBuild is Data:
  ShowBuild{words: List<&2, U32>, names: List<&2, String>, nnames: U32}
def low_amp_spine(fuel: Nat, e: Expr, acc: List<&2, Expr>) -> List<&2, Expr>:
  match fuel e:
    case 0n _: Con{e, acc}
    case 1n+p EOp{_, l, r}: low_amp_spine(p, l, Con{r, acc})
    case 1n+_ other: Con{other, acc}
def low_amp_build(es: List<&2, Expr>) -> Expr:
  match es:
    case Nil{}: EUnit{}
    case Con{h, Nil{}}: h
    case Con{h, t}: EOp{5, h, low_amp_build(t)}
def low_reassoc_amp(fuel: Nat, e: Expr) -> Expr:
  low_amp_build(low_amp_spine(fuel, e, Nil{}))
def low_last_expr(es: List<&2, Expr>, def_e: Expr) -> Expr:
  match es:
    case Nil{}: def_e
    case Con{h, Nil{}}: h
    case Con{_, t}: low_last_expr(t, def_e)
def low_type_elem(e: Expr) -> Expr:
  match e:
    case EApp{_, args}: low_last_expr(args, ENum{0})
    case _: ENum{0}
def low_show_code(+hd: String) -> U32:
  r = Bool.pick(U32, b5k_str_eq(hd, "Bool"), 6, Bool.pick(U32, b5k_str_eq(hd, "String"), 5, Bool.pick(U32, b5k_str_eq(hd, "Char"), 4, 0)))
  r = Bool.pick(U32, Bool.or(b5k_str_eq(hd, "List"), b5k_str_eq(hd, "Array")), 7, r)
  Bool.pick(U32, b5k_str_eq(hd, "IO"), 1, Bool.pick(U32, b5k_str_eq(hd, "F32"), 2, Bool.pick(U32, b5k_str_eq(hd, "Nat"), 3, r)))
def low_show_tup_b(nnames: U32, fst_idx: U32, snd_idx: U32, wa: List<&2, U32>, sb: ShowBuild) -> ShowBuild:
  match sb:
    case ShowBuild{wb, nb, nnb}:
      ShowBuild{b5k_list_app(U32, [7, 1, 1, nnames, 6, 2, 0, fst_idx, 1, snd_idx], b5k_list_app(U32, wa, wb)), nb, nnb}
def low_show_list_fin(base: U32, +nnames: U32, elem_idx: U32, sb: ShowBuild) -> ShowBuild:
  match sb:
    case ShowBuild{we, ne, nne}:
      ShowBuild{b5k_list_app(U32, [7, 1, 2, nnames, 4, 0, U32.add(nnames, 1), 5, 2, 0, elem_idx, 1, base], we), ne, nne}
type ShowTask is Data:
  STEnc{e: Expr, base: U32, names: List<&2, String>, nnames: U32}
  STHead{code: U32, o: Expr, base: U32, names: List<&2, String>, nnames: U32}
  STTupA{b: Expr, nnames: U32, fst_idx: U32, sb: ShowBuild}
def low_show_go(+fuel: Nat, +syms: SymTab, task: ShowTask) -> ShowBuild:
  match fuel task:
    case 0n STEnc{_, _, names, nnames}: ShowBuild{[0], names, nnames}
    case 0n STHead{_, _, _, names, nnames}: ShowBuild{[0], names, nnames}
    case 0n STTupA{_, _, _, sb}: sb
    case 1n+p STTupA{b, nnames, +fst_idx, ShowBuild{+wa, na, nna}}:
      +snd_idx = U32.add(fst_idx, b5k_u32_list_len(wa))
      low_show_tup_b(nnames, fst_idx, snd_idx, wa, low_show_go(p, syms, STEnc{b, snd_idx, na, nna}))
    case 1n+p STHead{code, o, +base, names, +nnames}:
      match code:
        case 2: ShowBuild{[1], names, nnames}
        case 3: ShowBuild{[2], names, nnames}
        case 4: ShowBuild{[3, 0], names, nnames}
        case 5: ShowBuild{[4], names, nnames}
        case 6: ShowBuild{[7, 0, 2, nnames, 18, 0, U32.add(nnames, 1), 14, 0], b5k_list_app(String, names, ["False", "True"]), U32.add(nnames, 2)}
        case 7:
          +elem_idx = U32.add(base, 13)
          low_show_list_fin(base, nnames, elem_idx, low_show_go(p, syms, STEnc{low_reassoc_amp(64n, low_type_elem(o)), elem_idx, b5k_list_app(String, names, ["Nil", "Con"]), U32.add(nnames, 2)}))
        case _: ShowBuild{[0], names, nnames}
    case 1n+p STEnc{EOp{_, a, b}, base, names, +nnames}:
      +fst_idx = U32.add(base, 10)
      sb_a = low_show_go(p, syms, STEnc{low_reassoc_amp(64n, a), fst_idx, b5k_list_app(String, names, ["Tuple"]), U32.add(nnames, 1)})
      low_show_go(p, syms, STTupA{b, nnames, fst_idx, sb_a})
    case 1n+p STEnc{+o, base, names, nnames}:
      low_show_go(p, syms, STHead{low_show_code(low_type_head(syms, o)), o, base, names, nnames})
def low_show_from_sb(sb: ShowBuild) -> ShowInfo:
  match sb:
    case ShowBuild{ws, ns, _}: ShowInfo{True{}, ws, ns}
def low_show_io_or(is_io: Bool, syms: SymTab, e: Expr) -> ShowInfo:
  match is_io:
    case True{}: ShowInfo{False{}, Nil{}, Nil{}}
    case False{}: low_show_from_sb(low_show_go(64n, syms, STEnc{low_reassoc_amp(64n, e), 0, Nil{}, 0}))
def low_show_info(+syms: SymTab, mret: Maybe<&2, Expr>) -> ShowInfo:
  match mret:
    case None{}: ShowInfo{True{}, [0], Nil{}}
    case Some{+e}: low_show_io_or(U32.is_eq(low_show_code(low_type_head(syms, e)), 1), syms, e)
def low_has_arr(+fuel: Nat, +syms: SymTab, e: Expr) -> Bool:
  match fuel e:
    case 0n _: False{}
    case 1n+p EOp{_, a, b}: Bool.or(low_has_arr(p, syms, a), low_has_arr(p, syms, b))
    case 1n+_ other: b5k_str_eq(low_type_head(syms, other), "Array")
def low_norm_arr(+fuel: Nat, +syms: SymTab, +t1: U32, +t2: U32, +a2l: U32, +e: Expr, ty: Expr) -> Expr:
  match fuel ty:
    case 0n _: e
    case 1n+p EOp{_, +a, +b}:
      Bool.pick(Expr, Bool.or(low_has_arr(p, syms, a), low_has_arr(p, syms, b)),
        ELet{PPair{PVar{t1, False{}}, PVar{t2, False{}}}, e, EPair{low_norm_arr(p, syms, t1, t2, a2l, EVar{t1}, a), low_norm_arr(p, syms, t1, t2, a2l, EVar{t2}, b)}}, e)
    case 1n+_ other: Bool.pick(Expr, b5k_str_eq(low_type_head(syms, other), "Array"), EApp{EVar{a2l}, [EUnit{}, e]}, e)
def low_patch_main_one(is_m: Bool, syms: SymTab, t1: U32, t2: U32, a2l: U32, rty: Expr, d: Def) -> Def:
  match is_m d:
    case False{} _: d
    case True{} Def{s, ps, ret, body, imp, uns}: Def{s, ps, ret, low_norm_arr(32n, syms, t1, t2, a2l, body, low_reassoc_amp(64n, rty)), imp, uns}
def low_patch_main(ds: List<&2, Def>, +msym: U32, +syms: SymTab, +t1: U32, +t2: U32, +a2l: U32, +rty: Expr) -> List<&2, Def>:
  match ds:
    case Nil{}: Nil{}
    case Con{Def{+s, ps, ret, body, imp, uns}, t}:
      Con{low_patch_main_one(U32.is_eq(s, msym), syms, t1, t2, a2l, rty, Def{s, ps, ret, body, imp, uns}), low_patch_main(t, msym, syms, t1, t2, a2l, rty)}
def low_maybe_patch_main(is_pure: Bool, mret: Maybe<&2, Expr>, +defs: List<&2, Def>, msym: U32, +syms: SymTab, t1: U32, t2: U32, a2l: U32) -> List<&2, Def>:
  match is_pure mret:
    case True{} Some{+rty}:
      Bool.pick(List<&2, Def>, low_has_arr(32n, syms, rty), low_patch_main(defs, msym, syms, t1, t2, a2l, rty), defs)
    case _ _: defs
# Function & Book Lowering
type DefRes is Data:
  DefRes{fn: IrFn, bank: CloBank}
def low_dr_fn(dr: DefRes) -> IrFn:
  match dr:
    case DefRes{fn, _}: fn
def low_dr_bank(dr: DefRes) -> CloBank:
  match dr:
    case DefRes{_, bk}: bk
def low_def_wrap_main(is_io_main: Bool, +st: CfgSt) -> CfgSt:
  match is_io_main:
    case False{}: cfg_seal(st, TRet{cfg_res(st)})
    case True{}:
      +st1 = cfg_alloc_reg(st)
      +clo = cfg_res(st1)
      cfg_seal(cfg_emit(st1, ICallClosure{clo, 1, [cfg_res(st)]}), TRet{clo})
def low_def_fin(env: LowEnv, +fid: U32, sym: U32, ar: U32, st: CfgSt) -> DefRes:
  match env st:
    case LowEnv{syms, _, _, _, _, main_fid, _, _, _, _, _, _, _, _} CfgSt{_, nregs, _, _, _, blks_rev, _, _, _, _, _, bk}:
      DefRes{IrFn{fid, symtab_name(syms, sym), ar, nregs, False{}, False{}, U32.is_eq(fid, main_fid), b5k_list_rev(IrBlock, blks_rev)}, bk}
def low_def(+env: LowEnv, +fid: U32, d: Def, bank: CloBank) -> DefRes:
  match env d:
    case LowEnv{_, _, _, _, _, main_fid, main_pure, _, _, _, _, _, _, _} Def{sym, +params, _, +body, _, _}:
      +ar = low_param_arity_go(params, 0)
      +st2 = low_go(U32.to_nat(2048), env, low_bind_params(params, cfg_new(fid, ar, bank), 0, body), LTExpr{body}, True{})
      low_def_fin(env, fid, sym, ar, low_def_wrap_main(Bool.and(U32.is_eq(fid, main_fid), Bool.not(main_pure)), st2))
type DefsRes is Data:
  DefsRes{fns: List<&2, IrFn>, bank: CloBank}
def low_defs(ds: List<&2, Def>, +env: LowEnv, +fid: U32, acc: List<&2, IrFn>, bank: CloBank) -> DefsRes:
  match ds:
    case Nil{}: DefsRes{b5k_list_rev(IrFn, acc), bank}
    case Con{d, t}:
      +dr = low_def(env, fid, d, bank)
      low_defs(t, env, U32.add(fid, 1), Con{low_dr_fn(dr), acc}, low_dr_bank(dr))
def b5k_lower_fin(dr: DefsRes, ctors_base: List<&2, IrCtor>, main_fid: U32, si: ShowInfo) -> LowerRes:
  match dr si:
    case DefsRes{def_fns, CloBank{_, _, lam_ctors_rev, lam_fns_rev, entries_rev}} ShowInfo{is_pure, sdesc, snames}:
      all_ctors = b5k_list_app(IrCtor, ctors_base, b5k_list_rev(IrCtor, lam_ctors_rev))
      LowerRes{True{}, "", IrProg{Con{low_mk_apply_fn(b5k_list_rev(CloEntry, entries_rev)), Con{low_mk_io_run_fn(), Con{low_mk_io_cont_fn(), b5k_list_app(IrFn, def_fns, b5k_list_rev(IrFn, lam_fns_rev))}}}, all_ctors, Nil{}, main_fid, is_pure, Nil{}, sdesc, snames}}
def low_sym_or(m: Maybe<&2, U32>) -> U32:
  match m:
    case Some{s}: s
    case None{}: 0
def b5k_lower_s4(s4: SymTab, +sym_tmp: U32, sym_t2: U32, defs: List<&2, Def>, ctor_by_sym: U32Map, next_cid: U32, ctors_rev: List<&2, IrCtor>, next_fid: U32, fn_by_sym: U32Map, fn_arity: U32Map, fn_emask: U32Map, +main_fid: U32, main_sym: U32, mret: Maybe<&2, Expr>, si: ShowInfo) -> LowerRes:
  match si:
    case ShowInfo{+is_pure, sdesc, snames}:
      +st = s4
      defs2 = low_maybe_patch_main(is_pure, mret, defs, main_sym, st, sym_tmp, sym_t2, low_sym_or(symtab_lookup(st, "Array.to_list")))
      dr = low_defs(defs2, LowEnv{st, ctor_by_sym, fn_by_sym, fn_arity, fn_emask, main_fid, is_pure, low_sym_or(symtab_lookup(st, "IO.bind")), low_sym_or(symtab_lookup(st, "IO.pure")), low_sym_or(symtab_lookup(st, "String.append")), sym_tmp, low_sym_or(symtab_lookup(st, "__arr_len")), low_sym_or(symtab_lookup(st, "Array.get")), low_sym_or(symtab_lookup(st, "Array.set"))}, 3, Nil{}, CloBank{next_fid, next_cid, Nil{}, Nil{}, Nil{}})
      b5k_lower_fin(dr, b5k_list_rev(IrCtor, ctors_rev), main_fid, ShowInfo{is_pure, sdesc, snames})
def b5k_lower_i2(sr: SymRes, sym_tmp: U32, +defs: List<&2, Def>, laws: List<&2, LawDef>, ctor_by_sym: U32Map, next_cid: U32, ctors_rev: List<&2, IrCtor>, next_fid: U32, fn_by_sym: U32Map, fn_arity: U32Map, fn_emask: U32Map, main_fid: U32, +main_sym: U32) -> LowerRes:
  match sr:
    case SymRes{+s5, sym_t2}:
      +mret = low_find_main_ret(defs, laws, main_sym)
      b5k_lower_s4(s5, sym_tmp, sym_t2, defs, ctor_by_sym, next_cid, ctors_rev, next_fid, fn_by_sym, fn_arity, fn_emask, main_fid, main_sym, mret, low_show_info(s5, mret))
def b5k_lower_i1(sr: SymRes, defs: List<&2, Def>, laws: List<&2, LawDef>, ctor_by_sym: U32Map, next_cid: U32, ctors_rev: List<&2, IrCtor>, next_fid: U32, fn_by_sym: U32Map, fn_arity: U32Map, fn_emask: U32Map, main_fid: U32, main_sym: U32) -> LowerRes:
  match sr:
    case SymRes{s4, sym_tmp}:
      b5k_lower_i2(symtab_intern(s4, "__b5k_t2"), sym_tmp, defs, laws, ctor_by_sym, next_cid, ctors_rev, next_fid, fn_by_sym, fn_arity, fn_emask, main_fid, main_sym)
def b5k_lower_s3(syms: SymTab, defs: List<&2, Def>, laws: List<&2, LawDef>, ctor_by_sym: U32Map, next_cid: U32, ctors_rev: List<&2, IrCtor>, fa: FnTabAcc) -> LowerRes:
  match fa:
    case FnTabAcc{next_fid, fn_by_sym, fn_arity, fn_emask, main_fid, main_sym}:
      b5k_lower_i1(symtab_intern(syms, "__b5k_tmp"), defs, laws, ctor_by_sym, next_cid, ctors_rev, next_fid, fn_by_sym, fn_arity, fn_emask, main_fid, main_sym)
def b5k_lower_s2(+defs: List<&2, Def>, laws: List<&2, LawDef>, ca: CtorTabAcc) -> LowerRes:
  match ca:
    case CtorTabAcc{+syms, next_cid, ctor_by_sym, ctors_rev}:
      b5k_lower_s3(syms, defs, laws, ctor_by_sym, next_cid, ctors_rev, low_add_defs(syms, defs, FnTabAcc{3, UM0{}, UM0{}, UM0{}, 3, 0}))
def b5k_lower_with_prelude(types: List<&2, TypeDef>, udefs: List<&2, Def>, laws: List<&2, LawDef>, pr: ParseRes) -> LowerRes:
  match pr:
    case ParseRes{_, _, Book{_, pdefs, _, syms1}}:
      b5k_lower_s2(b5k_list_app(Def, pdefs, udefs), laws, low_add_types(types, low_seed_core(low_core_specs(), CtorTabAcc{syms1, 0, UM0{}, Nil{}})))
def b5k_lower(book: Book) -> LowerRes:
  match book:
    case Book{types, defs, laws, syms}:
      b5k_lower_with_prelude(types, defs, laws, b5k_parse(b5k_prelude_src(), syms))
