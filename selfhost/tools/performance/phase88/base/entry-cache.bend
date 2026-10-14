# Candidate only: frozen decoder plus copied Phase88 entry.
# PRIVATE Phase88 transport experiment, not a public checker permission.
# Caller must authenticate the complete carrier and its producer/Base receipt.
# The stamp checked here is routing metadata, not a cryptographic certificate.
# Constructors are reconstructed in Bend; no native layouts or closures enter.
import Base

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
    case P88State{P88Cursor{SNil{},True{}},nodes,strings,made,sn,begin,end} Con{P88Defs{book}, Con{P88Checked{checked}, Con{P88Fresh{+fresh}, Con{P88World{+world}, Con{P88Frontend{+ready}, Nil{}}}}}}:
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

# Phase88 native-host entry. Reuses one checked Base world; algorithms stay Bend.
# Root freezes/audits Base, runtime and EFFECTDIR; only the three audited scalar
# Base effects are admitted. This is a prepared-session experiment, not a CLI.
# RUNTIME names the authenticated runtime whose five prepared sibling files
# RUNTIME.part0 .. RUNTIME.part4 are supplied by the root harness.
import Base

type P86Seed is Data:
  P86Seed{+source: FSource, +book: List<&2,KDef>, +fresh: FFreshPrefixState, +ready: FReadyPrefixState, +world: KBasePreparedWorld}

type P86Preparation is Data:
  P86PreparationError{+error: String}
  P86PreparationReady{+seed: P86Seed}

type P86Plan is Data:
  P86PlanError{+error: String}
  P86PlanReady{+request: NR_Request, +verdict: String}

type P86Result is Data:
  P86Result{+source: String, +error: String, +verdict: String}

# The ordinary host supplies JS UTF-16 lengths. This tail loop computes the
# same transport metadata in either execution backend, without dg_width's
# diagnostic-sized recursion on the entire75KiB Base source.
@unsafe
def p86_width(text: String, count: U32) -> U32:
  match text:
    case SNil{}: count
    case SCon{char, rest}: p86_width(rest, U32.add(count, dg_units(char)))

@unsafe
def p86_prepare(+path: String, +text: String) -> P86Preparation:
  +source = f_source_located(FSource{"Base", path, text}, 1, U32.add(p86_width(text, 0), 2))
  p86_prepare_loaded(source, f_load_graph("Base", [source]))

@unsafe
def p86_prepare_loaded(+source: FSource, loaded: FResult) -> P86Preparation:
  match loaded:
    case FResult{+book, +error, imports}:
      kc(P86Preparation, String.is_empty(error),
        u => p86_prepare_check(source, book, dg_check_world(book)),
        u => P86PreparationError{"base_parse: " ++ error})

# Preserve check_book's ordinary diagnostic path while retaining its checked
# world for the existing prefix-admission construction.
@unsafe
def p86_prepare_check(+source: FSource, +book: List<&2,KDef>, +checked: DChecking) -> P86Preparation:
  p86_prepare_checked(source, book, checked, dg_result_error(dg_legacy_result(book, Nil{}, checked)))

@unsafe
def p86_checked_prefix(+book: List<&2,KDef>, +checked: DChecking) -> KBasePrefixState:
  +world = rw(dg_checking_result(checked))
  base_prefix_prepare_fresh(book, norm_max_book(book), checked, world, kw_fresh(world))

@unsafe
def p86_prepare_checked(+source: FSource, +book: List<&2,KDef>, +checked: DChecking, +error: String) -> P86Preparation:
  kc(P86Preparation, String.is_empty(error),
    u => p86_prepare_states(source, book, f_fresh_prefix_prepare(book), f_ready_prefix_prepare(book), base_prefix_world_prepare(book, p86_checked_prefix(book, checked))),
    u => P86PreparationError{"base_check: " ++ error})

@unsafe
def p86_prepare_states(+source: FSource, +book: List<&2,KDef>, +fresh: FFreshPrefixState, +ready: FReadyPrefixState, +world: KBasePreparedWorld) -> P86Preparation:
  match fresh ready world:
    case FFreshPrefixState{next, fresh_ok} FReadyPrefixState{names, ctors, count, ready_ok} KBasePreparedWorld{state, prefix, final, saved, checked, seen, todos, bound}:
      match state:
        case KBasePrefixState{base_bound, delta, stamp, patches, checked_ok}:
          kc(P86Preparation, fresh_ok && ready_ok && checked_ok,
            u => P86PreparationReady{P86Seed{source, book, fresh, ready, world}},
            u => P86PreparationError{"base_prepare: prefix preparation was not eligible"})

@unsafe
def p86_import_error(imports: List<&2,KTerm>, found: Bool) -> String:
  match imports:
    case Nil{}: kc(String, found, u => "", u => "pilot requires import Base")
    case Con{+im, rest}: kc(String, String.eq(nm(im), "Base"),
      u => p86_import_error(rest, True{}), u => "pilot rejects additional import: " ++ nm(im))

@unsafe
def p86_plan(+seed: P86Seed, +path: String, +text: String) -> P86Plan:
  match seed:
    case P86Seed{+base, book, fresh, ready, world}:
      +begin = f_source_end(base)
      +source = f_source_located(FSource{path, path, text}, begin, U32.add(U32.add(begin, p86_width(text, 0)), 1))
      p86_plan_header(seed, source, f_source_header(source))

@unsafe
def p86_plan_header(+seed: P86Seed, +source: FSource, +header: FHeader) -> P86Plan:
  match header:
    case FHeader{imports, +error, body, line, offset}:
      kc(P86Plan, String.is_empty(error),
        u => p86_plan_imported(seed, source, header, p86_import_error(imports, False{})),
        u => P86PlanError{"parse: " ++ error})

@unsafe
def p86_plan_imported(+seed: P86Seed, +source: FSource, +header: FHeader, +error: String) -> P86Plan:
  kc(P86Plan, String.is_empty(error),
    u => p86_plan_seed(seed, source, header), u => P86PlanError{"load: " ++ error})

@unsafe
def p86_plan_seed(+seed: P86Seed, +source: FSource, +header: FHeader) -> P86Plan:
  match seed:
    case P86Seed{+base, +book, fresh, +ready, world}:
      p86_plan_seeded(seed, source, header,
        f_prefix_complete_ready_seed(base, "", f_prefix_graph_empty(), f_source_path(base), f_source_text(base), book, ready))

@unsafe
def p86_plan_seeded(+seed: P86Seed, +source: FSource, +header: FHeader, completion: FPrefixCompletion) -> P86Plan:
  match seed completion:
    case P86Seed{+base, book, fresh, ready, world} FPrefixCompletion{carrier, parsed}:
      match parsed:
        case FResult{defs, +error, imports}:
          kc(P86Plan, String.is_empty(error),
            u => p86_plan_completed(seed, source,
              f_prefix_complete_source(source, "", header, [source, base], carrier, f_path_dir(f_source_path(source)))),
            u => P86PlanError{"parse: " ++ error})

@unsafe
def p86_plan_completed(+seed: P86Seed, +source: FSource, completion: FPrefixCompletion) -> P86Plan:
  match seed completion:
    case P86Seed{+base, book, +fresh, ready, world} FPrefixCompletion{carrier, parsed}:
      p86_plan_loaded(seed, f_prefix_graph_trace(carrier, [source, base], fresh))

@unsafe
def p86_plan_loaded(+seed: P86Seed, +load: FPrefixLoad) -> P86Plan:
  match seed load:
    case P86Seed{base, book, fresh, ready, +world} FPrefixLoad{trace, prefix, suffix, eligible}:
      match trace:
        case FLoadTrace{result, done, sources}:
          match result:
            case FResult{+original, +error, imports}:
              kc(P86Plan, String.is_empty(error),
                u => p86_plan_checked(load, world, original, check_program_diagnostic_world(load, Nil{}, world)),
                u => P86PlanError{"parse: " ++ error})

@unsafe
def p86_plan_checked(+load: FPrefixLoad, +world: KBasePreparedWorld, +original: List<&2,KDef>, result: DResult) -> P86Plan:
  match result:
    case DResult{+error, +book, diagnostic}:
      kc(P86Plan, String.is_empty(error),
        u => p86_plan_reported(load, world, book, driver_report_data(original)),
        u => P86PlanError{"check: " ++ error})

@unsafe
def p86_plan_reported(+load: FPrefixLoad, +world: KBasePreparedWorld, +book: List<&2,KDef>, report: DR_Report) -> P86Plan:
  match report:
    case DR_Report{+verdict, names}:
      p86_plan_owned(load, world, book, verdict, driver_emit_owned(book))

@unsafe
def p86_plan_owned(+load: FPrefixLoad, +world: KBasePreparedWorld, +book: List<&2,KDef>, +verdict: String, +error: String) -> P86Plan:
  kc(P86Plan, String.is_empty(error),
    u => p86_plan_entry(load, world, book, verdict, j_compile_error(book)),
    u => P86PlanError{"compile: " ++ error})

@unsafe
def p86_plan_entry(+load: FPrefixLoad, +world: KBasePreparedWorld, +book: List<&2,KDef>, +verdict: String, +error: String) -> P86Plan:
  kc(P86Plan, String.is_empty(error),
    u => p86_plan_context(book_context_world(book, load, world), verdict),
    u => P86PlanError{"compile: " ++ error})

@unsafe
def p86_plan_context(+context: List<&2,KDef>, +verdict: String) -> P86Plan:
  +stops = nc_annotation_stops(context)
  p86_plan_annotated(context, stops, verdict, annotate_selected(context, reach_book(context, ["main"], stops), stops))

@unsafe
def p86_plan_annotated(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +annotated: List<&2,KDef>) -> P86Plan:
  +error = jl_checked_error(context, annotated, ["main"], stops)
  kc(P86Plan, String.is_empty(error),
    u => P86PlanReady{nr_prepare_annotated(context, annotated), verdict},
    u => P86PlanError{"compile: " ++ error})

# The root harness audits exact pinned Base and these three effect bytes before
# invocation. Arbitrary paths/foreign effects cannot acquire effectsSafe here.
@unsafe
def p86_effect_file(+base: String, +path: String) -> String:
  +dir = f_path_dir(base) ++ "effs/"
  +dot = f_path_dir(base) ++ "./effs/"
  kc(String, String.eq(path, dir ++ "args.c") || String.eq(path, dot ++ "args.c"), u => "args.c", u =>
    kc(String, String.eq(path, dir ++ "print.c") || String.eq(path, dot ++ "print.c"), u => "print.c", u =>
      kc(String, String.eq(path, dir ++ "now.c") || String.eq(path, dot ++ "now.c"), u => "now.c", u => "")))

@unsafe
def p86_effects(+request: NR_Request, +base: String, +directory: String, paths: List<&2,String>, +seen: List<&2,String>, +text: String) -> IO(String):
  match paths:
    case Nil{}: IO.pure(String, text)
    case Con{+path, +rest}:
      kc(IO(String), has_name(seen, path),
        u => p86_effects(request, base, directory, rest, seen, text),
        u => p86_effect_read(request, base, directory, path, rest, seen, text, p86_effect_file(base, path)))

@unsafe
def p86_effect_read(+request: NR_Request, +base: String, +directory: String, +path: String, +rest: List<&2,String>, +seen: List<&2,String>, +text: String, +file: String) -> IO(String):
  kc(IO(String), String.is_empty(file),
    u => IO.die(String, 1, "compile: pilot rejects foreign path " ++ path),
    u => do IO<String>:
      source : String <- p86_read_file(directory ++ "/" ++ file)
      p86_effect_parsed(request, base, directory, path, rest, seen, text, source))

@unsafe
def p86_effect_parsed(+request: NR_Request, +base: String, +directory: String, +path: String, +rest: List<&2,String>, +seen: List<&2,String>, +text: String, +source: String) -> IO(String):
  match request:
    case NR_Request{+book, erased, names, paths, +scope, bound}:
      p86_effect_checked(request, base, directory, path, rest, seen, text, source, kf_source(book, scope, path, source))

@unsafe
def p86_effect_checked(+request: NR_Request, +base: String, +directory: String, +path: String, +rest: List<&2,String>, +seen: List<&2,String>, +text: String, +source: String, +parsed: KF_Source) -> IO(String):
  match request parsed:
    case NR_Request{+book, erased, names, paths, +scope, bound} KF_Source{parts, +error}:
      kc(IO(String), String.is_empty(error),
        u => p86_effects(request, base, directory, rest, Con{path, seen}, text ++ kc(String, List.is_empty(&2, String, seen), v => "", v => "\n") ++ nc_foreign_source(book, scope, path, source, parsed)),
        u => IO.die(String, 1, "compile: " ++ error))

@unsafe
def p86_compile(plan: P86Plan, +runtime: NE_Runtime, +base: String, +directory: String) -> IO(P86Result):
  match plan:
    case P86PlanError{error}: IO.pure(P86Result, P86Result{"", error, ""})
    case P86PlanReady{+request, +verdict}:
      match request:
        case NR_Request{source, book, names, paths, scope, bound}:
          do IO<P86Result>:
            effects : String <- p86_effects(request, base, directory, paths, Nil{}, "")
            IO.pure(P86Result, p86_emitted(nr_compile_prepared(request, runtime, effects, True{}), verdict))

@unsafe
def p86_emitted(result: NC_Result, verdict: String) -> P86Result:
  match result:
    case NC_Result{source, error}: P86Result{source, error, verdict}

@unsafe
def p86_consumed(+result: P86Result) -> Nat:
  match result:
    case P86Result{source, error, verdict}: Nat.add(String.length(source), Nat.add(String.length(error), String.length(verdict)))

@unsafe
def p86_requests(+seed: P86Seed, +runtime: NE_Runtime, +input: String, +text: String, +base: String, +directory: String, +output: String, +left: U32, +call: U32) -> IO(U32):
  do IO<U32>:
    before : Nat <- IO.now()
    +result : P86Result <- p86_compile(p86_plan(seed, input, text), runtime, base, directory)
    consumed : Nat = p86_consumed(result)
    after : Nat <- IO.now()
    Unit <- IO.print_err("request=" ++ U32.show(call) ++ " request_ms=" ++ Nat.show(Nat.sub(after, before)) ++ " consumed_chars=" ++ Nat.show(consumed))
    p86_request_finished(seed, runtime, input, text, base, directory, output, left, call, result)

@unsafe
def p86_request_finished(+seed: P86Seed, +runtime: NE_Runtime, +input: String, +text: String, +base: String, +directory: String, +output: String, +left: U32, +call: U32, result: P86Result) -> IO(U32):
  match result:
    case P86Result{+source, +error, +verdict}:
      kc(IO(U32), String.is_empty(error),
        u => do IO<U32>:
          Unit <- p86_write_file(output ++ "." ++ U32.show(call) ++ ".c", source)
          kc(IO(U32), U32.is_eq(left, 1),
            v => do IO<U32>:
              Unit <- IO.print_err(verdict)
              IO.pure(U32, 0),
            v => p86_requests(seed, runtime, input, text, base, directory, output, U32.sub(left, 1), U32.add(call, 1))),
        u => IO.die(U32, 1, error))

@unsafe
def p86_runtime_prepared(+seed: P86Seed, +input: String, +text: String, +base: String, +directory: String, +output: String, +count: U32, +runtime: NE_Runtime, before: Nat) -> IO(U32):
  match runtime:
    case NE_Text{raw}: IO.die(U32, 1, "runtime_prepare: canonical template markers missing")
    case NE_Parts{parts}:
      do IO<U32>:
        after : Nat <- IO.now()
        Unit <- IO.print_err("runtime_prepare_ms=" ++ Nat.show(Nat.sub(after, before)))
        p86_requests(seed, runtime, input, text, base, directory, output, count, 1)

# The root verifies every part against the existing Bend-produced canonical
# template artifact and checks their concatenation against the raw runtime.
# This host transport replaces no compiler algorithm and rescans no template.
@unsafe
def p86_runtime_read(+path: String) -> IO(NE_Runtime):
  do IO<NE_Runtime>:
    part0 : String <- p86_read_file(path ++ ".part0")
    part1 : String <- p86_read_file(path ++ ".part1")
    part2 : String <- p86_read_file(path ++ ".part2")
    part3 : String <- p86_read_file(path ++ ".part3")
    part4 : String <- p86_read_file(path ++ ".part4")
    IO.pure(NE_Runtime, NE_Parts{[part0, part1, part2, part3, part4]})

@unsafe
def p86_base_prepared(+input: String, +text: String, +base: String, +runtime_path: String, +directory: String, +output: String, +count: U32, prepared: P86Preparation, before: Nat) -> IO(U32):
  match prepared:
    case P86PreparationError{error}: IO.die(U32, 1, error)
    case P86PreparationReady{seed}:
      do IO<U32>:
        after : Nat <- IO.now()
        Unit <- IO.print_err("base_prepare_ms=" ++ Nat.show(Nat.sub(after, before)))
        start : Nat <- IO.now()
        runtime : NE_Runtime <- p86_runtime_read(runtime_path)
        p86_runtime_prepared(seed, input, text, base, directory, output, count, runtime, start)

@unsafe
def p86_paths(+input: String, +base: String, runtime: String, +directory: String, +output: String, +count: U32) -> IO(U32):
  do IO<U32>:
    text : String <- p86_read_file(input)
    base_text : String <- p86_read_file(base)
    before : Nat <- IO.now()
    p86_base_prepared(input, text, base, runtime, directory, output, count, p86_prepare(base, base_text), before)

# Sized read plus EOF verification, adapted from the historical rapid host.
@unsafe
def p86_read_eof(pair: File & Result<&1,&1,U32 & String,String>, text: String) -> IO(String):
  (file, result) = pair
  do IO<String>:
    Unit <- File.close(file)
    tail : String <- IO.pass(String, result)
    kc(IO(String), String.is_empty(tail), u => IO.pure(String, text),
      u => IO.die(String, 1, "input was not completely read"))

@unsafe
def p86_read_more(pair: File & Result<&1,&1,U32 & String,String>) -> IO(String):
  (file, result) = pair
  match result:
    case Done{text}:
      do IO<String>:
        tail : File & Result<&1,&1,U32 & String,String> <- File.read(file, 1)
        p86_read_eof(tail, text)
    case Fail{error}:
      do IO<String>:
        Unit <- File.close(file)
        IO.pass(String, Fail{error})

@unsafe
def p86_read_sized(pair: File & Result<&1,&1,U32 & String,U32>) -> IO(String):
  (file, result) = pair
  match result:
    case Done{+size}:
      p86_read_limit(file, size, U32.is_le(size, 16777216))
    case Fail{error}:
      do IO<String>:
        Unit <- File.close(file)
        IO.pass(String, Fail{error})

@unsafe
def p86_read_limit(file: File, size: U32, allowed: Bool) -> IO(String):
  match allowed:
    case True{}:
      do IO<String>:
        read : File & Result<&1,&1,U32 & String,String> <- File.read(file, size)
        p86_read_more(read)
    case False{}:
      do IO<String>:
        Unit <- File.close(file)
        IO.die(String, 1, "input exceeds 16 MiB")

@unsafe
def p86_read_file(path: String) -> IO(String):
  do IO<String>:
    file : File <- IO.try(File, File.open(path, "r"))
    pair : File & Result<&1,&1,U32 & String,U32> <- File.size(file)
    p86_read_sized(pair)

@unsafe
def p86_write_close(pair: File & Result<&1,&1,U32 & String,Unit>) -> IO(Unit):
  (file, result) = pair
  do IO<Unit>:
    Unit <- File.close(file)
    IO.pass(Unit, result)

@unsafe
def p86_write_file(path: String, text: String) -> IO(Unit):
  do IO<Unit>:
    file : File <- IO.try(File, File.open(path, "w"))
    pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file, text)
    p86_write_close(pair)


# PRIVATE cache mode: the wrapper authenticates the complete carrier receipt,
# producer/Base/path/ABI and native consumer image before invoking this entry.
# A matching stamp alone grants no trust. Cache refusal never falls back silently.
@unsafe
def p88_cache_prepare(+path: String, +text: String, carrier: String, stamp: String) -> P86Preparation:
  +end = U32.add(p86_width(text,0),2)
  p88_cache_result(f_source_located(FSource{"Base",path,text},1,end),p88_decode_admitted(carrier,stamp,1,end))

@unsafe
def p88_cache_result(+source: FSource, decoded: P88Decoded) -> P86Preparation:
  match decoded:
    case P88DecodeError{error}: P86PreparationError{"base_cache: " ++ error}
    case P88DecodeReady{P88Products{book,fresh,ready,world}}:
      p86_prepare_states(source,book,fresh,ready,world)

@unsafe
def p88_cache_paths(+input: String, +base: String, runtime: String, +directory: String, +output: String, +count: U32, cache: String, stamp: String) -> IO(U32):
  do IO<U32>:
    text : String <- p86_read_file(input)
    base_text : String <- p86_read_file(base)
    before : Nat <- IO.now()
    carrier : String <- p86_read_file(cache)
    p86_base_prepared(input,text,base,runtime,directory,output,count,p88_cache_prepare(base,base_text,carrier,stamp),before)

@unsafe
def p88_cli_cache(+input: String, +base: String, +runtime: String, +directory: String, +output: String, +count: String, +cache: String, +stamp: String) -> IO(U32):
  kc(IO(U32),String.starts_with(input,"/") && String.starts_with(base,"/") && String.starts_with(runtime,"/") && String.starts_with(directory,"/") && String.starts_with(output,"/") && String.starts_with(cache,"/") && Bool.not(String.is_empty(stamp)) && (String.eq(count,"1") || String.eq(count,"5")),
    u => p88_cache_paths(input,base,runtime,directory,output,kc(U32,String.eq(count,"1"),v => 1,v => 5),cache,stamp),
    u => IO.die(U32,2,"expected absolute paths, COUNT 1 or 5, and authenticated cache stamp"))

@unsafe
def p86_cli(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{program, Con{+input, Con{+base, Con{+runtime, Con{+directory, Con{+output, Con{+count, Con{+cache, Con{+stamp, Nil{}}}}}}}}}}:
      p88_cli_cache(input,base,runtime,directory,output,count,cache,stamp)
    case Con{program, Con{+input, Con{+base, Con{+runtime, Con{+directory, Con{+output, Con{+count, Nil{}}}}}}}}:
      kc(IO(U32), String.starts_with(input, "/") && String.starts_with(base, "/") && String.starts_with(runtime, "/") && String.starts_with(directory, "/") && String.starts_with(output, "/") && (String.eq(count, "1") || String.eq(count, "5")),
        u => p86_paths(input, base, runtime, directory, output, kc(U32, String.eq(count, "1"), v => 1, v => 5)),
        u => IO.die(U32, 2, "expected absolute paths and COUNT 1 or 5"))
    case other: IO.die(U32, 2, "usage: compiler INPUT BASE RUNTIME EFFECTDIR OUTPUT COUNT [CACHE STAMP]")

@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p86_cli(args)
