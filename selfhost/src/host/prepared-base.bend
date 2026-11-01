
# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:8
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

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:24
type P88Cursor is Data:
  P88Cursor{+text: String, +mode: U32}

type P88Number is Data:
  P88Number{+cursor: P88Cursor, +value: U32}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:28
type P88TextRead is Data:
  P88TextRead{+cursor: P88Cursor, +value: String}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:30
type P88State is Type:
  P88State{cursor: P88Cursor, nodes: Array<P88Node>, strings: Array<String>, +made: U32, +sn: U32, +begin: U32, +end: U32}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:32
type P88Step is Type:
  P88Step{state: P88State, value: P88Node}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:34
type P88Products is Data:
  P88Products{+book: List<&2,KDef>, +fresh: FFreshPrefixState, +ready: FReadyPrefixState, +world: KBasePreparedWorld}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:36
type P88Decoded is Data:
  P88DecodeError{+error: String}
  P88DecodeReady{+products: P88Products}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:42
@unsafe
def p88_u32(cursor: P88Cursor) -> P88Number:
  match cursor:
    case P88Cursor{text,1}: p88_digits(text,0,0)
    case P88Cursor{text,2}: p130m_word(text)
    case other: P88Number{P88Cursor{"",0},0}

@unsafe
def p88_digits(text: String, +acc: U32, +digits: U32) -> P88Number:
  match text:
    case SCon{'\n',tail}: P88Number{P88Cursor{tail,p130m_status(U32.is_ne(digits,0),1)},acc}
    case SCon{Chr{c},tail}:
      +d = U32.sub(c,48)
      p88_digit(tail,acc,digits,d,U32.is_lt(d,10) && U32.is_lt(digits,10) && (U32.is_eq(digits,0) || U32.is_ne(acc,0)) && (U32.is_lt(acc,429496729) || (U32.is_eq(acc,429496729) && U32.is_le(d,5))))
    case other: P88Number{P88Cursor{"",0},0}

@unsafe
def p88_digit(text: String, acc: U32, digits: U32, digit: U32, ok: Bool) -> P88Number:
  match ok:
    case True{}: p88_digits(text,U32.add(U32.mul(acc,10),digit),U32.inc(digits))
    case False{}: P88Number{P88Cursor{"",0},0}

@unsafe
def p88_text(cursor: P88Cursor) -> P88TextRead:
  p88_text_size(p88_u32(cursor))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:67
@unsafe
def p88_text_size(read: P88Number) -> P88TextRead:
  match read:
    case P88Number{P88Cursor{text,+mode},+size}:
      p88_text_gate(text,size,mode,p130m_valid(mode) && U32.is_le(size,1048576))

@unsafe
def p88_text_gate(text: String, size: U32, mode: U32, ok: Bool) -> P88TextRead:
  match ok:
    case True{}: p88_text_chars(size,text,"",mode)
    case False{}: P88TextRead{P88Cursor{"",0},""}

@unsafe
def p88_text_chars(size: U32, text: String, acc: String, mode: U32) -> P88TextRead:
  match size text:
    case 0 SCon{'\n',tail}: P88TextRead{P88Cursor{tail,mode},String.reverse(acc)}
    case 0 other: P88TextRead{P88Cursor{"",0},""}
    case n SCon{Chr{+c},tail}:
      p88_text_char(tail,U32.sub(n,1),SCon{Chr{c},acc},mode,U32.is_le(c,1114111) && (U32.is_lt(c,55296) || U32.is_gt(c,57343)))
    case n other: P88TextRead{P88Cursor{"",0},""}

@unsafe
def p88_text_char(text: String, size: U32, acc: String, mode: U32, ok: Bool) -> P88TextRead:
  match ok:
    case True{}: p88_text_chars(size,text,acc,mode)
    case False{}: P88TextRead{P88Cursor{"",0},""}

@unsafe
def p88_state_bad(state: P88State) -> P88State:
  match state:
    case P88State{cursor,nodes,strings,made,sn,begin,end}:
      P88State{P88Cursor{"",0},nodes,strings,made,sn,begin,end}

@unsafe
def p88_number(state: P88State) -> P88Step:
  match state:
    case P88State{cursor, nodes, strings, made, sn, begin, end}:
      p88_number_read(nodes, strings, made, sn, begin, end, p88_u32(cursor))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:106
@unsafe
def p88_number_read(nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, read: P88Number) -> P88Step:
  match read:
    case P88Number{P88Cursor{text,+mode},n}:
      p130m_number_read(nodes,strings,made,sn,begin,end,text,mode,n,p130m_valid(mode))
# Isolated scalar spellings of two closed, fixed-result U32 tables.
# Literal values become scalar equality operands, never literal patterns.
# A finite safe chooser retains p112fp_binary safety and lazy result selection.
def p151_choose(-A: Type, +b: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match b:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

@unsafe
def p151_roles(+tag: U32) -> List<&2,U32>:
  p151_choose(List<&2,U32>,U32.is_eq(tag,1),u => [13,14],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,2),u => [3,3,1,1,6,8,1,1],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,3),u => [3,1,1,6,8,1,1,2],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,4),u => [3,1,3,1,1],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,5),u => [3,3,1,1,4,4,7,2,2],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,6),u => [1,7],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,7),u => [1,1,5,5],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,8),u => [1,1,1,7,2],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,9),u => [1,2],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,10),u => [9,7,7,7,7,7,1,1],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,11),u => [5,5,1,2],u => [])))))))))))

def p151_binary(+id: U32) -> String:
  p151_choose(String,U32.is_eq(id,26),u => "add",u =>
  p151_choose(String,U32.is_eq(id,27),u => "sub",u =>
  p151_choose(String,U32.is_eq(id,28),u => "mul",u =>
  p151_choose(String,U32.is_eq(id,29),u => "div",u =>
  p151_choose(String,U32.is_eq(id,30),u => "ceqs",u =>
  p151_choose(String,U32.is_eq(id,31),u => "cnes",u =>
  p151_choose(String,U32.is_eq(id,32),u => "clts",u =>
  p151_choose(String,U32.is_eq(id,33),u => "cles",u =>
  p151_choose(String,U32.is_eq(id,34),u => "cgts",u =>
  p151_choose(String,U32.is_eq(id,35),u => "cges",u => "INVALID_P112_FLOAT_OPERATION"))))))))))


# Preserve the original plain public argument quantity and unsafe annotation.
@unsafe
def p88_roles(tag: U32) -> List<&2,U32>:
  p151_roles(tag)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:131
@unsafe
def p88_role_empty(role: U32, node: P88Node) -> P88Node:
  match role node:
    case 6 P88Empty{}: P88Terms{Nil{}}
    case 7 P88Empty{}: P88Defs{Nil{}}
    case 8 P88Empty{}: P88Strings{Nil{}}
    case r n: n

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:139
@unsafe
def p88_field(state: P88State, role: U32) -> P88Step:
  p88_field_number(p88_number(state), role)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:143
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

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:155
@unsafe
def p88_bool_value(state: P88State, n: U32) -> P88Step:
  match n:
    case 0: P88Step{state,P88Bool{False{}}}
    case 1: P88Step{state,P88Bool{True{}}}
    case other: P88Step{p88_state_bad(state),P88Bad{}}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:162
@unsafe
def p88_head_at(state: P88State, n: U32, string: Bool) -> P88Step:
  match string:
    case True{}: p88_string_at(state, U32.sub(n, 2147483648))
    case False{}: p88_node_at(state, n, 13)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:168
@unsafe
def p88_node_at(state: P88State, +id: U32, role: U32) -> P88Step:
  match state:
    case P88State{cursor, nodes, strings, +made, sn, begin, end}:
      p88_node_gate(cursor, nodes, strings, made, sn, begin, end, id, role, U32.is_lt(id, made))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:174
@unsafe
def p88_node_gate(cursor: P88Cursor, nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, id: U32, role: U32, ok: Bool) -> P88Step:
  match ok:
    case False{}: P88Step{P88State{P88Cursor{"",0},nodes,strings,made,sn,begin,end},P88Bad{}}
    case True{}: p88_node_got(cursor,strings,made,sn,begin,end,role,Array.get(P88Node,nodes,id))

@unsafe
def p88_node_got(cursor: P88Cursor, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, role: U32, pair: Array<P88Node> & P88Node) -> P88Step:
  (nodes, node) = pair
  P88Step{P88State{cursor, nodes, strings, made, sn, begin, end}, p88_role_empty(role, node)}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:202
@unsafe
def p88_span(+a: U32, +b: U32, begin: U32, end: U32) -> Bool:
  (U32.is_eq(a, 0) && U32.is_eq(b, 0)) || (U32.is_ge(a, begin) && U32.is_ge(b, a) && U32.is_lt(b, end))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:206
@unsafe
def p88_valid_node(node: P88Node, valid: Bool) -> P88Node:
  match valid:
    case True{}: node
    case False{}: P88Bad{}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:212
@unsafe
def p88_build(tag: U32, fields: List<&2,P88Node>, +begin: U32, +end: U32) -> P88Node:
  match tag fields:
    case 0 Nil{}: P88Empty{}
    case 1 Con{P88Term{h}, Con{P88Empty{}, Nil{}}}: P88Terms{[h]}
    case 1 Con{P88Def{h}, Con{P88Empty{}, Nil{}}}: P88Defs{[h]}
    case 1 Con{P88String{h}, Con{P88Empty{}, Nil{}}}: P88Strings{[h]}
    case 1 Con{P88Term{h}, Con{P88Terms{t}, Nil{}}}: P88Terms{Con{h, t}}
    case 1 Con{P88Def{h}, Con{P88Defs{t}, Nil{}}}: P88Defs{Con{h, t}}
    case 1 Con{P88String{h}, Con{P88Strings{t}, Nil{}}}: P88Strings{Con{h, t}}
    case 2 Con{P88String{a}, Con{P88String{b}, Con{P88Word{c}, Con{P88Word{d}, Con{P88Terms{e}, Con{P88Strings{f}, Con{P88Word{+g}, Con{P88Word{+h}, Nil{}}}}}}}}}:
      p88_valid_node(P88Term{KTerm{a,b,c,d,e,f,g,h}}, p88_span(g,h,begin,end))
    case 3 Con{P88String{a}, Con{P88Word{b}, Con{P88Word{c}, Con{P88Terms{d}, Con{P88Strings{e}, Con{P88Word{+f}, Con{P88Word{+g}, Con{P88Bool{h}, Nil{}}}}}}}}}:
      p88_valid_node(P88Term{KLambda{a,b,c,d,e,f,g,h}}, p88_span(f,g,begin,end))
    case 4 Con{P88String{+a}, Con{P88Word{+b}, Con{P88String{+c}, Con{P88Word{+d}, Con{P88Word{+e}, Nil{}}}}}}:
      p88_valid_node(P88Term{KLiteral{a,b,c,d,e}}, p88_span(d,e,begin,end) && ((String.eq(a,"String") && U32.is_eq(b,0)) || ((String.eq(a,"Nat") || String.eq(a,"U32") || String.eq(a,"F32")) && String.is_empty(c))))
    case 5 Con{P88String{a}, Con{P88String{b}, Con{P88Word{c}, Con{P88Word{d}, Con{P88Term{e}, Con{P88Term{f}, Con{P88Defs{g}, Con{P88Bool{h}, Con{P88Bool{i}, Nil{}}}}}}}}}}:
      P88Def{KDef{a,b,c,d,e,f,g,h,i}}
    case 6 Con{P88Word{a}, Con{P88Defs{b}, Nil{}}}: P88Def{KIndexLeaf{a,b}}
    case 7 Con{P88Word{a}, Con{P88Word{b}, Con{P88Def{c}, Con{P88Def{d}, Nil{}}}}}: P88Def{KIndexNode{a,b,c,d}}
    case 8 Con{P88Word{a}, Con{P88Word{b}, Con{P88Word{c}, Con{P88Defs{d}, Con{P88Bool{e}, Nil{}}}}}}: P88Checked{KBasePrefixState{a,b,c,d,e}}
    case 9 Con{P88Word{a}, Con{P88Bool{b}, Nil{}}}: P88Fresh{FFreshPrefixState{a,b}}
    case 10 Con{P88Checked{a}, Con{P88Defs{b}, Con{P88Defs{c}, Con{P88Defs{d}, Con{P88Defs{e}, Con{P88Defs{f}, Con{P88Word{g}, Con{P88Word{h}, Nil{}}}}}}}}}: P88World{KBasePreparedWorld{a,b,c,d,e,f,g,h}}
    case 11 Con{P88Def{a}, Con{P88Def{b}, Con{P88Word{c}, Con{P88Bool{d}, Nil{}}}}}: P88Frontend{FReadyPrefixState{a,b,c,d}}
    case t other: P88Bad{}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:238
@unsafe
def p88_fields(state: P88State, +tag: U32, roles: List<&2,U32>, values: List<&2,P88Node>, +left: U32) -> P88Decoded:
  match roles:
    case Nil{}: p88_fields_finish(state,tag,values,left)
    case Con{role, rest}: p88_fields_next(p88_field(state,role),tag,rest,values,left)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:244
@unsafe
def p88_fields_finish(state: P88State, tag: U32, values: List<&2,P88Node>, left: U32) -> P88Decoded:
  match state:
    case P88State{cursor,nodes,strings,made,sn,+begin,+end}:
      p88_record_put(P88State{cursor,nodes,strings,made,sn,begin,end},p88_build(tag,List.reverse(&2,P88Node,values),begin,end),left)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:250
@unsafe
def p88_fields_next(step: P88Step, tag: U32, roles: List<&2,U32>, values: List<&2,P88Node>, left: U32) -> P88Decoded:
  match step:
    case P88Step{state, P88Bad{}}: P88DecodeError{"cache field"}
    case P88Step{state, value}: p88_fields(state,tag,roles,Con{value,values},left)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:256
@unsafe
def p88_record_put(state: P88State, node: P88Node, left: U32) -> P88Decoded:
  match state node:
    case s P88Bad{}: P88DecodeError{"cache record"}
    case P88State{cursor,nodes,strings,+made,sn,begin,end} n:
      p88_records(P88State{cursor,Array.set(P88Node,nodes,made,n),strings,U32.inc(made),sn,begin,end},U32.sub(left,1))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:263
@unsafe
def p88_records(state: P88State, left: U32) -> P88Decoded:
  match left:
    case 0: p88_roots(state,[7,9,10,11,12],Nil{})
    case n: p88_record_tag(p88_number(state),n)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:269
@unsafe
def p88_record_tag(step: P88Step, left: U32) -> P88Decoded:
  match step:
    case P88Step{state,P88Word{+tag}}: p88_record_tag_gate(state,tag,left,U32.is_le(tag,11))
    case P88Step{state,other}: P88DecodeError{"cache tag"}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:275
@unsafe
def p88_record_tag_gate(state: P88State, tag: U32, left: U32, ok: Bool) -> P88Decoded:
  match ok:
    case False{}: P88DecodeError{"cache tag"}
    case True{}: p88_record_width(p88_number(state),tag,left)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:281
@unsafe
def p88_record_width(step: P88Step, +tag: U32, left: U32) -> P88Decoded:
  match step:
    case P88Step{state,P88Word{width}}:
      p88_record_width_gate(state,tag,left,U32.is_eq(width,U32.from_nat(List.length(&2,U32,p88_roles(tag)))))
    case P88Step{state,other}: P88DecodeError{"cache width"}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:288
@unsafe
def p88_record_width_gate(state: P88State, +tag: U32, left: U32, ok: Bool) -> P88Decoded:
  match ok:
    case False{}: P88DecodeError{"cache width"}
    case True{}: p88_fields(state,tag,p88_roles(tag),Nil{},left)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:294
@unsafe
def p88_roots(state: P88State, roles: List<&2,U32>, values: List<&2,P88Node>) -> P88Decoded:
  match roles:
    case Nil{}: p88_roots_done(state,List.reverse(&2,P88Node,values))
    case Con{role,rest}: p88_roots_next(p88_field(state,role),rest,values)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:300
@unsafe
def p88_roots_next(step: P88Step, roles: List<&2,U32>, values: List<&2,P88Node>) -> P88Decoded:
  match step:
    case P88Step{state,P88Bad{}}: P88DecodeError{"cache root"}
    case P88Step{state,value}: p88_roots(state,roles,Con{value,values})

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:306
@unsafe
def p88_roots_done(state: P88State, values: List<&2,P88Node>) -> P88Decoded:
  match state values:
    case P88State{P88Cursor{SNil{},mode},nodes,strings,made,sn,begin,end} Con{P88Defs{book},Con{P88Checked{checked},Con{P88Fresh{+fresh},Con{P88World{+world},Con{P88Frontend{+ready},Nil{}}}}}}:
      p130m_roots_ready(P88Products{book,fresh,ready,world},fresh,ready,world,p130m_valid(mode))
    case s other: P88DecodeError{"cache roots or trailing data"}

@unsafe
def p88_roots_ready(products: P88Products, fresh: FFreshPrefixState, ready: FReadyPrefixState, world: KBasePreparedWorld) -> P88Decoded:
  match fresh ready world:
    case FFreshPrefixState{next,True{}} FReadyPrefixState{names,ctors,count,True{}} KBasePreparedWorld{KBasePrefixState{bound,delta,stamp,patches,True{}},prefix,final,book,checked,seen,todos,checkedBound}:
      p88_roots_gate(products,U32.is_ge(next,1) && U32.is_le(count,65536) && U32.is_le(bound,1048576) && U32.is_le(stamp,delta))
    case f r w: P88DecodeError{"cache readiness"}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:320
@unsafe
def p88_roots_gate(products: P88Products, ok: Bool) -> P88Decoded:
  match ok:
    case True{}: P88DecodeReady{products}
    case False{}: P88DecodeError{"cache readiness bounds"}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:326
@unsafe
def p88_strings(state: P88State, +index: U32, +total: U32) -> P88Decoded:
  match state:
    case P88State{cursor,nodes,strings,made,+sn,begin,end}:
      p88_strings_gate(cursor,nodes,strings,made,sn,begin,end,index,total,U32.is_lt(index,sn))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:332
@unsafe
def p88_strings_gate(cursor: P88Cursor, nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, index: U32, total: U32, more: Bool) -> P88Decoded:
  match more:
    case False{}: p88_records(P88State{cursor,nodes,strings,made,sn,begin,end},total)
    case True{}: p88_strings_read(nodes,strings,made,sn,begin,end,index,total,p88_text(cursor))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:338
@unsafe
def p88_strings_read(nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, index: U32, total: U32, read: P88TextRead) -> P88Decoded:
  match read:
    case P88TextRead{P88Cursor{text,+mode},value}:
      p130m_strings_read(nodes,strings,made,sn,begin,end,index,total,text,mode,value,p130m_valid(mode))

@unsafe
def p88_decode_admitted(+text: String, +expected_stamp: String, +begin: U32, +end: U32) -> P88Decoded:
  p88_header_stamp(p88_text(P88Cursor{text,p130m_initial(text,expected_stamp)}),expected_stamp,begin,end)

@unsafe
def p88_header_stamp(read: P88TextRead, expected: String, begin: U32, end: U32) -> P88Decoded:
  match read:
    case P88TextRead{P88Cursor{text,+mode},stamp}:
      p88_header_gate(P88Cursor{text,mode},begin,end,p130m_valid(mode) && String.eq(stamp,expected))

@unsafe
def p88_header_gate(cursor: P88Cursor, +begin: U32, +end: U32, ok: Bool) -> P88Decoded:
  match ok:
    case True{}: p88_header_nodes(p88_u32(cursor),begin,end)
    case False{}: P88DecodeError{"cache stamp"}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:363
@unsafe
def p88_header_nodes(read: P88Number, begin: U32, end: U32) -> P88Decoded:
  match read:
    case P88Number{cursor,n}: p88_header_counts(p88_u32(cursor),n,begin,end)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:368
@unsafe
def p88_header_counts(read: P88Number, +n: U32, +begin: U32, +end: U32) -> P88Decoded:
  match read:
    case P88Number{P88Cursor{text,+mode},+sn}:
      p88_header_allocate(P88Cursor{text,mode},n,sn,begin,end,p130m_valid(mode) && U32.is_ge(n,1) && U32.is_le(n,65536) && U32.is_le(sn,4096) && U32.is_ge(begin,1) && U32.is_gt(end,begin))

@unsafe
def p88_header_allocate(cursor: P88Cursor, +n: U32, +sn: U32, begin: U32, end: U32, ok: Bool) -> P88Decoded:
  match ok:
    case True{}: p88_strings(P88State{cursor,Array.new(P88Node,p88_array_depth(n,1,0n),P88Bad{}),Array.new(String,p88_array_depth(sn,1,0n),""),0,sn,begin,end},0,n)
    case False{}: P88DecodeError{"cache header bounds"}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:380
@unsafe
def p88_array_depth(+needed: U32, +capacity: U32, depth: Nat) -> Nat:
  p88_array_depth_step(needed,capacity,depth,U32.is_le(needed,capacity))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:384
@unsafe
def p88_array_depth_step(needed: U32, capacity: U32, depth: Nat, done: Bool) -> Nat:
  match done:
    case True{}: depth
    case False{}: p88_array_depth(needed,U32.mul(capacity,2),1n+depth)


# PRIVATE cache mode: the wrapper authenticates the complete carrier receipt,
# producer/Base/path/ABI and native consumer image before invoking this entry.
# A matching stamp alone grants no trust. Cache refusal never falls back silently.

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:762
@unsafe
def p88_cache_prepare(+path: String, +text: String, carrier: String, stamp: String) -> P86Preparation:
  +end = U32.add(p86_width(text,0),2)
  p88_cache_result(f_source_located(FSource{"Base",path,text},1,end),p88_decode_admitted(carrier,stamp,1,end))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:767
@unsafe
def p88_cache_result(+source: FSource, decoded: P88Decoded) -> P86Preparation:
  match decoded:
    case P88DecodeError{error}: P86PreparationError{"base_cache: " ++ error}
    case P88DecodeReady{P88Products{book,fresh,ready,world}}:
      p86_prepare_states(source,book,fresh,ready,world)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:774
@unsafe
def p88_cache_paths(+input: String, +base: String, runtime: String, +directory: String, +output: String, +count: U32, cache: String, stamp: String) -> IO(U32):
  do IO<U32>:
    text : String <- p86_read_file(input)
    base_text : String <- p86_read_file(base)
    before : Nat <- IO.now()
    carrier : String <- p86_read_file(cache)
    p86_base_prepared(input,text,base,runtime,directory,output,count,p88_cache_prepare(base,base_text,carrier,stamp),before)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:783
@unsafe
def p88_cli_cache(+input: String, +base: String, +runtime: String, +directory: String, +output: String, +count: String, +cache: String, +stamp: String) -> IO(U32):
  kc(IO(U32),String.starts_with(input,"/") && String.starts_with(base,"/") && String.starts_with(runtime,"/") && String.starts_with(directory,"/") && String.starts_with(output,"/") && String.starts_with(cache,"/") && Bool.not(String.is_empty(stamp)) && (String.eq(count,"1") || String.eq(count,"5")),
    u => p88_cache_paths(input,base,runtime,directory,output,kc(U32,String.eq(count,"1"),v => 1,v => 5),cache,stamp),
    u => IO.die(U32,2,"expected absolute paths, COUNT 1 or 5, and authenticated cache stamp"))
