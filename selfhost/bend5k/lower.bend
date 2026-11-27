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
def um_get0(m: U32Map, k: U32) -> U32:
  +v = um_get(m, k)
  Bool.pick(U32, U32.is_zero(v), 0, U32.sub(v, 1))
def low_expr_sym1(e: Expr) -> U32:
  match e:
    case EVar{s}: U32.add(s, 1)
    case ERef{s}: U32.add(s, 1)
    case _: 0
# Embedded Base/Runtime Prelude (parsed into Book before Pass 1)
def b5k_prelude_src() -> String:
  "def Bool.not(b: Bool) -> Bool:\n  if b: False{} else: True{}\ndef Bool.and(a: Bool, b: Bool) -> Bool:\n  if a: b else: False{}\ndef Bool.or(a: Bool, b: Bool) -> Bool:\n  if a: True{} else: b\ndef Bool.xor(a: Bool, b: Bool) -> Bool:\n  if a: Bool.not(b) else: b\ndef Bool.full_add(a: Bool, b: Bool, c: Bool) -> Bool & Bool:\n  if a: Tuple{Bool.not(Bool.xor(b, c)), Bool.or(b, c)} else: Tuple{Bool.xor(b, c), Bool.and(b, c)}\ndef Word.to_nat(n: Nat, w: Word) -> Nat:\n  if U32.is_ge(n, 32): w else: U32.and(w, U32.sub(U32.shln(1, n), 1))\ndef Word.add(n: Nat, a: Word, b: Word) -> Word:\n  Word.to_nat(n, U32.add(a, b))\ndef Word.add_comm(-n: Nat, -a: Word, -b: Word) -> U32:\n  0\ndef U32.add_comm(-a: U32, -b: U32) -> U32:\n  0\ndef Equal.sym(-T: Data, -a: U32, -b: U32, e: U32) -> U32:\n  e\ndef Equal.trans(-T: Data, -a: U32, -b: U32, -c: U32, e1: U32, e2: U32) -> U32:\n  e2\ndef Equal.cong(-A: Data, -B: Data, -f: U32, -a: U32, -b: U32, e: U32) -> U32:\n  e\ndef Bool.to_u32(b: Bool) -> U32:\n  if b: 1 else: 0\ndef Bool.pick(-T: Data, b: Bool, t: T, f: T) -> T:\n  if b: t else: f\ndef Char.to_u32(c: Char) -> U32:\n  c\ndef Char.from_u32(n: U32) -> Char:\n  n\ndef Char.show(c: Char) -> String:\n  SCon{c, SNil{}}\ndef Char.cmp(a: Char, b: Char) -> Cmp:\n  Tuple{Tuple{a, b}, if U32.is_lt(a, b): LT{} else: if U32.is_gt(a, b): GT{} else: EQ{}}\ndef Cmp.is_eq(c: Cmp) -> Bool:\n  match c:\n    case EQ{}: True{}\n    case _: False{}\ndef Maybe.default(-q: Data, -A: Data, m: Maybe<A>, d: A) -> A:\n  match m:\n    case None{}: d\n    case Some{v}: v\ndef List.append(-q: Data, -T: Data, a: List<T>, b: List<T>) -> List<T>:\n  match a:\n    case Nil{}: b\n    case Con{h, t}: Con{h, List.append(q, T, t, b)}\ndef String.is_empty(s: String) -> Bool:\n  match s:\n    case SNil{}: True{}\n    case SCon{_, _}: False{}\ndef String.length.go(s: String, acc: Nat) -> Nat:\n  match s:\n    case SNil{}: acc\n    case SCon{_, t}: String.length.go(t, U32.add(acc, 1))\ndef String.length(s: String) -> Nat:\n  String.length.go(s, 0)\n" ++
  "def String.starts_with(s: String, p: String) -> Bool:\n  match p s:\n    case SNil{} _: True{}\n    case SCon{_, _} SNil{}: False{}\n    case SCon{c1, t1} SCon{c2, t2}: if U32.is_eq(c1, c2): String.starts_with(t2, t1) else: False{}\ndef String.drop(s: String, n: Nat) -> String:\n  match n s:\n    case 0n _: s\n    case _ SNil{}: SNil{}\n    case 1n+p SCon{_, t}: String.drop(t, p)\ndef __b5k_str_append(a: String, b: String) -> String:\n  String.reverse.go(String.reverse(a), b)\ndef String.append(a: String, b: String) -> String:\n  __b5k_str_append(a, b)\ndef String.reverse.go(s: String, acc: String) -> String:\n  match s:\n    case SNil{}: acc\n    case SCon{h, t}: String.reverse.go(t, SCon{h, acc})\ndef String.reverse(s: String) -> String:\n  String.reverse.go(s, SNil{})\ndef String.order(a: String, b: String) -> Cmp:\n  match a b:\n    case SNil{} SNil{}: EQ{}\n    case SNil{} SCon{_, _}: LT{}\n    case SCon{_, _} SNil{}: GT{}\n    case SCon{x, t1} SCon{y, t2}:\n      if U32.is_lt(x, y): LT{} else: if U32.is_gt(x, y): GT{} else: String.order(t1, t2)\ndef String.cmp(a: String, b: String) -> (String & String) & Cmp:\n  Tuple{Tuple{a, b}, String.order(a, b)}\ndef String.eq(a: String, b: String) -> Bool:\n  match String.order(a, b):\n    case EQ{}: True{}\n    case _: False{}\ndef U32.show.go(n: U32, acc: String) -> String:\n  if U32.is_zero(n): acc else: U32.show.go(U32.div(n, 10), SCon{U32.add(48, U32.mod(n, 10)), acc})\ndef U32.show(n: U32) -> String:\n  if U32.is_zero(n): \"0\" else: U32.show.go(n, SNil{})\ndef U32.read.go(s: String, acc: U32) -> Maybe<U32>:\n  match s:\n    case SNil{}: Some{acc}\n    case SCon{c, t}:\n      d = U32.sub(c, 48)\n      n = U32.add(U32.mul(acc, 10), d)\n      if Bool.and(U32.is_lt(d, 10), U32.is_eq(U32.div(n, 10), acc)): U32.read.go(t, n) else: None{}\ndef U32.read(s: String) -> Maybe<U32>:\n  match s:\n    case SNil{}: None{}\n    case SCon{c, t}: U32.read.go(SCon{c, t}, 0)\ndef U32.max(a: U32, b: U32) -> U32:\n  if U32.is_gt(a, b): a else: b\ndef U32.min(a: U32, b: U32) -> U32:\n  if U32.is_lt(a, b): a else: b\n" ++
  "def U32.log2.go(k: Nat, n: U32, b: Nat) -> Nat:\n  match k:\n    case 0n: b\n    case 1n+p:\n      s = U32.shln(1, p)\n      t = if U32.is_ne(U32.shrn(n, s), 0): s else: 0\n      U32.log2.go(p, U32.shrn(n, t), U32.add(b, t))\ndef U32.log2(n: U32) -> Nat:\n  U32.log2.go(5n, n, 0)\ndef U32.cmp(a: U32, b: U32) -> Cmp:\n  if U32.is_lt(a, b): LT{} else: if U32.is_eq(a, b): EQ{} else: GT{}\ndef Nat.min(a: Nat, b: Nat) -> Nat:\n  if Nat.is_lt(a, b): a else: b\ndef Nat.max(a: Nat, b: Nat) -> Nat:\n  if Nat.is_lt(b, a): a else: b\ndef Nat.is_le(a: Nat, b: Nat) -> Bool:\n  Bool.not(Nat.is_lt(b, a))\ndef Nat.is_gt(a: Nat, b: Nat) -> Bool:\n  Nat.is_lt(b, a)\ndef Nat.is_ge(a: Nat, b: Nat) -> Bool:\n  Bool.not(Nat.is_lt(a, b))\ndef Nat.is_eq(a: Nat, b: Nat) -> Bool:\n  Cmp.is_eq(Nat.cmp(a, b))\ndef Nat.is_ne(a: Nat, b: Nat) -> Bool:\n  Bool.not(Cmp.is_eq(Nat.cmp(a, b)))\ndef Nat.show.go(n: Nat, acc: String) -> String:\n  if U32.is_zero(n): acc else:\n    (q, r) = Nat.divmod(n, 10)\n    Nat.show.go(q, SCon{U32.add(48, r), acc})\ndef Nat.show(n: Nat) -> String:\n  if U32.is_zero(n): \"0\" else: Nat.show.go(n, SNil{})\ndef Nat.read.trim(s: String) -> String:\n  match s:\n    case SCon{c, t}: if U32.is_eq(c, 48): Nat.read.trim(t) else: SCon{c, t}\n    case SNil{}: SNil{}\ndef Nat.read.go(s: String, acc: Nat) -> Maybe<Nat>:\n  match s:\n    case SNil{}: Some{acc}\n    case SCon{c, t}:\n      d = U32.sub(c, 48)\n      if U32.is_lt(d, 10): Nat.read.go(t, __nat_add(__nat_mul(acc, 10), d)) else: None{}\ndef Nat.read(s: String) -> Maybe<Nat>:\n  match s:\n    case SNil{}: None{}\n    case SCon{h, t}:\n      u = Nat.read.trim(SCon{h, t})\n      n = String.length(u)\n      if Bool.or(U32.is_lt(n, 15), Bool.and(U32.is_eq(n, 15), String.is_le(u, \"281474976710655\"))): Nat.read.go(u, 0) else: None{}\ndef IO.pure(-A: Data, x: A) -> IO(A):\n  k => k(x)\ndef IO.bind(-A: Data, -B: Data, m: IO(A), f: A -> IO(B)) -> IO(B):\n  k => m(x => f(x)(k))\ndef IO.print(s: String) -> IO(Unit):\n  k => __io_print(s, k)\ndef IO.print_err(s: String) -> IO(Unit):\n" ++
  "  k => __io_print_err(s, k)\ndef IO.exit(c: U32) -> IO(Unit):\n  k => Exit{c}\ndef __b5k_seal_args(xs: List<String>) -> List<String>:\n  match xs:\n    case Nil{}: Nil{}\n    case Con{s, t}: Con{String.reverse(String.reverse(s)), __b5k_seal_args(t)}\ndef IO.args() -> IO(List<String>):\n  IO.bind(List<String>, List<String>, k => __io_args(k), xs => IO.pure(List<String>, __b5k_seal_args(xs)))\ndef IO.now() -> IO(U32):\n  k => __io_now(k)\ndef File.open(p: String, m: String) -> IO(U32):\n  k => __file_open(p, m, k)\ndef File.read(f: U32, n: U32) -> IO(U32):\n  k => __file_read(f, n, k)\ndef File.size(f: U32) -> IO(U32):\n  k => __file_size(f, k)\ndef File.write(f: U32, s: String) -> IO(U32):\n  k => __file_write(f, s, k)\ndef File.write_bytes(f: U32, bs: List<U32>) -> IO(U32):\n  k => __file_write_bytes(f, bs, k)\ndef File.close(f: U32) -> IO(Unit):\n  k => __file_close(f, k)\ndef __arr_len(n: U32, v: U32) -> Array<U32>:\n  d = if U32.is_le(n, 1): 0 else: U32.log2(n)\n  Array.new(U32, d, v)\ndef Array.fork(-T: Data, +a: Array<T>) -> Array<T>:\n  Tuple{a, a}\ndef Array.join(-T: Data, a: Array<T>, b: Array<T>) -> Array<T>:\n  a\ndef __arr_toli_go(n: Nat, i: U32, a: Array<U32>, acc: List<U32>) -> List<U32>:\n  match n:\n    case 0n: acc\n    case 1n+p:\n      (a2, v) = Array.get(U32, a, i)\n      __arr_toli_go(p, U32.sub(i, 1), a2, Con{v, acc})\ndef Array.to_list(-T: Data, a: Array<T>) -> List<T>:\n  (a2, n) = Array.size(T, a)\n  __arr_toli_go(U32.to_nat(n), U32.sub(n, 1), a2, Nil{})\ndef Map.new(-q: Data, -V: Data) -> Map<V>:\n  MTip{}\ndef Map.set(-q: Data, -V: Data, m: Map<V>, k: String, v: V) -> Map<V>:\n  match m:\n    case MTip{}: MLeaf{k, v}\n    case MLeaf{k0, v0}:\n      match String.order(k, k0):\n        case LT{}: MNode{k, MLeaf{k, v}, MLeaf{k0, v0}}\n        case GT{}: MNode{k0, MLeaf{k0, v0}, MLeaf{k, v}}\n        case EQ{}: MLeaf{k, v}\n    case MNode{k0, l, r}:\n      match String.order(k, k0):\n        case GT{}: MNode{k0, l, Map.set(q, V, r, k, v)}\n        case _: MNode{k0, Map.set(q, V, l, k, v), r}\n" ++
  "def Map.get(-V: Data, d: V, m: Map<V>, k: String) -> Map<V>:\n  match m:\n    case MTip{}: Tuple{MTip{}, d}\n    case MLeaf{k0, v0}:\n      match String.order(k, k0):\n        case EQ{}: Tuple{MLeaf{k0, v0}, v0}\n        case _: Tuple{MLeaf{k0, v0}, d}\n    case MNode{k0, l, r}:\n      match String.order(k, k0):\n        case GT{}:\n          (r2, res) = Map.get(V, d, r, k)\n          Tuple{MNode{k0, l, r2}, res}\n        case _:\n          (l2, res) = Map.get(V, d, l, k)\n          Tuple{MNode{k0, l2, r}, res}\ndef Map.del(-q: Data, -V: Data, m: Map<V>, k: String) -> Map<V>:\n  match m:\n    case MTip{}: MTip{}\n    case MLeaf{k0, v0}:\n      match String.order(k, k0):\n        case EQ{}: MTip{}\n        case _: MLeaf{k0, v0}\n    case MNode{k0, l, r}:\n      match String.order(k, k0):\n        case GT{}:\n          r2 = Map.del(q, V, r, k)\n          match r2:\n            case MTip{}: l\n            case _: MNode{k0, l, r2}\n        case _:\n          l2 = Map.del(q, V, l, k)\n          match l2:\n            case MTip{}: r\n            case _: MNode{k0, l2, r}\ndef Map.to_list.go(m: Map<U32>, acc: List<U32>) -> List<U32>:\n  match m:\n    case MTip{}: acc\n    case MLeaf{k, v}: Con{Tuple{k, v}, acc}\n    case MNode{_, l, r}: Map.to_list.go(l, Map.to_list.go(r, acc))\ndef Map.to_list(-q: Data, -V: Data, m: Map<V>) -> List<V>:\n  Map.to_list.go(m, Nil{})\ndef Map.has(-q: Data, -V: Data, m: Map<V>, k: String) -> Map<V>:\n  match m:\n    case MTip{}: Tuple{MTip{}, False{}}\n    case MLeaf{k0, v0}:\n      match String.order(k, k0):\n        case EQ{}: Tuple{MLeaf{k0, v0}, True{}}\n        case _: Tuple{MLeaf{k0, v0}, False{}}\n    case MNode{k0, l, r}:\n      match String.order(k, k0):\n        case GT{}:\n          (r2, h) = Map.has(q, V, r, k)\n          Tuple{MNode{k0, l, r2}, h}\n        case _:\n          (l2, h) = Map.has(q, V, l, k)\n          Tuple{MNode{k0, l2, r}, h}\ndef Map.pop_r(k0: String, l: Map<U32>, r2: Map<U32>, o: Maybe<U32>) -> Map<U32>:\n  match r2:\n    case MTip{}: Tuple{l, o}\n" ++
  "    case _: Tuple{MNode{k0, l, r2}, o}\ndef Map.pop_l(k0: String, l2: Map<U32>, r: Map<U32>, o: Maybe<U32>) -> Map<U32>:\n  match l2:\n    case MTip{}: Tuple{r, o}\n    case _: Tuple{MNode{k0, l2, r}, o}\ndef Map.pop(-q: Data, -V: Data, m: Map<V>, k: String) -> Map<V>:\n  match m:\n    case MTip{}: Tuple{MTip{}, None{}}\n    case MLeaf{k0, v0}:\n      match String.order(k, k0):\n        case EQ{}: Tuple{MTip{}, Some{v0}}\n        case _: Tuple{MLeaf{k0, v0}, None{}}\n    case MNode{k0, l, r}:\n      match String.order(k, k0):\n        case GT{}:\n          (r2, o) = Map.pop(q, V, r, k)\n          Map.pop_r(k0, l, r2, o)\n        case _:\n          (l2, o) = Map.pop(q, V, l, k)\n          Map.pop_l(k0, l2, r, o)\ndef Map.from_list.go(xs: List<U32>, m: Map<U32>) -> Map<U32>:\n  match xs:\n    case Nil{}: m\n    case Con{kv, t}:\n      (k, v) = kv\n      Map.from_list.go(t, Map.set(0, 0, m, k, v))\ndef Map.from_list(-q: Data, -V: Data, xs: List<U32>) -> Map<V>:\n  Map.from_list.go(xs, MTip{})\ndef Map.union(-q: Data, -V: Data, a: Map<V>, b: Map<V>) -> Map<V>:\n  Map.from_list.go(Map.to_list(q, V, b), a)\ndef Map.keys.go(m: Map<U32>, acc: List<String>) -> List<String>:\n  match m:\n    case MTip{}: acc\n    case MLeaf{k, _}: Con{k, acc}\n    case MNode{_, l, r}: Map.keys.go(l, Map.keys.go(r, acc))\ndef Map.keys(-q: Data, -V: Data, m: Map<V>) -> List<String>:\n  Map.keys.go(m, Nil{})\ndef Map.values.go(m: Map<U32>, acc: List<U32>) -> List<U32>:\n  match m:\n    case MTip{}: acc\n    case MLeaf{_, v}: Con{v, acc}\n    case MNode{_, l, r}: Map.values.go(l, Map.values.go(r, acc))\ndef Map.values(-q: Data, -V: Data, m: Map<V>) -> List<V>:\n  Map.values.go(m, Nil{})\ndef Set.new() -> Map<Unit>:\n  MTip{}\ndef Set.add(s: Map<Unit>, k: String) -> Map<Unit>:\n  Map.set(0, 0, s, k, Unit{})\ndef Set.has(s: Map<Unit>, k: String) -> Map<Unit>:\n  Map.has(0, 0, s, k)\ndef Set.del(s: Map<Unit>, k: String) -> Map<Unit>:\n  Map.del(0, 0, s, k)\ndef Set.to_list(s: Map<Unit>) -> List<String>:\n  Map.keys(0, 0, s)\n" ++
  "def Set.size(s: Map<Unit>) -> Nat:\n  Map.size(0, 0, s)\ndef Set.from_list.go(xs: List<String>, s: Map<Unit>) -> Map<Unit>:\n  match xs:\n    case Nil{}: s\n    case Con{k, t}: Set.from_list.go(t, Set.add(s, k))\ndef Set.from_list(xs: List<String>) -> Map<Unit>:\n  Set.from_list.go(xs, MTip{})\ndef Bool.show(b: Bool) -> String:\n  if b: \"True\" else: \"False\"\ndef Cmp.is_lt(c: Cmp) -> Bool:\n  match c:\n    case LT{}: True{}\n    case _: False{}\ndef Cmp.is_gt(c: Cmp) -> Bool:\n  match c:\n    case GT{}: True{}\n    case _: False{}\ndef Cmp.is_le(c: Cmp) -> Bool:\n  match c:\n    case GT{}: False{}\n    case _: True{}\ndef Cmp.is_ge(c: Cmp) -> Bool:\n  match c:\n    case LT{}: False{}\n    case _: True{}\ndef Pair.fst(-A: Data, -B: Data, p: A & B) -> A:\n  (a, b) = p\n  a\ndef Pair.snd(-A: Data, -B: Data, p: A & B) -> B:\n  (a, b) = p\n  b\ndef Char.eq(a: Char, b: Char) -> Bool:\n  U32.is_eq(a, b)\ndef Char.is_eq(a: Char, b: Char) -> Bool:\n  U32.is_eq(a, b)\ndef Char.is_digit(c: Char) -> Bool:\n  Bool.and(U32.is_ge(c, 48), U32.is_le(c, 57))\ndef Char.is_upper(c: Char) -> Bool:\n  Bool.and(U32.is_ge(c, 65), U32.is_le(c, 90))\ndef Char.is_lower(c: Char) -> Bool:\n  Bool.and(U32.is_ge(c, 97), U32.is_le(c, 122))\ndef Char.is_alpha(c: Char) -> Bool:\n  Bool.or(Char.is_upper(c), Char.is_lower(c))\ndef Char.is_space(c: Char) -> Bool:\n  Bool.or(U32.is_eq(c, 32), Bool.or(U32.is_eq(c, 9), Bool.or(U32.is_eq(c, 10), U32.is_eq(c, 13))))\ndef Char.to_lower(c: Char) -> Char:\n  if Char.is_upper(c): U32.add(c, 32) else: c\ndef Char.to_upper(c: Char) -> Char:\n  if Char.is_lower(c): U32.sub(c, 32) else: c\ndef Maybe.pure(-q: Data, -A: Data, x: A) -> Maybe<A>:\n  Some{x}\ndef Maybe.some(-q: Data, -A: Data, x: A) -> Maybe<A>:\n  Some{x}\ndef Maybe.bind(-q1: Data, -q2: Data, -A: Data, -B: Data, m: Maybe<A>, f: A -> Maybe<B>) -> Maybe<B>:\n  match m:\n    case None{}: None{}\n    case Some{v}: f(v)\ndef __mb_pure(-A: Data, x: A) -> Maybe<A>:\n  Some{x}\ndef __mb_bind(-A: Data, -B: Data, m: Maybe<A>, f: A -> Maybe<B>) -> Maybe<B>:\n  match m:\n" ++
  "    case None{}: None{}\n    case Some{v}: f(v)\ndef Maybe.is_some(-q: Data, -A: Data, m: Maybe<A>) -> Bool:\n  match m:\n    case None{}: False{}\n    case Some{_}: True{}\ndef Maybe.is_none(-q: Data, -A: Data, m: Maybe<A>) -> Bool:\n  match m:\n    case None{}: True{}\n    case Some{_}: False{}\ndef Maybe.map(-q: Data, -A: Data, -B: Data, f: A -> B, m: Maybe<A>) -> Maybe<B>:\n  match m:\n    case None{}: None{}\n    case Some{v}: Some{f(v)}\ndef Maybe.or(-q: Data, -A: Data, m: Maybe<A>, n: Maybe<A>) -> Maybe<A>:\n  match m:\n    case None{}: n\n    case Some{v}: Some{v}\ndef Maybe.show(-q: Data, -A: Data, f: A -> String, m: Maybe<A>) -> String:\n  match m:\n    case None{}: \"None\"\n    case Some{v}: String.append(\"Some(\", String.append(f(v), \")\"))\ndef Result.pure(-q1: Data, -q2: Data, -E: Data, -A: Data, x: A) -> Result<E, A>:\n  Done{x}\ndef Result.bind(-q1: Data, -q2: Data, -E: Data, -A: Data, -B: Data, r: Result<E, A>, f: A -> Result<E, B>) -> Result<E, B>:\n  match r:\n    case Fail{e}: Fail{e}\n    case Done{v}: f(v)\ndef __res_pure(-A: Data, x: A) -> Result<U32, A>:\n  Done{x}\ndef __res_bind(-A: Data, -B: Data, r: Result<U32, A>, f: A -> Result<U32, B>) -> Result<U32, B>:\n  match r:\n    case Fail{e}: Fail{e}\n    case Done{v}: f(v)\ndef Result.default(-q1: Data, -q2: Data, -E: Data, -A: Data, r: Result<E, A>, d: A) -> A:\n  match r:\n    case Fail{_}: d\n    case Done{v}: v\ndef Result.is_done(-q1: Data, -q2: Data, -E: Data, -A: Data, r: Result<E, A>) -> Bool:\n  match r:\n    case Fail{_}: False{}\n    case Done{_}: True{}\ndef Result.is_fail(-q1: Data, -q2: Data, -E: Data, -A: Data, r: Result<E, A>) -> Bool:\n  match r:\n    case Fail{_}: True{}\n    case Done{_}: False{}\ndef Result.map(-q1: Data, -q2: Data, -E: Data, -A: Data, -B: Data, f: A -> B, r: Result<E, A>) -> Result<E, B>:\n  match r:\n    case Fail{e}: Fail{e}\n    case Done{v}: Done{f(v)}\ndef Result.or(-q1: Data, -q2: Data, -E: Data, -A: Data, r: Result<E, A>, b: Result<E, A>) -> Result<E, A>:\n  match r:\n    case Fail{_}: b\n" ++
  "    case Done{v}: Done{v}\ndef List.length.go(xs: List<U32>, acc: Nat) -> Nat:\n  match xs:\n    case Nil{}: acc\n    case Con{_, t}: List.length.go(t, U32.add(acc, 1))\ndef List.length(-q: Data, -A: Data, xs: List<A>) -> Nat:\n  List.length.go(xs, 0)\ndef List.concat(-q: Data, -A: Data, xss: List<List<A>>) -> List<A>:\n  match xss:\n    case Nil{}: Nil{}\n    case Con{h, t}: List.append(q, A, h, List.concat(q, A, t))\ndef List.reverse.go(xs: List<U32>, acc: List<U32>) -> List<U32>:\n  match xs:\n    case Nil{}: acc\n    case Con{h, t}: List.reverse.go(t, Con{h, acc})\ndef List.reverse(-q: Data, -A: Data, xs: List<A>) -> List<A>:\n  List.reverse.go(xs, Nil{})\ndef List.is_empty(-q: Data, -A: Data, xs: List<A>) -> Bool:\n  match xs:\n    case Nil{}: True{}\n    case Con{_, _}: False{}\ndef List.head(-q: Data, -A: Data, xs: List<A>) -> Maybe<A>:\n  match xs:\n    case Nil{}: None{}\n    case Con{h, _}: Some{h}\ndef List.tail(-q: Data, -A: Data, xs: List<A>) -> List<A>:\n  match xs:\n    case Nil{}: Nil{}\n    case Con{_, t}: t\ndef List.last.go(xs: List<U32>, last: U32) -> U32:\n  match xs:\n    case Nil{}: last\n    case Con{h, t}: List.last.go(t, h)\ndef List.last(-q: Data, -A: Data, xs: List<A>) -> Maybe<A>:\n  match xs:\n    case Nil{}: None{}\n    case Con{h, t}: Some{List.last.go(t, h)}\ndef List.get(-q: Data, -A: Data, xs: List<A>, n: Nat) -> Maybe<A>:\n  match xs n:\n    case Nil{} _: None{}\n    case Con{h, _} 0n: Some{h}\n    case Con{_, t} 1n+p: List.get(q, A, t, p)\ndef List.set(-q: Data, -A: Data, xs: List<A>, n: Nat, x: A) -> List<A>:\n  match xs n:\n    case Nil{} _: Nil{}\n    case Con{_, t} 0n: Con{x, t}\n    case Con{h, t} 1n+p: Con{h, List.set(q, A, t, p, x)}\ndef List.take(-q: Data, -A: Data, xs: List<A>, n: Nat) -> List<A>:\n  match xs n:\n    case _ 0n: Nil{}\n    case Nil{} _: Nil{}\n    case Con{h, t} 1n+p: Con{h, List.take(q, A, t, p)}\ndef List.drop(-q: Data, -A: Data, xs: List<A>, n: Nat) -> List<A>:\n  match xs n:\n    case _ 0n: xs\n    case Nil{} _: Nil{}\n" ++
  "    case Con{_, t} 1n+p: List.drop(q, A, t, p)\ndef List.zip(-q1: Data, -q2: Data, -A: Data, -B: Data, xs: List<A>, ys: List<B>) -> List<A & B>:\n  match xs ys:\n    case Con{x, xt} Con{y, yt}: Con{Tuple{x, y}, List.zip(q1, q2, A, B, xt, yt)}\n    case _ _: Nil{}\ndef List.range.go(n: Nat, acc: List<Nat>) -> List<Nat>:\n  match n:\n    case 0n: acc\n    case 1n+p: List.range.go(p, Con{p, acc})\ndef List.range(n: Nat) -> List<Nat>:\n  List.range.go(n, Nil{})\ndef List.replicate(-A: Data, n: Nat, x: A) -> List<A>:\n  match n:\n    case 0n: Nil{}\n    case 1n+p: Con{x, List.replicate(A, p, x)}\ndef List.map(-A: Data, -B: Data, f: A -> B, xs: List<A>) -> List<B>:\n  match xs:\n    case Nil{}: Nil{}\n    case Con{h, t}: Con{f(h), List.map(A, B, f, t)}\ndef List.filter(-A: Data, f: A -> Bool, xs: List<A>) -> List<A>:\n  match xs:\n    case Nil{}: Nil{}\n    case Con{h, t}: if f(h): Con{h, List.filter(A, f, t)} else: List.filter(A, f, t)\ndef List.foldl(-q: Data, -A: Data, -B: Data, f: B -> A -> B, xs: List<A>, acc: B) -> B:\n  match xs:\n    case Nil{}: acc\n    case Con{h, t}: List.foldl(q, A, B, f, t, f(acc)(h))\ndef List.foldr(-q: Data, -A: Data, -B: Data, f: A -> B -> B, xs: List<A>, acc: B) -> B:\n  match xs:\n    case Nil{}: acc\n    case Con{h, t}: f(h)(List.foldr(q, A, B, f, t, acc))\ndef List.any(-q: Data, -A: Data, f: A -> Bool, xs: List<A>) -> Bool:\n  match xs:\n    case Nil{}: False{}\n    case Con{h, t}: if f(h): True{} else: List.any(q, A, f, t)\ndef List.all(-q: Data, -A: Data, f: A -> Bool, xs: List<A>) -> Bool:\n  match xs:\n    case Nil{}: True{}\n    case Con{h, t}: if f(h): List.all(q, A, f, t) else: False{}\ndef List.find(-A: Data, f: A -> Bool, xs: List<A>) -> Maybe<A>:\n  match xs:\n    case Nil{}: None{}\n    case Con{h, t}: if f(h): Some{h} else: List.find(A, f, t)\ndef List.contains(-A: Data, eq: A -> A -> Bool, xs: List<A>, x: A) -> Bool:\n  match xs:\n    case Nil{}: False{}\n    case Con{h, t}: if eq(h)(x): True{} else: List.contains(A, eq, t, x)\n" ++
  "def List.merge(le: U32 -> U32 -> Bool, xs: List<U32>, ys: List<U32>) -> List<U32>:\n  match xs ys:\n    case Nil{} _: ys\n    case _ Nil{}: xs\n    case Con{x, xt} Con{y, yt}: if le(x)(y): Con{x, List.merge(le, xt, Con{y, yt})} else: Con{y, List.merge(le, Con{x, xt}, yt)}\ndef List.sort.pairs(le: U32 -> U32 -> Bool, xs: List<U32>) -> List<List<U32>>:\n  match xs:\n    case Nil{}: Nil{}\n    case Con{x, Nil{}}: Con{Con{x, Nil{}}, Nil{}}\n    case Con{x, Con{y, t}}: Con{if le(x)(y): Con{x, Con{y, Nil{}}} else: Con{y, Con{x, Nil{}}}, List.sort.pairs(le, t)}\ndef List.sort.pass(le: U32 -> U32 -> Bool, xss: List<List<U32>>) -> List<List<U32>>:\n  match xss:\n    case Nil{}: Nil{}\n    case Con{a, Nil{}}: Con{a, Nil{}}\n    case Con{a, Con{b, t}}: Con{List.merge(le, a, b), List.sort.pass(le, t)}\ndef List.sort.go(le: U32 -> U32 -> Bool, xss: List<List<U32>>) -> List<U32>:\n  match xss:\n    case Nil{}: Nil{}\n    case Con{a, Nil{}}: a\n    case _: List.sort.go(le, List.sort.pass(le, xss))\ndef List.sort(-A: Data, le: A -> A -> Bool, xs: List<A>) -> List<A>:\n  List.sort.go(le, List.sort.pairs(le, xs))\ndef List.for_each(-q: Data, -A: Data, f: A -> IO(Unit), xs: List<A>) -> IO(Unit):\n  match xs:\n    case Nil{}: IO.pure(Unit, Unit{})\n    case Con{h, t}: IO.bind(Unit, Unit, f(h), _ => List.for_each(q, A, f, t))\ndef List.show.go(f: U32 -> String, xs: List<U32>) -> String:\n  match xs:\n    case Nil{}: \"]\"\n    case Con{h, t}: String.append(\", \", String.append(f(h), List.show.go(f, t)))\ndef List.show(-q: Data, -A: Data, f: A -> String, xs: List<A>) -> String:\n  match xs:\n    case Nil{}: \"[]\"\n    case Con{h, t}: String.append(\"[\", String.append(f(h), List.show.go(f, t)))\ndef String.is_lt(a: String, b: String) -> Bool:\n  Cmp.is_lt(String.order(a, b))\ndef String.is_le(a: String, b: String) -> Bool:\n  Cmp.is_le(String.order(a, b))\ndef String.is_gt(a: String, b: String) -> Bool:\n  Cmp.is_gt(String.order(a, b))\ndef String.is_ge(a: String, b: String) -> Bool:\n  Cmp.is_ge(String.order(a, b))\n" ++
  "def String.ends_with(s: String, p: String) -> Bool:\n  String.starts_with(String.reverse(s), String.reverse(p))\ndef String.contains(s: String, p: String) -> Bool:\n  if String.starts_with(s, p): True{} else: match s:\n    case SNil{}: False{}\n    case SCon{_, t}: String.contains(t, p)\ndef String.take(s: String, n: Nat) -> String:\n  match s n:\n    case _ 0n: SNil{}\n    case SNil{} _: SNil{}\n    case SCon{h, t} 1n+p: SCon{h, String.take(t, p)}\ndef String.get(s: String, n: Nat) -> Maybe<Char>:\n  match s n:\n    case SNil{} _: None{}\n    case SCon{h, _} 0n: Some{h}\n    case SCon{_, t} 1n+p: String.get(t, p)\ndef String.to_list(s: String) -> List<Char>:\n  match s:\n    case SNil{}: Nil{}\n    case SCon{h, t}: Con{h, String.to_list(t)}\ndef String.from_list(cs: List<Char>) -> String:\n  match cs:\n    case Nil{}: SNil{}\n    case Con{h, t}: SCon{h, String.from_list(t)}\ndef String.concat(xs: List<String>) -> String:\n  match xs:\n    case Nil{}: SNil{}\n    case Con{h, t}: String.append(h, String.concat(t))\ndef String.join.go(xs: List<String>, h: String, sep: String) -> String:\n  match xs:\n    case Nil{}: h\n    case Con{x, t}: String.append(h, String.append(sep, String.join.go(t, x, sep)))\ndef String.join(xs: List<String>, sep: String) -> String:\n  match xs:\n    case Nil{}: SNil{}\n    case Con{h, t}: String.join.go(t, h, sep)\ndef String.split.push(c: Char, ps: List<String>) -> List<String>:\n  match ps:\n    case Nil{}: Con{SCon{c, SNil{}}, Nil{}}\n    case Con{h, t}: Con{SCon{c, h}, t}\ndef String.split(s: String, sep: Char) -> List<String>:\n  match s:\n    case SNil{}: Con{SNil{}, Nil{}}\n    case SCon{h, t}: if U32.is_eq(h, sep): Con{SNil{}, String.split(t, sep)} else: String.split.push(h, String.split(t, sep))\ndef String.lines(s: String) -> List<String>:\n  String.split(s, 10)\ndef String.repeat(s: String, n: Nat) -> String:\n  match n:\n    case 0n: SNil{}\n    case 1n+p: String.append(s, String.repeat(s, p))\ndef String.to_upper(s: String) -> String:\n  match s:\n    case SNil{}: SNil{}\n" ++
  "    case SCon{h, t}: SCon{Char.to_upper(h), String.to_upper(t)}\ndef String.to_lower(s: String) -> String:\n  match s:\n    case SNil{}: SNil{}\n    case SCon{h, t}: SCon{Char.to_lower(h), String.to_lower(t)}\ndef String.trim_start(s: String) -> String:\n  match s:\n    case SNil{}: SNil{}\n    case SCon{h, t}: if Char.is_space(h): String.trim_start(t) else: SCon{h, t}\ndef String.trim_end(s: String) -> String:\n  String.reverse(String.trim_start(String.reverse(s)))\ndef String.trim(s: String) -> String:\n  String.trim_end(String.trim_start(s))\ndef U32.MAX() -> U32:\n  4294967295\ndef U32.clamp(x: U32, lo: U32, hi: U32) -> U32:\n  U32.min(U32.max(x, lo), hi)\ndef U32.is_even(n: U32) -> Bool:\n  U32.is_zero(U32.and(n, 1))\ndef U32.pow(a: U32, n: Nat) -> U32:\n  match n:\n    case 0n: 1\n    case 1n+p: U32.mul(a, U32.pow(a, p))\ndef U32.popcount(n: U32) -> Nat:\n  a = U32.sub(n, U32.and(U32.shrn(n, 1n), 1431655765))\n  b = U32.add(U32.and(a, 858993459), U32.and(U32.shrn(a, 2n), 858993459))\n  c = U32.and(U32.add(b, U32.shrn(b, 4n)), 252645135)\n  U32.shrn(U32.mul(c, 16843009), 24n)\ndef U32.ctz(n: U32) -> Nat:\n  U32.popcount(U32.and(U32.not(n), U32.sub(n, 1)))\ndef Nat.div(a: Nat, b: Nat) -> Nat:\n  (q, r) = Nat.divmod(a, b)\n  q\ndef Nat.mod(a: Nat, b: Nat) -> Nat:\n  (q, r) = Nat.divmod(a, b)\n  r\ndef Nat.pow(a: Nat, n: Nat) -> Nat:\n  match n:\n    case 0n: 1\n    case 1n+p: __nat_mul(a, Nat.pow(a, p))\ndef F32.min(a: F32, b: F32) -> F32:\n  if F32.is_lt(a, b): a else: b\ndef F32.max(a: F32, b: F32) -> F32:\n  if F32.is_lt(a, b): b else: a\ndef F32.clamp(x: F32, lo: F32, hi: F32) -> F32:\n  F32.min(F32.max(x, lo), hi)\ndef F32.lerp(a: F32, b: F32, t: F32) -> F32:\n  if F32.is_eq(t, 0.0): a else: if F32.is_eq(t, 1.0): b else: F32.add(F32.mul(a, F32.sub(1.0, t)), F32.mul(b, t))\ndef F32.square(a: F32) -> F32:\n  F32.mul(a, a)\ndef F32.hypot(a: F32, b: F32) -> F32:\n  x = F32.abs(a)\n  y = F32.abs(b)\n  m = F32.max(x, y)\n  hi = F32.is_gt(m, F32.pow(2.0, 60.0))\n  lo = F32.is_lt(m, F32.pow(2.0, F32.neg(60.0)))\n" ++
  "  s = if hi: F32.pow(2.0, F32.neg(70.0)) else: if lo: F32.pow(2.0, 100.0) else: 1.0\n  u = if hi: F32.pow(2.0, 70.0) else: if lo: F32.pow(2.0, F32.neg(100.0)) else: 1.0\n  p = F32.mul(x, s)\n  q = F32.mul(y, s)\n  F32.mul(F32.sqrt(F32.add(F32.mul(p, p), F32.mul(q, q))), u)\ndef F32.round(a: F32) -> F32:\n  f = F32.floor(a)\n  r = F32.add(f, if F32.is_ge(F32.sub(a, f), 0.5): 1.0 else: 0.0)\n  if F32.is_eq(r, 0.0): F32.mul(a, 0.0) else: r\ndef F32.pi() -> F32:\n  F32.div(3141593.0, 1000000.0)\ndef F32.inf() -> F32:\n  F32.div(1.0, 0.0)\ndef F32.to_nat(a: F32) -> Nat:\n  p32 = F32.pow(2.0, 32.0)\n  p48 = F32.pow(2.0, 48.0)\n  if F32.is_gt(a, 0.0): if Bool.and(F32.is_ge(a, p32), F32.is_lt(a, p48)): __nat_add(__nat_mul(F32.to_u32(F32.div(a, p32)), __nat_mul(65536, 65536)), F32.to_u32(F32.mod(a, p32))) else: if F32.is_lt(a, p32): F32.to_u32(a) else: 0 else: 0\ndef Map.size(-q: Data, -V: Data, m: Map<V>) -> Nat:\n  match m:\n    case MTip{}: 0\n    case MLeaf{_, _}: 1\n    case MNode{_, l, r}: U32.add(Map.size(q, V, l), Map.size(q, V, r))\ndef Map.bit.u(x: U32, k: Nat) -> Bool:\n  U32.is_ne(U32.and(U32.shrn(x, k), 1), 0)\ndef Map.bit.go(s: String, ci: Nat, off: Nat) -> String & Bool:\n  match s:\n    case SNil{}: Tuple{SNil{}, False{}}\n    case SCon{c, t}: if Nat.is_eq(ci, 0): Tuple{SCon{c, t}, if Nat.is_eq(off, 0): True{} else: Map.bit.u(c, U32.sub(32, off))} else:\n      (t2, b) = Map.bit.go(t, Nat.sub(ci, 1), off)\n      Tuple{SCon{c, t2}, b}\ndef Map.bit(key: String, pos: Nat) -> String & Bool:\n  (ci, off) = Nat.divmod(pos, 33)\n  Map.bit.go(key, ci, off)\ndef Map.msb.u(n: Nat, x: U32) -> Nat:\n  match n:\n    case 0n: 0\n    case 1n+p: if U32.is_zero(x): 0 else: U32.add(1, Map.msb.u(p, U32.shr(x)))\ndef Array.set.fin(-T: Data, r: Array<T> & T) -> Array<T>:\n  (a, _) = r\n  a\ndef Array.map.go(n: Nat, i: U32, f: U32 -> U32, src: Array<U32>, dst: Array<U32>) -> Array<U32>:\n  match n:\n    case 0n: dst\n    case 1n+p:\n      (src2, v) = Array.get(U32, src, i)\n" ++
  "      Array.map.go(p, U32.add(i, 1), f, src2, Array.set(U32, dst, i, f(v)))\ndef Array.map(-T: Data, -U: Data, f: T -> U, a: Array<T>) -> Array<U>:\n  (a2, n) = Array.size(T, a)\n  (a3, v0) = Array.get(T, a2, 0)\n  d = if U32.is_le(n, 1): 0 else: U32.log2(n)\n  Array.map.go(U32.to_nat(n), 0, f, a3, Array.new(U, d, f(v0)))\ndef IO.die(-A: Data, code: U32, msg: String) -> IO(A):\n  IO.bind(Unit, Unit, IO.print_err(msg), _ => IO.exit(code))\ndef IO.write.strip(s: String) -> String:\n  match s:\n    case SNil{}: SNil{}\n    case SCon{c, SNil{}}: if U32.is_eq(c, 10): SNil{} else: SCon{c, SNil{}}\n    case SCon{c, t}: SCon{c, IO.write.strip(t)}\ndef IO.write(s: String) -> IO(Unit):\n  IO.print(IO.write.strip(s))\n"
# Shared List Combinators (used by lower, opt, x64)
def opt_foldl0(~A: Data, ~S: Data, ~f: A -> S -> S, xs: List<&2, A>, +st: S) -> S:
  match xs:
    case Nil{}: st
    case Con{+h, t}: opt_foldl0(~A, ~S, ~f, t, f(h, st))
def opt_foldl(~A: Data, ~E: Data, ~S: Data, ~f: E -> A -> S -> S, +env: E, xs: List<&2, A>, +st: S) -> S:
  match xs:
    case Nil{}: st
    case Con{+h, t}: opt_foldl(~A, ~E, ~S, ~f, env, t, f(env, h, st))
def opt_foldl2(~A: Data, ~E1: Data, ~E2: Data, ~S: Data, ~f: E1 -> E2 -> A -> S -> S, +e1: E1, +e2: E2, xs: List<&2, A>, +st: S) -> S:
  match xs:
    case Nil{}: st
    case Con{+h, t}: opt_foldl2(~A, ~E1, ~E2, ~S, ~f, e1, e2, t, f(e1, e2, h, st))
def opt_foldl3(~A: Data, ~E1: Data, ~E2: Data, ~E3: Data, ~S: Data, ~f: E1 -> E2 -> E3 -> A -> S -> S, +e1: E1, +e2: E2, +e3: E3, xs: List<&2, A>, +st: S) -> S:
  match xs:
    case Nil{}: st
    case Con{+h, t}: opt_foldl3(~A, ~E1, ~E2, ~E3, ~S, ~f, e1, e2, e3, t, f(e1, e2, e3, h, st))
def opt_mapl0(~A: Data, ~B: Data, ~f: A -> B, xs: List<&2, A>) -> List<&2, B>:
  match xs:
    case Nil{}: Nil{}
    case Con{+h, t}: Con{f(h), opt_mapl0(~A, ~B, ~f, t)}
def opt_mapl(~A: Data, ~E: Data, ~B: Data, ~f: E -> A -> B, +env: E, xs: List<&2, A>) -> List<&2, B>:
  match xs:
    case Nil{}: Nil{}
    case Con{+h, t}: Con{f(env, h), opt_mapl(~A, ~E, ~B, ~f, env, t)}
def opt_mapl2(~A: Data, ~E1: Data, ~E2: Data, ~B: Data, ~f: E1 -> E2 -> A -> B, +e1: E1, +e2: E2, xs: List<&2, A>) -> List<&2, B>:
  match xs:
    case Nil{}: Nil{}
    case Con{+h, t}: Con{f(e1, e2, h), opt_mapl2(~A, ~E1, ~E2, ~B, ~f, e1, e2, t)}
def opt_alll(~A: Data, ~E: Data, ~f: E -> A -> Bool, +env: E, xs: List<&2, A>) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{+h, t}: Bool.and(f(env, h), opt_alll(~A, ~E, ~f, env, t))
def opt_alll2(~A: Data, ~E1: Data, ~E2: Data, ~f: E1 -> E2 -> A -> Bool, +e1: E1, +e2: E2, xs: List<&2, A>) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{+h, t}: Bool.and(f(e1, e2, h), opt_alll2(~A, ~E1, ~E2, ~f, e1, e2, t))
def opt_alll3(~A: Data, ~E1: Data, ~E2: Data, ~E3: Data, ~f: E1 -> E2 -> E3 -> A -> Bool, +e1: E1, +e2: E2, +e3: E3, xs: List<&2, A>) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{+h, t}: Bool.and(f(e1, e2, e3, h), opt_alll3(~A, ~E1, ~E2, ~E3, ~f, e1, e2, e3, t))
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
  [CoreCtorSpec{"U32.add", 1}, CoreCtorSpec{"U32.sub", 2}, CoreCtorSpec{"U32.mul", 3}, CoreCtorSpec{"U32.div", 4}, CoreCtorSpec{"U32.mod", 5}, CoreCtorSpec{"U32.and", 6}, CoreCtorSpec{"Bool.and", 6}, CoreCtorSpec{"U32.or", 7}, CoreCtorSpec{"Bool.or", 7}, CoreCtorSpec{"U32.xor", 8}, CoreCtorSpec{"Bool.xor", 8}, CoreCtorSpec{"U32.is_eq", 11}, CoreCtorSpec{"U32.is_ne", 12}, CoreCtorSpec{"U32.is_lt", 13}, CoreCtorSpec{"U32.is_le", 14}, CoreCtorSpec{"U32.is_gt", 15}, CoreCtorSpec{"U32.is_ge", 16}, CoreCtorSpec{"U32.min", 17}, CoreCtorSpec{"U32.max", 18}, CoreCtorSpec{"U32.inc", 19}, CoreCtorSpec{"U32.dec", 20}, CoreCtorSpec{"U32.is_zero", 21}, CoreCtorSpec{"Bool.not", 21}, CoreCtorSpec{"U32.shl", 22}, CoreCtorSpec{"U32.shr", 23}, CoreCtorSpec{"U32.shln", 24},
   CoreCtorSpec{"U32.shrn", 25}, CoreCtorSpec{"U32.not", 26}, CoreCtorSpec{"U32.from_nat", 27}, CoreCtorSpec{"U32.to_nat", 27}, CoreCtorSpec{"F32.bits", 27}, CoreCtorSpec{"Bool.to_u32", 27}, CoreCtorSpec{"Char.to_u32", 27}, CoreCtorSpec{"Char.from_u32", 27}, CoreCtorSpec{"__io_print", 31}, CoreCtorSpec{"__io_print_err", 32}, CoreCtorSpec{"__io_args", 33}, CoreCtorSpec{"__io_now", 34}, CoreCtorSpec{"__file_open", 35}, CoreCtorSpec{"__file_read", 36}, CoreCtorSpec{"__file_size", 37}, CoreCtorSpec{"__file_write", 38}, CoreCtorSpec{"__file_write_bytes", 39}, CoreCtorSpec{"__file_close", 54}, CoreCtorSpec{"F32.add", 40}, CoreCtorSpec{"F32.sub", 41}, CoreCtorSpec{"F32.mul", 42}, CoreCtorSpec{"F32.div", 43}, CoreCtorSpec{"F32.is_eq", 44}, CoreCtorSpec{"F32.is_ne", 45}, CoreCtorSpec{"F32.is_lt", 46},
   CoreCtorSpec{"F32.is_le", 47}, CoreCtorSpec{"F32.is_gt", 48}, CoreCtorSpec{"F32.is_ge", 49}, CoreCtorSpec{"F32.neg", 50}, CoreCtorSpec{"F32.sqrt", 51}, CoreCtorSpec{"U32.to_f32", 52}, CoreCtorSpec{"F32.from_u32", 52}, CoreCtorSpec{"F32.to_u32", 53}, CoreCtorSpec{"Array.new", 60}, CoreCtorSpec{"Array.get", 61}, CoreCtorSpec{"Array.get_unchecked", 61}, CoreCtorSpec{"Array.set", 62}, CoreCtorSpec{"Array.set_unchecked", 62}, CoreCtorSpec{"Array.swap", 63}, CoreCtorSpec{"Array.size", 64}, CoreCtorSpec{"Array.clone", 65}, CoreCtorSpec{"U32.cmp", 66}, CoreCtorSpec{"U32.log2", 67}, CoreCtorSpec{"String.length", 67}, CoreCtorSpec{"String.eq", 67}, CoreCtorSpec{"String.is_empty", 67}, CoreCtorSpec{"String.starts_with", 67}, CoreCtorSpec{"Cmp.is_eq", 67},
   CoreCtorSpec{"F32.exp", 137}, CoreCtorSpec{"F32.log", 138}, CoreCtorSpec{"F32.log2", 139}, CoreCtorSpec{"F32.log10", 140}, CoreCtorSpec{"F32.sin", 141}, CoreCtorSpec{"F32.cos", 142}, CoreCtorSpec{"F32.tan", 143}, CoreCtorSpec{"F32.asin", 144}, CoreCtorSpec{"F32.acos", 145}, CoreCtorSpec{"F32.atan", 146}, CoreCtorSpec{"F32.sinh", 147}, CoreCtorSpec{"F32.cosh", 148}, CoreCtorSpec{"F32.tanh", 149}, CoreCtorSpec{"F32.floor", 150}, CoreCtorSpec{"F32.ceil", 151}, CoreCtorSpec{"F32.trunc", 152}, CoreCtorSpec{"F32.abs", 153}, CoreCtorSpec{"F32.pow", 154}, CoreCtorSpec{"F32.atan2", 155}, CoreCtorSpec{"F32.mod", 156}, CoreCtorSpec{"F32.show", 160}, CoreCtorSpec{"F32.read", 161}, CoreCtorSpec{"__nat_add", 162}, CoreCtorSpec{"Nat.add", 162}, CoreCtorSpec{"Nat.sub", 163}, CoreCtorSpec{"__nat_mul", 164},
   CoreCtorSpec{"Nat.mul", 164}, CoreCtorSpec{"Nat.double", 165}, CoreCtorSpec{"Nat.cmp", 166}, CoreCtorSpec{"Nat.is_lt", 167}, CoreCtorSpec{"Nat.divmod", 170}, CoreCtorSpec{"Array.atomic.add", 177}, CoreCtorSpec{"Array.atomic.min", 178}, CoreCtorSpec{"Array.atomic.max", 179}, CoreCtorSpec{"Array.atomic.and", 180}, CoreCtorSpec{"Array.atomic.or", 181}, CoreCtorSpec{"Array.atomic.xor", 182}, CoreCtorSpec{"Array.atomic.exch", 183}, CoreCtorSpec{"Array.atomic.cas", 184}, CoreCtorSpec{"Array.atomic.fadd", 185}, CoreCtorSpec{"F32.from_nat", 186}]
def low_kind_specs() -> List<&2, CoreCtorSpec>:
  [CoreCtorSpec{"False", 1}, CoreCtorSpec{"True", 2}, CoreCtorSpec{"Zero", 3}, CoreCtorSpec{"Succ", 4}, CoreCtorSpec{"Chr", 5}, CoreCtorSpec{"ALeaf", 8}, CoreCtorSpec{"ANode", 9}, CoreCtorSpec{"LT", 10}, CoreCtorSpec{"EQ", 11}, CoreCtorSpec{"GT", 12}, CoreCtorSpec{"Pair", 13}, CoreCtorSpec{"U32", 14}, CoreCtorSpec{"Nat", 15}, CoreCtorSpec{"F32", 16}, CoreCtorSpec{"Char", 17}, CoreCtorSpec{"Bool", 18}, CoreCtorSpec{"WNil", 19}, CoreCtorSpec{"WCon", 20}, CoreCtorSpec{"Word", 21}]
def low_is_scalar_type(+skind: U32Map, ty: Expr) -> Bool:
  +s1 = low_expr_sym1(ty)
  Bool.and(U32.is_ne(s1, 0), U32.is_ge(um_get(skind, U32.sub(s1, 1)), 14))
def low_maybe_sc_code(+skind: U32Map, mt: Maybe<&2, Expr>) -> U32:
  match mt:
    case None{}: 0
    case Some{EOp{5, a, b}}: U32.or(Bool.pick(U32, low_is_scalar_type(skind, a), 2, 0), Bool.pick(U32, low_is_scalar_type(skind, b), 4, 0))
    case Some{other}: Bool.to_u32(low_is_scalar_type(skind, other))
def low_param_mask_go(+is_e: Bool, +skind: U32Map, ps: List<&2, Param>, +idx: U32, acc: U32) -> U32:
  match ps:
    case Nil{}: acc
    case Con{Param{_, typ, erased, _}, t}:
      hit = Bool.pick(Bool, is_e, erased, U32.is_eq(low_maybe_sc_code(skind, typ), 1))
      bit = Bool.pick(U32, Bool.and(hit, U32.is_lt(idx, 32)), U32.shln(1, U32.to_nat(idx)), 0)
      low_param_mask_go(is_e, skind, t, U32.add(idx, 1), U32.or(acc, bit))
type CtorTabAcc is Data:
  CtorTabAcc{syms: SymTab, next_cid: U32, by_sym: U32Map, smask_by_sym: U32Map, single_by_sym: U32Map, arity_by_sym: U32Map, owner_by_sym: U32Map, ctors_rev: List<&2, IrCtor>}
def low_seed_core_one(sr: SymRes, +nm: String, +ar: U32, +cid: U32, by_sym: U32Map, smask: U32Map, +single: U32Map, arity: U32Map, owner: U32Map, rev: List<&2, IrCtor>) -> CtorTabAcc:
  SymRes{s2, +sym} = sr
  is_s = Bool.or(b5k_str_eq(nm, "Tuple"), Bool.or(b5k_str_eq(nm, "Pair"), b5k_str_eq(nm, "Unit")))
  CtorTabAcc{s2, U32.add(cid, 1), um_set(by_sym, sym, U32.add(cid, 1)), smask, Bool.pick(U32Map, is_s, um_set(single, sym, 1), single), um_set(arity, sym, U32.add(ar, 1)), owner, Con{IrCtor{cid, nm, ar, False{}}, rev}}
def low_seed_core(specs: List<&2, CoreCtorSpec>, acc: CtorTabAcc) -> CtorTabAcc:
  match specs acc:
    case Nil{} _: acc
    case Con{CoreCtorSpec{+nm, ar}, t} CtorTabAcc{syms, cid, by_sym, smask, single, arity, owner, rev}: low_seed_core(t, low_seed_core_one(symtab_intern(syms, nm), nm, ar, cid, by_sym, smask, single, arity, owner, rev))
def low_add_ctors(+skind: U32Map, +tsym: U32, cs: List<&2, CtorDef>, acc: CtorTabAcc) -> CtorTabAcc:
  match cs acc:
    case Nil{} a: a
    case Con{CtorDef{+sym, _, +fields}, t} CtorTabAcc{+syms, +cid, +by_sym, +smask, +single, +arity, +owner, +rev}: (sm = low_param_mask_go(False{}, skind, fields, 0, 0); +far = b5k_list_len(Param, fields); low_add_ctors(skind, tsym, t, Bool.pick(CtorTabAcc, U32.is_ne(um_get(by_sym, sym), 0), CtorTabAcc{syms, cid, by_sym, smask, single, arity, um_set(owner, sym, U32.add(tsym, 1)), rev}, CtorTabAcc{syms, U32.add(cid, 1), um_set(by_sym, sym, U32.add(cid, 1)), um_set(smask, sym, sm), single, um_set(arity, sym, U32.add(far, 1)), um_set(owner, sym, U32.add(tsym, 1)), Con{IrCtor{cid, symtab_name(syms, sym), far, False{}}, rev}})))
def low_mark_single(sym: U32, acc: CtorTabAcc) -> CtorTabAcc:
  CtorTabAcc{syms, cid, by_sym, smask, single, arity, owner, rev} = acc
  CtorTabAcc{syms, cid, by_sym, smask, um_set(single, sym, 1), arity, owner, rev}
def low_add_types(+skind: U32Map, ts: List<&2, TypeDef>, acc: CtorTabAcc) -> CtorTabAcc:
  match ts:
    case Nil{}: acc
    case Con{TypeDef{tsym, _, _, Con{CtorDef{+csym, cid, fs}, Nil{}}}, t}: low_add_types(skind, t, low_mark_single(csym, low_add_ctors(skind, tsym, [CtorDef{csym, cid, fs}], acc)))
    case Con{TypeDef{tsym, _, _, cs}, t}: low_add_types(skind, t, low_add_ctors(skind, tsym, cs, acc))
def low_param_arity_go(ps: List<&2, Param>, acc: U32) -> U32:
  match ps:
    case Nil{}: acc
    case Con{Param{_, _, erased, _}, t}: low_param_arity_go(t, U32.add(acc, Bool.pick(U32, erased, 0, 1)))
type LowEnv is Data:
  LowEnv{syms: SymTab, ctor_by_sym: U32Map, ctor_smask: U32Map, ctor_single: U32Map, ctor_arity: U32Map, ctor_owner: U32Map, fn_by_sym: U32Map, fn_arity: U32Map, fn_emask: U32Map, sym_intr: U32Map, sym_kind: U32Map, main_fid: U32, main_pure: Bool, sym_io_bind: U32, sym_io_pure: U32, sym_str_app: U32, sym_tmp: U32, sym_arr_len: U32}
def env_syms(e: LowEnv) -> SymTab:
  LowEnv{s, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _} = e
  s
def env_map(e: LowEnv, which: U32) -> U32Map:
  LowEnv{_, ct, cm, cs, ca, co, fn, ar, em, ir, kd, _, _, _, _, _, _, _} = e
  match which:
    case 0: ct
    case 1: cs
    case 2: fn
    case 3: ar
    case 4: em
    case 5: ir
    case 6: kd
    case 8: ca
    case 9: co
    case _: cm
def env_sym(e: LowEnv, is_arr: Bool) -> U32:
  LowEnv{_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, tmp, al} = e
  Bool.pick(U32, is_arr, al, tmp)
def env_str_app(e: LowEnv) -> U32:
  LowEnv{_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, sa, _, _} = e
  sa
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
def low_expr_kids(e: Expr) -> List<&2, Expr>:
  match e:
    case EApp{f, args}: Con{f, args}
    case ECtr{_, fs}: fs
    case EAnn{v, _}: [v]
    case EArrNew{es}: es
    case EArrGet{a, i}: [a, i]
    case EArrSet{a, i, v}: [a, i, v]
    case EOp{_, a, b}: [a, b]
    case EUnOp{_, a}: [a]
    case EPair{a, b}: [a, b]
    case EList{es}: es
    case _: Nil{}
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
    case Succ{p} UIExpr{ELam{ps, body}}: Bool.pick(U32, params_bind(sym, ps), 0, count_uses_go(p, sym, UIExpr{body}))
    case Succ{+p} UIExpr{ELet{pat, v, body}}: U32.add(count_uses_go(p, sym, UIExpr{v}), Bool.pick(U32, pat_binds_all(64n, sym, Con{pat, Nil{}}), 0, count_uses_go(p, sym, UIExpr{body})))
    case Succ{+p} UIExpr{EMat{scruts, cs}}: U32.add(count_uses_go(p, sym, UIExprs{scruts}), count_uses_go(p, sym, UICases{cs}))
    case Succ{+p} UIExpr{EIf{c, t, f}}: U32.add(count_uses_go(p, sym, UIExpr{c}), U32.max(count_uses_go(p, sym, UIExpr{t}), count_uses_go(p, sym, UIExpr{f})))
    case Succ{p} UIExpr{EDo{ss}}: count_uses_go(p, sym, UIStmts{ss})
    case Succ{p} UIExpr{other}: count_uses_go(p, sym, UIExprs{low_expr_kids(other)})
def low_is_ty_univ(+syms: SymTab, e: Expr) -> Bool:
  match e:
    case EVar{s}:
      +nm = symtab_name(syms, s)
      Bool.or(Bool.or(b5k_str_eq(nm, "Type"), b5k_str_eq(nm, "Data")),
              Bool.or(b5k_str_eq(nm, "Kind"), Bool.or(b5k_str_eq(nm, "Quant"), b5k_str_eq(nm, "Set"))))
    case EAll{_, body}: low_is_ty_univ(syms, body)
    case _: False{}
def low_param_is_erased(syms: SymTab, body: Expr, p: Param) -> Bool:
  match p:
    case Param{_, _, False{}, _}: False{}
    case Param{sym, Some{e}, True{}, _}: Bool.or(low_is_ty_univ(syms, e), U32.is_zero(count_uses_go(U32.to_nat(2048), sym, UIExpr{body})))
    case Param{sym, None{}, True{}, _}: U32.is_zero(count_uses_go(U32.to_nat(2048), sym, UIExpr{body}))
def low_param_arity_live(+syms: SymTab, +body: Expr, ps: List<&2, Param>, acc: U32) -> U32: opt_foldl2(~Param, ~SymTab, ~Expr, ~U32, ~(s => b => p => a => U32.add(a, Bool.pick(U32, low_param_is_erased(s, b, p), 0, 1))), syms, body, ps, acc)
def low_param_emask_live(+syms: SymTab, +body: Expr, ps: List<&2, Param>, +idx: U32, acc: U32) -> U32:
  match ps:
    case Nil{}: acc
    case Con{p, t}: (bit = Bool.pick(U32, Bool.and(low_param_is_erased(syms, body, p), U32.is_lt(idx, 32)), U32.shln(1, U32.to_nat(idx)), 0); low_param_emask_live(syms, body, t, U32.add(idx, 1), U32.or(acc, bit)))
type FnTabAcc is Data:
  FnTabAcc{next_fid: U32, by_sym: U32Map, arity: U32Map, emask: U32Map, main_fid: U32, main_sym: U32}
def low_add_defs(+syms: SymTab, ds: List<&2, Def>, acc: FnTabAcc) -> FnTabAcc:
  match ds acc:
    case Nil{} _: acc
    case Con{Def{+sym, +params, _, +body, _, _}, t} FnTabAcc{+fid, by_sym, arity, emask, main_fid, main_sym}: (+is_m = b5k_str_eq(symtab_name(syms, sym), "main"); low_add_defs(syms, t, FnTabAcc{U32.add(fid, 1), um_set(by_sym, sym, U32.add(fid, 1)), um_set(arity, fid, U32.add(low_param_arity_live(syms, body, params, 0), 1)), um_set(emask, fid, low_param_emask_live(syms, body, params, 0, 0)), Bool.pick(U32, is_m, fid, main_fid), Bool.pick(U32, is_m, sym, main_sym)}))
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
    case Succ{_} UIExpr{EVar{+s}}: (+a0 = acc; Bool.pick(List<&2, U32>, Bool.and(U32.is_ne(um_get(vmap, s), 0), Bool.and(U32.is_zero(um_get(bnd, s)), Bool.not(b5k_chk_u32_mem(a0, s)))), Con{s, a0}, a0))
    case Succ{p} UIExpr{ELam{ps, body}}: fv_go(p, vmap, fv_add_params(ps, bnd), UIExpr{body}, acc)
    case Succ{+p} UIExpr{ELet{pat, v, body}}: fv_go(p, vmap, fv_add_pat(32n, [pat], bnd), UIExpr{body}, fv_go(p, vmap, bnd, UIExpr{v}, acc))
    case Succ{+p} UIExpr{EMat{sc, cs}}: fv_go(p, vmap, bnd, UICases{cs}, fv_go(p, vmap, bnd, UIExprs{sc}, acc))
    case Succ{p} UIExpr{EIf{c, t, f}}: fv_go(p, vmap, bnd, UIExprs{[c, t, f]}, acc)
    case Succ{p} UIExpr{EDo{ss}}: fv_go(p, vmap, bnd, UIStmts{ss}, acc)
    case Succ{p} UIExpr{other}: fv_go(p, vmap, bnd, UIExprs{low_expr_kids(other)}, acc)
# Closure Registry & CFG Builder State
type CloEntry is Data:
  CloEntry{cid: U32, fid: U32, ncaps: U32}
type CloBank is Data:
  CloBank{next_fid: U32, next_cid: U32, ctors_rev: List<&2, IrCtor>, fns_rev: List<&2, IrFn>, entries_rev: List<&2, CloEntry>, next_stat: U32, stats_rev: List<&2, U32>, str_map: Map<&2, U32>}
type CfgSt is Data:
  CfgSt{cur_fid: U32, next_reg: U32, next_blk: U32, cur_blk: U32, cur_ops: List<&2, IrOp>, blocks: List<&2, IrBlock>, sealed: Bool, res: U32, rlist: List<&2, U32>, vmap: U32Map, nvm: U32Map, merged: Bool, bank: CloBank}
def cfg_new(fid: U32, nparams: U32, bank: CloBank) -> CfgSt: CfgSt{fid, nparams, 1, 0, Nil{}, Nil{}, False{}, 0, Nil{}, UM0{}, UM0{}, False{}, bank}
def cfg_res(st: CfgSt) -> U32:
  CfgSt{_, _, _, _, _, _, _, r, _, _, _, _, _} = st
  r
def cfg_rlist(st: CfgSt) -> List<&2, U32>:
  CfgSt{_, _, _, _, _, _, _, _, rl, _, _, _, _} = st
  rl
def cfg_map(st: CfgSt, is_nvm: Bool) -> U32Map:
  CfgSt{_, _, _, _, _, _, _, _, _, vm, nvm, _, _} = st
  Bool.pick(U32Map, is_nvm, nvm, vm)
def cfg_flag(st: CfgSt, is_mg: Bool) -> Bool:
  CfgSt{_, _, _, _, _, _, s, _, _, _, _, m, _} = st
  Bool.pick(Bool, is_mg, m, s)
def cfg_bank(st: CfgSt) -> CloBank:
  CfgSt{_, _, _, _, _, _, _, _, _, _, _, _, bk} = st
  bk
def cfg_set_res(st: CfgSt, r: U32) -> CfgSt:
  CfgSt{f, nr, nb, cb, ops, blks, s, _, rl, vm, nvm, mg, bk} = st
  CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, nvm, mg, bk}
def cfg_set_rlist(st: CfgSt, rl: List<&2, U32>) -> CfgSt:
  CfgSt{f, nr, nb, cb, ops, blks, s, r, _, vm, nvm, mg, bk} = st
  CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, nvm, mg, bk}
def cfg_set_vm_nvm(st: CfgSt, vm: U32Map, nvm: U32Map) -> CfgSt:
  CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, _, _, mg, bk} = st
  CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, nvm, mg, bk}
def cfg_set_merged(st: CfgSt, mg: Bool) -> CfgSt:
  CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, nvm, _, bk} = st
  CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, nvm, mg, bk}
def cfg_set_bank(st: CfgSt, bk: CloBank) -> CfgSt:
  CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, nvm, mg, _} = st
  CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, nvm, mg, bk}
def cfg_alloc(st: CfgSt, +is_blk: Bool) -> CfgSt:
  CfgSt{f, +nr, +nb, cb, ops, blks, s, _, rl, vm, nvm, mg, bk} = st
  CfgSt{f, Bool.pick(U32, is_blk, nr, U32.add(nr, 1)), Bool.pick(U32, is_blk, U32.add(nb, 1), nb), cb, ops, blks, s, Bool.pick(U32, is_blk, nb, nr), rl, vm, nvm, mg, bk}
def cfg_emit(st: CfgSt, op: IrOp) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, cb, ops, blks, False{}, r, rl, vm, nvm, mg, bk}: CfgSt{f, nr, nb, cb, Con{op, ops}, blks, False{}, r, rl, vm, nvm, mg, bk}
    case s: s
def cfg_seal(st: CfgSt, term: IrTerm) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, +cb, ops, blks, False{}, r, rl, vm, nvm, mg, bk}: CfgSt{f, nr, nb, cb, Nil{}, Con{IrBlock{cb, b5k_list_rev(IrOp, ops), term}, blks}, True{}, r, rl, vm, nvm, mg, bk}
    case s: s
def cfg_start(st: CfgSt, blk_id: U32) -> CfgSt:
  CfgSt{f, nr, nb, _, _, blks, _, r, rl, vm, nvm, mg, bk} = st
  CfgSt{f, nr, nb, blk_id, Nil{}, blks, False{}, r, rl, vm, nvm, mg, bk}
def cfg_end_merge(+st: CfgSt, base_vm: U32Map, base_nvm: U32Map, blk: U32, res_reg: U32) -> CfgSt: cfg_set_res(cfg_set_vm_nvm(Bool.pick(CfgSt, cfg_flag(st, True{}), cfg_start(st, blk), st), base_vm, base_nvm), res_reg)
def cfg_fin_branch(st: CfgSt, sld: Bool, res_reg: U32, v: U32, merge_blk: U32, prev_mg: Bool) -> CfgSt:
  match sld:
    case True{}: cfg_set_merged(st, prev_mg)
    case False{}: cfg_set_merged(cfg_seal(cfg_emit(st, ICopy{res_reg, v}), TJmp{merge_blk}), True{})
def cfg_emit_keeps_go(k: Nat, st: CfgSt, +v: U32) -> CfgSt:
  match k:
    case 0n: st
    case 1n+p: cfg_emit_keeps_go(p, cfg_emit(st, IKeep{v, v}), v)
# Intrinsics (U32.*, F32.*, IO.*) — O(1) via precomputed sym_intr U32Map
def low_um_le(m: U32Map, sym: U32, lim: U32) -> U32:
  +raw = um_get(m, sym)
  Bool.pick(U32, U32.is_le(raw, lim), raw, 0)
def low_intr_code(sintr: U32Map, sym: U32) -> U32:
  +raw = um_get(sintr, sym)
  Bool.pick(U32, Bool.or(U32.is_le(raw, 65), U32.is_ge(raw, 100)), raw, 0)
def low_special_ctor_kind(skind: U32Map, sym: U32) -> U32: low_um_le(skind, sym, 9)
def low_emit_u32(st: CfgSt, is_stat: Bool, +v: U32) -> CfgSt:
  +st1 = cfg_alloc(st, False{})
  cfg_emit(st1, Bool.pick(IrOp, is_stat, IStatic{cfg_res(st1), v}, IConst{cfg_res(st1), v}))
def low_emit_const(st: CfgSt, v: U32) -> CfgSt: low_emit_u32(st, False{}, v)
def low_emit_list(st: CfgSt, is_arr: Bool, +code: U32, +args: List<&2, U32>) -> CfgSt:
  +st1 = cfg_alloc(st, False{})
  cfg_emit(st1, Bool.pick(IrOp, is_arr, IArrOp{[cfg_res(st1)], code, args}, ICtor{cfg_res(st1), code, args}))
def low_emit_ctor(st: CfgSt, cid: U32, fs: List<&2, U32>) -> CfgSt: low_emit_list(st, False{}, cid, fs)
def low_emit_arr_one(st: CfgSt, aop: U32, args: List<&2, U32>) -> CfgSt: low_emit_list(st, True{}, aop, args)
def low_emit_bin_or_cmp(st: CfgSt, is_cmp: Bool, +op: U32, +va: U32, +vb: U32) -> CfgSt:
  +st1 = cfg_alloc(st, False{})
  cfg_emit(st1, Bool.pick(IrOp, is_cmp, ICmp{cfg_res(st1), op, va, vb}, IBin{cfg_res(st1), op, va, vb}))
def low_emit_un(st: CfgSt, uop: U32, va: U32) -> CfgSt:
  +st1 = cfg_alloc(st, False{})
  cfg_emit(st1, IUn{cfg_res(st1), uop, va})
def low_emit_cond_bin(st: CfgSt, cond: U32, bop: U32, va: U32, vb: U32) -> CfgSt:
  +st1 = cfg_alloc(st, True{})
  +st2 = cfg_alloc(st1, True{})
  +st3 = cfg_alloc(st2, True{})
  +st4 = cfg_alloc(st3, False{})
  +s2 = cfg_alloc(cfg_start(cfg_seal(cfg_emit(cfg_start(cfg_seal(st4, TBr{cond, cfg_res(st1), cfg_res(st2)}), cfg_res(st1)), IConst{cfg_res(st4), 0}), TJmp{cfg_res(st3)}), cfg_res(st2)), False{})
  cfg_set_res(cfg_start(cfg_seal(cfg_emit(cfg_emit(s2, IBin{cfg_res(s2), bop, va, vb}), ICopy{cfg_res(st4), cfg_res(s2)}), TJmp{cfg_res(st3)}), cfg_res(st3)), cfg_res(st4))
def low_emit_safe_shift(st: CfgSt, is_shr: Bool, +va: U32, +vb: U32) -> CfgSt:
  +st1 = low_emit_const(st, 32)
  +st2 = cfg_alloc(st1, False{})
  low_emit_cond_bin(cfg_emit(st2, ICmp{cfg_res(st2), B5K_CMP_GE(), vb, cfg_res(st1)}), cfg_res(st2), Bool.pick(U32, is_shr, B5K_OP_SHR(), B5K_OP_SHL()), va, vb)
def low_emit_io_eff(st: CfgSt, cid: U32, pre: List<&2, U32>, k: U32) -> CfgSt:
  +st1 = cfg_alloc(st, False{})
  low_emit_ctor(cfg_emit(st1, ICallClosure{cfg_res(st1), 2, [k]}), cid, b5k_list_app(U32, pre, [cfg_res(st1)]))
def low_emit_arr_pair(st: CfgSt, aop: U32, args: List<&2, U32>) -> CfgSt:
  +st1 = cfg_alloc(st, False{})
  +st2 = cfg_alloc(st1, False{})
  +st3 = cfg_alloc(cfg_emit(st2, IArrOp{[cfg_res(st1), cfg_res(st2)], aop, args}), False{})
  cfg_emit(st3, ICtor{cfg_res(st3), 6, [cfg_res(st1), cfg_res(st2)]})
def low_emit_minmax(st: CfgSt, cop: U32, +va: U32, +vb: U32) -> CfgSt:
  +st1 = cfg_alloc(st, False{})
  +st2 = cfg_alloc(cfg_emit(st1, ICmp{cfg_res(st1), cop, va, vb}), True{})
  +st3 = cfg_alloc(st2, True{})
  +st4 = cfg_alloc(st3, True{})
  +st5 = cfg_alloc(st4, False{})
  s1 = cfg_seal(cfg_emit(cfg_start(cfg_seal(st5, TBr{cfg_res(st1), cfg_res(st2), cfg_res(st3)}), cfg_res(st2)), ICopy{cfg_res(st5), va}), TJmp{cfg_res(st4)})
  cfg_set_res(cfg_start(cfg_seal(cfg_emit(cfg_start(s1, cfg_res(st3)), ICopy{cfg_res(st5), vb}), TJmp{cfg_res(st4)}), cfg_res(st4)), cfg_res(st5))
def low_emit_arr_get_pair(st: CfgSt, +va: U32, vb: U32) -> CfgSt:
  +st1 = low_emit_arr_one(st, 78, [va, vb])
  low_emit_ctor(st1, 6, [va, cfg_res(st1)])
def low_emit_u32_intr_go(st: CfgSt, +code: U32, vargs: List<&2, U32>) -> CfgSt:
  match code vargs:
    case 62 Con{va, Con{vb, Con{vc, Nil{}}}}: low_emit_arr_one(st, 73, [va, vb, vc])
    case 63 Con{va, Con{vb, Con{vc, Nil{}}}}: low_emit_arr_pair(st, 74, [va, vb, vc])
    case 68 Con{va, Con{vb, Con{vc, Nil{}}}}: low_emit_arr_one(st, 79, [va, vb, vc])
    case _ Con{va, Con{vb, Con{vc, Nil{}}}}: (+st0 = st; Bool.pick(CfgSt, Bool.and(U32.is_ge(code, 35), U32.is_le(code, 39)), low_emit_io_eff(st0, U32.sub(code, 3), [va, vb], vc), low_emit_const(st0, 0)))
    case 17 Con{+va, Con{+vb, Nil{}}}: low_emit_minmax(st, B5K_CMP_LT(), va, vb)
    case 18 Con{+va, Con{+vb, Nil{}}}: low_emit_minmax(st, B5K_CMP_GT(), va, vb)
    case 24 Con{+va, Con{+vb, Nil{}}}: low_emit_safe_shift(st, False{}, va, vb)
    case 25 Con{+va, Con{+vb, Nil{}}}: low_emit_safe_shift(st, True{}, va, vb)
    case 28 Con{+va, Con{+vb, Nil{}}}: low_emit_bin_or_cmp(st, False{}, B5K_OP_SHL(), va, vb)
    case 29 Con{+va, Con{+vb, Nil{}}}: low_emit_bin_or_cmp(st, False{}, B5K_OP_SHR(), va, vb)
    case 30 Con{+va, Con{+vb, Nil{}}}: (+st1 = cfg_alloc(st, False{}); low_emit_cond_bin(cfg_emit(st1, ICmp{cfg_res(st1), B5K_CMP_LT(), va, vb}), cfg_res(st1), B5K_OP_SUB(), va, vb))
    case 54 Con{va, Con{vb, Nil{}}}: low_emit_io_eff(st, 37, [va], vb)
    case 60 Con{va, Con{vb, Nil{}}}: low_emit_arr_one(st, 71, [va, vb])
    case 61 Con{+va, Con{vb, Nil{}}}: low_emit_arr_get_pair(st, va, vb)
    case _ Con{+va, Con{+vb, Nil{}}}:
      +st0 = st
      +is_flt = U32.is_ge(code, 40)
      +is_cmp = Bool.pick(Bool, is_flt, U32.is_ge(code, 44), U32.is_gt(code, 10))
      sub_k = Bool.pick(U32, is_flt, Bool.pick(U32, is_cmp, 38, 30), Bool.pick(U32, is_cmp, 11, 1))
      Bool.pick(CfgSt, Bool.or(U32.is_eq(code, 31), Bool.or(U32.is_eq(code, 32), U32.is_eq(code, 37))), low_emit_io_eff(st0, U32.sub(code, 3), [va], vb), low_emit_bin_or_cmp(st0, is_cmp, U32.sub(code, sub_k), va, vb))
    case 26 Con{va, Nil{}}: low_emit_un(st, 1, va)
    case 27 Con{va, Nil{}}: cfg_set_res(st, va)
    case 33 Con{va, Nil{}}: low_emit_io_eff(st, 30, Nil{}, va)
    case 34 Con{va, Nil{}}: low_emit_io_eff(st, 31, Nil{}, va)
    case 64 Con{va, Nil{}}: low_emit_arr_pair(st, 75, [va])
    case 65 Con{va, Nil{}}: low_emit_arr_pair(st, 76, [va])
    case _ Con{+va, Nil{}}:
      +st0 = st
      +is_z = U32.is_eq(code, 21)
      +st1 = low_emit_const(st0, Bool.pick(U32, is_z, 0, 1))
      op = Bool.pick(U32, U32.is_eq(code, 19), B5K_OP_ADD(), Bool.pick(U32, U32.is_eq(code, 20), B5K_OP_SUB(), Bool.pick(U32, U32.is_eq(code, 22), B5K_OP_SHL(), Bool.pick(U32, U32.is_eq(code, 23), B5K_OP_SHR(), B5K_CMP_EQ()))))
      Bool.pick(CfgSt, Bool.and(U32.is_ge(code, 50), U32.is_le(code, 53)), low_emit_un(st0, U32.sub(code, 48), va), low_emit_bin_or_cmp(st1, is_z, op, va, cfg_res(st1)))
    case _ _: low_emit_const(st, 0)
def low_if(-A: Data, c: Bool, t: U32 -> A, f: U32 -> A) -> A:
  match c:
    case True{}: t(0)
    case False{}: f(0)
def low_emit_u32_intr(+st: CfgSt, +code: U32, +vargs: List<&2, U32>) -> CfgSt:
  low_if(CfgSt, U32.is_ge(code, 100), _ => low_emit_arr_one(st, code, vargs), _ => low_emit_u32_intr_go(st, code, vargs))
# Sequential Pattern Matching & Lowering Helpers
def low_alloc_regs_go(n: Nat, st: CfgSt, acc: List<&2, U32>) -> CfgSt:
  match n:
    case 0n: cfg_set_rlist(st, b5k_list_rev(U32, acc))
    case 1n+p: (+st1 = cfg_alloc(st, False{}); low_alloc_regs_go(p, st1, Con{cfg_res(st1), acc}))
def pat_is_refut(fuel: Nat, ps: List<&2, Pat>) -> Bool:
  match fuel ps:
    case 0n _: False{}
    case _ Nil{}: False{}
    case 1n+p Con{PWild{}, t}: pat_is_refut(p, t)
    case 1n+p Con{PVar{_, _}, t}: pat_is_refut(p, t)
    case 1n+p Con{PPair{a, b}, t}: pat_is_refut(p, Con{a, Con{b, t}})
    case 1n+_ Con{_, _}: True{}
def low_test_cmp_const(st: CfgSt, cop: U32, r: U32, val: U32, fail_blk: U32) -> CfgSt:
  +st1 = cfg_alloc(st, False{})
  +st2 = cfg_alloc(cfg_emit(st1, IConst{cfg_res(st1), val}), False{})
  +st3 = cfg_alloc(cfg_emit(st2, ICmp{cfg_res(st2), cop, r, cfg_res(st1)}), True{})
  cfg_start(cfg_seal(st3, TBr{cfg_res(st2), cfg_res(st3), fail_blk}), cfg_res(st3))
def low_maybe_keep(+st: CfgSt, need: Bool, +r: U32) -> CfgSt: cfg_set_res(Bool.pick(CfgSt, need, cfg_emit(st, IKeep{r, r}), st), r)
def low_mask_scs(n: Nat, +smask: U32, +idx: U32) -> List<&2, U32>:
  match n:
    case 0n: Nil{}
    case 1n+p: (sc = Bool.to_u32(Bool.and(U32.is_lt(idx, 32), U32.is_ne(U32.and(U32.shrn(smask, U32.to_nat(idx)), 1), 0))); Con{sc, low_mask_scs(p, smask, U32.add(idx, 1))})
type PatStep is Data:
  PSNext{st: CfgSt, ps: List<&2, Pat>, regs: List<&2, U32>, scs: List<&2, U32>, trs: List<&2, U32>}
def low_test_bool(st: CfgSt, expect_true: Bool, +r: U32, +fail_blk: U32) -> CfgSt:
  +st1 = cfg_alloc(st, True{})
  +ok_blk = cfg_res(st1)
  cfg_start(cfg_seal(st1, Bool.pick(IrTerm, expect_true, TBr{r, ok_blk, fail_blk}, TBr{r, fail_blk, ok_blk})), ok_blk)
def low_opt_test_bool(hf: Bool, expect_true: Bool, +st: CfgSt, r: U32, fb: U32) -> CfgSt: Bool.pick(CfgSt, hf, low_test_bool(st, expect_true, r, fb), st)
def low_opt_test_eq(hf: Bool, +st: CfgSt, r: U32, val: U32, fb: U32) -> CfgSt: Bool.pick(CfgSt, hf, low_test_cmp_const(st, B5K_CMP_EQ(), r, val, fb), st)
def low_opt_test_tag(hf: Bool, st: CfgSt, r: U32, tr: U32, cid: U32, fb: U32) -> CfgSt:
  match hf tr:
    case False{} _: st
    case True{} 0: (+st1 = cfg_alloc(st, False{}); low_test_cmp_const(cfg_emit(st1, ITag{cfg_res(st1), r}), B5K_CMP_EQ(), cfg_res(st1), cid, fb))
    case True{} t1: low_test_cmp_const(st, B5K_CMP_EQ(), U32.sub(t1, 1), cid, fb)
def low_opt_rc(skip: Bool, st: CfgSt, +r: U32, uses: U32) -> CfgSt:
  match skip uses:
    case True{} _: st
    case False{} 0: cfg_emit(st, ISink{r})
    case False{} 1: st
    case False{} n: cfg_emit_keeps_go(U32.to_nat(U32.sub(n, 1)), st, r)
type NatPat is Data:
  NPConst{k: U32}
  NPSub{k: U32, inner: Pat}
def low_peel_nat(fuel: Nat, +skind: U32Map, +k: U32, p: Pat) -> NatPat:
  match fuel p:
    case 0n other: NPSub{k, other}
    case 1n+_ PNum{v}: NPConst{U32.add(k, v)}
    case 1n+_ PCtr{+sym, Nil{}}: Bool.pick(NatPat, U32.is_eq(low_special_ctor_kind(skind, sym), 3), NPConst{k}, NPSub{k, PCtr{sym, Nil{}}})
    case 1n+f PCtr{+sym, Con{+inner, Nil{}}}: Bool.pick(NatPat, U32.is_eq(low_special_ctor_kind(skind, sym), 4), low_peel_nat(f, skind, U32.add(k, 1), inner), NPSub{k, PCtr{sym, [inner]}})
    case 1n+_ other: NPSub{k, other}
def low_pat_is_dead_var(p: Pat, body: Expr) -> Bool:
  match p:
    case PWild{}: True{}
    case PVar{s, _}: U32.is_zero(count_uses_go(U32.to_nat(2048), s, UIExpr{body}))
    case _: False{}
def low_pat_nat_succ(np: NatPat, st: CfgSt, +pt: List<&2, Pat>, +r: U32, +rt: List<&2, U32>, +st_tail: List<&2, U32>, +tr_tail: List<&2, U32>, body: Expr, +fail_blk: U32, has_fail: Bool) -> PatStep:
  match np:
    case NPConst{k}: PSNext{low_opt_test_eq(has_fail, st, r, k, fail_blk), pt, rt, st_tail, tr_tail}
    case NPSub{+k, +rem}:
      +st0 = st
      +st1 = Bool.pick(CfgSt, has_fail, Bool.pick(CfgSt, U32.is_eq(k, 1), low_test_bool(st0, True{}, r, fail_blk), low_test_cmp_const(st0, B5K_CMP_GE(), r, k, fail_blk)), st0)
      +st2 = cfg_alloc(st1, False{})
      +st3 = cfg_alloc(cfg_emit(st2, IConst{cfg_res(st2), k}), False{})
      Bool.pick(PatStep, low_pat_is_dead_var(rem, body), PSNext{st1, pt, rt, st_tail, tr_tail}, PSNext{cfg_emit(st3, IBin{cfg_res(st3), B5K_OP_SUB(), r, cfg_res(st2)}), Con{rem, pt}, Con{cfg_res(st3), rt}, Con{1, st_tail}, Con{0, tr_tail}})
def low_pat_arr_test(hf: Bool, +kind: U32, st: CfgSt, +r: U32, fb: U32) -> CfgSt:
  match hf:
    case False{}: st
    case True{}: (+st1 = low_emit_arr_one(st, U32.add(200, kind), [r]); low_test_bool(st1, True{}, cfg_res(st1), fb))
def low_pat_is_arr(+skind: U32Map, p: Pat) -> Bool:
  match p:
    case PCtr{sym, _}: (+k = um_get(skind, sym); Bool.or(U32.is_eq(k, 8), U32.is_eq(k, 9)))
    case _: False{}
def low_pat_arr_defer(skind: U32Map, has_fail: Bool, pt: List<&2, Pat>) -> Bool:
  match has_fail pt:
    case True{} Con{+p1, t1}: Bool.and(Bool.not(low_pat_is_arr(skind, p1)), pat_is_refut(16n, Con{p1, t1}))
    case _ _: False{}
def low_pat_arr_step(+kind: U32, +env: LowEnv, +st: CfgSt, +sym: U32, +fs1: List<&2, Pat>, +pt: List<&2, Pat>, +r: U32, +rt: List<&2, U32>, +sc0: U32, +st_tail: List<&2, U32>, +tr0: U32, +tr_tail: List<&2, U32>, +fail_blk: U32, +has_fail: Bool) -> PatStep:
  low_if(PatStep, low_pat_arr_defer(env_map(env, 6), has_fail, pt),
    _ => PSNext{st, b5k_list_app(Pat, pt, [PCtr{sym, fs1}]), b5k_list_app(U32, rt, [r]), b5k_list_app(U32, st_tail, [sc0]), b5k_list_app(U32, tr_tail, [tr0])},
    _ => (+nf = Bool.pick(U32, U32.is_eq(kind, 8), 1, 2); +stK = low_maybe_keep(low_pat_arr_test(has_fail, kind, st, r, fail_blk), Bool.and(has_fail, Bool.or(pat_is_refut(16n, fs1), pat_is_refut(16n, pt))), r); +st2 = low_alloc_regs_go(U32.to_nat(nf), stK, Nil{}); +fregs = cfg_rlist(st2); PSNext{cfg_emit(st2, IArrOp{fregs, U32.add(210, kind), [cfg_res(stK)]}), b5k_list_app(Pat, fs1, pt), b5k_list_app(U32, fregs, rt), b5k_list_app(U32, low_mask_scs(U32.to_nat(nf), 0, 0), st_tail), b5k_list_app(U32, low_mask_scs(U32.to_nat(nf), 0, 0), tr_tail)}))
def low_pat_ctr_step(kind: U32, +env: LowEnv, st: CfgSt, +sym: U32, +fs: List<&2, Pat>, +pt: List<&2, Pat>, +r: U32, rt: List<&2, U32>, +sc0: U32, st_tail: List<&2, U32>, tr0: U32, tr_tail: List<&2, U32>, body: Expr, +fail_blk: U32, +has_fail: Bool) -> PatStep:
  match kind fs:
    case 4 Con{inner, Nil{}}: low_pat_nat_succ(low_peel_nat(32n, env_map(env, 6), 1, inner), st, pt, r, rt, st_tail, tr_tail, body, fail_blk, has_fail)
    case 4 _:
      +st2 = cfg_alloc(low_opt_test_bool(has_fail, True{}, st, r, fail_blk), False{})
      +st3 = cfg_alloc(cfg_emit(st2, IConst{cfg_res(st2), 1}), False{})
      PSNext{cfg_emit(st3, IBin{cfg_res(st3), B5K_OP_SUB(), r, cfg_res(st2)}), b5k_list_app(Pat, fs, pt), Con{cfg_res(st3), rt}, Con{1, st_tail}, Con{0, tr_tail}}
    case 20 _:
      +st1 = low_emit_const(st, 1)
      +st2 = low_emit_bin_or_cmp(st1, False{}, B5K_OP_AND(), r, cfg_res(st1))
      +st3 = low_emit_bin_or_cmp(st2, False{}, B5K_OP_SHR(), r, cfg_res(st1))
      PSNext{st3, b5k_list_app(Pat, fs, pt), Con{cfg_res(st2), Con{cfg_res(st3), rt}}, Con{1, Con{1, st_tail}}, Con{0, Con{0, tr_tail}}}
    case 1 _: PSNext{low_opt_test_bool(has_fail, False{}, st, r, fail_blk), pt, rt, st_tail, tr_tail}
    case 2 _: PSNext{low_opt_test_bool(has_fail, True{}, st, r, fail_blk), pt, rt, st_tail, tr_tail}
    case 3 _: PSNext{low_opt_test_bool(has_fail, False{}, st, r, fail_blk), pt, rt, st_tail, tr_tail}
    case 5 fs0: PSNext{st, b5k_list_app(Pat, fs0, pt), Con{r, rt}, Con{1, st_tail}, Con{0, tr_tail}}
    case 14 fs0: PSNext{st, b5k_list_app(Pat, fs0, pt), Con{r, rt}, Con{1, st_tail}, Con{0, tr_tail}}
    case 16 fs0: PSNext{st, b5k_list_app(Pat, fs0, pt), Con{r, rt}, Con{1, st_tail}, Con{0, tr_tail}}
    case 19 _: PSNext{st, pt, rt, st_tail, tr_tail}
    case 8 fs0: low_pat_arr_step(8, env, st, sym, fs0, pt, r, rt, sc0, st_tail, tr0, tr_tail, fail_blk, has_fail)
    case 9 fs0: low_pat_arr_step(9, env, st, sym, fs0, pt, r, rt, sc0, st_tail, tr0, tr_tail, fail_blk, has_fail)
    case _ Nil{}: PSNext{low_opt_test_tag(Bool.and(has_fail, U32.is_zero(um_get(env_map(env, 1), sym))), st, r, tr0, um_get0(env_map(env, 0), sym), fail_blk), pt, rt, st_tail, tr_tail}
    case _ +fs0:
      +cid = um_get0(env_map(env, 0), sym)
      +nf = b5k_list_len(Pat, fs0)
      sm = Bool.pick(U32, U32.is_eq(cid, 6), U32.shrn(sc0, 1n), um_get(env_map(env, 7), sym))
      +stK = low_maybe_keep(low_opt_test_tag(Bool.and(has_fail, U32.is_zero(um_get(env_map(env, 1), sym))), st, r, tr0, cid, fail_blk), Bool.and(has_fail, Bool.or(pat_is_refut(16n, fs0), pat_is_refut(16n, pt))), r)
      +st2 = low_alloc_regs_go(U32.to_nat(nf), stK, Nil{})
      +fregs = cfg_rlist(st2)
      PSNext{cfg_emit(st2, ITake{fregs, cfg_res(stK)}), b5k_list_app(Pat, fs0, pt), b5k_list_app(U32, fregs, rt), b5k_list_app(U32, low_mask_scs(U32.to_nat(nf), sm, 0), st_tail), b5k_list_app(U32, low_mask_scs(U32.to_nat(nf), 0, 0), tr_tail)}
def low_take2(st: CfgSt, r: U32, ps: List<&2, Pat>, rt: List<&2, U32>, sc0: U32, sc1: U32, st_tail: List<&2, U32>, tr_tail: List<&2, U32>) -> PatStep:
  +st1 = cfg_alloc(st, False{})
  +st2 = cfg_alloc(st1, False{})
  PSNext{cfg_emit(st2, ITake{[cfg_res(st1), cfg_res(st2)], r}), ps, Con{cfg_res(st1), Con{cfg_res(st2), rt}}, Con{sc0, Con{sc1, st_tail}}, Con{0, Con{0, tr_tail}}}
def low_pat_one(+env: LowEnv, st: CfgSt, p0: Pat, pt: List<&2, Pat>, +r: U32, rt: List<&2, U32>, +sc0: U32, st_tail: List<&2, U32>, tr0: U32, tr_tail: List<&2, U32>, body: Expr, fail_blk: U32, +has_fail: Bool) -> PatStep:
  match p0:
    case PWild{}: (+st0 = st; PSNext{Bool.pick(CfgSt, Bool.or(has_fail, U32.is_eq(sc0, 1)), st0, cfg_emit(st0, ISink{r})), pt, rt, st_tail, tr_tail})
    case PVar{+sym, _}:
      +uses = count_uses_go(U32.to_nat(2048), sym, UIExpr{body})
      +st1 = low_opt_rc(Bool.or(U32.is_eq(sc0, 1), Bool.and(has_fail, U32.is_zero(uses))), st, r, uses)
      PSNext{cfg_set_vm_nvm(st1, um_set(cfg_map(st1, False{}), sym, U32.add(r, 1)), um_set(cfg_map(st1, True{}), sym, sc0)), pt, rt, st_tail, tr_tail}
    case PNum{v}: PSNext{low_opt_test_eq(has_fail, st, r, v, fail_blk), pt, rt, st_tail, tr_tail}
    case PChr{c}: PSNext{low_opt_test_eq(has_fail, st, r, c, fail_blk), pt, rt, st_tail, tr_tail}
    case PPair{+a, +b}: (+st0 = low_maybe_keep(st, Bool.and(has_fail, pat_is_refut(16n, [a, b])), r); low_take2(st0, cfg_res(st0), Con{a, Con{b, pt}}, rt, Bool.to_u32(U32.is_ne(U32.and(sc0, 2), 0)), Bool.to_u32(U32.is_ne(U32.and(sc0, 4), 0)), st_tail, tr_tail))
    case PList{Nil{}}: PSNext{low_opt_test_tag(has_fail, st, r, tr0, 4, fail_blk), pt, rt, st_tail, tr_tail}
    case PList{Con{h, tl}}: (+stK = low_maybe_keep(low_opt_test_tag(has_fail, st, r, tr0, 5, fail_blk), has_fail, r); low_take2(stK, cfg_res(stK), Con{h, Con{PList{tl}, pt}}, rt, 0, 0, st_tail, tr_tail))
    case PCtr{+sym, +fs}: low_pat_ctr_step(um_get(env_map(env, 6), sym), env, st, sym, fs, pt, r, rt, sc0, st_tail, tr0, tr_tail, body, fail_blk, has_fail)
def low_match_pats_go(fuel: Nat, +env: LowEnv, step: PatStep, +body: Expr, +fail_blk: U32, +has_fail: Bool) -> CfgSt:
  match fuel step:
    case 1n+p PSNext{st, Con{p0, pt}, Con{r, rt}, Con{sc0, st_tail}, Con{tr0, tr_tail}}: low_match_pats_go(p, env, low_pat_one(env, st, p0, pt, r, rt, sc0, st_tail, tr0, tr_tail, body, fail_blk, has_fail), body, fail_blk, has_fail)
    case _ PSNext{st, _, _, _, _}: st
def low_match_pats_sct(fuel: Nat, env: LowEnv, st: CfgSt, ps: List<&2, Pat>, regs: List<&2, U32>, scs: List<&2, U32>, trs: List<&2, U32>, body: Expr, fail_blk: U32, has_fail: Bool) -> CfgSt: low_match_pats_go(fuel, env, PSNext{st, ps, regs, scs, trs}, body, fail_blk, has_fail)
def low_match_pats_sc(fuel: Nat, env: LowEnv, st: CfgSt, ps: List<&2, Pat>, +regs: List<&2, U32>, scs: List<&2, U32>, body: Expr, fail_blk: U32, has_fail: Bool) -> CfgSt: low_match_pats_go(fuel, env, PSNext{st, ps, regs, scs, low_mask_scs(U32.to_nat(b5k_u32_list_len(regs)), 0, 0)}, body, fail_blk, has_fail)
def low_apply_chain(vargs: List<&2, U32>, st: CfgSt, vfn: U32) -> CfgSt:
  match vargs:
    case Nil{}: cfg_set_res(st, vfn)
    case Con{va, t}:
      +st1 = cfg_alloc(st, False{})
      +dst = cfg_res(st1)
      low_apply_chain(t, cfg_emit(st1, ICallDirect{dst, 0, [vfn, va]}), dst)
def low_list_chain(vargs: List<&2, U32>, st: CfgSt) -> CfgSt:
  match vargs:
    case Nil{}: low_emit_ctor(st, 4, Nil{})
    case Con{h, t}: (+st1 = low_list_chain(t, st); low_emit_ctor(st1, 5, [h, cfg_res(st1)]))
def low_str_chain(s: String, st: CfgSt) -> CfgSt:
  match s:
    case SNil{}: low_emit_ctor(st, 0, Nil{})
    case SCon{c, t}:
      +st1 = low_str_chain(t, st)
      +st2 = low_emit_const(st1, Char.to_u32(c))
      low_emit_ctor(st2, 1, [cfg_res(st2), cfg_res(st1)])
def low_stat_str_go(s: String, +idx: U32, rev: List<&2, U32>) -> U32 & List<&2, U32>:
  match s:
    case SNil{}: (idx, rev)
    case SCon{c, SNil{}}: (U32.add(idx, 2), Con{2147483648, Con{Char.to_u32(c), rev}})
    case SCon{c, SCon{c2, t2}}: (+nxt = U32.add(idx, 2); low_stat_str_go(SCon{c2, t2}, nxt, Con{U32.add(2147483649, nxt), Con{Char.to_u32(c), rev}}))
def low_un_pair(-A: Data, -B: Data, -R: Type, p: A & B, k: A -> B -> R) -> R:
  (a, b) = p
  k(a, b)
def low_str_lit_go(is_z: Bool, is_lt: Bool, +s0: String, st: CfgSt, nf: U32, nc: U32, cr: List<&2, IrCtor>, fr: List<&2, IrFn>, er: List<&2, CloEntry>, +ns: U32, sr: List<&2, U32>, sm1: Map<&2, U32>, hit: U32) -> CfgSt:
  match is_z is_lt:
    case True{} True{}: low_un_pair(U32, List<&2, U32>, CfgSt, low_stat_str_go(s0, U32.add(ns, 1), Con{U32.add(2147483649, U32.add(ns, 1)), sr}), ns2 => sr2 => low_emit_u32(cfg_set_bank(st, CloBank{nf, nc, cr, fr, er, ns2, sr2, Map.set(&2, U32, sm1, s0, U32.add(ns, 1))}), True{}, ns))
    case True{} False{}: low_str_chain(s0, cfg_set_bank(st, CloBank{nf, nc, cr, fr, er, ns, sr, sm1}))
    case False{} _: low_emit_u32(cfg_set_bank(st, CloBank{nf, nc, cr, fr, er, ns, sr, sm1}), True{}, U32.sub(hit, 1))
def low_str_lit_bk(bk: CloBank, +s0: String, st: CfgSt) -> CfgSt:
  CloBank{nf, nc, cr, fr, er, +ns, sr, sm} = bk
  low_un_pair(Map<&2, U32>, U32, CfgSt, Map.get(U32, 0, sm, s0), sm1 => hit => (+h = hit; low_str_lit_go(U32.is_zero(h), U32.is_lt(ns, 524288), s0, st, nf, nc, cr, fr, er, ns, sr, sm1, h)))
def low_str_has_hi(s: String) -> Bool:
  match s:
    case SNil{}: False{}
    case SCon{c, t}: Bool.or(U32.is_ge(Char.to_u32(c), 2147483648), low_str_has_hi(t))
def low_str_lit(s: String, +st: CfgSt) -> CfgSt:
  match s:
    case SNil{}: low_emit_ctor(st, 0, Nil{})
    case SCon{+c, +t}: Bool.pick(CfgSt, low_str_has_hi(SCon{c, t}), low_str_chain(SCon{c, t}, st), low_str_lit_bk(cfg_bank(st), SCon{c, t}, st))
def low_filter_erased(es: List<&2, Expr>, +emask: U32, +idx: U32) -> List<&2, Expr>:
  match es:
    case Nil{}: Nil{}
    case Con{h, t}: (+rest = low_filter_erased(t, emask, U32.add(idx, 1)); Bool.pick(List<&2, Expr>, Bool.and(U32.is_lt(idx, 32), U32.is_ne(U32.and(U32.shrn(emask, U32.to_nat(idx)), 1), 0)), rest, Con{h, rest}))
def low_app_direct(+st: CfgSt, +fid: U32, +vargs: List<&2, U32>, +is_tail: Bool) -> CfgSt:
  CfgSt{cfid, _, _, _, _, _, _, _, _, _, _, _, _} = st
  +st1 = cfg_alloc(st, False{})
  +st_call = cfg_emit(st1, ICallDirect{cfg_res(st1), fid, vargs})
  Bool.pick(CfgSt, Bool.and(is_tail, U32.is_eq(fid, cfid)), cfg_set_res(cfg_seal(st, TTailCall{fid, vargs}), 0),
    Bool.pick(CfgSt, Bool.and(is_tail, U32.is_le(b5k_u32_list_len(vargs), 5)), cfg_set_res(cfg_seal(st_call, TRet{cfg_res(st1)}), 0), st_call))
def low_emit_add_or_cat(+env: LowEnv, st: CfgSt, +va: U32, +vb: U32) -> CfgSt:
  LowEnv{_, _, _, _, _, _, fns, _, _, _, _, _, _, _, _, str_app, _, _} = env
  +st1 = low_emit_ctor(st, 0, Nil{})
  +st2 = cfg_alloc(st1, False{})
  +st3 = cfg_alloc(cfg_emit(st2, ICmp{cfg_res(st2), B5K_CMP_EQ(), va, cfg_res(st1)}), True{})
  +st4 = cfg_alloc(st3, True{})
  +st5 = cfg_alloc(st4, True{})
  +st6 = cfg_alloc(st5, True{})
  +st7 = cfg_alloc(st6, True{})
  +st8 = cfg_alloc(st7, False{})
  +s2 = cfg_alloc(cfg_start(cfg_seal(cfg_emit(cfg_start(cfg_seal(st8, TBr{cfg_res(st2), cfg_res(st3), cfg_res(st4)}), cfg_res(st3)), ICopy{cfg_res(st8), vb}), TJmp{cfg_res(st7)}), cfg_res(st4)), False{})
  +s3 = low_emit_const(cfg_emit(s2, ITag{cfg_res(s2), va}), 1)
  +s4 = cfg_alloc(s3, False{})
  +s6 = cfg_alloc(cfg_start(cfg_seal(cfg_emit(s4, ICmp{cfg_res(s4), B5K_CMP_EQ(), cfg_res(s2), cfg_res(s3)}), TBr{cfg_res(s4), cfg_res(st5), cfg_res(st6)}), cfg_res(st5)), False{})
  +s8 = cfg_alloc(cfg_start(cfg_seal(cfg_emit(cfg_emit(s6, ICallDirect{cfg_res(s6), um_get0(fns, str_app), [va, vb]}), ICopy{cfg_res(st8), cfg_res(s6)}), TJmp{cfg_res(st7)}), cfg_res(st6)), False{})
  cfg_set_res(cfg_start(cfg_seal(cfg_emit(cfg_emit(s8, IBin{cfg_res(s8), B5K_OP_ADD(), va, vb}), ICopy{cfg_res(st8), cfg_res(s8)}), TJmp{cfg_res(st7)}), cfg_res(st7)), cfg_res(st8))
def low_is_num_expr(fuel: Nat, +env: LowEnv, +vm: U32Map, +nvm: U32Map, e: Expr) -> Bool:
  match fuel e:
    case 0n _: False{}
    case 1n+_ ENum{_}: True{}
    case 1n+_ EFlt{_}: True{}
    case 1n+_ EChr{_}: True{}
    case 1n+_ EVar{s}: U32.is_eq(um_get(nvm, s), 1)
    case 1n+p EUnOp{op, a}: Bool.or(U32.is_zero(op), low_is_num_expr(p, env, vm, nvm, a))
    case 1n++p EOp{+op, a, b}: Bool.or(U32.is_ne(op, 0), Bool.or(low_is_num_expr(p, env, vm, nvm, a), low_is_num_expr(p, env, vm, nvm, b)))
    case 1n+p EAnn{v, typ}: Bool.or(low_is_scalar_type(env_map(env, 6), typ), low_is_num_expr(p, env, vm, nvm, v))
    case 1n+_ ECtr{sym, _}: (+k = low_special_ctor_kind(env_map(env, 6), sym); Bool.and(U32.is_ge(k, 1), U32.is_le(k, 5)))
    case 1n+_ EApp{f, _}:
      +s1 = low_expr_sym1(f)
      +s = U32.sub(s1, 1)
      +ic = um_get(env_map(env, 5), s)
      is_ni = Bool.or(Bool.and(U32.is_ge(ic, 1), U32.is_le(ic, 30)), Bool.or(Bool.and(U32.is_ge(ic, 40), U32.is_le(ic, 53)), Bool.or(U32.is_eq(ic, 67), Bool.or(Bool.and(U32.is_ge(ic, 137), U32.is_le(ic, 158)), Bool.or(U32.is_eq(ic, 186), Bool.or(Bool.and(U32.is_ge(ic, 162), U32.is_le(ic, 165)), U32.is_eq(ic, 167)))))))
      Bool.and(U32.is_ne(s1, 0), Bool.and(U32.is_zero(um_get(vm, s)), is_ni))
    case 1n++p EIf{_, t, f}: Bool.and(low_is_num_expr(p, env, vm, nvm, t), low_is_num_expr(p, env, vm, nvm, f))
    case 1n+_ _: False{}
def low_is_nat_expr(fuel: Nat, +env: LowEnv, e: Expr) -> Bool:
  match fuel e:
    case 0n _: False{}
    case 1n+_ ECtr{sym, _}: (+k = um_get(env_map(env, 6), sym); Bool.or(U32.is_eq(k, 3), U32.is_eq(k, 4)))
    case 1n+_ EApp{f, _}: (+s1 = low_expr_sym1(f); low_if(Bool, U32.is_zero(s1), _ => False{}, _ => (+nm = symtab_name(env_syms(env), U32.sub(s1, 1)); Bool.or(b5k_str_eq(nm, "U32.to_nat"), String.starts_with(nm, "Nat.")))))
    case 1n++p EOp{0, a, b}: Bool.or(low_is_nat_expr(p, env, a), low_is_nat_expr(p, env, b))
    case 1n+p EAnn{v, typ}: (+s1 = low_expr_sym1(typ); Bool.or(Bool.and(U32.is_ne(s1, 0), U32.is_eq(um_get(env_map(env, 6), U32.sub(s1, 1)), 15)), low_is_nat_expr(p, env, v)))
    case 1n+_ _: False{}
def low_emit_op_go(is_add: Bool, is_zero: Bool, is_nat: Bool, env: LowEnv, +st: CfgSt, +op: U32, +va: U32, +vb: U32) -> CfgSt:
  match is_add is_zero is_nat:
    case True{} True{} True{}: low_emit_arr_one(st, 162, [va, vb])
    case True{} _ _: low_emit_bin_or_cmp(st, False{}, B5K_OP_ADD(), va, vb)
    case False{} True{} _: low_emit_add_or_cat(env, st, va, vb)
    case False{} False{} _: (+is_cmp = Bool.and(U32.is_ge(op, 20), U32.is_le(op, 25)); Bool.pick(CfgSt, U32.is_eq(op, 162), low_emit_arr_one(st, 162, [va, vb]), Bool.pick(CfgSt, U32.is_eq(op, 156), low_emit_arr_one(st, 156, [va, vb]), low_emit_bin_or_cmp(st, is_cmp, Bool.pick(U32, is_cmp, U32.sub(op, 20), op), va, vb))))
def low_lookup_fvs(fvs: List<&2, U32>, +vm: U32Map) -> List<&2, U32>: opt_mapl(~U32, ~U32Map, ~U32, ~(m => s => um_get0(m, s)), vm, fvs)
def low_expr_sc_code(+env: LowEnv, +vm: U32Map, +nvm: U32Map, e: Expr) -> U32:
  match e:
    case EVar{s}: um_get(nvm, s)
    case other: Bool.to_u32(low_is_num_expr(16n, env, vm, nvm, other))
def low_exprs_sc_codes(+env: LowEnv, +vm: U32Map, +nvm: U32Map, es: List<&2, Expr>) -> List<&2, U32>:
  match es:
    case Nil{}: Nil{}
    case Con{h, t}: Con{low_expr_sc_code(env, vm, nvm, h), low_exprs_sc_codes(env, vm, nvm, t)}
def low_bind_one(st: CfgSt, +sym: U32, +idx: U32, +sc: U32, body: Expr) -> CfgSt:
  +st1 = low_opt_rc(U32.is_eq(sc, 1), st, idx, count_uses_go(U32.to_nat(2048), sym, UIExpr{body}))
  cfg_set_vm_nvm(st1, um_set(cfg_map(st1, False{}), sym, U32.add(idx, 1)), um_set(cfg_map(st1, True{}), sym, sc))
def low_bind_lam_caps(+outer_nvm: U32Map, fvs: List<&2, U32>, st: CfgSt, +idx: U32, +body: Expr) -> CfgSt:
  match fvs:
    case Nil{}: st
    case Con{+s, t}: low_bind_lam_caps(outer_nvm, t, low_bind_one(st, s, idx, um_get(outer_nvm, s), body), U32.add(idx, 1), body)
def low_bind_params(+syms: SymTab, +skind: U32Map, ps: List<&2, Param>, +st: CfgSt, +idx: U32, +body: Expr) -> CfgSt:
  match ps:
    case Nil{}: st
    case Con{Param{+sym, +typ, +er, dup}, t}:
      +is_er = low_param_is_erased(syms, body, Param{sym, typ, er, dup})
      st1 = Bool.pick(CfgSt, is_er, st, low_bind_one(st, sym, idx, low_maybe_sc_code(skind, typ), body))
      low_bind_params(syms, skind, t, st1, U32.add(idx, Bool.pick(U32, is_er, 0, 1)), body)
def low_curry_lam(ps: List<&2, Param>, body: Expr) -> Expr:
  match ps:
    case Nil{}: body
    case Con{p, rest}: ELam{[p], low_curry_lam(rest, body)}
def low_desugar_do(+env: LowEnv, ss: List<&2, Stmt>) -> Expr:
  LowEnv{_, _, _, _, _, _, _, _, _, _, _, _, _, io_bind, io_pure, _, +tmp, _} = env
  match ss:
    case Nil{}: EUnit{}
    case Con{StRet{v}, _}: EApp{EVar{io_pure}, [EUnit{}, v]}
    case Con{StExpr{v}, Nil{}}: v
    case Con{StExpr{v}, t}: EApp{EVar{io_bind}, [EUnit{}, EUnit{}, v, ELam{[Param{tmp, None{}, False{}, False{}}], low_desugar_do(env, t)}]}
    case Con{StLet{pat, v}, t}: ELet{pat, v, low_desugar_do(env, t)}
    case Con{StBind{PVar{s, dup}, v}, t}: EApp{EVar{io_bind}, [EUnit{}, EUnit{}, v, ELam{[Param{s, None{}, False{}, dup}], low_desugar_do(env, t)}]}
    case Con{StBind{pat, v}, t}: EApp{EVar{io_bind}, [EUnit{}, EUnit{}, v, ELam{[Param{tmp, None{}, False{}, False{}}], ELet{pat, EVar{tmp}, low_desugar_do(env, t)}}]}
def low_nth(-A: Data, idx: Nat, defv: A, xs: List<&2, A>) -> A:
  match idx xs:
    case _ Nil{}: defv
    case 0n Con{h, _}: h
    case 1n+p Con{_, t}: low_nth(A, p, defv, t)
def low_emit_ctor_k(k: U32, +env: LowEnv, +st: CfgSt, +sym: U32, +vfs: List<&2, U32>) -> CfgSt:
  match k vfs:
    case 2 _: low_emit_const(st, 1)
    case 4 Con{vx, _}: (+st1 = low_emit_const(st, 1); low_emit_arr_one(st1, 162, [vx, cfg_res(st1)]))
    case 4 Nil{}: low_emit_const(st, 1)
    case 13 _: low_emit_ctor(st, 6, vfs)
    case 20 Con{vh, Con{vt, _}}: (+st1 = low_emit_const(st, 1); +st2 = low_emit_bin_or_cmp(st1, False{}, B5K_OP_SHL(), vt, cfg_res(st1)); +st3 = low_emit_bin_or_cmp(st2, False{}, B5K_OP_AND(), vh, cfg_res(st1)); low_emit_bin_or_cmp(st3, False{}, B5K_OP_OR(), cfg_res(st2), cfg_res(st3)))
    case 20 _: low_emit_const(st, 0)
    case 1 _: low_emit_const(st, 0)
    case 3 _: low_emit_const(st, 0)
    case 19 _: low_emit_const(st, 0)
    case 8 _: low_emit_arr_one(st, 8, vfs)
    case 9 _: low_emit_arr_one(st, 9, vfs)
    case 5 Con{vx, _}: cfg_set_res(st, vx)
    case 14 Con{vx, _}: cfg_set_res(st, vx)
    case 16 Con{vx, _}: cfg_set_res(st, vx)
    case 5 Nil{}: low_emit_const(st, 0)
    case 14 Nil{}: low_emit_const(st, 0)
    case 16 Nil{}: low_emit_const(st, 0)
    case _ _: low_emit_ctor(st, um_get0(env_map(env, 0), sym), vfs)
def low_emit_ctor_expr(+env: LowEnv, st: CfgSt, +sym: U32, vfs: List<&2, U32>) -> CfgSt: low_emit_ctor_k(um_get(env_map(env, 6), sym), env, st, sym, vfs)
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
    case EApp{+f, +args}:
      +s1 = low_expr_sym1(f)
      +sym = U32.sub(s1, 1)
      low_unbox_app(env_map(env, 6), Bool.and(U32.is_ne(s1, 0), U32.is_zero(um_get(vm, sym))), low_intr_code(env_map(env, 5), sym), EApp{f, args}, args)
    case other: UArrNone{other}
# Direct U32.cmp/Nat.cmp, Branchless Bool Match & Common Single-Ctor Hoisting
def low_pat_code(+skind: U32Map, is_cmp: Bool, p: Pat) -> U32:
  match p:
    case PWild{}: Bool.pick(U32, is_cmp, 4, 3)
    case PCtr{sym, Nil{}}: (+k = um_get(skind, sym); Bool.pick(U32, is_cmp, Bool.pick(U32, Bool.and(U32.is_ge(k, 10), U32.is_le(k, 12)), U32.sub(k, 9), 0), Bool.pick(U32, Bool.or(U32.is_eq(k, 1), U32.is_eq(k, 2)), k, 0)))
    case _: 0
def low_all_cmp_cases(+skind: U32Map, cs: List<&2, Case>, seen: Bool) -> Bool:
  match cs:
    case Nil{}: seen
    case Con{Case{Con{p, Nil{}}, _}, t}: Bool.and(U32.is_ne(low_pat_code(skind, True{}, p), 0), low_all_cmp_cases(skind, t, True{}))
    case _: False{}
type CmpMatchInfo is Data:
  CMNone{}
  CMHit{a: Expr, b: Expr}
def low_cmp_match_info(+env: LowEnv, +vm: U32Map, scrut: Expr, cs: List<&2, Case>) -> CmpMatchInfo:
  match scrut:
    case EApp{f, Con{a, Con{b, Nil{}}}}:
      +s1 = low_expr_sym1(f)
      +sym = U32.sub(s1, 1)
      Bool.pick(CmpMatchInfo, Bool.and(low_all_cmp_cases(env_map(env, 6), cs, False{}), Bool.and(U32.is_ne(s1, 0), Bool.and(U32.is_zero(um_get(vm, sym)), U32.is_eq(um_get(env_map(env, 5), sym), 66)))), CMHit{a, b}, CMNone{})
    case _: CMNone{}
def low_const01_code(+skind: U32Map, e: Expr) -> U32:
  match e:
    case ENum{0}: 1
    case ENum{1}: 2
    case ECtr{sym, Nil{}}: (+k = low_special_ctor_kind(skind, sym); Bool.pick(U32, Bool.or(U32.is_eq(k, 1), U32.is_eq(k, 2)), k, 0))
    case _: 0
def low_bool_match_kind(+skind: U32Map, cs: List<&2, Case>) -> U32:
  match cs:
    case Con{Case{Con{p1, Nil{}}, e1}, Con{Case{Con{p2, Nil{}}, e2}, Nil{}}}:
      +k1 = low_pat_code(skind, False{}, p1)
      +k2 = low_pat_code(skind, False{}, p2)
      +v1 = low_const01_code(skind, e1)
      +v2 = low_const01_code(skind, e2)
      ok_p = Bool.and(Bool.or(U32.is_eq(k1, 1), U32.is_eq(k1, 2)), Bool.or(U32.is_eq(k2, U32.sub(3, k1)), U32.is_eq(k2, 3)))
      ok_v = Bool.and(Bool.or(U32.is_eq(v1, 1), U32.is_eq(v1, 2)), U32.is_eq(v2, U32.sub(3, v1)))
      Bool.pick(U32, Bool.and(ok_p, ok_v), Bool.pick(U32, U32.is_eq(k1, v1), 1, 2), 0)
    case _: 0
type HoistCol is Data:
  HCNone{}
  HCPair{}
  HCCtr{sym: U32, nf: U32}
def low_hoist_match_one(spec: HoistCol, p: Pat) -> Bool:
  match spec p:
    case HCPair{} PPair{_, _}: True{}
    case HCCtr{sym, nf} PCtr{s2, fs}: Bool.and(U32.is_eq(sym, s2), U32.is_eq(nf, b5k_list_len(Pat, fs)))
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
def low_splice_u32(col: Nat, xs: List<&2, U32>, rep: List<&2, U32>) -> List<&2, U32>:
  match col xs:
    case _ Nil{}: Nil{}
    case 0n Con{_, t}: b5k_list_app(U32, rep, t)
    case 1n+p Con{h, t}: Con{h, low_splice_u32(p, t, rep)}
def low_is_tag_ctor(skind: U32Map, sym: U32) -> Bool:
  +k = um_get(skind, sym)
  Bool.or(U32.is_zero(k), Bool.and(U32.is_ge(k, 10), U32.is_le(k, 13)))
def low_grp_pat_m(+env: LowEnv, p: Pat) -> HoistCol:
  match p:
    case PPair{_, _}: HCPair{}
    case PCtr{+sym, +fs}: (+nf = b5k_list_len(Pat, fs); Bool.pick(HoistCol, Bool.and(low_is_tag_ctor(env_map(env, 6), sym), U32.is_gt(nf, 0)), HCCtr{sym, nf}, HCNone{}))
    case _: HCNone{}
type GrpSplit is Data:
  GrpSplit{grp: List<&2, Case>, tail: List<&2, Case>}
def low_grp_split(cs: List<&2, Case>, go: Bool, prev: Case, +spec: HoistCol, +col: U32, +acc: List<&2, Case>) -> GrpSplit:
  match cs go:
    case rest False{}: GrpSplit{b5k_list_rev(Case, acc), Con{prev, rest}}
    case Nil{} True{}: GrpSplit{b5k_list_rev(Case, acc), Nil{}}
    case Con{Case{+ps, +body}, t} True{}: (+ok = low_hoist_match_one(spec, low_nth(Pat, U32.to_nat(col), PWild{}, ps)); low_grp_split(t, ok, Case{ps, body}, spec, col, Bool.pick(List<&2, Case>, ok, Con{Case{ps, body}, acc}, acc)))
def low_pat_disjoint(+sym: U32, +cid: U32, p: Pat) -> Bool:
  match p:
    case PCtr{s2, _}: U32.is_ne(sym, s2)
    case PList{Nil{}}: U32.is_ne(cid, 4)
    case PList{Con{_, _}}: U32.is_ne(cid, 5)
    case _: False{}
def low_tail_disjoint(+sym: U32, +cid: U32, +col: U32, cs: List<&2, Case>) -> Bool:
  match cs:
    case Nil{}: True{}
    case Con{Case{ps, _}, t}: Bool.and(low_pat_disjoint(sym, cid, low_nth(Pat, U32.to_nat(col), PWild{}, ps)), low_tail_disjoint(sym, cid, col, t))
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
      +is_s = U32.is_ne(um_get(env_map(env, 1), sym), 0)
      ok = Bool.or(Bool.and(Bool.not(is_s), low_tail_disjoint(sym, um_get0(env_map(env, 0), sym), col, Con{th, tt})), low_grp_last_irref(col, Con{c0, Con{c1, gt}}))
      Bool.pick(GrpPick, ok, GPHit{col, HCCtr{sym, nf}, Con{c0, Con{c1, gt}}, Bool.pick(List<&2, Case>, is_s, Nil{}, Con{th, tt})}, GPNone{})
    case HCPair{} GrpSplit{Con{+c0, Con{+c1, +gt}}, Con{_, _}}: Bool.pick(GrpPick, low_grp_last_irref(col, Con{c0, Con{c1, gt}}), GPHit{col, HCPair{}, Con{c0, Con{c1, gt}}, Nil{}}, GPNone{})
    case _ _: GPNone{}
def low_grp_find(vs: List<&2, U32>, pick: GrpPick, +env: LowEnv, +ps0: List<&2, Pat>, +cs: List<&2, Case>, +col: U32) -> GrpPick:
  match vs pick:
    case _ GPHit{c, sp, g, tl}: GPHit{c, sp, g, tl}
    case Nil{} GPNone{}: GPNone{}
    case Con{_, vt} GPNone{}: (+sp = low_grp_pat_m(env, low_nth(Pat, U32.to_nat(col), PWild{}, ps0)); low_grp_find(vt, low_grp_try_split(env, col, sp, low_grp_split(cs, True{}, Case{Nil{}, EUnit{}}, sp, col, Nil{})), env, ps0, cs, U32.add(col, 1)))
type GrpTakeRes is Data:
  GrpTakeRes{st: CfgSt, vs: List<&2, U32>, scs: List<&2, U32>, trs: List<&2, U32>}
def low_grp_take_n(st: CfgSt, +nf: U32, sm: U32, +col: U32, +vs: List<&2, U32>, scs: List<&2, U32>, trs: List<&2, U32>) -> GrpTakeRes:
  +st2 = low_alloc_regs_go(U32.to_nat(nf), st, Nil{})
  +fregs = cfg_rlist(st2)
  GrpTakeRes{cfg_emit(st2, ITake{fregs, low_nth(U32, U32.to_nat(col), 0, vs)}), low_splice_u32(U32.to_nat(col), vs, fregs), low_splice_u32(U32.to_nat(col), scs, low_mask_scs(U32.to_nat(nf), sm, 0)), low_splice_u32(U32.to_nat(col), trs, low_mask_scs(U32.to_nat(nf), 0, 0))}
def low_grp_emit_take(+env: LowEnv, st: CfgSt, spec: HoistCol, +col: U32, vs: List<&2, U32>, +scs: List<&2, U32>, trs: List<&2, U32>) -> GrpTakeRes:
  match spec:
    case HCPair{}: low_grp_take_n(st, 2, U32.shrn(low_nth(U32, U32.to_nat(col), 0, scs), 1n), col, vs, scs, trs)
    case HCCtr{+sym, nf}: low_grp_take_n(st, nf, Bool.pick(U32, U32.is_eq(um_get0(env_map(env, 0), sym), 6), U32.shrn(low_nth(U32, U32.to_nat(col), 0, scs), 1n), um_get(env_map(env, 7), sym)), col, vs, scs, trs)
    case HCNone{}: GrpTakeRes{st, vs, scs, trs}
def low_mpat_needs_tag(+env: LowEnv, p: Pat) -> U32:
  match p:
    case PList{_}: 1
    case PCtr{+sym, _}: Bool.to_u32(Bool.and(low_is_tag_ctor(env_map(env, 6), sym), U32.is_zero(um_get(env_map(env, 1), sym))))
    case _: 0
def low_col_tag_uses(+env: LowEnv, +col: U32, cs: List<&2, Case>, +acc: U32) -> U32:
  match cs:
    case Nil{}: acc
    case Con{_, Nil{}}: acc
    case Con{Case{ps, _}, Con{c2, rt}}: low_col_tag_uses(env, col, Con{c2, rt}, U32.add(acc, low_mpat_needs_tag(env, low_nth(Pat, U32.to_nat(col), PWild{}, ps))))
def low_emit_tag_cache(vs: List<&2, U32>, +env: LowEnv, st: CfgSt, +cs: List<&2, Case>, +col: U32, +acc: List<&2, U32>) -> CfgSt:
  match vs:
    case Nil{}: cfg_set_rlist(st, b5k_list_rev(U32, acc))
    case Con{r, vt}:
      +st0 = st
      +st1 = cfg_alloc(st0, False{})
      +tr = cfg_res(st1)
      +need = U32.is_ge(low_col_tag_uses(env, col, cs, 0), 2)
      low_emit_tag_cache(vt, env, Bool.pick(CfgSt, need, cfg_emit(st1, ITag{tr, r}), st0), cs, U32.add(col, 1), Con{Bool.pick(U32, need, U32.add(tr, 1), 0), acc})
def low_pats_flat_ok(ps: List<&2, Pat>, +env: LowEnv) -> Bool:
  match ps:
    case Nil{}: True{}
    case Con{PPair{a, b}, t}: Bool.and(Bool.not(pat_is_refut(16n, [a, b])), low_pats_flat_ok(t, env))
    case Con{PList{Con{_, _}}, _}: False{}
    case Con{PCtr{+sym, +fs}, t}:
      +k = low_special_ctor_kind(env_map(env, 6), sym)
      ok = Bool.or(Bool.and(Bool.and(U32.is_ge(k, 1), U32.is_le(k, 3)), U32.is_zero(b5k_list_len(Pat, fs))), Bool.and(low_is_tag_ctor(env_map(env, 6), sym), Bool.not(pat_is_refut(16n, fs))))
      Bool.and(ok, low_pats_flat_ok(t, env))
    case Con{_, t}: low_pats_flat_ok(t, env)
def low_pretest_pats(ps: List<&2, Pat>, +env: LowEnv, st: CfgSt, rs: List<&2, U32>, trs: List<&2, U32>, +fb: U32) -> CfgSt:
  match ps rs trs:
    case Con{PNum{v}, pt} Con{r, rt} Con{_, trt}: low_pretest_pats(pt, env, low_test_cmp_const(st, B5K_CMP_EQ(), r, v, fb), rt, trt, fb)
    case Con{PChr{c}, pt} Con{r, rt} Con{_, trt}: low_pretest_pats(pt, env, low_test_cmp_const(st, B5K_CMP_EQ(), r, c, fb), rt, trt, fb)
    case Con{PList{Nil{}}, pt} Con{r, rt} Con{tr, trt}: low_pretest_pats(pt, env, low_opt_test_tag(True{}, st, r, tr, 4, fb), rt, trt, fb)
    case Con{PCtr{+sym, _}, pt} Con{+r, rt} Con{tr, trt}:
      +st0 = st
      +k = low_special_ctor_kind(env_map(env, 6), sym)
      st1 = Bool.pick(CfgSt, Bool.and(U32.is_ge(k, 1), U32.is_le(k, 3)), low_test_bool(st0, U32.is_eq(k, 2), r, fb), low_opt_test_tag(U32.is_zero(um_get(env_map(env, 1), sym)), st0, r, tr, um_get0(env_map(env, 0), sym), fb))
      low_pretest_pats(pt, env, st1, rt, trt, fb)
    case Con{_, pt} Con{_, rt} Con{_, trt}: low_pretest_pats(pt, env, st, rt, trt, fb)
    case _ _ _: st
def low_match_case_pats(+env: LowEnv, +st: CfgSt, +ps: List<&2, Pat>, +rs: List<&2, U32>, +scs: List<&2, U32>, +trs: List<&2, U32>, +body: Expr, +fb: U32) -> CfgSt:
  low_if(CfgSt, Bool.and(U32.is_ge(b5k_list_len(Pat, ps), 2), low_pats_flat_ok(ps, env)), _ => low_match_pats_sct(64n, env, low_pretest_pats(ps, env, st, rs, trs, fb), ps, rs, scs, trs, body, 0, False{}), _ => low_match_pats_sct(64n, env, st, ps, rs, scs, trs, body, fb, True{}))
type LowTask is Data:
  LTExpr{e: Expr}
  LTExprs{es: List<&2, Expr>, acc: List<&2, U32>}
  LTCases{base_vm: U32Map, base_nvm: U32Map, cs: List<&2, Case>, vscruts: List<&2, U32>, sc_scruts: List<&2, U32>, tregs: List<&2, U32>, res_reg: U32, merge_blk: U32}
  LTCasesGrp{base_vm: U32Map, base_nvm: U32Map, cs: List<&2, Case>, vscruts: List<&2, U32>, sc_scruts: List<&2, U32>, tregs: List<&2, U32>, res_reg: U32, merge_blk: U32, pick: GrpPick}
  LTCasesTake{base_vm: U32Map, base_nvm: U32Map, gtr: GrpTakeRes, grp: List<&2, Case>, tail: List<&2, Case>, tail_blk: U32, orig_vs: List<&2, U32>, orig_scs: List<&2, U32>, orig_trs: List<&2, U32>, res_reg: U32, merge_blk: U32}
  LTCmpCases{base_vm: U32Map, base_nvm: U32Map, cs: List<&2, Case>, va: U32, vb: U32, res_reg: U32, merge_blk: U32}
  LTMatStart{base_vm: U32Map, base_nvm: U32Map, cs: List<&2, Case>, vscruts: List<&2, U32>, sc_scruts: List<&2, U32>}
  LTMatOne{base_vm: U32Map, base_nvm: U32Map, s0: Expr, cs: List<&2, Case>, bkind: U32, cinfo: CmpMatchInfo}
  LTAppSym{sym: U32, args: List<&2, Expr>, lv: U32, icode: U32, fv: U32}
  LTAppIntr1{sym: U32, a: Expr, icode: U32, is_bin: Bool}
  LTAppFn{sym: U32, args: List<&2, Expr>, fid: U32, ar: U32, vargs: List<&2, U32>, is_sat: Bool, is_over: Bool}
  LTVar{sym: U32, lv: U32, fv: U32}
  LTLetUnbox{pa: Pat, pb: Pat, ua: UnboxArr, body: Expr}
  LTLetPat{pat: Pat, val: Expr, body: Expr}
def low_type_head(+syms: SymTab, e: Expr) -> String:
  match e:
    case EVar{s}: symtab_name(syms, s)
    case ERef{s}: symtab_name(syms, s)
    case EApp{f, _}: low_type_head(syms, f)
    case _: ""
def low_map_ops(+fuel: Nat, +mode: U32, e: Expr) -> Expr:
  match fuel e:
    case 0n _: e
    case 1n+p EOp{+op, a, b}:
      op2 = Bool.pick(U32, U32.is_eq(mode, 1), Bool.pick(U32, U32.is_lt(op, 4), U32.add(op, 10), Bool.pick(U32, U32.is_eq(op, 4), 156, op)),
            Bool.pick(U32, U32.is_eq(mode, 2), Bool.pick(U32, U32.is_zero(op), 162, op), Bool.pick(U32, U32.is_zero(op), 19, op)))
      EOp{op2, low_map_ops(p, mode, a), low_map_ops(p, mode, b)}
    case 1n+p EAnn{v, t}: EAnn{low_map_ops(p, mode, v), t}
    case 1n+_ other: other
def low_op_meth_name(+op: U32) -> String:
  match op:
    case 22: ".is_lt"
    case 23: ".is_le"
    case 24: ".is_gt"
    case 25: ".is_ge"
    case _: ""
def low_map_custom_op_k(ms: Maybe<&2, U32>, op: U32, a: Expr, b: Expr) -> Expr:
  match ms:
    case Some{s}: EApp{EVar{s}, [a, b]}
    case None{}: EOp{op, a, b}
def low_map_custom_ops(+fuel: Nat, +syms: SymTab, +th: String, e: Expr) -> Expr:
  match fuel e:
    case 0n _: e
    case 1n+p EOp{+op, a, b}:
      +a2 = low_map_custom_ops(p, syms, th, a)
      +b2 = low_map_custom_ops(p, syms, th, b)
      +mn = low_op_meth_name(op)
      Bool.pick(Expr, String.is_empty(mn), EOp{op, a2, b2}, low_map_custom_op_k(symtab_lookup(syms, String.append(th, mn)), op, a2, b2))
    case 1n+p EAnn{v, t}: EAnn{low_map_custom_ops(p, syms, th, v), t}
    case 1n+_ other: other
def low_take_u32(n: Nat, xs: List<&2, U32>) -> List<&2, U32>:
  match n xs:
    case 0n _: Nil{}
    case _ Nil{}: Nil{}
    case 1n+p Con{h, t}: Con{h, low_take_u32(p, t)}
def low_drop(-A: Data, n: Nat, xs: List<&2, A>) -> List<&2, A>:
  match n xs:
    case 0n _: xs
    case _ Nil{}: Nil{}
    case 1n+p Con{_, t}: low_drop(A, p, t)
def low_bank_next_cid(bk: CloBank) -> U32:
  CloBank{_, nc, _, _, _, _, _, _} = bk
  nc
def low_bank_finish_lam(+ncaps: U32, ar: U32, lam_st: CfgSt) -> CloBank:
  match lam_st:
    case CfgSt{_, nregs, _, _, _, blks_rev, _, _, _, _, _, _, CloBank{+lam_fid, +lam_cid, cr, fr, er, ns, sr, sm}}: CloBank{U32.add(lam_fid, 1), U32.add(lam_cid, 1), Con{IrCtor{lam_cid, String.append("__clo_", b5k_u32_to_str(lam_fid)), ncaps, False{}}, cr}, Con{IrFn{lam_fid, String.append("__lam_", b5k_u32_to_str(lam_fid)), ar, nregs, True{}, False{}, False{}, b5k_list_rev(IrBlock, blks_rev)}, fr}, Con{CloEntry{lam_cid, lam_fid, ncaps}, er}, ns, sr, sm}
def low_expr_lt32(fuel: Nat, +syms: SymTab, e: Expr) -> Bool:
  match fuel e:
    case 0n _: False{}
    case 1n+_ ENum{v}: U32.is_lt(v, 32)
    case 1n+p EAnn{v, _}: low_expr_lt32(p, syms, v)
    case 1n+p EApp{f, Con{x, Nil{}}}:
      +s1 = low_expr_sym1(f)
      +nm = symtab_name(syms, U32.sub(s1, 1))
      Bool.and(U32.is_ne(s1, 0), Bool.and(Bool.or(b5k_str_eq(nm, "U32.to_nat"), b5k_str_eq(nm, "U32.from_nat")), low_expr_lt32(p, syms, x)))
    case 1n++p EApp{f, Con{a, Con{b, Nil{}}}}: (+s1 = low_expr_sym1(f); Bool.and(U32.is_ne(s1, 0), Bool.and(b5k_str_eq(symtab_name(syms, U32.sub(s1, 1)), "U32.and"), Bool.or(low_expr_lt32(p, syms, a), low_expr_lt32(p, syms, b)))))
    case 1n++p EOp{5, a, b}: Bool.or(low_expr_lt32(p, syms, a), low_expr_lt32(p, syms, b))
    case 1n+_ _: False{}
def low_shift_code(syms: SymTab, skind: U32Map, +icode: U32, args: List<&2, Expr>) -> U32:
  match args:
    case Con{_, Con{eb, Nil{}}}: Bool.pick(U32, Bool.and(Bool.or(U32.is_eq(icode, 24), U32.is_eq(icode, 25)), low_expr_lt32(16n, syms, eb)), U32.add(icode, 4), icode)
    case Con{ty, _}: Bool.pick(U32, Bool.and(U32.is_eq(icode, 62), low_is_scalar_type(skind, ty)), 68, icode)
    case _: icode
def low_intr_is_bin(+ic: U32) -> Bool:
  Bool.or(Bool.and(U32.is_ge(ic, 1), U32.is_le(ic, 18)),
  Bool.or(Bool.or(U32.is_eq(ic, 24), U32.is_eq(ic, 25)),
  Bool.or(Bool.and(U32.is_ge(ic, 40), U32.is_le(ic, 49)),
  Bool.or(Bool.or(U32.is_eq(ic, 66), Bool.and(U32.is_ge(ic, 154), U32.is_le(ic, 156))),
  Bool.or(Bool.and(U32.is_ge(ic, 162), U32.is_le(ic, 164)),
          Bool.or(U32.is_eq(ic, 166), Bool.or(U32.is_eq(ic, 167), U32.is_eq(ic, 170))))))))
def low_const_log2_go(fuel: Nat, +n: U32, acc: U32, done: Bool) -> U32:
  match fuel done:
    case 1n+p False{}: low_const_log2_go(p, U32.shr(n), U32.add(acc, 1), U32.is_le(U32.shr(n), 1))
    case _ _: acc
def low_is_lam_mat_cases(cs: List<&2, Case>, has_ref: Bool) -> Bool:
  match cs:
    case Nil{}: has_ref
    case Con{Case{Con{PWild{}, Nil{}}, EAnn{_, ERef{_}}}, t}: low_is_lam_mat_cases(t, True{})
    case Con{Case{Con{PWild{}, Nil{}}, _}, t}: low_is_lam_mat_cases(t, has_ref)
    case _: False{}
def low_mk_fvars_go(n: Nat, +base: U32, +i: U32, ps: List<&2, Pat>, es: List<&2, Expr>) -> List<&2, Pat> & List<&2, Expr>:
  match n:
    case 0n: (b5k_list_rev(Pat, ps), b5k_list_rev(Expr, es))
    case 1n+p:
      +s = U32.add(base, i)
      low_mk_fvars_go(p, base, U32.add(i, 1), Con{PVar{s, False{}}, ps}, Con{EVar{s}, es})
def low_rw_lam_mat_arm(csym: U32, ar: U32, +rhs: Expr, p: List<&2, Pat> & List<&2, Expr>) -> Case:
  (fps, fes) = p
  Case{[PCtr{csym, fps}], Bool.pick(Expr, U32.is_zero(ar), rhs, EApp{rhs, fes})}
def low_kind_arity(+k: U32) -> U32:
  Bool.pick(U32, U32.is_eq(k, 20), 2, Bool.pick(U32, Bool.or(U32.is_eq(k, 4), Bool.or(U32.is_eq(k, 5), Bool.or(U32.is_eq(k, 14), U32.is_eq(k, 16)))), 1, 0))
def low_rw_lam_mat_case(+env: LowEnv, +sc: U32, +fbase: U32, c: Case) -> Case:
  match c:
    case Case{Con{PWild{}, Nil{}}, EAnn{rhs, ERef{+csym}}}:
      +ar0 = um_get(env_map(env, 8), csym)
      +ar = Bool.pick(U32, U32.is_zero(ar0), low_kind_arity(um_get(env_map(env, 6), csym)), U32.sub(ar0, 1))
      low_rw_lam_mat_arm(csym, ar, rhs, low_mk_fvars_go(U32.to_nat(ar), fbase, 0, Nil{}, Nil{}))
    case Case{Con{PWild{}, Nil{}}, rhs}: Case{[PWild{}], EApp{rhs, [EVar{sc}]}}
    case other: other
def low_rw_lam_mat_cases(+env: LowEnv, +sc: U32, +fbase: U32, cs: List<&2, Case>) -> List<&2, Case>:
  match cs:
    case Nil{}: Nil{}
    case Con{c, t}: Con{low_rw_lam_mat_case(env, sc, fbase, c), low_rw_lam_mat_cases(env, sc, fbase, t)}
def low_lam_is_mat(p0: Param, body: Expr) -> Bool:
  match p0 body:
    case Param{0, None{}, False{}, True{}} EMat{Con{EVar{0}, Nil{}}, cs}: low_is_lam_mat_cases(cs, False{})
    case _ _: False{}
def low_lam_rw_body(+env: LowEnv, +sc: U32, +fb: U32, body: Expr) -> Expr:
  match body:
    case EMat{Con{EVar{0}, Nil{}}, cs}: EMat{[EVar{sc}], low_rw_lam_mat_cases(env, sc, fb, cs)}
    case other: other
def low_do_head_from_expr(+syms: SymTab, +co: U32Map, e: Expr) -> String:
  match e:
    case EAnn{_, typ}: low_type_head(syms, typ)
    case ECtr{csym, _}:
      +ow = um_get(co, csym)
      Bool.pick(String, U32.is_zero(ow), "", symtab_name(syms, U32.sub(ow, 1)))
    case _: ""
def low_do_head_from_stmts(+syms: SymTab, +co: U32Map, ss: List<&2, Stmt>) -> String:
  match ss:
    case Nil{}: ""
    case Con{StBind{_, v}, t}:
      +hd = low_do_head_from_expr(syms, co, v)
      Bool.pick(String, String.is_empty(hd), low_do_head_from_stmts(syms, co, t), hd)
    case Con{StExpr{v}, t}:
      +hd = low_do_head_from_expr(syms, co, v)
      Bool.pick(String, String.is_empty(hd), low_do_head_from_stmts(syms, co, t), hd)
    case Con{_, t}: low_do_head_from_stmts(syms, co, t)
def low_env_with_monad(+hd: String, env: LowEnv) -> LowEnv:
  LowEnv{+syms, ct, cm, cs, ca, co, fn, ar, em, ir, kd, mf, mp, +ib, +ip, sa, tmp, al} = env
  +is_res = b5k_str_eq(hd, "Result")
  +is_mb = b5k_str_eq(hd, "Maybe")
  +is_io = Bool.or(String.is_empty(hd), b5k_str_eq(hd, "IO"))
  +cb = Bool.pick(U32, is_io, ib, Maybe.default(&2, U32, symtab_lookup(syms, String.append(hd, ".bind")), ib))
  +cp = Bool.pick(U32, is_io, ip, Maybe.default(&2, U32, symtab_lookup(syms, String.append(hd, ".pure")), ip))
  nb = Bool.pick(U32, is_res, Maybe.default(&2, U32, symtab_lookup(syms, "__res_bind"), ib), Bool.pick(U32, is_mb, Maybe.default(&2, U32, symtab_lookup(syms, "__mb_bind"), ib), cb))
  np = Bool.pick(U32, is_res, Maybe.default(&2, U32, symtab_lookup(syms, "__res_pure"), ip), Bool.pick(U32, is_mb, Maybe.default(&2, U32, symtab_lookup(syms, "__mb_pure"), ip), cp))
  LowEnv{syms, ct, cm, cs, ca, co, fn, ar, em, ir, kd, mf, mp, nb, np, sa, tmp, al}
def low_env_for_do(+env: LowEnv, ss: List<&2, Stmt>) -> LowEnv:
  +hd = low_do_head_from_stmts(env_syms(env), env_map(env, 9), ss)
  Bool.pick(LowEnv, String.is_empty(hd), env, low_env_with_monad(hd, env))
def low_go(fuel: Nat, +env: LowEnv, st: CfgSt, task: LowTask, +is_tail: Bool) -> CfgSt:
  match fuel task:
    case Zero{} _: st
    case Succ{_} LTExprs{Nil{}, acc}: cfg_set_rlist(st, b5k_list_rev(U32, acc))
    case Succ{+p} LTExprs{Con{h, t}, acc}: (+st1 = low_go(p, env, st, LTExpr{h}, False{}); low_go(p, env, st1, LTExprs{t, Con{cfg_res(st1), acc}}, False{}))
    case Succ{_} LTCases{_, _, Nil{}, _, _, _, _, _}: cfg_seal(st, TFail{1})
    case Succ{+p} LTCases{+base_vm, +base_nvm, Con{Case{+ps, +body}, rest}, +vscruts, +sc_scruts, +tregs, +res_reg, +merge_blk}:
      match rest:
        case Nil{}:
          +st0 = st
          prev_mg = cfg_flag(st0, True{})
          st1 = low_match_pats_sct(64n, env, cfg_set_vm_nvm(st0, base_vm, base_nvm), ps, vscruts, sc_scruts, tregs, body, 0, False{})
          +st2 = low_go(p, env, st1, LTExpr{body}, is_tail)
          cfg_fin_branch(st2, cfg_flag(st2, False{}), res_reg, cfg_res(st2), merge_blk, prev_mg)
        case Con{+rh, +rt}: low_go(p, env, st, LTCasesGrp{base_vm, base_nvm, Con{Case{ps, body}, Con{rh, rt}}, vscruts, sc_scruts, tregs, res_reg, merge_blk, low_grp_find(vscruts, GPNone{}, env, ps, Con{Case{ps, body}, Con{rh, rt}}, 0)}, is_tail)
    case Succ{+p} LTCasesGrp{+base_vm, +base_nvm, Con{Case{ps, +body}, rest}, +vscruts, +sc_scruts, +tregs, +res_reg, +merge_blk, GPNone{}}:
      +st0 = st
      prev_mg = cfg_flag(st0, True{})
      +st_f = cfg_alloc(st0, True{})
      +nxt_blk = cfg_res(st_f)
      st1 = low_match_case_pats(env, cfg_set_vm_nvm(st_f, base_vm, base_nvm), ps, vscruts, sc_scruts, tregs, body, nxt_blk)
      +st2 = low_go(p, env, st1, LTExpr{body}, is_tail)
      st3 = cfg_fin_branch(st2, cfg_flag(st2, False{}), res_reg, cfg_res(st2), merge_blk, prev_mg)
      low_go(p, env, cfg_start(st3, nxt_blk), LTCases{base_vm, base_nvm, rest, vscruts, sc_scruts, tregs, res_reg, merge_blk}, is_tail)
    case Succ{p} LTCasesGrp{base_vm, base_nvm, _, +vscruts, +sc_scruts, +tregs, res_reg, merge_blk, GPHit{+col, spec, grp, Nil{}}}: (+st0 = st; low_go(p, env, st0, LTCasesTake{base_vm, base_nvm, low_grp_emit_take(env, st0, spec, col, vscruts, sc_scruts, tregs), low_splice_cases(col, grp), Nil{}, 0, vscruts, sc_scruts, tregs, res_reg, merge_blk}, is_tail))
    case Succ{p} LTCasesGrp{base_vm, base_nvm, _, +vscruts, +sc_scruts, +tregs, res_reg, merge_blk, GPHit{+col, HCCtr{+sym, +nf}, grp, Con{th, tt}}}:
      +st_f = cfg_alloc(st, True{})
      +tail_blk = cfg_res(st_f)
      +st_ok = low_opt_test_tag(True{}, st_f, low_nth(U32, U32.to_nat(col), 0, vscruts), low_nth(U32, U32.to_nat(col), 0, tregs), um_get0(env_map(env, 0), sym), tail_blk)
      low_go(p, env, st_ok, LTCasesTake{base_vm, base_nvm, low_grp_emit_take(env, st_ok, HCCtr{sym, nf}, col, vscruts, sc_scruts, tregs), low_splice_cases(col, grp), Con{th, tt}, tail_blk, vscruts, sc_scruts, tregs, res_reg, merge_blk}, is_tail)
    case Succ{_} LTCasesGrp{_, _, _, _, _, _, _, _, _}: cfg_seal(st, TFail{1})
    case Succ{p} LTCasesTake{base_vm, base_nvm, GrpTakeRes{st1, vs1, scs1, trs1}, grp, Nil{}, _, _, _, _, res_reg, merge_blk}: low_go(p, env, st1, LTCases{base_vm, base_nvm, grp, vs1, scs1, trs1, res_reg, merge_blk}, is_tail)
    case Succ{+p} LTCasesTake{+base_vm, +base_nvm, GrpTakeRes{st1, vs1, scs1, trs1}, grp, Con{th, tt}, tail_blk, orig_vs, orig_scs, orig_trs, +res_reg, +merge_blk}: low_go(p, env, cfg_start(low_go(p, env, st1, LTCases{base_vm, base_nvm, grp, vs1, scs1, trs1, res_reg, merge_blk}, is_tail), tail_blk), LTCases{base_vm, base_nvm, Con{th, tt}, orig_vs, orig_scs, orig_trs, res_reg, merge_blk}, is_tail)
    case Succ{_} LTCmpCases{_, _, Nil{}, _, _, _, _}: cfg_seal(st, TFail{1})
    case Succ{+p} LTCmpCases{+base_vm, +base_nvm, Con{Case{Con{_, Nil{}}, body}, Nil{}}, _, _, +res_reg, +merge_blk}:
      +st0 = st
      prev_mg = cfg_flag(st0, True{})
      +st2 = low_go(p, env, cfg_set_vm_nvm(st0, base_vm, base_nvm), LTExpr{body}, is_tail)
      cfg_fin_branch(st2, cfg_flag(st2, False{}), res_reg, cfg_res(st2), merge_blk, prev_mg)
    case Succ{p} LTCmpCases{base_vm, base_nvm, Con{Case{Con{PWild{}, Nil{}}, body}, Con{_, _}}, va, vb, res_reg, merge_blk}: low_go(p, env, st, LTCmpCases{base_vm, base_nvm, [Case{[PWild{}], body}], va, vb, res_reg, merge_blk}, is_tail)
    case Succ{+p} LTCmpCases{+base_vm, +base_nvm, Con{Case{Con{p_other, Nil{}}, body}, Con{rh, rt}}, +va, +vb, +res_reg, +merge_blk}:
      +st0 = st
      prev_mg = cfg_flag(st0, True{})
      +code = low_pat_code(env_map(env, 6), True{}, p_other)
      cop = Bool.pick(U32, U32.is_eq(code, 1), B5K_CMP_LT(), Bool.pick(U32, U32.is_eq(code, 2), B5K_CMP_EQ(), B5K_CMP_GT()))
      +st_c = cfg_alloc(st0, False{})
      +st_o = cfg_alloc(cfg_emit(st_c, ICmp{cfg_res(st_c), cop, va, vb}), True{})
      +st_f = cfg_alloc(st_o, True{})
      +nxt_blk = cfg_res(st_f)
      st1 = cfg_start(cfg_seal(st_f, TBr{cfg_res(st_c), cfg_res(st_o), nxt_blk}), cfg_res(st_o))
      +st2 = low_go(p, env, cfg_set_vm_nvm(st1, base_vm, base_nvm), LTExpr{body}, is_tail)
      st3 = cfg_fin_branch(st2, cfg_flag(st2, False{}), res_reg, cfg_res(st2), merge_blk, prev_mg)
      low_go(p, env, cfg_start(st3, nxt_blk), LTCmpCases{base_vm, base_nvm, Con{rh, rt}, va, vb, res_reg, merge_blk}, is_tail)
    case Succ{+p} LTMatStart{+base_vm, +base_nvm, +cs1, +vscruts1, sc_scruts1}:
      +st_t = low_emit_tag_cache(vscruts1, env, st, cs1, 0, Nil{})
      +st2 = cfg_alloc(st_t, False{})
      +st3 = cfg_alloc(st2, True{})
      st4 = low_go(p, env, cfg_set_merged(st3, False{}), LTCases{base_vm, base_nvm, cs1, vscruts1, sc_scruts1, cfg_rlist(st_t), cfg_res(st2), cfg_res(st3)}, is_tail)
      cfg_end_merge(st4, base_vm, base_nvm, cfg_res(st3), cfg_res(st2))
    case Succ{+p} LTMatOne{_, _, s0, _, 1, _}: low_go(p, env, st, LTExpr{s0}, is_tail)
    case Succ{+p} LTMatOne{_, _, s0, _, 2, _}: (+st1 = low_go(p, env, st, LTExpr{s0}, False{}); low_emit_u32_intr(st1, 21, [cfg_res(st1)]))
    case Succ{+p} LTMatOne{+base_vm, +base_nvm, _, cs, _, CMHit{ea, eb}}:
      +st1 = low_go(p, env, st, LTExpr{ea}, False{})
      +st2 = low_go(p, env, st1, LTExpr{eb}, False{})
      +st3 = cfg_alloc(st2, False{})
      +st4 = cfg_alloc(st3, True{})
      st5 = low_go(p, env, cfg_set_merged(st4, False{}), LTCmpCases{base_vm, base_nvm, cs, cfg_res(st1), cfg_res(st2), cfg_res(st3), cfg_res(st4)}, is_tail)
      cfg_end_merge(st5, base_vm, base_nvm, cfg_res(st4), cfg_res(st3))
    case Succ{+p} LTMatOne{+base_vm, +base_nvm, +s0, cs, _, CMNone{}}: (+st1 = low_go(p, env, st, LTExprs{[s0], Nil{}}, False{}); low_go(p, env, st1, LTMatStart{base_vm, base_nvm, cs, cfg_rlist(st1), low_exprs_sc_codes(env, base_vm, base_nvm, [s0])}, is_tail))
    case Succ{_} LTAppFn{_, _, fid, _, vargs, True{}, _}: low_app_direct(st, fid, vargs, is_tail)
    case Succ{_} LTAppFn{_, _, fid, +ar, +vargs, False{}, True{}}: (+st1 = low_app_direct(st, fid, low_take_u32(U32.to_nat(ar), vargs), False{}); low_apply_chain(low_drop(U32, U32.to_nat(ar), vargs), st1, cfg_res(st1)))
    case Succ{p} LTAppFn{sym, +args, _, _, _, False{}, False{}}: (+tmp = U32.add(env_sym(env, False{}), U32.add(b5k_list_len(Expr, args), 2)); low_go(p, env, st, LTExpr{ELam{[Param{tmp, None{}, False{}, False{}}], EApp{EVar{sym}, b5k_list_app(Expr, args, [EVar{tmp}])}}}, False{}))
    case Succ{p} LTAppSym{sym, args, 0, 0, 0}: (+st1 = low_go(p, env, st, LTExprs{args, Nil{}}, False{}); low_emit_ctor_expr(env, st1, sym, cfg_rlist(st1)))
    case Succ{+p} LTAppSym{+sym, +args, 0, 0, fv}:
      +fid0 = U32.sub(fv, 1)
      +ar0 = um_get0(env_map(env, 3), fid0)
      +sa_fid1 = um_get(env_map(env, 2), env_str_app(env))
      +use_sa = Bool.and(Bool.and(U32.is_ne(ar0, 2), U32.is_eq(b5k_list_len(Expr, args), 2)), Bool.and(U32.is_ne(sa_fid1, 0), b5k_str_eq(symtab_name(env_syms(env), sym), "String.append")))
      +fid = Bool.pick(U32, use_sa, U32.sub(sa_fid1, 1), fid0)
      +ar = Bool.pick(U32, use_sa, 2, ar0)
      fargs = low_filter_erased(args, um_get(env_map(env, 4), fid), 0)
      +st1 = low_go(p, env, st, LTExprs{fargs, Nil{}}, False{})
      +vargs = cfg_rlist(st1)
      +nargs = b5k_u32_list_len(vargs)
      low_go(p, env, st1, LTAppFn{sym, args, fid, ar, vargs, U32.is_eq(nargs, ar), U32.is_gt(nargs, ar)}, is_tail)
    case Succ{p} LTAppSym{sym, Con{a, Nil{}}, 0, +icode, _}: low_go(p, env, st, LTAppIntr1{sym, a, icode, low_intr_is_bin(icode)}, False{})
    case Succ{p} LTAppIntr1{sym, a, _, True{}}: (+tmp = env_sym(env, False{}); low_go(p, env, st, LTExpr{ELam{[Param{tmp, None{}, False{}, False{}}], EApp{EVar{sym}, [a, EVar{tmp}]}}}, False{}))
    case Succ{p} LTAppIntr1{_, +a, icode, False{}}:
      +icode2 = low_shift_code(env_syms(env), env_map(env, 6), icode, [a])
      +st1 = low_go(p, env, st, LTExprs{Bool.pick(List<&2, Expr>, Bool.and(U32.is_ge(icode2, 60), U32.is_lt(icode2, 100)), Nil{}, [a]), Nil{}}, False{})
      low_emit_u32_intr(st1, icode2, cfg_rlist(st1))
    case Succ{p} LTAppSym{_, +args, 0, +icode, _}:
      +icode2 = low_shift_code(env_syms(env), env_map(env, 6), icode, args)
      +st1 = low_go(p, env, st, LTExprs{Bool.pick(List<&2, Expr>, Bool.and(U32.is_ge(icode2, 60), U32.is_lt(icode2, 100)), low_drop(Expr, 1n, args), args), Nil{}}, False{})
      low_emit_u32_intr(st1, icode2, cfg_rlist(st1))
    case Succ{p} LTAppSym{_, args, lv, _, _}: (+st1 = low_go(p, env, st, LTExprs{args, Nil{}}, False{}); low_apply_chain(cfg_rlist(st1), st1, U32.sub(lv, 1)))
    case Succ{p} LTVar{+sym, 0, 0}:
      +ic = low_intr_code(env_map(env, 5), sym)
      +t1 = env_sym(env, False{})
      +t2 = U32.add(t1, 1)
      is_u1 = Bool.or(Bool.and(U32.is_ge(ic, 19), U32.is_le(ic, 23)), Bool.or(Bool.or(U32.is_eq(ic, 26), U32.is_eq(ic, 27)), Bool.or(Bool.and(U32.is_ge(ic, 50), U32.is_le(ic, 53)), Bool.or(Bool.and(U32.is_ge(ic, 137), U32.is_le(ic, 153)), Bool.or(U32.is_eq(ic, 158), Bool.or(U32.is_eq(ic, 160), Bool.or(U32.is_eq(ic, 161), Bool.or(U32.is_eq(ic, 165), U32.is_eq(ic, 186)))))))))
      e = Bool.pick(Expr, is_u1, ELam{[Param{t1, None{}, False{}, False{}}], EApp{EVar{sym}, [EVar{t1}]}}, ELam{[Param{t1, None{}, False{}, False{}}], ELam{[Param{t2, None{}, False{}, False{}}], EApp{EVar{sym}, [EVar{t1}, EVar{t2}]}}})
      low_go(p, env, st, Bool.pick(LowTask, U32.is_zero(ic), LTExpr{ECtr{sym, Nil{}}}, LTExpr{e}), False{})
    case Succ{p} LTVar{+sym, 0, +fid1}:
      +fid = U32.sub(fid1, 1)
      +ar = um_get0(env_map(env, 3), fid)
      +t1 = env_sym(env, False{})
      +t2 = U32.add(t1, 1)
      e = Bool.pick(Expr, U32.is_eq(ar, 2), ELam{[Param{t1, None{}, False{}, False{}}], ELam{[Param{t2, None{}, False{}, False{}}], EApp{EVar{sym}, [EVar{t1}, EVar{t2}]}}}, ELam{[Param{t1, None{}, False{}, False{}}], EApp{EVar{sym}, [EVar{t1}]}})
      low_go(p, env, st, Bool.pick(LowTask, U32.is_zero(ar), LTExpr{EApp{EVar{sym}, Nil{}}}, LTExpr{e}), False{})
    case Succ{_} LTVar{_, lv, _}: cfg_set_res(st, U32.sub(lv, 1))
    case Succ{_} LTExpr{ENum{v}}: low_emit_const(st, v)
    case Succ{_} LTExpr{EFlt{bits}}: (+st1 = cfg_alloc(st, False{}); cfg_emit(st1, IFlt{cfg_res(st1), bits}))
    case Succ{_} LTExpr{EChr{c}}: low_emit_const(st, c)
    case Succ{_} LTExpr{EUnit{}}: low_emit_ctor(st, 7, Nil{})
    case Succ{_} LTExpr{EStr{s}}: low_str_lit(s, st)
    case Succ{p} LTExpr{EVar{+sym}}: (+st0 = st; low_go(p, env, st0, LTVar{sym, um_get(cfg_map(st0, False{}), sym), um_get(env_map(env, 2), sym)}, is_tail))
    case Succ{p} LTExpr{ERef{sym}}: low_go(p, env, st, LTExpr{EVar{sym}}, is_tail)
    case Succ{+p} LTExpr{EOp{+op, +a, +b}}:
      +st0 = st
      +is_add = Bool.or(U32.is_eq(op, 19), Bool.and(U32.is_zero(op), Bool.or(low_is_num_expr(16n, env, cfg_map(st0, False{}), cfg_map(st0, True{}), a), low_is_num_expr(16n, env, cfg_map(st0, False{}), cfg_map(st0, True{}), b))))
      +is_nat = Bool.and(U32.is_zero(op), Bool.or(low_is_nat_expr(8n, env, a), low_is_nat_expr(8n, env, b)))
      +st1 = low_go(p, env, st0, LTExpr{a}, False{})
      +st2 = low_go(p, env, st1, LTExpr{b}, False{})
      low_emit_op_go(is_add, U32.is_zero(op), is_nat, env, st2, op, cfg_res(st1), cfg_res(st2))
    case Succ{p} LTExpr{EUnOp{1, a}}: low_go(p, env, st, LTExpr{a}, is_tail)
    case Succ{p} LTExpr{EUnOp{+op, a}}: (+st1 = low_go(p, env, st, LTExpr{a}, False{}); low_emit_un(st1, Bool.pick(U32, U32.is_eq(op, 9), 1, op), cfg_res(st1)))
    case Succ{+p} LTLetUnbox{pa, pb, UArrGet{a, i, sc}, +body}:
      +st0 = st
      +st1 = low_go(p, env, st0, LTExpr{a}, False{})
      +st2 = low_go(p, env, st1, LTExpr{i}, False{})
      +st3 = low_emit_arr_one(st2, 78, [cfg_res(st1), cfg_res(st2)])
      st4 = low_match_pats_sc(64n, env, st3, [pa, pb], [cfg_res(st1), cfg_res(st3)], [0, sc], body, 0, False{})
      cfg_set_vm_nvm(low_go(p, env, st4, LTExpr{body}, is_tail), cfg_map(st0, False{}), cfg_map(st0, True{}))
    case Succ{+p} LTLetUnbox{pa, pb, UArrOp2{aop, args, sc1}, +body}:
      +st0 = st
      +st1 = low_go(p, env, st0, LTExprs{args, Nil{}}, False{})
      +st2 = cfg_alloc(st1, False{})
      +st3 = cfg_alloc(st2, False{})
      st4 = low_match_pats_sc(64n, env, cfg_emit(st3, IArrOp{[cfg_res(st2), cfg_res(st3)], aop, cfg_rlist(st1)}), [pa, pb], [cfg_res(st2), cfg_res(st3)], [0, sc1], body, 0, False{})
      cfg_set_vm_nvm(low_go(p, env, st4, LTExpr{body}, is_tail), cfg_map(st0, False{}), cfg_map(st0, True{}))
    case Succ{+p} LTLetUnbox{pa, pb, UArrPair{+a, +b}, +body}:
      +st0 = st
      sa = low_expr_sc_code(env, cfg_map(st0, False{}), cfg_map(st0, True{}), a)
      sb = low_expr_sc_code(env, cfg_map(st0, False{}), cfg_map(st0, True{}), b)
      +st1 = low_go(p, env, st0, LTExpr{a}, False{})
      +st2 = low_go(p, env, st1, LTExpr{b}, False{})
      st3 = low_match_pats_sc(64n, env, st2, [pa, pb], [cfg_res(st1), cfg_res(st2)], [sa, sb], body, 0, False{})
      cfg_set_vm_nvm(low_go(p, env, st3, LTExpr{body}, is_tail), cfg_map(st0, False{}), cfg_map(st0, True{}))
    case Succ{+p} LTLetUnbox{pa, pb, UArrNone{val}, body}: low_go(p, env, st, LTLetPat{PPair{pa, pb}, val, body}, is_tail)
    case Succ{+p} LTLetPat{pat, +val, +body}:
      +st0 = st
      val_sc = low_expr_sc_code(env, cfg_map(st0, False{}), cfg_map(st0, True{}), val)
      +st1 = low_go(p, env, st0, LTExpr{val}, False{})
      st2 = low_match_pats_sc(64n, env, st1, [pat], [cfg_res(st1)], [val_sc], body, 0, False{})
      cfg_set_vm_nvm(low_go(p, env, st2, LTExpr{body}, is_tail), cfg_map(st0, False{}), cfg_map(st0, True{}))
    case Succ{+p} LTExpr{ELet{PPair{pa, pb}, val, body}}: (+st0 = st; low_go(p, env, st0, LTLetUnbox{pa, pb, low_unbox_pair(env, cfg_map(st0, False{}), val), body}, is_tail))
    case Succ{+p} LTExpr{ELet{PCtr{+sym, Con{+pa, Con{+pb, Nil{}}}}, +val, +body}}: (+st0 = st; low_go(p, env, st0, Bool.pick(LowTask, U32.is_eq(um_get(env_map(env, 6), sym), 13), LTLetUnbox{pa, pb, low_unbox_pair(env, cfg_map(st0, False{}), val), body}, LTLetPat{PCtr{sym, [pa, pb]}, val, body}), is_tail))
    case Succ{+p} LTExpr{ELet{pat, val, body}}: low_go(p, env, st, LTLetPat{pat, val, body}, is_tail)
    case Succ{+p} LTExpr{EIf{cond, ENum{1}, ENum{0}}}: low_go(p, env, st, LTExpr{cond}, is_tail)
    case Succ{+p} LTExpr{EIf{cond, ENum{0}, ENum{1}}}: (+st1 = low_go(p, env, st, LTExpr{cond}, False{}); low_emit_u32_intr(st1, 21, [cfg_res(st1)]))
    case Succ{+p} LTExpr{EIf{cond, t, f}}:
      +st0 = st
      +base_vm = cfg_map(st0, False{})
      +base_nvm = cfg_map(st0, True{})
      +st1 = low_go(p, env, st0, LTExpr{cond}, False{})
      +st2 = cfg_alloc(st1, True{})
      +st3 = cfg_alloc(st2, True{})
      +st4 = cfg_alloc(st3, True{})
      +st5 = cfg_alloc(st4, False{})
      +st6 = low_go(p, env, cfg_start(cfg_seal(st5, TBr{cfg_res(st1), cfg_res(st2), cfg_res(st3)}), cfg_res(st2)), LTExpr{t}, is_tail)
      +st7 = cfg_fin_branch(st6, cfg_flag(st6, False{}), cfg_res(st5), cfg_res(st6), cfg_res(st4), False{})
      +st8 = low_go(p, env, cfg_set_vm_nvm(cfg_start(st7, cfg_res(st3)), base_vm, base_nvm), LTExpr{f}, is_tail)
      cfg_end_merge(cfg_fin_branch(st8, cfg_flag(st8, False{}), cfg_res(st5), cfg_res(st8), cfg_res(st4), cfg_flag(st7, True{})), base_vm, base_nvm, cfg_res(st4), cfg_res(st5))
    case Succ{p} LTExpr{ECtr{sym, fs}}: (+st1 = low_go(p, env, st, LTExprs{fs, Nil{}}, False{}); low_emit_ctor_expr(env, st1, sym, cfg_rlist(st1)))
    case Succ{p} LTExpr{EApp{ERef{sym}, args}}: low_go(p, env, st, LTExpr{EApp{EVar{sym}, args}}, is_tail)
    case Succ{p} LTExpr{EApp{EVar{+sym}, args}}: (+st0 = st; low_go(p, env, st0, LTAppSym{sym, args, um_get(cfg_map(st0, False{}), sym), low_intr_code(env_map(env, 5), sym), um_get(env_map(env, 2), sym)}, is_tail))
    case Succ{+p} LTExpr{EApp{other, args}}: (+st1 = low_go(p, env, st, LTExpr{other}, False{}); +st2 = low_go(p, env, st1, LTExprs{args, Nil{}}, False{}); low_apply_chain(cfg_rlist(st2), st2, cfg_res(st1)))
    case Succ{+p} LTExpr{EMat{Con{val, Nil{}}, Con{Case{Con{PPair{pa, pb}, Nil{}}, body}, Nil{}}}}: (+st0 = st; low_go(p, env, st0, LTLetUnbox{pa, pb, low_unbox_pair(env, cfg_map(st0, False{}), val), body}, is_tail))
    case Succ{+p} LTExpr{EMat{Con{+s0, Nil{}}, +cs}}:
      +st0 = st
      +base_vm = cfg_map(st0, False{})
      +base_nvm = cfg_map(st0, True{})
      low_go(p, env, st0, LTMatOne{base_vm, base_nvm, s0, cs, low_bool_match_kind(env_map(env, 6), cs), low_cmp_match_info(env, base_vm, s0, cs)}, is_tail)
    case Succ{+p} LTExpr{EMat{+scruts, +cs}}:
      +st0 = st
      +base_vm = cfg_map(st0, False{})
      +base_nvm = cfg_map(st0, True{})
      sc_scruts = low_exprs_sc_codes(env, base_vm, base_nvm, scruts)
      +st1 = low_go(p, env, st0, LTExprs{scruts, Nil{}}, False{})
      low_go(p, env, st1, LTMatStart{base_vm, base_nvm, cs, cfg_rlist(st1), sc_scruts}, is_tail)
    case Succ{p} LTExpr{EAnn{+v, typ}}:
      +syms = env_syms(env)
      +th = low_type_head(syms, typ)
      +is_f = b5k_str_eq(th, "F32")
      +is_u = b5k_str_eq(th, "U32")
      +is_n = b5k_str_eq(th, "Nat")
      +is_num = Bool.or(is_f, Bool.or(is_u, is_n))
      +v2 = Bool.pick(Expr, is_num, low_map_ops(32n, Bool.pick(U32, is_f, 1, Bool.pick(U32, is_n, 2, 0)), v), v)
      v3 = Bool.pick(Expr, Bool.or(String.is_empty(th), is_num), v2, low_map_custom_ops(32n, syms, th, v2))
      low_go(p, env, st, LTExpr{v3}, is_tail)
    case Succ{p} LTExpr{EList{es}}: (+st1 = low_go(p, env, st, LTExprs{es, Nil{}}, False{}); low_list_chain(cfg_rlist(st1), st1))
    case Succ{+p} LTExpr{EPair{a, b}}: (+st1 = low_go(p, env, st, LTExpr{a}, False{}); +st2 = low_go(p, env, st1, LTExpr{b}, False{}); low_emit_ctor(st2, 6, [cfg_res(st1), cfg_res(st2)]))
    case Succ{+p} LTExpr{EArrNew{es}}:
      match es:
        case Con{v, Con{dep, Con{_, Nil{}}}}:
          +st1 = low_go(p, env, st, LTExpr{v}, False{})
          +st2 = low_go(p, env, st1, LTExpr{dep}, False{})
          low_emit_arr_one(st2, 71, [cfg_res(st2), cfg_res(st1)])
        case Con{v, Con{ENum{+len}, Nil{}}}:
          +st1 = low_go(p, env, st, LTExpr{v}, False{})
          +st2 = low_emit_const(st1, low_const_log2_go(32n, len, 0, U32.is_le(len, 1)))
          low_emit_arr_one(st2, 71, [cfg_res(st2), cfg_res(st1)])
        case Con{v, Con{len, Nil{}}}: low_go(p, env, st, LTExpr{EApp{EVar{env_sym(env, True{})}, [len, v]}}, is_tail)
        case _: low_emit_const(st, 0)
    case Succ{+p} LTExpr{EArrGet{a, i}}: (+st1 = low_go(p, env, st, LTExpr{a}, False{}); +st2 = low_go(p, env, st1, LTExpr{i}, False{}); low_emit_arr_get_pair(st2, cfg_res(st1), cfg_res(st2)))
    case Succ{+p} LTExpr{EArrSet{a, i, +v}}:
      +st0 = st
      +st1 = low_go(p, env, st0, LTExpr{a}, False{})
      +st2 = low_go(p, env, st1, LTExpr{i}, False{})
      +st3 = low_go(p, env, st2, LTExpr{v}, False{})
      low_emit_arr_one(st3, Bool.pick(U32, low_is_num_expr(16n, env, cfg_map(st0, False{}), cfg_map(st0, True{}), v), 79, 73), [cfg_res(st1), cfg_res(st2), cfg_res(st3)])
    case Succ{p} LTExpr{EDo{+ss}}:
      +e2 = low_env_for_do(env, ss)
      low_go(p, e2, st, LTExpr{low_desugar_do(e2, ss)}, is_tail)
    case Succ{p} LTExpr{ELam{ps, +body}}:
      match ps:
        case Nil{}: low_go(p, env, st, LTExpr{body}, is_tail)
        case Con{p0, Con{p1, rest}}: low_go(p, env, st, LTExpr{low_curry_lam(Con{p0, Con{p1, rest}}, body)}, is_tail)
        case Con{+p0, Nil{}}:
          +st0 = st
          +is_lm = low_lam_is_mat(p0, body)
          +sc = U32.add(env_sym(env, False{}), 32)
          +p1 = Bool.pick(Param, is_lm, Param{sc, None{}, False{}, True{}}, p0)
          +b1 = Bool.pick(Expr, is_lm, low_lam_rw_body(env, sc, U32.add(env_sym(env, False{}), 64), body), body)
          +fvs = b5k_list_rev(U32, fv_go(U32.to_nat(2048), cfg_map(st0, False{}), fv_add_params([p1], UM0{}), UIExpr{b1}, Nil{}))
          +ncaps = b5k_u32_list_len(fvs)
          +ar = U32.add(ncaps, 1)
          lam_st0 = low_bind_params(env_syms(env), env_map(env, 6), [p1], low_bind_lam_caps(cfg_map(st0, True{}), fvs, cfg_new(4294967295, ar, cfg_bank(st0)), 0, b1), ncaps, b1)
          +lam_st1 = low_go(p, env, lam_st0, LTExpr{b1}, True{})
          bk2 = low_bank_finish_lam(ncaps, ar, cfg_seal(lam_st1, TRet{cfg_res(lam_st1)}))
          +st1 = cfg_alloc(cfg_set_bank(st0, bk2), False{})
          cfg_emit(st1, ICtor{cfg_res(st1), low_bank_next_cid(cfg_bank(lam_st1)), low_lookup_fvs(fvs, cfg_map(st0, False{}))})
    case Succ{_} _: low_emit_const(st, 0)
# Synthetic Runtime Dispatchers (__b5k_apply, __b5k_io_run, __b5k_io_cont)
def low_mk_apply_arms(entries: List<&2, CloEntry>, +blk_id: U32, arms: List<&2, IrSwitchArm>, blks: List<&2, IrBlock>) -> List<&2, IrBlock> & List<&2, IrSwitchArm>:
  match entries:
    case Nil{}: (b5k_list_rev(IrBlock, blks), b5k_list_rev(IrSwitchArm, arms))
    case Con{CloEntry{cid, +fid, +ncaps}, t}:
      st0 = low_alloc_regs_go(U32.to_nat(ncaps), cfg_new(0, 2, CloBank{0, 0, Nil{}, Nil{}, Nil{}, 0, Nil{}, Map.new(&2, U32)}), Nil{})
      +res_reg = U32.add(2, ncaps)
      +cap_regs = cfg_rlist(st0)
      ops = Bool.pick(List<&2, IrOp>, U32.is_zero(ncaps), [ISink{0}, ICallDirect{res_reg, fid, [1]}], [ITake{cap_regs, 0}, ICallDirect{res_reg, fid, b5k_list_app(U32, cap_regs, [1])}])
      low_mk_apply_arms(t, U32.add(blk_id, 1), Con{IrArm{cid, blk_id}, arms}, Con{IrBlock{blk_id, ops, TRet{res_reg}}, blks})
def low_max_caps_one(e: CloEntry, acc: U32) -> U32:
  CloEntry{_, _, nc} = e
  U32.max(acc, nc)
def low_mk_apply_fn(+entries: List<&2, CloEntry>) -> IrFn:
  low_un_pair(List<&2, IrBlock>, List<&2, IrSwitchArm>, IrFn, low_mk_apply_arms(entries, 3, Nil{}, Nil{}), arm_blks => arms =>
    IrFn{0, "__b5k_apply", 2, U32.max(5, U32.add(4, opt_foldl0(~CloEntry, ~U32, ~low_max_caps_one, entries, 0))), True{}, False{}, False{},
      Con{IrBlock{0, [ITag{2, 0}], TSwitch{2, Con{IrArm{38, 1}, arms}, 2}},
      Con{IrBlock{1, [ISink{0}, IConst{3, 0}, ICtor{4, 12, [1, 3]}], TRet{4}},
      Con{IrBlock{2, Nil{}, TFail{1}}, arm_blks}}}})
# Main Return Type & show_desc Builder
type ShowInfo is Data:
  ShowInfo{is_pure: Bool, desc: List<&2, U32>, names: List<&2, String>}
def low_find_law_ret(laws: List<&2, LawDef>, +msym: U32) -> Maybe<&2, Expr>:
  match laws:
    case Nil{}: None{}
    case Con{LawDef{s, _, ret}, t}: Bool.pick(Maybe<&2, Expr>, U32.is_eq(s, msym), Some{ret}, low_find_law_ret(t, msym))
def low_find_main_ret(defs: List<&2, Def>, +laws: List<&2, LawDef>, +msym: U32) -> Maybe<&2, Expr>:
  match defs:
    case Nil{}: low_find_law_ret(laws, msym)
    case Con{Def{s, _, Some{r}, _, _, _}, t}: Bool.pick(Maybe<&2, Expr>, U32.is_eq(s, msym), Some{r}, low_find_main_ret(t, laws, msym))
    case Con{Def{s, _, None{}, _, _, _}, t}: Bool.pick(Maybe<&2, Expr>, U32.is_eq(s, msym), low_find_law_ret(laws, msym), low_find_main_ret(t, laws, msym))
def low_amp_spine(fuel: Nat, e: Expr, acc: List<&2, Expr>) -> List<&2, Expr>:
  match fuel e:
    case 0n _: Con{e, acc}
    case 1n+p EOp{5, l, r}: low_amp_spine(p, l, Con{r, acc})
    case 1n+_ other: Con{other, acc}
def low_amp_build(es: List<&2, Expr>) -> Expr:
  match es:
    case Nil{}: EUnit{}
    case Con{h, Nil{}}: h
    case Con{h, t}: EOp{5, h, low_amp_build(t)}
def low_reassoc_amp(fuel: Nat, e: Expr) -> Expr: low_amp_build(low_amp_spine(fuel, e, Nil{}))
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
  r1 = Bool.pick(U32, b5k_str_eq(hd, "Unit"), 10, Bool.pick(U32, b5k_str_eq(hd, "Equal"), 11, Bool.pick(U32, b5k_str_eq(hd, "Maybe"), 12, Bool.pick(U32, b5k_str_eq(hd, "Result"), 13, Bool.pick(U32, b5k_str_eq(hd, "Either"), 14, Bool.pick(U32, b5k_str_eq(hd, "Sigma"), 15, Bool.pick(U32, b5k_str_eq(hd, "Array"), 16, 0)))))))
  r0 = Bool.pick(U32, b5k_str_eq(hd, "Cmp"), 8, Bool.pick(U32, b5k_str_eq(hd, "Pair"), 9, r1))
  r = Bool.pick(U32, b5k_str_eq(hd, "List"), 7, Bool.pick(U32, b5k_str_eq(hd, "Bool"), 6, Bool.pick(U32, b5k_str_eq(hd, "String"), 5, Bool.pick(U32, b5k_str_eq(hd, "Char"), 4, r0))))
  Bool.pick(U32, b5k_str_eq(hd, "IO"), 1, Bool.pick(U32, b5k_str_eq(hd, "F32"), 2, Bool.pick(U32, b5k_str_eq(hd, "Nat"), 3, r)))
type ShowBuild is Data:
  ShowBuild{words: List<&2, U32>, names: List<&2, String>, nnames: U32, seen: List<&2, ShowSeen>}
type EqWork is Data:
  EWOne{a: Expr, b: Expr}
  EWList{xs: List<&2, Expr>, ys: List<&2, Expr>}
def low_eq_go(+fuel: Nat, w: EqWork) -> Bool:
  match fuel w:
    case 0n _: False{}
    case 1n+_ EWList{Nil{}, Nil{}}: True{}
    case 1n++p EWList{Con{x, xt}, Con{y, yt}}: Bool.and(low_eq_go(p, EWOne{x, y}), low_eq_go(p, EWList{xt, yt}))
    case 1n+_ EWList{_, _}: False{}
    case 1n+_ EWOne{EVar{s1}, EVar{s2}}: U32.is_eq(s1, s2)
    case 1n+_ EWOne{ERef{s1}, ERef{s2}}: U32.is_eq(s1, s2)
    case 1n+_ EWOne{ENum{v1}, ENum{v2}}: U32.is_eq(v1, v2)
    case 1n++p EWOne{EApp{f1, a1}, EApp{f2, a2}}: Bool.and(low_eq_go(p, EWOne{f1, f2}), low_eq_go(p, EWList{a1, a2}))
    case 1n++p EWOne{EOp{o1, a1, b1}, EOp{o2, a2, b2}}: Bool.and(U32.is_eq(o1, o2), Bool.and(low_eq_go(p, EWOne{a1, a2}), low_eq_go(p, EWOne{b1, b2})))
    case 1n+p EWOne{EAnn{v1, _}, e2}: low_eq_go(p, EWOne{v1, e2})
    case 1n+p EWOne{e1, EAnn{v2, _}}: low_eq_go(p, EWOne{e1, v2})
    case 1n+_ EWOne{_, _}: False{}
type ShowSeen is Data:
  ShowSeen{ty: Expr, base: U32}
def low_show_seen_get(xs: List<&2, ShowSeen>, +ty: Expr) -> Maybe<&2, U32>:
  match xs:
    case Nil{}: None{}
    case Con{ShowSeen{s, b}, t}: Bool.pick(Maybe<&2, U32>, low_eq_go(32n, EWOne{s, ty}), Some{b}, low_show_seen_get(t, ty))
def low_find_type(ts: List<&2, TypeDef>, +sym: U32) -> Maybe<&2, TypeDef>:
  match ts:
    case Nil{}: None{}
    case Con{TypeDef{+s, p, d, c}, t}: Bool.pick(Maybe<&2, TypeDef>, U32.is_eq(s, sym), Some{TypeDef{s, p, d, c}}, low_find_type(t, sym))
def low_type_head_sym(e: Expr) -> Maybe<&2, U32>:
  match e:
    case EVar{s}: Some{s}
    case ERef{s}: Some{s}
    case EApp{f, _}: low_type_head_sym(f)
    case _: None{}
def low_type_args(e: Expr) -> List<&2, Expr>:
  match e:
    case EApp{_, args}: args
    case _: Nil{}
def low_penult_expr(es: List<&2, Expr>, def_e: Expr) -> Expr:
  match es:
    case Con{a, Con{_, Nil{}}}: a
    case Con{_, t}: low_penult_expr(t, def_e)
    case Nil{}: def_e
def low_unwrap_lam(e: Expr) -> Expr:
  match e:
    case ELam{_, b}: b
    case other: other
def low_subst_lookup(ps: List<&2, Param>, args: List<&2, Expr>, +sym: U32) -> Maybe<&2, Expr>:
  match ps args:
    case Con{Param{s, _, _, _}, pt} Con{a, at}: Bool.pick(Maybe<&2, Expr>, U32.is_eq(s, sym), Some{a}, low_subst_lookup(pt, at, sym))
    case _ _: None{}
type SubstWork is Data:
  SWOne{e: Expr}
  SWMany{es: List<&2, Expr>}
  SWCases{cs: List<&2, Case>}
type SubstRes is Data:
  SROne{e: Expr}
  SRMany{es: List<&2, Expr>}
  SRCases{cs: List<&2, Case>}
def low_subst_one(r: SubstRes) -> Expr:
  match r:
    case SROne{e}: e
    case _: ENum{0}
def low_subst_many(r: SubstRes) -> List<&2, Expr>:
  match r:
    case SRMany{es}: es
    case _: Nil{}
def low_subst_cases(r: SubstRes) -> List<&2, Case>:
  match r:
    case SRCases{cs}: cs
    case _: Nil{}
def low_subst_go(+fuel: Nat, +ps: List<&2, Param>, +args: List<&2, Expr>, w: SubstWork) -> SubstRes:
  match fuel w:
    case 0n SWOne{e}: SROne{e}
    case 0n SWMany{es}: SRMany{es}
    case 0n SWCases{cs}: SRCases{cs}
    case 1n+_ SWMany{Nil{}}: SRMany{Nil{}}
    case 1n++p SWMany{Con{h, t}}: SRMany{Con{low_subst_one(low_subst_go(p, ps, args, SWOne{h})), low_subst_many(low_subst_go(p, ps, args, SWMany{t}))}}
    case 1n+_ SWCases{Nil{}}: SRCases{Nil{}}
    case 1n++p SWCases{Con{Case{cps, body}, t}}: SRCases{Con{Case{cps, low_subst_one(low_subst_go(p, ps, args, SWOne{body}))}, low_subst_cases(low_subst_go(p, ps, args, SWCases{t}))}}
    case 1n+_ SWOne{EVar{+s}}: SROne{Maybe.default(&2, Expr, low_subst_lookup(ps, args, s), EVar{s})}
    case 1n++p SWOne{EApp{f, es}}: SROne{EApp{low_subst_one(low_subst_go(p, ps, args, SWOne{f})), low_subst_many(low_subst_go(p, ps, args, SWMany{es}))}}
    case 1n+p SWOne{ECtr{s, es}}: SROne{ECtr{s, low_subst_many(low_subst_go(p, ps, args, SWMany{es}))}}
    case 1n++p SWOne{EOp{op, a, b}}: SROne{EOp{op, low_subst_one(low_subst_go(p, ps, args, SWOne{a})), low_subst_one(low_subst_go(p, ps, args, SWOne{b}))}}
    case 1n+p SWOne{ELam{lps, b}}: SROne{ELam{lps, low_subst_one(low_subst_go(p, ps, args, SWOne{b}))}}
    case 1n+p SWOne{EUnOp{op, a}}: SROne{EUnOp{op, low_subst_one(low_subst_go(p, ps, args, SWOne{a}))}}
    case 1n++p SWOne{EAnn{v, ty}}: SROne{EAnn{low_subst_one(low_subst_go(p, ps, args, SWOne{v})), low_subst_one(low_subst_go(p, ps, args, SWOne{ty}))}}
    case 1n++p SWOne{EMat{scrs, cs}}: SROne{EMat{low_subst_many(low_subst_go(p, ps, args, SWMany{scrs})), low_subst_cases(low_subst_go(p, ps, args, SWCases{cs}))}}
    case 1n+_ SWOne{other}: SROne{other}
def low_subst_expr(fuel: Nat, ps: List<&2, Param>, args: List<&2, Expr>, e: Expr) -> Expr:
  low_subst_one(low_subst_go(fuel, ps, args, SWOne{e}))
def low_ctors_hdr_len(cs: List<&2, CtorDef>, acc: U32) -> U32:
  match cs:
    case Nil{}: acc
    case Con{CtorDef{_, _, fs}, t}: low_ctors_hdr_len(t, U32.add(acc, U32.add(3, U32.mul(2, b5k_list_len(Param, fs)))))
def low_sb_pre(pre: List<&2, U32>, sb: ShowBuild) -> ShowBuild:
  ShowBuild{wb, nb, nnb, ss} = sb
  ShowBuild{b5k_list_app(U32, pre, wb), nb, nnb, ss}
def low_find_type_opt(ts: List<&2, TypeDef>, ms: Maybe<&2, U32>) -> Maybe<&2, TypeDef>:
  match ms:
    case Some{s}: low_find_type(ts, s)
    case None{}: None{}
type ShowTask is Data:
  STEnc{e: Expr, base: U32, names: List<&2, String>, nnames: U32, in_adt: Bool}
  STHead{code: U32, o: Expr, base: U32, names: List<&2, String>, nnames: U32, in_adt: Bool}
  STTupA{b: Expr, nnames: U32, fst_idx: U32, sb: ShowBuild, in_adt: Bool}
  STBinA{b: Expr, nnames: U32, c0: U32, c1: U32, idx_a: U32, sb: ShowBuild}
  STAdtOpt{mt: Maybe<&2, TypeDef>, o: Expr, base: U32, names: List<&2, String>, nnames: U32}
  STAdtCs{cs: List<&2, CtorDef>, tps: List<&2, Param>, targs: List<&2, Expr>, sub_idx: U32, hdr_acc: List<&2, U32>, sub_acc: List<&2, U32>, names: List<&2, String>, nnames: U32}
  STAdtFs{fs: List<&2, Param>, j: U32, rest_cs: List<&2, CtorDef>, tps: List<&2, Param>, targs: List<&2, Expr>, sub_idx: U32, hdr_acc: List<&2, U32>, sub_acc: List<&2, U32>, names: List<&2, String>, nnames: U32}
  STAdtFHit{hit: Maybe<&2, U32>, ft: Expr, ft_rest: List<&2, Param>, j: U32, rest_cs: List<&2, CtorDef>, tps: List<&2, Param>, targs: List<&2, Expr>, sub_idx: U32, hdr_acc: List<&2, U32>, sub_acc: List<&2, U32>, names: List<&2, String>, nnames: U32}
  STAdtFSub{sb: ShowBuild, ft_rest: List<&2, Param>, j: U32, rest_cs: List<&2, CtorDef>, tps: List<&2, Param>, targs: List<&2, Expr>, sub_idx: U32, hdr_acc: List<&2, U32>, sub_acc: List<&2, U32>}
def low_find_def(ds: List<&2, Def>, +sym: U32) -> Maybe<&2, Def>:
  match ds:
    case Nil{}: None{}
    case Con{Def{+s, ps, ret, body, imp, uns}, t}: Bool.pick(Maybe<&2, Def>, U32.is_eq(s, sym), Some{Def{s, ps, ret, body, imp, uns}}, low_find_def(t, sym))
def low_strip_tilde1(e: Expr) -> Expr:
  match e:
    case EUnOp{1, x}: x
    case other: other
def low_strip_tildes(es: List<&2, Expr>) -> List<&2, Expr>: opt_mapl0(~Expr, ~Expr, ~low_strip_tilde1, es)
type PmStep is Data:
  PmFail{}
  PmNext{pfs: List<&2, Pat>, efs: List<&2, Expr>, ps: List<&2, Param>, vs: List<&2, Expr>}
def low_pm_step(+syms: SymTab, pat: Pat, e: Expr, pt: List<&2, Pat>, et: List<&2, Expr>, ps: List<&2, Param>, vs: List<&2, Expr>) -> PmStep:
  match pat e:
    case PWild{} _: PmNext{pt, et, ps, vs}
    case PVar{s, _} ex: PmNext{pt, et, Con{Param{s, None{}, False{}, False{}}, ps}, Con{ex, vs}}
    case PNum{n} ENum{m}: Bool.pick(PmStep, U32.is_eq(n, m), PmNext{pt, et, ps, vs}, PmFail{})
    case PCtr{s1, Nil{}} ENum{0}: Bool.pick(PmStep, b5k_str_eq(symtab_name(syms, s1), "Zero"), PmNext{pt, et, ps, vs}, PmFail{})
    case PCtr{s1, Con{p1, Nil{}}} ENum{+m}: Bool.pick(PmStep, Bool.and(U32.is_gt(m, 0), b5k_str_eq(symtab_name(syms, s1), "Succ")), PmNext{Con{p1, pt}, Con{ENum{U32.sub(m, 1)}, et}, ps, vs}, PmFail{})
    case PCtr{s1, pfs} ECtr{s2, efs}: Bool.pick(PmStep, U32.is_eq(s1, s2), PmNext{b5k_list_app(Pat, pfs, pt), b5k_list_app(Expr, efs, et), ps, vs}, PmFail{})
    case PPair{pa, pb} EPair{ea, eb}: PmNext{Con{pa, Con{pb, pt}}, Con{ea, Con{eb, et}}, ps, vs}
    case _ _: PmFail{}
type PmRes is Data:
  PmNone{}
  PmHit{ps: List<&2, Param>, vs: List<&2, Expr>}
def low_pm_go(fuel: Nat, +syms: SymTab, st: PmStep) -> PmRes:
  match fuel st:
    case 0n _: PmNone{}
    case _ PmFail{}: PmNone{}
    case _ PmNext{Nil{}, Nil{}, ps, vs}: PmHit{ps, vs}
    case 1n+p PmNext{Con{pf, pt}, Con{ef, et}, ps, vs}: low_pm_go(p, syms, low_pm_step(syms, pf, ef, pt, et, ps, vs))
    case _ _: PmNone{}
type UnfTask is Data:
  UTExpr{e: Expr}
  UTList{es: List<&2, Expr>, acc: List<&2, Expr>, cs: List<&2, Case>, orig: Expr}
  UTCases{scrs: List<&2, Expr>, cs: List<&2, Case>, orig: Expr}
  UTCasesK{r: PmRes, scrs: List<&2, Expr>, body: Expr, t: List<&2, Case>, orig: Expr}
  UTAppDef{md: Maybe<&2, Def>, args: List<&2, Expr>, orig: Expr}
def low_unf_app_body_k(ok: Bool, dps: List<&2, Param>, body: Expr, +args: List<&2, Expr>) -> Maybe<&2, Expr>:
  match ok dps body:
    case True{} _ _: Some{low_subst_expr(16n, dps, low_strip_tildes(args), body)}
    case False{} Nil{} ELam{+lps, lbody}: Bool.pick(Maybe<&2, Expr>, U32.is_eq(b5k_list_len(Param, lps), b5k_list_len(Expr, args)), Some{low_subst_expr(16n, lps, low_strip_tildes(args), lbody)}, None{})
    case _ _ _: None{}

def low_unfold_go(fuel: Nat, +syms: SymTab, +ds: List<&2, Def>, task: UnfTask) -> Expr:
  match fuel task:
    case 0n UTExpr{ex}: ex
    case 0n UTList{_, _, _, orig}: orig
    case 0n UTCases{_, _, orig}: orig
    case 0n UTCasesK{_, _, _, _, orig}: orig
    case 0n UTAppDef{_, _, orig}: orig
    case 1n+p UTExpr{EUnOp{1, a}}: low_unfold_go(p, syms, ds, UTExpr{a})
    case 1n+p UTExpr{EAnn{v, _}}: low_unfold_go(p, syms, ds, UTExpr{v})
    case 1n+p UTExpr{EMat{+scrs, +cs}}: low_unfold_go(p, syms, ds, UTList{scrs, Nil{}, cs, EMat{scrs, cs}})
    case 1n+p UTExpr{EVar{+s}}: low_unfold_go(p, syms, ds, Bool.pick(UnfTask, U32.is_zero(low_show_code(symtab_name(syms, s))), UTAppDef{low_find_def(ds, s), Nil{}, EVar{s}}, UTExpr{EVar{s}}))
    case 1n+p UTExpr{EApp{EVar{+s}, +args}}: low_unfold_go(p, syms, ds, Bool.pick(UnfTask, U32.is_zero(low_show_code(symtab_name(syms, s))), UTAppDef{low_find_def(ds, s), args, EApp{EVar{s}, args}}, UTExpr{EApp{EVar{s}, args}}))
    case _ UTExpr{other}: other
    case 1n+p UTList{Nil{}, acc, cs, orig}: low_unfold_go(p, syms, ds, UTCases{b5k_list_rev(Expr, acc), cs, orig})
    case 1n++p UTList{Con{h, t}, acc, cs, orig}: low_unfold_go(p, syms, ds, UTList{t, Con{low_unfold_go(p, syms, ds, UTExpr{h}), acc}, cs, orig})
    case _ UTCases{_, Nil{}, orig}: orig
    case 1n+p UTCases{+scrs, Con{Case{pats, body}, t}, orig}: low_unfold_go(p, syms, ds, UTCasesK{low_pm_go(32n, syms, PmNext{pats, scrs, Nil{}, Nil{}}), scrs, body, t, orig})
    case 1n+p UTCasesK{PmHit{bps, bvs}, _, body, _, _}: low_unfold_go(p, syms, ds, UTExpr{low_subst_expr(16n, bps, bvs, body)})
    case 1n+p UTCasesK{PmNone{}, scrs, _, t, orig}: low_unfold_go(p, syms, ds, UTCases{scrs, t, orig})
    case _ UTAppDef{None{}, _, orig}: orig
    case 1n+p UTAppDef{Some{Def{_, +dps, _, body, _, _}}, +args, orig}: low_unfold_go(p, syms, ds, UTExpr{Maybe.default(&2, Expr, low_unf_app_body_k(U32.is_eq(b5k_list_len(Param, dps), b5k_list_len(Expr, args)), dps, body, args), orig)})
def low_unfold_type(fuel: Nat, syms: SymTab, ds: List<&2, Def>, e: Expr) -> Expr: low_unfold_go(fuel, syms, ds, UTExpr{e})
def low_ctors_has_name(+syms: SymTab, cs: List<&2, CtorDef>, +nm: String) -> Bool:
  match cs:
    case Nil{}: False{}
    case Con{CtorDef{s, _, _}, t}: Bool.or(b5k_str_eq(symtab_name(syms, s), nm), low_ctors_has_name(syms, t, nm))
def low_nat_is_local(+syms: SymTab, mt: Maybe<&2, TypeDef>) -> Bool:
  match mt:
    case Some{TypeDef{_, _, _, cs}}: Bool.not(low_ctors_has_name(syms, cs, "Zero"))
    case None{}: False{}
type UnitFamT is Data:
  UFE{e: Expr}
  UFC{cs: List<&2, Case>, acc: U32}
  UFD{s: U32, md: Maybe<&2, Def>}
def low_unit_fam_go(fuel: Nat, +syms: SymTab, +defs: List<&2, Def>, +fn_sym: U32, t: UnitFamT) -> U32:
  match fuel t:
    case 0n _: 0
    case 1n+_ UFE{EUnit{}}: 2
    case 1n+_ UFE{EEmpty{}}: 1
    case 1n+_ UFE{EVar{s}}:
      +nm = symtab_name(syms, s)
      Bool.pick(U32, b5k_str_eq(nm, "Unit"), 2, Bool.pick(U32, b5k_str_eq(nm, "Empty"), 1, 0))
    case 1n+p UFE{EApp{EVar{+s}, _}}:
      Bool.pick(U32, U32.is_eq(s, fn_sym), 1, Bool.pick(U32, U32.is_eq(fn_sym, 4294967295), low_unit_fam_go(p, syms, defs, fn_sym, UFD{s, low_find_def(defs, s)}), 0))
    case 1n+p UFD{s, Some{Def{_, _, _, body, _, _}}}: low_unit_fam_go(p, syms, defs, s, UFE{body})
    case _ UFD{_, None{}}: 0
    case 1n+p UFE{EMat{_, cs}}: low_unit_fam_go(p, syms, defs, fn_sym, UFC{cs, 0})
    case _ UFE{_}: 0
    case _ UFC{Nil{}, acc}: acc
    case 1n++p UFC{Con{Case{_, body}, rest}, +acc}:
      +c = low_unit_fam_go(p, syms, defs, fn_sym, UFE{body})
      Bool.pick(U32, U32.is_zero(c), 0, low_unit_fam_go(p, syms, defs, fn_sym, UFC{rest, U32.max(acc, c)}))
def low_def_is_unit_fam_k(syms: SymTab, defs: List<&2, Def>, s: U32, md: Maybe<&2, Def>) -> Bool:
  match md:
    case Some{Def{_, _, _, body, _, _}}: U32.is_eq(low_unit_fam_go(16n, syms, defs, s, UFE{body}), 2)
    case None{}: False{}
def low_def_is_unit_fam(+syms: SymTab, +defs: List<&2, Def>, e: Expr) -> Bool:
  match e:
    case EApp{EVar{+s}, _}: low_def_is_unit_fam_k(syms, defs, s, low_find_def(defs, s))
    case EMat{_, cs}: U32.is_eq(low_unit_fam_go(16n, syms, defs, 4294967295, UFC{cs, 0}), 2)
    case _: False{}
def low_is_u32_box(syms: SymTab, cs: List<&2, CtorDef>) -> Bool:
  match cs:
    case Con{CtorDef{csym, _, _}, Nil{}}: b5k_str_eq(symtab_name(syms, csym), "U32")
    case _: False{}
def low_show_go(+fuel: Nat, +syms: SymTab, +types: List<&2, TypeDef>, +defs: List<&2, Def>, +cbs: U32Map, +seen: List<&2, ShowSeen>, task: ShowTask) -> ShowBuild:
  match fuel task:
    case 0n STEnc{_, _, names, nnames, _}: ShowBuild{[0], names, nnames, seen}
    case 0n STHead{_, _, _, names, nnames, _}: ShowBuild{[0], names, nnames, seen}
    case 0n STTupA{_, _, _, sb, _}: sb
    case 0n STBinA{_, _, _, _, _, sb}: sb
    case 0n STAdtOpt{_, _, _, names, nnames}: ShowBuild{[0], names, nnames, seen}
    case 0n STAdtCs{_, _, _, _, hdr, sub, names, nnames}: ShowBuild{b5k_list_app(U32, hdr, sub), names, nnames, seen}
    case 0n STAdtFs{_, _, _, _, _, _, hdr, sub, names, nnames}: ShowBuild{b5k_list_app(U32, hdr, sub), names, nnames, seen}
    case 0n STAdtFHit{_, _, _, _, _, _, _, _, hdr, sub, names, nnames}: ShowBuild{b5k_list_app(U32, hdr, sub), names, nnames, seen}
    case 0n STAdtFSub{sb, _, _, _, _, _, _, _, _}: sb
    case 1n+p STTupA{b, nnames, +fst_idx, ShowBuild{+wa, na, nna, _}, in_adt}: (+snd_idx = U32.add(fst_idx, b5k_u32_list_len(wa)); low_sb_pre(b5k_list_app(U32, [7, 1, 1, nnames, 6, 2, 0, fst_idx, 1, snd_idx], wa), low_show_go(p, syms, types, defs, cbs, seen, STEnc{low_unfold_type(64n, syms, defs, b), snd_idx, na, nna, in_adt})))
    case 1n+p STBinA{b, +nnames, c0, c1, +idx_a, ShowBuild{+wa, na, nna, _}}: (+idx_b = U32.add(idx_a, b5k_u32_list_len(wa)); low_sb_pre(b5k_list_app(U32, [7, 1, 2, nnames, c0, 1, 0, idx_a, U32.add(nnames, 1), c1, 1, 0, idx_b], wa), low_show_go(p, syms, types, defs, cbs, seen, STEnc{low_reassoc_amp(64n, b), idx_b, na, nna, True{}})))
    case 1n+_ STAdtOpt{None{}, o, _, +names, +nnames}: Bool.pick(ShowBuild, low_def_is_unit_fam(syms, defs, o), ShowBuild{[7, 1, 1, nnames, 7, 0], b5k_list_app(String, names, ["Unit"]), U32.add(nnames, 1), seen}, ShowBuild{[0], names, nnames, seen})
    case 1n+p STAdtOpt{Some{TypeDef{_, tps, _, +ctors}}, +o, +base, +names, +nnames}:
      +sub_idx = U32.add(base, U32.add(3, low_ctors_hdr_len(ctors, 0)))
      low_if(ShowBuild, low_is_u32_box(syms, ctors), _ => ShowBuild{[0], names, nnames, seen}, _ => low_show_go(p, syms, types, defs, cbs, Con{ShowSeen{o, base}, seen}, STAdtCs{ctors, tps, low_type_args(o), sub_idx, [7, 1, b5k_list_len(CtorDef, ctors)], Nil{}, names, nnames}))
    case 1n+_ STAdtCs{Nil{}, _, _, _, hdr, sub, names, nnames}: ShowBuild{b5k_list_app(U32, hdr, sub), names, nnames, seen}
    case 1n+p STAdtCs{Con{CtorDef{+csym, _, +fs}, rest_cs}, tps, targs, sub_idx, hdr, sub, names, +nnames}: (hdr2 = b5k_list_app(U32, hdr, [nnames, um_get0(cbs, csym), b5k_list_len(Param, fs)]); low_show_go(p, syms, types, defs, cbs, seen, STAdtFs{fs, 0, rest_cs, tps, targs, sub_idx, hdr2, sub, b5k_list_app(String, names, [symtab_name(syms, csym)]), U32.add(nnames, 1)}))
    case 1n+p STAdtFs{Nil{}, _, rest_cs, tps, targs, sub_idx, hdr, sub, names, nnames}: low_show_go(p, syms, types, defs, cbs, seen, STAdtCs{rest_cs, tps, targs, sub_idx, hdr, sub, names, nnames})
    case 1n+p STAdtFs{Con{Param{_, fty, _, _}, ft_rest}, j, rest_cs, +tps, +targs, sub_idx, hdr, sub, names, nnames}: (+ft = low_unfold_type(64n, syms, defs, low_subst_expr(16n, tps, targs, Maybe.default(&2, Expr, fty, ENum{0}))); low_show_go(p, syms, types, defs, cbs, seen, STAdtFHit{low_show_seen_get(seen, ft), ft, ft_rest, j, rest_cs, tps, targs, sub_idx, hdr, sub, names, nnames}))
    case 1n+p STAdtFHit{Some{rec_b}, _, ft_rest, +j, rest_cs, tps, targs, sub_idx, hdr, sub, names, nnames}: low_show_go(p, syms, types, defs, cbs, seen, STAdtFs{ft_rest, U32.add(j, 1), rest_cs, tps, targs, sub_idx, b5k_list_app(U32, hdr, [j, rec_b]), sub, names, nnames})
    case 1n++p STAdtFHit{None{}, ft, ft_rest, j, rest_cs, tps, targs, +sub_idx, hdr, sub, names, nnames}: low_show_go(p, syms, types, defs, cbs, seen, STAdtFSub{low_show_go(p, syms, types, defs, cbs, seen, STEnc{low_reassoc_amp(64n, ft), sub_idx, names, nnames, True{}}), ft_rest, j, rest_cs, tps, targs, sub_idx, hdr, sub})
    case 1n+p STAdtFSub{ShowBuild{+sw, sn, snn, ss}, ft_rest, +j, rest_cs, tps, targs, +sub_idx, hdr, sub}: low_show_go(p, syms, types, defs, cbs, ss, STAdtFs{ft_rest, U32.add(j, 1), rest_cs, tps, targs, U32.add(sub_idx, b5k_u32_list_len(sw)), b5k_list_app(U32, hdr, [j, sub_idx]), b5k_list_app(U32, sub, sw), sn, snn})
    case 1n++p STHead{code, +o, +base, +names, +nnames, +in_adt}:
      match code:
        case 2: ShowBuild{[1], names, nnames, seen}
        case 3:
          +mt = low_find_type_opt(types, low_type_head_sym(o))
          Bool.pick(ShowBuild, low_nat_is_local(syms, mt), low_show_go(p, syms, types, defs, cbs, seen, STAdtOpt{mt, o, base, names, nnames}), ShowBuild{[2], names, nnames, seen})
        case 4: ShowBuild{[3, 0], names, nnames, seen}
        case 5: ShowBuild{[4], names, nnames, seen}
        case 6: ShowBuild{[7, 0, 2, nnames, 18, 0, U32.add(nnames, 1), 14, 0], b5k_list_app(String, names, ["False", "True"]), U32.add(nnames, 2), seen}
        case 7: low_sb_pre([7, 1, 2, nnames, 4, 0, U32.add(nnames, 1), 5, 2, 0, U32.add(base, 13), 1, base], low_show_go(p, syms, types, defs, cbs, seen, STEnc{low_reassoc_amp(64n, low_type_elem(o)), U32.add(base, 13), b5k_list_app(String, names, ["Nil", "Con"]), U32.add(nnames, 2), True{}}))
        case 8: ShowBuild{[7, 1, 3, nnames, 15, 0, U32.add(nnames, 1), 16, 0, U32.add(nnames, 2), 17, 0], b5k_list_app(String, names, ["LT", "EQ", "GT"]), U32.add(nnames, 3), seen}
        case 9:
          match o:
            case EApp{_, Con{a, Con{b, Nil{}}}}: (+fst_idx = U32.add(base, 10); low_show_go(p, syms, types, defs, cbs, seen, STTupA{b, nnames, fst_idx, low_show_go(p, syms, types, defs, cbs, seen, STEnc{low_reassoc_amp(64n, a), fst_idx, b5k_list_app(String, names, ["Tuple"]), U32.add(nnames, 1), in_adt}), in_adt}))
            case _: ShowBuild{[0], names, nnames, seen}
        case 10: ShowBuild{[7, 1, 1, nnames, 7, 0], b5k_list_app(String, names, ["Unit"]), U32.add(nnames, 1), seen}
        case 11: ShowBuild{[5], names, nnames, seen}
        case 12: low_sb_pre([7, 1, 2, nnames, 8, 0, U32.add(nnames, 1), 9, 1, 0, U32.add(base, 11)], low_show_go(p, syms, types, defs, cbs, seen, STEnc{low_reassoc_amp(64n, low_type_elem(o)), U32.add(base, 11), b5k_list_app(String, names, ["None", "Some"]), U32.add(nnames, 2), True{}}))
        case 13: (+idx_a = U32.add(base, 13); +targs = low_type_args(o); low_show_go(p, syms, types, defs, cbs, seen, STBinA{low_last_expr(targs, ENum{0}), nnames, 10, 11, idx_a, low_show_go(p, syms, types, defs, cbs, seen, STEnc{low_reassoc_amp(64n, low_penult_expr(targs, ENum{0})), idx_a, b5k_list_app(String, names, ["Fail", "Done"]), U32.add(nnames, 2), True{}})}))
        case 14: (+idx_a = U32.add(base, 13); +targs = low_type_args(o); low_show_go(p, syms, types, defs, cbs, seen, STBinA{low_last_expr(targs, ENum{0}), nnames, 20, 21, idx_a, low_show_go(p, syms, types, defs, cbs, seen, STEnc{low_reassoc_amp(64n, low_penult_expr(targs, ENum{0})), idx_a, b5k_list_app(String, names, ["Inl", "Inr"]), U32.add(nnames, 2), True{}})}))
        case 15: (+targs = low_type_args(o); +fst_idx = U32.add(base, 10); low_show_go(p, syms, types, defs, cbs, seen, STTupA{low_unwrap_lam(low_last_expr(targs, ENum{0})), nnames, fst_idx, low_show_go(p, syms, types, defs, cbs, seen, STEnc{low_reassoc_amp(64n, low_penult_expr(targs, ENum{0})), fst_idx, b5k_list_app(String, names, ["Tuple"]), U32.add(nnames, 1), in_adt}), in_adt}))
        case 16:
          match in_adt:
            case False{}: low_show_go(p, syms, types, defs, cbs, seen, STHead{7, o, base, names, nnames, False{}})
            case True{}: low_sb_pre([6, U32.add(base, 3), 0], low_show_go(p, syms, types, defs, cbs, seen, STEnc{low_reassoc_amp(64n, low_type_elem(o)), U32.add(base, 3), names, nnames, True{}}))
        case _: low_show_go(p, syms, types, defs, cbs, seen, STAdtOpt{low_find_type_opt(types, low_type_head_sym(o)), o, base, names, nnames})
    case 1n+_ STEnc{EEq{_, _}, _, names, nnames, _}: ShowBuild{[5], names, nnames, seen}
    case 1n+_ STEnc{EOp{20, _, _}, _, names, nnames, _}: ShowBuild{[5], names, nnames, seen}
    case 1n+p STEnc{EAnn{v, _}, base, names, nnames, in_adt}: low_show_go(p, syms, types, defs, cbs, seen, STEnc{v, base, names, nnames, in_adt})
    case 1n++p STEnc{EOp{5, a, b}, base, names, +nnames, +in_adt}: (+fst_idx = U32.add(base, 10); low_show_go(p, syms, types, defs, cbs, seen, STTupA{b, nnames, fst_idx, low_show_go(p, syms, types, defs, cbs, seen, STEnc{low_reassoc_amp(64n, low_unfold_type(64n, syms, defs, a)), fst_idx, b5k_list_app(String, names, ["Tuple"]), U32.add(nnames, 1), in_adt}), in_adt}))
    case 1n+p STEnc{EAll{Param{0, _, _, _}, _}, _, names, nnames, _}: ShowBuild{[0], names, nnames, seen}
    case 1n+p STEnc{EAll{Param{_, Some{a}, _, _}, b}, base, names, nnames, in_adt}: low_show_go(p, syms, types, defs, cbs, seen, STEnc{EOp{5, a, b}, base, names, nnames, in_adt})
    case 1n+p STEnc{+o, base, names, nnames, in_adt}: low_show_go(p, syms, types, defs, cbs, seen, STHead{low_show_code(low_type_head(syms, o)), o, base, names, nnames, in_adt})
def low_show_from_sb(is_io: Bool, sb: ShowBuild) -> ShowInfo:
  ShowBuild{ws, ns, _, _} = sb
  Bool.pick(ShowInfo, is_io, ShowInfo{False{}, Nil{}, Nil{}}, ShowInfo{True{}, ws, ns})
def low_show_info(+syms: SymTab, types: List<&2, TypeDef>, +defs: List<&2, Def>, cbs: U32Map, mret: Maybe<&2, Expr>) -> ShowInfo:
  match mret:
    case None{}: ShowInfo{True{}, [0], Nil{}}
    case Some{e}: (+eu = low_unfold_type(64n, syms, defs, e); low_show_from_sb(U32.is_eq(low_show_code(low_type_head(syms, eu)), 1), low_show_go(U32.to_nat(2048), syms, types, defs, cbs, Nil{}, STEnc{low_reassoc_amp(64n, eu), 0, Nil{}, 0, False{}})))
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
def low_patch_main(ds: List<&2, Def>, +msym: U32, +syms: SymTab, +t1: U32, +t2: U32, +a2l: U32, +rty: Expr) -> List<&2, Def>:
  match ds:
    case Nil{}: Nil{}
    case Con{Def{+s, +ps, +ret, +body, +imp, +uns}, t}: (d2 = Bool.pick(Def, U32.is_eq(s, msym), Def{s, ps, ret, low_norm_arr(32n, syms, t1, t2, a2l, body, low_reassoc_amp(64n, rty)), imp, uns}, Def{s, ps, ret, body, imp, uns}); Con{d2, low_patch_main(t, msym, syms, t1, t2, a2l, rty)})
# Function & Book Lowering
type DefAcc is Data:
  DefAcc{fns_rev: List<&2, IrFn>, bank: CloBank}
def low_def_fin(syms: SymTab, +fid: U32, main_fid: U32, sym: U32, ar: U32, acc: List<&2, IrFn>, st: CfgSt) -> DefAcc:
  CfgSt{_, nregs, _, _, _, blks_rev, _, _, _, _, _, _, bk} = st
  DefAcc{Con{IrFn{fid, symtab_name(syms, sym), ar, nregs, False{}, False{}, U32.is_eq(fid, main_fid), b5k_list_rev(IrBlock, blks_rev)}, acc}, bk}
def low_env_for_ret(mret: Maybe<&2, Expr>, +env: LowEnv) -> LowEnv:
  match mret:
    case None{}: env
    case Some{r}: low_env_with_monad(low_type_head(env_syms(env), r), env)
def low_def(+env: LowEnv, laws: List<&2, LawDef>, +fid: U32, d: Def, da: DefAcc) -> DefAcc:
  LowEnv{+syms, _, _, _, _, _, _, _, _, _, skind, +main_fid, +main_pure, _, _, _, _, _} = env
  Def{+sym, +params, mret, +body, _, _} = d
  DefAcc{acc, bank} = da
  +ar = low_param_arity_live(syms, body, params, 0)
  mr = Maybe.or(&2, Expr, mret, low_find_law_ret(laws, sym))
  +st2 = low_go(U32.to_nat(2048), low_env_for_ret(mr, env), low_bind_params(syms, skind, params, cfg_new(fid, ar, bank), 0, body), LTExpr{body}, Bool.or(U32.is_ne(fid, main_fid), main_pure))
  +st1 = cfg_alloc(st2, False{})
  low_def_fin(syms, fid, main_fid, sym, ar, acc, Bool.pick(CfgSt, Bool.and(U32.is_eq(fid, main_fid), Bool.not(main_pure)), cfg_seal(cfg_emit(st1, ICallClosure{cfg_res(st1), 1, [cfg_res(st2)]}), TRet{cfg_res(st1)}), cfg_seal(st2, TRet{cfg_res(st2)})))
def low_defs(ds: List<&2, Def>, +env: LowEnv, +laws: List<&2, LawDef>, +fid: U32, da: DefAcc) -> DefAcc:
  match ds:
    case Nil{}: da
    case Con{d, t}: low_defs(t, env, laws, U32.add(fid, 1), low_def(env, laws, fid, d, da))
def low_maybe_patch_main(is_pure: Bool, mret: Maybe<&2, Expr>, +defs: List<&2, Def>, msym: U32, +syms: SymTab, t1: U32, t2: U32, a2l: U32) -> List<&2, Def>:
  match is_pure mret:
    case True{} Some{+rty}: Bool.pick(List<&2, Def>, low_has_arr(32n, syms, rty), low_patch_main(defs, msym, syms, t1, t2, a2l, rty), defs)
    case _ _: defs
def low_udef_sym1(d: Def, acc: U32Map) -> U32Map:
  Def{s, _, _, _, _, _} = d
  um_set(acc, s, 1)
def low_filter_pdefs(+um: U32Map, ps: List<&2, Def>) -> List<&2, Def>:
  match ps:
    case Nil{}: Nil{}
    case Con{Def{+s, a, b, c, d, e}, t}: (+rest = low_filter_pdefs(um, t); Bool.pick(List<&2, Def>, U32.is_ne(um_get(um, s), 0), rest, Con{Def{s, a, b, c, d, e}, rest}))
def b5k_lower_fin(da: DefAcc, ctors_rev: List<&2, IrCtor>, main_fid: U32, is_pure: Bool, sdesc: List<&2, U32>, snames: List<&2, String>) -> LowerRes:
  DefAcc{def_fns_rev, CloBank{_, _, lam_ctors_rev, lam_fns_rev, entries_rev, _, stats_rev, _}} = da
  LowerRes{True{}, "", IrProg{Con{low_mk_apply_fn(b5k_list_rev(CloEntry, entries_rev)), Con{IrFn{1, "__b5k_io_run", 2, 4, True{}, False{}, False{}, [IrBlock{0, [ISink{1}, ICtor{2, 38, Nil{}}, ICallDirect{3, 0, [0, 2]}], TRet{3}}]}, Con{IrFn{2, "__b5k_io_cont", 2, 3, True{}, False{}, False{}, [IrBlock{0, [ICallDirect{2, 0, [0, 1]}], TRet{2}}]}, b5k_list_app(IrFn, b5k_list_rev(IrFn, def_fns_rev), b5k_list_rev(IrFn, lam_fns_rev))}}}, b5k_list_app(IrCtor, b5k_list_rev(IrCtor, ctors_rev), b5k_list_rev(IrCtor, lam_ctors_rev)), b5k_list_rev(U32, stats_rev), main_fid, is_pure, Nil{}, sdesc, snames}}
def b5k_lower_run(si: ShowInfo, mret: Maybe<&2, Expr>, +st: SymTab, +sym_tmp: U32, sym_t2: U32, defs: List<&2, Def>, laws: List<&2, LawDef>, ca: CtorTabAcc, fa: FnTabAcc) -> LowerRes:
  ShowInfo{+is_pure, sdesc, snames} = si
  CtorTabAcc{_, next_cid, ctor_by_sym, ctor_smask, ctor_single, ctor_arity, ctor_owner, ctors_rev} = ca
  FnTabAcc{next_fid, fn_by_sym, fn_arity, fn_emask, +main_fid, main_sym} = fa
  defs2 = low_maybe_patch_main(is_pure, mret, defs, main_sym, st, sym_tmp, sym_t2, Maybe.default(&2, U32, symtab_lookup(st, "Array.to_list"), 0))
  b5k_lower_fin(low_defs(defs2, LowEnv{st, ctor_by_sym, ctor_smask, ctor_single, ctor_arity, ctor_owner, fn_by_sym, fn_arity, fn_emask, low_seed_u32_map(st, low_intr_specs(), UM0{}), low_seed_u32_map(st, low_kind_specs(), UM0{}), main_fid, is_pure, Maybe.default(&2, U32, symtab_lookup(st, "IO.bind"), 0), Maybe.default(&2, U32, symtab_lookup(st, "IO.pure"), 0), Maybe.default(&2, U32, symtab_lookup(st, "__b5k_str_append"), 0), sym_tmp, Maybe.default(&2, U32, symtab_lookup(st, "__arr_len"), 0)}, laws, 3, DefAcc{Nil{}, CloBank{next_fid, next_cid, Nil{}, Nil{}, Nil{}, 0, Nil{}, Map.new(&2, U32)}}), ctors_rev, main_fid, is_pure, sdesc, snames)
def b5k_lower_s2(+cta: CtorTabAcc, +fta: FnTabAcc, sr1: SymRes, sr2: SymRes, types: List<&2, TypeDef>, +defs: List<&2, Def>, +laws: List<&2, LawDef>) -> LowerRes:
  CtorTabAcc{_, _, ctor_by_sym, _, _, _, _, _} = cta
  FnTabAcc{_, _, _, _, _, +main_sym} = fta
  SymRes{_, sym_tmp} = sr1
  SymRes{+st, sym_t2} = sr2
  +mret = low_find_main_ret(defs, laws, main_sym)
  b5k_lower_run(low_show_info(st, types, defs, ctor_by_sym, mret), mret, st, sym_tmp, sym_t2, defs, laws, cta, fta)
def b5k_lower_i1(cta: CtorTabAcc, fta: FnTabAcc, sr1: SymRes, types: List<&2, TypeDef>, defs: List<&2, Def>, laws: List<&2, LawDef>) -> LowerRes:
  SymRes{+s4, sym_tmp} = sr1
  b5k_lower_s2(cta, fta, SymRes{s4, sym_tmp}, symtab_intern(s4, "__b5k_t2"), types, defs, laws)
def b5k_lower_cta(+cta: CtorTabAcc, types: List<&2, TypeDef>, +defs: List<&2, Def>, laws: List<&2, LawDef>) -> LowerRes:
  CtorTabAcc{+syms2, _, _, _, _, _, _, _} = cta
  b5k_lower_i1(cta, low_add_defs(syms2, defs, FnTabAcc{3, UM0{}, UM0{}, UM0{}, 3, 0}), symtab_intern(syms2, "__b5k_tmp"), types, defs, laws)
def b5k_lower_pre(pr: ParseRes, +types: List<&2, TypeDef>, +udefs: List<&2, Def>, laws: List<&2, LawDef>) -> LowerRes:
  ParseRes{_, _, Book{_, pdefs, _, +syms1}} = pr
  skind0 = low_seed_u32_map(syms1, low_kind_specs(), UM0{})
  defs = b5k_list_app(Def, low_filter_pdefs(opt_foldl0(~Def, ~U32Map, ~low_udef_sym1, udefs, UM0{}), pdefs), udefs)
  b5k_lower_cta(low_add_types(skind0, types, low_seed_core(low_core_specs(), CtorTabAcc{syms1, 0, UM0{}, UM0{}, UM0{}, UM0{}, UM0{}, Nil{}})), types, defs, laws)
def b5k_lower(book: Book) -> LowerRes:
  Book{types, udefs, laws, syms} = book
  b5k_lower_pre(b5k_parse(b5k_prelude_src(), syms), types, udefs, laws)
