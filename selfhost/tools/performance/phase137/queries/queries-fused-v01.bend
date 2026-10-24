import Base

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


type KTerm is Data:
  KTerm{+tag: String, +name: String, +id: U32, +quant: U32, +kids: List<&2, KTerm>, +removed: List<&2, String>, +originBegin: U32, +originEnd: U32}
  KLambda{+name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +removed: List<&2,String>, +originBegin: U32, +originEnd: U32, +quantityPresent: Bool}
  KLiteral{+kind: String, +number: U32, +text: String, +originBegin: U32, +originEnd: U32}

# Module: src/core/term.bend:30

type KDef is Data:
  KDef{+name: String, +kind: String, +arity: U32, +templates: U32, +typ: KTerm, +value: KTerm, +ctors: List<&2, KDef>, +native: Bool, +unsafe: Bool}
  KIndexLeaf{+hash: U32, +bucket: List<&2,KDef>}
  KIndexNode{+hash: U32, +mask: U32, +left: KDef, +right: KDef}

# Module: src/core/normalize.bend:367

law index_child_list:
  for +ds: List<&2, KDef>
  for +right: Bool
  KDef

# Module: src/core/index.bend:9
@unsafe
def index_child_list(ds, right):
  match ds:
    case Nil{}:
      missing()
    case Con{h, rest}:
      match right:
        case True{}: index_first(rest)
        case False{}: h

# Module: src/core/index.bend:61

law index_first:
  for +ds: List<&2, KDef>
  KDef

# Module: src/core/index.bend:13
@unsafe
def index_first(ds):
  match ds:
    case Nil{}:
      missing()
    case Con{h, rest}:
      h

# The public callers supply complete 32-bit hashes. `bits` remains in this
# internal ABI for the native identifier validator; paths use stored masks.

# Module: src/core/index.bend:71

law index_bucket:
  for +ds: List<&2, KDef>
  for +name: String
  KDef

# Compressed persistent binary trie. Internal nodes carry one discriminating
# hash bit; leaves retain exact-name buckets for complete 32-bit collisions.

# Module: src/core/index.bend:20
@unsafe
def index_bucket(ds, name):
  match ds:
    case Nil{}:
      missing()
    case Con{h, rest}:
      kc(KDef, p88_string_eq(dn(h), name), u => h, u => index_bucket(rest, name))

# Module: src/core/index.bend:134

law index_lookup:
  for +cache: KDef
  for +name: String
  KDef

# Module: src/core/index.bend:308
@unsafe
def index_lookup(cache, name):
  index_find(index_first(dc(cache)), name, index_hash(name, 2166136261), 32)

# Module: src/core/index.bend:263

law nc_ctor_owned:
  for +book: List<&2, KDef>
  for +name: String
  Bool

# Module: src/back/native/identity.bend:11
@unsafe
def nc_ctor_owned(book, name):
  match book:
    case Nil{}:
      False{}
    case Con{d, rest}:
      kc(Bool, p137q_kind_eq(d, "ADT"),
        u => kc(Bool, p137q_kind_eq(lookup(dc(d), name), "Ctr"), u => db(d), u => nc_ctor_owned(rest, name)),
        u => nc_ctor_owned(rest, name))

# Module: src/back/native/identity.bend:54

@unsafe
def kc(
  -A: Type,
  +b: Bool,
  yes: Unit -> A,
  no: Unit -> A,
) -> A:
  match b:
    case True{}:
      yes(Unit{})
    case False{}:
      no(Unit{})

# Module identity uses ns:name; only external output replaces its first colon.

# Module: src/core/term.bend:18

@unsafe
def kt(
  +tag: String,
  +name: String,
  +id: U32,
  +quant: U32,
  +kids: List<&2, KTerm>,
) -> KTerm:
  KTerm{tag, name, id, quant, kids, Nil{}, 0, 0}

# Module: src/core/term.bend:46

@unsafe
def atom(
  +tag: String,
) -> KTerm:
  kt(tag, "", 0, 0, Nil{})

# Module: src/core/term.bend:52

@unsafe
def qua(
  +q: U32,
) -> KTerm:
  kt("Qua", "", 0, q, Nil{})

# Module: src/core/term.bend:161

@unsafe
def typ(
  +q: U32,
) -> KTerm:
  kt("Typ", "", 0, 0, Con{qua(q), Nil{}})

# Module: src/core/term.bend:167

@unsafe
def dn(
  +d: KDef,
) -> String:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      name
    case KIndexLeaf{hash, bucket}: ""
    case KIndexNode{hash, mask, left, right}: ""

# Module: src/core/term.bend:194

@unsafe
def dk(
  +d: KDef,
) -> String:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      kind
    case KIndexLeaf{hash, bucket}: "IndexLeaf"
    case KIndexNode{hash, mask, left, right}: "IndexNode"

# Module: src/core/term.bend:204

@unsafe
def da(
  +d: KDef,
) -> U32:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      arity
    case KIndexLeaf{hash, bucket}: hash
    case KIndexNode{hash, mask, left, right}: hash

# Module: src/core/term.bend:214

@unsafe
def dx(
  +d: KDef,
) -> U32:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      templates
    case KIndexLeaf{hash, bucket}: 0
    case KIndexNode{hash, mask, left, right}: mask

# Module: src/core/term.bend:224

@unsafe
def dc(
  +d: KDef,
) -> List<&2, KDef>:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      ctors
    case KIndexLeaf{hash, bucket}: bucket
    case KIndexNode{hash, mask, left, right}: Con{left, Con{right, Nil{}}}

# Module: src/core/term.bend:254

@unsafe
def db(
  +d: KDef,
) -> Bool:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      native
    case KIndexLeaf{hash, bucket}: True{}
    case KIndexNode{hash, mask, left, right}: True{}

# Module: src/core/term.bend:264

@unsafe
def missing() -> KDef:
  KDef{"", "Absent", 0, 0,
    KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0},
    KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0},
    Nil{}, False{}, False{}}


@unsafe
def lookup(+book: List<&2,KDef>, +name: String) -> KDef:
  match book:
    case Nil{}: missing()
    case Con{+d,+rest}:
      kc(KDef, p137q_kind_eq(d, "BookCache"),
        u => index_lookup(d, name),
        u => kc(KDef, p137q_name_eq(d, name),
          v => d, v => lookup(rest, name)))


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

# Module: src/core/index.bend:37

@unsafe
def index_child(
  +tree: KDef,
  +right: Bool,
) -> KDef:
  match tree:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      index_child_list(ctors, right)
    case KIndexLeaf{hash, bucket}: index_child_list(bucket, right)
    case KIndexNode{hash, mask, left, next}:
      match right:
        case False{}: left
        case True{}: next

# Module: src/core/index.bend:51

@unsafe
def index_find(+tree: KDef, +name: String, +hash: U32, +bits: U32) -> KDef:
  match tree:
    case KDef{label, kind, arity, +templates, typ, value, +ctors, native, unsafe}:
      kc(KDef, p88_string_eq(kind, "Absent"), u => missing(),
        u => kc(KDef, U32.is_eq(templates, 0),
          v => kc(KDef, U32.is_eq(arity, hash),
            w => index_bucket(ctors, name), w => missing()),
          v => index_find(index_child_list(ctors,
            Bool.not(U32.is_eq(U32.and(hash, templates), 0))), name, hash, bits)))
    case KIndexLeaf{stored, bucket}:
      kc(KDef, U32.is_eq(stored, hash),
        u => index_bucket(bucket, name), u => missing())
    case KIndexNode{stored, +mask, +left, +right}:
      kc(KDef, U32.is_eq(mask, 0),
        u => kc(KDef, U32.is_eq(stored, hash),
          v => index_bucket([left, right], name), v => missing()),
        u => kc(KDef, U32.is_eq(U32.and(hash, mask), 0),
          v => index_find(left, name, hash, bits),
          v => index_find(right, name, hash, bits)))


@unsafe
def index_remove(
  +ds: List<&2, KDef>,
  +name: String,
) -> List<&2, KDef>:
  match ds:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      index_remove_step(h, rest, name, p88_string_eq(dn(h), name))

# Module: src/core/index.bend:145

@unsafe
def index_remove_step(
  +h: KDef, +rest: List<&2, KDef>, +name: String, +same: Bool,
) -> List<&2, KDef>:
  match same:
    case True{}: index_remove(rest, name)
    case False{}: Con{h, index_remove(rest, name)}

# Module: src/core/index.bend:153

@unsafe
def index_tip(
  +tree: KDef,
  +hash: U32,
) -> KDef:
  match tree:
    case KDef{label, kind, arity, templates, typ, value, ctors, native, unsafe}:
      kc(KDef, U32.is_eq(templates, 0), u => tree,
        u => index_tip(index_child(tree, Bool.not(U32.is_eq(U32.and(hash, templates), 0))), hash))
    case KIndexLeaf{stored, bucket}: tree
    case KIndexNode{stored, mask, left, right}:
      kc(KDef, U32.is_eq(mask, 0), u => tree,
        u => kc(KDef, U32.is_eq(U32.and(hash, mask), 0),
          v => index_tip(left, hash), v => index_tip(right, hash)))

# U32 subtraction wraps: x & (0 - x) isolates its lowest set bit, or 0.

# Module: src/core/index.bend:169

@unsafe
def index_split_bit(
  +diff: U32,
) -> U32:
  U32.and(diff, U32.sub(0, diff))

# Module: src/core/index.bend:175

@unsafe
def index_leaf(
  +d: KDef,
  +hash: U32,
  +ds: List<&2, KDef>,
) -> KDef:
  KIndexLeaf{hash, Con{d, index_remove(ds, dn(d))}}

# Module: src/core/index.bend:183

@unsafe
def index_node(
  +hash: U32,
  +mask: U32,
  +left: KDef,
  +right: KDef,
) -> KDef:
  KIndexNode{hash, mask, left, right}

# Module: src/core/index.bend:192

@unsafe
def index_join(
  +tree: KDef,
  +d: KDef,
  +hash: U32,
  +mask: U32,
) -> KDef:
  kc(KDef, U32.is_eq(U32.and(hash, mask), 0),
    u => index_node(da(tree), mask, index_leaf(d, hash, Nil{}), tree),
    u => index_node(da(tree), mask, tree, index_leaf(d, hash, Nil{})))

# Module: src/core/index.bend:203

@unsafe
def index_insert(
  +tree: KDef,
  +d: KDef,
  +hash: U32,
  +mask: U32,
) -> KDef:
  match tree:
    case KDef{label, kind, arity, templates, typ, value, ctors, native, unsafe}:
      index_insert_legacy(tree, d, hash, mask)
    case KIndexLeaf{stored, bucket}:
      kc(KDef, Bool.not(U32.is_eq(mask, 0)),
        u => index_join(tree, d, hash, mask), u => index_leaf(d, hash, bucket))
    case KIndexNode{stored, split, left, right}:
      kc(KDef, U32.is_eq(split, 0), u => index_insert_legacy(tree, d, hash, mask),
      u => kc(KDef, Bool.not(U32.is_eq(mask, 0)) && U32.is_lt(mask, split),
        u => index_join(tree, d, hash, mask),
        u => kc(KDef, U32.is_eq(U32.and(hash, split), 0),
          u => index_node(stored, split, index_insert(left, d, hash, mask), right),
          u => index_node(stored, split, left, index_insert(right, d, hash, mask)))))

# Module: src/core/index.bend:224

@unsafe
def index_insert_legacy(
  +tree: KDef,
  +d: KDef,
  +hash: U32,
  +mask: U32,
) -> KDef:
  kc(KDef, Bool.not(U32.is_eq(mask, 0)) && (U32.is_eq(dx(tree), 0) || U32.is_lt(mask, dx(tree))),
    u => index_join(tree, d, hash, mask),
    u => kc(KDef, U32.is_eq(dx(tree), 0),
      u => index_leaf(d, hash, dc(tree)),
      u => kc(KDef, U32.is_eq(U32.and(hash, dx(tree)), 0),
        u => index_node(da(tree), dx(tree), index_insert(index_child(tree, False{}), d, hash, mask), index_child(tree, True{})),
        u => index_node(da(tree), dx(tree), index_child(tree, False{}), index_insert(index_child(tree, True{}), d, hash, mask)))))

# Module: src/core/index.bend:239

@unsafe
def index_set(+tree: KDef, +d: KDef, +hash: U32, +bits: U32) -> KDef:
  p131i_insert(tree, d, hash)


@unsafe
def index_build(
  +book: List<&2, KDef>,
) -> KDef:
  match book:
    case Nil{}:
      missing()
    case Con{h, rest}:
      index_set(index_build(rest), h, index_hash(dn(h), 2166136261), 32)

# Module: src/core/index.bend:259

@unsafe
def book_cached(
  +book: List<&2, KDef>,
  +bound: U32,
) -> List<&2, KDef>:
  Con{KDef{"$kernel.cache", "BookCache", bound, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{index_build(book), Nil{}}, True{}, False{}}, book}

# A cached name miss proves the declaration list contains nothing to remove.
# Missing definitions have the empty name. Preserve the generic empty-name case
# through filtering, even for malformed/duplicate books supplied through the API.

# Module: src/core/index.bend:273

@unsafe
def f_eq(
  +a: String,
  +b: String,
) -> Bool:
  p88_string_eq(a, b)

# Module: src/front/lexer.bend:68

@unsafe
def f_find(
  +name: String,
  +book: List<&2, KDef>,
) -> KDef:
  match book:
    case Nil{}:
      KDef{name, "Missing", 0, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}
    case Con{+d, ds}:
      f_find_next(name, d, ds, p137q_key_eq(name, d))

# Module: src/front/declarations.bend:253

@unsafe
def f_find_next(
  +name: String, +d: KDef, +ds: List<&2, KDef>, +same: Bool,
) -> KDef:
  match same:
    case True{}: d
    case False{}: f_find(name, ds)

# Module: src/front/declarations.bend:261

@unsafe
def p131i_original_set(+tree: KDef, +d: KDef, +hash: U32, +bits: U32) -> KDef:
  kc(KDef, p88_string_eq(dk(tree), "Absent"), u => index_leaf(d, hash, Nil{}),
    u => index_insert(tree, d, hash, index_split_bit(U32.xor(hash, da(index_tip(tree, hash))))))



@unsafe
def p131i_insert(+tree: KDef, +d: KDef, +hash: U32) -> KDef:
  match tree:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      p131i_original_set(tree, d, hash, 32)
    case KIndexLeaf{stored, bucket}:
      +mask = index_split_bit(U32.xor(hash, stored))
      kc(KDef, U32.is_eq(mask, 0),
        u => index_leaf(d, hash, bucket),
        u => index_join(tree, d, hash, mask))
    case KIndexNode{stored, split, left, right}:
      +diff = U32.xor(hash, stored)
      kc(KDef, U32.is_eq(split, 0),
        u => p131i_original_set(tree, d, hash, 32),
        u => kc(KDef, Bool.not(U32.is_eq(U32.and(diff, U32.sub(split, 1)), 0)),
          v => index_join(tree, d, hash, index_split_bit(diff)),
          v => kc(KDef, U32.is_eq(U32.and(hash, split), 0),
            w => index_node(stored, split, p131i_insert(left, d, hash), right),
            w => index_node(stored, split, left, p131i_insert(right, d, hash)))))



# Whole scalar observers: preserve each original operand order and all variants.
@unsafe
def p137q_name_eq(record: KDef, key: String) -> Bool:
  match record:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: p88_string_eq(name,key)
    case KIndexLeaf{hash,bucket}: p88_string_eq("",key)
    case KIndexNode{hash,mask,left,right}: p88_string_eq("",key)

@unsafe
def p137q_key_eq(key: String, record: KDef) -> Bool:
  match record:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: p88_string_eq(key,name)
    case KIndexLeaf{hash,bucket}: p88_string_eq(key,"")
    case KIndexNode{hash,mask,left,right}: p88_string_eq(key,"")

@unsafe
def p137q_kind_eq(record: KDef, key: String) -> Bool:
  match record:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: p88_string_eq(kind,key)
    case KIndexLeaf{hash,bucket}: p88_string_eq("IndexLeaf",key)
    case KIndexNode{hash,mask,left,right}: p88_string_eq("IndexNode",key)

# Fixed construction and independently specified outputs; no workload recognizer.
type P137QRecord is Data:
  P137QRecord{+label: String, +other: String, +numbers: List<&2,U32>, +labels: List<&2,String>, +payload: KTerm, +serial: U32, +marker: Bool, +children: List<&2,KTerm>, +tail: String}

@unsafe
def p137q_label(record: P137QRecord) -> String:
  match record:
    case P137QRecord{label,other,numbers,labels,payload,serial,marker,children,tail}: label

@unsafe
def p137q_record_query(record: P137QRecord, key: String) -> Bool:
  match record:
    case P137QRecord{label,other,numbers,labels,payload,serial,marker,children,tail}: p88_string_eq(label,key)

@unsafe
def p137q_record_numbers(record: P137QRecord) -> List<&2,U32>:
  match record:
    case P137QRecord{label,other,numbers,labels,payload,serial,marker,children,tail}: numbers

@unsafe
def p137q_record(+key: String) -> P137QRecord:
  P137QRecord{key,"kept",[3,5,7],["retained","λ🌍"],KLiteral{"String",0,"opaque",0,0},99,True{},[],"tail"}

@unsafe
def p137q_node(name: String, kind: String, arity: U32, owned: Bool, children: List<&2,KDef>) -> KDef:
  KDef{name,kind,arity,3,KLiteral{"String",0,"opaque type",0,0},
    KTerm{"App","opaque value",23,2,[],["retained","λ🌍"],2,9},children,owned,False{}}

@unsafe
def p137q_value(record: KDef) -> String:
  match record:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: p137q_term_value(value)
    case KIndexLeaf{hash,bucket}: "index"
    case KIndexNode{hash,mask,left,right}: "index"

@unsafe
def p137q_term_value(value: KTerm) -> String:
  match value:
    case KTerm{tag,name,id,quant,kids,removed,begin,end}: name
    case KLambda{name,id,quant,kids,removed,begin,end,present}: name
    case KLiteral{kind,number,text,begin,end}: text

@unsafe
def p137q_rows(names: List<&2,String>, +arity: U32) -> List<&2,KDef>:
  match names:
    case Nil{}: [p137q_node("PayloadOwner","ADT",71,True{},[p137q_node("Payload","Ctr",0,False{},[])])]
    case Con{name,rest}: Con{p137q_node(name,"Def",arity,False{},[]),p137q_rows(rest,U32.add(arity,1))}

@unsafe
def p137q_queries(+book: List<&2,KDef>, +key: String) -> U32:
  U32.add(da(f_find(key,book)),U32.add(da(lookup(book,key)),
    U32.add(Bool.to_u32(nc_ctor_owned(book,"Payload")),
    U32.add(da(f_find(":absent:",book)),U32.add(da(lookup(book,":absent:")),Bool.to_u32(nc_ctor_owned(book,":absent:")))))))

@unsafe
def p137q_once(+book: List<&2,KDef>, +record: P137QRecord, +key: String) -> U32:
  p137q_queries(book,key)

@unsafe
def p137q_checks() -> List<&2,Bool>:
  +first = p137q_node("a","Def",17,False{},[])
  +last = p137q_node("b","Def",23,False{},[])
  +duplicate = p137q_node("a","Def",99,False{},[])
  +ctor = p137q_node("C","Ctr",0,False{},[])
  +plain = p137q_node("Plain","ADT",0,False{},[ctor])
  +owned = p137q_node("Owned","ADT",0,True{},[ctor])
  +shadow = p137q_node("Shadow","ADT",0,True{},[p137q_node("C","Def",0,False{},[]),ctor])
  +cached = p137q_node("Cached","ADT",0,True{},book_cached([ctor],0))
  +book = book_cached([first,last,duplicate],0)
  +record = p137q_record("λ🌍")
  [p88_string_eq(dn(f_find("missing",[])),"missing"),
   p88_string_eq(dk(f_find("missing",[])),"Missing"),
   p88_string_eq(dn(lookup([],"missing")),""),
   p88_string_eq(dk(lookup([],"missing")),"Absent"),
   U32.is_eq(da(f_find("a",[first,last,duplicate])),17),
   U32.is_eq(da(lookup([first,last,duplicate],"a")),17),
   U32.is_eq(da(lookup(book,"a")),17),
   U32.is_eq(da(lookup(book,"b")),23),
   p88_string_eq(dk(lookup(book,"$kernel.cache")),"Absent"),
   p88_string_eq(dk(f_find("$kernel.cache",book)),"BookCache"),
   Bool.not(nc_ctor_owned([plain,owned],"C")),
   nc_ctor_owned([shadow,owned],"C"),
   nc_ctor_owned([cached],"C"),
   Bool.not(nc_ctor_owned([p137q_node("Ignored","Def",0,True{},[ctor])],"C")),
   Bool.not(nc_ctor_owned([plain,owned],"missing")),
   nc_ctor_owned([p137q_node("商","ADT",0,True{},[p137q_node("字","Ctr",0,False{},[])])],"字"),
   p88_string_eq(dk(f_find("",[KIndexLeaf{7,[]},first])),"IndexLeaf"),
   p88_string_eq(dk(lookup([KIndexNode{0,1,first,last}],"")),"IndexNode"),
   p88_string_eq(p137q_value(first),"opaque value"),
   U32.is_eq(da(first),17),
   p137q_record_query(record,"λ🌍"),
   Bool.not(p137q_record_query(record,"λ")),
   U32.is_eq(U32.from_nat(List.length(&2,U32,p137q_record_numbers(record))),3)]

@unsafe
def p137q_print(values: List<&2,Bool>) -> IO(Unit):
  match values:
    case Nil{}: IO.pure(Unit,Unit{})
    case Con{value,rest}:
      do IO<Unit>:
        Unit <- IO.print(U32.show(Bool.to_u32(value)))
        p137q_print(rest)

@unsafe
def p137q_repeat(left: Nat, +book: List<&2,KDef>, +record: P137QRecord, +key: String, sum: U32) -> U32:
  match left:
    case 0n: sum
    case 1n+rest: p137q_repeat(rest,book,record,key,U32.add(sum,p137q_once(book,record,key)))

@unsafe
def p137q_timed(repeats: Nat, +book: List<&2,KDef>, +record: P137QRecord, +key: String) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(p137q_once(book,record,key)))
    before : Nat <- IO.now()
    Unit <- IO.print(U32.show(p137q_repeat(repeats,book,record,key,0)))
    after : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(after,before)))

@unsafe
def p137q_select(repeats: Nat) -> IO(Unit):
  match repeats:
    case 0n: p137q_print(p137q_checks())
    case 1n+rest:
      +key : String = String.append("p111_","emit_admitted")
      p137q_timed(1n+rest,p137q_rows(p137q_names(),0),p137q_record(key),key)

@unsafe
def p137q_number(value: Maybe<&2,Nat>, fallback: Nat) -> Nat:
  match value:
    case None{}: fallback
    case Some{number}: number

@unsafe
def p137q_args(args: List<String>, fallback: Nat) -> Nat:
  match args:
    case Nil{}: fallback
    case head <> tail: p137q_args(tail,p137q_number(Nat.read(head),fallback))

@unsafe
def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p137q_select(p137q_args(args,0n))

@unsafe
def p137q_names() -> List<&2,String>:
  ["p88_string_eq_go", "p98_eq_finish", "p88_string_eq", "p88_string_order_go", "p88_string_order", "kc", "name_key", "kt", "atom", "tg", "nm", "ix", "qt", "ks", "rm", "terms_at", "kid", "var", "ref", "qua", "typ", "app", "all", "dn", "dk", "da", "dx", "dt", "dv", "dc", "db", "du", "missing", "lookup", "lookup_cached", "lookup_named", "terms_len", "has_name", "has_name_next", "subst", "core_force", "core_apply_span", "core_beta", "core_subst_stable", "norm_join", "core_nat", "core_nat_make", "core_literal_type", "core_literal_word", "core_literal_step", "core_literal_string", "core_literal_same", "compiler_term_abi", "kb", "ke", "compiler_span_abi", "k_with_children", "k_with_span", "kt_span", "core_literal", "kl_number", "kl_text", "kl_make", "p111_emit_admitted"]

