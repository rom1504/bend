# Bounded structural descriptors. Type parameters may be opaque; live dependent
# fields and differing instantiations of one visible owner are refused.
type P195ODShape is Data:
  P195ODShape{+pattern: KTerm, +params: List<&2,KTerm>, +types: List<&2,KTerm>, +error: String}

type P195ODSchema is Data:
  P195ODSchema{+schema: NO_Schema, +inputs: List<&2,KTerm>}

law p195od_shape:
  for +book: List<&2,KDef>
  for +ty: KTerm
  for +next: U32
  for +fuel: U32
  P195ODShape

law p195od_wrap:
  for +book: List<&2,KDef>
  for +ty: KTerm
  for +params: List<&2,KTerm>
  for +roots: List<&2,U32>
  for +shells: U32
  for +observation: String
  NOL_Wrap

@unsafe
def p195od_absent() -> KTerm:
  kt("Absent","",0,0,[])

@unsafe
def p195od_fields(+book: List<&2,KDef>, +ty: KTerm, +tel: KTerm, +left: U32, +seen: List<&2,U32>) -> KTerm:
  +head = nq_layout_type(book,tel)
  nt_choose(KTerm,U32.is_eq(left,0),
    u => nt_choose(KTerm,String.eq(tg(head),"ADT") && norm_exact(head,ty),v => kt("NO_Types","",0,0,[]),v => nol_error("owned diagnostic: indexed constructor")),
    u => nt_choose(KTerm,String.eq(tg(head),"All") && Bool.not(U32.is_eq(qt(head),0)) && U32.is_le(left,16),
      v => nt_choose(KTerm,Bool.not(nq_layout_dep(nq_layout_type(book,kid(head,0)),seen)),
        w => nol_field_cons(nq_layout_type(book,kid(head,0)),p195od_fields(book,ty,kid(head,1),U32.sub(left,1),Con{ix(head),seen})),
        w => nol_error("owned diagnostic: live dependent field")),v => nol_error("owned diagnostic: field telescope")))

@unsafe
def p195od_ctor_fields(+book: List<&2,KDef>, +ty: KTerm, +ctr: KDef) -> KTerm:
  nt_choose(KTerm,nol_owner(book,ty) && String.eq(dk(ctr),"Ctr") && U32.is_eq(dx(ctr),0) && U32.is_le(da(ctr),16),
    u => p195od_fields(book,ty,nq_layout_specialize(dt(ctr),ks(ty),64),da(ctr),[]),u => nol_error("owned diagnostic: constructor descriptor"))

@unsafe
def p195od_signature(+book: List<&2,KDef>, +ty: KTerm, +args: List<&2,KTerm>, +seen: List<&2,U32>, +fuel: U32) -> KTerm:
  +head = nq_layout_type(book,ty)
  nt_choose(KTerm,U32.is_eq(fuel,0),u => nol_error("owned diagnostic: telescope budget"),
    u => nt_choose(KTerm,String.eq(tg(head),"All"),
      v => nt_choose(KTerm,U32.is_eq(qt(head),0),
        w => p195od_signature(book,kid(head,1),args,seen,U32.sub(fuel,1)),
        w => nt_choose(KTerm,Bool.not(nq_layout_dep(kid(head,0),seen)),
          z => p195od_signature(book,kid(head,1),Con{nq_layout_type(book,kid(head,0)),args},Con{ix(head),seen},U32.sub(fuel,1)),
          z => nol_error("owned diagnostic: dependent argument"))),
      v => nt_choose(KTerm,Bool.not(nq_layout_dep(head,seen)),
        w => kt("ODSignature","",0,0,[kt("ODTypes","",0,0,nt_reverse(KTerm,args,[])),head]),w => nol_error("owned diagnostic: dependent result"))))

@unsafe
def p195od_shape_leaf(+book: List<&2,KDef>, +ty: KTerm, +next: U32) -> P195ODShape:
  +p = kt("Var",nm(ty),nc_id(next),0,[ty])
  nt_choose(P195ODShape,nol_owner(book,ty) && U32.is_lt(next,8),
    u => P195ODShape{p,[p],nt_choose(List<&2,KTerm>,nol_scalar(book,ty),v => [],v => [ty]),""},
    u => P195ODShape{p,[],[],"owned diagnostic: unsupported input leaf or width"})

@unsafe
def p195od_shape_join(+first: P195ODShape, +rest: P195ODShape) -> P195ODShape:
  match first rest:
    case P195ODShape{a,ap,at,ae} P195ODShape{b,bp,bt,be}:
      P195ODShape{k_with_children(b,Con{a,ks(b)}),nt_append(KTerm,ap,bp),nt_append(KTerm,at,bt),p111_first(ae,be)}

@unsafe
def p195od_shape_fields(+book: List<&2,KDef>, fields: List<&2,KTerm>, +next: U32, +fuel: U32) -> P195ODShape:
  match fields:
    case Nil{}: P195ODShape{kt("ODInputs","",0,0,[]),[],[],""}
    case Con{+ty,rest}:
      +first = p195od_shape(book,ty,next,fuel)
      match first:
        case P195ODShape{pattern,+params,types,error}:
          p195od_shape_join(first,p195od_shape_fields(book,rest,U32.add(next,terms_len(params)),fuel))

@unsafe
def p195od_shape_ctor(+book: List<&2,KDef>, +ty: KTerm, +ctr: KDef, +next: U32, +fuel: U32) -> P195ODShape:
  +fields = p195od_ctor_fields(book,ty,ctr)
  nt_choose(P195ODShape,String.eq(tg(fields),"NO_Types") && U32.is_ge(da(ctr),1),
    u => p195od_shape_named(nc_ctor_identity(book,dn(ctr)),p195od_shape_fields(book,ks(fields),next,U32.sub(fuel,1))),
    u => P195ODShape{p195od_absent(),[],[],"owned diagnostic: product input fields"})

@unsafe
def p195od_shape_named(name: String, shape: P195ODShape) -> P195ODShape:
  match shape:
    case P195ODShape{pattern,params,types,error}: P195ODShape{kt("Ctr",name,0,0,ks(pattern)),params,types,error}

@unsafe
def p195od_shape_cases(+book: List<&2,KDef>, +ty: KTerm, +next: U32, +fuel: U32, cases: List<&2,KDef>) -> P195ODShape:
  match cases:
    case Con{+ctor,Nil{}}:
      nt_choose(P195ODShape,Bool.not(db(lookup(book,nm(ty)))) || String.eq(nm(ty),"Sigma"),
        u => p195od_shape_ctor(book,ty,ctor,next,fuel),u => p195od_shape_leaf(book,ty,next))
    case _: p195od_shape_leaf(book,ty,next)

@unsafe
def p195od_shape(book,ty,next,fuel):
  nt_choose(P195ODShape,U32.is_eq(fuel,0),u => P195ODShape{p195od_absent(),[],[],"owned diagnostic: input product budget"},
    u => nt_choose(P195ODShape,nol_scalar(book,ty),v => p195od_shape_leaf(book,ty,next),
      v => p195od_shape_cases(book,ty,next,fuel,dc(lookup(book,nm(ty))))))

@unsafe
def p195od_roots(+book: List<&2,KDef>, params: List<&2,KTerm>, +i: U32) -> List<&2,U32>:
  match params:
    case Nil{}: []
    case Con{+p,rest}:
      nt_choose(List<&2,U32>,nol_scalar(book,kid(p,0)),u => p195od_roots(book,rest,U32.inc(i)),u => Con{i,p195od_roots(book,rest,U32.inc(i))})

@unsafe
def p195od_root_type(+ty: KTerm, +params: List<&2,KTerm>, roots: List<&2,U32>) -> KTerm:
  match roots:
    case Nil{}: p195od_absent()
    case Con{+i,rest}: nt_choose(KTerm,norm_exact(ty,kid(terms_at(params,i),0)),u => terms_at(params,i),u => p195od_root_type(ty,params,rest))

@unsafe
def p195od_remove(+id: U32, +params: List<&2,KTerm>, roots: List<&2,U32>) -> List<&2,U32>:
  match roots:
    case Nil{}: []
    case Con{+i,rest}: nt_choose(List<&2,U32>,U32.is_eq(ix(terms_at(params,i)),id),u => rest,u => Con{i,p195od_remove(id,params,rest)})

@unsafe
def p195od_wrap_fields(+book: List<&2,KDef>, fields: List<&2,KTerm>, +params: List<&2,KTerm>, +roots: List<&2,U32>, +shells: U32, +observation: String) -> NOL_Wrap:
  match fields:
    case Nil{}: NOL_Wrap{kt("NO_WrapFields","",0,0,[]),roots,shells,observation,""}
    case Con{ty,rest}: p195od_wrap_tail(book,rest,params,p195od_wrap(book,ty,params,roots,shells,observation))

@unsafe
def p195od_wrap_tail(+book: List<&2,KDef>, rest: List<&2,KTerm>, params: List<&2,KTerm>, +head: NOL_Wrap) -> NOL_Wrap:
  match head:
    case NOL_Wrap{term,roots,shells,observation,+error}:
      nt_choose(NOL_Wrap,String.is_empty(error),u => nol_wrap_cons(term,p195od_wrap_fields(book,rest,params,roots,shells,observation)),u => head)

@unsafe
def p195od_optional(+book: List<&2,KDef>, +ty: KTerm, +empty: KDef, +one: KDef, +roots: List<&2,U32>, +shells: U32, +observation: String) -> NOL_Wrap:
  +ef = p195od_ctor_fields(book,ty,empty)
  +sf = p195od_ctor_fields(book,ty,one)
  +payload = kid(sf,0)
  nt_choose(NOL_Wrap,String.is_empty(observation) && U32.is_eq(da(empty),0) && U32.is_eq(da(one),1) &&
    String.eq(tg(ef),"NO_Types") && String.eq(tg(sf),"NO_Types") && nol_owner(book,payload),
    u => NOL_Wrap{kt("ODOwned",nm(payload),0,0,[ref(nc_ctor_identity(book,dn(empty))),ref(nc_ctor_identity(book,dn(one)))]),roots,shells,nm(payload),""},
    u => nol_wrap_fail("owned diagnostic: optional result shape",roots,shells,observation))

@unsafe
def p195od_wrap_cases(+book: List<&2,KDef>, +ty: KTerm, +params: List<&2,KTerm>, +roots: List<&2,U32>, +shells: U32, +observation: String, cases: List<&2,KDef>) -> NOL_Wrap:
  match cases:
    case Con{+ctr,Nil{}}:
      +fields = p195od_ctor_fields(book,ty,ctr)
      nt_choose(NOL_Wrap,String.eq(tg(fields),"NO_Types") && U32.is_ge(da(ctr),1) && (Bool.not(db(lookup(book,nm(ty)))) || String.eq(nm(ty),"Sigma")),
        u => nol_wrap_constructor(nc_ctor_identity(book,dn(ctr)),p195od_wrap_fields(book,ks(fields),params,roots,U32.inc(shells),observation)),
        u => nol_wrap_fail("owned diagnostic: result product",roots,shells,observation))
    case Con{+a,Con{+b,Nil{}}}:
      nt_choose(NOL_Wrap,U32.is_eq(da(a),0),u => p195od_optional(book,ty,a,b,roots,shells,observation),u => p195od_optional(book,ty,b,a,roots,shells,observation))
    case _: nol_wrap_fail("owned diagnostic: result descriptor",roots,shells,observation)

@unsafe
def p195od_wrap(book,ty,params,roots,shells,observation):
  +root = p195od_root_type(ty,params,roots)
  nt_choose(NOL_Wrap,U32.is_ge(shells,4),u => nol_wrap_fail("owned diagnostic: result budget",roots,shells,observation),
    u => nt_choose(NOL_Wrap,String.eq(tg(root),"Var"),v => NOL_Wrap{root,p195od_remove(ix(root),params,roots),shells,observation,""},
      v => p195od_wrap_cases(book,ty,params,roots,shells,observation,dc(lookup(book,nm(ty))))))

@unsafe
def p195od_field_name(+book: List<&2,KDef>, +field: KTerm) -> String:
  nt_choose(String,nol_owner(book,field),u => nm(field),u => "$p195.opaque." ++ term_key(field))

@unsafe
def p195od_field_names(+book: List<&2,KDef>, fields: List<&2,KTerm>) -> List<&2,String>:
  match fields:
    case Nil{}: []
    case Con{field,rest}: Con{p195od_field_name(book,field),p195od_field_names(book,rest)}

@unsafe
def p195od_children(+book: List<&2,KDef>, fields: List<&2,KTerm>) -> List<&2,KTerm>:
  match fields:
    case Nil{}: []
    case Con{+field,rest}: nt_choose(List<&2,KTerm>,nol_owner(book,field) && Bool.not(nol_scalar(book,field)),u => Con{field,p195od_children(book,rest)},u => p195od_children(book,rest))

@unsafe
def p195od_graph_case(+book: List<&2,KDef>, +ty: KTerm, +ctor: KDef) -> P128BLNode:
  +fields = p195od_ctor_fields(book,ty,ctor)
  +width = da(ctor)
  +key = nc_ctor_identity(book,dn(ctor))
  nt_choose(P128BLNode,String.eq(tg(fields),"NO_Types") && (U32.is_eq(width,0) || (U32.is_ge(width,2) && U32.is_le(width,16))),
    u => P128BLNode{[NO_Spec{NO_Layout{key,key,nt_choose(String,U32.is_eq(width,0),v => "Nullary",v => "Boxed"),width},nm(ty),p195od_field_names(book,ks(fields))}],p195od_children(book,ks(fields)),""},
    u => P128BLNode{[],[],"owned diagnostic: graph constructor fields/width"})

@unsafe
def p195od_graph_cases(+book: List<&2,KDef>, +ty: KTerm, cases: List<&2,KDef>, +fuel: U32) -> P128BLNode:
  match cases:
    case Nil{}: P128BLNode{[],[],""}
    case Con{ctor,rest}: nt_choose(P128BLNode,U32.is_eq(fuel,0),u => P128BLNode{[],[],"owned diagnostic: constructor budget"},u => p131rg_join(p195od_graph_case(book,ty,ctor),p195od_graph_cases(book,ty,rest,U32.sub(fuel,1))))

@unsafe
def p195od_graph_node(+book: List<&2,KDef>, +ty: KTerm) -> P128BLNode:
  +owner = lookup(book,nm(ty))
  +old = nol_root_specs(book,ty)
  nt_choose(P128BLNode,Bool.not(List.is_empty(&2,NO_Spec,old)),u => P128BLNode{old,[],""},
    u => nt_choose(P128BLNode,nol_owner(book,ty) && Bool.not(db(owner)) && Bool.not(List.is_empty(&2,KDef,dc(owner))),
      v => p195od_graph_cases(book,ty,dc(owner),8),v => P128BLNode{[],[],"owned diagnostic: graph native/unknown owner"}))

law p195od_graph:
  for +book: List<&2,KDef>
  for todo: List<&2,KTerm>
  for +types: List<&2,KTerm>
  for +specs: List<&2,NO_Spec>
  for +fuel: U32
  P128BLGraph

@unsafe
def p195od_graph_extend(+book: List<&2,KDef>, +ty: KTerm, rest: List<&2,KTerm>, types: List<&2,KTerm>, specs: List<&2,NO_Spec>, fuel: U32, node: P128BLNode) -> P128BLGraph:
  match node:
    case P128BLNode{added,children,+error}: nt_choose(P128BLGraph,String.is_empty(error),u => p195od_graph(book,nt_append(KTerm,children,rest),Con{ty,types},nt_append(NO_Spec,added,specs),fuel),u => P128BLGraph{[],[],error})

@unsafe
def p195od_graph(book,todo,types,specs,fuel):
  match todo:
    case Nil{}: P128BLGraph{types,specs,""}
    case Con{+ty,rest}:
      +old = p128bl_type(nm(ty),types)
      nt_choose(P128BLGraph,U32.is_eq(fuel,0),u => P128BLGraph{[],[],"owned diagnostic: layout graph budget"},
        u => nt_choose(P128BLGraph,String.eq(tg(old),"Absent"),v => p195od_graph_extend(book,ty,rest,types,specs,U32.sub(fuel,1),p195od_graph_node(book,ty)),
          v => nt_choose(P128BLGraph,norm_exact(old,ty),w => p195od_graph(book,rest,types,specs,U32.sub(fuel,1)),w => P128BLGraph{[],[],"owned diagnostic: conflicting visible specialization"})))

@unsafe
def p195od_schema_finish(+book: List<&2,KDef>, +params: List<&2,KTerm>, +inputs: List<&2,KTerm>, +roots: List<&2,U32>, graph: P128BLGraph, wrapped: NOL_Wrap) -> P195ODSchema:
  match graph wrapped:
    case P128BLGraph{types,specs,ge} NOL_Wrap{wrapper,remaining,shells,observation,we}:
      +error = p111_first(ge,p111_first(we,nt_choose(String,List.is_empty(&2,U32,remaining) && Bool.not(String.is_empty(observation)) && U32.is_ge(nt_count(U32,roots),1) && U32.is_le(nt_count(U32,roots),3),u => "",u => "owned diagnostic: root/result coverage")))
      P195ODSchema{NO_Schema{params,roots,wrapper,nc_id(64),observation,nt_append(NO_Spec,specs,nol_scalar_specs(book,book)),100,error},inputs}

@unsafe
def p195od_schema_shape(+book: List<&2,KDef>, +result: KTerm, shape: P195ODShape) -> P195ODSchema:
  match shape:
    case P195ODShape{pattern,+params,types,+error}:
      +roots = p195od_roots(book,params,0)
      nt_choose(P195ODSchema,String.is_empty(error),
        u => p195od_schema_finish(book,params,ks(pattern),roots,p195od_graph(book,types,[],[],64),p195od_wrap(book,result,params,roots,0,"")),
        u => P195ODSchema{nol_failure(error,100),[]})

@unsafe
def p195od_schema(+book: List<&2,KDef>, +owner: String) -> P195ODSchema:
  +d = lookup(book,owner)
  +sig = p195od_signature(book,dt(d),[],[],32)
  nt_choose(P195ODSchema,String.eq(dk(d),"Def") && Bool.not(nc_native_def(d) || nc_foreign(d)) && String.eq(tg(sig),"ODSignature") && U32.is_le(terms_len(ks(kid(sig,0))),4),
    u => p195od_schema_shape(book,kid(sig,1),p195od_shape_fields(book,ks(kid(sig,0)),0,4)),
    u => P195ODSchema{nol_failure("owned diagnostic: owner/signature",100),[]})
