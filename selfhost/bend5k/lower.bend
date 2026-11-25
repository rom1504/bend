# bend5k/lower.bend — Direct-First ANF/CFG Lowerer (Book -> IrProg)
# ==================================================================
type LowerRes is Data:
  LowerRes{ok: Bool, err: String, prog: IrProg}
# Dense U32 -> U32 Map via Core RaVec<U32> (0 = absent)
type U32Map is Data:
  UM0{}
  UMV{v: RaVec<U32>}
def um_set(m: U32Map, +k: U32, v: U32) -> U32Map:
  match m:
    case UM0{}: UMV{ra_vec_set(U32, 8n, k, v, RVEmpty{})}
    case UMV{t}: UMV{ra_vec_set(U32, 8n, k, v, t)}
def um_get(m: U32Map, +k: U32) -> U32:
  match m:
    case UM0{}: 0
    case UMV{t}: ra_vec_get(U32, 8n, 0, k, t)
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
  "def __arr_len(n: U32, v: U32) -> Array<U32>:\n  d = if U32.is_le(n, 1): 0 else: U32.log2(n)\n  Array.new(U32, d, v)\n" ++
  "def Array.fork(-T: Data, +a: Array<T>) -> Array<T>:\n  Tuple{a, a}\n" ++
  "def Array.join(-T: Data, a: Array<T>, b: Array<T>) -> Array<T>:\n  a\n" ++
  "def __arr_toli_go(n: Nat, i: U32, a: Array<U32>, acc: List<U32>) -> List<U32>:\n  match n:\n    case 0n: acc\n    case 1n+p:\n      (a2, v) = Array.get(U32, a, i)\n      __arr_toli_go(p, U32.sub(i, 1), a2, Con{v, acc})\n" ++
  "def Array.to_list(-T: Data, a: Array<T>) -> List<T>:\n  (a2, n) = Array.size(T, a)\n  __arr_toli_go(U32.to_nat(n), U32.sub(n, 1), a2, Nil{})\n" ++
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
def low_seed_u32_one(m: Maybe<&2, U32>, code: U32, acc: U32Map) -> U32Map:
  match m:
    case None{}: acc
    case Some{s}: um_set(acc, s, code)
def low_seed_u32_map(+syms: SymTab, xs: List<&2, CoreCtorSpec>, acc: U32Map) -> U32Map:
  match xs:
    case Nil{}: acc
    case Con{CoreCtorSpec{nm, code}, t}: low_seed_u32_map(syms, t, low_seed_u32_one(symtab_lookup(syms, nm), code, acc))
def low_intr_specs() -> List<&2, CoreCtorSpec>:
  [CoreCtorSpec{"U32.add", 1}, CoreCtorSpec{"Nat.add", 1}, CoreCtorSpec{"U32.sub", 2}, CoreCtorSpec{"U32.mul", 3}, CoreCtorSpec{"Nat.mul", 3}, CoreCtorSpec{"U32.div", 4}, CoreCtorSpec{"U32.mod", 5},
   CoreCtorSpec{"U32.and", 6}, CoreCtorSpec{"Bool.and", 6}, CoreCtorSpec{"U32.or", 7}, CoreCtorSpec{"Bool.or", 7}, CoreCtorSpec{"U32.xor", 8}, CoreCtorSpec{"Bool.xor", 8},
   CoreCtorSpec{"U32.is_eq", 11}, CoreCtorSpec{"Nat.is_eq", 11}, CoreCtorSpec{"U32.is_ne", 12}, CoreCtorSpec{"Nat.is_ne", 12}, CoreCtorSpec{"U32.is_lt", 13}, CoreCtorSpec{"Nat.is_lt", 13},
   CoreCtorSpec{"U32.is_le", 14}, CoreCtorSpec{"Nat.is_le", 14}, CoreCtorSpec{"U32.is_gt", 15}, CoreCtorSpec{"Nat.is_gt", 15}, CoreCtorSpec{"U32.is_ge", 16}, CoreCtorSpec{"Nat.is_ge", 16},
   CoreCtorSpec{"U32.min", 17}, CoreCtorSpec{"Nat.min", 17}, CoreCtorSpec{"U32.max", 18}, CoreCtorSpec{"Nat.max", 18}, CoreCtorSpec{"U32.inc", 19}, CoreCtorSpec{"U32.dec", 20},
   CoreCtorSpec{"U32.is_zero", 21}, CoreCtorSpec{"Bool.not", 21}, CoreCtorSpec{"U32.shl", 22}, CoreCtorSpec{"Nat.double", 22}, CoreCtorSpec{"U32.shr", 23}, CoreCtorSpec{"U32.shln", 24},
   CoreCtorSpec{"U32.shrn", 25}, CoreCtorSpec{"U32.not", 26}, CoreCtorSpec{"U32.from_nat", 27}, CoreCtorSpec{"U32.to_nat", 27}, CoreCtorSpec{"F32.bits", 27}, CoreCtorSpec{"Bool.to_u32", 27},
   CoreCtorSpec{"Char.to_u32", 27}, CoreCtorSpec{"Char.from_u32", 27}, CoreCtorSpec{"Nat.sub", 30}, CoreCtorSpec{"__io_print", 31}, CoreCtorSpec{"__io_print_err", 32},
   CoreCtorSpec{"__io_args", 33}, CoreCtorSpec{"__io_now", 34}, CoreCtorSpec{"__file_open", 35}, CoreCtorSpec{"__file_read", 36}, CoreCtorSpec{"__file_size", 37},
   CoreCtorSpec{"__file_write", 38}, CoreCtorSpec{"__file_write_bytes", 39}, CoreCtorSpec{"__file_close", 54}, CoreCtorSpec{"F32.add", 40}, CoreCtorSpec{"F32.sub", 41},
   CoreCtorSpec{"F32.mul", 42}, CoreCtorSpec{"F32.div", 43}, CoreCtorSpec{"F32.is_eq", 44}, CoreCtorSpec{"F32.is_ne", 45}, CoreCtorSpec{"F32.is_lt", 46}, CoreCtorSpec{"F32.is_le", 47},
   CoreCtorSpec{"F32.is_gt", 48}, CoreCtorSpec{"F32.is_ge", 49}, CoreCtorSpec{"F32.neg", 50}, CoreCtorSpec{"F32.sqrt", 51}, CoreCtorSpec{"U32.to_f32", 52}, CoreCtorSpec{"F32.from_u32", 52},
   CoreCtorSpec{"F32.to_u32", 53}, CoreCtorSpec{"Array.new", 60}, CoreCtorSpec{"Array.get", 61}, CoreCtorSpec{"Array.get_unchecked", 61}, CoreCtorSpec{"Array.set", 62}, CoreCtorSpec{"Array.set_unchecked", 62},
   CoreCtorSpec{"Array.swap", 63}, CoreCtorSpec{"Array.size", 64}, CoreCtorSpec{"Array.clone", 65}, CoreCtorSpec{"U32.cmp", 66}, CoreCtorSpec{"Nat.cmp", 66},
   CoreCtorSpec{"U32.log2", 67}, CoreCtorSpec{"String.length", 67}, CoreCtorSpec{"String.eq", 67}, CoreCtorSpec{"String.is_empty", 67}, CoreCtorSpec{"String.starts_with", 67}, CoreCtorSpec{"Cmp.is_eq", 67}]
def low_kind_specs() -> List<&2, CoreCtorSpec>:
  [CoreCtorSpec{"False", 1}, CoreCtorSpec{"True", 2}, CoreCtorSpec{"Zero", 3}, CoreCtorSpec{"Succ", 4}, CoreCtorSpec{"Chr", 5}, CoreCtorSpec{"ALeaf", 8}, CoreCtorSpec{"ANode", 9},
   CoreCtorSpec{"LT", 10}, CoreCtorSpec{"EQ", 11}, CoreCtorSpec{"GT", 12}, CoreCtorSpec{"Pair", 13}, CoreCtorSpec{"U32", 14}, CoreCtorSpec{"Nat", 15}, CoreCtorSpec{"F32", 16}, CoreCtorSpec{"Char", 17}, CoreCtorSpec{"Bool", 18}]
def low_is_scalar_type(+skind: U32Map, ty: Expr) -> Bool:
  match ty:
    case EVar{s}: U32.is_ge(um_get(skind, s), 14)
    case ERef{s}: U32.is_ge(um_get(skind, s), 14)
    case _: False{}
def low_type_sc_code(+skind: U32Map, ty: Expr) -> U32:
  match ty:
    case EVar{s}: Bool.to_u32(U32.is_ge(um_get(skind, s), 14))
    case ERef{s}: Bool.to_u32(U32.is_ge(um_get(skind, s), 14))
    case EOp{5, a, b}:
      U32.or(Bool.pick(U32, low_is_scalar_type(skind, a), 2, 0), Bool.pick(U32, low_is_scalar_type(skind, b), 4, 0))
    case _: 0
def low_maybe_sc_code(+skind: U32Map, mt: Maybe<&2, Expr>) -> U32:
  match mt:
    case Some{ty}: low_type_sc_code(skind, ty)
    case None{}: 0
def low_maybe_scalar_type(+skind: U32Map, mt: Maybe<&2, Expr>) -> Bool:
  U32.is_eq(low_maybe_sc_code(skind, mt), 1)
def low_param_smask_go(+skind: U32Map, ps: List<&2, Param>, +idx: U32, acc: U32) -> U32:
  match ps:
    case Nil{}: acc
    case Con{Param{_, typ, _, _}, t}:
      bit = Bool.pick(U32, Bool.and(low_maybe_scalar_type(skind, typ), U32.is_lt(idx, 32)), U32.shln(1, U32.to_nat(idx)), 0)
      low_param_smask_go(skind, t, U32.add(idx, 1), U32.or(acc, bit))
type CtorTabAcc is Data:
  CtorTabAcc{syms: SymTab, next_cid: U32, by_sym: U32Map, smask_by_sym: U32Map, single_by_sym: U32Map, ctors_rev: List<&2, IrCtor>}
def low_seed_core_one(sr: SymRes, +name: String, ar: U32, +cid: U32, by_sym: U32Map, smask_by_sym: U32Map, +single_by_sym: U32Map, rev: List<&2, IrCtor>) -> CtorTabAcc:
  match sr:
    case SymRes{s2, +sym}:
      is_s = Bool.or(b5k_str_eq(name, "Tuple"), Bool.or(b5k_str_eq(name, "Pair"), b5k_str_eq(name, "Unit")))
      sg2 = Bool.pick(U32Map, is_s, um_set(single_by_sym, sym, 1), single_by_sym)
      CtorTabAcc{s2, U32.add(cid, 1), um_set(by_sym, sym, U32.add(cid, 1)), smask_by_sym, sg2, Con{IrCtor{cid, name, ar, False{}}, rev}}
def low_seed_core(specs: List<&2, CoreCtorSpec>, acc: CtorTabAcc) -> CtorTabAcc:
  match specs acc:
    case Nil{} _: acc
    case Con{CoreCtorSpec{+nm, ar}, t} CtorTabAcc{syms, cid, by_sym, smask, single, rev}:
      low_seed_core(t, low_seed_core_one(symtab_intern(syms, nm), nm, ar, cid, by_sym, smask, single, rev))
def low_add_ctor_one(has: Bool, +skind: U32Map, +sym: U32, +fields: List<&2, Param>, acc: CtorTabAcc) -> CtorTabAcc:
  match has acc:
    case True{} a: a
    case False{} CtorTabAcc{+syms, +cid, by_sym, smask, single, rev}:
      sm = low_param_smask_go(skind, fields, 0, 0)
      CtorTabAcc{syms, U32.add(cid, 1), um_set(by_sym, sym, U32.add(cid, 1)), um_set(smask, sym, sm), single, Con{IrCtor{cid, symtab_name(syms, sym), b5k_list_len(Param, fields), False{}}, rev}}
def low_add_ctors(+skind: U32Map, cs: List<&2, CtorDef>, acc: CtorTabAcc) -> CtorTabAcc:
  match cs acc:
    case Nil{} a: a
    case Con{CtorDef{+sym, _, fields}, t} CtorTabAcc{syms, cid, +by_sym, smask, single, rev}:
      low_add_ctors(skind, t, low_add_ctor_one(U32.is_ne(um_get(by_sym, sym), 0), skind, sym, fields, CtorTabAcc{syms, cid, by_sym, smask, single, rev}))
def low_mark_single(sym: U32, acc: CtorTabAcc) -> CtorTabAcc:
  match acc:
    case CtorTabAcc{syms, cid, by_sym, smask, single, rev}:
      CtorTabAcc{syms, cid, by_sym, smask, um_set(single, sym, 1), rev}
def low_add_types(+skind: U32Map, ts: List<&2, TypeDef>, acc: CtorTabAcc) -> CtorTabAcc:
  match ts:
    case Nil{}: acc
    case Con{TypeDef{_, _, _, Con{CtorDef{+csym, cid, fs}, Nil{}}}, t}:
      low_add_types(skind, t, low_mark_single(csym, low_add_ctors(skind, [CtorDef{csym, cid, fs}], acc)))
    case Con{TypeDef{_, _, _, cs}, t}: low_add_types(skind, t, low_add_ctors(skind, cs, acc))
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
    syms: SymTab, ctor_by_sym: U32Map, ctor_smask: U32Map, ctor_single: U32Map, fn_by_sym: U32Map, fn_arity: U32Map, fn_emask: U32Map,
    sym_intr: U32Map, sym_kind: U32Map,
    main_fid: U32, main_pure: Bool,
    sym_io_bind: U32, sym_io_pure: U32, sym_str_app: U32, sym_tmp: U32,
    sym_arr_len: U32
  }
def env_syms(e: LowEnv) -> SymTab:
  LowEnv{s, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _} = e
  s
def env_ctors(e: LowEnv) -> U32Map:
  LowEnv{_, m, _, _, _, _, _, _, _, _, _, _, _, _, _, _} = e
  m
def env_csmask(e: LowEnv) -> U32Map:
  LowEnv{_, _, m, _, _, _, _, _, _, _, _, _, _, _, _, _} = e
  m
def env_csingle(e: LowEnv) -> U32Map:
  LowEnv{_, _, _, m, _, _, _, _, _, _, _, _, _, _, _, _} = e
  m
def env_fns(e: LowEnv) -> U32Map:
  LowEnv{_, _, _, _, m, _, _, _, _, _, _, _, _, _, _, _} = e
  m
def env_arity(e: LowEnv) -> U32Map:
  LowEnv{_, _, _, _, _, m, _, _, _, _, _, _, _, _, _, _} = e
  m
def env_emask(e: LowEnv) -> U32Map:
  LowEnv{_, _, _, _, _, _, m, _, _, _, _, _, _, _, _, _} = e
  m
def env_intr(e: LowEnv) -> U32Map:
  LowEnv{_, _, _, _, _, _, _, m, _, _, _, _, _, _, _, _} = e
  m
def env_kind(e: LowEnv) -> U32Map:
  LowEnv{_, _, _, _, _, _, _, _, m, _, _, _, _, _, _, _} = e
  m
def env_io_bind(e: LowEnv) -> U32:
  LowEnv{_, _, _, _, _, _, _, _, _, _, _, s, _, _, _, _} = e
  s
def env_io_pure(e: LowEnv) -> U32:
  LowEnv{_, _, _, _, _, _, _, _, _, _, _, _, s, _, _, _} = e
  s
def env_str_app(e: LowEnv) -> U32:
  LowEnv{_, _, _, _, _, _, _, _, _, _, _, _, _, s, _, _} = e
  s
def env_tmp(e: LowEnv) -> U32:
  LowEnv{_, _, _, _, _, _, _, _, _, _, _, _, _, _, s, _} = e
  s
def env_arr_len(e: LowEnv) -> U32:
  LowEnv{_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, s} = e
  s
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
    case Succ{+p} UICases{Con{Case{ps, body}, t}}: U32.max(Bool.pick(U32, pat_binds_all(64n, sym, ps), 0, count_uses_go(p, sym, UIExpr{body})), count_uses_go(p, sym, UICases{t}))
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
    case Succ{+p} UIExpr{EIf{c, t, f}}: U32.add(count_uses_go(p, sym, UIExpr{c}), U32.max(count_uses_go(p, sym, UIExpr{t}), count_uses_go(p, sym, UIExpr{f})))
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
    sealed: Bool, res: U32, rlist: List<&2, U32>, vmap: U32Map, nvm: U32Map, merged: Bool, bank: CloBank
  }
def cfg_new(fid: U32, nparams: U32, bank: CloBank) -> CfgSt:
  CfgSt{fid, nparams, 1, 0, Nil{}, Nil{}, False{}, 0, Nil{}, UM0{}, UM0{}, False{}, bank}
def cfg_res(st: CfgSt) -> U32:
  match st:
    case CfgSt{_, _, _, _, _, _, _, r, _, _, _, _, _}: r
def cfg_rlist(st: CfgSt) -> List<&2, U32>:
  match st:
    case CfgSt{_, _, _, _, _, _, _, _, rl, _, _, _, _}: rl
def cfg_vmap(st: CfgSt) -> U32Map:
  match st:
    case CfgSt{_, _, _, _, _, _, _, _, _, vm, _, _, _}: vm
def cfg_nvm(st: CfgSt) -> U32Map:
  match st:
    case CfgSt{_, _, _, _, _, _, _, _, _, _, nvm, _, _}: nvm
def cfg_sealed(st: CfgSt) -> Bool:
  match st:
    case CfgSt{_, _, _, _, _, _, s, _, _, _, _, _, _}: s
def cfg_merged(st: CfgSt) -> Bool:
  match st:
    case CfgSt{_, _, _, _, _, _, _, _, _, _, _, m, _}: m
def cfg_cur_fid(st: CfgSt) -> U32:
  match st:
    case CfgSt{fid, _, _, _, _, _, _, _, _, _, _, _, _}: fid
def cfg_bank(st: CfgSt) -> CloBank:
  match st:
    case CfgSt{_, _, _, _, _, _, _, _, _, _, _, _, bk}: bk
def cfg_set_res(st: CfgSt, r: U32) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, cb, ops, blks, s, _, rl, vm, nvm, mg, bk}: CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, nvm, mg, bk}
def cfg_set_rlist(st: CfgSt, rl: List<&2, U32>) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, cb, ops, blks, s, r, _, vm, nvm, mg, bk}: CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, nvm, mg, bk}
def cfg_set_vm_nvm(st: CfgSt, vm: U32Map, nvm: U32Map) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, _, _, mg, bk}: CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, nvm, mg, bk}
def cfg_set_merged(st: CfgSt, mg: Bool) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, nvm, _, bk}: CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, nvm, mg, bk}
def cfg_set_bank(st: CfgSt, bk: CloBank) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, nvm, mg, _}: CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, nvm, mg, bk}
def cfg_alloc_reg(st: CfgSt) -> CfgSt:
  match st:
    case CfgSt{f, +nr, nb, cb, ops, blks, s, _, rl, vm, nvm, mg, bk}: CfgSt{f, U32.add(nr, 1), nb, cb, ops, blks, s, nr, rl, vm, nvm, mg, bk}
def cfg_alloc_blk(st: CfgSt) -> CfgSt:
  match st:
    case CfgSt{f, nr, +nb, cb, ops, blks, s, _, rl, vm, nvm, mg, bk}: CfgSt{f, nr, U32.add(nb, 1), cb, ops, blks, s, nb, rl, vm, nvm, mg, bk}
def cfg_emit(st: CfgSt, op: IrOp) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, cb, ops, blks, sealed, r, rl, vm, nvm, mg, bk}:
      match sealed:
        case True{}: CfgSt{f, nr, nb, cb, ops, blks, True{}, r, rl, vm, nvm, mg, bk}
        case False{}: CfgSt{f, nr, nb, cb, Con{op, ops}, blks, False{}, r, rl, vm, nvm, mg, bk}
def cfg_seal(st: CfgSt, term: IrTerm) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, +cb, ops, blks, sealed, r, rl, vm, nvm, mg, bk}:
      match sealed:
        case True{}: CfgSt{f, nr, nb, cb, ops, blks, True{}, r, rl, vm, nvm, mg, bk}
        case False{}: CfgSt{f, nr, nb, cb, Nil{}, Con{IrBlock{cb, b5k_list_rev(IrOp, ops), term}, blks}, True{}, r, rl, vm, nvm, mg, bk}
def cfg_start(st: CfgSt, blk_id: U32) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, _, _, blks, _, r, rl, vm, nvm, mg, bk}: CfgSt{f, nr, nb, blk_id, Nil{}, blks, False{}, r, rl, vm, nvm, mg, bk}
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
# Intrinsics (U32.*, F32.*, IO.*) — O(1) via precomputed sym_intr U32Map
def low_intr_code(sintr: U32Map, sym: U32) -> U32:
  +raw = um_get(sintr, sym)
  Bool.pick(U32, U32.is_le(raw, 65), raw, 0)
def low_special_ctor_kind(skind: U32Map, sym: U32) -> U32:
  +k = um_get(skind, sym)
  Bool.pick(U32, U32.is_le(k, 9), k, 0)
def low_emit_const(st: CfgSt, v: U32) -> CfgSt:
  +st1 = cfg_alloc_reg(st)
  cfg_emit(st1, IConst{cfg_res(st1), v})
def low_emit_ctor(st: CfgSt, cid: U32, fs: List<&2, U32>) -> CfgSt:
  +st1 = cfg_alloc_reg(st)
  cfg_emit(st1, ICtor{cfg_res(st1), cid, fs})
def low_emit_bin_or_cmp(st: CfgSt, is_cmp: Bool, +op: U32, +va: U32, +vb: U32) -> CfgSt:
  +st1 = cfg_alloc_reg(st)
  +dst = cfg_res(st1)
  cfg_emit(st1, Bool.pick(IrOp, is_cmp, ICmp{dst, op, va, vb}, IBin{dst, op, va, vb}))
def low_emit_un(st: CfgSt, uop: U32, va: U32) -> CfgSt:
  +st1 = cfg_alloc_reg(st)
  cfg_emit(st1, IUn{cfg_res(st1), uop, va})
def low_emit_cond_bin(st: CfgSt, cond: U32, bop: U32, va: U32, vb: U32) -> CfgSt:
  +st1 = cfg_alloc_blk(st)
  +b_z = cfg_res(st1)
  +st2 = cfg_alloc_blk(st1)
  +b_ok = cfg_res(st2)
  +st3 = cfg_alloc_blk(st2)
  +b_m = cfg_res(st3)
  +st4 = cfg_alloc_reg(st3)
  +dst = cfg_res(st4)
  s0 = cfg_seal(st4, TBr{cond, b_z, b_ok})
  s1 = cfg_seal(cfg_emit(cfg_start(s0, b_z), IConst{dst, 0}), TJmp{b_m})
  +s2 = cfg_alloc_reg(cfg_start(s1, b_ok))
  s3 = cfg_seal(cfg_emit(cfg_emit(s2, IBin{cfg_res(s2), bop, va, vb}), ICopy{dst, cfg_res(s2)}), TJmp{b_m})
  cfg_set_res(cfg_start(s3, b_m), dst)
def low_emit_safe_shift(st: CfgSt, is_shr: Bool, +va: U32, +vb: U32) -> CfgSt:
  +st1 = low_emit_const(st, 32)
  +st2 = cfg_alloc_reg(st1)
  low_emit_cond_bin(cfg_emit(st2, ICmp{cfg_res(st2), B5K_CMP_GE(), vb, cfg_res(st1)}), cfg_res(st2), Bool.pick(U32, is_shr, B5K_OP_SHR(), B5K_OP_SHL()), va, vb)
def low_emit_io_eff(st: CfgSt, cid: U32, pre: List<&2, U32>, k: U32) -> CfgSt:
  +st1 = cfg_alloc_reg(st)
  low_emit_ctor(cfg_emit(st1, ICallClosure{cfg_res(st1), 2, [k]}), cid, b5k_list_app(U32, pre, [cfg_res(st1)]))
def low_emit_u32_intr2_rest(st: CfgSt, is_flt: Bool, +code: U32, va: U32, vb: U32) -> CfgSt:
  match is_flt:
    case True{}:
      +is_fcmp = U32.is_ge(code, 44)
      low_emit_bin_or_cmp(st, is_fcmp, Bool.pick(U32, is_fcmp, U32.sub(code, 38), U32.sub(code, 30)), va, vb)
    case False{}:
      +is_cmp = U32.is_gt(code, 10)
      low_emit_bin_or_cmp(st, is_cmp, Bool.pick(U32, is_cmp, U32.sub(code, 11), U32.sub(code, 1)), va, vb)
def low_emit_arr_one(st: CfgSt, aop: U32, args: List<&2, U32>) -> CfgSt:
  +st1 = cfg_alloc_reg(st)
  cfg_emit(st1, IArrOp{[cfg_res(st1)], aop, args})
def low_emit_arr_pair(st: CfgSt, aop: U32, args: List<&2, U32>) -> CfgSt:
  +st1 = cfg_alloc_reg(st)
  +r0 = cfg_res(st1)
  +st2 = cfg_alloc_reg(st1)
  +r1 = cfg_res(st2)
  +st3 = cfg_alloc_reg(cfg_emit(st2, IArrOp{[r0, r1], aop, args}))
  cfg_emit(st3, ICtor{cfg_res(st3), 6, [r0, r1]})
def low_emit_minmax(st: CfgSt, cop: U32, +va: U32, +vb: U32) -> CfgSt:
  +st1 = cfg_alloc_reg(st)
  +cond = cfg_res(st1)
  +st2 = cfg_alloc_blk(cfg_emit(st1, ICmp{cond, cop, va, vb}))
  +b_t = cfg_res(st2)
  +st3 = cfg_alloc_blk(st2)
  +b_f = cfg_res(st3)
  +st4 = cfg_alloc_blk(st3)
  +b_m = cfg_res(st4)
  +st5 = cfg_alloc_reg(st4)
  +dst = cfg_res(st5)
  s0 = cfg_seal(st5, TBr{cond, b_t, b_f})
  s1 = cfg_seal(cfg_emit(cfg_start(s0, b_t), ICopy{dst, va}), TJmp{b_m})
  s2 = cfg_seal(cfg_emit(cfg_start(s1, b_f), ICopy{dst, vb}), TJmp{b_m})
  cfg_set_res(cfg_start(s2, b_m), dst)
def low_emit_nat_sub(st: CfgSt, +va: U32, +vb: U32) -> CfgSt:
  +st1 = cfg_alloc_reg(st)
  low_emit_cond_bin(cfg_emit(st1, ICmp{cfg_res(st1), B5K_CMP_LT(), va, vb}), cfg_res(st1), B5K_OP_SUB(), va, vb)
def low_emit_arr_get_pair(st: CfgSt, +va: U32, vb: U32) -> CfgSt:
  +st1 = low_emit_arr_one(st, 78, [va, vb])
  low_emit_ctor(st1, 6, [va, cfg_res(st1)])
def low_emit_u32_intr2(st: CfgSt, +code: U32, +va: U32, +vb: U32) -> CfgSt:
  match code:
    case 17: low_emit_minmax(st, B5K_CMP_LT(), va, vb)
    case 18: low_emit_minmax(st, B5K_CMP_GT(), va, vb)
    case 24: low_emit_safe_shift(st, False{}, va, vb)
    case 25: low_emit_safe_shift(st, True{}, va, vb)
    case 28: low_emit_bin_or_cmp(st, False{}, B5K_OP_SHL(), va, vb)
    case 29: low_emit_bin_or_cmp(st, False{}, B5K_OP_SHR(), va, vb)
    case 30: low_emit_nat_sub(st, va, vb)
    case 31: low_emit_io_eff(st, 28, [va], vb)
    case 32: low_emit_io_eff(st, 29, [va], vb)
    case 37: low_emit_io_eff(st, 34, [va], vb)
    case 54: low_emit_io_eff(st, 37, [va], vb)
    case 60: low_emit_arr_one(st, 71, [va, vb])
    case 61: low_emit_arr_get_pair(st, va, vb)
    case _: low_emit_u32_intr2_rest(st, U32.is_ge(code, 40), code, va, vb)
def low_emit_u32_intr3(st: CfgSt, code: U32, va: U32, vb: U32, vc: U32) -> CfgSt:
  match code:
    case 35: low_emit_io_eff(st, 32, [va, vb], vc)
    case 36: low_emit_io_eff(st, 33, [va, vb], vc)
    case 38: low_emit_io_eff(st, 35, [va, vb], vc)
    case 39: low_emit_io_eff(st, 36, [va, vb], vc)
    case 62: low_emit_arr_one(st, 73, [va, vb, vc])
    case 63: low_emit_arr_pair(st, 74, [va, vb, vc])
    case 68: low_emit_arr_one(st, 79, [va, vb, vc])
    case _: low_emit_const(st, 0)
def low_emit_u32_intr1(st: CfgSt, +code: U32, +va: U32) -> CfgSt:
  match code:
    case 26: low_emit_un(st, 1, va)
    case 27: cfg_set_res(st, va)
    case 33: low_emit_io_eff(st, 30, Nil{}, va)
    case 34: low_emit_io_eff(st, 31, Nil{}, va)
    case 64: low_emit_arr_pair(st, 75, [va])
    case 65: low_emit_arr_pair(st, 76, [va])
    case 50: low_emit_un(st, 2, va)
    case 51: low_emit_un(st, 3, va)
    case 52: low_emit_un(st, 4, va)
    case 53: low_emit_un(st, 5, va)
    case _:
      +is_z = U32.is_eq(code, 21)
      +st1 = low_emit_const(st, Bool.pick(U32, is_z, 0, 1))
      op = Bool.pick(U32, U32.is_eq(code, 19), B5K_OP_ADD(), Bool.pick(U32, U32.is_eq(code, 20), B5K_OP_SUB(), Bool.pick(U32, U32.is_eq(code, 22), B5K_OP_SHL(), Bool.pick(U32, U32.is_eq(code, 23), B5K_OP_SHR(), B5K_CMP_EQ()))))
      low_emit_bin_or_cmp(st1, is_z, op, va, cfg_res(st1))
def low_emit_u32_intr(st: CfgSt, code: U32, vargs: List<&2, U32>) -> CfgSt:
  match vargs:
    case Con{va, Con{vb, Con{vc, Nil{}}}}: low_emit_u32_intr3(st, code, va, vb, vc)
    case Con{va, Con{vb, Nil{}}}: low_emit_u32_intr2(st, code, va, vb)
    case Con{va, Nil{}}: low_emit_u32_intr1(st, code, va)
    case _: low_emit_const(st, 0)
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
def low_mask_scs(n: Nat, +smask: U32, +idx: U32) -> List<&2, U32>:
  match n:
    case 0n: Nil{}
    case 1n+p:
      sc = Bool.to_u32(Bool.and(U32.is_lt(idx, 32), U32.is_ne(U32.and(U32.shrn(smask, U32.to_nat(idx)), 1), 0)))
      Con{sc, low_mask_scs(p, smask, U32.add(idx, 1))}
def low_zero_scs(n: Nat) -> List<&2, U32>:
  match n:
    case 0n: Nil{}
    case 1n+p: Con{0, low_zero_scs(p)}
type PatStep is Data:
  PSDone{st: CfgSt}
  PSNext{st: CfgSt, ps: List<&2, Pat>, regs: List<&2, U32>, scs: List<&2, U32>, trs: List<&2, U32>}
def low_test_bool(st: CfgSt, expect_true: Bool, +r: U32, +fail_blk: U32) -> CfgSt:
  +st1 = cfg_alloc_blk(st)
  +ok_blk = cfg_res(st1)
  term = Bool.pick(IrTerm, expect_true, TBr{r, ok_blk, fail_blk}, TBr{r, fail_blk, ok_blk})
  cfg_start(cfg_seal(st1, term), ok_blk)
def low_opt_test_bool(hf: Bool, expect_true: Bool, st: CfgSt, r: U32, fb: U32) -> CfgSt:
  match hf:
    case True{}: low_test_bool(st, expect_true, r, fb)
    case False{}: st
def low_opt_test_eq(hf: Bool, st: CfgSt, r: U32, val: U32, fb: U32) -> CfgSt:
  match hf:
    case True{}: low_test_cmp_const(st, B5K_CMP_EQ(), r, val, fb)
    case False{}: st
def low_test_ge_go(is1: Bool, st: CfgSt, r: U32, k: U32, fb: U32) -> CfgSt:
  match is1:
    case True{}: low_test_bool(st, True{}, r, fb)
    case False{}: low_test_cmp_const(st, B5K_CMP_GE(), r, k, fb)
def low_opt_test_ge(hf: Bool, st: CfgSt, r: U32, +k: U32, fb: U32) -> CfgSt:
  match hf:
    case False{}: st
    case True{}: low_test_ge_go(U32.is_eq(k, 1), st, r, k, fb)
def low_test_tag_tr(has_tr: Bool, st: CfgSt, r: U32, tr: U32, cid: U32, fb: U32) -> CfgSt:
  match has_tr:
    case True{}: low_test_cmp_const(st, B5K_CMP_EQ(), U32.sub(tr, 1), cid, fb)
    case False{}: low_test_tag(st, r, cid, fb)
def low_opt_test_tag(hf: Bool, st: CfgSt, r: U32, +tr: U32, cid: U32, fb: U32) -> CfgSt:
  match hf:
    case True{}: low_test_tag_tr(U32.is_ne(tr, 0), st, r, tr, cid, fb)
    case False{}: st
def low_opt_sink(skip: Bool, st: CfgSt, r: U32) -> CfgSt:
  match skip:
    case True{}: st
    case False{}: cfg_emit(st, ISink{r})
def low_opt_rc(skip: Bool, st: CfgSt, r: U32, uses: U32) -> CfgSt:
  match skip:
    case True{}: st
    case False{}: cfg_apply_rc(st, r, uses)
type NatPat is Data:
  NPConst{k: U32}
  NPSub{k: U32, inner: Pat}
type NatPeelTask is Data:
  NPTPat{p: Pat}
  NPTCtr{kind: U32, sym: U32, fs: List<&2, Pat>}
def low_peel_nat_go(fuel: Nat, +skind: U32Map, +k: U32, task: NatPeelTask) -> NatPat:
  match fuel task:
    case 0n NPTPat{other}: NPSub{k, other}
    case 0n NPTCtr{_, sym, fs}: NPSub{k, PCtr{sym, fs}}
    case 1n+f NPTPat{PCtr{+sym, fs}}: low_peel_nat_go(f, skind, k, NPTCtr{low_special_ctor_kind(skind, sym), sym, fs})
    case 1n+_ NPTPat{PNum{v}}: NPConst{U32.add(k, v)}
    case 1n+_ NPTPat{other}: NPSub{k, other}
    case 1n+_ NPTCtr{3, _, Nil{}}: NPConst{k}
    case 1n+f NPTCtr{4, _, Con{inner, Nil{}}}: low_peel_nat_go(f, skind, U32.add(k, 1), NPTPat{inner})
    case 1n+_ NPTCtr{_, sym, fs}: NPSub{k, PCtr{sym, fs}}
def low_peel_nat(fuel: Nat, +skind: U32Map, +k: U32, p: Pat) -> NatPat:
  low_peel_nat_go(fuel, skind, k, NPTPat{p})
def low_pat_is_dead_var(p: Pat, body: Expr) -> Bool:
  match p:
    case PWild{}: True{}
    case PVar{s, _}: U32.is_zero(count_uses_go(U32.to_nat(2048), s, UIExpr{body}))
    case _: False{}
def low_pat_nat_succ_fin(is_dead: Bool, st1: CfgSt, +k: U32, rem: Pat, pt: List<&2, Pat>, r: U32, rt: List<&2, U32>, st_tail: List<&2, U32>, tr_tail: List<&2, U32>) -> PatStep:
  match is_dead:
    case True{}: PSNext{st1, pt, rt, st_tail, tr_tail}
    case False{}:
      +st2 = cfg_alloc_reg(st1)
      +ck = cfg_res(st2)
      +st3 = cfg_alloc_reg(cfg_emit(st2, IConst{ck, k}))
      +pr = cfg_res(st3)
      PSNext{cfg_emit(st3, IBin{pr, B5K_OP_SUB(), r, ck}), Con{rem, pt}, Con{pr, rt}, Con{1, st_tail}, Con{0, tr_tail}}
def low_pat_nat_succ(np: NatPat, st: CfgSt, pt: List<&2, Pat>, +r: U32, rt: List<&2, U32>, st_tail: List<&2, U32>, tr_tail: List<&2, U32>, body: Expr, fail_blk: U32, has_fail: Bool) -> PatStep:
  match np:
    case NPConst{k}: PSNext{low_opt_test_eq(has_fail, st, r, k, fail_blk), pt, rt, st_tail, tr_tail}
    case NPSub{+k, +rem}:
      st1 = low_opt_test_ge(has_fail, st, r, k, fail_blk)
      low_pat_nat_succ_fin(low_pat_is_dead_var(rem, body), st1, k, rem, pt, r, rt, st_tail, tr_tail)
def low_pat_ctr_box(st: CfgSt, cid: U32, smask: U32, is_single: Bool, +fs: List<&2, Pat>, +pt: List<&2, Pat>, +r: U32, rt: List<&2, U32>, st_tail: List<&2, U32>, tr0: U32, tr_tail: List<&2, U32>, fail_blk: U32, +has_fail: Bool, nf_zero: Bool, +nf: U32) -> PatStep:
  match nf_zero:
    case True{}: PSNext{low_opt_test_tag(Bool.and(has_fail, Bool.not(is_single)), st, r, tr0, cid, fail_blk), pt, rt, st_tail, tr_tail}
    case False{}:
      st1 = low_opt_test_tag(Bool.and(has_fail, Bool.not(is_single)), st, r, tr0, cid, fail_blk)
      +stK = low_maybe_keep(st1, Bool.and(has_fail, Bool.or(pat_is_refut(16n, fs), pat_is_refut(16n, pt))), r)
      +st2 = low_alloc_regs_go(U32.to_nat(nf), stK, Nil{})
      +fregs = cfg_rlist(st2)
      fscs = low_mask_scs(U32.to_nat(nf), smask, 0)
      ftrs = low_zero_scs(U32.to_nat(nf))
      PSNext{cfg_emit(st2, ITake{fregs, cfg_res(stK)}), b5k_list_app(Pat, fs, pt), b5k_list_app(U32, fregs, rt), b5k_list_app(U32, fscs, st_tail), b5k_list_app(U32, ftrs, tr_tail)}
def low_pat_ctr_step(kind: U32, +env: LowEnv, st: CfgSt, +sym: U32, +fs: List<&2, Pat>, pt: List<&2, Pat>, +r: U32, rt: List<&2, U32>, +sc0: U32, st_tail: List<&2, U32>, tr0: U32, tr_tail: List<&2, U32>, body: Expr, fail_blk: U32, +has_fail: Bool) -> PatStep:
  match kind:
    case 1: PSNext{low_opt_test_bool(has_fail, False{}, st, r, fail_blk), pt, rt, st_tail, tr_tail}
    case 2: PSNext{low_opt_test_bool(has_fail, True{}, st, r, fail_blk), pt, rt, st_tail, tr_tail}
    case 3: PSNext{low_opt_test_bool(has_fail, False{}, st, r, fail_blk), pt, rt, st_tail, tr_tail}
    case 4:
      match fs:
        case Con{inner, Nil{}}: low_pat_nat_succ(low_peel_nat(32n, env_kind(env), 1, inner), st, pt, r, rt, st_tail, tr_tail, body, fail_blk, has_fail)
        case _:
          st1 = low_opt_test_bool(has_fail, True{}, st, r, fail_blk)
          +st2 = cfg_alloc_reg(st1)
          +c1 = cfg_res(st2)
          +st3 = cfg_alloc_reg(cfg_emit(st2, IConst{c1, 1}))
          +pr = cfg_res(st3)
          PSNext{cfg_emit(st3, IBin{pr, B5K_OP_SUB(), r, c1}), b5k_list_app(Pat, fs, pt), Con{pr, rt}, Con{1, st_tail}, Con{0, tr_tail}}
    case 5: PSNext{st, b5k_list_app(Pat, fs, pt), Con{r, rt}, Con{1, st_tail}, Con{0, tr_tail}}
    case _:
      +cv = um_get(env_ctors(env), sym)
      +cid = Bool.pick(U32, U32.is_zero(cv), 0, U32.sub(cv, 1))
      +nf = b5k_list_len(Pat, fs)
      sm = Bool.pick(U32, U32.is_eq(cid, 6), U32.shrn(sc0, 1n), um_get(env_csmask(env), sym))
      is_s = U32.is_ne(um_get(env_csingle(env), sym), 0)
      low_pat_ctr_box(st, cid, sm, is_s, fs, pt, r, rt, st_tail, tr0, tr_tail, fail_blk, has_fail, U32.is_zero(nf), nf)
def low_pat_one(+env: LowEnv, st: CfgSt, p0: Pat, pt: List<&2, Pat>, +r: U32, rt: List<&2, U32>, +sc0: U32, st_tail: List<&2, U32>, tr0: U32, tr_tail: List<&2, U32>, body: Expr, fail_blk: U32, +has_fail: Bool) -> PatStep:
  match p0:
    case PWild{}: PSNext{low_opt_sink(Bool.or(has_fail, U32.is_eq(sc0, 1)), st, r), pt, rt, st_tail, tr_tail}
    case PVar{+sym, _}:
      +uses = count_uses_go(U32.to_nat(2048), sym, UIExpr{body})
      +st1 = low_opt_rc(Bool.or(U32.is_eq(sc0, 1), Bool.and(has_fail, U32.is_zero(uses))), st, r, uses)
      PSNext{cfg_set_vm_nvm(st1, um_set(cfg_vmap(st1), sym, U32.add(r, 1)), um_set(cfg_nvm(st1), sym, sc0)), pt, rt, st_tail, tr_tail}
    case PNum{v}: PSNext{low_opt_test_eq(has_fail, st, r, v, fail_blk), pt, rt, st_tail, tr_tail}
    case PChr{c}: PSNext{low_opt_test_eq(has_fail, st, r, c, fail_blk), pt, rt, st_tail, tr_tail}
    case PPair{+a, +b}:
      +st0 = low_maybe_keep(st, Bool.and(has_fail, pat_is_refut(16n, [a, b])), r)
      +st1 = cfg_alloc_reg(st0)
      +ra = cfg_res(st1)
      +st2 = cfg_alloc_reg(st1)
      +rb = cfg_res(st2)
      sa = Bool.to_u32(U32.is_ne(U32.and(sc0, 2), 0))
      sb = Bool.to_u32(U32.is_ne(U32.and(sc0, 4), 0))
      PSNext{cfg_emit(st2, ITake{[ra, rb], cfg_res(st0)}), Con{a, Con{b, pt}}, Con{ra, Con{rb, rt}}, Con{sa, Con{sb, st_tail}}, Con{0, Con{0, tr_tail}}}
    case PList{Nil{}}: PSNext{low_opt_test_tag(has_fail, st, r, tr0, 4, fail_blk), pt, rt, st_tail, tr_tail}
    case PList{Con{h, tl}}:
      st0 = low_opt_test_tag(has_fail, st, r, tr0, 5, fail_blk)
      +stK = low_maybe_keep(st0, has_fail, r)
      +st1 = cfg_alloc_reg(stK)
      +rh = cfg_res(st1)
      +st2 = cfg_alloc_reg(st1)
      +rt2 = cfg_res(st2)
      PSNext{cfg_emit(st2, ITake{[rh, rt2], cfg_res(stK)}), Con{h, Con{PList{tl}, pt}}, Con{rh, Con{rt2, rt}}, Con{0, Con{0, st_tail}}, Con{0, Con{0, tr_tail}}}
    case PCtr{+sym, +fs}:
      low_pat_ctr_step(low_special_ctor_kind(env_kind(env), sym), env, st, sym, fs, pt, r, rt, sc0, st_tail, tr0, tr_tail, body, fail_blk, has_fail)
def low_match_pats_go(fuel: Nat, +env: LowEnv, step: PatStep, +body: Expr, +fail_blk: U32, +has_fail: Bool) -> CfgSt:
  match fuel step:
    case 0n PSDone{st}: st
    case 0n PSNext{st, _, _, _, _}: st
    case _ PSDone{st}: st
    case 1n+p PSNext{st, Nil{}, _, _, _}: st
    case 1n+p PSNext{st, _, Nil{}, _, _}: st
    case 1n+p PSNext{st, _, _, Nil{}, _}: st
    case 1n+p PSNext{st, _, _, _, Nil{}}: st
    case 1n+p PSNext{st, Con{p0, pt}, Con{r, rt}, Con{sc0, st_tail}, Con{tr0, tr_tail}}:
      low_match_pats_go(p, env, low_pat_one(env, st, p0, pt, r, rt, sc0, st_tail, tr0, tr_tail, body, fail_blk, has_fail), body, fail_blk, has_fail)
def low_match_pats_sct(fuel: Nat, env: LowEnv, st: CfgSt, ps: List<&2, Pat>, regs: List<&2, U32>, scs: List<&2, U32>, trs: List<&2, U32>, body: Expr, fail_blk: U32, has_fail: Bool) -> CfgSt:
  low_match_pats_go(fuel, env, PSNext{st, ps, regs, scs, trs}, body, fail_blk, has_fail)
def low_match_pats_sc(fuel: Nat, env: LowEnv, st: CfgSt, ps: List<&2, Pat>, +regs: List<&2, U32>, scs: List<&2, U32>, body: Expr, fail_blk: U32, has_fail: Bool) -> CfgSt:
  low_match_pats_go(fuel, env, PSNext{st, ps, regs, scs, low_zero_scs(U32.to_nat(b5k_u32_list_len(regs)))}, body, fail_blk, has_fail)
def low_apply_chain(vargs: List<&2, U32>, st: CfgSt, vfn: U32) -> CfgSt:
  match vargs:
    case Nil{}: cfg_set_res(st, vfn)
    case Con{va, t}:
      +st1 = cfg_alloc_reg(st)
      +dst = cfg_res(st1)
      low_apply_chain(t, cfg_emit(st1, ICallDirect{dst, 0, [vfn, va]}), dst)
def low_list_chain(vargs: List<&2, U32>, st: CfgSt) -> CfgSt:
  match vargs:
    case Nil{}: low_emit_ctor(st, 4, Nil{})
    case Con{h, t}:
      +st1 = low_list_chain(t, st)
      low_emit_ctor(st1, 5, [h, cfg_res(st1)])
def low_str_chain(s: String, st: CfgSt) -> CfgSt:
  match s:
    case SNil{}: low_emit_ctor(st, 0, Nil{})
    case SCon{c, t}:
      +st1 = low_str_chain(t, st)
      +st2 = low_emit_const(st1, Char.to_u32(c))
      low_emit_ctor(st2, 1, [cfg_res(st2), cfg_res(st1)])
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
def low_is_num_intr(sintr: U32Map, sym: U32) -> Bool:
  +ic = um_get(sintr, sym)
  Bool.or(Bool.and(U32.is_ge(ic, 1), U32.is_le(ic, 30)), Bool.or(Bool.and(U32.is_ge(ic, 40), U32.is_le(ic, 53)), U32.is_eq(ic, 67)))
def low_is_num_expr(fuel: Nat, +env: LowEnv, +vm: U32Map, +nvm: U32Map, e: Expr) -> Bool:
  match fuel e:
    case 0n _: False{}
    case 1n+_ ENum{_}: True{}
    case 1n+_ EFlt{_}: True{}
    case 1n+_ EChr{_}: True{}
    case 1n+_ EVar{s}: U32.is_eq(um_get(nvm, s), 1)
    case 1n+_ EUnOp{_, _}: True{}
    case 1n+p EOp{+op, a, b}:
      +p0 = p
      Bool.or(U32.is_ne(op, 0), Bool.or(low_is_num_expr(p0, env, vm, nvm, a), low_is_num_expr(p0, env, vm, nvm, b)))
    case 1n+p EAnn{v, typ}: Bool.or(low_is_scalar_type(env_kind(env), typ), low_is_num_expr(p, env, vm, nvm, v))
    case 1n+_ ECtr{sym, _}:
      +k = low_special_ctor_kind(env_kind(env), sym)
      Bool.and(U32.is_ge(k, 1), U32.is_le(k, 5))
    case 1n+_ EApp{EVar{+s}, _}: Bool.and(U32.is_zero(um_get(vm, s)), low_is_num_intr(env_intr(env), s))
    case 1n+_ EApp{ERef{+s}, _}: Bool.and(U32.is_zero(um_get(vm, s)), low_is_num_intr(env_intr(env), s))
    case 1n+p EIf{_, t, f}:
      +p0 = p
      Bool.and(low_is_num_expr(p0, env, vm, nvm, t), low_is_num_expr(p0, env, vm, nvm, f))
    case 1n+_ _: False{}
def low_emit_op_go(is_add: Bool, is_zero: Bool, env: LowEnv, st: CfgSt, +op: U32, va: U32, vb: U32) -> CfgSt:
  match is_add is_zero:
    case True{} _: low_emit_bin_or_cmp(st, False{}, B5K_OP_ADD(), va, vb)
    case False{} True{}: low_emit_add_or_cat(env, st, va, vb)
    case False{} False{}:
      +is_cmp = Bool.and(U32.is_ge(op, 20), U32.is_le(op, 25))
      low_emit_bin_or_cmp(st, is_cmp, Bool.pick(U32, is_cmp, U32.sub(op, 20), op), va, vb)
def low_lookup_fvs(fvs: List<&2, U32>, +vm: U32Map) -> List<&2, U32>:
  match fvs:
    case Nil{}: Nil{}
    case Con{s, t}:
      +v = um_get(vm, s)
      Con{Bool.pick(U32, U32.is_zero(v), 0, U32.sub(v, 1)), low_lookup_fvs(t, vm)}
def low_expr_sc_code(+env: LowEnv, +vm: U32Map, +nvm: U32Map, e: Expr) -> U32:
  match e:
    case EVar{s}: um_get(nvm, s)
    case other: Bool.to_u32(low_is_num_expr(16n, env, vm, nvm, other))
def low_exprs_sc_codes(+env: LowEnv, +vm: U32Map, +nvm: U32Map, es: List<&2, Expr>) -> List<&2, U32>:
  match es:
    case Nil{}: Nil{}
    case Con{h, t}: Con{low_expr_sc_code(env, vm, nvm, h), low_exprs_sc_codes(env, vm, nvm, t)}
def low_bind_lam_caps(+outer_nvm: U32Map, fvs: List<&2, U32>, st: CfgSt, +idx: U32, +body: Expr) -> CfgSt:
  match fvs:
    case Nil{}: st
    case Con{+s, t}:
      +sc = um_get(outer_nvm, s)
      +st1 = low_opt_rc(U32.is_eq(sc, 1), st, idx, count_uses_go(U32.to_nat(2048), s, UIExpr{body}))
      low_bind_lam_caps(outer_nvm, t, cfg_set_vm_nvm(st1, um_set(cfg_vmap(st1), s, U32.add(idx, 1)), um_set(cfg_nvm(st1), s, sc)), U32.add(idx, 1), body)
def low_bind_params(+skind: U32Map, ps: List<&2, Param>, st: CfgSt, +idx: U32, +body: Expr) -> CfgSt:
  match ps:
    case Nil{}: st
    case Con{Param{+sym, typ, erased, _}, t}:
      match erased:
        case True{}: low_bind_params(skind, t, st, idx, body)
        case False{}:
          +sc = low_maybe_sc_code(skind, typ)
          +st1 = low_opt_rc(U32.is_eq(sc, 1), st, idx, count_uses_go(U32.to_nat(2048), sym, UIExpr{body}))
          low_bind_params(skind, t, cfg_set_vm_nvm(st1, um_set(cfg_vmap(st1), sym, U32.add(idx, 1)), um_set(cfg_nvm(st1), sym, sc)), U32.add(idx, 1), body)
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
def low_emit_ctor_kind(kind: U32, +env: LowEnv, st: CfgSt, sym: U32, vfs: List<&2, U32>) -> CfgSt:
  match kind:
    case 1: low_emit_const(st, 0)
    case 2: low_emit_const(st, 1)
    case 3: low_emit_const(st, 0)
    case 4:
      match vfs:
        case Con{vx, _}:
          +st1 = low_emit_const(st, 1)
          low_emit_bin_or_cmp(st1, False{}, B5K_OP_ADD(), vx, cfg_res(st1))
        case Nil{}: low_emit_const(st, 1)
    case 5:
      match vfs:
        case Con{vx, _}: cfg_set_res(st, vx)
        case Nil{}: low_emit_const(st, 0)
    case 8: low_emit_arr_one(st, 8, vfs)
    case 9: low_emit_arr_one(st, 9, vfs)
    case 13: low_emit_ctor(st, 6, vfs)
    case _:
      +cv = um_get(env_ctors(env), sym)
      low_emit_ctor(st, Bool.pick(U32, U32.is_zero(cv), 0, U32.sub(cv, 1)), vfs)
def low_emit_ctor_expr(+env: LowEnv, st: CfgSt, +sym: U32, vfs: List<&2, U32>) -> CfgSt:
  low_emit_ctor_kind(um_get(env_kind(env), sym), env, st, sym, vfs)
# Single Self-Recursive Expression -> Flat CFG Lowerer
type UnboxArr is Data:
  UArrNone{e: Expr}
  UArrGet{a: Expr, i: Expr, sc: U32}
  UArrOp2{aop: U32, args: List<&2, Expr>, sc1: U32}
  UArrPair{a: Expr, b: Expr}
def low_unbox_app(+skind: U32Map, is_free: Bool, icode: U32, orig: Expr, args: List<&2, Expr>) -> UnboxArr:
  match is_free icode args:
    case True{} 61 Con{ty, Con{a, Con{i, Nil{}}}}: UArrGet{a, i, Bool.to_u32(low_is_scalar_type(skind, ty))}
    case True{} 63 Con{_, Con{a, Con{i, Con{v, Nil{}}}}}: UArrOp2{74, [a, i, v], 0}
    case True{} 64 Con{_, Con{a, Nil{}}}: UArrOp2{75, [a], 1}
    case True{} 65 Con{_, Con{a, Nil{}}}: UArrOp2{76, [a], 0}
    case _ _ _: UArrNone{orig}
def low_unbox_pair(+env: LowEnv, +vm: U32Map, val: Expr) -> UnboxArr:
  match val:
    case EArrGet{a, i}: UArrGet{a, i, 0}
    case EPair{a, b}: UArrPair{a, b}
    case EApp{EVar{+sym}, +args}:
      low_unbox_app(env_kind(env), U32.is_zero(um_get(vm, sym)), low_intr_code(env_intr(env), sym), EApp{EVar{sym}, args}, args)
    case EApp{ERef{+sym}, +args}:
      low_unbox_app(env_kind(env), U32.is_zero(um_get(vm, sym)), low_intr_code(env_intr(env), sym), EApp{ERef{sym}, args}, args)
    case other: UArrNone{other}
# Direct U32.cmp/Nat.cmp, Branchless Bool Match & Common Single-Ctor Hoisting
def low_cmp_pat_code(+skind: U32Map, p: Pat) -> U32:
  match p:
    case PWild{}: 4
    case PCtr{sym, Nil{}}:
      +k = um_get(skind, sym)
      Bool.pick(U32, Bool.and(U32.is_ge(k, 10), U32.is_le(k, 12)), U32.sub(k, 9), 0)
    case _: 0
def low_all_cmp_cases_go(+skind: U32Map, cs: List<&2, Case>) -> Bool:
  match cs:
    case Nil{}: True{}
    case Con{Case{Con{p, Nil{}}, _}, t}: Bool.and(U32.is_ne(low_cmp_pat_code(skind, p), 0), low_all_cmp_cases_go(skind, t))
    case _: False{}
def low_all_cmp_cases(+skind: U32Map, cs: List<&2, Case>) -> Bool:
  match cs:
    case Nil{}: False{}
    case other: low_all_cmp_cases_go(skind, other)
type CmpMatchInfo is Data:
  CMNone{}
  CMHit{a: Expr, b: Expr}
def low_cmp_match_check(+sintr: U32Map, +vm: U32Map, +sym: U32, args: List<&2, Expr>) -> CmpMatchInfo:
  match args:
    case Con{a, Con{b, Nil{}}}:
      Bool.pick(CmpMatchInfo, Bool.and(U32.is_zero(um_get(vm, sym)), U32.is_eq(um_get(sintr, sym), 66)), CMHit{a, b}, CMNone{})
    case _: CMNone{}
def low_cmp_match_info_go(ok: Bool, +sintr: U32Map, +vm: U32Map, scrut: Expr) -> CmpMatchInfo:
  match ok scrut:
    case False{} _: CMNone{}
    case True{} EApp{EVar{sym}, args}: low_cmp_match_check(sintr, vm, sym, args)
    case True{} EApp{ERef{sym}, args}: low_cmp_match_check(sintr, vm, sym, args)
    case True{} _: CMNone{}
def low_cmp_match_info(+env: LowEnv, +vm: U32Map, scrut: Expr, cs: List<&2, Case>) -> CmpMatchInfo:
  low_cmp_match_info_go(low_all_cmp_cases(env_kind(env), cs), env_intr(env), vm, scrut)
def low_bool_pat_code(+skind: U32Map, p: Pat) -> U32:
  match p:
    case PWild{}: 3
    case PCtr{sym, Nil{}}:
      +k = low_special_ctor_kind(skind, sym)
      Bool.pick(U32, Bool.or(U32.is_eq(k, 1), U32.is_eq(k, 2)), k, 0)
    case _: 0
def low_const01_code(+skind: U32Map, e: Expr) -> U32:
  match e:
    case ENum{0}: 1
    case ENum{1}: 2
    case ECtr{sym, Nil{}}:
      +k = low_special_ctor_kind(skind, sym)
      Bool.pick(U32, Bool.or(U32.is_eq(k, 1), U32.is_eq(k, 2)), k, 0)
    case _: 0
def low_bool_match_kind(+skind: U32Map, cs: List<&2, Case>) -> U32:
  match cs:
    case Con{Case{Con{p1, Nil{}}, e1}, Con{Case{Con{p2, Nil{}}, e2}, Nil{}}}:
      +k1 = low_bool_pat_code(skind, p1)
      +k2 = low_bool_pat_code(skind, p2)
      +v1 = low_const01_code(skind, e1)
      +v2 = low_const01_code(skind, e2)
      is_id = Bool.or(Bool.and(U32.is_eq(k1, 1), Bool.and(U32.is_eq(v1, 1), Bool.and(Bool.or(U32.is_eq(k2, 2), U32.is_eq(k2, 3)), U32.is_eq(v2, 2)))),
                      Bool.and(U32.is_eq(k1, 2), Bool.and(U32.is_eq(v1, 2), Bool.and(Bool.or(U32.is_eq(k2, 1), U32.is_eq(k2, 3)), U32.is_eq(v2, 1)))))
      is_not = Bool.or(Bool.and(U32.is_eq(k1, 1), Bool.and(U32.is_eq(v1, 2), Bool.and(Bool.or(U32.is_eq(k2, 2), U32.is_eq(k2, 3)), U32.is_eq(v2, 1)))),
                       Bool.and(U32.is_eq(k1, 2), Bool.and(U32.is_eq(v1, 1), Bool.and(Bool.or(U32.is_eq(k2, 1), U32.is_eq(k2, 3)), U32.is_eq(v2, 2)))))
      Bool.pick(U32, is_id, 1, Bool.pick(U32, is_not, 2, 0))
    case _: 0
def low_nth_pat(idx: Nat, ps: List<&2, Pat>) -> Maybe<&2, Pat>:
  match idx ps:
    case _ Nil{}: None{}
    case 0n Con{h, _}: Some{h}
    case 1n+p Con{_, t}: low_nth_pat(p, t)
type HoistCol is Data:
  HCNone{}
  HCPair{}
  HCCtr{sym: U32, nf: U32}
def low_hoist_match_one(spec: HoistCol, mp: Maybe<&2, Pat>) -> Bool:
  match spec mp:
    case HCPair{} Some{PPair{_, _}}: True{}
    case HCCtr{sym, nf} Some{PCtr{s2, fs}}: Bool.and(U32.is_eq(sym, s2), U32.is_eq(nf, b5k_list_len(Pat, fs)))
    case _ _: False{}
def low_splice_pat(col: Nat, ps: List<&2, Pat>) -> List<&2, Pat>:
  match col ps:
    case _ Nil{}: Nil{}
    case 1n+p Con{h, t}: Con{h, low_splice_pat(p, t)}
    case 0n Con{PPair{a, b}, t}: Con{a, Con{b, t}}
    case 0n Con{PCtr{_, fs}, t}: b5k_list_app(Pat, fs, t)
    case 0n Con{other, t}: Con{other, t}
def low_splice_cases(+col: U32, cs: List<&2, Case>) -> List<&2, Case>:
  match cs:
    case Nil{}: Nil{}
    case Con{Case{ps, body}, t}: Con{Case{low_splice_pat(U32.to_nat(col), ps), body}, low_splice_cases(col, t)}
def low_nth_u32(idx: Nat, xs: List<&2, U32>) -> U32:
  match idx xs:
    case _ Nil{}: 0
    case 0n Con{h, _}: h
    case 1n+p Con{_, t}: low_nth_u32(p, t)
def low_splice_u32(col: Nat, xs: List<&2, U32>, rep: List<&2, U32>) -> List<&2, U32>:
  match col xs:
    case _ Nil{}: Nil{}
    case 0n Con{_, t}: b5k_list_app(U32, rep, t)
    case 1n+p Con{h, t}: Con{h, low_splice_u32(p, t, rep)}
def low_grp_pat_m(+env: LowEnv, mp: Maybe<&2, Pat>) -> HoistCol:
  match mp:
    case Some{PPair{_, _}}: HCPair{}
    case Some{PCtr{+sym, +fs}}:
      +k = low_special_ctor_kind(env_kind(env), sym)
      +nf = b5k_list_len(Pat, fs)
      Bool.pick(HoistCol, Bool.and(Bool.or(U32.is_zero(k), U32.is_gt(k, 5)), U32.is_gt(nf, 0)), HCCtr{sym, nf}, HCNone{})
    case _: HCNone{}
type GrpSplit is Data:
  GrpSplit{grp: List<&2, Case>, tail: List<&2, Case>}
type GrpSplitTask is Data:
  GSNext{cs: List<&2, Case>, acc: List<&2, Case>}
  GSStep{hit: Bool, c: Case, t: List<&2, Case>, acc: List<&2, Case>}
def low_grp_split_go(fuel: Nat, +spec: HoistCol, +col: U32, task: GrpSplitTask) -> GrpSplit:
  match fuel task:
    case 0n GSNext{cs, acc}: GrpSplit{b5k_list_rev(Case, acc), cs}
    case 0n GSStep{_, c, t, acc}: GrpSplit{b5k_list_rev(Case, acc), Con{c, t}}
    case 1n+_ GSNext{Nil{}, acc}: GrpSplit{b5k_list_rev(Case, acc), Nil{}}
    case 1n+p GSNext{Con{Case{+ps, body}, t}, acc}:
      low_grp_split_go(p, spec, col, GSStep{low_hoist_match_one(spec, low_nth_pat(U32.to_nat(col), ps)), Case{ps, body}, t, acc})
    case 1n+p GSStep{True{}, c, t, acc}: low_grp_split_go(p, spec, col, GSNext{t, Con{c, acc}})
    case 1n+_ GSStep{False{}, c, t, acc}: GrpSplit{b5k_list_rev(Case, acc), Con{c, t}}
def low_pat_disjoint(+sym: U32, +cid: U32, mp: Maybe<&2, Pat>) -> Bool:
  match mp:
    case Some{PCtr{s2, _}}: U32.is_ne(sym, s2)
    case Some{PList{Nil{}}}: U32.is_ne(cid, 4)
    case Some{PList{Con{_, _}}}: U32.is_ne(cid, 5)
    case _: False{}
def low_tail_disjoint(+sym: U32, +cid: U32, +col: U32, cs: List<&2, Case>) -> Bool:
  match cs:
    case Nil{}: True{}
    case Con{Case{ps, _}, t}: Bool.and(low_pat_disjoint(sym, cid, low_nth_pat(U32.to_nat(col), ps)), low_tail_disjoint(sym, cid, col, t))
def low_grp_last_irref(+col: U32, grp: List<&2, Case>) -> Bool:
  match grp:
    case Nil{}: False{}
    case Con{Case{ps, _}, Nil{}}: Bool.not(pat_is_refut(16n, low_splice_pat(U32.to_nat(col), ps)))
    case Con{_, t}: low_grp_last_irref(col, t)
type GrpPick is Data:
  GPNone{}
  GPHit{col: U32, spec: HoistCol, grp: List<&2, Case>, tail: List<&2, Case>}
def low_grp_try_split(+env: LowEnv, +col: U32, spec: HoistCol, gs: GrpSplit) -> GrpPick:
  match spec gs:
    case sp GrpSplit{Con{c0, Con{c1, gt}}, Nil{}}: GPHit{col, sp, Con{c0, Con{c1, gt}}, Nil{}}
    case HCCtr{+sym, +nf} GrpSplit{Con{+c0, Con{+c1, +gt}}, Con{+th, +tt}}:
      +is_s = U32.is_ne(um_get(env_csingle(env), sym), 0)
      +cv = um_get(env_ctors(env), sym)
      ok = Bool.or(Bool.and(Bool.not(is_s), low_tail_disjoint(sym, Bool.pick(U32, U32.is_zero(cv), 0, U32.sub(cv, 1)), col, Con{th, tt})), low_grp_last_irref(col, Con{c0, Con{c1, gt}}))
      Bool.pick(GrpPick, ok, GPHit{col, HCCtr{sym, nf}, Con{c0, Con{c1, gt}}, Bool.pick(List<&2, Case>, is_s, Nil{}, Con{th, tt})}, GPNone{})
    case HCPair{} GrpSplit{Con{+c0, Con{+c1, +gt}}, Con{_, _}}:
      Bool.pick(GrpPick, low_grp_last_irref(col, Con{c0, Con{c1, gt}}), GPHit{col, HCPair{}, Con{c0, Con{c1, gt}}, Nil{}}, GPNone{})
    case _ _: GPNone{}
type GrpFindTask is Data:
  GFCol{vs: List<&2, U32>, col: U32}
  GFSpec{spec: HoistCol, vt: List<&2, U32>, col: U32}
  GFPick{pick: GrpPick, vt: List<&2, U32>, col: U32}
def low_grp_find_go(fuel: Nat, +env: LowEnv, +ps0: List<&2, Pat>, +cs: List<&2, Case>, task: GrpFindTask) -> GrpPick:
  match fuel task:
    case 0n _: GPNone{}
    case 1n+_ GFCol{Nil{}, _}: GPNone{}
    case 1n+p GFCol{Con{_, vt}, +col}:
      low_grp_find_go(p, env, ps0, cs, GFSpec{low_grp_pat_m(env, low_nth_pat(U32.to_nat(col), ps0)), vt, col})
    case 1n+p GFSpec{HCNone{}, vt, col}: low_grp_find_go(p, env, ps0, cs, GFCol{vt, U32.add(col, 1)})
    case 1n+p GFSpec{+spec, vt, +col}:
      low_grp_find_go(p, env, ps0, cs, GFPick{low_grp_try_split(env, col, spec, low_grp_split_go(256n, spec, col, GSNext{cs, Nil{}})), vt, col})
    case 1n+p GFPick{GPNone{}, vt, col}: low_grp_find_go(p, env, ps0, cs, GFCol{vt, U32.add(col, 1)})
    case 1n+_ GFPick{hit, _, _}: hit
type GrpTakeRes is Data:
  GrpTakeRes{st: CfgSt, vs: List<&2, U32>, scs: List<&2, U32>, trs: List<&2, U32>}
def low_grp_emit_take(+env: LowEnv, st: CfgSt, spec: HoistCol, +col: U32, +vs: List<&2, U32>, +scs: List<&2, U32>, +trs: List<&2, U32>) -> GrpTakeRes:
  match spec:
    case HCPair{}:
      +sc = low_nth_u32(U32.to_nat(col), scs)
      +st1 = cfg_alloc_reg(st)
      +ra = cfg_res(st1)
      +st2 = cfg_alloc_reg(st1)
      +rb = cfg_res(st2)
      GrpTakeRes{cfg_emit(st2, ITake{[ra, rb], low_nth_u32(U32.to_nat(col), vs)}), low_splice_u32(U32.to_nat(col), vs, [ra, rb]), low_splice_u32(U32.to_nat(col), scs, [Bool.to_u32(U32.is_ne(U32.and(sc, 2), 0)), Bool.to_u32(U32.is_ne(U32.and(sc, 4), 0))]), low_splice_u32(U32.to_nat(col), trs, [0, 0])}
    case HCCtr{+sym, +nf}:
      +cv = um_get(env_ctors(env), sym)
      sm = Bool.pick(U32, U32.is_eq(Bool.pick(U32, U32.is_zero(cv), 0, U32.sub(cv, 1)), 6), U32.shrn(low_nth_u32(U32.to_nat(col), scs), 1n), um_get(env_csmask(env), sym))
      +st2 = low_alloc_regs_go(U32.to_nat(nf), st, Nil{})
      +fregs = cfg_rlist(st2)
      GrpTakeRes{cfg_emit(st2, ITake{fregs, low_nth_u32(U32.to_nat(col), vs)}), low_splice_u32(U32.to_nat(col), vs, fregs), low_splice_u32(U32.to_nat(col), scs, low_mask_scs(U32.to_nat(nf), sm, 0)), low_splice_u32(U32.to_nat(col), trs, low_zero_scs(U32.to_nat(nf)))}
    case HCNone{}: GrpTakeRes{st, vs, scs, trs}
def low_pat_needs_tag(+env: LowEnv, p: Pat) -> Bool:
  match p:
    case PList{_}: True{}
    case PCtr{+sym, _}:
      +k = low_special_ctor_kind(env_kind(env), sym)
      Bool.and(Bool.or(U32.is_zero(k), U32.is_gt(k, 5)), U32.is_zero(um_get(env_csingle(env), sym)))
    case _: False{}
def low_mpat_needs_tag(+env: LowEnv, mp: Maybe<&2, Pat>) -> U32:
  match mp:
    case Some{p}: Bool.to_u32(low_pat_needs_tag(env, p))
    case None{}: 0
def low_col_tag_uses(+env: LowEnv, +col: U32, cs: List<&2, Case>, +acc: U32) -> U32:
  match cs:
    case Nil{}: acc
    case Con{_, Nil{}}: acc
    case Con{Case{ps, _}, Con{c2, rt}}:
      low_col_tag_uses(env, col, Con{c2, rt}, U32.add(acc, low_mpat_needs_tag(env, low_nth_pat(U32.to_nat(col), ps))))
def low_emit_tag_cache_one(need: Bool, st: CfgSt, r: U32, acc: List<&2, U32>) -> CfgSt:
  match need:
    case True{}:
      +st1 = cfg_alloc_reg(st)
      +tr = cfg_res(st1)
      cfg_set_rlist(cfg_emit(st1, ITag{tr, r}), Con{U32.add(tr, 1), acc})
    case False{}: cfg_set_rlist(st, Con{0, acc})
def low_emit_tag_cache(vs: List<&2, U32>, +env: LowEnv, st: CfgSt, +cs: List<&2, Case>, +col: U32, acc: List<&2, U32>) -> CfgSt:
  match vs:
    case Nil{}: cfg_set_rlist(st, b5k_list_rev(U32, acc))
    case Con{r, vt}:
      +st1 = low_emit_tag_cache_one(U32.is_ge(low_col_tag_uses(env, col, cs, 0), 2), st, r, acc)
      low_emit_tag_cache(vt, env, st1, cs, U32.add(col, 1), cfg_rlist(st1))
def low_pat_flat_ok(+env: LowEnv, p: Pat) -> Bool:
  match p:
    case PWild{}: True{}
    case PVar{_, _}: True{}
    case PNum{_}: True{}
    case PChr{_}: True{}
    case PPair{a, b}: Bool.not(pat_is_refut(16n, [a, b]))
    case PList{Nil{}}: True{}
    case PCtr{+sym, +fs}:
      +k = low_special_ctor_kind(env_kind(env), sym)
      is_bn = Bool.and(Bool.and(U32.is_ge(k, 1), U32.is_le(k, 3)), U32.is_zero(b5k_list_len(Pat, fs)))
      is_bx = Bool.and(Bool.or(U32.is_zero(k), U32.is_gt(k, 5)), Bool.not(pat_is_refut(16n, fs)))
      Bool.or(is_bn, is_bx)
    case _: False{}
def low_pats_flat_ok(ps: List<&2, Pat>, +env: LowEnv) -> Bool:
  match ps:
    case Nil{}: True{}
    case Con{p, t}: Bool.and(low_pat_flat_ok(env, p), low_pats_flat_ok(t, env))
def low_pretest_ctr(k: U32, +env: LowEnv, st: CfgSt, +sym: U32, r: U32, tr: U32, fb: U32) -> CfgSt:
  match k:
    case 1: low_test_bool(st, False{}, r, fb)
    case 2: low_test_bool(st, True{}, r, fb)
    case 3: low_test_bool(st, False{}, r, fb)
    case _:
      +cv = um_get(env_ctors(env), sym)
      cid = Bool.pick(U32, U32.is_zero(cv), 0, U32.sub(cv, 1))
      low_opt_test_tag(U32.is_zero(um_get(env_csingle(env), sym)), st, r, tr, cid, fb)
def low_pretest_one(+env: LowEnv, st: CfgSt, p: Pat, r: U32, tr: U32, fb: U32) -> CfgSt:
  match p:
    case PNum{v}: low_test_cmp_const(st, B5K_CMP_EQ(), r, v, fb)
    case PChr{c}: low_test_cmp_const(st, B5K_CMP_EQ(), r, c, fb)
    case PList{Nil{}}: low_opt_test_tag(True{}, st, r, tr, 4, fb)
    case PCtr{+sym, _}: low_pretest_ctr(low_special_ctor_kind(env_kind(env), sym), env, st, sym, r, tr, fb)
    case _: st
def low_pretest_pats(ps: List<&2, Pat>, +env: LowEnv, st: CfgSt, rs: List<&2, U32>, trs: List<&2, U32>, +fb: U32) -> CfgSt:
  match ps rs trs:
    case Con{p, pt} Con{r, rt} Con{tr, trt}: low_pretest_pats(pt, env, low_pretest_one(env, st, p, r, tr, fb), rt, trt, fb)
    case _ _ _: st
def low_match_case_pats_go(is_flat: Bool, +env: LowEnv, st: CfgSt, +ps: List<&2, Pat>, +rs: List<&2, U32>, scs: List<&2, U32>, +trs: List<&2, U32>, body: Expr, +fb: U32) -> CfgSt:
  match is_flat:
    case True{}:
      st1 = low_pretest_pats(ps, env, st, rs, trs, fb)
      low_match_pats_sct(64n, env, st1, ps, rs, scs, trs, body, 0, False{})
    case False{}: low_match_pats_sct(64n, env, st, ps, rs, scs, trs, body, fb, True{})
def low_match_case_pats(+env: LowEnv, st: CfgSt, +ps: List<&2, Pat>, rs: List<&2, U32>, scs: List<&2, U32>, trs: List<&2, U32>, body: Expr, fb: U32) -> CfgSt:
  is_multi = U32.is_ge(b5k_list_len(Pat, ps), 2)
  low_match_case_pats_go(Bool.and(is_multi, low_pats_flat_ok(ps, env)), env, st, ps, rs, scs, trs, body, fb)
type LowTask is Data:
  LTExpr{e: Expr}
  LTExprs{es: List<&2, Expr>, acc: List<&2, U32>}
  LTCases{base_vm: U32Map, base_nvm: U32Map, cs: List<&2, Case>, vscruts: List<&2, U32>, sc_scruts: List<&2, U32>, tregs: List<&2, U32>, res_reg: U32, merge_blk: U32}
  LTCasesGrp{base_vm: U32Map, base_nvm: U32Map, cs: List<&2, Case>, vscruts: List<&2, U32>, sc_scruts: List<&2, U32>, tregs: List<&2, U32>, res_reg: U32, merge_blk: U32, pick: GrpPick}
  LTCasesTake{base_vm: U32Map, base_nvm: U32Map, gtr: GrpTakeRes, grp: List<&2, Case>, tail: List<&2, Case>, tail_blk: U32, orig_vs: List<&2, U32>, orig_scs: List<&2, U32>, orig_trs: List<&2, U32>, res_reg: U32, merge_blk: U32}
  LTCmpCases{base_vm: U32Map, base_nvm: U32Map, cs: List<&2, Case>, va: U32, vb: U32, res_reg: U32, merge_blk: U32}
  LTMatStart{base_vm: U32Map, base_nvm: U32Map, cs: List<&2, Case>, vscruts: List<&2, U32>, sc_scruts: List<&2, U32>}
  LTMatOne{base_vm: U32Map, base_nvm: U32Map, s0: Expr, cs: List<&2, Case>, bkind: U32, cinfo: CmpMatchInfo}
  LTAppSym{sym: U32, args: List<&2, Expr>, lv: U32, lz: Bool}
  LTAppGlob{sym: U32, args: List<&2, Expr>, icode: U32, has_i: Bool, fv: U32, fz: Bool}
  LTAppFn{sym: U32, args: List<&2, Expr>, fid: U32, ar: U32, vargs: List<&2, U32>, is_sat: Bool, is_over: Bool}
  LTVar{sym: U32, lv: U32, lz: Bool}
  LTVarGlob{sym: U32, fz: Bool}
  LTLam{p0: Param, body: Expr, fvs: List<&2, U32>, bk: CloBank}
  LTLetUnbox{pa: Pat, pb: Pat, ua: UnboxArr, body: Expr}
  LTLetCtr2{is_tup: Bool, sym: U32, pa: Pat, pb: Pat, val: Expr, body: Expr}
def low_type_head(+syms: SymTab, e: Expr) -> String:
  match e:
    case EVar{s}: symtab_name(syms, s)
    case ERef{s}: symtab_name(syms, s)
    case EApp{f, _}: low_type_head(syms, f)
    case _: ""
def low_map_ops(+fuel: Nat, +is_f32: Bool, e: Expr) -> Expr:
  match fuel e:
    case 0n _: e
    case 1n+p EOp{+op, a, b}:
      op2 = Bool.pick(U32, is_f32, Bool.pick(U32, U32.is_lt(op, 4), U32.add(op, 10), op), Bool.pick(U32, U32.is_zero(op), 19, op))
      EOp{op2, low_map_ops(p, is_f32, a), low_map_ops(p, is_f32, b)}
    case 1n+p EAnn{v, t}: EAnn{low_map_ops(p, is_f32, v), t}
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
    case CfgSt{_, nregs, _, _, _, blks_rev, _, _, _, _, _, _, CloBank{+lam_fid, +lam_cid, cr, fr, er}}:
      CloBank{U32.add(lam_fid, 1), U32.add(lam_cid, 1), Con{IrCtor{lam_cid, String.append("__clo_", b5k_u32_to_str(lam_fid)), ncaps, False{}}, cr}, Con{IrFn{lam_fid, String.append("__lam_", b5k_u32_to_str(lam_fid)), ar, nregs, True{}, False{}, False{}, b5k_list_rev(IrBlock, blks_rev)}, fr}, Con{CloEntry{lam_cid, lam_fid, ncaps}, er}}
def low_drop_intr_arg(drop: Bool, args: List<&2, Expr>) -> List<&2, Expr>:
  match drop args:
    case True{} Con{_, t}: t
    case _ xs: xs
def low_expr_lt32(fuel: Nat, +syms: SymTab, e: Expr) -> Bool:
  match fuel e:
    case 0n _: False{}
    case 1n+_ ENum{v}: U32.is_lt(v, 32)
    case 1n+p EAnn{v, _}: low_expr_lt32(p, syms, v)
    case 1n+p EApp{EVar{s}, Con{x, Nil{}}}:
      +nm = symtab_name(syms, s)
      Bool.and(Bool.or(b5k_str_eq(nm, "U32.to_nat"), b5k_str_eq(nm, "U32.from_nat")), low_expr_lt32(p, syms, x))
    case 1n+p EApp{ERef{s}, Con{x, Nil{}}}:
      +nm = symtab_name(syms, s)
      Bool.and(Bool.or(b5k_str_eq(nm, "U32.to_nat"), b5k_str_eq(nm, "U32.from_nat")), low_expr_lt32(p, syms, x))
    case 1n+p EApp{EVar{s}, Con{a, Con{b, Nil{}}}}:
      +p0 = p
      Bool.and(b5k_str_eq(symtab_name(syms, s), "U32.and"), Bool.or(low_expr_lt32(p0, syms, a), low_expr_lt32(p0, syms, b)))
    case 1n+p EApp{ERef{s}, Con{a, Con{b, Nil{}}}}:
      +p0 = p
      Bool.and(b5k_str_eq(symtab_name(syms, s), "U32.and"), Bool.or(low_expr_lt32(p0, syms, a), low_expr_lt32(p0, syms, b)))
    case 1n+p EOp{5, a, b}:
      +p0 = p
      Bool.or(low_expr_lt32(p0, syms, a), low_expr_lt32(p0, syms, b))
    case 1n+_ _: False{}
def low_shift_code(syms: SymTab, skind: U32Map, +icode: U32, args: List<&2, Expr>) -> U32:
  match args:
    case Con{_, Con{eb, Nil{}}}: Bool.pick(U32, Bool.and(Bool.or(U32.is_eq(icode, 24), U32.is_eq(icode, 25)), low_expr_lt32(16n, syms, eb)), U32.add(icode, 4), icode)
    case Con{ty, _}: Bool.pick(U32, Bool.and(U32.is_eq(icode, 62), low_is_scalar_type(skind, ty)), 68, icode)
    case _: icode
def low_const_log2_go(fuel: Nat, +n: U32, acc: U32, done: Bool) -> U32:
  match fuel done:
    case 0n _: acc
    case _ True{}: acc
    case 1n+p False{}:
      +nxt = U32.shr(n)
      low_const_log2_go(p, nxt, U32.add(acc, 1), U32.is_le(nxt, 1))
def low_const_log2(fuel: Nat, +n: U32, acc: U32) -> U32:
  low_const_log2_go(fuel, n, acc, U32.is_le(n, 1))
def low_go(fuel: Nat, +env: LowEnv, st: CfgSt, task: LowTask, +is_tail: Bool) -> CfgSt:
  match fuel task:
    case Zero{} _: st
    case Succ{_} LTExprs{Nil{}, acc}: cfg_set_rlist(st, b5k_list_rev(U32, acc))
    case Succ{+p} LTExprs{Con{h, t}, acc}:
      +st1 = low_go(p, env, st, LTExpr{h}, False{})
      low_go(p, env, st1, LTExprs{t, Con{cfg_res(st1), acc}}, False{})
    case Succ{_} LTCases{_, _, Nil{}, _, _, _, _, _}: cfg_seal(st, TFail{1})
    case Succ{+p} LTCases{+base_vm, +base_nvm, Con{Case{+ps, +body}, rest}, +vscruts, +sc_scruts, +tregs, +res_reg, +merge_blk}:
      match rest:
        case Nil{}:
          +st0 = st
          prev_mg = cfg_merged(st0)
          st1 = low_match_pats_sct(64n, env, cfg_set_vm_nvm(st0, base_vm, base_nvm), ps, vscruts, sc_scruts, tregs, body, 0, False{})
          +st2 = low_go(p, env, st1, LTExpr{body}, is_tail)
          cfg_fin_branch(st2, cfg_sealed(st2), res_reg, cfg_res(st2), merge_blk, prev_mg)
        case Con{+rh, +rt}:
          low_go(p, env, st, LTCasesGrp{base_vm, base_nvm, Con{Case{ps, body}, Con{rh, rt}}, vscruts, sc_scruts, tregs, res_reg, merge_blk, low_grp_find_go(64n, env, ps, Con{Case{ps, body}, Con{rh, rt}}, GFCol{vscruts, 0})}, is_tail)
    case Succ{+p} LTCasesGrp{+base_vm, +base_nvm, Con{Case{ps, +body}, rest}, +vscruts, +sc_scruts, +tregs, +res_reg, +merge_blk, GPNone{}}:
      +st0 = st
      prev_mg = cfg_merged(st0)
      +st_f = cfg_alloc_blk(st0)
      +nxt_blk = cfg_res(st_f)
      st1 = low_match_case_pats(env, cfg_set_vm_nvm(st_f, base_vm, base_nvm), ps, vscruts, sc_scruts, tregs, body, nxt_blk)
      +st2 = low_go(p, env, st1, LTExpr{body}, is_tail)
      st3 = cfg_fin_branch(st2, cfg_sealed(st2), res_reg, cfg_res(st2), merge_blk, prev_mg)
      low_go(p, env, cfg_start(st3, nxt_blk), LTCases{base_vm, base_nvm, rest, vscruts, sc_scruts, tregs, res_reg, merge_blk}, is_tail)
    case Succ{p} LTCasesGrp{base_vm, base_nvm, _, +vscruts, +sc_scruts, +tregs, res_reg, merge_blk, GPHit{+col, spec, grp, Nil{}}}:
      +st0 = st
      low_go(p, env, st0, LTCasesTake{base_vm, base_nvm, low_grp_emit_take(env, st0, spec, col, vscruts, sc_scruts, tregs), low_splice_cases(col, grp), Nil{}, 0, vscruts, sc_scruts, tregs, res_reg, merge_blk}, is_tail)
    case Succ{p} LTCasesGrp{base_vm, base_nvm, _, +vscruts, +sc_scruts, +tregs, res_reg, merge_blk, GPHit{+col, HCCtr{+sym, +nf}, grp, Con{th, tt}}}:
      +st_f = cfg_alloc_blk(st)
      +tail_blk = cfg_res(st_f)
      +cv = um_get(env_ctors(env), sym)
      +st_ok = low_opt_test_tag(True{}, st_f, low_nth_u32(U32.to_nat(col), vscruts), low_nth_u32(U32.to_nat(col), tregs), Bool.pick(U32, U32.is_zero(cv), 0, U32.sub(cv, 1)), tail_blk)
      low_go(p, env, st_ok, LTCasesTake{base_vm, base_nvm, low_grp_emit_take(env, st_ok, HCCtr{sym, nf}, col, vscruts, sc_scruts, tregs), low_splice_cases(col, grp), Con{th, tt}, tail_blk, vscruts, sc_scruts, tregs, res_reg, merge_blk}, is_tail)
    case Succ{_} LTCasesGrp{_, _, _, _, _, _, _, _, _}: cfg_seal(st, TFail{1})
    case Succ{p} LTCasesTake{base_vm, base_nvm, GrpTakeRes{st1, vs1, scs1, trs1}, grp, Nil{}, _, _, _, _, res_reg, merge_blk}:
      low_go(p, env, st1, LTCases{base_vm, base_nvm, grp, vs1, scs1, trs1, res_reg, merge_blk}, is_tail)
    case Succ{+p} LTCasesTake{+base_vm, +base_nvm, GrpTakeRes{st1, vs1, scs1, trs1}, grp, Con{th, tt}, tail_blk, orig_vs, orig_scs, orig_trs, +res_reg, +merge_blk}:
      st2 = low_go(p, env, st1, LTCases{base_vm, base_nvm, grp, vs1, scs1, trs1, res_reg, merge_blk}, is_tail)
      low_go(p, env, cfg_start(st2, tail_blk), LTCases{base_vm, base_nvm, Con{th, tt}, orig_vs, orig_scs, orig_trs, res_reg, merge_blk}, is_tail)
    case Succ{_} LTCmpCases{_, _, Nil{}, _, _, _, _}: cfg_seal(st, TFail{1})
    case Succ{+p} LTCmpCases{+base_vm, +base_nvm, Con{Case{Con{_, Nil{}}, body}, Nil{}}, _, _, +res_reg, +merge_blk}:
      +st0 = st
      prev_mg = cfg_merged(st0)
      +st2 = low_go(p, env, cfg_set_vm_nvm(st0, base_vm, base_nvm), LTExpr{body}, is_tail)
      cfg_fin_branch(st2, cfg_sealed(st2), res_reg, cfg_res(st2), merge_blk, prev_mg)
    case Succ{+p} LTCmpCases{+base_vm, +base_nvm, Con{Case{Con{PWild{}, Nil{}}, body}, Con{_, _}}, _, _, +res_reg, +merge_blk}:
      +st0 = st
      prev_mg = cfg_merged(st0)
      +st2 = low_go(p, env, cfg_set_vm_nvm(st0, base_vm, base_nvm), LTExpr{body}, is_tail)
      cfg_fin_branch(st2, cfg_sealed(st2), res_reg, cfg_res(st2), merge_blk, prev_mg)
    case Succ{+p} LTCmpCases{+base_vm, +base_nvm, Con{Case{Con{p_other, Nil{}}, body}, Con{rh, rt}}, +va, +vb, +res_reg, +merge_blk}:
      +st0 = st
      prev_mg = cfg_merged(st0)
      +code = low_cmp_pat_code(env_kind(env), p_other)
      +cop = Bool.pick(U32, U32.is_eq(code, 1), B5K_CMP_LT(), Bool.pick(U32, U32.is_eq(code, 2), B5K_CMP_EQ(), B5K_CMP_GT()))
      +st_c = cfg_alloc_reg(st0)
      +cond = cfg_res(st_c)
      +st_o = cfg_alloc_blk(cfg_emit(st_c, ICmp{cond, cop, va, vb}))
      +ok_blk = cfg_res(st_o)
      +st_f = cfg_alloc_blk(st_o)
      +nxt_blk = cfg_res(st_f)
      st1 = cfg_start(cfg_seal(st_f, TBr{cond, ok_blk, nxt_blk}), ok_blk)
      +st2 = low_go(p, env, cfg_set_vm_nvm(st1, base_vm, base_nvm), LTExpr{body}, is_tail)
      st3 = cfg_fin_branch(st2, cfg_sealed(st2), res_reg, cfg_res(st2), merge_blk, prev_mg)
      low_go(p, env, cfg_start(st3, nxt_blk), LTCmpCases{base_vm, base_nvm, Con{rh, rt}, va, vb, res_reg, merge_blk}, is_tail)
    case Succ{+p} LTMatStart{+base_vm, +base_nvm, +cs1, +vscruts1, sc_scruts1}:
      +st_t = low_emit_tag_cache(vscruts1, env, st, cs1, 0, Nil{})
      +tregs = cfg_rlist(st_t)
      +st2 = cfg_alloc_reg(st_t)
      +res_reg = cfg_res(st2)
      +st3 = cfg_alloc_blk(st2)
      +merge_blk = cfg_res(st3)
      +st4 = low_go(p, env, cfg_set_merged(st3, False{}), LTCases{base_vm, base_nvm, cs1, vscruts1, sc_scruts1, tregs, res_reg, merge_blk}, is_tail)
      cfg_set_res(cfg_set_vm_nvm(cfg_maybe_start(st4, cfg_merged(st4), merge_blk), base_vm, base_nvm), res_reg)
    case Succ{+p} LTMatOne{_, _, s0, _, 1, _}: low_go(p, env, st, LTExpr{s0}, is_tail)
    case Succ{+p} LTMatOne{_, _, s0, _, 2, _}:
      +st1 = low_go(p, env, st, LTExpr{s0}, False{})
      +st2 = low_emit_const(st1, 0)
      low_emit_bin_or_cmp(st2, True{}, B5K_CMP_EQ(), cfg_res(st1), cfg_res(st2))
    case Succ{+p} LTMatOne{+base_vm, +base_nvm, _, cs, _, CMHit{ea, eb}}:
      +st1 = low_go(p, env, st, LTExpr{ea}, False{})
      +st2 = low_go(p, env, st1, LTExpr{eb}, False{})
      +st3 = cfg_alloc_reg(st2)
      +res_reg = cfg_res(st3)
      +st4 = cfg_alloc_blk(st3)
      +merge_blk = cfg_res(st4)
      +st5 = low_go(p, env, cfg_set_merged(st4, False{}), LTCmpCases{base_vm, base_nvm, cs, cfg_res(st1), cfg_res(st2), res_reg, merge_blk}, is_tail)
      cfg_set_res(cfg_set_vm_nvm(cfg_maybe_start(st5, cfg_merged(st5), merge_blk), base_vm, base_nvm), res_reg)
    case Succ{+p} LTMatOne{+base_vm, +base_nvm, +s0, cs, _, CMNone{}}:
      sc_scruts = low_exprs_sc_codes(env, base_vm, base_nvm, [s0])
      +st1 = low_go(p, env, st, LTExprs{[s0], Nil{}}, False{})
      low_go(p, env, st1, LTMatStart{base_vm, base_nvm, cs, cfg_rlist(st1), sc_scruts}, is_tail)
    case Succ{_} LTAppFn{_, _, +fid, _, vargs, True{}, _}:
      +st0 = st
      low_app_direct(st0, fid, vargs, Bool.and(is_tail, U32.is_eq(fid, cfg_cur_fid(st0))))
    case Succ{_} LTAppFn{_, _, fid, +ar, +vargs, False{}, True{}}:
      +st1 = low_app_direct(st, fid, low_take_u32(U32.to_nat(ar), vargs), False{})
      low_apply_chain(low_drop_u32(U32.to_nat(ar), vargs), st1, cfg_res(st1))
    case Succ{p} LTAppFn{sym, args, _, _, _, False{}, False{}}:
      +tmp = env_tmp(env)
      low_go(p, env, st, LTExpr{ELam{[Param{tmp, None{}, False{}, False{}}], EApp{EVar{sym}, b5k_list_app(Expr, args, [EVar{tmp}])}}}, False{})
    case Succ{p} LTAppGlob{_, +args, +icode, True{}, _, _}:
      +icode2 = low_shift_code(env_syms(env), env_kind(env), icode, args)
      +st1 = low_go(p, env, st, LTExprs{low_drop_intr_arg(U32.is_ge(icode2, 60), args), Nil{}}, False{})
      low_emit_u32_intr(st1, icode2, cfg_rlist(st1))
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
      +icode = low_intr_code(env_intr(env), sym)
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
      lam_st0 = low_bind_params(env_kind(env), [p0], low_bind_lam_caps(cfg_nvm(st0), fvs, cfg_new(4294967295, ar, bk0), 0, body), ncaps, body)
      +lam_st1 = low_go(p, env, lam_st0, LTExpr{body}, True{})
      lam_cid = low_bank_next_cid(cfg_bank(lam_st1))
      bk2 = low_bank_finish_lam(ncaps, ar, cfg_seal(lam_st1, TRet{cfg_res(lam_st1)}))
      cap_vregs = low_lookup_fvs(fvs, cfg_vmap(st0))
      +st1 = cfg_alloc_reg(cfg_set_bank(st0, bk2))
      cfg_emit(st1, ICtor{cfg_res(st1), lam_cid, cap_vregs})
    case Succ{_} LTExpr{ENum{v}}: low_emit_const(st, v)
    case Succ{_} LTExpr{EFlt{bits}}:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, IFlt{cfg_res(st1), bits})
    case Succ{_} LTExpr{EChr{c}}: low_emit_const(st, c)
    case Succ{_} LTExpr{EUnit{}}: low_emit_ctor(st, 7, Nil{})
    case Succ{_} LTExpr{EStr{s}}: low_str_chain(s, st)
    case Succ{p} LTExpr{EVar{+sym}}:
      +st0 = st
      +lv = um_get(cfg_vmap(st0), sym)
      low_go(p, env, st0, LTVar{sym, lv, U32.is_zero(lv)}, is_tail)
    case Succ{p} LTExpr{ERef{sym}}: low_go(p, env, st, LTExpr{EVar{sym}}, is_tail)
    case Succ{+p} LTExpr{EOp{+op, +a, +b}}:
      +st0 = st
      +is_add = Bool.or(U32.is_eq(op, 19), Bool.and(U32.is_zero(op), Bool.or(low_is_num_expr(16n, env, cfg_vmap(st0), cfg_nvm(st0), a), low_is_num_expr(16n, env, cfg_vmap(st0), cfg_nvm(st0), b))))
      +st1 = low_go(p, env, st0, LTExpr{a}, False{})
      +st2 = low_go(p, env, st1, LTExpr{b}, False{})
      low_emit_op_go(is_add, U32.is_zero(op), env, st2, op, cfg_res(st1), cfg_res(st2))
    case Succ{p} LTExpr{EUnOp{op, a}}:
      +st1 = low_go(p, env, st, LTExpr{a}, False{})
      low_emit_un(st1, op, cfg_res(st1))
    case Succ{+p} LTLetUnbox{pa, pb, ua, +body}:
      match ua:
        case UArrGet{a, i, sc}:
          +st0 = st
          base_vm = cfg_vmap(st0)
          base_nvm = cfg_nvm(st0)
          +st1 = low_go(p, env, st0, LTExpr{a}, False{})
          +st2 = low_go(p, env, st1, LTExpr{i}, False{})
          +st3 = low_emit_arr_one(st2, 78, [cfg_res(st1), cfg_res(st2)])
          st4 = low_match_pats_sc(64n, env, st3, [pa, pb], [cfg_res(st1), cfg_res(st3)], [0, sc], body, 0, False{})
          cfg_set_vm_nvm(low_go(p, env, st4, LTExpr{body}, is_tail), base_vm, base_nvm)
        case UArrOp2{aop, args, sc1}:
          +st0 = st
          base_vm = cfg_vmap(st0)
          base_nvm = cfg_nvm(st0)
          +st1 = low_go(p, env, st0, LTExprs{args, Nil{}}, False{})
          +st2 = cfg_alloc_reg(st1)
          +r0 = cfg_res(st2)
          +st3 = cfg_alloc_reg(st2)
          +r1 = cfg_res(st3)
          st4 = low_match_pats_sc(64n, env, cfg_emit(st3, IArrOp{[r0, r1], aop, cfg_rlist(st1)}), [pa, pb], [r0, r1], [0, sc1], body, 0, False{})
          cfg_set_vm_nvm(low_go(p, env, st4, LTExpr{body}, is_tail), base_vm, base_nvm)
        case UArrPair{+a, +b}:
          +st0 = st
          base_vm = cfg_vmap(st0)
          base_nvm = cfg_nvm(st0)
          sa = low_expr_sc_code(env, cfg_vmap(st0), cfg_nvm(st0), a)
          sb = low_expr_sc_code(env, cfg_vmap(st0), cfg_nvm(st0), b)
          +st1 = low_go(p, env, st0, LTExpr{a}, False{})
          +st2 = low_go(p, env, st1, LTExpr{b}, False{})
          st3 = low_match_pats_sc(64n, env, st2, [pa, pb], [cfg_res(st1), cfg_res(st2)], [sa, sb], body, 0, False{})
          cfg_set_vm_nvm(low_go(p, env, st3, LTExpr{body}, is_tail), base_vm, base_nvm)
        case UArrNone{+val}:
          +st0 = st
          base_vm = cfg_vmap(st0)
          base_nvm = cfg_nvm(st0)
          vsc = low_expr_sc_code(env, cfg_vmap(st0), cfg_nvm(st0), val)
          +st1 = low_go(p, env, st0, LTExpr{val}, False{})
          st2 = low_match_pats_sc(64n, env, st1, [PPair{pa, pb}], [cfg_res(st1)], [vsc], body, 0, False{})
          cfg_set_vm_nvm(low_go(p, env, st2, LTExpr{body}, is_tail), base_vm, base_nvm)
    case Succ{+p} LTLetCtr2{True{}, _, pa, pb, val, body}:
      +st0 = st
      low_go(p, env, st0, LTLetUnbox{pa, pb, low_unbox_pair(env, cfg_vmap(st0), val), body}, is_tail)
    case Succ{+p} LTLetCtr2{False{}, sym, pa, pb, +val, +body}:
      +st0 = st
      base_vm = cfg_vmap(st0)
      base_nvm = cfg_nvm(st0)
      val_sc = low_expr_sc_code(env, cfg_vmap(st0), cfg_nvm(st0), val)
      +st1 = low_go(p, env, st0, LTExpr{val}, False{})
      st2 = low_match_pats_sc(64n, env, st1, [PCtr{sym, [pa, pb]}], [cfg_res(st1)], [val_sc], body, 0, False{})
      cfg_set_vm_nvm(low_go(p, env, st2, LTExpr{body}, is_tail), base_vm, base_nvm)
    case Succ{+p} LTExpr{ELet{PPair{pa, pb}, val, body}}:
      +st0 = st
      low_go(p, env, st0, LTLetUnbox{pa, pb, low_unbox_pair(env, cfg_vmap(st0), val), body}, is_tail)
    case Succ{+p} LTExpr{ELet{PCtr{+sym, Con{pa, Con{pb, Nil{}}}}, val, body}}:
      low_go(p, env, st, LTLetCtr2{U32.is_eq(um_get(env_kind(env), sym), 13), sym, pa, pb, val, body}, is_tail)
    case Succ{+p} LTExpr{ELet{pat, +val, +body}}:
      +st0 = st
      base_vm = cfg_vmap(st0)
      base_nvm = cfg_nvm(st0)
      val_sc = low_expr_sc_code(env, cfg_vmap(st0), cfg_nvm(st0), val)
      +st1 = low_go(p, env, st0, LTExpr{val}, False{})
      st2 = low_match_pats_sc(64n, env, st1, [pat], [cfg_res(st1)], [val_sc], body, 0, False{})
      cfg_set_vm_nvm(low_go(p, env, st2, LTExpr{body}, is_tail), base_vm, base_nvm)
    case Succ{+p} LTExpr{EIf{cond, ENum{1}, ENum{0}}}:
      low_go(p, env, st, LTExpr{cond}, is_tail)
    case Succ{+p} LTExpr{EIf{cond, ENum{0}, ENum{1}}}:
      +st1 = low_go(p, env, st, LTExpr{cond}, False{})
      +st2 = cfg_alloc_reg(st1)
      +c0 = cfg_res(st2)
      low_emit_bin_or_cmp(cfg_emit(st2, IConst{c0, 0}), True{}, B5K_CMP_EQ(), cfg_res(st1), c0)
    case Succ{+p} LTExpr{EIf{cond, t, f}}:
      +st0 = st
      +base_vm = cfg_vmap(st0)
      +base_nvm = cfg_nvm(st0)
      +st1 = low_go(p, env, st0, LTExpr{cond}, False{})
      +st2 = cfg_alloc_blk(st1)
      +st3 = cfg_alloc_blk(st2)
      +st4 = cfg_alloc_blk(st3)
      +lbl_m = cfg_res(st4)
      +st5 = cfg_alloc_reg(st4)
      +res_reg = cfg_res(st5)
      +st6 = low_go(p, env, cfg_start(cfg_seal(st5, TBr{cfg_res(st1), cfg_res(st2), cfg_res(st3)}), cfg_res(st2)), LTExpr{t}, is_tail)
      +st7 = cfg_fin_branch(st6, cfg_sealed(st6), res_reg, cfg_res(st6), lbl_m, False{})
      +st8 = low_go(p, env, cfg_set_vm_nvm(cfg_start(st7, cfg_res(st3)), base_vm, base_nvm), LTExpr{f}, is_tail)
      +st9 = cfg_fin_branch(st8, cfg_sealed(st8), res_reg, cfg_res(st8), lbl_m, cfg_merged(st7))
      cfg_set_res(cfg_set_vm_nvm(cfg_maybe_start(st9, cfg_merged(st9), lbl_m), base_vm, base_nvm), res_reg)
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
    case Succ{+p} LTExpr{EMat{Con{val, Nil{}}, Con{Case{Con{PPair{pa, pb}, Nil{}}, body}, Nil{}}}}:
      +st0 = st
      low_go(p, env, st0, LTLetUnbox{pa, pb, low_unbox_pair(env, cfg_vmap(st0), val), body}, is_tail)
    case Succ{+p} LTExpr{EMat{Con{+s0, Nil{}}, +cs}}:
      +st0 = st
      +base_vm = cfg_vmap(st0)
      +base_nvm = cfg_nvm(st0)
      low_go(p, env, st0, LTMatOne{base_vm, base_nvm, s0, cs, low_bool_match_kind(env_kind(env), cs), low_cmp_match_info(env, base_vm, s0, cs)}, is_tail)
    case Succ{+p} LTExpr{EMat{+scruts, +cs}}:
      +st0 = st
      +base_vm = cfg_vmap(st0)
      +base_nvm = cfg_nvm(st0)
      sc_scruts = low_exprs_sc_codes(env, base_vm, base_nvm, scruts)
      +st1 = low_go(p, env, st0, LTExprs{scruts, Nil{}}, False{})
      low_go(p, env, st1, LTMatStart{base_vm, base_nvm, cs, cfg_rlist(st1), sc_scruts}, is_tail)
    case Succ{p} LTExpr{EAnn{+v, typ}}:
      +th = low_type_head(env_syms(env), typ)
      +v1 = Bool.pick(Expr, b5k_str_eq(th, "F32"), low_map_ops(32n, True{}, v), v)
      v2 = Bool.pick(Expr, Bool.or(b5k_str_eq(th, "U32"), b5k_str_eq(th, "Nat")), low_map_ops(32n, False{}, v1), v1)
      low_go(p, env, st, LTExpr{v2}, is_tail)
    case Succ{p} LTExpr{EList{es}}:
      +st1 = low_go(p, env, st, LTExprs{es, Nil{}}, False{})
      low_list_chain(cfg_rlist(st1), st1)
    case Succ{+p} LTExpr{EPair{a, b}}:
      +st1 = low_go(p, env, st, LTExpr{a}, False{})
      +st2 = low_go(p, env, st1, LTExpr{b}, False{})
      low_emit_ctor(st2, 6, [cfg_res(st1), cfg_res(st2)])
    case Succ{p} LTExpr{EArrNew{es}}:
      match es:
        case Con{v, Con{ENum{len}, Nil{}}}:
          +st1 = low_go(p, env, st, LTExpr{v}, False{})
          +st2 = low_emit_const(st1, low_const_log2(32n, len, 0))
          low_emit_arr_one(st2, 71, [cfg_res(st2), cfg_res(st1)])
        case Con{v, Con{len, Nil{}}}: low_go(p, env, st, LTExpr{EApp{EVar{env_arr_len(env)}, [len, v]}}, is_tail)
        case _: low_emit_const(st, 0)
    case Succ{+p} LTExpr{EArrGet{a, i}}:
      +st1 = low_go(p, env, st, LTExpr{a}, False{})
      +st2 = low_go(p, env, st1, LTExpr{i}, False{})
      low_emit_arr_get_pair(st2, cfg_res(st1), cfg_res(st2))
    case Succ{+p} LTExpr{EArrSet{a, i, +v}}:
      +st0 = st
      +st1 = low_go(p, env, st0, LTExpr{a}, False{})
      +st2 = low_go(p, env, st1, LTExpr{i}, False{})
      +st3 = low_go(p, env, st2, LTExpr{v}, False{})
      low_emit_arr_one(st3, Bool.pick(U32, low_is_num_expr(16n, env, cfg_vmap(st0), cfg_nvm(st0), v), 79, 73), [cfg_res(st1), cfg_res(st2), cfg_res(st3)])
    case Succ{p} LTExpr{EDo{ss}}: low_go(p, env, st, LTExpr{low_desugar_do(env, ss)}, is_tail)
    case Succ{p} LTExpr{ELam{ps, +body}}:
      match ps:
        case Nil{}: low_go(p, env, st, LTExpr{body}, is_tail)
        case Con{p0, Con{p1, rest}}: low_go(p, env, st, LTExpr{low_curry_lam(Con{p0, Con{p1, rest}}, body)}, is_tail)
        case Con{+p0, Nil{}}:
          +st0 = st
          fvs = b5k_list_rev(U32, fv_go(U32.to_nat(2048), cfg_vmap(st0), fv_add_params([p0], UM0{}), UIExpr{body}, Nil{}))
          low_go(p, env, st0, LTLam{p0, body, fvs, cfg_bank(st0)}, False{})
    case Succ{_} _: low_emit_const(st, 0)
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
def low_def_wrap_main(is_io_main: Bool, +st: CfgSt) -> CfgSt:
  match is_io_main:
    case False{}: cfg_seal(st, TRet{cfg_res(st)})
    case True{}:
      +st1 = cfg_alloc_reg(st)
      +clo = cfg_res(st1)
      cfg_seal(cfg_emit(st1, ICallClosure{clo, 1, [cfg_res(st)]}), TRet{clo})
def low_def_fin(env: LowEnv, +fid: U32, sym: U32, ar: U32, st: CfgSt) -> DefRes:
  LowEnv{syms, _, _, _, _, _, _, _, _, main_fid, _, _, _, _, _, _} = env
  CfgSt{_, nregs, _, _, _, blks_rev, _, _, _, _, _, _, bk} = st
  DefRes{IrFn{fid, symtab_name(syms, sym), ar, nregs, False{}, False{}, U32.is_eq(fid, main_fid), b5k_list_rev(IrBlock, blks_rev)}, bk}
def low_def(+env: LowEnv, +fid: U32, d: Def, bank: CloBank) -> DefRes:
  LowEnv{_, _, _, _, _, _, _, _, skind, main_fid, main_pure, _, _, _, _, _} = env
  Def{sym, +params, _, +body, _, _} = d
  +ar = low_param_arity_go(params, 0)
  +st2 = low_go(U32.to_nat(2048), env, low_bind_params(skind, params, cfg_new(fid, ar, bank), 0, body), LTExpr{body}, True{})
  low_def_fin(env, fid, sym, ar, low_def_wrap_main(Bool.and(U32.is_eq(fid, main_fid), Bool.not(main_pure)), st2))
type DefsRes is Data:
  DefsRes{fns: List<&2, IrFn>, bank: CloBank}
def low_dr_fn(dr: DefRes) -> IrFn:
  DefRes{fn, _} = dr
  fn
def low_dr_bank(dr: DefRes) -> CloBank:
  DefRes{_, bk} = dr
  bk
def low_defs(ds: List<&2, Def>, +env: LowEnv, +fid: U32, acc: List<&2, IrFn>, bank: CloBank) -> DefsRes:
  match ds:
    case Nil{}: DefsRes{b5k_list_rev(IrFn, acc), bank}
    case Con{d, t}:
      +dr = low_def(env, fid, d, bank)
      low_defs(t, env, U32.add(fid, 1), Con{low_dr_fn(dr), acc}, low_dr_bank(dr))
def b5k_lower_fin(dr: DefsRes, ctors_base: List<&2, IrCtor>, main_fid: U32, si: ShowInfo) -> LowerRes:
  DefsRes{def_fns, CloBank{_, _, lam_ctors_rev, lam_fns_rev, entries_rev}} = dr
  ShowInfo{is_pure, sdesc, snames} = si
  all_ctors = b5k_list_app(IrCtor, ctors_base, b5k_list_rev(IrCtor, lam_ctors_rev))
  LowerRes{True{}, "", IrProg{Con{low_mk_apply_fn(b5k_list_rev(CloEntry, entries_rev)), Con{low_mk_io_run_fn(), Con{low_mk_io_cont_fn(), b5k_list_app(IrFn, def_fns, b5k_list_rev(IrFn, lam_fns_rev))}}}, all_ctors, Nil{}, main_fid, is_pure, Nil{}, sdesc, snames}}
def low_sym_or(m: Maybe<&2, U32>) -> U32:
  match m:
    case Some{s}: s
    case None{}: 0
def b5k_lower_s4(+st: SymTab, +sym_tmp: U32, sym_t2: U32, defs: List<&2, Def>, ctor_by_sym: U32Map, ctor_smask: U32Map, ctor_single: U32Map, next_cid: U32, ctors_rev: List<&2, IrCtor>, next_fid: U32, fn_by_sym: U32Map, fn_arity: U32Map, fn_emask: U32Map, +main_fid: U32, main_sym: U32, mret: Maybe<&2, Expr>, si: ShowInfo) -> LowerRes:
  ShowInfo{+is_pure, sdesc, snames} = si
  sintr = low_seed_u32_map(st, low_intr_specs(), UM0{})
  skind = low_seed_u32_map(st, low_kind_specs(), UM0{})
  defs2 = low_maybe_patch_main(is_pure, mret, defs, main_sym, st, sym_tmp, sym_t2, low_sym_or(symtab_lookup(st, "Array.to_list")))
  dr = low_defs(defs2, LowEnv{st, ctor_by_sym, ctor_smask, ctor_single, fn_by_sym, fn_arity, fn_emask, sintr, skind, main_fid, is_pure, low_sym_or(symtab_lookup(st, "IO.bind")), low_sym_or(symtab_lookup(st, "IO.pure")), low_sym_or(symtab_lookup(st, "String.append")), sym_tmp, low_sym_or(symtab_lookup(st, "__arr_len"))}, 3, Nil{}, CloBank{next_fid, next_cid, Nil{}, Nil{}, Nil{}})
  b5k_lower_fin(dr, b5k_list_rev(IrCtor, ctors_rev), main_fid, ShowInfo{is_pure, sdesc, snames})
def b5k_lower_i2(sr: SymRes, sym_tmp: U32, +defs: List<&2, Def>, laws: List<&2, LawDef>, ctor_by_sym: U32Map, ctor_smask: U32Map, ctor_single: U32Map, next_cid: U32, ctors_rev: List<&2, IrCtor>, next_fid: U32, fn_by_sym: U32Map, fn_arity: U32Map, fn_emask: U32Map, main_fid: U32, +main_sym: U32) -> LowerRes:
  SymRes{+s5, sym_t2} = sr
  +mret = low_find_main_ret(defs, laws, main_sym)
  b5k_lower_s4(s5, sym_tmp, sym_t2, defs, ctor_by_sym, ctor_smask, ctor_single, next_cid, ctors_rev, next_fid, fn_by_sym, fn_arity, fn_emask, main_fid, main_sym, mret, low_show_info(s5, mret))
def b5k_lower_i1(sr: SymRes, defs: List<&2, Def>, laws: List<&2, LawDef>, ctor_by_sym: U32Map, ctor_smask: U32Map, ctor_single: U32Map, next_cid: U32, ctors_rev: List<&2, IrCtor>, next_fid: U32, fn_by_sym: U32Map, fn_arity: U32Map, fn_emask: U32Map, main_fid: U32, main_sym: U32) -> LowerRes:
  SymRes{s4, sym_tmp} = sr
  b5k_lower_i2(symtab_intern(s4, "__b5k_t2"), sym_tmp, defs, laws, ctor_by_sym, ctor_smask, ctor_single, next_cid, ctors_rev, next_fid, fn_by_sym, fn_arity, fn_emask, main_fid, main_sym)
def b5k_lower_s3(syms: SymTab, defs: List<&2, Def>, laws: List<&2, LawDef>, ctor_by_sym: U32Map, ctor_smask: U32Map, ctor_single: U32Map, next_cid: U32, ctors_rev: List<&2, IrCtor>, fa: FnTabAcc) -> LowerRes:
  FnTabAcc{next_fid, fn_by_sym, fn_arity, fn_emask, main_fid, main_sym} = fa
  b5k_lower_i1(symtab_intern(syms, "__b5k_tmp"), defs, laws, ctor_by_sym, ctor_smask, ctor_single, next_cid, ctors_rev, next_fid, fn_by_sym, fn_arity, fn_emask, main_fid, main_sym)
def b5k_lower_s2(+defs: List<&2, Def>, laws: List<&2, LawDef>, ca: CtorTabAcc) -> LowerRes:
  CtorTabAcc{+syms, next_cid, ctor_by_sym, ctor_smask, ctor_single, ctors_rev} = ca
  b5k_lower_s3(syms, defs, laws, ctor_by_sym, ctor_smask, ctor_single, next_cid, ctors_rev, low_add_defs(syms, defs, FnTabAcc{3, UM0{}, UM0{}, UM0{}, 3, 0}))
def b5k_lower_with_prelude(types: List<&2, TypeDef>, udefs: List<&2, Def>, laws: List<&2, LawDef>, pr: ParseRes) -> LowerRes:
  ParseRes{_, _, Book{_, pdefs, _, +syms1}} = pr
  skind0 = low_seed_u32_map(syms1, low_kind_specs(), UM0{})
  b5k_lower_s2(b5k_list_app(Def, pdefs, udefs), laws, low_add_types(skind0, types, low_seed_core(low_core_specs(), CtorTabAcc{syms1, 0, UM0{}, UM0{}, UM0{}, Nil{}})))
def b5k_lower(book: Book) -> LowerRes:
  Book{types, defs, laws, syms} = book
  b5k_lower_with_prelude(types, defs, laws, b5k_parse(b5k_prelude_src(), syms))
