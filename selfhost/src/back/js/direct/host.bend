
# Native Nat rows compare the original scrutinee at every literal alternative.
# A predecessor subtraction is a demanded arm view, never an intermediate test.
# This mirrors mat_nats, including the final unconditional fallback row.

# Module: src/back/js/direct/host.bend:128
type JDHostFields is Data:
  JDHostFieldsEnd{+error: String}
  JDHostFieldsCon{+name: String, +marshal: String, +rest: JDHostFields}

# Module: src/back/js/direct/host.bend:169
type JDHostSignature is Data:
  JDHostSignature{+result: KTerm, +heads: List<&2,KTerm>}

# Module: src/back/js/direct/host.bend:4
@unsafe
def jd_host_error(+message: String) -> String:
  "(\n/*JD_UNSUPPORTED: host marshalling */()=>{throw new Error(" ++ j_quote("direct-js prototype unsupported: " ++ message) ++ ");})"

# One global worklist budget: repeated recursive datatypes are visited once per
# exact specialized type. Abstract erased types have no known Nat conversion.

# Module: src/back/js/direct/host.bend:10
@unsafe
def jd_host_nat_status(+book: List<&2,KDef>, +todo: List<&2,KTerm>, +seen: List<&2,String>, +fuel: U32) -> U32:
  match todo:
    case Nil{}: 0
    case Con{t, rest}:
      kc(U32, U32.is_gt(fuel, 0),
        u => jd_host_nat_status_on(book, wnf(book, t), rest, seen, U32.sub(fuel, 1)), u => 2)

# Module: src/back/js/direct/host.bend:18
@unsafe
def jd_host_nat_status_on(+book: List<&2,KDef>, +t: KTerm, +rest: List<&2,KTerm>, +seen: List<&2,String>, +fuel: U32) -> U32:
  kc(U32, p98_tag_eq(t, "All"), u =>
    jd_host_nat_status(book, kc(List<&2,KTerm>, U32.is_eq(qt(t), 0),
      u => Con{j_app_type(t, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), rest}, u => Con{kid(t, 0), Con{j_app_type(t, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), rest}}), seen, fuel), u =>
    kc(U32, p98_tag_eq(t, "ADT"), u =>
      kc(U32, p88_string_eq(nm(t), "Nat") && db(lookup(book, nm(t))), u => 1, u =>
        kc(U32, has_name(seen, term_key(t)), u => jd_host_nat_status(book, rest, seen, fuel), u =>
          jd_host_nat_status(book, List.append(&2,KTerm,
            jd_host_ctor_types(book, dc(lookup(book, nm(t))), ks(t)), rest),
            Con{term_key(t), seen}, fuel))), u => jd_host_nat_status(book, rest, seen, fuel)))

# Module: src/back/js/direct/host.bend:30
@unsafe
def jd_host_ctor_types(+book: List<&2,KDef>, +ctors: List<&2,KDef>, +args: List<&2,KTerm>) -> List<&2,KTerm>:
  match ctors:
    case Nil{}: Nil{}
    case Con{c, rest}: Con{j_specialize(book, dt(c), args), jd_host_ctor_types(book, rest, args)}

# Module: src/back/js/direct/host.bend:36
@unsafe
def jd_marshal(+book: List<&2,KDef>, +ty: KTerm, +out: Bool) -> String:
  jd_host_scalar(book, wnf(book, ty), out)

# The current upstream host ABI converts only a scalar at the declared edge.
# Aggregates and functions retain their identity and native Number Nat fields.
@unsafe
def jd_host_scalar(+book: List<&2,KDef>, +ty: KTerm, +out: Bool) -> String:
  kc(String, p98_tag_eq(ty, "ADT") && db(lookup(book, nm(ty))), u =>
    kc(String, p88_string_eq(nm(ty), "Char") || p88_string_eq(nm(ty), "String"),
      v => kc(String, out, w => "str_out", w => "str_in"), v =>
    kc(String, Bool.not(out) && p88_string_eq(nm(ty), "Nat"), w => "nat_in", w =>
    kc(String, Bool.not(out) && p88_string_eq(nm(ty), "F32"), z => "Math.fround", z => ""))),
    u => "")

# Module: src/back/js/direct/host.bend:42
@unsafe
def jd_host_marshal(+book: List<&2,KDef>, +ty: KTerm, +out: Bool,
  +seen: List<&2,KTerm>, +depth: U32, +fuel: U32) -> String:
  kc(String, U32.is_gt(fuel, 0), u =>
    jd_host_marshal_on(book, wnf(book, ty), out, seen, depth, U32.sub(fuel, 1)),
    u => jd_host_error("host type marshalling depth"))

# Module: src/back/js/direct/host.bend:49
@unsafe
def jd_host_marshal_on(+book: List<&2,KDef>, +t: KTerm, +out: Bool,
  +seen: List<&2,KTerm>, +depth: U32, +fuel: U32) -> String:
  jd_host_scalar(book, t, out)

# Module: src/back/js/direct/host.bend:59
@unsafe
def jd_host_marshal_fun(+book: List<&2,KDef>, +t: KTerm, +out: Bool,
  +seen: List<&2,KTerm>, +depth: U32, +fuel: U32) -> String:
  +result = jd_host_marshal(book, j_app_type(t, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), out, seen, depth, fuel)
  kc(String, U32.is_eq(qt(t), 0), u => result, u =>
    jd_host_marshal_fun_done(jd_host_marshal(book, kid(t, 0), Bool.not(out), seen, depth, fuel), result))

# Module: src/back/js/direct/host.bend:66
@unsafe
def jd_host_marshal_fun_done(+input: String, +result: String) -> String:
  kc(String, p88_string_eq(input ++ result, ""), u => "",
    u => "((f)=>(x)=>" ++ result ++ "(f(" ++ input ++ "(x))))")

# Module: src/back/js/direct/host.bend:71
@unsafe
def jd_host_marshal_key(+t: KTerm, +out: Bool) -> String:
  kc(String, out, u => "out ", u => "in ") ++ term_key(t)

# Module: src/back/js/direct/host.bend:75
@unsafe
def jd_host_marshal_find(+seen: List<&2,KTerm>, +key: String) -> String:
  match seen:
    case Nil{}: ""
    case Con{t, rest}:
      kc(String, p88_string_eq(nm(t), key), u => "$dm" ++ U32.show(ix(t)),
        u => jd_host_marshal_find(rest, key))

# Every ADT or Array converter shares one explicit work stack. Its owner
# drains pending (converter, object, field) triples; Nat and function parts
# convert immediately. Named lexical references close recursive type graphs.

# Module: src/back/js/direct/host.bend:86
@unsafe
def jd_host_marshal_named(+book: List<&2,KDef>, +t: KTerm, +out: Bool,
  +seen: List<&2,KTerm>, +depth: U32, +fuel: U32) -> String:
  +key = jd_host_marshal_key(t, out)
  +found = jd_host_marshal_find(seen, key)
  kc(String, p88_string_eq(found, ""), u =>
    "(function $dm" ++ U32.show(depth) ++ "(v,q){const own=q===undefined;if(own)q=[];let r;" ++
      jd_host_marshal_body(book, t, out,
        Con{kt("JDMarshal", key, depth, 0, Nil{}), seen}, U32.inc(depth), fuel) ++
      "if(own)while(q.length){const i=q.pop(),a=q.pop();a[i]=q.pop()(a[i],q);}return r;})", u => found)

# Module: src/back/js/direct/host.bend:97
@unsafe
def jd_host_marshal_body(+book: List<&2,KDef>, +t: KTerm, +out: Bool,
  +seen: List<&2,KTerm>, +depth: U32, +fuel: U32) -> String:
  kc(String, p88_string_eq(nm(t), "Array") && db(lookup(book, nm(t))), u =>
    "r=v;v.forEach((x,i)=>{" ++
      jd_host_marshal_put(jd_host_marshal(book, kid(t, 0), out, seen, depth, fuel), "v", "i") ++ "});", u =>
    "switch(v.$){" ++ jd_host_marshal_ctors(book, dc(lookup(book, nm(t))), ks(t), out, seen, depth, fuel) ++
      "default:throw " ++ j_quote("bend: " ++ name_key(nm(t)) ++ " has no tag ") ++ "+v?.$+" ++
        j_quote(" (its tags: " ++ jd_host_ctor_tags(dc(lookup(book, nm(t)))) ++
          "); a tag names its constructor as the loading file sees it, which a later version will make the same everywhere (#1105)") ++ ";}")

# Composite expressions and lexical recursive references accept the shared q.
# Function wrappers and scalar conversions deliberately stay immediate.

# Module: src/back/js/direct/host.bend:110
@unsafe
def jd_host_marshal_put(+marshal: String, +object: String, +field: String) -> String:
  kc(String, p88_string_eq(marshal, ""), u => "", u =>
    kc(String, String.starts_with(marshal, "$dm") || String.starts_with(marshal, "(function $dm"), u =>
      "q.push(" ++ marshal ++ "," ++ object ++ "," ++ field ++ ");", u =>
      object ++ "[" ++ field ++ "]=" ++ marshal ++ "(" ++ object ++ "[" ++ field ++ "]);") )

# Module: src/back/js/direct/host.bend:117
@unsafe
def jd_host_marshal_ctors(+book: List<&2,KDef>, +ctors: List<&2,KDef>, +args: List<&2,KTerm>,
  +out: Bool, +seen: List<&2,KTerm>, +depth: U32, +fuel: U32) -> String:
  match ctors:
    case Nil{}: ""
    case Con{c, rest}:
      jd_host_marshal_arm(book, c, j_specialize(book, dt(c), args), out, seen, depth, fuel) ++
      jd_host_marshal_ctors(book, rest, args, out, seen, depth, fuel)

# One constructor field plan supplies the copy decision and queued field work.
# An exhausted telescope keeps its explicit refusal; it cannot silently omit
# an unconverted field. Type-planning depth/fuel remains bounded.

# Module: src/back/js/direct/host.bend:133
@unsafe
def jd_host_marshal_arm(+book: List<&2,KDef>, +c: KDef, +tel: KTerm, +out: Bool,
  +seen: List<&2,KTerm>, +depth: U32, +fuel: U32) -> String:
  jd_host_marshal_arm_fields(c, jd_host_marshal_field_rows(book, tel, out, seen, depth, fuel))

# Module: src/back/js/direct/host.bend:138
@unsafe
def jd_host_marshal_arm_fields(+c: KDef, +fields: JDHostFields) -> String:
  +work = jd_host_marshal_rows_text(fields)
  "case " ++ j_quote(jd_tag(dn(c))) ++ ":r=" ++
    kc(String, p88_string_eq(work, ""), u => "v;", u => "{...v};") ++ work ++ "break;"

# Module: src/back/js/direct/host.bend:144
@unsafe
def jd_host_marshal_field_rows(+book: List<&2,KDef>, +tel: KTerm, +out: Bool,
  +seen: List<&2,KTerm>, +depth: U32, +fuel: U32) -> JDHostFields:
  kc(JDHostFields, U32.is_gt(fuel, 0), u =>
    jd_host_marshal_field_rows_on(book, wnf(book, tel), out, seen, depth, U32.sub(fuel, 1)),
    u => JDHostFieldsEnd{jd_host_error("host field telescope depth") ++ "();"})

# Module: src/back/js/direct/host.bend:151
@unsafe
def jd_host_marshal_field_rows_on(+book: List<&2,KDef>, +t: KTerm, +out: Bool,
  +seen: List<&2,KTerm>, +depth: U32, +fuel: U32) -> JDHostFields:
  kc(JDHostFields, p98_tag_eq(t, "All"), u =>
    kc(JDHostFields, U32.is_eq(qt(t), 0), v =>
      jd_host_marshal_field_rows(book, j_app_type(t, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), out, seen, depth, fuel), v =>
      JDHostFieldsCon{nm(t), jd_host_marshal(book, kid(t, 0), out, seen, depth, fuel),
        jd_host_marshal_field_rows(book, j_app_type(t, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), out, seen, depth, fuel)}),
    u => JDHostFieldsEnd{""})

# Module: src/back/js/direct/host.bend:161
@unsafe
def jd_host_marshal_rows_text(+fields: JDHostFields) -> String:
  match fields:
    case JDHostFieldsEnd{error}: error
    case JDHostFieldsCon{name, marshal, rest}:
      jd_host_marshal_put(marshal, "r", j_quote(name)) ++ jd_host_marshal_rows_text(rest)

# The host telescope substitutes Absent at each formal. Keep it separate from
# the raw formal telescope used by live arity and internal parameter names.

# Module: src/back/js/direct/host.bend:173
@unsafe
def jd_host_signature(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> JDHostSignature:
  kc(JDHostSignature, U32.is_gt(left, 0), u =>
    jd_host_signature_head(book, wnf(book, ty), left),
    u => JDHostSignature{wnf(book, ty), Nil{}})

# Module: src/back/js/direct/host.bend:179
@unsafe
def jd_host_signature_head(+book: List<&2,KDef>, +head: KTerm, +left: U32) -> JDHostSignature:
  jd_host_signature_prepend(head,
    jd_host_signature(book, j_app_type(head, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), U32.sub(left, 1)))

# Module: src/back/js/direct/host.bend:184
@unsafe
def jd_host_signature_prepend(+head: KTerm, +signature: JDHostSignature) -> JDHostSignature:
  match signature:
    case JDHostSignature{result, heads}: JDHostSignature{result, Con{head, heads}}

# Build at the original result-telescope demand; conversion remains result,
# all inputs, then all copybacks. Invalid heads retain each consumer's refusal.

# Module: src/back/js/direct/host.bend:191
@unsafe
def jd_host(+book: List<&2,KDef>, +d: KDef) -> String:
  +arity = jd_emitted_arity(book, d)
  +live = jd_live_arity(book, dt(d), arity)
  +names = jd_host_names(live, 0)
  jd_host_signature_text(book, d, names, True{}, jd_host_signature(book, dt(d), arity))

# Module: src/back/js/direct/host.bend:199
@unsafe
def jd_host_signature_text(+book: List<&2,KDef>, +d: KDef, +names: String,
  +marshal: Bool, +signature: JDHostSignature) -> String:
  match signature:
    case JDHostSignature{result, heads}:
      "(" ++ names ++ ")=>{const r=" ++
        jd_host_convert(book, result, True{}, marshal) ++ "(run_loop(" ++ jd_name(dn(d)) ++
        "(" ++ jd_host_signature_args(book, heads, 0, marshal) ++ ")));return r;}"

# Module: src/back/js/direct/host.bend:209
@unsafe
def jd_host_signature_args(+book: List<&2,KDef>, +heads: List<&2,KTerm>, +at: U32, +marshal: Bool) -> String:
  match heads:
    case Nil{}: ""
    case Con{t, rest}: kc(String, p98_tag_eq(t, "All"), u =>
      kc(String, U32.is_eq(qt(t), 0), v => jd_host_signature_args(book, rest, at, marshal), v =>
        jd_host_convert(book, kid(t, 0), False{}, marshal) ++ "(a" ++ U32.show(at) ++ ")," ++
          jd_host_signature_args(book, rest, U32.inc(at), marshal)),
      u => jd_host_error("host formal telescope") ++ "(),")

# Module: src/back/js/direct/host.bend:219
@unsafe
def jd_host_signature_back(+book: List<&2,KDef>, +heads: List<&2,KTerm>, +at: U32, +marshal: Bool) -> String:
  match heads:
    case Nil{}: ""
    case Con{t, rest}: kc(String, p98_tag_eq(t, "All"), u =>
      kc(String, U32.is_eq(qt(t), 0), v => jd_host_signature_back(book, rest, at, marshal), v =>
        jd_host_convert(book, kid(t, 0), True{}, marshal) ++ "(a" ++ U32.show(at) ++ ");" ++
          jd_host_signature_back(book, rest, U32.inc(at), marshal)), u => "")

# Only a completed no-Nat signature scan can bypass the component scans.
# Nat found or budget exhausted retains the original per-component marshalling.

# Module: src/back/js/direct/host.bend:230
@unsafe
def jd_host_convert(+book: List<&2,KDef>, +ty: KTerm, +out: Bool, +marshal: Bool) -> String:
  kc(String, marshal, u => jd_marshal(book, ty, out), u => "")

# Module: src/back/js/direct/host.bend:234
@unsafe
def jd_host_names(+left: U32, +at: U32) -> String:
  kc(String, U32.is_gt(left, 0), u => "a" ++ U32.show(at) ++ "," ++
    jd_host_names(U32.sub(left, 1), U32.inc(at)), u => "")

# Module: src/back/js/direct/host.bend:239
@unsafe
def jd_host_result(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> KTerm:
  kc(KTerm, U32.is_gt(left, 0), u =>
    jd_host_result(book, j_app_type(wnf(book, ty), {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), U32.sub(left, 1)), u => wnf(book, ty))

# Module: src/back/js/direct/host.bend:244
@unsafe
def jd_host_args(+book: List<&2,KDef>, +ty: KTerm, +left: U32, +at: U32, +out: Bool, +marshal: Bool) -> String:
  kc(String, U32.is_gt(left, 0),
    u => jd_host_args_on(book, wnf(book, ty), left, at, out, marshal), u => "")

# Module: src/back/js/direct/host.bend:249
@unsafe
def jd_host_args_on(+book: List<&2,KDef>, +t: KTerm, +left: U32, +at: U32, +out: Bool, +marshal: Bool) -> String:
  kc(String, p98_tag_eq(t, "All"), u =>
    kc(String, U32.is_eq(qt(t), 0), u =>
      jd_host_args(book, j_app_type(t, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), U32.sub(left, 1), at, out, marshal), u =>
      jd_host_convert(book, kid(t, 0), out, marshal) ++ "(a" ++ U32.show(at) ++ ")," ++
        jd_host_args(book, j_app_type(t, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), U32.sub(left, 1), U32.inc(at), out, marshal)),
    u => jd_host_error("host formal telescope") ++ "(),")

# Module: src/back/js/direct/host.bend:258
@unsafe
def jd_host_back(+book: List<&2,KDef>, +ty: KTerm, +left: U32, +at: U32, +marshal: Bool) -> String:
  kc(String, U32.is_gt(left, 0), u => jd_host_back_on(book, wnf(book, ty), left, at, marshal), u => "")

# Module: src/back/js/direct/host.bend:262
@unsafe
def jd_host_back_on(+book: List<&2,KDef>, +t: KTerm, +left: U32, +at: U32, +marshal: Bool) -> String:
  kc(String, p98_tag_eq(t, "All"), u =>
    kc(String, U32.is_eq(qt(t), 0), u => jd_host_back(book, j_app_type(t, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), U32.sub(left, 1), at, marshal), u =>
      jd_host_convert(book, kid(t, 0), True{}, marshal) ++ "(a" ++ U32.show(at) ++ ");" ++
        jd_host_back(book, j_app_type(t, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), U32.sub(left, 1), U32.inc(at), marshal)), u => "")

# Module: src/back/js/direct/host.bend:269
@unsafe
def jd_host_io(+book: List<&2,KDef>, +ty: KTerm, +fuel: U32) -> U32:
  kc(U32, U32.is_gt(fuel, 0), u => jd_host_io_on(book, wnf(book, ty), U32.sub(fuel, 1)), u => 2)

# Module: src/back/js/direct/host.bend:273
@unsafe
def jd_host_io_on(+book: List<&2,KDef>, +t: KTerm, +fuel: U32) -> U32:
  kc(U32, p98_tag_eq(t, "All"), u => jd_host_io(book, j_app_type(t, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), fuel),
    u => kc(U32, p98_tag_eq(t, "ADT") && p88_string_eq(nm(t), "IO.OP"), u => 1, u => 0))

# Module: src/back/js/direct/host.bend:278
@unsafe
def jd_exports(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> String:
  "\nexport const backend={kind:\"direct-js\",representation:\"upstream-native\",prototype:true,foreign:\"upstream-cps\",hostABI:\"number-nat-scalar-text-v2\"};\nexport default {\n" ++
    jd_host_exports(book, defs) ++ "};\n"

# Module: src/back/js/direct/host.bend:283
@unsafe
def jd_host_exports(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> String:
  match defs:
    case Nil{}: ""
    case Con{d, rest}:
      kc(String, p88_string_eq(dk(d), "Def") && U32.is_eq(dx(d), 0) && Bool.not(db(d)) &&
        Bool.not(p98_tag_eq(j_strip(dv(d)), "Absent")) && Bool.not(p98_tag_eq(j_strip(dv(d)), "Foreign")), u =>
        jd_host_export(book, d, kc(U32, j_io_type(book, dt(d)), u => 1, u => 0)), u => "") ++
        jd_host_exports(book, rest)

# The full IO telescope includes its erased result type and final live kont.
# The runtime resolves the displayed effect tag when the request is executed.

# Module: src/back/js/direct/host.bend:295
@unsafe
def jd_foreign_def(+book: List<&2,KDef>, +d: KDef) -> String:
  kc(String, j_io_type(book, jd_host_result(j_io_shadow(book), dt(d), da(d))), u =>
    jd_foreign_ready(book, d, jd_emitted_arity(book, d), jd_live_arity(book, dt(d), jd_emitted_arity(book, d))),
    u => jd_fail("foreign result is not IO"))

# Module: src/back/js/direct/host.bend:301
@unsafe
def jd_foreign_ready(+book: List<&2,KDef>, +d: KDef, +arity: U32, +live: U32) -> String:
  kc(String, U32.is_gt(live, 0), u =>
    "function " ++ jd_name(dn(d)) ++ "(" ++ jd_host_names(live, 0) ++ "){return {$:" ++
      j_quote(dn(d)) ++ ",args:[" ++
      jd_foreign_values(book, dt(d), arity, 0, live, False{}) ++ "],kont:" ++
      jd_foreign_values(book, dt(d), arity, 0, live, True{}) ++ "};}\n",
    u => jd_fail("foreign continuation missing"))

# Module: src/back/js/direct/host.bend:310
@unsafe
def jd_foreign_values(+book: List<&2,KDef>, +ty: KTerm, +left: U32, +at: U32, +live: U32, +kont: Bool) -> String:
  kc(String, U32.is_gt(left, 0), u =>
    jd_foreign_values_on(book, wnf(book, ty), left, at, live, kont),
    u => kc(String, kont, u => jd_fail("foreign continuation telescope"), u => ""))

# Module: src/back/js/direct/host.bend:316
@unsafe
def jd_foreign_values_on(+book: List<&2,KDef>, +t: KTerm, +left: U32, +at: U32, +live: U32, +kont: Bool) -> String:
  kc(String, p98_tag_eq(t, "All"), u =>
    kc(String, U32.is_eq(qt(t), 0), u =>
      jd_foreign_values(book, j_app_type(t, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), U32.sub(left, 1), at, live, kont), u =>
      kc(String, U32.is_eq(U32.inc(at), live), u =>
        kc(String, kont, u => "(x)=>a" ++ U32.show(at) ++ "(" ++ jd_marshal(book, kid(wnf(book, kid(t, 0)), 0), False{}) ++ "(x))", u => ""), u =>
        kc(String, kont, u => "", u => jd_marshal(book, kid(t, 0), True{}) ++ "(a" ++ U32.show(at) ++ "),") ++
          jd_foreign_values(book, j_app_type(t, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), U32.sub(left, 1), U32.inc(at), live, kont))),
    u => jd_fail("foreign formal telescope"))

# Foreign paths include Base effects: this runtime has no legacy built-in G ABI.

# Module: src/back/js/direct/host.bend:328
@unsafe
def jd_foreign_paths(+defs: List<&2,KDef>) -> List<&2,String>:
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}: kc(List<&2,String>, p98_tag_eq(j_strip(dv(d)), "Foreign"),
      u => Con{j_foreign_path(ks(j_strip(dv(d)))), jd_foreign_paths(rest)}, u => jd_foreign_paths(rest))

# Module: src/back/js/direct/host.bend:335
@unsafe
def jd_foreign_error(+defs: List<&2,KDef>) -> String:
  match defs:
    case Nil{}: ""
    case Con{d, rest}: kc(String, p98_tag_eq(j_strip(dv(d)), "Foreign"), u =>
      kc(String, p88_string_eq(j_foreign_path(ks(j_strip(dv(d)))), ""),
        u => "no JavaScript effect source for " ++ name_key(dn(d)), u => jd_foreign_error(rest)), u => jd_foreign_error(rest))

# Sources are the shared scanner's namespace-resolved Source/Text/CID/FID rows.
# Only a CID that resolves to a constructor loses its namespace.

# Module: src/back/js/direct/host.bend:345
@unsafe
def jd_modules(+defs: List<&2,KDef>, +sources: List<&2,KTerm>) -> String:
  jd_module_sources(defs, sources)

# Module: src/back/js/direct/host.bend:349
@unsafe
def jd_module_sources(+defs: List<&2,KDef>, +sources: List<&2,KTerm>) -> String:
  match sources:
    case Nil{}: ""
    case Con{source, rest}: "(()=>{\n" ++ jd_source_parts(defs, ks(source)) ++ "\n})();\n" ++ jd_module_sources(defs, rest)

# Module: src/back/js/direct/host.bend:355
@unsafe
def jd_source_parts(+defs: List<&2,KDef>, +parts: List<&2,KTerm>) -> String:
  match parts:
    case Nil{}: ""
    case Con{part, rest}: jd_source_part(defs, part) ++ jd_source_parts(defs, rest)

@unsafe
def jd_source_part(+defs: List<&2,KDef>, +part: KTerm) -> String:
  kc(String, p98_tag_eq(part, "Text"), u => nm(part), u =>
    j_quote(kc(String, p98_tag_eq(part, "CID") &&
      (p88_string_eq(dk(lookup(defs, nm(part))), "Ctr") ||
       p88_string_eq(dk(lookup(dc(kr_resolve(defs, nm(part))), nm(part))), "Ctr")),
      v => jd_tag(nm(part)), v => nm(part))))

# Module: src/back/js/direct/host.bend:361
@unsafe
def jd_host_ctor_tags(+ctors: List<&2,KDef>) -> String:
  match ctors:
    case Nil{}: ""
    case Con{c, rest}:
      jd_tag(dn(c)) ++
        kc(String, List.is_empty(&2,KDef, rest), u => "", u => ", ") ++ jd_host_ctor_tags(rest)

# Module: src/back/js/direct/host.bend:369
@unsafe
def jd_host_marshal_status(+book: List<&2,KDef>, +t: KTerm, +out: Bool,
  +seen: List<&2,KTerm>, +depth: U32, +fuel: U32, +status: U32) -> String:
  kc(String, U32.is_eq(status, 2), u => jd_host_error("host type graph budget"), u =>
    kc(String, U32.is_eq(status, 1),
      u => jd_host_marshal_named(book, t, out, seen, depth, fuel), u => ""))

# Module: src/back/js/direct/host.bend:376
@unsafe
def jd_host_export(+book: List<&2,KDef>, +d: KDef, +status: U32) -> String:
  kc(String, U32.is_eq(status, 1), u => "", u =>
    kc(String, U32.is_eq(status, 2),
      u => "[" ++ j_quote(dn(d)) ++ "]:" ++ jd_host_error("host result telescope budget") ++ ",\n", u =>
      "[" ++ j_quote(dn(d)) ++ "]:run_lib(" ++ jd_host(book, d) ++ "," ++
        U32.show(jd_live_arity(book, dt(d), jd_emitted_arity(book, d))) ++ "),\n"))
