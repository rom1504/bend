import Base

# Exact compiler.bend definitions (certified by AGY-W3B-STRHASH dual-seed AST pin)
def p88_string_eq_go(a: String, b: String, same: Bool) -> Bool:
  match a b same:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h, t} result: False{}
    case SCon{h, t} SNil{} result: False{}
    case SCon{h1, t1} SCon{h2, t2} False{}: False{}
    case SCon{h1, t1} SCon{h2, t2} True{}:
      p88_string_eq_go(t1, t2, Char.is_eq(h1, h2))

def p98_eq_finish(same: Bool, left: String, right: String) -> Bool:
  same

def p88_string_eq(+a: String, +b: String) -> Bool:
  p98_eq_finish(p88_string_eq_go(a, b, True{}), a, b)

@unsafe
def index_hash(
  +name: String,
  +acc: U32,
) -> U32:
  match name:
    case SNil{}:
      acc
    case SCon{h, rest}:
      index_hash(rest, U32.mul(U32.xor(acc, Char.to_u32(h)), 16777619))

type KTerm is Data:
  KTerm{+tag: String, +name: String, +id: U32, +quant: U32, +kids: List<&2, KTerm>, +removed: List<&2, String>, +originBegin: U32, +originEnd: U32}
  KLambda{+name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +removed: List<&2,String>, +originBegin: U32, +originEnd: U32, +quantityPresent: Bool}
  KLiteral{+kind: String, +number: U32, +text: String, +originBegin: U32, +originEnd: U32}

def p98_tag_eq_read(term: KTerm, key: String) -> Bool:
  match term:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}:
      p88_string_eq_go(tag, key, True{})
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      p88_string_eq("Lam", key)
    case KLiteral{kind, number, text, begin, end}:
      p88_string_eq("Lit", key)

def p98_tag_eq_finish(same: Bool, term: KTerm, key: String) -> Bool:
  same

def p98_tag_eq(+term: KTerm, +key: String) -> Bool:
  p98_tag_eq_finish(p98_tag_eq_read(term, key), term, key)

type BenchData is Data:
  BenchData{+s_eq1: String, +s_eq2: String, +s_d0: String, +s_dm: String, +s_de: String,
    +s_long1: String, +s_long2: String, +t_var: KTerm, +t_lam: KTerm, +t_lit: KTerm}

@unsafe
def bench_once(+d: BenchData) -> U32:
  match d:
    case BenchData{s_eq1, s_eq2, s_d0, s_dm, s_de, s_long1, s_long2, t_var, t_lam, t_lit}:
      +b0 = Bool.to_u32(p88_string_eq(s_eq1, s_eq2))
      +b1 = Bool.to_u32(p88_string_eq(s_eq1, s_d0))
      +b2 = Bool.to_u32(p88_string_eq(s_eq1, s_dm))
      +b3 = Bool.to_u32(p88_string_eq(s_eq1, s_de))
      +b4 = Bool.to_u32(p88_string_eq(s_long1, s_long2))
      +b5 = Bool.to_u32(p88_string_eq(s_long1, s_long1))
      +b6 = Bool.to_u32(p88_string_eq("", ""))
      +b7 = Bool.to_u32(String.eq(s_eq1, s_eq2))
      +h1 = index_hash(s_long1, 2166136261)
      +h2 = index_hash(s_eq1, h1)
      +t0 = Bool.to_u32(p98_tag_eq(t_var, "Var"))
      +t1 = Bool.to_u32(p98_tag_eq(t_var, "App"))
      +t2 = Bool.to_u32(p98_tag_eq(t_lam, "Lam"))
      +t3 = Bool.to_u32(p98_tag_eq(t_lit, "Lit"))
      +t4 = Bool.to_u32(p98_tag_eq(t_lit, "Lam"))
      +bits = U32.add(b0, U32.add(U32.mul(b1, 2), U32.add(U32.mul(b2, 4), U32.add(U32.mul(b3, 8),
        U32.add(U32.mul(b4, 16), U32.add(U32.mul(b5, 32), U32.add(U32.mul(b6, 64), U32.add(U32.mul(b7, 128),
        U32.add(U32.mul(t0, 256), U32.add(U32.mul(t1, 512), U32.add(U32.mul(t2, 1024), U32.add(U32.mul(t3, 2048), U32.mul(t4, 4096)))))))))))))
      U32.xor(bits, h2)

@unsafe
def bench_step(+done: Bool, +n: U32, +d: BenchData, +acc: U32) -> U32:
  match done:
    case True{}: acc
    case False{}:
      +n1 = U32.sub(n, 1)
      bench_step(U32.is_eq(n1, 0), n1, d, U32.xor(U32.add(acc, bench_once(d)), n1))

def main() -> IO(Unit):
  +s_eq1 = String.append("p118borrow.read.", "p88_string_eq_go")
  +s_eq2 = String.append("p118borrow.read.", "p88_string_eq_go")
  +s_d0  = String.append("X118borrow.read.", "p88_string_eq_go")
  +s_dm  = String.append("p118borrow.read.", "p88_Xtring_eq_go")
  +s_de  = String.append("p118borrow.read.", "p88_string_eq_gX")
  +s_long1 = String.append("selfhost/compiler/native/x86_64/", "p113d_p118borrow_read_index_hash_long_identifier")
  +s_long2 = String.append("selfhost/compiler/native/x86_64/", "p113d_p118borrow_read_index_hash_long_identifier")
  +t_var : KTerm = KTerm{"Var", "x", 0, 0, [], [], 0, 0}
  +t_lam : KTerm = KLambda{"x", 0, 1, [], [], 0, 0, False{}}
  +t_lit : KTerm = KLiteral{"U32", 42, "42", 0, 0}
  +d : BenchData = BenchData{s_eq1, s_eq2, s_d0, s_dm, s_de, s_long1, s_long2, t_var, t_lam, t_lit}
  # 100,000 iters x 15 string/hash/tag ops = 1,500,000 calls!
  IO.print(U32.show(bench_step(False{}, 100000, d, 0)))
