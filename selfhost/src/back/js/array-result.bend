# Public flat composite adapter. Keep original Array handles throughout the
# private region; only its final local record vector receives a public shell.
@unsafe
def j_array_result_shape(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +head = wnf(book, ty)
  +c = j_region_local_ctor_head(book, head)
  j_region_local_type(book, head) && j_region_local_vector(book, head) &&
    String.eq(dk(c), "Ctr") && Bool.not(db(c)) && U32.is_gt(da(c), 0) &&
    j_array_result_fields(book, dt(c), nm(head), da(c), False{})

@unsafe
def j_array_result_fields(+book: List<&2,KDef>, +ty: KTerm, +owner: String, +left: U32, +array: Bool) -> Bool:
  +head = wnf(book, ty)
  kc(Bool, U32.is_eq(left, 0), u => array && String.eq(tg(head), "ADT") &&
    String.eq(nm(head), owner) && U32.is_eq(terms_len(ks(head)), 0) && List.is_empty(&2, String, rm(head)), u =>
    String.eq(tg(head), "All") && Bool.not(U32.is_eq(qt(head), 0)) &&
    (j_region_scalar(book, kid(head, 0)) || j_region_local_array(book, wnf(book, kid(head, 0)))) &&
    j_array_result_fields(book, kid(head, 1), owner, U32.sub(left, 1),
      array || j_region_local_array(book, wnf(book, kid(head, 0)))))

@unsafe
def j_array_result_signature(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> Bool:
  +head = wnf(book, ty)
  kc(Bool, U32.is_eq(left, 0), u => j_array_result_shape(book, head), u =>
    String.eq(tg(head), "All") && Bool.not(U32.is_eq(qt(head), 0)) && j_region_scalar(book, kid(head, 0)) &&
    j_array_result_signature(book, kid(head, 1), U32.sub(left, 1)))

# Mirror existing region root bounds, without admitting public container inputs.
@unsafe
def j_array_result_root_plan(+book: List<&2,KDef>, +d: KDef) -> JRootPlan:
  kc(JRootPlan, Bool.not(j_array_view_active(book)) && j_region_capture_eligible(book, d) && j_array_result_signature(book, dt(d), da(d)) &&
    String.eq(tg(j_strip(dv(d))), "Lam"), u =>
    kc(JRootPlan, j_u32_bounded([dv(d)], 8192) && U32.is_eq(j_nat_loop_count(dv(d), 0), da(d)), u =>
      kc(JRootPlan, j_nat_loop_distinct(dv(d), Nil{}) && Bool.not(j_l_deep(dv(d), 0)), u =>
        j_array_result_done(book, d, j_region_prefix(book, Nil{}, dv(d), dt(d), 0, da(d), True{}, "@root-return", [dn(d)], 0,
          JRegionBuild{atom("Absent"), Nil{}, 32768, True{}})), u => JRootPlan{"", False{}}),
      u => JRootPlan{"", False{}}), u => JRootPlan{"", False{}})

# This graph audit supplies closed ownership, not a raw representation marker.
@unsafe
def j_array_result_done(+book: List<&2,KDef>, +d: KDef, +s: JRegionBuild) -> JRootPlan:
  kc(JRootPlan, j_region_valid(s) && j_region_has_loop(book, j_region_helpers(s)) &&
    String.eq(dk(lookup(j_region_helpers(s), "Array.new")), "Def") &&
    j_array_view_terms(book, j_region_helpers(s), [j_region_term(s)], 8192) &&
    j_array_view_helpers(book, j_region_helpers(s), j_region_helpers(s)), u =>
    JRootPlan{j_array_result_emit(book, d, s), True{}}, u => JRootPlan{"", False{}})

# Use the ordinary book: all native helpers retain public handle identity.
# Private vector construction keeps field order; final ctor restores public ABI.
@unsafe
def j_array_result_emit(+book: List<&2,KDef>, +d: KDef, +s: JRegionBuild) -> String:
  +result = j_fold_root_result(book, dt(d), da(d))
  +c = j_region_local_ctor_head(book, result)
  "(()=>{" ++ j_region_declarations(book, j_region_helpers(s)) ++
    "const $arrayResultBody=function(" ++ j_region_vector_names("$s", 0, da(d)) ++ "){" ++
    j_nat_loop_generic(book, Nil{}, j_region_term(s), dt(d), 0) ++ "};" ++
    "const $guards=[" ++ j_quote(dn(d)) ++ "," ++ j_region_names(j_region_helpers(s)) ++ "];return " ++
    "fn(" ++ U32.show(da(d)) ++ ",exactCode(function(a,$entered){" ++ j_nat_loop_slots(da(d), 0) ++
    "if($entered&&arrayViewHostGuard()&&" ++ j_region_inputs(book, dt(d), 0, da(d), False{}) ++
    "&&localGuard($guards)){/* private composite array result */const $arrayResult=" ++
    "$arrayResultBody(" ++ j_region_vector_names("$s", 0, da(d)) ++ ");return ctor(" ++ j_quote(dn(c)) ++ ",$arrayResult);}" ++
    j_nat_loop_generic(book, Nil{}, dv(d), dt(d), 0) ++ "}));})()"
