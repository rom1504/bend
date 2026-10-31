
# Module: src/core/index.bend:4
law index_child_list:
  for +ds: List<&2, KDef>
  for +right: Bool
  KDef

# Module: src/core/index.bend:9
law index_first:
  for +ds: List<&2, KDef>
  KDef

# Module: src/core/index.bend:13
law index_bucket:
  for +ds: List<&2, KDef>
  for +name: String
  KDef

# Compressed persistent binary trie. Internal nodes carry one discriminating
# hash bit; leaves retain exact-name buckets for complete 32-bit collisions.

# Module: src/core/index.bend:20
law index_lookup:
  for +cache: KDef
  for +name: String
  KDef

# Module: src/core/index.bend:308
law book_final_reverse:
  for +book: List<&2,KDef>
  for +done: List<&2,KDef>
  List<&2,KDef>

# Module: src/core/index.bend:313
law book_final_scan:
  for +book: List<&2,KDef>
  for +seen: KDef
  for +kept: List<&2,KDef>
  for +done: List<&2,KDef>
  List<&2,KDef>

# Module: src/core/index.bend:320
law book_final_step:
  for +d: KDef
  for +rest: List<&2,KDef>
  for +seen: KDef
  for +kept: List<&2,KDef>
  for +done: List<&2,KDef>
  for +hash: U32
  List<&2,KDef>

# Module: src/core/index.bend:329
law book_final_filter:
  for +done: List<&2,KDef>
  for +seen: KDef
  List<&2,KDef>

# Module: src/core/index.bend:334
law book_final_legacy:
  for +book: List<&2,KDef>
  for +done: List<&2,KDef>
  List<&2,KDef>

# Module: src/core/index.bend:26
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
def index_child_list(ds, right):
  match ds:
    case Nil{}:
      missing()
    case Con{h, rest}:
      match right:
        case True{}: index_first(rest)
        case False{}: h

# Module: src/core/index.bend:61
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
def index_find_absent(
  +tree: KDef,
  +name: String,
  +hash: U32,
  +bits: U32,
  +absent: Bool,
) -> KDef:
  match absent:
    case True{}: missing()
    case False{}:
      index_find_leaf(tree, name, hash, bits, U32.is_eq(dx(tree), 0))

# Module: src/core/index.bend:102
@unsafe
def index_find_leaf(
  +tree: KDef,
  +name: String,
  +hash: U32,
  +bits: U32,
  +leaf: Bool,
) -> KDef:
  match leaf:
    case True{}:
      index_find_hash(tree, name, U32.is_eq(da(tree), hash))
    case False{}:
      index_find(index_child(tree, Bool.not(U32.is_eq(U32.and(hash, dx(tree)), 0))), name, hash, bits)

# Module: src/core/index.bend:116
@unsafe
def index_find_hash(
  +tree: KDef,
  +name: String,
  +same: Bool,
) -> KDef:
  match same:
    case True{}: index_bucket(dc(tree), name)
    case False{}: missing()

# Module: src/core/index.bend:126
@unsafe
def index_bucket(ds, name):
  match ds:
    case Nil{}:
      missing()
    case Con{h, rest}:
      kc(KDef, p88_string_eq(dn(h), name), u => h, u => index_bucket(rest, name))

# Module: src/core/index.bend:134
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
      kc(KDef, U32.is_eq(mask, 0),
        u => index_leaf(d, hash, bucket), u => index_join(tree, d, hash, mask))
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
def index_lookup(cache, name):
  index_find(index_first(dc(cache)), name, index_hash(name, 2166136261), 32)

# Module: src/core/index.bend:263
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
def index_put_rest(
  +cache: KDef,
  +rest: List<&2, KDef>,
  +name: String,
) -> List<&2, KDef>:
  kc(List<&2, KDef>, Bool.not(p88_string_eq(name, "")) && p88_string_eq(dn(index_lookup(cache, name)), ""),
    u => rest, u => index_remove(rest, name))

# Module: src/core/index.bend:282
@unsafe
def book_put(
  +book: List<&2, KDef>,
  +d: KDef,
) -> List<&2, KDef>:
  match book:
    case Nil{}:
      Con{d, Nil{}}
    case Con{h, rest}:
      kc(List<&2, KDef>, p88_string_eq(dk(h), "BookCache"), u => Con{KDef{dn(h), dk(h), da(h), 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{index_set(index_first(dc(h)), d, index_hash(dn(d), 2166136261), 32), Nil{}}, True{}, False{}}, Con{d, index_put_rest(h, rest, dn(d))}}, u => Con{d, index_remove(book, dn(d))})


# An immutable context may be reused by several backend phases. Never nest the
# sentinel or recompute its maximum binder ID from the index's implementation.

# Module: src/core/index.bend:296
@unsafe
def book_context(
  +book: List<&2, KDef>,
) -> List<&2, KDef>:
  match book:
    case Nil{}:
      book_cached(book, 0)
    case Con{h, rest}:
      kc(List<&2, KDef>, p88_string_eq(dk(h), "BookCache"), u => book, u => book_cached(book, norm_max_book(book)))


# Exact final-definition selection. Short event lists use the original scan.
# Marker values distinguish even the empty name from an unsuccessful lookup.

# Module: src/core/index.bend:340
@unsafe
def book_final_large(
  +book: List<&2,KDef>,
  +remaining: U32,
) -> Bool:
  match book:
    case Nil{}: U32.is_eq(remaining, 0)
    case Con{h, rest}:
      kc(Bool, U32.is_eq(remaining, 0), u => True{}, u => book_final_large(rest, U32.sub(remaining, 1)))

# Malformed raw JavaScript names retain the legacy comparison demand order.
# Projection and Char.to_u32 do not throw on surrogate codepoints; only the
# unchanged legacy comparisons decide whether such input must fail.

# Module: src/core/index.bend:353
@unsafe
def book_final_name_valid(
  +name: String,
) -> Bool:
  match name:
    case SNil{}: True{}
    case SCon{h, rest}:
      kc(Bool, U32.is_le(U32.sub(Char.to_u32(h), 55296), 2047),
        u => False{}, u => book_final_name_valid(rest))

# Module: src/core/index.bend:363
@unsafe
def book_final_names_valid(
  +book: List<&2,KDef>,
) -> Bool:
  match book:
    case Nil{}: True{}
    case Con{d, rest}:
      kc(Bool, book_final_name_valid(dn(d)),
        u => book_final_names_valid(rest), u => False{})

# Module: src/core/index.bend:373
@unsafe
def book_final_fast(
  +book: List<&2,KDef>,
  +done: List<&2,KDef>,
) -> List<&2,KDef>:
  kc(List<&2,KDef>, book_final_large(book, 256),
    u => kc(List<&2,KDef>, book_final_names_valid(book),
      u => kc(List<&2,KDef>, book_final_names_valid(done),
        u => book_final_scan(book_final_reverse(book, Nil{}), missing(), Nil{}, done),
        u => book_final_legacy(book, done)),
      u => book_final_legacy(book, done)),
    u => book_final_legacy(book, done))

# Module: src/core/index.bend:386
@unsafe
def book_final_reverse(book, done):
  match book:
    case Nil{}: done
    case Con{d, rest}: book_final_reverse(rest, Con{d, done})

# Module: src/core/index.bend:392
@unsafe
def book_final_seen(
  +seen: KDef,
  +name: String,
  +hash: U32,
) -> Bool:
  p88_string_eq(dk(index_find(seen, name, hash, 32)), "$final.seen")

# Module: src/core/index.bend:400
@unsafe
def book_final_scan(book, seen, kept, done):
  match book:
    case Nil{}: book_final_reverse(kept, book_final_filter(done, seen))
    case Con{d, rest}:
      book_final_step(d, rest, seen, kept, done, index_hash(dn(d), 2166136261))

# Module: src/core/index.bend:407
@unsafe
def book_final_step(d, rest, seen, kept, done, hash):
  kc(List<&2,KDef>, book_final_seen(seen, dn(d), hash),
    u => book_final_scan(rest, seen, kept, done),
    u => book_final_scan(rest,
      index_set(seen, KDef{dn(d), "$final.seen", 0, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, True{}, False{}}, hash, 32),
      Con{d, kept}, done))

# Module: src/core/index.bend:415
@unsafe
def book_final_filter(done, seen):
  match done:
    case Nil{}: Nil{}
    case Con{d, rest}:
      kc(List<&2,KDef>, book_final_seen(seen, dn(d), index_hash(dn(d), 2166136261)),
        u => book_final_filter(rest, seen),
        u => Con{d, book_final_filter(rest, seen)})

# Module: src/core/index.bend:424
@unsafe
def book_final_legacy(book, done):
  match book:
    case Nil{}: done
    case Con{d, rest}: book_final_legacy(rest, Con{d, index_remove(done, dn(d))})

# Batch an immutable declaration overlay. Retain the original sequential path
# for cache-valued declarations, malformed names and cache misses that disagree
# with the retained event list. Definition references/order are retained;
# event-list cell identity is not promised.

# Module: src/core/index.bend:434
@unsafe
def book_put_many_regular(+defs: List<&2,KDef>) -> Bool:
  match defs:
    case Nil{}: True{}
    case Con{d, rest}:
      kc(Bool, p88_string_eq(dk(d), "BookCache"),
        u => False{}, u => book_put_many_regular(rest))

# Module: src/core/index.bend:442
@unsafe
def book_put_many_legacy(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,KDef>:
  match defs:
    case Nil{}: book
    case Con{d, rest}: book_put_many_legacy(book_put(book, d), rest)

# Module: src/core/index.bend:448
@unsafe
def index_set_many(+tree: KDef, +defs: List<&2,KDef>) -> KDef:
  match defs:
    case Nil{}: tree
    case Con{d, rest}:
      index_set_many(index_set(tree, d, index_hash(dn(d), 2166136261), 32), rest)

# Module: src/core/index.bend:455
@unsafe
def book_put_many_cache_name(+cache: KDef, +rest: List<&2,KDef>, +name: String) -> Bool:
  kc(Bool, p88_string_eq(name, ""), u => True{},
    u => kc(Bool, p88_string_eq(dn(index_lookup(cache, name)), ""),
      u => p88_string_eq(dn(index_bucket(rest, name)), ""), u => True{}))

# Module: src/core/index.bend:461
@unsafe
def book_put_many_cache_valid(+cache: KDef, +rest: List<&2,KDef>, +defs: List<&2,KDef>) -> Bool:
  match defs:
    case Nil{}: True{}
    case Con{d, more}:
      kc(Bool, book_put_many_cache_name(cache, rest, dn(d)),
        u => book_put_many_cache_valid(cache, rest, more), u => False{})

# Module: src/core/index.bend:469
@unsafe
def book_put_many_cached(+cache: KDef, +rest: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,KDef>:
  Con{KDef{dn(cache), dk(cache), da(cache), 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},
    Con{index_set_many(index_first(dc(cache)), defs), Nil{}}, True{}, False{}},
    book_final_fast(defs, rest)}

# Module: src/core/index.bend:475
@unsafe
def book_put_many_fast(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Nil{}: book_final_fast(defs, Nil{})
    case Con{cache, rest}:
      kc(List<&2,KDef>, p88_string_eq(dk(cache), "BookCache"),
        u => kc(List<&2,KDef>, book_put_many_cache_valid(cache, rest, defs),
          u => book_put_many_cached(cache, rest, defs),
          u => book_put_many_legacy(book, defs)),
        u => book_final_fast(defs, book))

# Module: src/core/index.bend:486
@unsafe
def book_put_many(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,KDef>:
  match defs:
    case Nil{}: book
    case Con{d, rest}:
      kc(List<&2,KDef>, book_put_many_regular(defs),
        u => kc(List<&2,KDef>, book_final_names_valid(defs),
          u => kc(List<&2,KDef>, book_final_names_valid(book),
            u => book_put_many_fast(book, defs), u => book_put_many_legacy(book, defs)),
          u => book_put_many_legacy(book, defs)),
        u => book_put_many_legacy(book, defs))
