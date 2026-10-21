# Internal immutable alternatives from verified original IR. Policy chooses
# existing legal routes; original ownership/hygiene/renderers remain unchanged.
type P115Menu is Data:
  P115Direct{+name: String, +arity: U32}
  P115Choices{+segment: N111Segment, +r: P114RPlan, +g: P114GPlan,
    +h: P114HPlan, +fusion: P112FusionBody, +allow_r: Bool, +allow_g: Bool}

type P115Context is Data:
  P115Empty{+chunks: List<&2,String>}
  P115Context{+segments: List<&2,N111Segment>, +direct: KDef,
    +index: P112FusionIndex, +ids: N111Ids, +ready: KDef,
    +prefix: List<&2,String>, +private: String, +suffix: List<&2,String>}

type P115Prepared is Data:
  P115Prepared{+context: P115Context, +menus: List<&2,P115Menu>}

@unsafe
def p115_choices(+segment: N111Segment, +index: P112FusionIndex, +ready: KDef,
    +r: P114RPlan, +g: P114GPlan) -> P115Menu:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,+body}:
      P115Choices{segment,r,g,p114h_plan(segment,index,ready),
        p112c_plan_index(segment,index,ready),p114r_hygiene(body,index,r),p114g_hygiene(body,index,g)}

@unsafe
def p115_menu(+segment: N111Segment, +direct: KDef, +index: P112FusionIndex, +ready: KDef) -> P115Menu:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      +function = p111v_get(direct,name)
      nt_choose(P115Menu,String.eq(dk(function),"P113Direct") && U32.is_eq(ix(dv(function)),1),
        u => P115Direct{name,arity},
        u => p115_choices(segment,index,ready,p114r_plan(segment,index),p114g_plan(segment,index,ready)))

@unsafe
def p115_menus(segments: List<&2,N111Segment>, +direct: KDef, +index: P112FusionIndex,
    +ready: KDef, acc: List<&2,P115Menu>) -> List<&2,P115Menu>:
  match segments:
    case Nil{}: nt_reverse(P115Menu,acc,[])
    case Con{segment,rest}: p115_menus(rest,direct,index,ready,Con{p115_menu(segment,direct,index,ready),acc})

@unsafe
def p115_prepare(+context: P115Context) -> P115Prepared:
  match context:
    case P115Empty{chunks}: P115Prepared{context,[]}
    case P115Context{segments,direct,index,ids,ready,prefix,private,suffix}:
      P115Prepared{context,p115_menus(segments,direct,index,ready,[])}

# 1=R, 2=G, 3=H, 4=generic. Direct admission precedes every policy.
@unsafe
def p115_route(+policy: U32, +r: Bool, +g: Bool, +h: Bool) -> U32:
  match policy:
    case 0: nt_choose(U32,h,u => 3,u => nt_choose(U32,r,u => 1,u => nt_choose(U32,g,u => 2,u => 4)))
    case 1: nt_choose(U32,r,u => 1,u => nt_choose(U32,g,u => 2,u => nt_choose(U32,h,u => 3,u => 4)))
    case 2: nt_choose(U32,h,u => 3,u => 4)
    case _: 4

@unsafe
def p115_render_choice(+segment: N111Segment, +ids: N111Ids, +ready: KDef,
    +r: P114RPlan, +g: P114GPlan, +h: P114HPlan, +fusion: P112FusionBody, route: U32) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      match route:
        case 1: p114r_public(name,arity) ++ p114r_private(name,ids,r)
        case 2: p114r_public(name,arity) ++ p114g_private(name,ids,g)
        case 3: p114r_public(name,arity) ++ p114h_private(name,ids,h)
        case _: p112f_public(segment,ids,ready,fusion)

@unsafe
def p115_render(menu: P115Menu, +ids: N111Ids, +ready: KDef, +policy: U32) -> String:
  match menu:
    case P115Direct{name,arity}: p113e_public(name,arity)
    case P115Choices{segment,r,g,+h,fusion,allow_r,allow_g}:
      p115_render_choice(segment,ids,ready,r,g,h,fusion,p115_route(policy,allow_r,allow_g,p114h_valid(h)))

@unsafe
def p115_render_all(menus: List<&2,P115Menu>, +ids: N111Ids, +ready: KDef,
    +policy: U32, acc: List<&2,String>) -> List<&2,String>:
  match menus:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{menu,rest}: p115_render_all(rest,ids,ready,policy,Con{p115_render(menu,ids,ready,policy),acc})

# Original-style evaluator: computes each alternative as it is tried. Policy0
# calls the untouched Phase114 hook, including its repeated rejected H query.
@unsafe
def p115_legacy_other(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids,
    +ready: KDef, policy: U32) -> String:
  match policy:
    case 1: p114h_public_r(segment,index,ids,ready,p114r_plan(segment,index))
    case 2: p114h_public_planned(segment,index,ids,ready,p114h_plan(segment,index,ready))
    case _: p112f_public(segment,ids,ready,p112c_plan_index(segment,index,ready))

@unsafe
def p115_legacy(+segment: N111Segment, +direct: KDef, +index: P112FusionIndex,
    +ids: N111Ids, +ready: KDef, +policy: U32) -> String:
  nt_choose(String,U32.is_eq(policy,0),u => p113e_public_chunk(segment,direct,index,ids,ready),
    u => p115_legacy_nondefault(segment,direct,index,ids,ready,policy))

@unsafe
def p115_legacy_nondefault(+segment: N111Segment, +direct: KDef, +index: P112FusionIndex,
    +ids: N111Ids, +ready: KDef, +policy: U32) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      +function = p111v_get(direct,name)
      nt_choose(String,String.eq(dk(function),"P113Direct") && U32.is_eq(ix(dv(function)),1),
        u => p113e_public(name,arity),u => p115_legacy_other(segment,index,ids,ready,policy))

@unsafe
def p115_legacy_all(segments: List<&2,N111Segment>, +direct: KDef, +index: P112FusionIndex,
    +ids: N111Ids, +ready: KDef, +policy: U32, acc: List<&2,String>) -> List<&2,String>:
  match segments:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{segment,rest}: p115_legacy_all(rest,direct,index,ids,ready,policy,Con{p115_legacy(segment,direct,index,ids,ready,policy),acc})

@unsafe
def p115_legacy_chunks(context: P115Context, +policy: U32) -> List<&2,String>:
  match context:
    case P115Empty{chunks}: chunks
    case P115Context{segments,direct,index,ids,ready,prefix,private,suffix}:
      nt_append(String,prefix,nt_append(String,p112c_attach(p115_legacy_all(segments,direct,index,ids,ready,policy,[]),private),suffix))

@unsafe
def p115_cached_chunks(prepared: P115Prepared, +policy: U32) -> List<&2,String>:
  match prepared:
    case P115Prepared{context,menus}:
      match context:
        case P115Empty{chunks}: chunks
        case P115Context{segments,direct,index,ids,ready,prefix,private,suffix}:
          nt_append(String,prefix,nt_append(String,p112c_attach(p115_render_all(menus,ids,ready,policy,[]),private),suffix))

@unsafe
def p115_registered(+program: P111Program, +nodes: List<&2,P112SNode>, +functions: List<&2,P113DFunction>,
    +index: P112FusionIndex, +ids: N111Ids, +enabled: Bool, registry: P112RegionRegistry) -> P115Context:
  match program registry:
    case P111Program{segments,constructors,show,names,effects,pure} P112RegionRegistry{ready,symbols,entries,workers,fusions}:
      +direct = p113e_signatures(functions,missing())
      +prefix = nt_choose(List<&2,String>,enabled,
        u => p113ah_private_chunks(functions,ids,p113a_heap_min(nodes),[]),
        u => p113e_private_chunks(functions,ids,[]))
      P115Context{segments,direct,index,ids,ready,prefix,
        nt_join(p113e_old_private_chunks(entries,direct,ids,[]),""),
        nt_append(String,p111q_data_chunks(nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),
          u => p111q_tables(program,ids),u => p112s_tables(program,nodes,ids))),[p111q_main()])}

@unsafe
def p115_indexed(+program: P111Program, +nodes: List<&2,P112SNode>, +functions: List<&2,P113DFunction>,
    +enabled: Bool, +index: P112FusionIndex) -> P115Context:
  match program:
    case P111Program{segments,constructors,show,names,effects,pure}:
      p115_registered(program,nodes,functions,index,p111q_ids(program),enabled,p112c_index_with(segments,index))

@unsafe
def p115_open(program: P113AProgram) -> P115Context:
  match program:
    case P113AProgram{P113DProgram{original,Nil{}},certificate}: P115Empty{p112s_chunks(original)}
    case P113AProgram{P113DProgram{P112StaticProgram{+original,nodes},functions},certificate}:
      p115_original(original,nodes,functions,p113a_enabled(certificate))

@unsafe
def p115_original(+original: P111Program, +nodes: List<&2,P112SNode>,
    +functions: List<&2,P113DFunction>, +enabled: Bool) -> P115Context:
  match original:
    case P111Program{segments,constructors,show,names,effects,pure}:
      p115_indexed(original,nodes,functions,enabled,p112f_index(segments))
