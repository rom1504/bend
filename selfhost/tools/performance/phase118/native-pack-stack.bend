# Exact nc_pack_foreign predicate with a direct-tail explicit DFS worklist.
# Visit a definition, its dc children, then its following siblings as before.
# Cached-book/index children must remain included. No permission is broadened.
@unsafe
def p118np_foreign(+d: KDef) -> Bool:
  Bool.not(db(d)) && (p98_tag_eq(nc_unann(dv(d)),"Foreign") ||
    (p88_string_eq(dk(d),"Def") && nc_foreign(d)))

@unsafe
def p118np_walk(todo: List<&2,List<&2,KDef>>, +found: Bool) -> Bool:
  match todo:
    case Nil{}: found
    case Con{Nil{},rest}: p118np_walk(rest,found)
    case Con{Con{+d,following},rest}:
      p118np_walk(Con{dc(d),Con{following,rest}},found || p118np_foreign(d))

@unsafe
def nc_pack_foreign(ds: List<&2,KDef>) -> Bool:
  p118np_walk([ds],False{})

# Small frozen-reference semantics for finite analysis controls only.
@unsafe
def p118np_reference(ds: List<&2,KDef>) -> Bool:
  match ds:
    case Nil{}: False{}
    case Con{+d,rest}:
      (Bool.not(db(d)) && (p98_tag_eq(nc_unann(dv(d)),"Foreign") ||
        (p88_string_eq(dk(d),"Def") && nc_foreign(d)))) ||
        p118np_reference(dc(d)) || p118np_reference(rest)

def p118np_definition(name: String, kind: String, value: KTerm, children: List<&2,KDef>, trusted: Bool) -> KDef:
  KDef{name,kind,0,0,atom("Typ"),value,children,trusted,False{}}

@unsafe
def p118np_case(+name: String, +defs: List<&2,KDef>, +expected: Bool) -> String:
  p113ft_row(name,U32.is_eq(Bool.to_u32(nc_pack_foreign(defs)),Bool.to_u32(expected)) &&
    U32.is_eq(Bool.to_u32(p118np_reference(defs)),Bool.to_u32(expected)))

@unsafe
def p118np_controls() -> List<&2,String>:
  +plain = p118np_definition("plain","Def",kt("NWord","7",0,0,[]),[],False{})
  +foreign = p118np_definition("foreign","Def",atom("Foreign"),[],False{})
  +trusted = p118np_definition("trusted","Def",atom("Foreign"),[],True{})
  +absent = p118np_definition("absent","Def",atom("Absent"),[],False{})
  +nondef = p118np_definition("nondef","ADT",atom("Absent"),[],False{})
  +nested = p118np_definition("cache","BookCache",atom("Absent"),[plain,foreign],True{})
  +annotated = p118np_definition("annotation","Def",kt("Ann","",0,0,[atom("Foreign"),atom("Typ")]),[],False{})
  [p118np_case("pack-stack-empty",[],False{}),
   p118np_case("pack-stack-ordinary",[plain,nondef],False{}),
   p118np_case("pack-stack-untrusted-foreign",[foreign],True{}),
   p118np_case("pack-stack-trusted-foreign",[trusted],False{}),
   p118np_case("pack-stack-unfilled-definition",[absent],True{}),
   p118np_case("pack-stack-annotated-foreign",[annotated],True{}),
   p118np_case("pack-stack-cache-children",[nested],True{}),
   p118np_case("pack-stack-following-sibling",[plain,trusted,foreign],True{})]

@unsafe
def p118np_flat(+n: U32, +plain: KDef, tail: List<&2,KDef>) -> List<&2,KDef>:
  match n:
    case 0: tail
    case _: p118np_flat(U32.sub(n,1),plain,Con{plain,tail})

@unsafe
def p118np_nested(+n: U32, children: List<&2,KDef>) -> List<&2,KDef>:
  match n:
    case 0: children
    case _: p118np_nested(U32.sub(n,1),[p118np_definition("nested","BookCache",atom("Absent"),children,True{})])

@unsafe
def p118np_scale(requested: U32) -> List<&2,String>:
  +n = U32.min(requested,65536)
  +plain = p118np_definition("plain","Def",kt("NWord","7",0,0,[]),[],False{})
  +foreign = p118np_definition("foreign","Def",atom("Foreign"),[],False{})
  [p113ft_row("pack-stack-large-flat-clear",Bool.not(nc_pack_foreign(p118np_flat(n,plain,[])))),
   p113ft_row("pack-stack-large-last-foreign",nc_pack_foreign(p118np_flat(n,plain,[foreign]))),
   p113ft_row("pack-stack-large-nested-clear",Bool.not(nc_pack_foreign(p118np_nested(n,[])))),
   p113ft_row("pack-stack-large-nested-foreign",nc_pack_foreign(p118np_nested(n,[foreign])))]
