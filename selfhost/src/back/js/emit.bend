
# Module: src/back/js/emit.bend:3
law j_l_name:
  for +t: KTerm
  String

# Module: src/back/js/emit.bend:7
law j_l_names:
  for +names: List<&2, String>
  String

# Module: src/back/js/emit.bend:11
law j_l_capture:
  for +env: List<&2, KTerm>
  for +seen: List<&2, String>
  String

# Module: src/back/js/emit.bend:16
law j_l_deeps:
  for +ts: List<&2, KTerm>
  for +depth: U32
  Bool

# Module: src/back/js/emit.bend:21
law j_l_marks:
  for +ts: List<&2, KTerm>
  for +path: String
  for +depth: U32
  for +at: U32
  List<&2, KTerm>

# Module: src/back/js/emit.bend:28
law j_l_def:
  for +book: List<&2, KDef>
  for +d: KDef
  String

# Module: src/back/js/emit.bend:33
law j_l_definition:
  for +book: List<&2, KDef>
  for +d: KDef
  for +t: KTerm
  String

# Module: src/back/js/emit.bend:39
law j_l_walk:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  String

# Module: src/back/js/emit.bend:46
law j_l_children:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  String

# Module: src/back/js/emit.bend:53
law j_l_lam:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  String

# Module: src/back/js/emit.bend:60
law j_l_mat:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  String

# Module: src/back/js/emit.bend:67
law j_l_app:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  String

# Module: src/back/js/emit.bend:74
law j_l_fields:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +ts: List<&2, KTerm>
  for +ty: KTerm
  String

# Module: src/back/js/emit.bend:81
law j_l_bindings:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +ts: List<&2, KTerm>
  String


# JavaScript emission from the checked first-order core.
# Emission is Bend2; JavaScript only supplies primitive values and effects.
# Erased binders retain a null ABI slot, but their arguments are never evaluated.

# Module: src/back/js/emit.bend:91
law j_local:
  for +id: U32
  String

# Module: src/back/js/emit.bend:111
law j_exprs_tail:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +xs: List<&2, KTerm>
  String

# Module: src/back/js/emit.bend:125
law j_expr:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +tail: Bool
  String

# Module: src/back/js/emit.bend:176
law j_expr_on:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +tail: Bool
  for +key: String
  String

# Module: src/back/js/emit.bend:201
law j_lambda_count:
  for +t: KTerm
  U32

# Module: src/back/js/emit.bend:209
law j_lambda_code:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +at: U32
  String

# Module: src/back/js/emit.bend:221
law j_lambda_bind:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +at: U32
  String

# Module: src/back/js/emit.bend:233
law j_call_arity:
  for +d: KDef
  U32

# Module: src/back/js/emit.bend:241
law j_apply_args:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +ty: KTerm
  String

# Module: src/back/js/emit.bend:252
law j_apply_args_head:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +ty: KTerm
  String

# Module: src/back/js/emit.bend:266
law j_descriptor:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +fuel: U32
  String

# Module: src/back/js/emit.bend:284
law j_desc_head_on:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +fuel: U32
  for +key: String
  String

# Module: src/back/js/emit.bend:295
law j_intrinsic:
  for +name: String
  Bool

# Module: src/back/js/emit.bend:329
law j_program_selected:
  for +book: List<&2, KDef>
  for +defs: List<&2, KDef>
  String

# Module: src/back/js/emit.bend:338
law j_program_context:
  for +book: List<&2, KDef>
  for +defs: List<&2, KDef>
  String

# Module: src/back/js/emit.bend:350
law j_schemas:
  for +book: List<&2, KDef>
  for +defs: List<&2, KDef>
  String

# Module: src/back/js/emit.bend:363
law j_schema_ctors:
  for +book: List<&2, KDef>
  for +ctors: List<&2, KDef>
  for +params: U32
  String

# Module: src/back/js/emit.bend:377
law j_schema_params:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +left: U32
  for +index: U32
  String

# Module: src/back/js/emit.bend:388
law j_schema_fields:
  for +book: List<&2, KDef>
  for +ty: KTerm
  String

# Module: src/back/js/emit.bend:397
law j_desc_args:
  for +book: List<&2, KDef>
  for +args: List<&2, KTerm>
  for +fuel: U32
  String

# Module: src/back/js/emit.bend:425
law j_constructor_mode:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +tail: Bool
  String

# Module: src/back/js/emit.bend:438
law j_ctor_thunks:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +tel: KTerm
  String

# Module: src/back/js/emit.bend:453
law j_constructor_literal:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +literal: String
  String

# Module: src/back/js/emit.bend:503
law j_library_selected:
  for +book: List<&2, KDef>
  for +defs: List<&2, KDef>
  String

# Module: src/back/js/emit.bend:512
law j_library_context:
  for +book: List<&2, KDef>
  for +defs: List<&2, KDef>
  String

# Module: src/back/js/emit.bend:521
law j_desc_kind:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +fuel: U32
  String

# Module: src/back/js/emit.bend:538
law j_library_roots:
  for +book: List<&2, KDef>
  List<&2, String>

# Module: src/back/js/emit.bend:698
law j_l_global:
  for +book: List<&2, KDef>
  for +d: KDef
  for +t: KTerm
  String

# Module: src/back/js/emit.bend:96
@unsafe
def j_local(id):
  "x" ++ U32.show(id)

# Module: src/back/js/emit.bend:100
@unsafe
def j_exprs(
  +book: List<&2, KDef>,
  +env: List<&2, KTerm>,
  +xs: List<&2, KTerm>,
) -> String:
  match xs:
    case Nil{}:
      ""
    case Con{h, rest}:
      j_expr(book, env, h, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, False{}) ++ j_exprs_tail(book, env, rest)

# Module: src/back/js/emit.bend:118
@unsafe
def j_exprs_tail(book, env, xs):
  match xs:
    case Nil{}:
      ""
    case Con{h, rest}:
      "," ++ j_expr(book, env, h, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, False{}) ++ j_exprs_tail(book, env, rest)

# Module: src/back/js/emit.bend:134
@unsafe
def j_expr(book, env, t, ty, tail):
  jir_compile(book, jir_lower(book, env, t, ty, tail))

# Module: src/back/js/emit.bend:138
@unsafe
def j_expr_legacy(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +tail: Bool) -> String:
  kc(String, p98_tag_eq(t, "JDirectCall"), u => j_direct_emit_call(book, env, t), u =>
  kc(String, (p98_tag_eq(t, "Lam") || p98_tag_eq(t, "Mat")) && Bool.not(p88_string_eq(j_l_name(t), "")), u => "F[" ++ j_quote(j_l_name(t)) ++ "](" ++ j_l_capture(env, Nil{}) ++ ")", u => j_expr_private(book, env, t, ty, tail)))

# Private nodes are created only by the bounded private-region plan. Ordinary
# types, arithmetic, arguments and parallel lets retain their shared emitter.

# Module: src/back/js/emit.bend:145
@unsafe
def j_expr_private(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +tail: Bool) -> String:
  kc(String, p98_tag_eq(t, "JF32"), u => j_private_float_code(ix(t)), u =>
  kc(String, p98_tag_eq(t, "JVirtual"), u => "[" ++ j_region_vector_names("$w", 0, ix(t)) ++ "]", u =>
  kc(String, p98_tag_eq(t, "JInline") || p98_tag_eq(t, "JInlineRead"), u => "(()=>{" ++ j_region_inline_return(book, env, t, ty) ++ "})()", u =>
  kc(String, p98_tag_eq(t, "JLoopSlot"), u => "$s" ++ U32.show(ix(t)), u =>
  kc(String, p98_tag_eq(t, "JSlot"), u => "$p" ++ U32.show(ix(t)), u =>
  kc(String, p98_tag_eq(t, "JNatRest"), u => "($p" ++ U32.show(ix(t)) ++ "-" ++ nm(t) ++ "n)", u =>
  kc(String, p98_tag_eq(t, "JNatCase"), u => "($p" ++ U32.show(ix(t)) ++ "===" ++ U32.show(qt(t)) ++ "n?" ++
    j_expr(book, env, kid(t, 0), ty, tail) ++ ":" ++ j_expr(book, env, kid(t, 1), ty, tail) ++ ")", u =>
  kc(String, p98_tag_eq(t, "JCall"), u => j_region_name(nm(t)) ++ kc(String, U32.is_eq(qt(t), 1), u => "$tree", u => "") ++ "(" ++ j_apply_args(book, env, ks(t), dt(lookup(book, nm(t)))) ++ ")", u =>
  kc(String, p98_tag_eq(t, "JReadCall"), u => j_region_name(nm(t)) ++ "$get(" ++ j_region_read_args(book, env, ks(t), dt(lookup(book, nm(t)))) ++ ")", u =>
  kc(String, p98_tag_eq(t, "JGeneric"), u => j_expr(book, env, j_region_app(ref(nm(t)), ks(t)), ty, False{}), u =>
  kc(String, p98_tag_eq(t, "JNative"), u => j_region_native_emit(book, env, t), u =>
  kc(String, p98_tag_eq(t, "JVector"), u => "[" ++ j_ctor_args(book, env, ks(t), j_region_local_fields(book, ty)) ++ "]", u =>
  kc(String, p98_tag_eq(t, "JUnpack"), u => "((" ++ j_region_parameters(U32.inc(ix(t)), U32.inc(U32.add(ix(t), qt(t)))) ++ ")=>" ++
    j_expr(book, env, kid(t, 0), ty, tail) ++ ")(" ++ j_flat_reads(book, kid(t, 1), "$p" ++ U32.show(ix(t)), 0, qt(t)) ++ ")", u =>
  kc(String, p98_tag_eq(t, "JIf"), u => "(" ++ j_expr(book, env, kid(t, 0), kt("ADT", "Bool", 0, 0, Nil{}), False{}) ++ "?" ++
    j_expr(book, env, kid(t, 1), ty, tail) ++ ":" ++ j_expr(book, env, kid(t, 2), ty, tail) ++ ")", u => j_expr_on(book, env, t, ty, tail, tg(t))))))))))))))))

# Module: src/back/js/emit.bend:165
@unsafe
def j_region_read_args(+book: List<&2,KDef>, +env: List<&2,KTerm>, +args: List<&2,KTerm>, +ty: KTerm) -> String:
  match args:
    case Nil{}: ""
    case Con{h, Nil{}}: j_apply_args(book, env, ks(j_strip(h)), dt(lookup(book, "Array.get")))
    case Con{h, rest}:
      +head = wnf(book, ty)
      j_expr(book, env, h, kid(head, 0), False{}) ++ "," ++ j_region_read_args(book, env, rest, j_app_type(head, h))

# Only legacy leaves/private constructors and marked Lam/Mat factories arrive
# here. Ordinary variables, applications, annotations and bindings are lowered
# by jir_lower; deep factories deliberately bypass their own marker once.

# Module: src/back/js/emit.bend:186
@unsafe
def j_expr_on(book, env, t, ty, tail, key):
  kc(String, p88_string_eq(key, "Ctr") || core_literal(t),
    u => j_constructor_mode(book, env, t, ty, tail), u =>
  kc(String, p88_string_eq(key, "Lam"),
    u => jir_compile(book, jir_lower_lambdas(book, env, t, wnf(book, ty), Nil{})), u =>
  kc(String, p88_string_eq(key, "Mat"),
    u => jir_compile(book, jir_lower_match(book, env, t, wnf(book, ty))), u =>
  kc(String, p88_string_eq(key, "Efq"), u => "fn(1,()=>bad(\"an absurd elimination\"))", u =>
  kc(String, p88_string_eq(key, "Hol"), u => "bad(\"cannot compile a hole\")", u =>
  kc(String, p88_string_eq(key, "ADT"),
    u => "({typeName:" ++ j_quote(nm(t)) ++ ",typeArgs:[" ++ j_exprs(book, env, ks(t)) ++ "]})", u =>
  kc(String, p88_string_eq(key, "Qua"), u => "({typeName:" ++ j_quote("&" ++ U32.show(qt(t))) ++ "})", u =>
  kc(String, p88_string_eq(key, "Typ"), u => "({typeName:\"Type\"})", u =>
  kc(String, p88_string_eq(key, "Rfl"), u => "({proof:true})", u => "null")))))))))

# Module: src/back/js/emit.bend:206
@unsafe
def j_lambda_count(t):
  kc(U32, p98_tag_eq(t, "Ann"), u => j_lambda_count(kid(t, 0)), u => kc(U32, p98_tag_eq(t, "Lam"), u => U32.add(1, j_lambda_count(kid(t, 0))), u => 0))

# Module: src/back/js/emit.bend:218
@unsafe
def j_lambda_code(book, env, t, ty, at):
  kc(String, p98_tag_eq(t, "Ann"), u => j_lambda_code(book, env, kid(t, 0), kid(t, 1), at), u => kc(String, p98_tag_eq(t, "Lam"), u => j_lambda_bind(book, env, t, wnf(book, ty), at), u => "return " ++ j_expr(book, env, t, ty, True{}) ++ ";"))

# Module: src/back/js/emit.bend:230
@unsafe
def j_lambda_bind(book, env, t, ty, at):
  "const " ++ j_local(ix(t)) ++ "=" ++ kc(String, U32.is_eq(qt(ty), 0) && p98_tag_eq(ty, "All"), u => "null", u => "a[" ++ U32.show(at) ++ "]") ++ ";" ++ j_lambda_code(book, Con{kt("Env", "", ix(t), 0, Con{kid(ty, 0), Nil{}}), env}, kid(t, 0), subst(kid(ty, 1), ix(ty), var(nm(t), ix(t))), U32.add(at, 1))

# Module: src/back/js/emit.bend:238
@unsafe
def j_call_arity(d):
  kc(U32, db(d) && j_intrinsic(dn(d)), u => da(d), u => j_lambda_count(dv(d)))

# Module: src/back/js/emit.bend:249
@unsafe
def j_apply_args(book, env, args, ty):
  j_apply_args_head(book, env, args, wnf(book, ty))

# Module: src/back/js/emit.bend:260
@unsafe
def j_apply_args_head(book, env, args, ty):
  match args:
    case Nil{}: ""
    case Con{h, rest}:
      kc(String, p98_tag_eq(ty, "All") && U32.is_eq(qt(ty), 0), u => "null", u => j_expr(book, env, h, kid(ty, 0), False{})) ++ "," ++ j_apply_args(book, env, rest, j_app_type(ty, h))

# Module: src/back/js/emit.bend:273
@unsafe
def j_descriptor(book, ty, fuel):
  j_desc_kind(book, wnf(book, ty), fuel)

# Module: src/back/js/emit.bend:277
@unsafe
def j_desc_head(
  +book: List<&2, KDef>,
  +ty: KTerm,
  +fuel: U32,
) -> String:
  j_desc_head_on(book, ty, fuel, nm(ty))

# Module: src/back/js/emit.bend:292
@unsafe
def j_desc_head_on(book, ty, fuel, key):
  kc(String, p88_string_eq(key, "Char"), u => "[\"Char\"]", u => kc(String, p88_string_eq(key, "F32"), u => "[\"F32\"]", u => kc(String, p88_string_eq(key, "List"), u => "[\"List\"," ++ j_descriptor(book, kid(ty, 1), fuel) ++ "]", u => kc(String, p88_string_eq(key, "Array"), u => "[\"Array\"," ++ j_descriptor(book, kid(ty, 0), fuel) ++ "]", u => kc(String, p88_string_eq(key, "Sigma"), u => "[\"Tuple\"," ++ j_descriptor(book, kid(ty, 2), fuel) ++ "," ++ j_descriptor(book, kid(kid(ty, 3), 0), fuel) ++ "]", u => kc(String, p98_tag_eq(ty, "Var"), u => "(typeof " ++ j_local(ix(ty)) ++ "===\"undefined\"?null:" ++ j_local(ix(ty)) ++ ")", u => kc(String, p98_tag_eq(ty, "ADT"), u => "[\"Named\"," ++ j_quote(nm(ty)) ++ ",[" ++ j_desc_args(book, ks(ty), fuel) ++ "]]", u => "null")))))))

# Module: src/back/js/emit.bend:300
@unsafe
def j_intrinsic(name):
  String.contains("|U32.add|U32.sub|U32.and|U32.or|U32.xor|U32.is_eq|U32.is_ne|U32.is_lt|U32.is_le|U32.is_gt|U32.is_ge|U32.mul|U32.div|U32.mod|U32.inc|U32.shl|U32.shr|U32.shln|U32.shrn|U32.not|U32.is_zero|U32.cmp|U32.to_f32|U32.to_nat|U32.from_nat|F32.add|F32.sub|F32.mul|F32.div|F32.neg|F32.is_eq|F32.is_ne|F32.is_lt|F32.is_le|F32.is_gt|F32.is_ge|F32.sqrt|F32.exp|F32.log|F32.log2|F32.log10|F32.sin|F32.cos|F32.tan|F32.asin|F32.acos|F32.atan|F32.sinh|F32.cosh|F32.tanh|F32.floor|F32.ceil|F32.trunc|F32.abs|F32.pow|F32.atan2|F32.mod|F32.to_u32|F32.bits|F32.show|F32.read|Nat.add|Nat.sub|Nat.mul|Nat.double|Nat.cmp|Nat.is_lt|Nat.divmod|Array.new|Array.set|Array.get|Array.swap|Array.size|Array.clone|Array.atomic.add|Array.atomic.min|Array.atomic.max|Array.atomic.and|Array.atomic.or|Array.atomic.xor|Array.atomic.exch|Array.atomic.cas|Array.atomic.fadd|IO.pure|IO.bind|IO.try|IO.pass|IO.die|IO.args|IO.print|IO.write|IO.print_err|IO.get_env|IO.now|IO.sleep|IO.random_u32|IO.spawn|IO.fork|IO.join|String.append|String.length|String.eq|String.contains|String.starts_with|String.reverse|String.is_empty|Bool.or|Bool.xor|", "|" ++ name ++ "|")

# Module: src/back/js/emit.bend:304
@unsafe
def j_def(
  +book: List<&2, KDef>,
  +d: KDef,
) -> String:
  kc(String, p98_tag_eq(dv(d), "Foreign"), u => j_foreign_def(book, d), u => kc(String, p88_string_eq(dk(d), "Def") && U32.is_eq(dx(d), 0) && Bool.not(p98_tag_eq(dv(d), "Absent")) && Bool.not(p98_tag_eq(dv(d), "Foreign")),
    u => kc(String, db(d) && j_intrinsic(dn(d)), u => "if(!Object.hasOwn(G," ++ j_quote(dn(d)) ++ "))", u => "") ++ j_l_def(book, d),
    u => ""))

# Module: src/back/js/emit.bend:313
@unsafe
def j_defs(
  +book: List<&2, KDef>,
  +defs: List<&2, KDef>,
) -> String:
  match defs:
    case Nil{}:
      ""
    case Con{d, rest}:
      j_def(book, d) ++ j_defs(book, rest)

# Module: src/back/js/emit.bend:324
@unsafe
def j_program(
  +book: List<&2, KDef>,
) -> String:
  j_program_selected(book, book)

# Module: src/back/js/emit.bend:335
@unsafe
def j_program_selected(book, defs):
  j_program_context(j_plan_context(book_context(book), defs), defs)

# Module: src/back/js/emit.bend:344
@unsafe
def j_program_context(book, defs):
  j_ctor_metadata(defs) ++ j_schemas(book, defs) ++ j_defs(book, defs) ++ "\nawait runmain(" ++ j_descriptor(book, dt(lookup(book, "main")), 64) ++ "," ++ kc(String, j_io_type(book, dt(lookup(book, "main"))), u => "true", u => "false") ++ ");\n"

# Constructor telescopes specialize ADT parameters before entering match arms.
# Readback schemas are finite graphs. Recursive ADTs refer to schema names;
# neither the compiler nor the runtime expands recursive types eagerly.

# Module: src/back/js/emit.bend:356
@unsafe
def j_schemas(book, defs):
  match defs:
    case Nil{}:
      ""
    case Con{d, rest}:
      kc(String, p88_string_eq(dk(d), "ADT"), u => "showSchemas[" ++ j_quote(dn(d)) ++ "]=(p)=>[\"ADT\",{" ++ j_schema_ctors(book, dc(d), da(d)) ++ "}];\n", u => "") ++ j_schemas(book, rest)

# Module: src/back/js/emit.bend:370
@unsafe
def j_schema_ctors(book, ctors, params):
  match ctors:
    case Nil{}:
      ""
    case Con{d, rest}:
      j_quote(dn(d)) ++ ":(()=>{" ++ j_schema_params(book, dt(d), params, 0) ++ "})()," ++ j_schema_ctors(book, rest, params)

# Module: src/back/js/emit.bend:385
@unsafe
def j_schema_params(book, ty, left, index):
  kc(String, U32.is_eq(left, 0), u => "return [" ++ j_schema_fields(book, ty) ++ "];", u => "const " ++ j_local(ix(ty)) ++ "=p[" ++ U32.show(index) ++ "];" ++ j_schema_params(book, kid(ty, 1), U32.sub(left, 1), U32.add(index, 1)))

# Module: src/back/js/emit.bend:394
@unsafe
def j_schema_fields(book, ty):
  kc(String, p98_tag_eq(ty, "All"), u => kc(String, U32.is_eq(qt(ty), 0), u => "[\"Erased\"]", u => j_descriptor(book, kid(ty, 0), 64)) ++ "," ++ j_schema_fields(book, kid(ty, 1)), u => "")

# Module: src/back/js/emit.bend:404
@unsafe
def j_desc_args(book, args, fuel):
  match args:
    case Nil{}:
      ""
    case Con{h, rest}:
      j_descriptor(book, h, fuel) ++ "," ++ j_desc_args(book, rest, fuel)

# Module: src/back/js/emit.bend:411
@unsafe
def j_ctor_args(
  +book: List<&2, KDef>,
  +env: List<&2, KTerm>,
  +args: List<&2, KTerm>,
  +tel: KTerm,
) -> String:
  match args:
    case Nil{}:
      ""
    case Con{h, rest}:
      kc(String, p98_tag_eq(tel, "All") && U32.is_eq(qt(tel), 0), u => "null", u => j_expr(book, env, h, kid(tel, 0), False{})) ++ "," ++ j_ctor_args(book, env, rest, j_app_type(tel, h))

# Constructor fields in return position are evaluated by the application
# trampoline, retaining source order without growing the host call stack.

# Module: src/back/js/emit.bend:434
@unsafe
def j_constructor_mode(book, env, t, ty, tail):
  +literal = j_literal_typed(book, t, ty)
  kc(String, tail && p88_string_eq(literal, ""), u => "build(" ++ j_quote(nm(t)) ++ ",[" ++ j_ctor_thunks(book, env, ks(t), j_specialize(book, dt(j_layout_ctor(book, wnf(book, ty), nm(t))), ks(wnf(book, ty)))) ++ "])", u => j_constructor_literal(book, env, t, ty, literal))

# Module: src/back/js/emit.bend:446
@unsafe
def j_ctor_thunks(book, env, args, tel):
  match args:
    case Nil{}:
      ""
    case Con{h, rest}:
      "()=>" ++ kc(String, p98_tag_eq(tel, "All") && U32.is_eq(qt(tel), 0), u => "null", u => j_expr(book, env, h, kid(tel, 0), True{})) ++ "," ++ j_ctor_thunks(book, env, rest, j_app_type(tel, h))

# Module: src/back/js/emit.bend:462
@unsafe
def j_constructor_literal(book, env, t, ty, literal):
  +native = j_owned_native_literal(book, env, t, ty)
  kc(String, Bool.not(p88_string_eq(native, "")), u => native, u =>
  kc(String, p88_string_eq(literal, ""), u =>
    kc(String, j_owned_ctor(book, t, ty),
      u => kc(String, j_flat_data(book, ty),
        u => "({$:" ++ j_quote(nm(t)) ++ "," ++ j_flat_ctor_args(book, env, ks(t), j_specialize(book, dt(j_layout_ctor(book, wnf(book, ty), nm(t))), ks(wnf(book, ty))), 0) ++ "})",
        u => "({$:" ++ j_quote(nm(t)) ++ ",a:[" ++ j_ctor_args(book, env, ks(t), j_specialize(book, dt(j_layout_ctor(book, wnf(book, ty), nm(t))), ks(wnf(book, ty)))) ++ "]})"),
      u => "ctor(" ++ j_quote(nm(t)) ++ ",[" ++ j_ctor_args(book, env, ks(t), j_specialize(book, dt(j_layout_ctor(book, wnf(book, ty), nm(t))), ks(wnf(book, ty)))) ++ "])"), u => literal))

# Only owned private eager constructors use canonical closed native layouts.
# Preserve original typed field emission, erased slots, order and aliases.

# Module: src/back/js/emit.bend:475
@unsafe
def j_owned_native_literal(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm) -> String:
  kc(String, p98_tag_eq(t, "Ctr") && has_name(rm(t), "$private.owned.ctor"),
    u => j_owned_native_head(book, env, t, wnf(book, ty)), u => "")

# Module: src/back/js/emit.bend:480
@unsafe
def j_owned_native_head(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +head: KTerm) -> String:
  +c = j_layout_ctor(book, head, nm(t))
  kc(String, p88_string_eq(nm(t), "Tuple") && U32.is_eq(terms_len(ks(t)), 2) &&
    j_pure_closed_sigma(book, head) && j_pure_native_ctor(c, "Tuple", 2),
    u => "[" ++ j_ctor_args(book, env, ks(t), j_specialize(book, dt(c), ks(head))) ++ "]", u =>
  kc(String, ((p88_string_eq(nm(t), "Nil") && U32.is_eq(terms_len(ks(t)), 0) && j_pure_native_ctor(c, "Nil", 0)) ||
    (p88_string_eq(nm(t), "Con") && U32.is_eq(terms_len(ks(t)), 2) && j_pure_native_ctor(c, "Con", 2))) &&
    j_pure_closed_list(book, head),
    u => "({$:" ++ j_quote(nm(t)) ++ ",a:[" ++ j_ctor_args(book, env, ks(t), j_specialize(book, dt(c), ks(head))) ++ "]})", u =>
  kc(String, U32.is_eq(terms_len(ks(t)), 0) && j_primitive_type(book, head, "Bool") &&
    ((p88_string_eq(nm(t), "True") && j_pure_native_ctor(c, "True", 0)) ||
     (p88_string_eq(nm(t), "False") && j_pure_native_ctor(c, "False", 0))),
    u => kc(String, p88_string_eq(nm(t), "True"), u => "true", u => "false"), u => "")))


# Library output exposes the same primitive ABI as generated executables;
# callers may use G/call/list/ctor without invoking main.

# Module: src/back/js/emit.bend:498
@unsafe
def j_library(
  +book: List<&2, KDef>,
) -> String:
  j_library_selected(book, book)

# Module: src/back/js/emit.bend:509
@unsafe
def j_library_selected(book, defs):
  j_library_context(j_plan_context(book_context(book), defs), defs)

# Module: src/back/js/emit.bend:518
@unsafe
def j_library_context(book, defs):
  j_ctor_metadata(defs) ++ j_schemas(book, defs) ++ j_defs(book, defs) ++ "\nexport {G,call,list,ctor};\nexport default Object.fromEntries(Object.keys(G).map(k=>[k.replace(':','.'),(...args)=>call(get(G,k),args)]));\n"

# Module: src/back/js/emit.bend:528
@unsafe
def j_desc_kind(book, ty, fuel):
  kc(String, p98_tag_eq(ty, "All"), u => "[\"Fun\"," ++ U32.show(qt(ty)) ++ "," ++ j_descriptor(book, kid(ty, 0), fuel) ++ "," ++ j_descriptor(book, kid(ty, 1), fuel) ++ "]", u => j_desc_head(book, ty, fuel))
# Roots and intrinsic stops for the shared dependency reachability pass.

# Module: src/back/js/emit.bend:532
@unsafe
def j_roots(
  +book: List<&2, KDef>,
  +library: Bool,
) -> List<&2, String>:
  kc(List<&2, String>, library, u => j_library_roots(book), u => ["main"])

# Module: src/back/js/emit.bend:543
@unsafe
def j_library_roots(book):
  match book:
    case Nil{}:
      Nil{}
    case Con{d, rest}:
      kc(List<&2, String>, p88_string_eq(dk(d), "Def") && U32.is_eq(dx(d), 0) && Bool.not(p98_tag_eq(dv(d), "Absent")) && (Bool.not(db(d)) || p98_tag_eq(dv(d), "Foreign")), u => Con{dn(d), j_library_roots(rest)}, u => j_library_roots(rest))

# Module: src/back/js/emit.bend:551
@unsafe
def j_stops(
  +book: List<&2, KDef>,
) -> List<&2, String>:
  match book:
    case Nil{}:
      Nil{}
    case Con{d, rest}:
      kc(List<&2, String>, db(d) && j_intrinsic(dn(d)), u => Con{dn(d), j_stops(rest)}, u => j_stops(rest))
# A checked residual datatype with one remaining constructor needs projection,
# not another tag test. This also preserves the foreign JS lane's trusted values.
# Deep closures use flat factories with explicit lexical captures.

# Module: src/back/js/emit.bend:563
@unsafe
def j_l_name(t):
  j_l_names(rm(t))

# Module: src/back/js/emit.bend:567
@unsafe
def j_l_names(names):
  match names:
    case Nil{}: ""
    case Con{h, rest}: kc(String, String.starts_with(h, "$js."), u => h, u => "")

# Module: src/back/js/emit.bend:573
@unsafe
def j_l_capture(env, seen):
  match env:
    case Nil{}: ""
    case Con{h, rest}:
      kc(String, has_name(seen, j_local(ix(h))), u => j_l_capture(rest, seen), u => j_local(ix(h)) ++ "," ++ j_l_capture(rest, Con{j_local(ix(h)), seen}))

# Module: src/back/js/emit.bend:580
@unsafe
def j_l_deep(
  +t: KTerm,
  +depth: U32,
) -> Bool:
  kc(Bool, p98_tag_eq(t, "Ann"), u => j_l_deep(kid(t, 0), depth), u =>
  kc(Bool, p98_tag_eq(t, "Var") || p98_tag_eq(t, "Ref"), u => False{}, u =>
  kc(Bool, p98_tag_eq(t, "Lam") || p98_tag_eq(t, "Mat"), u => kc(Bool, U32.is_ge(depth, 32), u => True{}, u => j_l_deeps(ks(t), U32.inc(depth))), u => j_l_deeps(ks(t), depth))))

# Module: src/back/js/emit.bend:589
@unsafe
def j_l_deeps(ts, depth):
  match ts:
    case Nil{}: False{}
    case Con{h, rest}: kc(Bool, j_l_deep(h, depth), u => True{}, u => j_l_deeps(rest, depth))

# Module: src/back/js/emit.bend:595
@unsafe
def j_l_mark(
  +t: KTerm,
  +path: String,
  +depth: U32,
) -> KTerm:
  kc(KTerm, p98_tag_eq(t, "Ann"), u => k_with_children(t, [j_l_mark(kid(t, 0), path, depth), kid(t, 1)]), u =>
  kc(KTerm, p98_tag_eq(t, "Var") || p98_tag_eq(t, "Ref"), u => t, u =>
  kc(KTerm, p98_tag_eq(t, "Lam") || p98_tag_eq(t, "Mat"), u =>
    kc(KTerm, U32.is_ge(depth, 32), u => k_rebuild(t, nm(t), ix(t), qt(t), j_l_marks(ks(t), path, 0, 0), ["$js." ++ path], kb(t), ke(t)), u => k_with_children(t, j_l_marks(ks(t), path, U32.inc(depth), 0))), u =>
    k_with_children(t, j_l_marks(ks(t), path, depth, 0)))))

# Module: src/back/js/emit.bend:607
@unsafe
def j_l_marks(ts, path, depth, at):
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{j_l_mark(h, path ++ "_" ++ U32.show(at), depth), j_l_marks(rest, path, depth, U32.inc(at))}

# Module: src/back/js/emit.bend:613
@unsafe
def j_l_def(book, d):
  +worker = j_nat_loop_worker(book, d)
  kc(String, p88_string_eq(worker, ""), u => j_l_def_tree(book, d, j_tree_worker(book, d)),
    u => j_l_def_selected(book, d, "G[" ++ j_quote(dn(d)) ++ "]=" ++ worker ++ ";\n"))

# Module: src/back/js/emit.bend:619
@unsafe
def j_l_def_tree(+book: List<&2,KDef>, +d: KDef, +worker: String) -> String:
  kc(String, p88_string_eq(worker, ""), u => j_l_def_callback(book, d, j_callback_root(book, d)),
    u => j_l_def_selected(book, d, "G[" ++ j_quote(dn(d)) ++ "]=" ++ worker ++ ";\n"))

# Module: src/back/js/emit.bend:624
@unsafe
def j_l_def_callback(+book: List<&2,KDef>, +d: KDef, +worker: String) -> String:
  kc(String, p88_string_eq(worker, ""), u => j_l_def_composite(book, d, j_region_root_plan(book, d)),
    u => j_l_def_selected(book, d, j_l_global_worker(book, d, dv(d), worker)))

# Module: src/back/js/emit.bend:629
@unsafe
def j_l_def_composite(+book: List<&2,KDef>, +d: KDef, +plan: JRootPlan) -> String:
  match plan:
    case JRootPlan{code, strong}:
      j_l_def_region(book, d, kc(JRootPlan, p88_string_eq(code, ""),
        u => j_array_result_root_plan(book, d), u => plan))

# Module: src/back/js/emit.bend:636
@unsafe
def j_l_def_region(+book: List<&2,KDef>, +d: KDef, +plan: JRootPlan) -> String:
  match plan:
    case JRootPlan{code, strong}:
      kc(String, strong, u => j_l_def_selected(book, d, j_l_global_worker(book, d, dv(d), code)),
        u => j_l_def_array_literal(book, d, code))

# Module: src/back/js/emit.bend:643
@unsafe
def j_l_def_instance(+book: List<&2,KDef>, +d: KDef, +region: String, +instance: String) -> String:
  kc(String, p88_string_eq(instance, ""), u =>
    j_l_def_selected(book, d, kc(String, p88_string_eq(region, ""), u => j_u32_global(book, d, j_u32_worker(book, d)),
      u => j_l_global_worker(book, d, dv(d), region))),
    u => j_l_global_worker(book, d, dv(d), instance))

# Module: src/back/js/emit.bend:650
@unsafe
def j_l_def_selected(+book: List<&2,KDef>, +d: KDef, +code: String) -> String:
  +component = lookup(book, dn(d))
  code ++ j_component_declaration(book, component, j_component_cached(book, dn(component)))

# Module: src/back/js/emit.bend:655
@unsafe
def j_l_definition(book, d, t):
  "{const F=Object.create(null);\n" ++ j_l_walk(book, Nil{}, t, dt(d)) ++ j_l_global(book, d, t) ++ "}\n"

# Module: src/back/js/emit.bend:659
@unsafe
def j_l_walk(book, env, t, ty):
  kc(String, p98_tag_eq(t, "Ann"), u => j_l_walk(book, env, kid(t, 0), kid(t, 1)), u =>
  kc(String, p88_string_eq(j_l_name(t), ""), u => "", u => "F[" ++ j_quote(j_l_name(t)) ++ "]=function(" ++ j_l_capture(env, Nil{}) ++ "){return " ++ j_expr_on(book, env, t, ty, False{}, tg(t)) ++ ";};\n") ++ j_l_children(book, env, t, ty))

# Module: src/back/js/emit.bend:664
@unsafe
def j_l_children(book, env, t, ty):
  kc(String, p98_tag_eq(t, "Lam"), u => j_l_lam(book, env, t, wnf(book, ty)), u =>
  kc(String, p98_tag_eq(t, "Mat"), u => j_l_mat(book, env, t, wnf(book, ty)), u =>
  kc(String, p98_tag_eq(t, "App"), u => j_l_app(book, env, t, wnf(book, j_type(book, env, kid(t, 0)))), u =>
  kc(String, p98_tag_eq(t, "Let"), u => j_l_bindings(book, env, ks(t)) ++ j_l_walk(book, j_context(book, env, ks(t)), j_body(ks(t)), ty), u =>
  kc(String, p98_tag_eq(t, "Ctr"), u => kc(String, p88_string_eq(j_literal_typed(book, t, ty), ""), u => j_l_fields(book, env, ks(t), j_specialize(book, dt(j_layout_ctor(book, wnf(book, ty), nm(t))), ks(wnf(book, ty)))), u => ""), u =>
  kc(String, p98_tag_eq(t, "Rwt"), u => j_l_walk(book, env, kid(t, 2), ty), u => ""))))))

# Module: src/back/js/emit.bend:673
@unsafe
def j_l_lam(book, env, t, ty):
  j_l_walk(book, Con{kt("Env", "", ix(t), 0, [kid(ty, 0)]), env}, kid(t, 0), subst(kid(ty, 1), ix(ty), var(nm(t), ix(t))))

# Module: src/back/js/emit.bend:677
@unsafe
def j_l_mat(book, env, t, ty):
  j_l_walk(book, env, kid(t, 0), j_arm_type(book, ty, nm(t))) ++ kc(String, U32.is_eq(j_constructor_count(book, wnf(book, kid(ty, 0))), 1), u => "", u => j_l_walk(book, env, kid(t, 1), ty))

# Module: src/back/js/emit.bend:681
@unsafe
def j_l_app(book, env, t, ty):
  j_l_walk(book, env, kid(t, 0), ty) ++ kc(String, p98_tag_eq(ty, "All") && U32.is_eq(qt(ty), 0), u => "", u => j_l_walk(book, env, kid(t, 1), kid(ty, 0)))

# Module: src/back/js/emit.bend:685
@unsafe
def j_l_fields(book, env, ts, ty):
  match ts:
    case Nil{}: ""
    case Con{h, rest}: kc(String, p98_tag_eq(ty, "All") && U32.is_eq(qt(ty), 0), u => "", u => j_l_walk(book, env, h, kid(ty, 0))) ++ j_l_fields(book, env, rest, j_app_type(ty, h))

# Module: src/back/js/emit.bend:691
@unsafe
def j_l_bindings(book, env, ts):
  match ts:
    case Nil{}: ""
    case Con{h, Nil{}}: ""
    case Con{h, rest}: kc(String, U32.is_eq(qt(h), 0), u => "", u => j_l_walk(book, env, kid(h, 0), j_type(book, env, kid(h, 0)))) ++ j_l_bindings(book, env, rest)

# Leading lambdas and matchers are pure closure initializers; their bodies stay delayed.

# Module: src/back/js/emit.bend:705
@unsafe
def j_l_global(book, d, t):
  j_l_global_worker(book, d, t, j_projection_worker(book, t, dt(d)))

# Module: src/back/js/emit.bend:709
@unsafe
def j_region_native_emit(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm) -> String:
  j_array_effect_emit(book, env, t, j_array_view_active(book))

# Module: src/back/js/emit.bend:713
@unsafe
def j_region_field_reads(+base: String, +at: U32, +total: U32) -> String:
  kc(String, U32.is_eq(at, total), u => "", u => base ++ "[" ++ U32.show(at) ++ "]" ++
    kc(String, U32.is_eq(U32.inc(at), total), u => "", u => "," ++ j_region_field_reads(base, U32.inc(at), total)))
