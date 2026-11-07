# Phase173 explicit wide-return ceiling revision2; affine payload quantity preserved.
# Alternative module, not production; select in place of store-wide8.bend.
# Derived from store-flat7.bend; algorithm and Array tuple ABI unchanged.
# Phase173 flat-carrier alternative to store.bend; select ONE implementation.
# Based on frozen store-modules05/store.bend SHA256 812c755230558a97be7cd8636626c9935e82bb92c62f2dac7ce6c2d26b15849b.
# Remove only stored node/edge depths; derive log2(capacity) on growth.
# Phase173 experimental semantic store. Not installed compiler code.
# IDs are append-only postorder identities. Arrays are linearly threaded;
# no packed-array, foreign allocator, mutation alias or Array.fork assumption.
type P173Shape is Data:
  P173Term{+tag: String, +name: String, +id: U32, +quant: U32, +removed: List<&2,String>, +begin: U32, +end: U32}
  P173Lambda{+name: String, +id: U32, +quant: U32, +removed: List<&2,String>, +begin: U32, +end: U32, +present: Bool}
  P173Literal{+kind: String, +number: U32, +text: String, +begin: U32, +end: U32}

type P173Node is Data:
  P173Node{+shape: P173Shape, +start: U32, +count: U32}

type P173Store is Type:
  P173Store{nodes: Array<P173Node>,edges: Array<U32>,+used: U32,+edgeUsed: U32,+nodeCapacity: U32,+edgeCapacity: U32,+ok: Bool}

# Explicit source ceiling: shallow eight-word return ABI. Each Array handle
# retains its ordinary affine ownership; payload stays one opaque Data word.
type P173Return<-T: Data> is Type:
  P173Return{nodes: Array<P173Node>,edges: Array<U32>,+used: U32,+edgeUsed: U32,+nodeCapacity: U32,+edgeCapacity: U32,+ok: Bool,value: T}

@unsafe
def p173r_pack(-T: Data, store: P173Store, value: T) -> P173Return<T>:
  match store:
    case P173Store{nodes,edges,+n,+e,+nc,+ec,+ok}:
      P173Return{nodes,edges,n,e,nc,ec,ok,value}

type P173ImportFrame is Data:
  P173ImportVisit{+term: KTerm}
  P173ImportChildren{+shape: P173Shape, +rest: List<&2,KTerm>, +ids: List<&2,U32>}

type P173ExportFrame is Data:
  P173ExportVisit{id: U32}
  P173ExportChildren{+shape: P173Shape, +start: U32, +next: U32, +count: U32, +terms: List<&2,KTerm>}

law p173match_1:
  for +values: List<&2,U32>
  for store: P173Store
  P173Return<U32>

law p173match_2:
  for +values: List<&2,KTerm>
  for store: P173Store
  P173Return<KTerm>

law p173match_5:
  for +kids: List<&2,KTerm>
  for +values: List<&2,U32>
  for store: P173Store
  for +rest: List<&2,P173ImportFrame>
  for +next: U32
  for +shape: P173Shape
  for +ids: List<&2,U32>
  for +id: U32
  P173Return<U32>

law p173match_4:
  for +values: List<&2,U32>
  for store: P173Store
  for +rest: List<&2,P173ImportFrame>
  for +next: U32
  for +shape: P173Shape
  for +kids: List<&2,KTerm>
  for +ids: List<&2,U32>
  P173Return<U32>

law p173match_3:
  for +frame: P173ImportFrame
  for store: P173Store
  for +values: List<&2,U32>
  for +rest: List<&2,P173ImportFrame>
  for +next: U32
  P173Return<U32>

law p173match_7:
  for +values: List<&2,KTerm>
  for store: P173Store
  for +fuel: U32
  for +rest: List<&2,P173ExportFrame>
  for +shape: P173Shape
  for +start: U32
  for +next: U32
  for +count: U32
  for +terms: List<&2,KTerm>
  P173Return<KTerm>

law p173match_6:
  for +frame: P173ExportFrame
  for store: P173Store
  for +values: List<&2,KTerm>
  for +fuel: U32
  for +rest: List<&2,P173ExportFrame>
  P173Return<KTerm>

law p173take_2:
  for +shape: P173Shape
  for +start: U32
  for pair: P173Return<U32>
  P173Return<U32>

law p173take_1:
  for +shape: P173Shape
  for +ids: List<&2,U32>
  for pair: P173Return<U32>
  P173Return<U32>

law p173take_3:
  for +todo: List<&2,P173ImportFrame>
  for +values: List<&2,U32>
  for +fuel: U32
  for pair: P173Return<U32>
  P173Return<U32>

law p173take_4:
  for +todo: List<&2,P173ExportFrame>
  for +values: List<&2,KTerm>
  for +fuel: U32
  for pair: P173Return<P173Node>
  P173Return<KTerm>

law p173take_6:
  for +fuel: U32
  for +n: U32
  for pair: P173Return<U32>
  P173Return<Bool>

law p173take_5:
  for +fuel: U32
  for pair: P173Return<U32>
  P173Return<Bool>

law p173take_7:
  for edges: Array<U32>
  for +n: U32
  for +e: U32
  for +nc: U32
  for +ec: U32
  for +ok: Bool
  for pair: Array<P173Node> & P173Node
  P173Return<P173Node>

law p173take_8:
  for nodes: Array<P173Node>
  for +n: U32
  for +e: U32
  for +nc: U32
  for +ec: U32
  for +ok: Bool
  for pair: Array<U32> & U32
  P173Return<U32>

law p173take_9:
  for +values: List<&2,U32>
  for +rest: List<&2,P173ImportFrame>
  for +next: U32
  for pair: P173Return<U32>
  P173Return<U32>

law p173take_10:
  for +todo: List<&2,P173ExportFrame>
  for +values: List<&2,KTerm>
  for +fuel: U32
  for +shape: P173Shape
  for +start: U32
  for +count: U32
  for pair: P173Return<U32>
  P173Return<KTerm>

law p173take_11:
  for +values: List<&2,KTerm>
  for +fuel: U32
  for +rest: List<&2,P173ExportFrame>
  for +shape: P173Shape
  for +start: U32
  for +next: U32
  for +count: U32
  for +terms: List<&2,KTerm>
  for +term: KTerm
  for pair: P173Return<U32>
  P173Return<KTerm>

law p173take_12:
  for +start: U32
  for +todo: List<&2,U32>
  for +left: U32
  for pair: P173Return<U32>
  P173Return<List<&2,U32>>

law p173take_13:
  for +acc: List<&2,String>
  for +fuel: U32
  for +shape: P173Shape
  for pair: P173Return<List<&2,U32>>
  P173Return<List<&2,String>>

law p173take_14:
  for +todo: List<&2,U32>
  for +acc: List<&2,String>
  for +fuel: U32
  for pair: P173Return<P173Node>
  P173Return<List<&2,String>>

law p173take_15:
  for +id: U32
  for +start: U32
  for +count: U32
  for +fuel: U32
  for pair: P173Return<U32>
  P173Return<Bool>

law p173take_16:
  for +id: U32
  for +n: U32
  for +edges: U32
  for +fuel: U32
  for +count: U32
  for pair: P173Return<Bool>
  P173Return<Bool>

law p173take_17:
  for +id: U32
  for +n: U32
  for +edges: U32
  for +fuel: U32
  for pair: P173Return<P173Node>
  P173Return<Bool>

law p173branch_1:
  for +id: U32
  for nodes: Array<P173Node>
  for edges: Array<U32>
  for +n: U32
  for +e: U32
  for +nc: U32
  for +ec: U32
  for +ok: Bool
  for +p173test: Bool
  P173Return<P173Node>

law p173branch_2:
  for +id: U32
  for nodes: Array<P173Node>
  for edges: Array<U32>
  for +n: U32
  for +e: U32
  for +nc: U32
  for +ec: U32
  for +ok: Bool
  for +p173test: Bool
  P173Return<U32>

law p173branch_4:
  for +node: P173Node
  for nodes: Array<P173Node>
  for edges: Array<U32>
  for +n: U32
  for +e: U32
  for +nc: U32
  for +ec: U32
  for +ok: Bool
  for +p173test: Bool
  P173Return<U32>

law p173branch_3:
  for +node: P173Node
  for nodes: Array<P173Node>
  for edges: Array<U32>
  for +n: U32
  for +e: U32
  for +nc: U32
  for +ec: U32
  for +ok: Bool
  for +p173test: Bool
  P173Return<U32>

law p173branch_7:
  for +id: U32
  for nodes: Array<P173Node>
  for edges: Array<U32>
  for +n: U32
  for +e: U32
  for +nc: U32
  for +ec: U32
  for +ok: Bool
  for +p173test: Bool
  P173Store

law p173branch_6:
  for +id: U32
  for nodes: Array<P173Node>
  for edges: Array<U32>
  for +n: U32
  for +e: U32
  for +nc: U32
  for +ec: U32
  for +ok: Bool
  for +p173test: Bool
  P173Store

law p173branch_5:
  for +id: U32
  for nodes: Array<P173Node>
  for edges: Array<U32>
  for +n: U32
  for +e: U32
  for +nc: U32
  for +ec: U32
  for +ok: Bool
  for +p173test: Bool
  P173Store

law p173branch_8:
  for store: P173Store
  for +values: List<&2,U32>
  for +fuel: U32
  for +frame: P173ImportFrame
  for +rest: List<&2,P173ImportFrame>
  for +p173test: Bool
  P173Return<U32>

law p173branch_10:
  for store: P173Store
  for +todo: List<&2,P173ExportFrame>
  for +values: List<&2,KTerm>
  for +fuel: U32
  for +shape: P173Shape
  for +start: U32
  for +count: U32
  for +p173test: Bool
  P173Return<KTerm>

law p173branch_9:
  for store: P173Store
  for +todo: List<&2,P173ExportFrame>
  for +values: List<&2,KTerm>
  for +fuel: U32
  for +node: P173Node
  P173Return<KTerm>

law p173branch_12:
  for store: P173Store
  for +values: List<&2,KTerm>
  for +fuel: U32
  for +rest: List<&2,P173ExportFrame>
  for +shape: P173Shape
  for +start: U32
  for +next: U32
  for +count: U32
  for +terms: List<&2,KTerm>
  for +term: KTerm
  for +p173test: Bool
  P173Return<KTerm>

law p173branch_11:
  for store: P173Store
  for +values: List<&2,KTerm>
  for +fuel: U32
  for +frame: P173ExportFrame
  for +rest: List<&2,P173ExportFrame>
  for +p173test: Bool
  P173Return<KTerm>

law p173branch_13:
  for store: P173Store
  for +start: U32
  for +count: U32
  for +todo: List<&2,U32>
  for +p173test: Bool
  P173Return<List<&2,U32>>

law p173branch_16:
  for store: P173Store
  for +todo: List<&2,U32>
  for +acc: List<&2,String>
  for +fuel: U32
  for +shape: P173Shape
  for +p173test: Bool
  P173Return<List<&2,String>>

law p173branch_15:
  for store: P173Store
  for +todo: List<&2,U32>
  for +acc: List<&2,String>
  for +fuel: U32
  for +node: P173Node
  P173Return<List<&2,String>>

law p173branch_14:
  for store: P173Store
  for +todo: List<&2,U32>
  for +acc: List<&2,String>
  for +fuel: U32
  for +id: U32
  for +p173test: Bool
  P173Return<List<&2,String>>

law p173branch_19:
  for store: P173Store
  for +id: U32
  for +start: U32
  for +count: U32
  for +fuel: U32
  for +kid: U32
  for +p173test: Bool
  P173Return<Bool>

law p173branch_18:
  for store: P173Store
  for +id: U32
  for +start: U32
  for +count: U32
  for +fuel: U32
  for +p173test: Bool
  P173Return<Bool>

law p173branch_17:
  for store: P173Store
  for +id: U32
  for +start: U32
  for +count: U32
  for +fuel: U32
  for +p173test: Bool
  P173Return<Bool>

law p173branch_24:
  for store: P173Store
  for +id: U32
  for +n: U32
  for +edges: U32
  for +fuel: U32
  for +count: U32
  for +valid: Bool
  P173Return<Bool>

law p173branch_23:
  for store: P173Store
  for +id: U32
  for +n: U32
  for +edges: U32
  for +fuel: U32
  for +start: U32
  for +count: U32
  for +p173test: Bool
  P173Return<Bool>

law p173branch_22:
  for store: P173Store
  for +id: U32
  for +n: U32
  for +edges: U32
  for +fuel: U32
  for +node: P173Node
  P173Return<Bool>

law p173branch_21:
  for store: P173Store
  for +id: U32
  for +n: U32
  for +edges: U32
  for +fuel: U32
  for +p173test: Bool
  P173Return<Bool>

law p173branch_20:
  for store: P173Store
  for +id: U32
  for +n: U32
  for +edges: U32
  for +fuel: U32
  for +p173test: Bool
  P173Return<Bool>

law p173s_import_go:
  for store: P173Store
  for +todo: List<&2,P173ImportFrame>
  for +values: List<&2,U32>
  for +fuel: U32
  P173Return<U32>

law p173s_export_go:
  for store: P173Store
  for +todo: List<&2,P173ExportFrame>
  for +values: List<&2,KTerm>
  for +fuel: U32
  P173Return<KTerm>

@unsafe
def p173s_absent() -> P173Shape:
  P173Term{"Absent","",0,0,[],0,0}

@unsafe
def p173s_empty_node() -> P173Node:
  P173Node{p173s_absent(),0,0}

@unsafe
def p173s_new() -> P173Store:
  P173Store{Array.new(P173Node,4n,p173s_empty_node()),Array.new(U32,4n,0),1,0,16,16,True{}}

@unsafe
def p173s_fail(store: P173Store) -> P173Store:
  match store:
    case P173Store{nodes,edges,+n,+e,+nc,+ec,+ok}:
      P173Store{nodes,edges,n,e,nc,ec,False{}}

@unsafe
def p173s_ok(store: P173Store) -> P173Return<Bool>:
  match store:
    case P173Store{nodes,edges,+n,+e,+nc,+ec,+ok}:
      P173Return{nodes,edges,n,e,nc,ec,ok,ok}

@unsafe
def p173s_size(store: P173Store) -> P173Return<U32>:
  match store:
    case P173Store{nodes,edges,+n,+e,+nc,+ec,+ok}:
      P173Return{nodes,edges,n,e,nc,ec,ok,n}

@unsafe
def p173s_node(store: P173Store, +id: U32) -> P173Return<P173Node>:
  match store:
    case P173Store{nodes,edges,+n,+e,+nc,+ec,+ok}:
      p173branch_1(id,nodes,edges,n,e,nc,ec,ok,U32.is_lt(id,n))
@unsafe
def p173s_edge(store: P173Store, +id: U32) -> P173Return<U32>:
  match store:
    case P173Store{nodes,edges,+n,+e,+nc,+ec,+ok}:
      p173branch_2(id,nodes,edges,n,e,nc,ec,ok,U32.is_lt(id,e))
@unsafe
def p173s_add_node(store: P173Store, +node: P173Node) -> P173Return<U32>:
  match store:
    case P173Store{nodes,edges,+n,+e,+nc,+ec,+ok}:
      p173branch_3(node,nodes,edges,n,e,nc,ec,ok,U32.is_lt(n,nc))
@unsafe
def p173s_add_edge(store: P173Store, +id: U32) -> P173Store:
  match store:
    case P173Store{nodes,edges,+n,+e,+nc,+ec,+ok}:
      p173branch_5(id,nodes,edges,n,e,nc,ec,ok,U32.is_lt(id,n))
@unsafe
def p173s_edges_end(store: P173Store) -> P173Return<U32>:
  match store:
    case P173Store{nodes,edges,+n,+e,+nc,+ec,+ok}:
      P173Return{nodes,edges,n,e,nc,ec,ok,e}

@unsafe
def p173s_add_edges(store: P173Store, +ids: List<&2,U32>, +count: U32) -> P173Return<U32>:
  match ids:
    case Nil{}: p173r_pack(U32,store,count)
    case Con{+id,+rest}: p173s_add_edges(p173s_add_edge(store,id),rest,U32.inc(count))

@unsafe
def p173s_emit(store: P173Store, +shape: P173Shape, +ids: List<&2,U32>) -> P173Return<U32>:
  p173take_1(shape,ids,p173s_edges_end(store))
@unsafe
def p173s_shape_tag(+shape: P173Shape) -> String:
  match shape:
    case P173Term{+tag,+name,+id,+q,+removed,+b,+e}: tag
    case P173Lambda{+name,+id,+q,+removed,+b,+e,+p}: "Lam"
    case P173Literal{+kind,+n,+text,+b,+e}: "Lit"

@unsafe
def p173s_shape_name(+shape: P173Shape) -> String:
  match shape:
    case P173Term{+tag,+name,+id,+q,+removed,+b,+e}: name
    case P173Lambda{+name,+id,+q,+removed,+b,+e,+p}: name
    case P173Literal{+kind,+n,+text,+b,+e}: kind

@unsafe
def p173s_shape_term(+shape: P173Shape, +terms: List<&2,KTerm>) -> KTerm:
  match shape:
    case P173Term{+tag,+name,+id,+q,+removed,+b,+e}: KTerm{tag,name,id,q,terms,removed,b,e}
    case P173Lambda{+name,+id,+q,+removed,+b,+e,+p}: KLambda{name,id,q,terms,removed,b,e,p}
    case P173Literal{+kind,+n,+text,+b,+e}: KLiteral{kind,n,text,b,e}

@unsafe
def p173s_import_children(store: P173Store, +shape: P173Shape, +kids: List<&2,KTerm>, +todo: List<&2,P173ImportFrame>, +values: List<&2,U32>, +fuel: U32) -> P173Return<U32>:
  match kids:
    case Nil{}:
      p173take_3(todo,values,fuel,p173s_emit(store,shape,[]))
    case Con{+head,+rest}:
      p173s_import_go(store,Con{P173ImportVisit{head},Con{P173ImportChildren{shape,rest,[]},todo}},values,fuel)

@unsafe
def p173s_import_visit(store: P173Store, +term: KTerm, +todo: List<&2,P173ImportFrame>, +values: List<&2,U32>, +fuel: U32) -> P173Return<U32>:
  match term:
    case KTerm{+tag,+name,+id,+q,+kids,+removed,+b,+e}:
      p173s_import_children(store,P173Term{tag,name,id,q,removed,b,e},kids,todo,values,fuel)
    case KLambda{+name,+id,+q,+kids,+removed,+b,+e,+p}:
      p173s_import_children(store,P173Lambda{name,id,q,removed,b,e,p},kids,todo,values,fuel)
    case KLiteral{+kind,+n,+text,+b,+e}:
      p173s_import_children(store,P173Literal{kind,n,text,b,e},[],todo,values,fuel)

@unsafe
def p173s_import_go(store, todo, values, fuel):
  match todo:
    case Nil{}:
      p173match_1(values,store)
    case Con{+frame,+rest}:
      p173branch_8(store,values,fuel,frame,rest,U32.is_eq(fuel,0))
@unsafe
def p173s_import(store: P173Store, +term: KTerm, +fuel: U32) -> P173Return<U32>:
  p173s_import_go(store,[P173ImportVisit{term}],[],fuel)

@unsafe
def p173s_export_visit(store: P173Store, +id: U32, +todo: List<&2,P173ExportFrame>, +values: List<&2,KTerm>, +fuel: U32) -> P173Return<KTerm>:
  p173take_4(todo,values,fuel,p173s_node(store,id))
@unsafe
def p173s_export_go(store, todo, values, fuel):
  match todo:
    case Nil{}:
      p173match_2(values,store)
    case Con{+frame,+rest}:
      p173branch_11(store,values,fuel,frame,rest,U32.is_eq(fuel,0))
@unsafe
def p173s_export(store: P173Store, +id: U32, +fuel: U32) -> P173Return<KTerm>:
  p173s_export_go(store,[P173ExportVisit{id}],[],fuel)

@unsafe
def p173s_push_edges(store: P173Store, +start: U32, +count: U32, +todo: List<&2,U32>) -> P173Return<List<&2,U32>>:
  p173branch_13(store,start,count,todo,U32.is_eq(count,0))
@unsafe
def p173s_refs_go(store: P173Store, +todo: List<&2,U32>, +acc: List<&2,String>, +fuel: U32) -> P173Return<List<&2,String>>:
  match todo:
    case Nil{}: p173r_pack(List<&2,String>,store,nt_reverse(String,acc,[]))
    case Con{+id,+todo}:
      p173branch_14(store,todo,acc,fuel,id,U32.is_eq(fuel,0))
@unsafe
def p173s_refs(store: P173Store, +id: U32, +fuel: U32) -> P173Return<List<&2,String>>:
  p173s_refs_go(store,[id],[],fuel)

@unsafe
def p173s_valid_edges(store: P173Store, +id: U32, +start: U32, +count: U32, +fuel: U32) -> P173Return<Bool>:
  p173branch_17(store,id,start,count,fuel,U32.is_eq(count,0))
@unsafe
def p173s_valid_go(store: P173Store, +id: U32, +n: U32, +edges: U32, +fuel: U32) -> P173Return<Bool>:
  p173branch_20(store,id,n,edges,fuel,U32.is_eq(id,n))
@unsafe
def p173s_valid_header_test(store: P173Store, +fuel: U32, valid: Bool) -> P173Return<Bool>:
  match valid:
    case False{}: p173r_pack(Bool,store,False{})
    case True{}: p173take_5(fuel,p173s_size(store))

@unsafe
def p173s_valid_earray(nodes: Array<P173Node>, +n: U32, +e: U32, +nc: U32, +ec: U32, +ok: Bool, +fuel: U32, +observedNodes: U32, pair: Array<U32> & U32) -> P173Return<Bool>:
  match pair:
    case Tuple{edges,+observedEdges}:
      p173s_valid_header_test(P173Store{nodes,edges,n,e,nc,ec,ok},fuel,
        ok && U32.is_eq(nc,observedNodes) && U32.is_eq(ec,observedEdges) && U32.is_gt(n,0) && U32.is_le(n,nc) && U32.is_le(e,ec))

@unsafe
def p173s_valid_narray(edges: Array<U32>, +n: U32, +e: U32, +nc: U32, +ec: U32, +ok: Bool, +fuel: U32, pair: Array<P173Node> & U32) -> P173Return<Bool>:
  match pair:
    case Tuple{nodes,+observedNodes}:
      p173s_valid_earray(nodes,n,e,nc,ec,ok,fuel,observedNodes,Array.size(U32,edges))

@unsafe
def p173s_valid(store: P173Store, +fuel: U32) -> P173Return<Bool>:
  match store:
    case P173Store{nodes,edges,+n,+e,+nc,+ec,+ok}:
      p173s_valid_narray(edges,n,e,nc,ec,ok,fuel,Array.size(P173Node,nodes))
@unsafe
def p173branch_1(id, nodes, edges, n, e, nc, ec, ok, p173test):
  match p173test:
    case True{}:
      p173take_7(edges,n,e,nc,ec,ok,Array.get(P173Node,nodes,id))
    case False{}:
      P173Return{nodes,edges,n,e,nc,ec,False{},p173s_empty_node()}


@unsafe
def p173branch_2(id, nodes, edges, n, e, nc, ec, ok, p173test):
  match p173test:
    case True{}:
      p173take_8(nodes,n,e,nc,ec,ok,Array.get(U32,edges,id))
    case False{}:
      P173Return{nodes,edges,n,e,nc,ec,False{},0}


@unsafe
def p173branch_4(node, nodes, edges, n, e, nc, ec, ok, p173test):
  match p173test:
    case True{}:
      +capacity = U32.mul(nc,2)
      nodes : Array<P173Node> = ANode{nodes,Array.new(P173Node,U32.log2(nc),p173s_empty_node())}
      P173Return{Array.set(P173Node,nodes,n,node),edges,U32.inc(n),e,capacity,ec,ok,n}
    case False{}:
      P173Return{nodes,edges,n,e,nc,ec,False{},0}


@unsafe
def p173branch_3(node, nodes, edges, n, e, nc, ec, ok, p173test):
  match p173test:
    case True{}:
      P173Return{Array.set(P173Node,nodes,n,node),edges,U32.inc(n),e,nc,ec,ok,n}
    case False{}:
      p173branch_4(node,nodes,edges,n,e,nc,ec,ok,U32.is_lt(nc,1073741824))

@unsafe
def p173branch_7(id, nodes, edges, n, e, nc, ec, ok, p173test):
  match p173test:
    case True{}:
      edges : Array<U32> = ANode{edges,Array.new(U32,U32.log2(ec),0)}
      P173Store{nodes,Array.set(U32,edges,e,id),n,U32.inc(e),nc,U32.mul(ec,2),ok}
    case False{}: P173Store{nodes,edges,n,e,nc,ec,False{}}


@unsafe
def p173branch_6(id, nodes, edges, n, e, nc, ec, ok, p173test):
  match p173test:
    case True{}:
      P173Store{nodes,Array.set(U32,edges,e,id),n,U32.inc(e),nc,ec,ok}
    case False{}:
      p173branch_7(id,nodes,edges,n,e,nc,ec,ok,U32.is_lt(ec,1073741824))

@unsafe
def p173branch_5(id, nodes, edges, n, e, nc, ec, ok, p173test):
  match p173test:
    case False{}: P173Store{nodes,edges,n,e,nc,ec,False{}}
    case True{}:
      p173branch_6(id,nodes,edges,n,e,nc,ec,ok,U32.is_lt(e,ec))

@unsafe
def p173branch_8(store, values, fuel, frame, rest, p173test):
  match p173test:
    case True{}: p173r_pack(U32,p173s_fail(store),0)
    case False{}:
      +next = U32.sub(fuel,1)
      p173match_3(frame,store,values,rest,next)
@unsafe
def p173branch_10(store, todo, values, fuel, shape, start, count, p173test):
  match p173test:
    case True{}:
      p173s_export_go(store,todo,Con{p173s_shape_term(shape,[]),values},fuel)
    case False{}:
      p173take_10(todo,values,fuel,shape,start,count,p173s_edge(store,start))
@unsafe
def p173branch_9(store, todo, values, fuel, node):
  match node:
    case P173Node{+shape,+start,+count}:
      p173branch_10(store,todo,values,fuel,shape,start,count,U32.is_eq(count,0))

@unsafe
def p173branch_12(store, values, fuel, rest, shape, start, next, count, terms, term, p173test):
  match p173test:
    case True{}:
      p173s_export_go(store,rest,Con{p173s_shape_term(shape,nt_reverse(KTerm,Con{term,terms},[])),values},fuel)
    case False{}:
      p173take_11(values,fuel,rest,shape,start,next,count,terms,term,p173s_edge(store,U32.add(start,next)))
@unsafe
def p173branch_11(store, values, fuel, frame, rest, p173test):
  match p173test:
    case True{}: p173r_pack(KTerm,p173s_fail(store),atom("Absent"))
    case False{}:
      +fuel = U32.sub(fuel,1)
      p173match_6(frame,store,values,fuel,rest)
@unsafe
def p173branch_13(store, start, count, todo, p173test):
  match p173test:
    case True{}: p173r_pack(List<&2,U32>,store,todo)
    case False{}:
      +left = U32.sub(count,1)
      p173take_12(start,todo,left,p173s_edge(store,U32.add(start,left)))
@unsafe
def p173branch_16(store, todo, acc, fuel, shape, p173test):
  match p173test:
    case True{}: p173s_refs_go(store,todo,Con{p173s_shape_name(shape),acc},U32.sub(fuel,1))
    case False{}: p173s_refs_go(store,todo,acc,U32.sub(fuel,1))


@unsafe
def p173branch_15(store, todo, acc, fuel, node):
  match node:
    case P173Node{+shape,+start,+count}:
      p173take_13(acc,fuel,shape,p173s_push_edges(store,start,count,todo))
@unsafe
def p173branch_14(store, todo, acc, fuel, id, p173test):
  match p173test:
    case True{}: p173r_pack(List<&2,String>,p173s_fail(store),[])
    case False{}:
      p173take_14(todo,acc,fuel,p173s_node(store,id))
@unsafe
def p173branch_19(store, id, start, count, fuel, kid, p173test):
  match p173test:
    case False{}: p173r_pack(Bool,store,False{})
    case True{}: p173s_valid_edges(store,id,U32.inc(start),U32.sub(count,1),U32.sub(fuel,1))


@unsafe
def p173branch_18(store, id, start, count, fuel, p173test):
  match p173test:
    case True{}: p173r_pack(Bool,store,False{})
    case False{}:
      p173take_15(id,start,count,fuel,p173s_edge(store,start))
@unsafe
def p173branch_17(store, id, start, count, fuel, p173test):
  match p173test:
    case True{}: p173r_pack(Bool,store,True{})
    case False{}:
      p173branch_18(store,id,start,count,fuel,U32.is_eq(fuel,0))

@unsafe
def p173branch_24(store, id, n, edges, fuel, count, valid):
  match valid:
    case False{}: p173r_pack(Bool,store,False{})
    case True{}: p173s_valid_go(store,U32.inc(id),n,edges,U32.sub(U32.sub(fuel,1),count))


@unsafe
def p173branch_23(store, id, n, edges, fuel, start, count, p173test):
  match p173test:
    case False{}: p173r_pack(Bool,store,False{})
    case True{}:
      p173take_16(id,n,edges,fuel,count,p173s_valid_edges(store,id,start,count,fuel))
@unsafe
def p173branch_22(store, id, n, edges, fuel, node):
  match node:
    case P173Node{+shape,+start,+count}:
      p173branch_23(store,id,n,edges,fuel,start,count,U32.is_le(start,edges) && U32.is_le(count,U32.sub(edges,start)) && U32.is_le(count,U32.sub(fuel,1)))

@unsafe
def p173branch_21(store, id, n, edges, fuel, p173test):
  match p173test:
    case True{}: p173r_pack(Bool,store,False{})
    case False{}:
      p173take_17(id,n,edges,fuel,p173s_node(store,id))
@unsafe
def p173branch_20(store, id, n, edges, fuel, p173test):
  match p173test:
    case True{}: p173s_ok(store)
    case False{}:
      p173branch_21(store,id,n,edges,fuel,U32.is_eq(fuel,0))

@unsafe
def p173take_2(shape, start, pair):
  match pair:
    case P173Return{p173r_nodes,p173r_edges,+p173r_used,+p173r_edgeUsed,+p173r_nodeCapacity,+p173r_edgeCapacity,+p173r_ok,+count}:
      p173s_add_node(P173Store{p173r_nodes,p173r_edges,p173r_used,p173r_edgeUsed,p173r_nodeCapacity,p173r_edgeCapacity,p173r_ok},P173Node{shape,start,count})


@unsafe
def p173take_1(shape, ids, pair):
  match pair:
    case P173Return{p173r_nodes,p173r_edges,+p173r_used,+p173r_edgeUsed,+p173r_nodeCapacity,+p173r_edgeCapacity,+p173r_ok,+start}:
      p173take_2(shape,start,p173s_add_edges(P173Store{p173r_nodes,p173r_edges,p173r_used,p173r_edgeUsed,p173r_nodeCapacity,p173r_edgeCapacity,p173r_ok},ids,0))

@unsafe
def p173take_3(todo, values, fuel, pair):
  match pair:
    case P173Return{p173r_nodes,p173r_edges,+p173r_used,+p173r_edgeUsed,+p173r_nodeCapacity,+p173r_edgeCapacity,+p173r_ok,+id}:
      p173s_import_go(P173Store{p173r_nodes,p173r_edges,p173r_used,p173r_edgeUsed,p173r_nodeCapacity,p173r_edgeCapacity,p173r_ok},todo,Con{id,values},fuel)

@unsafe
def p173take_4(todo, values, fuel, pair):
  match pair:
    case P173Return{p173r_nodes,p173r_edges,+p173r_used,+p173r_edgeUsed,+p173r_nodeCapacity,+p173r_edgeCapacity,+p173r_ok,+node}:
      p173branch_9(P173Store{p173r_nodes,p173r_edges,p173r_used,p173r_edgeUsed,p173r_nodeCapacity,p173r_edgeCapacity,p173r_ok},todo,values,fuel,node)

@unsafe
def p173take_6(fuel, n, pair):
  match pair:
    case P173Return{p173r_nodes,p173r_edges,+p173r_used,+p173r_edgeUsed,+p173r_nodeCapacity,+p173r_edgeCapacity,+p173r_ok,+edges}:
      p173s_valid_go(P173Store{p173r_nodes,p173r_edges,p173r_used,p173r_edgeUsed,p173r_nodeCapacity,p173r_edgeCapacity,p173r_ok},0,n,edges,fuel)


@unsafe
def p173take_5(fuel, pair):
  match pair:
    case P173Return{p173r_nodes,p173r_edges,+p173r_used,+p173r_edgeUsed,+p173r_nodeCapacity,+p173r_edgeCapacity,+p173r_ok,+n}:
      p173take_6(fuel,n,p173s_edges_end(P173Store{p173r_nodes,p173r_edges,p173r_used,p173r_edgeUsed,p173r_nodeCapacity,p173r_edgeCapacity,p173r_ok}))

@unsafe
def p173take_7(edges, n, e, nc, ec, ok, pair):
  match pair:
    case Tuple{nodes,+value}:
      P173Return{nodes,edges,n,e,nc,ec,ok,value}

@unsafe
def p173take_8(nodes, n, e, nc, ec, ok, pair):
  match pair:
    case Tuple{edges,+value}:
      P173Return{nodes,edges,n,e,nc,ec,ok,value}

@unsafe
def p173take_9(values, rest, next, pair):
  match pair:
    case P173Return{p173r_nodes,p173r_edges,+p173r_used,+p173r_edgeUsed,+p173r_nodeCapacity,+p173r_edgeCapacity,+p173r_ok,+id}:
      p173s_import_go(P173Store{p173r_nodes,p173r_edges,p173r_used,p173r_edgeUsed,p173r_nodeCapacity,p173r_edgeCapacity,p173r_ok},rest,Con{id,values},next)

@unsafe
def p173take_10(todo, values, fuel, shape, start, count, pair):
  match pair:
    case P173Return{p173r_nodes,p173r_edges,+p173r_used,+p173r_edgeUsed,+p173r_nodeCapacity,+p173r_edgeCapacity,+p173r_ok,+kid}:
      p173s_export_go(P173Store{p173r_nodes,p173r_edges,p173r_used,p173r_edgeUsed,p173r_nodeCapacity,p173r_edgeCapacity,p173r_ok},Con{P173ExportVisit{kid},Con{P173ExportChildren{shape,start,1,count,[]},todo}},values,fuel)



@unsafe
def p173take_11(values, fuel, rest, shape, start, next, count, terms, term, pair):
  match pair:
    case P173Return{p173r_nodes,p173r_edges,+p173r_used,+p173r_edgeUsed,+p173r_nodeCapacity,+p173r_edgeCapacity,+p173r_ok,+kid}:
      p173s_export_go(P173Store{p173r_nodes,p173r_edges,p173r_used,p173r_edgeUsed,p173r_nodeCapacity,p173r_edgeCapacity,p173r_ok},Con{P173ExportVisit{kid},Con{P173ExportChildren{shape,start,U32.inc(next),count,Con{term,terms}},rest}},values,fuel)



@unsafe
def p173take_12(start, todo, left, pair):
  match pair:
    case P173Return{p173r_nodes,p173r_edges,+p173r_used,+p173r_edgeUsed,+p173r_nodeCapacity,+p173r_edgeCapacity,+p173r_ok,+id}:
      p173s_push_edges(P173Store{p173r_nodes,p173r_edges,p173r_used,p173r_edgeUsed,p173r_nodeCapacity,p173r_edgeCapacity,p173r_ok},start,left,Con{id,todo})



@unsafe
def p173take_13(acc, fuel, shape, pair):
  match pair:
    case P173Return{p173r_nodes,p173r_edges,+p173r_used,+p173r_edgeUsed,+p173r_nodeCapacity,+p173r_edgeCapacity,+p173r_ok,+todo}:
      p173branch_16(P173Store{p173r_nodes,p173r_edges,p173r_used,p173r_edgeUsed,p173r_nodeCapacity,p173r_edgeCapacity,p173r_ok},todo,acc,fuel,shape,p88_string_eq(p173s_shape_tag(shape),"Ref"))


@unsafe
def p173take_14(todo, acc, fuel, pair):
  match pair:
    case P173Return{p173r_nodes,p173r_edges,+p173r_used,+p173r_edgeUsed,+p173r_nodeCapacity,+p173r_edgeCapacity,+p173r_ok,+node}:
      p173branch_15(P173Store{p173r_nodes,p173r_edges,p173r_used,p173r_edgeUsed,p173r_nodeCapacity,p173r_edgeCapacity,p173r_ok},todo,acc,fuel,node)


@unsafe
def p173take_15(id, start, count, fuel, pair):
  match pair:
    case P173Return{p173r_nodes,p173r_edges,+p173r_used,+p173r_edgeUsed,+p173r_nodeCapacity,+p173r_edgeCapacity,+p173r_ok,+kid}:
      p173branch_19(P173Store{p173r_nodes,p173r_edges,p173r_used,p173r_edgeUsed,p173r_nodeCapacity,p173r_edgeCapacity,p173r_ok},id,start,count,fuel,kid,U32.is_lt(kid,id))


@unsafe
def p173take_16(id, n, edges, fuel, count, pair):
  match pair:
    case P173Return{p173r_nodes,p173r_edges,+p173r_used,+p173r_edgeUsed,+p173r_nodeCapacity,+p173r_edgeCapacity,+p173r_ok,+valid}:
      p173branch_24(P173Store{p173r_nodes,p173r_edges,p173r_used,p173r_edgeUsed,p173r_nodeCapacity,p173r_edgeCapacity,p173r_ok},id,n,edges,fuel,count,valid)


@unsafe
def p173take_17(id, n, edges, fuel, pair):
  match pair:
    case P173Return{p173r_nodes,p173r_edges,+p173r_used,+p173r_edgeUsed,+p173r_nodeCapacity,+p173r_edgeCapacity,+p173r_ok,+node}:
      p173branch_22(P173Store{p173r_nodes,p173r_edges,p173r_used,p173r_edgeUsed,p173r_nodeCapacity,p173r_edgeCapacity,p173r_ok},id,n,edges,fuel,node)


@unsafe
def p173match_1(values, store):
  match values:
    case Con{+id,+rest}: p173r_pack(U32,store,id)
    case Nil{}: p173r_pack(U32,p173s_fail(store),0)

@unsafe
def p173match_2(values, store):
  match values:
    case Con{+term,+rest}: p173r_pack(KTerm,store,term)
    case Nil{}: p173r_pack(KTerm,p173s_fail(store),atom("Absent"))

@unsafe
def p173match_5(kids, values, store, rest, next, shape, ids, id):
  match kids:
    case Nil{}:
      p173take_9(values,rest,next,p173s_emit(store,shape,nt_reverse(U32,Con{id,ids},[])))
    case Con{+kid,+kids}:
      p173s_import_go(store,Con{P173ImportVisit{kid},Con{P173ImportChildren{shape,kids,Con{id,ids}},rest}},values,next)



@unsafe
def p173match_4(values, store, rest, next, shape, kids, ids):
  match values:
    case Nil{}: p173r_pack(U32,p173s_fail(store),0)
    case Con{+id,+values}:
      p173match_5(kids,values,store,rest,next,shape,ids,id)

@unsafe
def p173match_3(frame, store, values, rest, next):
  match frame:
    case P173ImportVisit{+term}: p173s_import_visit(store,term,rest,values,next)
    case P173ImportChildren{+shape,+kids,+ids}:
      p173match_4(values,store,rest,next,shape,kids,ids)

@unsafe
def p173match_7(values, store, fuel, rest, shape, start, next, count, terms):
  match values:
    case Nil{}: p173r_pack(KTerm,p173s_fail(store),atom("Absent"))
    case Con{+term,+values}:
      p173branch_12(store,values,fuel,rest,shape,start,next,count,terms,term,U32.is_eq(next,count))


@unsafe
def p173match_6(frame, store, values, fuel, rest):
  match frame:
    case P173ExportVisit{+id}: p173s_export_visit(store,id,rest,values,fuel)
    case P173ExportChildren{+shape,+start,+next,+count,+terms}:
      p173match_7(values,store,fuel,rest,shape,start,next,count,terms)
