# Exact index_find branches with dx pushed into each returned value.
# No raw pointers, runtime changes or production verifier edits.
@unsafe
def p131sc_bucket(ds: List<&2,KDef>, +name: String) -> U32:
  match ds:
    case Nil{}: 0
    case Con{h,rest}:
      kc(U32,p88_string_eq(dn(h),name),u => dx(h),u => p131sc_bucket(rest,name))

@unsafe
def p131sc_find(+tree: KDef, +name: String, +hash: U32, +bits: U32) -> U32:
  match tree:
    case KDef{label,kind,arity,+templates,typ,value,+ctors,native,unsafe}:
      kc(U32,p88_string_eq(kind,"Absent"),u => 0,
        u => kc(U32,U32.is_eq(templates,0),
          v => kc(U32,U32.is_eq(arity,hash),
            w => p131sc_bucket(ctors,name),w => 0),
          v => p131sc_find(index_child_list(ctors,
            Bool.not(U32.is_eq(U32.and(hash,templates),0))),name,hash,bits)))
    case KIndexLeaf{stored,bucket}:
      kc(U32,U32.is_eq(stored,hash),u => p131sc_bucket(bucket,name),u => 0)
    case KIndexNode{stored,+mask,+left,+right}:
      kc(U32,U32.is_eq(mask,0),
        u => kc(U32,U32.is_eq(stored,hash),
          v => p131sc_bucket([left,right],name),v => 0),
        u => kc(U32,U32.is_eq(U32.and(hash,mask),0),
          v => p131sc_find(left,name,hash,bits),
          v => p131sc_find(right,name,hash,bits)))

def p131sc_old(tree: KDef, name: String, hash: U32) -> U32:
  dx(index_find(tree,name,hash,32))

def p131sc_query(tree: KDef, name: String, hash: U32) -> U32:
  p131sc_old(tree,name,hash)

def p131sc_entry(name: String, capacity: U32) -> KDef:
  KDef{name,"local",3,capacity,atom("Absent"),atom("Absent"),[],False{},False{}}

def p131sc_legacy(kind: String, hash: U32, mask: U32, children: List<&2,KDef>) -> KDef:
  KDef{"",kind,hash,mask,atom("Absent"),atom("Absent"),children,False{},False{}}

def p131sc_pair(+tree: KDef, +name: String, +hash: U32) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(p131sc_old(tree,name,hash)))
    IO.print(U32.show(p131sc_find(tree,name,hash,32)))

def p131sc_check() -> IO(Unit):
  +a = p131sc_entry("alpha",11)
  +b = p131sc_entry("beta",22)
  +unicode = p131sc_entry("λ雪",33)
  +leaf : KDef = KIndexLeaf{7,[a,b]}
  +left : KDef = KIndexLeaf{2,[a]}
  +right : KDef = KIndexLeaf{3,[b]}
  +node : KDef = KIndexNode{0,1,left,right}
  +zero : KDef = KIndexNode{7,0,a,b}
  +odd : KDef = KIndexNode{0,99,missing(),missing()}
  do IO<Unit>:
    Unit <- p131sc_pair(leaf,"alpha",7)
    Unit <- p131sc_pair(leaf,"absent",7)
    Unit <- p131sc_pair(leaf,"alpha",8)
    Unit <- p131sc_pair(KIndexLeaf{7,[a,p131sc_entry("alpha",99)]},"alpha",7)
    Unit <- p131sc_pair(KIndexLeaf{7,[unicode]},"λ雪",7)
    Unit <- p131sc_pair(p131sc_legacy("Leaf",7,0,[a,b]),"beta",7)
    Unit <- p131sc_pair(p131sc_legacy("Absent",7,0,[a,b]),"alpha",7)
    Unit <- p131sc_pair(node,"alpha",2)
    Unit <- p131sc_pair(node,"beta",3)
    Unit <- p131sc_pair(node,"beta",2)
    Unit <- p131sc_pair(zero,"beta",7)
    Unit <- p131sc_pair(zero,"alpha",7)
    Unit <- p131sc_pair(zero,"beta",8)
    Unit <- p131sc_pair(KIndexNode{7,0,odd,p131sc_entry("",55)},"",7)
    Unit <- p131sc_pair(missing(),"",7)
    Unit <- p131sc_pair(p131sc_legacy("Node",0,1,[left,right]),"alpha",2)
    Unit <- IO.print(U32.show(dx(a)))
    IO.print(U32.show(dx(b)))

def p131sc_entries(n: Nat) -> List<&2,KDef>:
  match n:
    case 0n: []
    case 1n+rest:
      p131sc_entry("prefix-" ++ Nat.show(1n+rest),1) <> p131sc_entries(rest)

def p131sc_repeat(left: Nat, +tree: KDef, sum: U32) -> U32:
  match left:
    case 0n: sum
    case 1n+rest:
      p131sc_repeat(rest,tree,U32.add(sum,U32.add(
        p131sc_query(tree,"prefix-1",7),p131sc_query(tree,"absent",7))))

def p131sc_timed(repeats: Nat) -> IO(Unit):
  +tree : KDef = KIndexLeaf{7,p131sc_entries(64n)}
  do IO<Unit>:
    Unit <- IO.print(U32.show(U32.add(p131sc_query(tree,"prefix-1",7),p131sc_query(tree,"absent",7))))
    before : Nat <- IO.now()
    Unit <- IO.print(U32.show(p131sc_repeat(repeats,tree,0)))
    after : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(after,before)))

def p131sc_value(value: Maybe<&2,Nat>, fallback: Nat) -> Nat:
  match value:
    case None{}: fallback
    case Some{number}: number

def p131sc_args(args: List<String>, fallback: Nat) -> Nat:
  match args:
    case Nil{}: fallback
    case head <> tail: p131sc_args(tail,p131sc_value(Nat.read(head),fallback))

def p131sc_select(repeats: Nat) -> IO(Unit):
  match repeats:
    case 0n: p131sc_check()
    case 1n+rest: p131sc_timed(1n+rest)

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p131sc_select(p131sc_args(args,0n))
