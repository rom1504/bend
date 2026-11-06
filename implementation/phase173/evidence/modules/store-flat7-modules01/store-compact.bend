# Exact indexed implementation of native literal compaction. All recursive
# consumers operate on IDs; KTerm exists only at store import/export boundaries.
type P173CompactFrame is Data:
  P173CompactVisit{id: U32}
  P173CompactChildren{+shape: P173Shape, +start: U32, +next: U32, +count: U32, +ids: List<&2,U32>}
  P173CompactSucc{count: U32}
  P173CompactString{+text: String}
  P173CompactStringJoin{head: U32}

type P173Decode is Data:
  P173Decode{valid: Bool, +value: U32, +fuel: U32}

type P173Succ is Data:
  P173Succ{tail: U32, +count: U32, +fuel: U32}

law p173match_8:
  for +values: List<&2,U32>
  for store: P173Store
  P173Store & U32

law p173match_9:
  for +shape: P173Shape
  for store: P173Store
  for +value: U32
  for +fuel: U32
  for +start: U32
  for +count: U32
  P173Store & P173Decode

law p173match_10:
  for +valid: Bool
  for store: P173Store
  for +shape: P173Shape
  for +start: U32
  for +count: U32
  for +todo: List<&2,P173CompactFrame>
  for +values: List<&2,U32>
  for +word: U32
  for +left: U32
  P173Store & U32

law p173match_11:
  for +shape: P173Shape
  for store: P173Store
  for +id: U32
  for +todo: List<&2,P173CompactFrame>
  for +values: List<&2,U32>
  for +fuel: U32
  for +start: U32
  for +count: U32
  P173Store & U32

law p173match_13:
  for +text: String
  for store: P173Store
  for +values: List<&2,U32>
  for +fuel: U32
  for +rest: List<&2,P173CompactFrame>
  P173Store & U32

law p173match_14:
  for +values: List<&2,U32>
  for store: P173Store
  for +fuel: U32
  for +rest: List<&2,P173CompactFrame>
  for +head: U32
  P173Store & U32

law p173match_15:
  for +values: List<&2,U32>
  for store: P173Store
  for +fuel: U32
  for +rest: List<&2,P173CompactFrame>
  for +count: U32
  P173Store & U32

law p173match_16:
  for +values: List<&2,U32>
  for store: P173Store
  for +fuel: U32
  for +rest: List<&2,P173CompactFrame>
  for +shape: P173Shape
  for +start: U32
  for +next: U32
  for +count: U32
  for +ids: List<&2,U32>
  P173Store & U32

law p173match_12:
  for +frame: P173CompactFrame
  for store: P173Store
  for +values: List<&2,U32>
  for +fuel: U32
  for +rest: List<&2,P173CompactFrame>
  P173Store & U32

law p173take_18:
  for +shape: P173Shape
  for +start: U32
  for +count: U32
  for +todo: List<&2,P173CompactFrame>
  for +values: List<&2,U32>
  for pair: P173Store & P173Decode
  P173Store & U32

law p173take_19:
  for +id: U32
  for +todo: List<&2,P173CompactFrame>
  for +values: List<&2,U32>
  for +fuel: U32
  for pair: P173Store & P173Node
  P173Store & U32

law p173take_20:
  for +value: U32
  for +fuel: U32
  for pair: P173Store & U32
  P173Store & P173Decode

law p173take_21:
  for +value: U32
  for +fuel: U32
  for pair: P173Store & P173Node
  P173Store & P173Decode

law p173take_22:
  for +bit: U32
  for +value: U32
  for +fuel: U32
  for +mask: U32
  for pair: P173Store & U32
  P173Store & P173Decode

law p173take_24:
  for +bit: U32
  for +value: U32
  for +fuel: U32
  for +start: U32
  for +count: U32
  for pair: P173Store & P173Node
  P173Store & P173Decode

law p173take_23:
  for +bit: U32
  for +value: U32
  for +fuel: U32
  for +node: P173Node
  for +start: U32
  for +count: U32
  for pair: P173Store & U32
  P173Store & P173Decode

law p173take_25:
  for +bit: U32
  for +value: U32
  for +fuel: U32
  for pair: P173Store & P173Node
  P173Store & P173Decode

law p173take_26:
  for +fuel: U32
  for pair: P173Store & U32
  P173Store & P173Decode

law p173take_27:
  for +amount: U32
  for +fuel: U32
  for pair: P173Store & U32
  P173Store & P173Succ

law p173take_28:
  for +id: U32
  for +amount: U32
  for +fuel: U32
  for pair: P173Store & P173Node
  P173Store & P173Succ

law p173take_29:
  for +todo: List<&2,P173CompactFrame>
  for +values: List<&2,U32>
  for +fuel: U32
  for pair: P173Store & U32
  P173Store & U32

law p173take_30:
  for +shape: P173Shape
  for +start: U32
  for +count: U32
  for +todo: List<&2,P173CompactFrame>
  for +values: List<&2,U32>
  for +fuel: U32
  for pair: P173Store & U32
  P173Store & U32

law p173take_32:
  for +todo: List<&2,P173CompactFrame>
  for +values: List<&2,U32>
  for +left: U32
  for pair: P173Store & P173Succ
  P173Store & U32

law p173take_31:
  for +todo: List<&2,P173CompactFrame>
  for +values: List<&2,U32>
  for +left: U32
  for pair: P173Store & U32
  P173Store & U32

law p173take_33:
  for +todo: List<&2,P173CompactFrame>
  for +values: List<&2,U32>
  for +left: U32
  for pair: P173Store & U32
  P173Store & U32

law p173take_34:
  for +todo: List<&2,P173CompactFrame>
  for +values: List<&2,U32>
  for +fuel: U32
  for pair: P173Store & U32
  P173Store & U32

law p173take_35:
  for +values: List<&2,U32>
  for +fuel: U32
  for +rest: List<&2,P173CompactFrame>
  for pair: P173Store & U32
  P173Store & U32

law p173take_36:
  for +values: List<&2,U32>
  for +fuel: U32
  for +rest: List<&2,P173CompactFrame>
  for +shape: P173Shape
  for +start: U32
  for +next: U32
  for +count: U32
  for +ids: List<&2,U32>
  for +id: U32
  for pair: P173Store & U32
  P173Store & U32

law p173take_37:
  for +values: List<&2,U32>
  for +fuel: U32
  for +rest: List<&2,P173CompactFrame>
  for pair: P173Store & U32
  P173Store & U32

law p173take_39:
  for +values: List<&2,U32>
  for +fuel: U32
  for +rest: List<&2,P173CompactFrame>
  for +tail: String
  for pair: P173Store & U32
  P173Store & U32

law p173take_38:
  for +values: List<&2,U32>
  for +fuel: U32
  for +rest: List<&2,P173CompactFrame>
  for +tail: String
  for pair: P173Store & U32
  P173Store & U32

law p173take_40:
  for +values: List<&2,U32>
  for +fuel: U32
  for +rest: List<&2,P173CompactFrame>
  for pair: P173Store & U32
  P173Store & U32

law p173take_41:
  for +values: List<&2,U32>
  for +fuel: U32
  for +rest: List<&2,P173CompactFrame>
  for pair: P173Store & U32
  P173Store & U32

law p173branch_25:
  for store: P173Store
  for +start: U32
  for +count: U32
  for +i: U32
  for +p173test: Bool
  P173Store & U32

law p173branch_28:
  for store: P173Store
  for +value: U32
  for +fuel: U32
  for +kind: String
  for +number: U32
  for +p173test: Bool
  P173Store & P173Decode

law p173branch_31:
  for store: P173Store
  for +value: U32
  for +fuel: U32
  for +start: U32
  for +count: U32
  for +name: String
  for +p173test: Bool
  P173Store & P173Decode

law p173branch_30:
  for store: P173Store
  for +value: U32
  for +fuel: U32
  for +start: U32
  for +count: U32
  for +name: String
  for +p173test: Bool
  P173Store & P173Decode

law p173branch_29:
  for store: P173Store
  for +value: U32
  for +fuel: U32
  for +start: U32
  for +count: U32
  for +tag: String
  for +name: String
  for +p173test: Bool
  P173Store & P173Decode

law p173branch_27:
  for store: P173Store
  for +value: U32
  for +fuel: U32
  for +node: P173Node
  P173Store & P173Decode

law p173branch_26:
  for store: P173Store
  for +id: U32
  for +value: U32
  for +fuel: U32
  for +p173test: Bool
  P173Store & P173Decode

law p173branch_37:
  for store: P173Store
  for +bit: U32
  for +value: U32
  for +fuel: U32
  for +start: U32
  for +count: U32
  for +hshape: P173Shape
  for +p173test: Bool
  P173Store & P173Decode

law p173branch_36:
  for store: P173Store
  for +bit: U32
  for +value: U32
  for +fuel: U32
  for +node: P173Node
  for +start: U32
  for +count: U32
  P173Store & P173Decode

law p173branch_35:
  for store: P173Store
  for +bit: U32
  for +value: U32
  for +fuel: U32
  for +node: P173Node
  for +shape: P173Shape
  for +start: U32
  for +count: U32
  for +p173test: Bool
  P173Store & P173Decode

law p173branch_34:
  for store: P173Store
  for +bit: U32
  for +value: U32
  for +fuel: U32
  for +node: P173Node
  for +shape: P173Shape
  for +start: U32
  for +count: U32
  for +p173test: Bool
  P173Store & P173Decode

law p173branch_33:
  for store: P173Store
  for +bit: U32
  for +value: U32
  for +fuel: U32
  for +node: P173Node
  P173Store & P173Decode

law p173branch_32:
  for store: P173Store
  for +id: U32
  for +bit: U32
  for +value: U32
  for +fuel: U32
  for +p173test: Bool
  P173Store & P173Decode

law p173branch_38:
  for store: P173Store
  for +id: U32
  for +shape: P173Shape
  for +start: U32
  for +count: U32
  for +fuel: U32
  for +p173test: Bool
  P173Store & P173Decode

law p173branch_41:
  for store: P173Store
  for +id: U32
  for +amount: U32
  for +fuel: U32
  for +shape: P173Shape
  for +start: U32
  for +count: U32
  for +p173test: Bool
  P173Store & P173Succ

law p173branch_40:
  for store: P173Store
  for +id: U32
  for +amount: U32
  for +fuel: U32
  for +node: P173Node
  P173Store & P173Succ

law p173branch_39:
  for store: P173Store
  for +id: U32
  for +amount: U32
  for +fuel: U32
  for +p173test: Bool
  P173Store & P173Succ

law p173branch_42:
  for store: P173Store
  for +shape: P173Shape
  for +start: U32
  for +count: U32
  for +todo: List<&2,P173CompactFrame>
  for +values: List<&2,U32>
  for +fuel: U32
  for +p173test: Bool
  P173Store & U32

law p173branch_45:
  for store: P173Store
  for +todo: List<&2,P173CompactFrame>
  for +values: List<&2,U32>
  for +left: U32
  for +scanned: P173Succ
  P173Store & U32

law p173branch_44:
  for store: P173Store
  for +shape: P173Shape
  for +start: U32
  for +count: U32
  for +todo: List<&2,P173CompactFrame>
  for +values: List<&2,U32>
  for +left: U32
  for +p173test: Bool
  P173Store & U32

law p173branch_43:
  for store: P173Store
  for +shape: P173Shape
  for +start: U32
  for +count: U32
  for +todo: List<&2,P173CompactFrame>
  for +values: List<&2,U32>
  for +decoded: P173Decode
  P173Store & U32

law p173branch_47:
  for store: P173Store
  for +todo: List<&2,P173CompactFrame>
  for +values: List<&2,U32>
  for +fuel: U32
  for +kind: String
  for +number: U32
  for +text: String
  for +p173test: Bool
  P173Store & U32

law p173branch_49:
  for store: P173Store
  for +id: U32
  for +todo: List<&2,P173CompactFrame>
  for +values: List<&2,U32>
  for +fuel: U32
  for +shape: P173Shape
  for +start: U32
  for +count: U32
  for +tag: String
  for +p173test: Bool
  P173Store & U32

law p173branch_48:
  for store: P173Store
  for +id: U32
  for +todo: List<&2,P173CompactFrame>
  for +values: List<&2,U32>
  for +fuel: U32
  for +shape: P173Shape
  for +start: U32
  for +count: U32
  for +tag: String
  for +name: String
  for +n: U32
  for +q: U32
  for +removed: List<&2,String>
  for +b: U32
  for +e: U32
  for +p173test: Bool
  P173Store & U32

law p173branch_46:
  for store: P173Store
  for +id: U32
  for +todo: List<&2,P173CompactFrame>
  for +values: List<&2,U32>
  for +fuel: U32
  for +node: P173Node
  P173Store & U32

law p173branch_51:
  for store: P173Store
  for +values: List<&2,U32>
  for +fuel: U32
  for +rest: List<&2,P173CompactFrame>
  for +shape: P173Shape
  for +start: U32
  for +next: U32
  for +count: U32
  for +ids: List<&2,U32>
  for +id: U32
  for +p173test: Bool
  P173Store & U32

law p173branch_50:
  for store: P173Store
  for +values: List<&2,U32>
  for +fuel: U32
  for +frame: P173CompactFrame
  for +rest: List<&2,P173CompactFrame>
  for +p173test: Bool
  P173Store & U32

law p173c_go:
  for store: P173Store
  for +todo: List<&2,P173CompactFrame>
  for +values: List<&2,U32>
  for +fuel: U32
  P173Store & U32

@unsafe
def p173c_clear(+shape: P173Shape) -> P173Shape:
  match shape:
    case P173Term{+tag,+name,+id,+q,+removed,+b,+e}: P173Term{tag,name,id,q,[],0,0}
    case P173Lambda{+name,+id,+q,+removed,+b,+e,+p}: P173Lambda{name,id,q,[],0,0,p}
    case P173Literal{+kind,+n,+text,+b,+e}: P173Literal{kind,n,text,b,e}

@unsafe
def p173c_kid(store: P173Store, +start: U32, +count: U32, +i: U32) -> P173Store & U32:
  p173branch_25(store,start,count,i,U32.is_lt(i,count))
@unsafe
def p173c_word_emit(store: P173Store, +word: U32) -> P173Store & U32:
  p173s_emit(store,P173Term{"NWord",U32.show(word),0,0,[],0,0},[])

@unsafe
def p173c_nat(store: P173Store, +id: U32, +value: U32, +fuel: U32) -> P173Store & P173Decode:
  p173branch_26(store,id,value,fuel,U32.is_eq(fuel,0))
@unsafe
def p173c_word(store: P173Store, +id: U32, +bit: U32, +value: U32, +fuel: U32) -> P173Store & P173Decode:
  p173branch_32(store,id,bit,value,fuel,U32.is_eq(fuel,0))
@unsafe
def p173c_decode(store: P173Store, +id: U32, +shape: P173Shape, +start: U32, +count: U32, +fuel: U32) -> P173Store & P173Decode:
  p173branch_38(store,id,shape,start,count,fuel,p88_string_eq(p173s_shape_name(shape),"U32") || p88_string_eq(p173s_shape_name(shape),"F32"))
@unsafe
def p173c_succ_scan(store: P173Store, +id: U32, +amount: U32, +fuel: U32) -> P173Store & P173Succ:
  p173branch_39(store,id,amount,fuel,U32.is_eq(fuel,0))
@unsafe
def p173c_children(store: P173Store, +shape: P173Shape, +start: U32, +count: U32, +todo: List<&2,P173CompactFrame>, +values: List<&2,U32>, +fuel: U32) -> P173Store & U32:
  p173branch_42(store,shape,start,count,todo,values,fuel,U32.is_eq(count,0))
@unsafe
def p173c_constructor(store: P173Store, +id: U32, +shape: P173Shape, +start: U32, +count: U32, +todo: List<&2,P173CompactFrame>, +values: List<&2,U32>, +fuel: U32) -> P173Store & U32:
  p173take_18(shape,start,count,todo,values,p173c_decode(store,id,shape,start,count,fuel))
@unsafe
def p173c_visit(store: P173Store, +id: U32, +todo: List<&2,P173CompactFrame>, +values: List<&2,U32>, +fuel: U32) -> P173Store & U32:
  p173take_19(id,todo,values,fuel,p173s_node(store,id))
@unsafe
def p173c_go(store, todo, values, fuel):
  match todo:
    case Nil{}:
      p173match_8(values,store)
    case Con{+frame,+rest}:
      p173branch_50(store,values,fuel,frame,rest,U32.is_eq(fuel,0))
@unsafe
def p173s_compact(store: P173Store, +id: U32, +fuel: U32) -> P173Store & U32:
  p173c_go(store,[P173CompactVisit{id}],[],fuel)

@unsafe
def p173branch_25(store, start, count, i, p173test):
  match p173test:
    case True{}: p173s_edge(store,U32.add(start,i))
    case False{}: (store,0)


@unsafe
def p173branch_28(store, value, fuel, kind, number, p173test):
  match p173test:
    case True{}: (store,P173Decode{True{},U32.add(value,number),U32.sub(fuel,1)})
    case False{}: (store,P173Decode{False{},0,U32.sub(fuel,1)})

@unsafe
def p173branch_31(store, value, fuel, start, count, name, p173test):
  match p173test:
    case False{}: (store,P173Decode{False{},0,U32.sub(fuel,1)})
    case True{}:
      p173take_20(value,fuel,p173c_kid(store,start,count,0))
@unsafe
def p173branch_30(store, value, fuel, start, count, name, p173test):
  match p173test:
    case True{}: (store,P173Decode{True{},value,U32.sub(fuel,1)})
    case False{}:
      p173branch_31(store,value,fuel,start,count,name,p88_string_eq(name,"Succ"))

@unsafe
def p173branch_29(store, value, fuel, start, count, tag, name, p173test):
  match p173test:
    case False{}: (store,P173Decode{False{},0,U32.sub(fuel,1)})
    case True{}:
      p173branch_30(store,value,fuel,start,count,name,p88_string_eq(name,"Zero"))

@unsafe
def p173branch_27(store, value, fuel, node):
  match node:
    case P173Node{+shape,+start,+count}:
      p173match_9(shape,store,value,fuel,start,count)
@unsafe
def p173branch_26(store, id, value, fuel, p173test):
  match p173test:
    case True{}: (p173s_fail(store),P173Decode{False{},0,0})
    case False{}:
      p173take_21(value,fuel,p173s_node(store,id))
@unsafe
def p173branch_37(store, bit, value, fuel, start, count, hshape, p173test):
  match p173test:
    case False{}: (store,P173Decode{False{},0,U32.sub(fuel,1)})
    case True{}:
      +flag = p88_string_eq(p173s_shape_name(hshape),"True")
      +mask = kc(U32,flag,u => U32.shln(1,U32.to_nat(bit)),u => 0)
      p173take_22(bit,value,fuel,mask,p173c_kid(store,start,count,1))
@unsafe
def p173branch_36(store, bit, value, fuel, node, start, count):
  match node:
    case P173Node{+hshape,+hs,+hc}:
      p173branch_37(store,bit,value,fuel,start,count,hshape,p88_string_eq(p173s_shape_tag(hshape),"Ctr") && (p88_string_eq(p173s_shape_name(hshape),"True") || p88_string_eq(p173s_shape_name(hshape),"False")))

@unsafe
def p173branch_35(store, bit, value, fuel, node, shape, start, count, p173test):
  match p173test:
    case False{}: (store,P173Decode{False{},0,U32.sub(fuel,1)})
    case True{}:
      p173take_23(bit,value,fuel,node,start,count,p173c_kid(store,start,count,0))
@unsafe
def p173branch_34(store, bit, value, fuel, node, shape, start, count, p173test):
  match p173test:
    case True{}: (store,P173Decode{True{},value,U32.sub(fuel,1)})
    case False{}:
      p173branch_35(store,bit,value,fuel,node,shape,start,count,p88_string_eq(p173s_shape_tag(shape),"Ctr") && p88_string_eq(p173s_shape_name(shape),"WCon") && U32.is_lt(bit,32))

@unsafe
def p173branch_33(store, bit, value, fuel, node):
  match node:
    case P173Node{+shape,+start,+count}:
      p173branch_34(store,bit,value,fuel,node,shape,start,count,p88_string_eq(p173s_shape_tag(shape),"Ctr") && p88_string_eq(p173s_shape_name(shape),"WNil"))

@unsafe
def p173branch_32(store, id, bit, value, fuel, p173test):
  match p173test:
    case True{}: (p173s_fail(store),P173Decode{False{},0,0})
    case False{}:
      p173take_25(bit,value,fuel,p173s_node(store,id))
@unsafe
def p173branch_38(store, id, shape, start, count, fuel, p173test):
  match p173test:
    case True{}:
      p173take_26(fuel,p173c_kid(store,start,count,0))
    case False{}: p173c_nat(store,id,0,fuel)


@unsafe
def p173branch_41(store, id, amount, fuel, shape, start, count, p173test):
  match p173test:
    case True{}:
      p173take_27(amount,fuel,p173c_kid(store,start,count,0))
    case False{}: (store,P173Succ{id,amount,U32.sub(fuel,1)})


@unsafe
def p173branch_40(store, id, amount, fuel, node):
  match node:
    case P173Node{+shape,+start,+count}:
      p173branch_41(store,id,amount,fuel,shape,start,count,p88_string_eq(p173s_shape_tag(shape),"Ctr") && p88_string_eq(p173s_shape_name(shape),"Succ") && U32.is_eq(count,1) && U32.is_lt(amount,4294967295))

@unsafe
def p173branch_39(store, id, amount, fuel, p173test):
  match p173test:
    case True{}: (p173s_fail(store),P173Succ{id,amount,0})
    case False{}:
      p173take_28(id,amount,fuel,p173s_node(store,id))
@unsafe
def p173branch_42(store, shape, start, count, todo, values, fuel, p173test):
  match p173test:
    case True{}:
      p173take_29(todo,values,fuel,p173s_emit(store,p173c_clear(shape),[]))
    case False{}:
      p173take_30(shape,start,count,todo,values,fuel,p173s_edge(store,start))
@unsafe
def p173branch_45(store, todo, values, left, scanned):
  match scanned:
    case P173Succ{+tail,+amount,+left}:
      p173c_go(store,Con{P173CompactVisit{tail},Con{P173CompactSucc{amount},todo}},values,left)


@unsafe
def p173branch_44(store, shape, start, count, todo, values, left, p173test):
  match p173test:
    case False{}: p173c_children(store,shape,start,count,todo,values,left)
    case True{}:
      p173take_31(todo,values,left,p173c_kid(store,start,count,0))
@unsafe
def p173branch_43(store, shape, start, count, todo, values, decoded):
  match decoded:
    case P173Decode{+valid,+word,+left}:
      p173match_10(valid,store,shape,start,count,todo,values,word,left)
@unsafe
def p173branch_47(store, todo, values, fuel, kind, number, text, p173test):
  match p173test:
    case True{}: p173c_go(store,Con{P173CompactString{text},todo},values,fuel)
    case False{}:
      p173take_34(todo,values,fuel,p173c_word_emit(store,number))
@unsafe
def p173branch_49(store, id, todo, values, fuel, shape, start, count, tag, p173test):
  match p173test:
    case True{}: p173c_constructor(store,id,shape,start,count,todo,values,fuel)
    case False{}: p173c_children(store,shape,start,count,todo,values,fuel)


@unsafe
def p173branch_48(store, id, todo, values, fuel, shape, start, count, tag, name, n, q, removed, b, e, p173test):
  match p173test:
    case True{}: p173c_go(store,todo,Con{id,values},fuel)
    case False{}:
      +shape : P173Shape = P173Term{tag,name,n,q,removed,b,e}
      p173branch_49(store,id,todo,values,fuel,shape,start,count,tag,p88_string_eq(tag,"Ctr"))

@unsafe
def p173branch_46(store, id, todo, values, fuel, node):
  match node:
    case P173Node{+shape,+start,+count}:
      p173match_11(shape,store,id,todo,values,fuel,start,count)
@unsafe
def p173branch_51(store, values, fuel, rest, shape, start, next, count, ids, id, p173test):
  match p173test:
    case True{}:
      p173take_35(values,fuel,rest,p173s_emit(store,p173c_clear(shape),nt_reverse(U32,Con{id,ids},[])))
    case False{}:
      p173take_36(values,fuel,rest,shape,start,next,count,ids,id,p173s_edge(store,U32.add(start,next)))
@unsafe
def p173branch_50(store, values, fuel, frame, rest, p173test):
  match p173test:
    case True{}: (p173s_fail(store),0)
    case False{}:
      +fuel = U32.sub(fuel,1)
      p173match_12(frame,store,values,fuel,rest)
@unsafe
def p173take_18(shape, start, count, todo, values, pair):
  match pair:
    case Tuple{store,+decoded}:
      p173branch_43(store,shape,start,count,todo,values,decoded)

@unsafe
def p173take_19(id, todo, values, fuel, pair):
  match pair:
    case Tuple{store,+node}:
      p173branch_46(store,id,todo,values,fuel,node)

@unsafe
def p173take_20(value, fuel, pair):
  match pair:
    case Tuple{store,+kid}:
      p173c_nat(store,kid,U32.inc(value),U32.sub(fuel,1))



@unsafe
def p173take_21(value, fuel, pair):
  match pair:
    case Tuple{store,+node}:
      p173branch_27(store,value,fuel,node)


@unsafe
def p173take_22(bit, value, fuel, mask, pair):
  match pair:
    case Tuple{store,+tail}:
      p173c_word(store,tail,U32.inc(bit),U32.or(value,mask),U32.sub(fuel,1))



@unsafe
def p173take_24(bit, value, fuel, start, count, pair):
  match pair:
    case Tuple{store,+node}:
      p173branch_36(store,bit,value,fuel,node,start,count)


@unsafe
def p173take_23(bit, value, fuel, node, start, count, pair):
  match pair:
    case Tuple{store,+head}:
      p173take_24(bit,value,fuel,start,count,p173s_node(store,head))

@unsafe
def p173take_25(bit, value, fuel, pair):
  match pair:
    case Tuple{store,+node}:
      p173branch_33(store,bit,value,fuel,node)


@unsafe
def p173take_26(fuel, pair):
  match pair:
    case Tuple{store,+kid}:
      p173c_word(store,kid,0,0,fuel)

@unsafe
def p173take_27(amount, fuel, pair):
  match pair:
    case Tuple{store,+kid}:
      p173c_succ_scan(store,kid,U32.inc(amount),U32.sub(fuel,1))

@unsafe
def p173take_28(id, amount, fuel, pair):
  match pair:
    case Tuple{store,+node}:
      p173branch_40(store,id,amount,fuel,node)


@unsafe
def p173take_29(todo, values, fuel, pair):
  match pair:
    case Tuple{store,+id}:
      p173c_go(store,todo,Con{id,values},fuel)

@unsafe
def p173take_30(shape, start, count, todo, values, fuel, pair):
  match pair:
    case Tuple{store,+kid}:
      p173c_go(store,Con{P173CompactVisit{kid},Con{P173CompactChildren{shape,start,1,count,[]},todo}},values,fuel)



@unsafe
def p173take_32(todo, values, left, pair):
  match pair:
    case Tuple{store,+scanned}:
      p173branch_45(store,todo,values,left,scanned)


@unsafe
def p173take_31(todo, values, left, pair):
  match pair:
    case Tuple{store,+kid}:
      p173take_32(todo,values,left,p173c_succ_scan(store,kid,1,left))

@unsafe
def p173take_33(todo, values, left, pair):
  match pair:
    case Tuple{store,+result}:
      p173c_go(store,todo,Con{result,values},left)

@unsafe
def p173take_34(todo, values, fuel, pair):
  match pair:
    case Tuple{store,+result}:
      p173c_go(store,todo,Con{result,values},fuel)


@unsafe
def p173take_35(values, fuel, rest, pair):
  match pair:
    case Tuple{store,+result}:
      p173c_go(store,rest,Con{result,values},fuel)

@unsafe
def p173take_36(values, fuel, rest, shape, start, next, count, ids, id, pair):
  match pair:
    case Tuple{store,+kid}:
      p173c_go(store,Con{P173CompactVisit{kid},Con{P173CompactChildren{shape,start,U32.inc(next),count,Con{id,ids}},rest}},values,fuel)



@unsafe
def p173take_37(values, fuel, rest, pair):
  match pair:
    case Tuple{store,+id}:
      p173c_go(store,rest,Con{id,values},fuel)

@unsafe
def p173take_39(values, fuel, rest, tail, pair):
  match pair:
    case Tuple{store,+chr}:
      p173c_go(store,Con{P173CompactString{tail},Con{P173CompactStringJoin{chr},rest}},values,fuel)

@unsafe
def p173take_38(values, fuel, rest, tail, pair):
  match pair:
    case Tuple{store,+word}:
      p173take_39(values,fuel,rest,tail,p173s_emit(store,P173Term{"Ctr","Chr",0,1,[],0,0},[word]))

@unsafe
def p173take_40(values, fuel, rest, pair):
  match pair:
    case Tuple{store,+id}:
      p173c_go(store,rest,Con{id,values},fuel)

@unsafe
def p173take_41(values, fuel, rest, pair):
  match pair:
    case Tuple{store,+id}:
      p173c_go(store,rest,Con{id,values},fuel)

@unsafe
def p173match_8(values, store):
  match values:
    case Con{+id,+rest}: (store,id)
    case Nil{}: (p173s_fail(store),0)

@unsafe
def p173match_9(shape, store, value, fuel, start, count):
  match shape:
    case P173Literal{+kind,+number,+text,+b,+e}:
      p173branch_28(store,value,fuel,kind,number,p88_string_eq(kind,"Nat") && U32.is_le(number,U32.sub(4294967295,value)))
    case P173Lambda{+name,+n,+q,+removed,+b,+e,+p}: (store,P173Decode{False{},0,U32.sub(fuel,1)})
    case P173Term{+tag,+name,+n,+q,+removed,+b,+e}:
      p173branch_29(store,value,fuel,start,count,tag,name,p88_string_eq(tag,"Ctr"))


@unsafe
def p173match_10(valid, store, shape, start, count, todo, values, word, left):
  match valid:
    case True{}:
      p173take_33(todo,values,left,p173c_word_emit(store,word))
    case False{}:
      p173branch_44(store,shape,start,count,todo,values,left,p88_string_eq(p173s_shape_name(shape),"Succ") && U32.is_eq(count,1))


@unsafe
def p173match_11(shape, store, id, todo, values, fuel, start, count):
  match shape:
    case P173Literal{+kind,+number,+text,+b,+e}:
      p173branch_47(store,todo,values,fuel,kind,number,text,p88_string_eq(kind,"String"))
    case P173Lambda{+name,+n,+q,+removed,+b,+e,+p}:
      p173c_children(store,P173Lambda{name,n,q,removed,b,e,p},start,count,todo,values,fuel)
    case P173Term{+tag,+name,+n,+q,+removed,+b,+e}:
      p173branch_48(store,id,todo,values,fuel,shape,start,count,tag,name,n,q,removed,b,e,p88_string_eq(tag,"NStatic"))


@unsafe
def p173match_13(text, store, values, fuel, rest):
  match text:
    case SNil{}:
      p173take_37(values,fuel,rest,p173s_emit(store,P173Term{"Ctr","SNil",0,1,[],0,0},[]))
    case SCon{+head,+tail}:
      p173take_38(values,fuel,rest,tail,p173c_word_emit(store,Char.to_u32(head)))

@unsafe
def p173match_14(values, store, fuel, rest, head):
  match values:
    case Nil{}: (p173s_fail(store),0)
    case Con{+tail,+values}:
      p173take_40(values,fuel,rest,p173s_emit(store,P173Term{"Ctr","SCon",0,1,[],0,0},[head,tail]))

@unsafe
def p173match_15(values, store, fuel, rest, count):
  match values:
    case Nil{}: (p173s_fail(store),0)
    case Con{+kid,+values}:
      +shape = kc(P173Shape,U32.is_eq(count,1),u => P173Term{"Ctr","Succ",0,0,[],0,0},u => P173Term{"NNatAdd",U32.show(U32.sub(count,1)),0,0,[],0,0})
      p173take_41(values,fuel,rest,p173s_emit(store,shape,[kid]))

@unsafe
def p173match_16(values, store, fuel, rest, shape, start, next, count, ids):
  match values:
    case Nil{}: (p173s_fail(store),0)
    case Con{+id,+values}:
      p173branch_51(store,values,fuel,rest,shape,start,next,count,ids,id,U32.is_eq(next,count))


@unsafe
def p173match_12(frame, store, values, fuel, rest):
  match frame:
    case P173CompactVisit{+id}: p173c_visit(store,id,rest,values,fuel)
    case P173CompactString{+text}:
      p173match_13(text,store,values,fuel,rest)
    case P173CompactStringJoin{+head}:
      p173match_14(values,store,fuel,rest,head)
    case P173CompactSucc{+count}:
      p173match_15(values,store,fuel,rest,count)
    case P173CompactChildren{+shape,+start,+next,+count,+ids}:
      p173match_16(values,store,fuel,rest,shape,start,next,count,ids)
