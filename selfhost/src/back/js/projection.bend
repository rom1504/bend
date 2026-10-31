
# Module: src/back/js/projection.bend:4
law j_projection_match:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +ty: KTerm
  String

# Module: src/back/js/projection.bend:10
law j_projection_arm:
  for +t: KTerm
  for +tel: KTerm
  for +slots: List<&2, KTerm>
  for +at: U32
  String

# Module: src/back/js/projection.bend:17
law j_projection_slot:
  for +id: U32
  for +slots: List<&2, KTerm>
  String

# Module: src/back/js/projection.bend:22
law j_projection_code:
  for +name: String
  for +slot: String
  String

# Module: src/back/js/projection.bend:28
@unsafe
def j_projection_worker(
  +book: List<&2, KDef>,
  +t: KTerm,
  +ty: KTerm,
) -> String:
  kc(String, p98_tag_eq(j_strip(t), "Mat"), u => j_projection_match(book, j_strip(t), wnf(book, ty)), u => "")

# Module: src/back/js/projection.bend:36
@unsafe
def j_projection_match(book, t, ty):
  kc(String, p98_tag_eq(ty, "All") && Bool.not(U32.is_eq(qt(ty), 0)) && U32.is_eq(j_constructor_count(book, wnf(book, kid(ty, 0))), 1),
    u => j_projection_code(nm(t), j_projection_arm(j_strip(kid(t, 0)), j_specialize(book, dt(j_find_ctor(book, nm(t))), ks(wnf(book, kid(ty, 0)))), Nil{}, 0)), u => "")

# Module: src/back/js/projection.bend:41
@unsafe
def j_projection_arm(t, tel, slots, at):
  kc(String, p98_tag_eq(tel, "All"),
    u => kc(String, p98_tag_eq(t, "Lam") && Bool.not(U32.is_eq(qt(tel), 0)),
      u => j_projection_arm(j_strip(kid(t, 0)), kid(tel, 1), Con{kt("Slot", "", ix(t), at, Nil{}), slots}, U32.inc(at)), u => ""),
    u => kc(String, p98_tag_eq(t, "Var"), u => j_projection_slot(ix(t), slots), u => ""))

# Module: src/back/js/projection.bend:48
@unsafe
def j_projection_slot(id, slots):
  match slots:
    case Nil{}: ""
    case Con{s, rest}: kc(String, U32.is_eq(id, ix(s)), u => U32.show(qt(s)), u => j_projection_slot(id, rest))

# Module: src/back/js/projection.bend:54
@unsafe
def j_projection_code(name, slot):
  kc(String, p88_string_eq(slot, ""), u => "", u => "fn(1,function(a){return project(" ++ j_quote(name) ++ ",a[0]).slice()[" ++ slot ++ "];})")

# Module: src/back/js/projection.bend:58
@unsafe
def j_l_global_worker(
  +book: List<&2, KDef>,
  +d: KDef,
  +t: KTerm,
  +worker: String,
) -> String:
  "G[" ++ j_quote(dn(d)) ++ "]=" ++ j_l_capture_scalar(book, d, kc(String, p88_string_eq(worker, ""), u => kc(String, (p98_tag_eq(j_strip(t), "Lam") || p98_tag_eq(j_strip(t), "Mat")), u => j_expr(book, Nil{}, t, dt(d), False{}), u => "fn(0,function(){return " ++ j_expr(book, Nil{}, t, dt(d), True{}) ++ ";})"),
    u => worker)) ++ ";\n"

# Module: src/back/js/projection.bend:68
@unsafe
def j_l_capture_scalar(+book: List<&2,KDef>, +d: KDef, +code: String) -> String:
  kc(String, j_region_capture_eligible(book, d) || j_callback_capture_eligible(book, d) || j_instance_public_capture(d) || j_pure_bool_native(book, d), u => "scalarCapture(" ++ j_quote(dn(d)) ++ "," ++ code ++ "," ++ kc(String, j_string_uses([dt(d), dv(d)], 8192) || j_string_family(book, [dt(d)], Nil{}, 512), u => "true", u => "false") ++ ")", u => code)
