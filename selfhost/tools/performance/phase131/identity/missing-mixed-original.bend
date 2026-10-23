import Base

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
def dt(
  +d: KDef,
) -> KTerm:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      typ
    case KIndexLeaf{hash, bucket}: atom("Absent")
    case KIndexNode{hash, mask, left, right}: atom("Absent")

# Module: src/core/term.bend:234

@unsafe
def dv(
  +d: KDef,
) -> KTerm:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      value
    case KIndexLeaf{hash, bucket}: atom("Absent")
    case KIndexNode{hash, mask, left, right}: atom("Absent")

# Module: src/core/term.bend:244

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
def du(
  +d: KDef,
) -> Bool:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      unsafe
    case KIndexLeaf{hash, bucket}: False{}
    case KIndexNode{hash, mask, left, right}: False{}

# Module: src/core/term.bend:274

@unsafe
def missing() -> KDef:
  KDef{"", "Absent", 0, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}

# Module: src/core/term.bend:278

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
def index_set(
  +tree: KDef,
  +d: KDef,
  +hash: U32,
  +bits: U32,
) -> KDef:
  kc(KDef, p88_string_eq(dk(tree), "Absent"), u => index_leaf(d, hash, Nil{}),
    u => index_insert(tree, d, hash, index_split_bit(U32.xor(hash, da(index_tip(tree, hash))))))

# Module: src/core/index.bend:249

def p131ip_names() -> List<&2,String>:
  ["p88_string_eq_go",
   "p98_eq_finish",
   "p88_string_eq",
   "p88_string_order_go",
   "p88_string_order",
   "kc",
   "name_key",
   "kt",
   "atom",
   "tg",
   "nm",
   "ix",
   "qt",
   "ks",
   "rm",
   "terms_at",
   "kid",
   "var",
   "ref",
   "qua",
   "typ",
   "app",
   "all",
   "dn",
   "dk",
   "da",
   "dx",
   "dt",
   "dv",
   "dc",
   "db",
   "du",
   "missing",
   "lookup",
   "lookup_cached",
   "lookup_named",
   "terms_len",
   "has_name",
   "has_name_next",
   "subst",
   "subst_node",
   "subst_terms",
   "core_force",
   "core_rebuild",
   "core_apply",
   "core_apply_span",
   "core_beta",
   "core_subst_stable",
   "core_subst_stable_terms",
   "core_subst_stable_app",
   "core_subst_stable_app_kids",
   "core_subst_stable_app_tail",
   "core_subst_stable_app_last",
   "norm_join",
   "norm_defs_join",
   "core_nat",
   "core_nat_make",
   "core_literal_type",
   "core_literal_word",
   "core_literal_step",
   "core_literal_string",
   "core_literal_same",
   "compiler_term_abi",
   "kb",
   "ke",
   "compiler_span_abi",
   "k_with_children",
   "k_with_span",
   "kt_span",
   "core_literal",
   "kl_number",
   "kl_text",
   "kl_make",
   "k_lam",
   "k_quantity_present",
   "k_rebuild",
   "k_snf_children",
   "k_lambda_presence",
   "index_hash",
   "index_child",
   "index_child_list",
   "index_first",
   "index_find",
   "index_find_absent",
   "index_find_leaf",
   "index_find_hash",
   "index_bucket",
   "index_remove",
   "index_remove_step",
   "index_tip",
   "index_split_bit",
   "index_leaf",
   "index_node",
   "index_join",
   "index_insert",
   "index_insert_legacy",
   "index_set",
   "index_build",
   "index_lookup",
   "book_cached",
   "index_put_rest",
   "book_put",
   "book_context",
   "book_final_large",
   "book_final_name_valid",
   "book_final_names_valid",
   "book_final_fast",
   "book_final_reverse",
   "book_final_seen",
   "book_final_scan",
   "book_final_step",
   "book_final_filter",
   "book_final_legacy",
   "book_put_many_regular",
   "book_put_many_legacy",
   "index_set_many",
   "book_put_many_cache_name",
   "book_put_many_cache_valid",
   "book_put_many_cached",
   "book_put_many_fast",
   "book_put_many",
   "norm_apply",
   "wnf",
   "norm_eval_node",
   "norm_node_app",
   "norm_node_ann",
   "norm_node_let",
   "norm_node_ref",
   "norm_node_min",
   "norm_node_rwt",
   "norm_ref",
   "norm_args",
   "norm_dec",
   "norm_match",
   "norm_stuck",
   "norm_min",
   "norm_min_left",
   "norm_min_right",
   "strong",
   "norm_max",
   "norm_max_term",
   "norm_max_book",
   "compare",
   "norm_compare",
   "norm_subset",
   "norm_removed",
   "norm_let",
   "norm_let_tail",
   "norm_eval",
   "norm_var",
   "norm_names_len",
   "norm_book_bound",
   "norm_bound_found",
   "norm_max_walk",
   "norm_max_defs",
   "norm_rebind",
   "norm_exact",
   "norm_exact_lists",
   "norm_exact_head",
   "norm_exact_names",
   "norm_convert",
   "norm_cmp_loop",
   "norm_cmp_quick",
   "norm_cmp_fail",
   "norm_cmp_test",
   "norm_cmp_heads",
   "norm_cmp_same",
   "norm_cmp_plain",
   "norm_cmp_ref",
   "norm_cmp_fields",
   "norm_cmp_zip",
   "norm_cmp_kind",
   "norm_cmp_left",
   "norm_cmp_right",
   "norm_cmp_kind_left",
   "norm_cmp_kind_right",
   "g_heap",
   "g_next",
   "g_state",
   "g_term",
   "g_states",
   "g_terms",
   "g_get",
   "g_put",
   "g_put_node",
   "g_share",
   "g_share_terms",
   "g_shared_term",
   "g_share_head",
   "g_shared_head",
   "g_cache",
   "g_wnf",
   "g_eval",
   "g_cell",
   "g_app",
   "g_ref",
   "g_args",
   "g_return",
   "g_resume",
   "g_filled",
   "g_min_left",
   "g_match",
   "g_let",
   "g_let_shared",
   "g_let_sub",
   "graph_strong",
   "g_snf_go",
   "g_snf_head",
   "g_snf_open",
   "g_snf_children",
   "g_snf_return",
   "g_start",
   "g_shared_domain",
   "reach_book",
   "kr_filter",
   "kr_visit",
   "kr_visit_def",
   "kr_resolve",
   "kr_resolve_head",
   "kr_parent",
   "kr_dependencies",
   "kr_ctor_refs",
   "kr_refs",
   "kr_refs_list",
   "kr_push",
   "kf_unann",
   "kf_has_path",
   "kf_namespaces",
   "kf_namespace_step",
   "kf_namespace",
   "kf_word",
   "kf_name",
   "kf_known",
   "kf_resolve",
   "kf_char",
   "kf_token",
   "kf_region",
   "kf_shield",
   "kf_scan",
   "kf_source",
   "kp_eq",
   "kp_is",
   "kp_quant",
   "kp_join",
   "kp_par",
   "kp_alias_name",
   "kp_file_name",
   "kp_name",
   "kp_show",
   "kp_scope",
   "kp_index",
   "kp_depth",
   "kp_bound",
   "kp_bind",
   "kp_each",
   "kp_chain"]

# Two complete persistent-index construction/update passes, followed by exact
# name lookups. The index algorithms and KDef representation are copied verbatim
# from the selected compiler. The names are actual declarations in that source.

@unsafe
def p131ip_record(+name: String, +version: U32) -> KDef:
  KDef{name,"IdentityProxy",version,U32.add(version,7),
    kt("Type",name,version,2,[]),kt("Body",name,version,1,[atom("Nested")]),[],False{},False{}}

@unsafe
def p131ip_build(names: List<&2,String>, index: KDef, +version: U32) -> KDef:
  match names:
    case Nil{}: index
    case Con{+name,rest}:
      p131ip_build(rest,index_set(index,p131ip_record(name,version),index_hash(name,2166136261),32),U32.inc(version))

@unsafe
def p131ip_digest(names: List<&2,String>, +index: KDef, +acc: U32) -> U32:
  match names:
    case Nil{}: acc
    case Con{+name,rest}:
      p131ip_digest(rest,index,U32.add(U32.mul(acc,16777619),da(index_find(index,name,index_hash(name,2166136261),32))))

@unsafe
def p131ip_once(+names: List<&2,String>) -> U32:
  +index = p131ip_build(names,p131ip_build(names,missing(),1),1001)
  p131ip_digest(p131im_queries(names),index,2166136261)

def p131ip_take(n: Nat, names: List<&2,String>) -> List<&2,String>:
  match n names:
    case 0n _: []
    case 1n+rest Nil{}: []
    case 1n+rest Con{name,tail}: Con{name,p131ip_take(rest,tail)}

@unsafe
def p131ip_loop(n: Nat, +names: List<&2,String>, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+rest: p131ip_loop(rest,names,U32.add(acc,p131ip_once(names)))

@unsafe
def p131ip_check() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(p131ip_once([])))
    Unit <- IO.print(U32.show(p131ip_once(p131ip_take(1n,p131ip_names()))))
    Unit <- IO.print(U32.show(p131ip_once(p131ip_take(16n,p131ip_names()))))
    Unit <- IO.print(U32.show(p131ip_once(p131ip_take(64n,p131ip_names()))))
    IO.print(U32.show(p131ip_once(p131ip_take(256n,p131ip_names()))))

def p131ip_nat(value: Maybe<&2,Nat>, fallback: Nat) -> Nat:
  match value:
    case None{}: fallback
    case Some{number}: number

@unsafe
def p131ip_execute(repetitions: Nat, warmups: Nat, size: Nat) -> IO(Unit):
  +names : List<&2,String> = p131ip_take(size,p131ip_names())
  +index : KDef = p131ip_build(names,p131ip_build(names,missing(),1),1001)
  +queries : List<&2,String> = p131im_queries(names)
  do IO<Unit>:
    Unit <- IO.print(U32.show(p131ip_digest(queries,index,2166136261)))
    Unit <- IO.print(U32.show(p131ir_loop(warmups,queries,index,0)))
    t0 : Nat <- IO.now()
    Unit <- IO.print(U32.show(p131ir_loop(repetitions,queries,index,0)))
    t1 : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(t1,t0)))
@unsafe
def p131ip_arguments(args: List<String>) -> IO(Unit):
  match args:
    case repetitions <> warmups <> size <> reserved <> Nil{}:
      p131ip_execute(p131ip_nat(Nat.read(repetitions),256n),
        p131ip_nat(Nat.read(warmups),4n),p131ip_nat(Nat.read(size),256n))
    case head <> rest: p131ip_arguments(rest)
    case Nil{}: p131ip_check()

@unsafe
def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p131ip_arguments(args)

@unsafe
def p131ir_loop(n: Nat, +names: List<&2,String>, +index: KDef, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+rest:
      p131ir_loop(rest,names,index,U32.add(acc,p131ip_digest(names,index,2166136261)))


def p131im_queries(names: List<&2,String>) -> List<&2,String>:
  match names:
    case Nil{}: Nil{}
    case Con{+name,rest}:
      Con{name,Con{":missing:" ++ name,p131im_queries(rest)}}

