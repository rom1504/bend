# Private exact-input transport for Phase154 prepared-book fixtures.
# Decimal mode1: nodeCount, stringCount, p88_text strings, then P88 tag/width/
# field records (tags0..7), and one role7 book root. All numbers end in LF;
# strings carry a Unicode codepoint count and one trailing LF. No extra bytes.
# This is not a production cache entry or an authentication boundary. The root
# harness pins input bytes and checks the decoded graph against the capture.
# P88State and raw buffers remain affine; no array-bearing Data wrapper exists.
type P154RResult is Data:
  P154RReady{+book: List<&2,KDef>}
  P154RError{+error: String}

@unsafe
def p154r_fields(state: P88State, +tag: U32, roles: List<&2,U32>, values: List<&2,P88Node>, +left: U32) -> P154RResult:
  match roles:
    case Nil{}: p154r_fields_finish(state,tag,values,left)
    case Con{role, rest}: p154r_fields_next(p88_field(state,role),tag,rest,values,left)

@unsafe
def p154r_fields_finish(state: P88State, tag: U32, values: List<&2,P88Node>, left: U32) -> P154RResult:
  match state:
    case P88State{cursor,nodes,strings,made,sn,+begin,+end}:
      p154r_record_put(P88State{cursor,nodes,strings,made,sn,begin,end},p88_build(tag,List.reverse(&2,P88Node,values),begin,end),left)

@unsafe
def p154r_fields_next(step: P88Step, tag: U32, roles: List<&2,U32>, values: List<&2,P88Node>, left: U32) -> P154RResult:
  match step:
    case P88Step{state, P88Bad{}}: P154RError{"phase154 input field"}
    case P88Step{state, value}: p154r_fields(state,tag,roles,Con{value,values},left)

@unsafe
def p154r_record_put(state: P88State, node: P88Node, left: U32) -> P154RResult:
  match state node:
    case s P88Bad{}: P154RError{"phase154 input record"}
    case P88State{cursor,nodes,strings,+made,sn,begin,end} n:
      p154r_records(P88State{cursor,Array.set(P88Node,nodes,made,n),strings,U32.inc(made),sn,begin,end},U32.sub(left,1))

@unsafe
def p154r_records(state: P88State, left: U32) -> P154RResult:
  match left:
    case 0: p154r_root(p88_field(state,7))
    case n: p154r_record_tag(p88_number(state),n)

@unsafe
def p154r_record_tag(step: P88Step, left: U32) -> P154RResult:
  match step:
    case P88Step{state,P88Word{+tag}}: p154r_record_tag_gate(state,tag,left,U32.is_le(tag,7))
    case P88Step{state,other}: P154RError{"phase154 input tag"}

@unsafe
def p154r_record_tag_gate(state: P88State, tag: U32, left: U32, ok: Bool) -> P154RResult:
  match ok:
    case False{}: P154RError{"phase154 input tag"}
    case True{}: p154r_record_width(p88_number(state),tag,left)

@unsafe
def p154r_record_width(step: P88Step, +tag: U32, left: U32) -> P154RResult:
  match step:
    case P88Step{state,P88Word{width}}:
      p154r_record_width_gate(state,tag,left,U32.is_eq(width,U32.from_nat(List.length(&2,U32,p88_roles(tag)))))
    case P88Step{state,other}: P154RError{"phase154 input width"}

@unsafe
def p154r_record_width_gate(state: P88State, +tag: U32, left: U32, ok: Bool) -> P154RResult:
  match ok:
    case False{}: P154RError{"phase154 input width"}
    case True{}: p154r_fields(state,tag,p88_roles(tag),Nil{},left)

@unsafe
def p154r_strings(state: P88State, +index: U32, +total: U32) -> P154RResult:
  match state:
    case P88State{cursor,nodes,strings,made,+sn,begin,end}:
      p154r_strings_gate(cursor,nodes,strings,made,sn,begin,end,index,total,U32.is_lt(index,sn))

@unsafe
def p154r_strings_gate(cursor: P88Cursor, nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, index: U32, total: U32, more: Bool) -> P154RResult:
  match more:
    case False{}: p154r_records(P88State{cursor,nodes,strings,made,sn,begin,end},total)
    case True{}: p154r_strings_read(nodes,strings,made,sn,begin,end,index,total,p88_text(cursor))

@unsafe
def p154r_root(step: P88Step) -> P154RResult:
  match step:
    case P88Step{state,P88Defs{book}}: p154r_done(state,book)
    case P88Step{state,other}: P154RError{"phase154 input root"}

@unsafe
def p154r_done(state: P88State, book: List<&2,KDef>) -> P154RResult:
  match state:
    case P88State{P88Cursor{SNil{},1},nodes,strings,made,sn,begin,end}: P154RReady{book}
    case other: P154RError{"phase154 input cursor or trailing data"}

@unsafe
def p154r_strings_read(nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32,
    +index: U32, total: U32, read: P88TextRead) -> P154RResult:
  match read:
    case P88TextRead{P88Cursor{text,1},value}:
      p154r_strings(P88State{P88Cursor{text,1},nodes,Array.set(String,strings,index,value),made,sn,begin,end},U32.inc(index),total)
    case other: P154RError{"phase154 input string"}

@unsafe
def p154r_read(text: String) -> P154RResult:
  p154r_nodes(p88_u32(P88Cursor{text,1}))

@unsafe
def p154r_nodes(read: P88Number) -> P154RResult:
  match read:
    case P88Number{cursor,n}: p154r_counts(p88_u32(cursor),n)

@unsafe
def p154r_counts(read: P88Number, +n: U32) -> P154RResult:
  match read:
    case P88Number{P88Cursor{text,+mode},+sn}:
      p154r_allocate(P88Cursor{text,mode},n,sn,
        U32.is_eq(mode,1) && U32.is_ge(n,1) && U32.is_le(n,262144) && U32.is_le(sn,8192))

@unsafe
def p154r_allocate(cursor: P88Cursor, +n: U32, +sn: U32, ok: Bool) -> P154RResult:
  match ok:
    case True{}:
      p154r_strings(P88State{cursor,Array.new(P88Node,p88_array_depth(n,1,0n),P88Bad{}),
        Array.new(String,p88_array_depth(sn,1,0n),""),0,sn,1,4294967295},0,n)
    case False{}: P154RError{"phase154 input header bounds"}

