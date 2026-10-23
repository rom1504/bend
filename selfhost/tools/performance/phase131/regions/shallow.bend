# Experimental shallow borrowed views. Existing complete spine layouts win.
# Only this layout discovery hook changes; NO analysis, its origin/scalar gates,
# owning adapters, recursion rules, runtime and final verifier are unchanged.

@unsafe
def p131rg_opaque() -> String:
  "$p131.borrowed.opaque"

@unsafe
def p131rg_symbol_available(book: List<&2,KDef>) -> Bool:
  String.eq(dk(lookup(book,p131rg_opaque())),"Absent")

@unsafe
def p131rg_width(+width: U32) -> Bool:
  U32.is_eq(width,0) || (U32.is_ge(width,2) && U32.is_le(width,8))

@unsafe
def p131rg_visible(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  nol_scalar(book,ty) || Bool.not(List.is_empty(&2,NO_Spec,nol_root_specs(book,ty)))

@unsafe
def p131rg_names(+book: List<&2,KDef>, fields: List<&2,KTerm>) -> List<&2,String>:
  match fields:
    case Nil{}: []
    case Con{+field,rest}:
      Con{nt_choose(String,p131rg_visible(book,field),u => nm(field),u => p131rg_opaque()),
        p131rg_names(book,rest)}

@unsafe
def p131rg_children(+book: List<&2,KDef>, fields: List<&2,KTerm>) -> List<&2,KTerm>:
  match fields:
    case Nil{}: []
    case Con{+field,+rest}:
      nt_choose(List<&2,KTerm>,p131rg_visible(book,field) && Bool.not(nol_scalar(book,field)),
        u => Con{field,p131rg_children(book,rest)},u => p131rg_children(book,rest))

@unsafe
def p131rg_join(first: P128BLNode, tail: P128BLNode) -> P128BLNode:
  match first tail:
    case P128BLNode{a,ac,+ae} P128BLNode{b,bc,be}:
      P128BLNode{nt_append(NO_Spec,a,b),nt_append(KTerm,ac,bc),p111_first(ae,be)}

@unsafe
def p131rg_case(+book: List<&2,KDef>, +ty: KTerm, +ctor: KDef, +fields: KTerm) -> P128BLNode:
  +width = terms_len(ks(fields))
  +key = nc_ctor_identity(book,dn(ctor))
  nt_choose(P128BLNode,String.eq(tg(fields),"NO_Types") && U32.is_eq(width,da(ctor)) && p131rg_width(width),
    u => P128BLNode{[NO_Spec{NO_Layout{key,key,
      nt_choose(String,U32.is_eq(width,0),v => "Nullary",v => "Boxed"),width},nm(ty),p131rg_names(book,ks(fields))}],
      p131rg_children(book,ks(fields)),""},
    u => P128BLNode{[],[],"shallow observer: unsupported constructor fields/width"})

@unsafe
def p131rg_ctors(+book: List<&2,KDef>, +ty: KTerm, ctors: List<&2,KDef>, +fuel: U32) -> P128BLNode:
  match ctors:
    case Nil{}: P128BLNode{[],[],""}
    case Con{+ctor,+rest}:
      nt_choose(P128BLNode,U32.is_eq(fuel,0),u => P128BLNode{[],[],"shallow observer: constructor budget"},
        u => p131rg_join(p131rg_case(book,ty,ctor,nol_ctor_fields(book,ty,ctor)),
          p131rg_ctors(book,ty,rest,U32.sub(fuel,1))))

@unsafe
def p131rg_node(+book: List<&2,KDef>, +ty: KTerm) -> P128BLNode:
  +owner = lookup(book,nm(ty))
  nt_choose(P128BLNode,p131rg_symbol_available(book) && nol_plain(ty) && nol_owner(book,ty) &&
    Bool.not(db(owner)) && Bool.not(List.is_empty(&2,KDef,dc(owner))),
    u => p131rg_ctors(book,ty,dc(owner),8),
    u => P128BLNode{[],[],"shallow observer: nonplain/native/unknown owner"})

@unsafe
def p131rg_fallback(+book: List<&2,KDef>, +ty: KTerm, +original: P128BLNode) -> P128BLNode:
  match original:
    case P128BLNode{specs,children,+error}:
      nt_choose(P128BLNode,String.is_empty(error),u => original,u => p131rg_node(book,ty))

# Exact previous behavior is tried first. Opaque fields have no layout or
# scalar type; matching, arithmetic, borrowed-helper passing, root escape and
# recursive promotion are refused by the unchanged observer evaluator.
@unsafe
def p128bl_node(+book: List<&2,KDef>, +ty: KTerm) -> P128BLNode:
  +owner = lookup(book,nm(ty))
  p131rg_fallback(book,ty,
    nt_choose(P128BLNode,nol_owner(book,ty) && (Bool.not(db(owner)) ||
      String.eq(nm(ty),"String") || String.eq(nm(ty),"List")),
      u => p128bl_ctors(book,ty,dc(owner)),
      u => P128BLNode{[],[],"nested observer: unknown or native non-boxed owner"}))
