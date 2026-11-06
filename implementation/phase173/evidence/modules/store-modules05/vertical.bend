# Real compiler-pass observations. Every body, reference occurrence, and source
# field is observable; hashes are not the semantic oracle. This module adds no
# production entry and does not replace a verifier.

type P173VInput is Data:
  P173VInput{+name: String, +body: KTerm}

type P173VBody is Data:
  P173VBody{+name: String, +body: KTerm, +references: List<&2,String>, +error: String}

@unsafe
def p173v_inputs_names(+book: List<&2,KDef>, names: List<&2,String>) -> List<&2,P173VInput>:
  match names:
    case Nil{}: []
    case Con{+name,+rest}:
      +definition = lookup(book,name)
      nt_choose(List<&2,P173VInput>,p88_string_eq(dk(definition),"Def") &&
        Bool.not(nc_native_def(definition) || nc_foreign(definition)),
        u => Con{P173VInput{name,nc_definition(book,definition,0)},p173v_inputs_names(book,rest)},
        u => p173v_inputs_names(book,rest))

@unsafe
def p173v_inputs(request: NR_Request) -> List<&2,P173VInput>:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}: p173v_inputs_names(book,names)

@unsafe
def p173v_baseline_body(input: P173VInput) -> P173VBody:
  match input:
    case P173VInput{name,body}:
      +compact = nc_compact(body)
      P173VBody{name,compact,nc_refs(compact),""}

@unsafe
def p173v_original_body(input: P173VInput) -> P173VBody:
  match input:
    case P173VInput{name,+body}: P173VBody{name,body,nc_refs(body),""}

@unsafe
def p173v_baseline(inputs: List<&2,P173VInput>) -> List<&2,P173VBody>:
  match inputs:
    case Nil{}: []
    case Con{head,rest}: Con{p173v_baseline_body(head),p173v_baseline(rest)}

# Reconstruct the complete real erasure/dependency result from the retained
# checked source. It is a separate diagnostic, not omitted from request cost.
@unsafe
def p173v_erasure(request: NR_Request) -> NR_Closure:
  match request:
    case NR_Request{+source,book,names,paths,scope,bound}:
      nr_walk(p144o_view(source,p144o_build(source)),["main"],[],[])

@unsafe
def p173v_control_ref(name: String, id: U32) -> KTerm:
  KTerm{"Ref",name,id,2,[],["retained-origin"],17,23}

# Finite data controls include all representation variants, ordered duplicate
# refs, static opaque nodes, string expansion, numeric compaction and dynamic
# Nat tails. These are compiler data; malformed values are never executed.
@unsafe
def p173v_control_term(mode: U32) -> KTerm:
    match mode:
      case 0: KTerm{"Ref","alpha",13,2,[],["removed"],5,12}
      case 1: KLambda{"x",7,2,[p173v_control_ref("beta",8)],["lambda-removed"],6,18,False{}}
      case 2: KLambda{"x",7,0,[p173v_control_ref("beta",8)],["lambda-removed"],6,18,True{}}
      case 3: KLiteral{"U32",4294967295,"4294967295",2,12}
      case 4: KLiteral{"F32",2147483648,"-0.0",2,6}
      case 5: KLiteral{"Nat",7,"7",3,4}
      case 6: KLiteral{"String",0,"a\nλ",3,10}
      case 7: KTerm{"Ctr","Zero",0,0,[],["zero-origin"],1,5}
      case 8: KTerm{"Ctr","Succ",0,0,[KLiteral{"Nat",5,"5",5,6}],[],1,6}
      case 9: KTerm{"Ctr","Succ",0,0,[KTerm{"Ctr","Succ",0,0,[p173v_control_ref("tail",4)],[],2,5}],[],1,6}
      case 10: KTerm{"App","application",19,2,[p173v_control_ref("z",1),p173v_control_ref("a",2),p173v_control_ref("z",1)],["app-removed"],9,24}
      case 11: KTerm{"NStatic","opaque",23,2,[p173v_control_ref("inside",6)],["must-survive"],9,24}
      case 12: KTerm{"Ctr","$OwnedCtor",7,1,[KLiteral{"U32",5,"5",2,3},p173v_control_ref("owned",4)],["owned-origin"],1,9}
      case 13: KTerm{"Let","binding",31,1,[p173v_control_ref("producer",3),KLambda{"y",32,1,[p173v_control_ref("consumer",4)],[],10,20,False{}}],[],1,21}
      case 14: KTerm{"Ref","empty-name-control",0,0,[],[],0,0}
      case _: KTerm{"Absent","",0,0,[],[],0,0}

@unsafe
def p173v_control(+mode: U32) -> P173VInput:
  P173VInput{"finite-" ++ U32.show(mode),p173v_control_term(mode)}

@unsafe
def p173v_control_inputs() -> List<&2,P173VInput>:
  [p173v_control(0),p173v_control(1),p173v_control(2),p173v_control(3),
    p173v_control(4),p173v_control(5),p173v_control(6),p173v_control(7),
    p173v_control(8),p173v_control(9),p173v_control(10),p173v_control(11),
    p173v_control(12),p173v_control(13),p173v_control(14),p173v_control(15)]
