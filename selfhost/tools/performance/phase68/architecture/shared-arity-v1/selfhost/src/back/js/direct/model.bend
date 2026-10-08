# Direct JavaScript's runtime arguments omit erased source telescope slots.
# No descriptor, mutable global table or legacy runtime operation is represented.
type JDArgs is Data:
  JDArgs{+values: List<&2,String>, +rest: List<&2,KTerm>, +typ: KTerm, +missing: U32}

@unsafe
def jd_name(+name: String) -> String:
  "$jd$" ++ jd_name_chars(name)

@unsafe
def jd_name_chars(name: String) -> String:
  match name:
    case SNil{}: ""
    case SCon{+h, rest}:
      +n = Char.to_u32(h)
      kc(String, (U32.is_ge(n, 48) && U32.is_le(n, 57)) ||
        (U32.is_ge(n, 65) && U32.is_le(n, 90)) || (U32.is_ge(n, 97) && U32.is_le(n, 122)),
        u => SCon{h, SNil{}}, u => "_" ++ U32.show(n) ++ "_") ++ jd_name_chars(rest)

@unsafe
def jd_local(+id: U32) -> String:
  "$x" ++ U32.show(id)

# Physical newlines cannot be forged by quoted source strings. These comments
# record emitted uses, including uses in closures, for lazy match/let demand.
@unsafe
def jd_use(+id: U32) -> String:
  "\n/*JD_USE:" ++ U32.show(id) ++ "*/"

@unsafe
def jd_ref(+name: String) -> String:
  "\n/*JD_REF:" ++ jd_name(name) ++ "*/"

@unsafe
def jd_var(+env: List<&2,KTerm>, +id: U32) -> String:
  "(" ++ jd_use(id) ++ jd_var_value(env, id) ++ ")"

@unsafe
def jd_var_value(+env: List<&2,KTerm>, +id: U32) -> String:
  match env:
    case Nil{}: jd_local(id)
    case Con{h, rest}: kc(String, U32.is_eq(ix(h), id), u =>
      kc(String, String.eq(tg(h), "$JD.View"), v => nm(h), v => jd_local(id)),
      u => jd_var_value(rest, id))

@unsafe
def jd_is_view(+value: String) -> Bool:
  (String.starts_with(value, "u32_to_word(") && Bool.not(String.contains(value, "["))) ||
    (String.starts_with(value, "$match") && String.contains(value, ".codePointAt(0)"))

@unsafe
def jd_fail(+message: String) -> String:
  "(\n/*JD_UNSUPPORTED: direct lowering */(()=>{throw new Error(" ++ j_quote(message) ++ ");})())"

@unsafe
def jd_bind_env(+env: List<&2,KTerm>, +id: U32, +ty: KTerm) -> List<&2,KTerm>:
  Con{kt("Env", "", id, 0, [ty]), env}

@unsafe
def jd_owner(+env: List<&2,KTerm>) -> String:
  match env:
    case Nil{}: ""
    case Con{h, rest}: kc(String, String.eq(tg(h), "$JD.Owner"), u => nm(h), u => jd_owner(rest))

@unsafe
def jd_without_owner(+env: List<&2,KTerm>) -> List<&2,KTerm>:
  match env:
    case Nil{}: Nil{}
    case Con{h, rest}: kc(List<&2,KTerm>, String.eq(tg(h), "$JD.Owner") || String.eq(tg(h), "$JD.Expression"),
      u => jd_without_owner(rest), u => Con{h, jd_without_owner(rest)})

@unsafe
def jd_expression_env(+env: List<&2,KTerm>) -> List<&2,KTerm>:
  Con{kt("$JD.Expression", "", 4294967293, 0, Nil{}), jd_without_owner(env)}

@unsafe
def jd_tail_position(+env: List<&2,KTerm>) -> Bool:
  match env:
    case Nil{}: True{}
    case Con{h, rest}: kc(Bool, String.eq(tg(h), "$JD.Expression"), u => False{}, u => jd_tail_position(rest))

# Private emitter query: d is a definition of the completed call context.
# Call analysis retains the arity it already needed; other inputs stay raw.
@unsafe
def jd_emitted_arity(+book: List<&2,KDef>, +d: KDef) -> U32:
  jd_emitted_arity_on(book, d, kid(dv(jd_calls_fact(book, dn(d))), 0))

@unsafe
def jd_emitted_arity_on(+book: List<&2,KDef>, +d: KDef, +fact: KTerm) -> U32:
  kc(U32, String.eq(tg(fact), "JDArity"), u => ix(fact), u => jd_arity(book, d))

@unsafe
def jd_params(+book: List<&2,KDef>, +ty: KTerm, +left: U32, +at: U32) -> List<&2,String>:
  kc(List<&2,String>, U32.is_eq(left, 0), u => Nil{}, u => jd_params_head(book, wnf(book, ty), left, at))

@unsafe
def jd_params_head(+book: List<&2,KDef>, +ty: KTerm, +left: U32, +at: U32) -> List<&2,String>:
  kc(List<&2,String>, String.eq(tg(ty), "All"), u =>
    kc(List<&2,String>, U32.is_eq(qt(ty), 0), u => jd_params(book, kid(ty, 1), U32.sub(left, 1), at),
      u => Con{"$a" ++ U32.show(at), jd_params(book, kid(ty, 1), U32.sub(left, 1), U32.inc(at))}), u => Nil{})

@unsafe
def jd_join(+xs: List<&2,String>) -> String:
  match xs:
    case Nil{}: ""
    case Con{x, Nil{}}: x
    case Con{x, rest}: x ++ "," ++ jd_join(rest)

@unsafe
def jd_string_at(+xs: List<&2,String>, +at: U32) -> String:
  match xs:
    case Nil{}: ""
    case Con{x, rest}: kc(String, U32.is_eq(at, 0), u => x, u => jd_string_at(rest, U32.sub(at, 1)))

@unsafe
def jd_string_len(+xs: List<&2,String>) -> U32:
  match xs:
    case Nil{}: 0
    case Con{x, rest}: U32.inc(jd_string_len(rest))

@unsafe
def jd_width_params(+left: U32, +at: U32) -> List<&2,String>:
  kc(List<&2,String>, U32.is_eq(left, 0), u => Nil{},
    u => Con{"$a" ++ U32.show(at), jd_width_params(U32.sub(left, 1), U32.inc(at))})
