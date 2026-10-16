# Bounded aggregate observations. Applied field types stay opaque; no erased
# nominal name can grant an applied field scalar/match/call authority.
@unsafe
def nog_field_types(types: List<&2, KTerm>) -> List<&2, String>:
  match types:
    case Nil{}: Nil{}
    case Con{+head, rest}: Con{nt_choose(String, nol_plain(head), u => nm(head), u => ""), nog_field_types(rest)}

@unsafe
def nog_boxed(ctors: List<&2, KDef>) -> Bool:
  match ctors:
    case Nil{}: False{}
    case Con{+ctr, rest}: U32.is_ge(da(ctr), 2) || nog_boxed(rest)

@unsafe
def nog_ctors_valid(+book: List<&2, KDef>, +ty: KTerm, ctors: List<&2, KDef>, +left: U32) -> Bool:
  match ctors:
    case Nil{}: True{}
    case Con{+ctr, +rest}:
      nt_choose(Bool, U32.is_gt(left, 0) && (U32.is_eq(da(ctr), 0) || U32.is_ge(da(ctr), 2)),
        u => p98_tag_eq(nol_ctor_fields(book, ty, ctr), "NO_Types") && nog_ctors_valid(book, ty, rest, U32.sub(left, 1)), u => False{})

@unsafe
def nog_specs(+book: List<&2, KDef>, +ty: KTerm, ctors: List<&2, KDef>) -> List<&2, NO_Spec>:
  match ctors:
    case Nil{}: Nil{}
    case Con{+ctr, rest}:
      +key = nc_ctor_identity(book, dn(ctr))
      +fields = ks(nol_ctor_fields(book, ty, ctr))
      Con{NO_Spec{NO_Layout{key, key, nt_choose(String, U32.is_eq(da(ctr), 0), u => "Nullary", u => "Boxed"), da(ctr)}, nm(ty), nog_field_types(fields)}, nog_specs(book, ty, rest)}

@unsafe
def nog_root_choice(+book: List<&2, KDef>, +ty: KTerm, +ctors: List<&2, KDef>, +aggregate: Bool, +known: List<&2, NO_Spec>) -> List<&2, NO_Spec>:
  nt_choose(List<&2, NO_Spec>, List.is_empty(&2, NO_Spec, known),
    u => nt_choose(List<&2, NO_Spec>, aggregate && U32.is_le(nt_count(KDef, ctors), 4) && nog_boxed(ctors) && nog_ctors_valid(book, ty, ctors, 4),
      v => nog_specs(book, ty, ctors), v => Nil{}), u => known)

# A certified call with a virtual root may be specialized again, still within
# the existing depth-eight/global-fuel budgets. No virtual word is residualized.
@unsafe
def nog_virtual_roots(args: List<&2, KTerm>, +roots: List<&2, U32>, +i: U32) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{+arg, rest}: (no_root_index(roots, i) && p98_tag_eq(arg, "OC")) || nog_virtual_roots(rest, roots, U32.inc(i))
