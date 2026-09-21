import Base

# Persistent exact-name index for checked books. Source event lists remain intact.
law index_hash:
  for +name: String
  for +acc: U32
  U32

law index_child:
  for +tree: KDef
  for +right: Bool
  KDef

law index_child_list:
  for +ds: List<&2, KDef>
  for +right: Bool
  KDef

law index_first:
  for +ds: List<&2, KDef>
  KDef

law index_find:
  for +tree: KDef
  for +name: String
  for +hash: U32
  for +bits: U32
  KDef

law index_bucket:
  for +ds: List<&2, KDef>
  for +name: String
  KDef

law index_remove:
  for +ds: List<&2, KDef>
  for +name: String
  List<&2, KDef>

law index_set:
  for +tree: KDef
  for +d: KDef
  for +hash: U32
  for +bits: U32
  KDef

law index_set_node:
  for +tree: KDef
  for +d: KDef
  for +hash: U32
  for +bits: U32
  for +right: Bool
  KDef

law index_build:
  for +book: List<&2, KDef>
  KDef

law index_lookup:
  for +cache: KDef
  for +name: String
  KDef

law book_cached:
  for +book: List<&2, KDef>
  for +bound: U32
  List<&2, KDef>

law book_put:
  for +book: List<&2, KDef>
  for +d: KDef
  List<&2, KDef>

@unsafe
def index_hash(name, acc):
  match name:
    case SNil{}:
      acc
    case SCon{h, rest}:
      index_hash(rest, U32.mul(U32.xor(acc, Char.to_u32(h)), 16777619))

@unsafe
def index_child(tree, right):
  index_child_list(dc(tree), right)

@unsafe
def index_child_list(ds, right):
  match ds:
    case Nil{}:
      missing()
    case Con{h, rest}:
      kc(KDef, right, u => index_first(rest), u => h)

@unsafe
def index_first(ds):
  match ds:
    case Nil{}:
      missing()
    case Con{h, rest}:
      h

@unsafe
def index_find(tree, name, hash, bits):
  kc(KDef, String.eq(dk(tree), "Absent"), u => missing(), u => kc(KDef, U32.is_eq(bits, 0), u => index_bucket(dc(tree), name), u => index_find(index_child(tree, Bool.not(U32.is_eq(U32.and(hash, 1), 0))), name, U32.shr(hash), U32.sub(bits, 1))))

@unsafe
def index_bucket(ds, name):
  match ds:
    case Nil{}:
      missing()
    case Con{h, rest}:
      kc(KDef, String.eq(dn(h), name), u => h, u => index_bucket(rest, name))

@unsafe
def index_remove(ds, name):
  match ds:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      kc(List<&2, KDef>, String.eq(dn(h), name), u => index_remove(rest, name), u => Con{h, index_remove(rest, name)})

@unsafe
def index_set(tree, d, hash, bits):
  kc(KDef, U32.is_eq(bits, 0), u => KDef{"", "IndexLeaf", 0, 0, atom("Absent"), atom("Absent"), Con{d, index_remove(dc(tree), dn(d))}, True{}, False{}}, u => index_set_node(tree, d, hash, bits, Bool.not(U32.is_eq(U32.and(hash, 1), 0))))

@unsafe
def index_set_node(tree, d, hash, bits, right):
  KDef{"", "IndexNode", 0, 0, atom("Absent"), atom("Absent"), Con{kc(KDef, right, u => index_child(tree, False{}), u => index_set(index_child(tree, False{}), d, U32.shr(hash), U32.sub(bits, 1))), Con{kc(KDef, right, u => index_set(index_child(tree, True{}), d, U32.shr(hash), U32.sub(bits, 1)), u => index_child(tree, True{})), Nil{}}}, True{}, False{}}

@unsafe
def index_build(book):
  match book:
    case Nil{}:
      missing()
    case Con{h, rest}:
      index_set(index_build(rest), h, index_hash(dn(h), 2166136261), 32)

@unsafe
def index_lookup(cache, name):
  index_find(index_first(dc(cache)), name, index_hash(name, 2166136261), 32)

@unsafe
def book_cached(book, bound):
  Con{KDef{"$kernel.cache", "BookCache", bound, 0, atom("Absent"), atom("Absent"), Con{index_build(book), Nil{}}, True{}, False{}}, book}

@unsafe
def book_put(book, d):
  match book:
    case Nil{}:
      Con{d, Nil{}}
    case Con{h, rest}:
      kc(List<&2, KDef>, String.eq(dk(h), "BookCache"), u => Con{KDef{dn(h), dk(h), da(h), 0, atom("Absent"), atom("Absent"), Con{index_set(index_first(dc(h)), d, index_hash(dn(d), 2166136261), 32), Nil{}}, True{}, False{}}, Con{d, index_remove(rest, dn(d))}}, u => Con{d, index_remove(book, dn(d))})


# An immutable context may be reused by several backend phases. Never nest the
# sentinel or recompute its maximum binder ID from the index's implementation.
law book_context:
  for +book: List<&2, KDef>
  List<&2, KDef>

@unsafe
def book_context(book):
  match book:
    case Nil{}:
      book_cached(book, 0)
    case Con{h, rest}:
      kc(List<&2, KDef>, String.eq(dk(h), "BookCache"), u => book, u => book_cached(book, norm_max_book(book)))
