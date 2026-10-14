import Base

type KTerm is Data:
  KTerm{+tag: String, +name: String, +id: U32, +quant: U32, +kids: List<&2, KTerm>, +removed: List<&2, String>, +originBegin: U32, +originEnd: U32}
  KLambda{+name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +removed: List<&2,String>, +originBegin: U32, +originEnd: U32, +quantityPresent: Bool}
  KLiteral{+kind: String, +number: U32, +text: String, +originBegin: U32, +originEnd: U32}

type KDef is Data:
  KDef{+name: String, +kind: String, +arity: U32, +templates: U32, +typ: KTerm, +value: KTerm, +ctors: List<&2, KDef>, +native: Bool, +unsafe: Bool}
  KIndexLeaf{+hash: U32, +bucket: List<&2,KDef>}
  KIndexNode{+hash: U32, +mask: U32, +left: KDef, +right: KDef}

type KBasePrefixState is Data:
  KBasePrefixState{+bound: U32, +delta: U32, +stamp: U32, +patches: List<&2,KDef>, +ready: Bool}

type KBasePreparedWorld is Data:
  KBasePreparedWorld{+state: KBasePrefixState, +prefix: List<&2,KDef>, +final: List<&2,KDef>, +book: List<&2,KDef>, +checked: List<&2,KDef>, +seen: List<&2,KDef>, +todos: U32, +checkedBound: U32}

type FFreshPrefixState is Data:
  FFreshPrefixState{+next: U32, +ready: Bool}

type FReadyPrefixState is Data:
  FReadyPrefixState{+names: KDef, +ctors: KDef, +count: U32, +ready: Bool}

# PRIVATE Phase88 transport experiment, not a public checker permission.
# Caller must authenticate the complete carrier and its producer/Base receipt.
# The stamp checked here is routing metadata, not a cryptographic certificate.
# Constructors are reconstructed in Bend; no native layouts or closures enter.

type P88Node is Data:
  P88Bad{}
  P88Empty{}
  P88Word{+value: U32}
  P88Bool{+value: Bool}
  P88String{+value: String}
  P88Term{+value: KTerm}
  P88Def{+value: KDef}
  P88Terms{+value: List<&2,KTerm>}
  P88Defs{+value: List<&2,KDef>}
  P88Strings{+value: List<&2,String>}
  P88Checked{+value: KBasePrefixState}
  P88Fresh{+value: FFreshPrefixState}
  P88World{+value: KBasePreparedWorld}
  P88Frontend{+value: FReadyPrefixState}

type P88Cursor is Data:
  P88Cursor{+text: String, +ok: Bool}
type P88Number is Data:
  P88Number{+cursor: P88Cursor, +value: U32}
type P88TextRead is Data:
  P88TextRead{+cursor: P88Cursor, +value: String}
type P88State is Type:
  P88State{cursor: P88Cursor, nodes: Array<P88Node>, strings: Array<String>, +made: U32, +sn: U32, +begin: U32, +end: U32}
type P88Step is Type:
  P88Step{state: P88State, value: P88Node}
type P88Products is Data:
  P88Products{+book: List<&2,KDef>, +fresh: FFreshPrefixState, +ready: FReadyPrefixState, +world: KBasePreparedWorld}
type P88Decoded is Data:
  P88DecodeError{+error: String}
  P88DecodeReady{+products: P88Products}

# Bounded decimal integers, canonical spelling, no arithmetic wraparound.
@unsafe
def p88_u32(cursor: P88Cursor) -> P88Number:
  match cursor:
    case P88Cursor{text, True{}}: p88_digits(text, 0, 0)
    case other: P88Number{P88Cursor{"", False{}}, 0}

@unsafe
def p88_digits(text: String, +acc: U32, +digits: U32) -> P88Number:
  match text:
    case SCon{'\n', tail}: P88Number{P88Cursor{tail, U32.is_ne(digits, 0)}, acc}
    case SCon{Chr{c}, tail}:
      +d = U32.sub(c, 48)
      p88_digit(tail, acc, digits, d, U32.is_lt(d, 10) && U32.is_lt(digits, 10) && (U32.is_eq(digits, 0) || U32.is_ne(acc, 0)) && (U32.is_lt(acc, 429496729) || (U32.is_eq(acc, 429496729) && U32.is_le(d, 5))))
    case other: P88Number{P88Cursor{"", False{}}, 0}

@unsafe
def p88_digit(text: String, acc: U32, digits: U32, digit: U32, ok: Bool) -> P88Number:
  match ok:
    case True{}: p88_digits(text, U32.add(U32.mul(acc, 10), digit), U32.inc(digits))
    case False{}: P88Number{P88Cursor{"", False{}}, 0}

@unsafe
def p88_text(cursor: P88Cursor) -> P88TextRead:
  p88_text_size(p88_u32(cursor))

@unsafe
def p88_text_size(read: P88Number) -> P88TextRead:
  match read:
    case P88Number{P88Cursor{text, +ok}, +size}:
      p88_text_gate(text, size, ok && U32.is_le(size, 1048576))

@unsafe
def p88_text_gate(text: String, size: U32, ok: Bool) -> P88TextRead:
  match ok:
    case True{}: p88_text_chars(size, text, "")
    case False{}: P88TextRead{P88Cursor{"", False{}}, ""}

@unsafe
def p88_text_chars(size: U32, text: String, acc: String) -> P88TextRead:
  match size text:
    case 0 SCon{'\n', tail}: P88TextRead{P88Cursor{tail, True{}}, String.reverse(acc)}
    case 0 other: P88TextRead{P88Cursor{"", False{}}, ""}
    case n SCon{Chr{+c}, tail}:
      p88_text_char(tail, U32.sub(n, 1), SCon{Chr{c}, acc}, U32.is_le(c, 1114111) && (U32.is_lt(c, 55296) || U32.is_gt(c, 57343)))
    case n other: P88TextRead{P88Cursor{"", False{}}, ""}

@unsafe
def p88_text_char(text: String, size: U32, acc: String, ok: Bool) -> P88TextRead:
  match ok:
    case True{}: p88_text_chars(size, text, acc)
    case False{}: P88TextRead{P88Cursor{"", False{}}, ""}

@unsafe
def p88_state_bad(state: P88State) -> P88State:
  match state:
    case P88State{cursor, nodes, strings, made, sn, begin, end}:
      P88State{P88Cursor{"", False{}}, nodes, strings, made, sn, begin, end}

@unsafe
def p88_number(state: P88State) -> P88Step:
  match state:
    case P88State{cursor, nodes, strings, made, sn, begin, end}:
      p88_number_read(nodes, strings, made, sn, begin, end, p88_u32(cursor))

@unsafe
def p88_number_read(nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, read: P88Number) -> P88Step:
  match read:
    case P88Number{P88Cursor{text,True{}}, n}: P88Step{P88State{P88Cursor{text,True{}}, nodes, strings, made, sn, begin, end}, P88Word{n}}
    case other: P88Step{P88State{P88Cursor{"",False{}},nodes,strings,made,sn,begin,end},P88Bad{}}

# Role1 word,2 Bool,3 String,4 term,5 def,6 terms,7 defs,8 strings,
# 9 checked,10 fresh,11 world,12 frontend,13 Con head,14 Con tail.
@unsafe
def p88_roles(tag: U32) -> List<&2,U32>:
  match tag:
    case 0: []
    case 1: [13,14]
    case 2: [3,3,1,1,6,8,1,1]
    case 3: [3,1,1,6,8,1,1,2]
    case 4: [3,1,3,1,1]
    case 5: [3,3,1,1,4,4,7,2,2]
    case 6: [1,7]
    case 7: [1,1,5,5]
    case 8: [1,1,1,7,2]
    case 9: [1,2]
    case 10: [9,7,7,7,7,7,1,1]
    case 11: [5,5,1,2]
    case other: []

@unsafe
def p88_role_empty(role: U32, node: P88Node) -> P88Node:
  match role node:
    case 6 P88Empty{}: P88Terms{Nil{}}
    case 7 P88Empty{}: P88Defs{Nil{}}
    case 8 P88Empty{}: P88Strings{Nil{}}
    case r n: n

@unsafe
def p88_field(state: P88State, role: U32) -> P88Step:
  p88_field_number(p88_number(state), role)

@unsafe
def p88_field_number(step: P88Step, role: U32) -> P88Step:
  match step:
    case P88Step{state, P88Word{+n}}:
      match role:
        case 1: P88Step{state, P88Word{n}}
        case 2: p88_bool_value(state,n)
        case 3: p88_string_at(state, n)
        case 13: p88_head_at(state, n, U32.is_ge(n, 2147483648))
        case other: p88_node_at(state, n, role)
    case P88Step{state, other}: P88Step{p88_state_bad(state), P88Bad{}}

@unsafe
def p88_bool_value(state: P88State, n: U32) -> P88Step:
  match n:
    case 0: P88Step{state,P88Bool{False{}}}
    case 1: P88Step{state,P88Bool{True{}}}
    case other: P88Step{p88_state_bad(state),P88Bad{}}

@unsafe
def p88_head_at(state: P88State, n: U32, string: Bool) -> P88Step:
  match string:
    case True{}: p88_string_at(state, U32.sub(n, 2147483648))
    case False{}: p88_node_at(state, n, 13)

@unsafe
def p88_node_at(state: P88State, +id: U32, role: U32) -> P88Step:
  match state:
    case P88State{cursor, nodes, strings, +made, sn, begin, end}:
      p88_node_gate(cursor, nodes, strings, made, sn, begin, end, id, role, U32.is_lt(id, made))

@unsafe
def p88_node_gate(cursor: P88Cursor, nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, id: U32, role: U32, ok: Bool) -> P88Step:
  match ok:
    case False{}: P88Step{P88State{P88Cursor{"", False{}}, nodes, strings, made, sn, begin, end}, P88Bad{}}
    case True{}: p88_node_got(cursor, strings, made, sn, begin, end, role, Array.get(P88Node, nodes, id))

@unsafe
def p88_node_got(cursor: P88Cursor, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, role: U32, pair: Array<P88Node> & P88Node) -> P88Step:
  (nodes, node) = pair
  P88Step{P88State{cursor, nodes, strings, made, sn, begin, end}, p88_role_empty(role, node)}

@unsafe
def p88_string_at(state: P88State, +id: U32) -> P88Step:
  match state:
    case P88State{cursor, nodes, strings, made, +sn, begin, end}:
      p88_string_gate(cursor, nodes, strings, made, sn, begin, end, id, U32.is_lt(id, sn))

@unsafe
def p88_string_gate(cursor: P88Cursor, nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, id: U32, ok: Bool) -> P88Step:
  match ok:
    case False{}: P88Step{P88State{P88Cursor{"", False{}}, nodes, strings, made, sn, begin, end}, P88Bad{}}
    case True{}: p88_string_got(cursor, nodes, made, sn, begin, end, Array.get(String, strings, id))

@unsafe
def p88_string_got(cursor: P88Cursor, nodes: Array<P88Node>, made: U32, sn: U32, begin: U32, end: U32, pair: Array<String> & String) -> P88Step:
  (strings, text) = pair
  P88Step{P88State{cursor, nodes, strings, made, sn, begin, end}, P88String{text}}

@unsafe
def p88_span(+a: U32, +b: U32, begin: U32, end: U32) -> Bool:
  (U32.is_eq(a, 0) && U32.is_eq(b, 0)) || (U32.is_ge(a, begin) && U32.is_ge(b, a) && U32.is_lt(b, end))

@unsafe
def p88_valid_node(node: P88Node, valid: Bool) -> P88Node:
  match valid:
    case True{}: node
    case False{}: P88Bad{}

@unsafe
def p88_build(tag: U32, fields: List<&2,P88Node>, +begin: U32, +end: U32) -> P88Node:
  match tag fields:
    case 0 Nil{}: P88Empty{}
    case 1 [P88Term{h}, P88Empty{}]: P88Terms{[h]}
    case 1 [P88Def{h}, P88Empty{}]: P88Defs{[h]}
    case 1 [P88String{h}, P88Empty{}]: P88Strings{[h]}
    case 1 [P88Term{h}, P88Terms{t}]: P88Terms{Con{h, t}}
    case 1 [P88Def{h}, P88Defs{t}]: P88Defs{Con{h, t}}
    case 1 [P88String{h}, P88Strings{t}]: P88Strings{Con{h, t}}
    case 2 [P88String{a}, P88String{b}, P88Word{c}, P88Word{d}, P88Terms{e}, P88Strings{f}, P88Word{+g}, P88Word{+h}]:
      p88_valid_node(P88Term{KTerm{a,b,c,d,e,f,g,h}}, p88_span(g,h,begin,end))
    case 3 [P88String{a}, P88Word{b}, P88Word{c}, P88Terms{d}, P88Strings{e}, P88Word{+f}, P88Word{+g}, P88Bool{h}]:
      p88_valid_node(P88Term{KLambda{a,b,c,d,e,f,g,h}}, p88_span(f,g,begin,end))
    case 4 [P88String{+a}, P88Word{+b}, P88String{+c}, P88Word{+d}, P88Word{+e}]:
      p88_valid_node(P88Term{KLiteral{a,b,c,d,e}}, p88_span(d,e,begin,end) && ((String.eq(a,"String") && U32.is_eq(b,0)) || ((String.eq(a,"Nat") || String.eq(a,"U32") || String.eq(a,"F32")) && String.is_empty(c))))
    case 5 [P88String{a}, P88String{b}, P88Word{c}, P88Word{d}, P88Term{e}, P88Term{f}, P88Defs{g}, P88Bool{h}, P88Bool{i}]:
      P88Def{KDef{a,b,c,d,e,f,g,h,i}}
    case 6 [P88Word{a}, P88Defs{b}]: P88Def{KIndexLeaf{a,b}}
    case 7 [P88Word{a}, P88Word{b}, P88Def{c}, P88Def{d}]: P88Def{KIndexNode{a,b,c,d}}
    case 8 [P88Word{a}, P88Word{b}, P88Word{c}, P88Defs{d}, P88Bool{e}]: P88Checked{KBasePrefixState{a,b,c,d,e}}
    case 9 [P88Word{a}, P88Bool{b}]: P88Fresh{FFreshPrefixState{a,b}}
    case 10 [P88Checked{a}, P88Defs{b}, P88Defs{c}, P88Defs{d}, P88Defs{e}, P88Defs{f}, P88Word{g}, P88Word{h}]: P88World{KBasePreparedWorld{a,b,c,d,e,f,g,h}}
    case 11 [P88Def{a}, P88Def{b}, P88Word{c}, P88Bool{d}]: P88Frontend{FReadyPrefixState{a,b,c,d}}
    case t other: P88Bad{}

@unsafe
def p88_fields(state: P88State, +tag: U32, roles: List<&2,U32>, values: List<&2,P88Node>, +left: U32) -> P88Decoded:
  match roles:
    case Nil{}: p88_fields_finish(state,tag,values,left)
    case Con{role, rest}: p88_fields_next(p88_field(state,role),tag,rest,values,left)

@unsafe
def p88_fields_finish(state: P88State, tag: U32, values: List<&2,P88Node>, left: U32) -> P88Decoded:
  match state:
    case P88State{cursor,nodes,strings,made,sn,+begin,+end}:
      p88_record_put(P88State{cursor,nodes,strings,made,sn,begin,end},p88_build(tag,List.reverse(&2,P88Node,values),begin,end),left)

@unsafe
def p88_fields_next(step: P88Step, tag: U32, roles: List<&2,U32>, values: List<&2,P88Node>, left: U32) -> P88Decoded:
  match step:
    case P88Step{state, P88Bad{}}: P88DecodeError{"cache field"}
    case P88Step{state, value}: p88_fields(state,tag,roles,Con{value,values},left)

@unsafe
def p88_record_put(state: P88State, node: P88Node, left: U32) -> P88Decoded:
  match state node:
    case s P88Bad{}: P88DecodeError{"cache record"}
    case P88State{cursor,nodes,strings,+made,sn,begin,end} n:
      p88_records(P88State{cursor,Array.set(P88Node,nodes,made,n),strings,U32.inc(made),sn,begin,end},U32.sub(left,1))

@unsafe
def p88_records(state: P88State, left: U32) -> P88Decoded:
  match left:
    case 0: p88_roots(state,[7,9,10,11,12],Nil{})
    case n: p88_record_tag(p88_number(state),n)

@unsafe
def p88_record_tag(step: P88Step, left: U32) -> P88Decoded:
  match step:
    case P88Step{state,P88Word{+tag}}: p88_record_tag_gate(state,tag,left,U32.is_le(tag,11))
    case P88Step{state,other}: P88DecodeError{"cache tag"}

@unsafe
def p88_record_tag_gate(state: P88State, tag: U32, left: U32, ok: Bool) -> P88Decoded:
  match ok:
    case False{}: P88DecodeError{"cache tag"}
    case True{}: p88_record_width(p88_number(state),tag,left)

@unsafe
def p88_record_width(step: P88Step, +tag: U32, left: U32) -> P88Decoded:
  match step:
    case P88Step{state,P88Word{width}}:
      p88_record_width_gate(state,tag,left,U32.is_eq(width,U32.from_nat(List.length(&2,U32,p88_roles(tag)))))
    case P88Step{state,other}: P88DecodeError{"cache width"}

@unsafe
def p88_record_width_gate(state: P88State, +tag: U32, left: U32, ok: Bool) -> P88Decoded:
  match ok:
    case False{}: P88DecodeError{"cache width"}
    case True{}: p88_fields(state,tag,p88_roles(tag),Nil{},left)

@unsafe
def p88_roots(state: P88State, roles: List<&2,U32>, values: List<&2,P88Node>) -> P88Decoded:
  match roles:
    case Nil{}: p88_roots_done(state,List.reverse(&2,P88Node,values))
    case Con{role,rest}: p88_roots_next(p88_field(state,role),rest,values)

@unsafe
def p88_roots_next(step: P88Step, roles: List<&2,U32>, values: List<&2,P88Node>) -> P88Decoded:
  match step:
    case P88Step{state,P88Bad{}}: P88DecodeError{"cache root"}
    case P88Step{state,value}: p88_roots(state,roles,Con{value,values})

@unsafe
def p88_roots_done(state: P88State, values: List<&2,P88Node>) -> P88Decoded:
  match state values:
    case P88State{P88Cursor{SNil{},True{}},nodes,strings,made,sn,begin,end} [P88Defs{book},P88Checked{checked},P88Fresh{+fresh},P88World{+world},P88Frontend{+ready}]:
      p88_roots_ready(P88Products{book,fresh,ready,world},fresh,ready,world)
    case s other: P88DecodeError{"cache roots or trailing data"}

@unsafe
def p88_roots_ready(products: P88Products, fresh: FFreshPrefixState, ready: FReadyPrefixState, world: KBasePreparedWorld) -> P88Decoded:
  match fresh ready world:
    case FFreshPrefixState{next,True{}} FReadyPrefixState{names,ctors,count,True{}} KBasePreparedWorld{KBasePrefixState{bound,delta,stamp,patches,True{}},prefix,final,book,checked,seen,todos,checkedBound}:
      p88_roots_gate(products,U32.is_ge(next,1) && U32.is_le(count,65536) && U32.is_le(bound,1048576) && U32.is_le(stamp,delta))
    case f r w: P88DecodeError{"cache readiness"}

@unsafe
def p88_roots_gate(products: P88Products, ok: Bool) -> P88Decoded:
  match ok:
    case True{}: P88DecodeReady{products}
    case False{}: P88DecodeError{"cache readiness bounds"}

@unsafe
def p88_strings(state: P88State, +index: U32, +total: U32) -> P88Decoded:
  match state:
    case P88State{cursor,nodes,strings,made,+sn,begin,end}:
      p88_strings_gate(cursor,nodes,strings,made,sn,begin,end,index,total,U32.is_lt(index,sn))

@unsafe
def p88_strings_gate(cursor: P88Cursor, nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, index: U32, total: U32, more: Bool) -> P88Decoded:
  match more:
    case False{}: p88_records(P88State{cursor,nodes,strings,made,sn,begin,end},total)
    case True{}: p88_strings_read(nodes,strings,made,sn,begin,end,index,total,p88_text(cursor))

@unsafe
def p88_strings_read(nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, +index: U32, total: U32, read: P88TextRead) -> P88Decoded:
  match read:
    case P88TextRead{P88Cursor{text,True{}},value}:
      p88_strings(P88State{P88Cursor{text,True{}},nodes,Array.set(String,strings,index,value),made,sn,begin,end},U32.inc(index),total)
    case other: P88DecodeError{"cache string"}

# Exactly five roots, <=65,536 records, <=4,096 strings, <=1Mi scalars/string.
# Host reads <=16MiB carrier and authenticates the complete bytes before calling.
@unsafe
def p88_decode_admitted(text: String, expected_stamp: String, +begin: U32, +end: U32) -> P88Decoded:
  p88_header_stamp(p88_text(P88Cursor{text,True{}}),expected_stamp,begin,end)

@unsafe
def p88_header_stamp(read: P88TextRead, expected: String, begin: U32, end: U32) -> P88Decoded:
  match read:
    case P88TextRead{P88Cursor{text,+ok},stamp}:
      p88_header_gate(P88Cursor{text,ok},begin,end,ok && String.eq(stamp,expected))

@unsafe
def p88_header_gate(cursor: P88Cursor, +begin: U32, +end: U32, ok: Bool) -> P88Decoded:
  match ok:
    case True{}: p88_header_nodes(p88_u32(cursor),begin,end)
    case False{}: P88DecodeError{"cache stamp"}

@unsafe
def p88_header_nodes(read: P88Number, begin: U32, end: U32) -> P88Decoded:
  match read:
    case P88Number{cursor,n}: p88_header_counts(p88_u32(cursor),n,begin,end)

@unsafe
def p88_header_counts(read: P88Number, +n: U32, +begin: U32, +end: U32) -> P88Decoded:
  match read:
    case P88Number{P88Cursor{text,+ok},+sn}:
      p88_header_allocate(P88Cursor{text,ok},n,sn,begin,end,ok && U32.is_ge(n,1) && U32.is_le(n,65536) && U32.is_le(sn,4096) && U32.is_ge(begin,1) && U32.is_gt(end,begin))

@unsafe
def p88_header_allocate(cursor: P88Cursor, +n: U32, +sn: U32, begin: U32, end: U32, ok: Bool) -> P88Decoded:
  match ok:
    case True{}: p88_strings(P88State{cursor,Array.new(P88Node,p88_array_depth(n,1,0n),P88Bad{}),Array.new(String,p88_array_depth(sn,1,0n),""),0,sn,begin,end},0,n)
    case False{}: P88DecodeError{"cache header bounds"}

@unsafe
def p88_array_depth(+needed: U32, +capacity: U32, depth: Nat) -> Nat:
  p88_array_depth_step(needed,capacity,depth,U32.is_le(needed,capacity))

@unsafe
def p88_array_depth_step(needed: U32, capacity: U32, depth: Nat, done: Bool) -> Nat:
  match done:
    case True{}: depth
    case False{}: p88_array_depth(needed,U32.mul(capacity,2),1n+depth)


@unsafe
def p88_control_term(t: KTerm) -> Bool:
  match t:
    case KTerm{a,b,0,0,Nil{},Nil{},1,2}: String.eq(a,"Typ") && String.eq(b,"λ🙂")
    case other: False{}

@unsafe
def p88_control_defs(xs: List<&2,KDef>) -> Bool:
  match xs:
    case [KDef{a,b,0,0,t,v,Nil{},False{},False{}}]: String.eq(a,"λ🙂") && String.eq(b,"Def") && p88_control_term(t) && p88_control_term(v)
    case other: False{}

@unsafe
def p88_control_index(d: KDef) -> Bool:
  match d:
    case KIndexLeaf{4294967295,xs}: p88_control_defs(xs)
    case other: False{}

@unsafe
def p88_control_positive(result: P88Decoded) -> Bool:
  match result:
    case P88DecodeReady{P88Products{book,FFreshPrefixState{1,True{}},FReadyPrefixState{names,ctors,1,True{}},KBasePreparedWorld{KBasePrefixState{1,0,0,Nil{},True{}},prefix,final,saved,Nil{},Nil{},0,1}}}:
      p88_control_defs(book) && p88_control_defs(prefix) && p88_control_defs(final) && p88_control_defs(saved) && p88_control_index(names) && p88_control_index(ctors)
    case other: False{}

@unsafe
def p88_control_negative(result: P88Decoded) -> Bool:
  match result:
    case P88DecodeError{error}: True{}
    case other: False{}

@unsafe
def main() -> Bool:
  +c0 = p88_control_positive(p88_decode_admitted("20\np88-small-control-v1\n9\n4\n3\nTyp\n2\nλ🙂\n0\n\n3\nDef\n0\n0\n2\n8\n0\n1\n0\n0\n0\n0\n1\n2\n5\n9\n1\n3\n0\n0\n1\n1\n0\n0\n0\n1\n2\n2\n0\n6\n2\n4294967295\n3\n8\n5\n1\n0\n0\n0\n1\n9\n2\n1\n1\n10\n8\n5\n3\n3\n3\n0\n0\n0\n1\n11\n4\n4\n4\n1\n1\n3\n5\n6\n7\n8\n","p88-small-control-v1",1,8))
  +c1 = p88_control_negative(p88_decode_admitted("20\np88-small-control-v1\n9\n4\n3\nTyp\n2\nλ🙂\n0\n\n3\nDef\n0\n0\n2\n8\n0\n1\n0\n0\n0\n0\n1\n2\n5\n9\n1\n3\n0\n0\n1\n1\n0\n0\n0\n1\n2\n2\n0\n6\n2\n4294967295\n3\n8\n5\n1\n0\n0\n0\n1\n9\n2\n1\n1\n10\n8\n5\n3\n3\n3\n0\n0\n0\n1\n11\n4\n4\n4\n1\n1\n3\n5\n6\n7\n8\n","p88-small-control-v1!",1,8))
  +c2 = p88_control_negative(p88_decode_admitted("20\np88-small-control-v1\n9\n4\n3\nTyp\n2\nλ🙂\n0\n\n3\nDef\n0\n0\n2\n8\n0\n1\n0\n0\n0\n0\n1\n2\n5\n9\n1\n3\n0\n0\n1\n1\n0\n0\n0\n1\n2\n2\n0\n6\n2\n4294967295\n3\n8\n5\n1\n0\n0\n0\n1\n9\n2\n1\n1\n10\n8\n5\n3\n3\n3\n0\n0\n0\n1\n11\n4\n4\n4\n1\n1\n3\n5\n6\n7","p88-small-control-v1",1,8))
  +c3 = p88_control_negative(p88_decode_admitted("20\np88-small-control-v1\n9\n4\n3\nTyp\n2\nλ🙂\n0\n\n3\nDef\n0\n0\n2\n8\n0\n1\n0\n0\n0\n0\n1\n2\n5\n9\n1\n3\n0\n0\n1\n1\n0\n0\n0\n1\n2\n2\n0\n6\n2\n4294967295\n3\n8\n5\n1\n0\n0\n0\n1\n9\n2\n1\n1\n10\n8\n5\n3\n3\n3\n0\n0\n0\n1\n11\n4\n4\n4\n1\n1\n3\n5\n6\n7\n8\nx","p88-small-control-v1",1,8))
  +c4 = p88_control_negative(p88_decode_admitted("20\np88-small-control-v1\n9\n4\n3\nTyp\n2\nλ🙂\n0\n\n3\nDef\n0\n0\n2\n8\n0\n1\n0\n0\n0\n0\n1\n2\n5\n9\n1\n3\n0\n0\n1\n1\n0\n0\n0\n1\n2\n3\n0\n6\n2\n4294967295\n3\n8\n5\n1\n0\n0\n0\n1\n9\n2\n1\n1\n10\n8\n5\n3\n3\n3\n0\n0\n0\n1\n11\n4\n4\n4\n1\n1\n3\n5\n6\n7\n8\n","p88-small-control-v1",1,8))
  +c5 = p88_control_negative(p88_decode_admitted("20\np88-small-control-v1\n9\n4\n3\nTyp\n2\nλ🙂\n0\n\n3\nDef\n0\n0\n2\n8\n0\n1\n0\n0\n0\n0\n1\n2\n5\n9\n1\n3\n0\n0\n1\n1\n0\n0\n0\n1\n2\n2\n0\n6\n2\n4294967295\n1\n8\n5\n1\n0\n0\n0\n1\n9\n2\n1\n1\n10\n8\n5\n3\n3\n3\n0\n0\n0\n1\n11\n4\n4\n4\n1\n1\n3\n5\n6\n7\n8\n","p88-small-control-v1",1,8))
  +c6 = p88_control_negative(p88_decode_admitted("20\np88-small-control-v1\n9\n4\n3\nTyp\n2\nλ🙂\n0\n\n3\nDef\n0\n0\n2\n8\n0\n1\n0\n0\n0\n0\n1\n2\n5\n9\n1\n3\n0\n0\n1\n1\n0\n0\n0\n1\n2\n2\n0\n6\n2\n4294967295\n3\n8\n5\n1\n0\n0\n0\n1\n9\n2\n1\n2\n10\n8\n5\n3\n3\n3\n0\n0\n0\n1\n11\n4\n4\n4\n1\n1\n3\n5\n6\n7\n8\n","p88-small-control-v1",1,8))
  +c7 = p88_control_negative(p88_decode_admitted("20\np88-small-control-v1\n9\n4\n3\nTyp\n2\nλ🙂\n0\n\n3\nDef\n0\n0\n2\n8\n0\n1\n0\n0\n0\n0\n1\n2\n5\n9\n1\n3\n0\n0\n1\n1\n0\n0\n0\n1\n2\n2\n0\n6\n2\n4294967295\n3\n8\n5\n1\n0\n0\n0\n1\n9\n2\n1\n0\n10\n8\n5\n3\n3\n3\n0\n0\n0\n1\n11\n4\n4\n4\n1\n1\n3\n5\n6\n7\n8\n","p88-small-control-v1",1,8))
  +c8 = p88_control_negative(p88_decode_admitted("20\np88-small-control-v1\n9\n4\n3\nTyp\n2\nλ🙂\n0\n\n3\nDef\n0\n0\n2\n8\n0\n1\n0\n0\n0\n0\n1\n2\n5\n9\n1\n3\n0\n0\n1\n1\n0\n0\n0\n1\n2\n2\n0\n6\n2\n4294967295\n3\n8\n5\n1\n0\n0\n0\n1\n12\n2\n1\n1\n10\n8\n5\n3\n3\n3\n0\n0\n0\n1\n11\n4\n4\n4\n1\n1\n3\n5\n6\n7\n8\n","p88-small-control-v1",1,8))
  +c9 = p88_control_negative(p88_decode_admitted("20\np88-small-control-v1\n9\n4\n3\nTyp\n2\nλ🙂\n0\n\n3\nDef\n0\n0\n2\n8\n0\n1\n0\n0\n0\n0\n1\n8\n5\n9\n1\n3\n0\n0\n1\n1\n0\n0\n0\n1\n2\n2\n0\n6\n2\n4294967295\n3\n8\n5\n1\n0\n0\n0\n1\n9\n2\n1\n1\n10\n8\n5\n3\n3\n3\n0\n0\n0\n1\n11\n4\n4\n4\n1\n1\n3\n5\n6\n7\n8\n","p88-small-control-v1",1,8))
  +c10 = p88_control_negative(p88_decode_admitted("20\np88-small-control-v1\n9\n4\n3\nTyp\n2\nλ🙂\n0\n\n3\nDef\n0\n0\n2\n8\n0\n1\n0\n0\n0\n0\n1\n2\n5\n9\n1\n3\n0\n0\n1\n1\n0\n0\n0\n1\n2\n2\n0\n6\n2\n4294967295\n3\n8\n5\n1\n0\n0\n0\n1\n9\n2\n1\n1\n10\n8\n5\n3\n3\n3\n0\n0\n0\n1\n11\n4\n4\n4\n1\n1\n3\n5\n6\n1\n8\n","p88-small-control-v1",1,8))
  +c11 = p88_control_negative(p88_decode_admitted("20\np88-small-control-v1\n9\n4\n3\nTyp\n2\nλ🙂\n0\n\n3\nDef\n0\n0\n2\n8\n0\n1\n0\n0\n0\n0\n1\n2\n5\n9\n1\n3\n0\n0\n1\n1\n0\n0\n0\n1\n2\n2\n0\n6\n2\n4294967296\n3\n8\n5\n1\n0\n0\n0\n1\n9\n2\n1\n1\n10\n8\n5\n3\n3\n3\n0\n0\n0\n1\n11\n4\n4\n4\n1\n1\n3\n5\n6\n7\n8\n","p88-small-control-v1",1,8))
  +c12 = p88_control_negative(p88_decode_admitted("20\np88-small-control-v1\n9\n4\n3\nTyp\n2\nλ🙂\n0\n\n3\nDef\n0\n0\n2\n8\n0\n1\n0\n0\n0\n0\n1\n2\n5\n9\n1\n3\n0\n0\n1\n1\n0\n0\n0\n1\n2\n2\n0\n6\n2\n04294967295\n3\n8\n5\n1\n0\n0\n0\n1\n9\n2\n1\n1\n10\n8\n5\n3\n3\n3\n0\n0\n0\n1\n11\n4\n4\n4\n1\n1\n3\n5\n6\n7\n8\n","p88-small-control-v1",1,8))
  +c13 = p88_control_negative(p88_decode_admitted("20\np88-small-control-v1\n9\n4\n3\nTyp\n2\nλ🙂\n0\n\n3\nDef\n0\n0\n2\n8\n0\n1\n0\n0\n0\n0\n1\n2\n5\n9\n1\n3\n0\n0\n1\n1\n0\n0\n0\n1\n2\n2\n0\n6\n1\n4294967295\n3\n8\n5\n1\n0\n0\n0\n1\n9\n2\n1\n1\n10\n8\n5\n3\n3\n3\n0\n0\n0\n1\n11\n4\n4\n4\n1\n1\n3\n5\n6\n7\n8\n","p88-small-control-v1",1,8))
  +c14 = p88_control_negative(p88_decode_admitted("20\np88-small-control-v1\n65537\n4\n3\nTyp\n2\nλ🙂\n0\n\n3\nDef\n0\n0\n2\n8\n0\n1\n0\n0\n0\n0\n1\n2\n5\n9\n1\n3\n0\n0\n1\n1\n0\n0\n0\n1\n2\n2\n0\n6\n2\n4294967295\n3\n8\n5\n1\n0\n0\n0\n1\n9\n2\n1\n1\n10\n8\n5\n3\n3\n3\n0\n0\n0\n1\n11\n4\n4\n4\n1\n1\n3\n5\n6\n7\n8\n","p88-small-control-v1",1,8))
  +c15 = p88_control_negative(p88_decode_admitted("20\np88-small-control-v1\n9\n4\n3\nTyp\n3\nλ🙂\n0\n\n3\nDef\n0\n0\n2\n8\n0\n1\n0\n0\n0\n0\n1\n2\n5\n9\n1\n3\n0\n0\n1\n1\n0\n0\n0\n1\n2\n2\n0\n6\n2\n4294967295\n3\n8\n5\n1\n0\n0\n0\n1\n9\n2\n1\n1\n10\n8\n5\n3\n3\n3\n0\n0\n0\n1\n11\n4\n4\n4\n1\n1\n3\n5\n6\n7\n8\n","p88-small-control-v1",1,8))
  c0 && c1 && c2 && c3 && c4 && c5 && c6 && c7 && c8 && c9 && c10 && c11 && c12 && c13 && c14 && c15
#|True{}
